# Database Verification Checklist

> Bổ sung cho các file `FRS_TC_*.md` — những file đó test qua **API/UI**; file này hướng dẫn tester xác minh **trực tiếp trong MySQL** rằng dữ liệu thực sự đúng, không chỉ tin vào response API (API có thể trả `200 OK` trong khi dữ liệu ghi sai). Dùng tài khoản `tester_ro`/`tester_rw` đã tạo ở `08_TEST_ENVIRONMENT_SETUP.md` mục 11 — **không** dùng tài khoản `root`/tài khoản Backend.

**Quy ước:** mọi câu lệnh dưới đây chạy trên database `language_learning` ở môi trường Local test, **không bao giờ** chạy trên môi trường có dữ liệu thật. Tên bảng/cột dùng snake_case theo JPA mặc định (Hibernate) — nếu Backend cấu hình naming strategy khác, đối chiếu lại với `07_DATA_DICTIONARY.md` và cập nhật câu lệnh cho khớp.

## 1. Khi nào cần test ở tầng DB

Không cần chạy SQL cho mọi test case — chỉ bổ sung xác minh DB cho các case mà **response API đúng vẫn có thể che giấu dữ liệu sai bên dưới**:

- Rule liên quan tổng hợp/tính toán (XP ledger, Streak, Quiz score) — API có thể trả đúng số cho 1 lần gọi nhưng dữ liệu gốc đã lệch.
- Rule về tính duy nhất/toàn vẹn quan hệ (SRS khoá theo `(user, vocabulary)`, Deck Clone độc lập, không trùng lặp DeckCard).
- Soft-delete — xác minh bản ghi **còn tồn tại** trong DB (chỉ ẩn) chứ không bị xoá cứng.
- Sau các thao tác xoá — xác minh không phát sinh dữ liệu mồ côi (orphan).

## 2. Bộ SQL xác minh Business Rules (map với `04_BUSINESS_RULES_GLOBAL.md`)

### 2.1 XP Ledger nhất quán (mục 1 — `04_BUSINESS_RULES_GLOBAL.md`)

```sql
-- Phải trả về 0 dòng. Nếu có dòng nào xuất hiện → User.xp bị lệch khỏi tổng XpLog → bug Critical.
SELECT u.id, u.username, u.xp AS xp_denormalized, COALESCE(SUM(x.amount), 0) AS xp_from_log
FROM users u
LEFT JOIN xp_log x ON x.user_id = u.id
GROUP BY u.id, u.username, u.xp
HAVING u.xp <> COALESCE(SUM(x.amount), 0);
```

### 2.2 Streak — Longest Streak không được nhỏ hơn Current Streak

```sql
-- Phải trả về 0 dòng.
SELECT user_id, current_streak, longest_streak
FROM user_streak
WHERE longest_streak < current_streak;
```

### 2.3 SRS — Không được có 2 bản ghi progress cho cùng 1 cặp (user, vocabulary) (D2)

```sql
-- Phải trả về 0 dòng. Đây là rule quan trọng nhất của hệ thống Deck/Lesson dùng chung từ vựng — xem TC-SRS-011.
SELECT user_id, vocabulary_id, COUNT(*) AS so_ban_ghi
FROM user_vocabulary_progress
GROUP BY user_id, vocabulary_id
HAVING COUNT(*) > 1;
```

### 2.4 Deck Clone — DeckCard của bản clone trỏ đúng cùng Vocabulary với deck gốc (D3)

```sql
-- Thay :cloned_deck_id và :original_deck_id bằng id thực tế sau khi test TC-DECK-017.
-- Kết quả 2 truy vấn phải trả về TẬP HỢP vocabulary_id giống hệt nhau.
SELECT vocabulary_id FROM deck_card WHERE deck_id = :cloned_deck_id ORDER BY vocabulary_id;
SELECT vocabulary_id FROM deck_card WHERE deck_id = :original_deck_id ORDER BY vocabulary_id;
```

```sql
-- Xác nhận deck clone có chủ sở hữu khác deck gốc và liên kết đúng clonedFromDeckId
SELECT id, owner_id, cloned_from_deck_id FROM deck WHERE id = :cloned_deck_id;
```

### 2.5 Quiz — tổng số câu phải khớp đúng cấu trúc (mục 5)

```sql
-- Phải trả về 0 dòng.
SELECT id, total_questions, correct_answers, wrong_answers
FROM quiz_attempt
WHERE total_questions <> (correct_answers + wrong_answers);
```

### 2.6 Enrollment/Lesson Progress không trùng lặp

```sql
-- Cả 2 câu phải trả về 0 dòng.
SELECT user_id, course_id, COUNT(*) FROM course_enrollment GROUP BY user_id, course_id HAVING COUNT(*) > 1;
SELECT user_id, lesson_id, COUNT(*) FROM lesson_progress GROUP BY user_id, lesson_id HAVING COUNT(*) > 1;
```

### 2.7 UserDailyActivity — không trùng ngày cho cùng 1 user

```sql
-- Phải trả về 0 dòng. Nếu có trùng → nguy cơ tính sai Streak/Daily Goal (liên quan rule timezone ở mục 2, 04_BUSINESS_RULES_GLOBAL.md).
SELECT user_id, activity_date, COUNT(*) FROM user_daily_activity GROUP BY user_id, activity_date HAVING COUNT(*) > 1;
```

### 2.8 Soft Delete — bản ghi "đã xoá" vẫn còn trong DB, chỉ bị đánh dấu

```sql
-- Sau khi Admin xoá 1 Course qua UI/API (TC-ADMIN-006), chạy lại:
SELECT id, title, is_deleted, deleted_at, deleted_by FROM course WHERE id = :deleted_course_id;
-- Kỳ vọng: vẫn trả về 1 dòng (không mất), is_deleted = 1, deleted_at/deleted_by có giá trị.
```

## 3. Test ràng buộc DB trực tiếp (dùng `tester_rw`, luôn ROLLBACK)

> Các test dưới đây cố tình chèn dữ liệu vi phạm rule để xác nhận DB **từ chối** — nếu DB cho phép insert thành công, đây là lỗ hổng schema (thiếu UNIQUE/FK/NOT NULL constraint), báo bug Critical vì đây là tuyến phòng thủ cuối cùng khi code Service có bug.

| ID | Tiêu đề | Câu lệnh | Expected Result | Priority |
|---|---|---|---|---|
| TC-DB-001 | Chặn trùng `(user_id, vocabulary_id)` trong `user_vocabulary_progress` | `START TRANSACTION;` sau đó `INSERT INTO user_vocabulary_progress (user_id, vocabulary_id, ease_factor, interval_days, repetition_count, next_review_date) VALUES (:existing_user_id, :existing_vocab_id, 2.5, 1, 0, CURDATE());` rồi `ROLLBACK;` | Insert bị từ chối bởi UNIQUE constraint (lỗi `Duplicate entry`) | Critical |
| TC-DB-002 | Chặn trùng `(deck_id, vocabulary_id)` trong `deck_card` | Insert trùng cặp đã tồn tại, sau đó `ROLLBACK;` | Bị từ chối bởi UNIQUE constraint | High |
| TC-DB-003 | Chặn `email` trùng trong `users` | Insert user mới với `email` đã tồn tại, sau đó `ROLLBACK;` | Bị từ chối bởi UNIQUE constraint | Critical |
| TC-DB-004 | Chặn `username` trùng trong `users` | Tương tự với `username`, sau đó `ROLLBACK;` | Bị từ chối | Critical |
| TC-DB-005 | Chặn FK không hợp lệ ở `lesson.course_id` | `INSERT INTO lesson (course_id, title, display_order, status) VALUES (999999, 'x', 1, 'DRAFT');` sau đó `ROLLBACK;` | Bị từ chối bởi FK constraint (nếu Hibernate đã sinh FK thật — nếu **không** bị chặn, ghi nhận đây là gap: `ddl-auto=update` có thể không tạo FK constraint, cần dev bổ sung thủ công hoặc chấp nhận rủi ro và ghi vào Known Issue) | High |
| TC-DB-006 | Chặn NOT NULL ở field bắt buộc | `INSERT INTO course (title) VALUES (NULL);` (bỏ các cột NOT NULL khác) sau đó `ROLLBACK;` | Bị từ chối | Medium |
| TC-DB-007 | Chặn trùng `(user_id, achievement_id)` trong `user_achievement` (Phase 2) | Insert trùng cặp đã tồn tại, sau đó `ROLLBACK;` | Bị từ chối bởi UNIQUE constraint | Medium |

**Lưu ý quan trọng:** nếu bất kỳ case nào ở mục 3 **không** bị DB từ chối (insert thành công), đây tự nó đã là một bug cần báo cáo — nhưng đừng quên `ROLLBACK;` ngay sau đó để không để lại dữ liệu rác trong DB test.

## 4. Kiểm tra dữ liệu mồ côi (Orphan Data) sau thao tác xoá

```sql
-- DeckCard trỏ tới Vocabulary đã bị soft-delete (không nên hiển thị nhưng bản ghi liên kết không nên "vô hình" gây lỗi khi load Deck)
SELECT dc.id, dc.deck_id, dc.vocabulary_id
FROM deck_card dc
JOIN vocabulary v ON v.id = dc.vocabulary_id
WHERE v.is_deleted = 1;
```

```sql
-- LessonVocabulary trỏ tới Vocabulary đã bị soft-delete
SELECT lv.lesson_id, lv.vocabulary_id
FROM lesson_vocabulary lv
JOIN vocabulary v ON v.id = lv.vocabulary_id
WHERE v.is_deleted = 1;
```

```sql
-- Question có source_type=LESSON nhưng Lesson gốc đã bị soft-delete
SELECT q.id, q.source_type, q.source_id
FROM question q
JOIN lesson l ON l.id = q.source_id AND q.source_type = 'LESSON'
WHERE l.is_deleted = 1;
```

```sql
-- CourseEnrollment còn tồn tại nhưng Course đã bị soft-delete — không phải lỗi (theo TC-ADMIN-012, dữ liệu tiến độ cũ phải giữ), nhưng cần xác nhận API xử lý đúng khi trả về danh sách "My Courses" (không được crash)
SELECT ce.id, ce.user_id, ce.course_id
FROM course_enrollment ce
JOIN course c ON c.id = ce.course_id
WHERE c.is_deleted = 1;
```

> Với mỗi query ở mục này: có kết quả trả về **không tự động là bug** — mục đích là để tester biết chính xác những trường hợp cần verify thủ công qua UI/API xem hệ thống có xử lý (ẩn/thông báo rõ ràng) đúng hay không, thay vì crash hoặc hiển thị dữ liệu rác.

## 5. Đối chiếu Schema thực tế với Data Dictionary

Sau mỗi lần thay đổi entity lớn (đặc biệt vì dự án dùng `ddl-auto=update`, không có migration script tường minh — xem rủi ro đã ghi ở `docs/PROJECT_OVERVIEW.md` mục 10.3), đối chiếu schema thật với `07_DATA_DICTIONARY.md`:

```sql
-- Liệt kê toàn bộ cột + kiểu dữ liệu + nullable của 1 bảng, so sánh thủ công với bảng tương ứng trong 07_DATA_DICTIONARY.md
DESCRIBE vocabulary;

-- Hoặc xem chi tiết hơn qua information_schema
SELECT column_name, data_type, is_nullable, column_default, character_maximum_length
FROM information_schema.columns
WHERE table_schema = 'language_learning' AND table_name = 'vocabulary'
ORDER BY ordinal_position;
```

**Checklist đối chiếu cho mỗi bảng quan trọng** (`users`, `course`, `lesson`, `vocabulary`, `deck`, `deck_card`, `user_vocabulary_progress`, `question`, `quiz_attempt`, `xp_log`):

- [ ] Số lượng cột khớp với Data Dictionary (không thiếu, không thừa cột "rác" do đổi tên field mà Hibernate sinh cột mới thay vì rename).
- [ ] Kiểu dữ liệu khớp (vd `varchar(200)` không bị Hibernate sinh thành `varchar(255)` mặc định nếu chưa khai báo `length` trong entity).
- [ ] Cột đánh dấu **Required** ở Data Dictionary thực sự là `NOT NULL` trong DB.
- [ ] Cột đánh dấu **Unique** thực sự có UNIQUE INDEX (`SHOW INDEX FROM table_name;`).
- [ ] Bảng audit (Content/Master data) có đủ `created_at, created_by, updated_at, updated_by, is_deleted, deleted_at, deleted_by`; bảng log (`xp_log`, `review_log`, `activity_history`, `quiz_attempt_answer`) **không** có các cột này thừa (đúng D9).

## 6. Ghi nhận kết quả

Sử dụng đúng `10_BUG_REPORT_TEMPLATE.md` khi báo lỗi phát hiện ở tầng DB — trong "Steps to Reproduce", dán nguyên câu lệnh SQL đã chạy và kết quả trả về, kèm ghi chú rõ đây là phát hiện ở tầng Database (không phải qua UI) để Dev không mất công tìm theo hướng Frontend.
