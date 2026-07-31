# Module: Spaced Repetition & Review — Functional Requirements & Test Cases

> **Phần 1 = Đặc tả chức năng (Functional Spec)** — dev đọc phần này để biết cần implement gì, không cần đọc Test Case. **Phần 2 + 3 = Test Scenarios/Test Case** — tester dùng để kiểm thử. File gộp chung 2 mục đích để tránh 2 tài liệu lệch nhau khi sửa rule (xem `CLAUDE.md`).

## Phần 1 — Functional Requirements

### 1.1 Review Today

**API:** `GET /api/review/today` (protected)
**Main flow:** Trả danh sách `Vocabulary` mà `UserVocabularyProgress.nextReviewDate` ≤ hôm nay (theo timezone user) đối với user hiện tại. Sắp xếp gợi ý: từ quá hạn lâu nhất trước, hoặc theo `masteryLevel` thấp trước (xác nhận rule ưu tiên cụ thể khi code).

### 1.2 Đánh giá mức độ nhớ (Submit Review)

**API:** `POST /api/review/{vocabularyId}` (protected), body: `{rating: FORGOT|HARD|GOOD|EASY}`
**Business Rule (SM-2 rút gọn — xem đầy đủ công thức ở `04_BUSINESS_RULES_GLOBAL.md` mục 3):**
- Nếu chưa có `UserVocabularyProgress` cho `(user, vocabulary)` → tạo mới với giá trị khởi tạo mặc định trước khi áp dụng rating.
- `Forgot` → reset `repetitionCount=0`, giảm `easeFactor` (không dưới sàn), `interval` reset về khoảng ngắn, `forgotCount += 1`.
- `Hard`/`Good`/`Easy` → `repetitionCount += 1`, `interval` tăng theo công thức tương ứng, `easeFactor` điều chỉnh theo mức đánh giá.
- `nextReviewDate` = ngày đánh giá + `interval` mới.
- `lastReviewDate` = ngày đánh giá hiện tại.
- Ghi 1 dòng vào `ReviewLog` (append-only) cho mỗi lần đánh giá — **không** ghi đè lịch sử cũ.
- Cộng XP theo reason `REVIEW_DONE` (xem `04_BUSINESS_RULES_GLOBAL.md` mục 1).
- Cập nhật `UserDailyActivity` của ngày hôm nay (theo timezone user) → ảnh hưởng Streak/Daily Goal.

### 1.3 Mức độ ghi nhớ (Mastery Level)

**Mô tả:** Suy ra từ `repetitionCount` và `easeFactor`/`forgotCount` — hiển thị cho người dùng biết mức độ thành thạo mỗi từ (vd trên Deck Detail hoặc trang từ vựng cá nhân). Không phải input trực tiếp, chỉ là giá trị tính toán.

## Phần 2 — Test Scenarios

1. Review Today trả đúng danh sách từ đến hạn, không trả từ chưa đến hạn.
2. Đánh giá 1 từ lần đầu (chưa có progress) → tạo bản ghi mới đúng giá trị khởi tạo.
3. Đánh giá Forgot → interval/repetitionCount reset đúng, forgotCount tăng.
4. Đánh giá Hard/Good/Easy → interval tăng theo đúng thứ tự (Easy tăng nhanh nhất, Hard chậm nhất).
5. `nextReviewDate` tính đúng theo interval mới.
6. Một từ xuất hiện ở cả Lesson và nhiều Deck khác nhau — chỉ có 1 progress duy nhất dùng chung (D2).
7. ReviewLog ghi nhận đầy đủ, không mất lịch sử qua nhiều lần đánh giá.
8. XP và UserDailyActivity cập nhật đúng sau mỗi lần review.
9. Review từ không thuộc sở hữu/không liên quan tới user hiện tại — không cho phép thao tác hộ user khác.
10. Review Today rỗng khi không có từ nào đến hạn — Empty State đúng.

## Phần 3 — Test Cases chi tiết

> **Trạng thái implement (2026-07-31, cập nhật sau khi retrofit XP ở Giai đoạn 7):** TC-SRS-001 → 016 (Review Today, đánh giá 4 loại rating, SM-2 rút gọn, `nextReviewDate`, tiến trình dùng chung giữa Lesson/Deck theo D2, ReviewLog append-only, 401/400) **đã test được**. TC-SRS-017 test được nhưng đơn giản hoá — Mastery Level tính thuần theo `repetitionCount` (không kết hợp `easeFactor`/`forgotCount`), xem `docs/PROJECT_OVERVIEW.md` mục 13 giới hạn phạm vi. TC-SRS-013, 014 (XP, `UserDailyActivity`) **đã test được** — `ReviewServiceImpl.submitReview` cộng XP `REVIEW_DONE` (2, mọi lần review) + `VOCAB_LEARNED` (10, chỉ lần review đầu của từ đó) và gọi `DailyActivityService.recordActivity` (retrofit Giai đoạn 7, xem `docs/dev/SCHEMA_CHANGE_LOG.md`), đã verify qua curl + kiểm DB trực tiếp (`xp_log`/`user_daily_activity`). TC-SRS-018 (timezone 23:59 vs 00:01) **về mặt code đã hỗ trợ đúng** — `DailyActivityServiceImpl.recordActivity` dùng `LocalDate.now(ZoneId.of(user.getTimezone()))` để tính `activityDate` (cùng cơ chế `nextReviewDate`/`lastReviewDate` của `UserVocabularyProgress` đã dùng từ trước) — nhưng **chưa test riêng qua curl đúng thời điểm biên 23:59/00:01** (cần canh giờ thật hoặc chỉnh giờ hệ thống để test, chưa thực hiện).

| ID | Tiêu đề | Precondition | Steps | Test Data | Expected Result | Priority |
|---|---|---|---|---|---|---|
| TC-SRS-001 | Review Today trả đúng danh sách từ đến hạn | user01 có từ "family" với `nextReviewDate=hôm nay` (xem `09_TEST_DATA.md`) | `GET /api/review/today` | | Danh sách chứa "family" | Critical |
| TC-SRS-002 | Review Today không trả từ chưa đến hạn | Từ có `nextReviewDate` = 5 ngày sau | `GET /api/review/today` | | Từ đó **không** xuất hiện trong danh sách | Critical |
| TC-SRS-003 | Review Today rỗng | User không có từ nào đến hạn hôm nay | `GET /api/review/today` | | Trả mảng rỗng, FE hiển thị Empty State "Không có từ cần ôn hôm nay" | Medium |
| TC-SRS-004 | Đánh giá từ lần đầu — Good | Từ "my_custom_word" chưa có UserVocabularyProgress | `POST /api/review/{vocabId}` rating=GOOD | | Tạo mới progress, `repetitionCount=1`, `easeFactor` mặc định (vd 2.5), `nextReviewDate` = hôm nay + interval mặc định | Critical |
| TC-SRS-005 | Đánh giá Forgot | Từ đã có progress với `repetitionCount=3` | rating=FORGOT | | `repetitionCount` reset về 0, `interval` reset ngắn, `forgotCount += 1`, `easeFactor` giảm nhưng không dưới sàn tối thiểu | Critical |
| TC-SRS-006 | Đánh giá Hard | Từ có progress hiện tại | rating=HARD | | `repetitionCount += 1`, `interval` tăng ít hơn so với Good | High |
| TC-SRS-007 | Đánh giá Good | Từ có progress hiện tại | rating=GOOD | | `repetitionCount += 1`, `interval` tăng theo công thức chuẩn | High |
| TC-SRS-008 | Đánh giá Easy | Từ có progress hiện tại | rating=EASY | | `repetitionCount += 1`, `interval` tăng nhiều hơn Good, `easeFactor` tăng | High |
| TC-SRS-009 | So sánh interval sau Easy vs Hard cùng điều kiện ban đầu | 2 từ có progress giống hệt nhau ban đầu | Đánh giá 1 từ Easy, 1 từ Hard | | interval sau Easy > interval sau Good > interval sau Hard | Critical |
| TC-SRS-010 | nextReviewDate tính đúng | Sau TC-SRS-007, biết interval trả về | Xem lại UserVocabularyProgress | | `nextReviewDate == ngày đánh giá + interval` chính xác | Critical |
| TC-SRS-011 | Một từ dùng chung giữa Lesson và Deck — progress duy nhất | Từ "family" vừa có ở Lesson 2 vừa có ở "My First Deck" của user01 | Đánh giá từ "family" khi học ở Deck | | Progress cập nhật; sau đó xem lại từ "family" khi học lại ở Lesson 2 → cùng 1 giá trị `nextReviewDate`/`repetitionCount`, không phải 2 bản ghi khác nhau | Critical |
| TC-SRS-012 | ReviewLog ghi nhận từng lần đánh giá | Đánh giá 1 từ 3 lần liên tiếp (3 ngày khác nhau, hoặc giả lập) | Xem lịch sử ReviewLog của từ đó | | Có đúng 3 dòng ReviewLog, không ghi đè lên nhau | Medium |
| TC-SRS-013 | XP cộng sau khi review | Trước và sau khi đánh giá 1 từ | So sánh `User.xp` trước/sau | | Tăng đúng theo rule `REVIEW_DONE` (xem `04_BUSINESS_RULES_GLOBAL.md`), có 1 dòng mới trong XpLog | High |
| TC-SRS-014 | UserDailyActivity cập nhật sau review | Trước khi có hoạt động trong ngày | Đánh giá 1 từ | | `UserDailyActivity` của "hôm nay" (theo timezone user) được tạo/cập nhật | Critical |
| TC-SRS-015 | Đánh giá từ khi chưa login | Chưa login | `POST /api/review/{vocabId}` | | 401 | Critical |
| TC-SRS-016 | Đánh giá với rating không hợp lệ | Đã login | rating="AMAZING" (giá trị không thuộc enum) | | 400 validate error | Medium |
| TC-SRS-017 | Mastery Level hiển thị đúng theo tiến trình | Từ mới học (repetitionCount=0) vs từ đã ôn nhiều lần thành công | So sánh Mastery Level hiển thị | | Từ mới = NEW/LEARNING, từ ôn nhiều = FAMILIAR/MASTERED — tăng dần đúng logic, không hiển thị ngẫu nhiên | Medium |
| TC-SRS-018 | Timezone — hoạt động 23:59 vs 00:01 giờ địa phương | User `user01` (Asia/Ho_Chi_Minh) | Đánh giá 1 từ lúc 23:59, đánh giá từ khác lúc 00:01 hôm sau (giờ VN) | | 2 `UserDailyActivity` khác nhau (2 ngày khác nhau theo giờ VN), không gộp thành 1 ngày dù giờ server (UTC) có thể cùng ngày UTC | Critical |
