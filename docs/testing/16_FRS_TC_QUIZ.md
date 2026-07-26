# Module: Quiz — Functional Requirements & Test Cases

> **Phần 1 = Đặc tả chức năng (Functional Spec)** — dev đọc phần này để biết cần implement gì, không cần đọc Test Case. **Phần 2 + 3 = Test Scenarios/Test Case** — tester dùng để kiểm thử. File gộp chung 2 mục đích để tránh 2 tài liệu lệch nhau khi sửa rule (xem `CLAUDE.md`).

## Phần 1 — Functional Requirements

### 1.1 Generate Quiz (sinh động, không phải entity tĩnh — xem D5)

**API:** `POST /api/quizzes/generate` (protected), body: `{sourceType: LESSON|COURSE|DECK|VOCAB_LIST, sourceId, questionCount: 10|20|50|ALL}`
**Main flow:** Backend truy vấn `Question` theo `sourceType/sourceId`, random chọn đủ `questionCount` (hoặc tất cả nếu `ALL`/tổng số câu ít hơn yêu cầu), random thứ tự câu và thứ tự `QuestionOption` trong mỗi câu → trả về danh sách câu hỏi cho FE (không kèm đáp án đúng).
**Exception flow:** Nguồn không có đủ Question theo `questionCount` yêu cầu → trả về tối đa số câu hiện có, kèm cảnh báo rõ ràng (không lỗi 500, không trả thiếu mà không giải thích). Nguồn không tồn tại → 404.
**Business Rule:** Bài tập ("Exercise") trong Lesson chính là Question có `sourceType=LESSON` — không có API/entity Exercise riêng (D4).

### 1.2 Làm bài & Nộp bài (Submit)

**API:** `POST /api/quizzes/attempts` (protected), body gồm danh sách câu trả lời của người dùng.
**Business Rule chấm điểm:** xem chi tiết đầy đủ ở `04_BUSINESS_RULES_GLOBAL.md` mục 5 (cách so khớp đáp án theo từng loại câu hỏi, cách tính `score`/`accuracy`/`xpEarned`).
**Main flow:** Backend so khớp từng câu trả lời với đáp án đúng → tạo `QuizAttempt` + các `QuizAttemptAnswer` → trả kết quả tổng hợp + chi tiết từng câu (đúng/sai/đáp án đúng/giải thích).

### 1.3 Lịch sử Quiz (Quiz History)

**API:** `GET /api/quizzes/attempts` (protected)
**Main flow:** Trả danh sách `QuizAttempt` của **chính user hiện tại**, sắp xếp theo `completedAt` giảm dần, phân trang. Xem chi tiết 1 attempt → trả lại từng câu kèm câu trả lời đã chọn/đáp án đúng.

## Phần 2 — Test Scenarios

1. Generate Quiz đúng số lượng câu theo lựa chọn (10/20/50/Tất cả).
2. Generate Quiz khi nguồn không đủ số câu yêu cầu.
3. Random thứ tự câu hỏi và đáp án giữa các lần generate khác nhau.
4. Làm bài & chấm điểm đúng cho từng loại câu hỏi (Multiple Choice, Fill Blank).
5. Câu bỏ qua (không trả lời) tính là sai.
6. Nộp bài — kết quả tổng hợp (score/accuracy/duration/xpEarned) chính xác.
7. Xem lại chi tiết 1 QuizAttempt — đúng/sai/đáp án đúng/giải thích hiển thị đúng.
8. Quiz History chỉ hiện của chính user, không lẫn của user khác.
9. XP cộng đúng sau khi hoàn thành Quiz, kể cả làm lại nhiều lần (không giới hạn số lần làm nhưng chỉ tính XP theo mỗi attempt).
10. Generate Quiz từ nguồn không tồn tại hoặc không có quyền truy cập.

## Phần 3 — Test Cases chi tiết

| ID | Tiêu đề | Precondition | Steps | Test Data | Expected Result | Priority |
|---|---|---|---|---|---|---|
| TC-QUIZ-001 | Generate Quiz 10 câu từ Lesson | Lesson 1 có ≥ 10 Question (xem `09_TEST_DATA.md` mục 8) | `POST /api/quizzes/generate` sourceType=LESSON, questionCount=10 | | Trả đúng 10 câu, không trùng lặp câu nào trong danh sách | Critical |
| TC-QUIZ-002 | Generate Quiz "Tất cả" | Lesson 1 có N Question | questionCount=ALL | | Trả đúng N câu | High |
| TC-QUIZ-003 | Generate Quiz khi nguồn không đủ câu | Nguồn chỉ có 5 Question | questionCount=10 | | Trả về 5 câu (tối đa hiện có) kèm cảnh báo rõ ràng, không lỗi 500 | High |
| TC-QUIZ-004 | Câu hỏi trả về không kèm đáp án đúng | Sau generate | Kiểm tra response JSON | | Field đánh dấu `isCorrect` của `QuestionOption` **không** xuất hiện trong response (tránh gian lận phía client) | Critical |
| TC-QUIZ-005 | Random thứ tự câu hỏi giữa 2 lần generate | Generate 2 lần liên tiếp cùng nguồn | So sánh thứ tự câu hỏi | | Thứ tự khác nhau (xác suất cao) giữa 2 lần | Medium |
| TC-QUIZ-006 | Random thứ tự đáp án | Generate Quiz Multiple Choice | So sánh thứ tự option giữa 2 câu hỏi cùng loại ở 2 lần generate | | Thứ tự đáp án đúng không cố định luôn ở vị trí A | Medium |
| TC-QUIZ-007 | Generate Quiz từ nguồn không tồn tại | | sourceType=LESSON, sourceId=999999 | | 404 | Medium |
| TC-QUIZ-008 | Generate Quiz từ Deck | Deck có Question liên kết (qua Vocabulary) | sourceType=DECK | | Trả câu hỏi liên quan đúng các từ trong Deck đó | High |
| TC-QUIZ-009 | Làm bài Multiple Choice — chọn đúng | Đã generate quiz | `POST /api/quizzes/attempts` với `selectedOptionId` đúng cho 1 câu | | Câu đó được chấm `isCorrect=true` | Critical |
| TC-QUIZ-010 | Làm bài Multiple Choice — chọn sai | | `selectedOptionId` sai | | `isCorrect=false` | Critical |
| TC-QUIZ-011 | Làm bài Fill in the Blank — đáp án đúng, khác hoa/thường | Câu Fill Blank đáp án đúng là "is" | `typedAnswer="IS"` | | Chấm đúng (không phân biệt hoa/thường theo `04_BUSINESS_RULES_GLOBAL.md` mục 5) | High |
| TC-QUIZ-012 | Làm bài Fill in the Blank — thừa khoảng trắng | | `typedAnswer="  is  "` | | Chấm đúng (đã trim khoảng trắng) | Medium |
| TC-QUIZ-013 | Làm bài Fill in the Blank — sai | | `typedAnswer="are"` | | Chấm sai | High |
| TC-QUIZ-014 | Bỏ qua 1 câu không trả lời | Quiz có 10 câu, chỉ trả lời 9 câu | Nộp bài | | Câu bị bỏ qua tính là sai, `wrongAnswers` tăng tương ứng, `totalQuestions=10` vẫn giữ nguyên | High |
| TC-QUIZ-015 | Nộp bài — tính điểm tổng hợp chính xác | Quiz 10 câu, đúng 7 | Nộp bài | | `correctAnswers=7`, `wrongAnswers=3`, `accuracy=70%`, `score` tương ứng | Critical |
| TC-QUIZ-016 | Nộp bài toàn bộ sai | 10 câu, đúng 0 | Nộp bài | | `xpEarned=0` (theo rule mục 5), `accuracy=0%` | High |
| TC-QUIZ-017 | Nộp bài toàn bộ đúng | 10 câu, đúng 10 | Nộp bài | | `accuracy=100%`, `xpEarned` > 0, cộng XP vào User + XpLog reason=QUIZ_COMPLETED | Critical |
| TC-QUIZ-018 | Xem chi tiết QuizAttempt sau khi nộp | Sau TC-QUIZ-015 | `GET /api/quizzes/attempts/{id}` | | Hiển thị đúng từng câu: câu trả lời đã chọn, đáp án đúng, giải thích (explanation) | High |
| TC-QUIZ-019 | Quiz History chỉ hiện của chính mình | user01 và user02 đều đã làm quiz | user02 gọi `GET /api/quizzes/attempts` | | Chỉ thấy QuizAttempt của user02, không lẫn của user01 | Critical |
| TC-QUIZ-020 | Xem chi tiết QuizAttempt của người khác | user02 biết id attempt của user01 | `GET /api/quizzes/attempts/{user01AttemptId}` bằng token user02 | | 403/404 | Critical |
| TC-QUIZ-021 | Làm lại Quiz nhiều lần cùng nguồn | Đã làm quiz Lesson 1 một lần | Generate + làm lại lần 2 | | Tạo `QuizAttempt` thứ 2 độc lập, XP cộng thêm đúng theo lần làm mới, không chặn làm lại | Medium |
| TC-QUIZ-022 | Nộp bài khi chưa login | Chưa login | `POST /api/quizzes/attempts` | | 401 | Critical |
| TC-QUIZ-023 | Nộp bài với questionId không thuộc quiz đã generate | Đã generate 1 quiz | `POST /api/quizzes/attempts` kèm 1 `questionId` ngoài danh sách đã generate | questionId của 1 câu hỏi thuộc Lesson khác | 400, không cho chấm điểm gian lận với câu hỏi ngoài phạm vi đã generate | High |
