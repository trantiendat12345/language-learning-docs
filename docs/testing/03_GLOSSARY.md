# Glossary — Thuật ngữ nghiệp vụ

> Tester đọc file này để hiểu đúng ý nghĩa thuật ngữ trước khi viết/thực thi Test Case, tránh hiểu sai dẫn đến Expected Result sai.

## A. Học tập chung

| Thuật ngữ | Giải thích |
|---|---|
| **Language** | Một ngôn ngữ hệ thống hỗ trợ để học (English, Japanese...). Course và Deck đều gắn với 1 Language. |
| **Course** | Khoá học có cấu trúc do Admin tạo (vd: "English Beginner A1"), gồm nhiều Lesson theo thứ tự. |
| **Lesson** | Một bài học nằm trong Course, chứa Vocabulary + Grammar + Question (Quiz/Exercise). |
| **Enroll** | Hành động người dùng "đăng ký học" một Course để bắt đầu theo dõi tiến độ (`CourseEnrollment`). |
| **Vocabulary** | Một từ vựng trong "từ điển" dùng chung của hệ thống (theo Language). Có thể do Admin tạo (system word) hoặc do User tự tạo (custom word, có `ownerId`). |
| **Grammar** | Một điểm ngữ pháp gắn với Lesson, gồm pattern, giải thích, ví dụ. |
| **Difficulty** | Mức độ khó của Course/Lesson/Vocabulary/Question (vd: BEGINNER/ELEMENTARY/INTERMEDIATE/ADVANCED hoặc A1–C2). |

## B. Deck & Flashcard

| Thuật ngữ | Giải thích |
|---|---|
| **Deck** | Bộ từ vựng do người dùng tự tạo, có thể Private (chỉ chủ sở hữu thấy) hoặc Public (mọi người tìm/xem/clone được). |
| **DeckCard** | Bản ghi liên kết một Vocabulary vào một Deck cụ thể (không copy dữ liệu từ, chỉ tham chiếu). |
| **Clone Deck / Copy Deck** | Sao chép một Public Deck về tài khoản của mình — tạo Deck mới thuộc sở hữu người clone, các DeckCard trỏ tới cùng Vocabulary gốc. Deck gốc bị sửa sau đó **không** ảnh hưởng đến bản đã clone. |
| **Flashcard** | Không phải là một loại dữ liệu riêng — chỉ là **cách hiển thị** một Vocabulary dưới dạng thẻ lật (mặt trước = từ, mặt sau = nghĩa/IPA/ví dụ/hình ảnh) khi học Deck hoặc Lesson. |
| **Flashcard mode — Normal** | Xem mặt trước (từ) → đoán nghĩa → lật xem mặt sau. |
| **Flashcard mode — Reverse** | Xem mặt sau (nghĩa) → đoán từ. |
| **Flashcard mode — Shuffle/Random** | Thứ tự các thẻ được xáo trộn ngẫu nhiên mỗi lượt học. |

## C. Spaced Repetition (Ôn tập ngắt quãng)

| Thuật ngữ | Giải thích |
|---|---|
| **SRS (Spaced Repetition System)** | Cơ chế lên lịch ôn tập dựa trên mức độ ghi nhớ thực tế của người học, thay vì học lại toàn bộ. |
| **SM-2** | Thuật toán tính khoảng cách ngày ôn tập tiếp theo, dựa trên `easeFactor`, `interval`, `repetitionCount` và đánh giá của người dùng (Forgot/Hard/Good/Easy). |
| **UserVocabularyProgress** | Bản ghi trạng thái ghi nhớ của **một người dùng** đối với **một từ vựng** cụ thể — duy nhất theo cặp `(user, vocabulary)`. Không phân biệt từ đó học từ Lesson hay từ Deck nào. |
| **Ease Factor** | Hệ số phản ánh độ "dễ nhớ" của một từ đối với người dùng — tăng khi trả lời tốt (Easy), giảm khi Forgot. |
| **Interval (Khoảng ôn)** | Số ngày cho đến lần ôn tập tiếp theo của một từ. |
| **Next Review Date** | Ngày hệ thống dự kiến người dùng nên ôn lại từ đó. |
| **Review Today** | Danh sách các từ có `nextReviewDate` ≤ hôm nay — người dùng cần ôn tập trong ngày. |
| **Mastery Level** | Mức độ thành thạo một từ (vd: NEW/LEARNING/FAMILIAR/MASTERED), suy ra từ `repetitionCount` và `easeFactor`. |
| **Rating: Forgot / Hard / Good / Easy** | 4 mức đánh giá người dùng chọn sau khi ôn một từ, quyết định `interval` tiếp theo tăng/giảm ra sao. |

## D. Quiz

| Thuật ngữ | Giải thích |
|---|---|
| **Question** | Một câu hỏi trong ngân hàng câu hỏi, gắn với một nguồn (`sourceType`/`sourceId`: LESSON, COURSE, DECK, VOCAB_LIST). Bài tập ("Exercise") trong Lesson thực chất là Question có `sourceType = LESSON`. |
| **Question Type** | Loại câu hỏi: Multiple Choice, Fill in the Blank, Typing, Listening, Matching, Reorder Sentence, Image Choice, Audio Choice. |
| **Quiz (hành động)** | Không phải một entity cố định — là **phiên làm bài** được sinh động (generate) từ ngân hàng Question theo nguồn và số lượng câu người dùng chọn. |
| **QuizAttempt** | Bản ghi một lần làm Quiz đã hoàn thành/nộp bài — gồm điểm số, số câu đúng/sai, thời gian làm, XP nhận được. Đây chính là "lịch sử Quiz". |
| **Accuracy** | Tỉ lệ phần trăm câu trả lời đúng trong một QuizAttempt. |

## E. Progress & Gamification

| Thuật ngữ | Giải thích |
|---|---|
| **XP (Experience Point)** | Điểm kinh nghiệm cộng dồn khi học từ, hoàn thành Lesson, làm Quiz, ôn tập, đạt Daily Goal. |
| **XpLog** | Nhật ký từng lần nhận XP (append-only) — dùng để tính XP theo khoảng thời gian (tuần/tháng) cho Leaderboard. |
| **Streak (Chuỗi ngày học)** | Số ngày liên tiếp người dùng có hoạt động học hợp lệ. `Current Streak` = chuỗi hiện tại, `Longest Streak` = kỷ lục dài nhất từng đạt. |
| **Daily Goal** | Mục tiêu học mỗi ngày do người dùng tự đặt (theo thời gian hoặc số từ). |
| **UserDailyActivity** | Bản ghi tổng hợp hoạt động học của một người dùng trong một ngày cụ thể (theo timezone của người dùng) — nền tảng để tính Streak và Daily Goal. |
| **Achievement** | Thành tích được unlock tự động khi người dùng đạt điều kiện nhất định (vd: học 100 từ, học 7 ngày liên tiếp). |
| **Leaderboard** | Bảng xếp hạng người dùng theo XP, theo kỳ Weekly/Monthly/All-time. |
| **Coin** | Đơn vị tiền ảo trong hệ thống (dự trữ cho tính năng tương lai — Premium/Shop). |

## F. Vai trò & Quyền

| Thuật ngữ | Giải thích |
|---|---|
| **Role** | Vai trò người dùng: `ADMIN` hoặc `USER` (MVP). |
| **Permission** | Quyền hạn chi tiết hơn Role (vd: `COURSE_CREATE`) — đã thiết kế sẵn ở tầng dữ liệu nhưng MVP chưa dùng, chỉ check theo Role. |
| **Ownership** | Quyền sở hữu dữ liệu cá nhân (vd: chủ Deck). Người dùng khác không phải chủ sở hữu (và không phải Admin) không được sửa/xoá dữ liệu đó. |

## G. Khác

| Thuật ngữ | Giải thích |
|---|---|
| **Soft Delete** | Xoá "mềm" — dữ liệu không bị xoá vật lý khỏi DB mà chỉ đánh dấu `is_deleted = true`, ẩn khỏi các truy vấn thông thường. |
| **Visibility (Deck)** | `PRIVATE` (chỉ chủ sở hữu thấy) hoặc `PUBLIC` (mọi người tìm kiếm/xem/clone được). |
| **Status** | Trạng thái chung của một bản ghi nội dung, ví dụ Course/Lesson: `DRAFT` (đang soạn, chưa hiển thị cho User) / `PUBLISHED` (đã công khai) / `ARCHIVED` (đã ẩn). |
