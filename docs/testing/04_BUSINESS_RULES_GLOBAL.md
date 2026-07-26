# Business Rules — Quy tắc nghiệp vụ liên module

> Các quy tắc dùng chung bởi **nhiều module** phải được định nghĩa một nơi duy nhất để tránh mỗi module hiểu/áp dụng một kiểu khác nhau. Quy tắc riêng của từng module (không dùng chung) nằm trong section "Functional Requirements" của file `FRS_TC_*.md` tương ứng. Tester dùng file này làm nguồn xác định Expected Result cho các case liên quan XP/Streak/SRS/Ownership.

## 1. Quy tắc tính XP

XP được cộng vào `User.xp` (denormalized) đồng thời ghi 1 dòng vào `XpLog` mỗi khi phát sinh sự kiện:

| Sự kiện | Reason (XpLog) | Ghi chú |
|---|---|---|
| Học/ôn tập 1 từ vựng lần đầu | `VOCAB_LEARNED` | Chỉ tính khi từ chuyển từ trạng thái chưa học sang đã học lần đầu tiên, không tính mỗi lần xem lại |
| Hoàn thành 1 Lesson | `LESSON_COMPLETED` | Chỉ tính 1 lần cho mỗi Lesson/User — hoàn thành lại không cộng thêm XP |
| Hoàn thành 1 lượt Quiz | `QUIZ_COMPLETED` | Tính theo mỗi `QuizAttempt`, kể cả làm lại nhiều lần |
| Hoàn thành 1 lượt Review (đánh giá 1 từ ở Review Today) | `REVIEW_DONE` | Tính theo từng từ được đánh giá |
| Đạt Daily Goal trong ngày | `DAILY_GOAL_MET` | Chỉ cộng 1 lần/ngày, không cộng lặp nếu vượt mục tiêu nhiều lần |
| Unlock Achievement | `ACHIEVEMENT` | Cộng theo `xpReward` định nghĩa trên Achievement (Phase 2) |

**Quy tắc kiểm tra quan trọng:** `User.xp` (all-time) phải luôn bằng `SUM(XpLog.amount)` của user đó. Nếu lệch → bug Critical (sai lệch dữ liệu gamification, ảnh hưởng Leaderboard).

## 2. Quy tắc Streak & Daily Goal

- Mỗi hoạt động học hợp lệ (hoàn thành Lesson, học từ mới, ôn tập, làm Quiz) ghi nhận vào `UserDailyActivity` với `activityDate` = ngày hiện tại **theo timezone của User** (không phải theo giờ server/UTC).
- `Current Streak` tăng thêm 1 khi `UserDailyActivity` của "hôm nay" (theo timezone user) được tạo lần đầu **và** ngày liền trước đó (`lastActiveDate` + 1 ngày) cũng có hoạt động.
- Nếu người dùng bỏ lỡ ít nhất 1 ngày không có hoạt động, `Current Streak` phải reset về 1 vào lần học tiếp theo (không phải về 0 — vì ngày quay lại học cũng tính là 1 ngày streak).
- `Longest Streak` chỉ tăng, không bao giờ giảm — luôn bằng `MAX(longest_streak hiện tại, current_streak mới)`.
- `Daily Goal` được coi là "đạt" (`goal_met = true`) khi tổng `study_minutes` hoặc `words_learned` trong ngày (tuỳ loại goal người dùng chọn) ≥ giá trị mục tiêu đã đặt.
- **Test biên quan trọng:** hoạt động học lúc 23:59 và 00:01 giờ địa phương của user phải được tính vào **2 ngày khác nhau** — đây là rule hay bị lỗi nếu code dùng nhầm giờ server thay vì timezone user.

## 3. Quy tắc Spaced Repetition (SM-2 rút gọn cho mục đích test)

Áp dụng cho `UserVocabularyProgress` mỗi khi người dùng đánh giá một từ ở Review Today hoặc lần đầu học một từ:

| Đánh giá | Tác động đến `repetitionCount` | Tác động đến `easeFactor` | Tác động đến `interval` |
|---|---|---|---|
| **Forgot** | Reset về 0 | Giảm (tối thiểu không dưới ngưỡng sàn, vd 1.3) | Reset về khoảng ngắn (vd 1 ngày) |
| **Hard** | +1 | Giảm nhẹ | Tăng chậm hơn bình thường |
| **Good** | +1 | Giữ nguyên | Tăng theo công thức chuẩn (interval × easeFactor) |
| **Easy** | +1 | Tăng | Tăng nhanh hơn bình thường |

- `nextReviewDate` = ngày đánh giá + `interval` (ngày).
- `forgotCount` tăng 1 mỗi khi người dùng chọn Forgot (dùng để tính Mastery Level, không reset).
- **Từ mới học lần đầu** (chưa có `UserVocabularyProgress`) → hệ thống tạo bản ghi mới với giá trị khởi tạo mặc định (interval nhỏ, easeFactor mặc định thường là 2.5).
- **Quy tắc khoá theo cặp `(user, vocabulary)`**: nếu một từ xuất hiện ở cả Lesson và nhiều Deck khác nhau, chỉ có **một** bản ghi `UserVocabularyProgress` duy nhất cho từ đó với người dùng đó — đánh giá "Good" ở Deck A phải ảnh hưởng luôn tới lịch ôn khi từ đó xuất hiện lại ở Deck B hoặc Lesson.

## 4. Quy tắc Deck Clone

- Clone Deck tạo **Deck mới**: `ownerId` = user hiện tại, `clonedFromDeckId` = id deck gốc, `visibility` mặc định = `PRIVATE` (người clone tự quyết định công khai lại hay không).
- Các `DeckCard` của deck mới trỏ tới **cùng** `vocabularyId` với deck gốc — **không** tạo bản sao dữ liệu Vocabulary.
- Sau khi clone: sửa/xoá deck gốc (kể cả xoá hẳn deck gốc) **không được** làm mất hoặc hỏng deck đã clone.
- Người clone có toàn quyền sửa/xoá deck đã clone như deck tự tạo (vì giờ họ là owner của bản clone).
- `UserVocabularyProgress` của người clone đối với các từ trong deck **độc lập hoàn toàn** với người tạo deck gốc — clone deck không copy tiến độ ghi nhớ của chủ deck gốc.

## 5. Quy tắc Quiz — chấm điểm

- `score` / `accuracy` tính trên số câu đã trả lời đúng / tổng số câu (`totalQuestions`).
- Với `MULTIPLE_CHOICE`/`IMAGE_CHOICE`/`AUDIO_CHOICE`: đúng khi `selectedOptionId` trùng `QuestionOption.isCorrect = true`.
- Với `FILL_BLANK`/`TYPING`: đúng khi `typedAnswer` khớp đáp án đúng (không phân biệt hoa/thường, loại bỏ khoảng trắng thừa ở đầu/cuối).
- Câu không trả lời (bỏ qua) tính là **sai**, không tính là "chưa làm" riêng biệt trong `wrongAnswers`.
- `xpEarned` của một `QuizAttempt` tỉ lệ theo số câu đúng (chi tiết công thức xác định khi triển khai module Quiz — tối thiểu phải > 0 nếu có ít nhất 1 câu đúng, = 0 nếu toàn bộ sai).
- Random câu hỏi và random thứ tự đáp án chỉ áp dụng tại thời điểm **generate** quiz — trong cùng một `QuizAttempt`, thứ tự không đổi khi người dùng back/forward giữa các câu (nếu FE cho phép).

## 6. Quy tắc Ownership & Authorization (áp dụng toàn hệ thống)

- Mọi API sửa/xoá dữ liệu cá nhân (Deck, DeckCard, StudyReminder, Favorite...) phải kiểm tra `resource.ownerId == currentUserId` (lấy từ JWT/SecurityContext, **không** nhận `userId` từ request body/param).
- User A thao tác lên tài nguyên của User B (không phải của mình) → phải trả về lỗi **403 Forbidden**, không phải 404 (để nhất quán, trừ trường hợp cố ý ẩn sự tồn tại tài nguyên private — xác nhận cụ thể khi test từng API).
- Mọi endpoint dưới `/api/admin/**` chỉ Role `ADMIN` gọi được — User thường gọi phải trả về **403 Forbidden**.
- Người chưa đăng nhập gọi API `protected` phải trả về **401 Unauthorized**.

## 7. Quy tắc Soft Delete

- Áp dụng cho **Content/Master data** (User, Course, Lesson, Vocabulary, Deck, Achievement, Notification...): xoá = set `is_deleted = true`, bản ghi không còn xuất hiện trong danh sách/tìm kiếm thông thường nhưng vẫn tồn tại trong DB.
- **Không** áp dụng cho Log/Transaction data (`XpLog`, `ReviewLog`, `ActivityHistory`, `QuizAttemptAnswer`) — các bảng này không có khái niệm xoá mềm.
- Test quan trọng: sau khi Admin "xoá" một Course (soft delete), Course đó phải biến mất khỏi danh sách User thấy, nhưng dữ liệu tiến độ học (`CourseEnrollment`, `LessonProgress`) của User đã học trước đó **không bị mất** (không lỗi khi User xem lại lịch sử/Progress cũ).

## 8. Quy tắc dữ liệu đa ngôn ngữ (MVP)

- `Vocabulary.meaning` / `exampleTranslation` cố định là tiếng Việt trong MVP — **không** kỳ vọng có bản dịch theo `nativeLanguage` khác của user ở giai đoạn này (xem D11 trong `docs/PROJECT_OVERVIEW.md`).
- Course/Deck/Vocabulary luôn gắn với đúng 1 `Language` (ngôn ngữ đang học), không được để trống.

## 9. Quy tắc từ vựng dùng chung (D1)

- Một `Vocabulary` có thể được tham chiếu bởi nhiều `Lesson` (qua `LessonVocabulary`) và nhiều `Deck` (qua `DeckCard`) cùng lúc — sửa nội dung một `Vocabulary` (do Admin sửa system word) sẽ phản ánh ở **mọi nơi** đang tham chiếu tới nó.
- `Vocabulary` do User tự tạo (`ownerId` khác null) chỉ nên hiển thị/sửa được bởi chính user đó (không lẫn vào ngân hàng từ chung cho Lesson của Admin).
