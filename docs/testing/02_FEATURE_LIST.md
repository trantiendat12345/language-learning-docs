# Feature List — Language Learning Platform

> Danh sách phẳng toàn bộ tính năng của hệ thống, dùng làm mục lục tra cứu nhanh và checklist coverage tổng quát. Chi tiết nghiệp vụ + test case nằm ở các file `FRS_TC_*.md` tương ứng (cột cuối).

Ký hiệu **Phase**: `MVP` = phải có trong bản đầu tiên · `P2` = Phase 2 · `P3` = Phase 3+ (tương lai xa, chưa thiết kế chi tiết).

## 1. Authentication & Account

| # | Tính năng | Phase | File Test Case |
|---|---|---|---|
| 1.1 | Đăng ký tài khoản (Register) | MVP | `11_FRS_TC_AUTH.md` |
| 1.2 | Đăng nhập (Login) | MVP | `11_FRS_TC_AUTH.md` |
| 1.3 | Đăng xuất (Logout) | MVP | `11_FRS_TC_AUTH.md` |
| 1.4 | Làm mới Access Token (Refresh Token) | MVP | `11_FRS_TC_AUTH.md` |
| 1.5 | Quên mật khẩu (Forgot Password) | MVP | `11_FRS_TC_AUTH.md` |
| 1.6 | Đặt lại mật khẩu (Reset Password) | MVP | `11_FRS_TC_AUTH.md` |
| 1.7 | Xác thực Email (Email Verification) | MVP | `11_FRS_TC_AUTH.md` |
| 1.8 | Đăng nhập qua Google/Facebook/Apple | P3 | — |

## 2. User Profile & Settings

| # | Tính năng | Phase | File Test Case |
|---|---|---|---|
| 2.1 | Xem hồ sơ cá nhân (My Profile) | MVP | `12_FRS_TC_USER_PROFILE.md` |
| 2.2 | Chỉnh sửa hồ sơ (Edit Profile) | MVP | `12_FRS_TC_USER_PROFILE.md` |
| 2.3 | Đổi mật khẩu (Change Password) | MVP | `12_FRS_TC_USER_PROFILE.md` |
| 2.4 | Cài đặt học tập (Learning Settings: Daily Goal, ngôn ngữ học) | MVP | `12_FRS_TC_USER_PROFILE.md` |
| 2.5 | Cài đặt chung (Theme Light/Dark, thông báo) | MVP | `12_FRS_TC_USER_PROFILE.md` |

## 3. Language / Course / Lesson / Vocabulary / Grammar

| # | Tính năng | Phase | File Test Case |
|---|---|---|---|
| 3.1 | Xem danh sách ngôn ngữ hỗ trợ | MVP | `13_FRS_TC_COURSE_LESSON.md` |
| 3.2 | Xem danh sách Course (search/filter theo Language, Level) | MVP | `13_FRS_TC_COURSE_LESSON.md` |
| 3.3 | Xem chi tiết Course | MVP | `13_FRS_TC_COURSE_LESSON.md` |
| 3.4 | Đăng ký học Course (Enroll) | MVP | `13_FRS_TC_COURSE_LESSON.md` |
| 3.5 | Tiếp tục học (Continue Learning) | MVP | `13_FRS_TC_COURSE_LESSON.md` |
| 3.6 | Theo dõi tiến độ Course (Course Progress) | MVP | `13_FRS_TC_COURSE_LESSON.md`, `17_FRS_TC_PROGRESS_GAMIFICATION.md` |
| 3.7 | Học nội dung Lesson (Vocabulary + Grammar) | MVP | `13_FRS_TC_COURSE_LESSON.md` |
| 3.8 | Đánh dấu hoàn thành Lesson | MVP | `13_FRS_TC_COURSE_LESSON.md` |
| 3.9 | Nghe phát âm từ vựng (Audio) | MVP | `13_FRS_TC_COURSE_LESSON.md` |
| 3.10 | Xem từ đồng nghĩa/trái nghĩa (Synonym/Antonym) | P2 | `13_FRS_TC_COURSE_LESSON.md` |

## 4. Deck & Flashcard

| # | Tính năng | Phase | File Test Case |
|---|---|---|---|
| 4.1 | Tạo Deck (Create Deck) | MVP | `14_FRS_TC_DECK_FLASHCARD.md` |
| 4.2 | Sửa Deck (Update Deck) | MVP | `14_FRS_TC_DECK_FLASHCARD.md` |
| 4.3 | Xoá Deck (Delete Deck) | MVP | `14_FRS_TC_DECK_FLASHCARD.md` |
| 4.4 | Thêm từ vựng vào Deck | MVP | `14_FRS_TC_DECK_FLASHCARD.md` |
| 4.5 | Sửa/Xoá từ vựng trong Deck | MVP | `14_FRS_TC_DECK_FLASHCARD.md` |
| 4.6 | Đặt Deck Public/Private | MVP | `14_FRS_TC_DECK_FLASHCARD.md` |
| 4.7 | Tìm kiếm Public Deck | MVP | `14_FRS_TC_DECK_FLASHCARD.md`, `20_FRS_TC_SEARCH.md` |
| 4.8 | Sao chép (Clone) Public Deck | MVP | `14_FRS_TC_DECK_FLASHCARD.md` |
| 4.9 | Học Flashcard — chế độ Normal | MVP | `14_FRS_TC_DECK_FLASHCARD.md` |
| 4.10 | Học Flashcard — chế độ Reverse/Shuffle/Random | MVP | `14_FRS_TC_DECK_FLASHCARD.md` |
| 4.11 | Học Flashcard — nghe audio nhập từ / xem hình chọn từ | P2 | `14_FRS_TC_DECK_FLASHCARD.md` |

## 5. Spaced Repetition (Ôn tập)

| # | Tính năng | Phase | File Test Case |
|---|---|---|---|
| 5.1 | Xem danh sách từ cần ôn hôm nay (Review Today) | MVP | `15_FRS_TC_SRS_REVIEW.md` |
| 5.2 | Đánh giá mức độ nhớ (Forgot/Hard/Good/Easy) | MVP | `15_FRS_TC_SRS_REVIEW.md` |
| 5.3 | Hệ thống tự tính ngày ôn tiếp theo (SM-2) | MVP | `15_FRS_TC_SRS_REVIEW.md` |
| 5.4 | Xem mức độ ghi nhớ từng từ (Mastery Level) | MVP | `15_FRS_TC_SRS_REVIEW.md` |

## 6. Quiz

| # | Tính năng | Phase | File Test Case |
|---|---|---|---|
| 6.1 | Tạo Quiz từ Lesson/Course/Deck/Vocabulary List | MVP | `16_FRS_TC_QUIZ.md` |
| 6.2 | Chọn số lượng câu hỏi (10/20/50/Tất cả) | MVP | `16_FRS_TC_QUIZ.md` |
| 6.3 | Làm Quiz — Multiple Choice | MVP | `16_FRS_TC_QUIZ.md` |
| 6.4 | Làm Quiz — Fill in the Blank | MVP | `16_FRS_TC_QUIZ.md` |
| 6.5 | Làm Quiz — Typing/Listening/Matching/Reorder/Image/Audio Choice | P2 | `16_FRS_TC_QUIZ.md` |
| 6.6 | Nộp bài & chấm điểm tự động | MVP | `16_FRS_TC_QUIZ.md` |
| 6.7 | Xem kết quả Quiz (đúng/sai/giải thích) | MVP | `16_FRS_TC_QUIZ.md` |
| 6.8 | Xem lịch sử Quiz (Quiz History) | MVP | `16_FRS_TC_QUIZ.md` |

## 7. Progress & Gamification

| # | Tính năng | Phase | File Test Case |
|---|---|---|---|
| 7.1 | Dashboard tổng quan sau đăng nhập | MVP | `17_FRS_TC_PROGRESS_GAMIFICATION.md` |
| 7.2 | Đặt mục tiêu học hằng ngày (Daily Goal) | MVP | `17_FRS_TC_PROGRESS_GAMIFICATION.md` |
| 7.3 | Theo dõi Streak (Current/Longest) | MVP | `17_FRS_TC_PROGRESS_GAMIFICATION.md` |
| 7.4 | Nhận XP khi học/ôn tập/làm Quiz | MVP | `17_FRS_TC_PROGRESS_GAMIFICATION.md` |
| 7.5 | Hệ thống Achievement (unlock tự động) | P2 | `17_FRS_TC_PROGRESS_GAMIFICATION.md` |
| 7.6 | Leaderboard (Weekly/Monthly/All-time) | P2 | `17_FRS_TC_PROGRESS_GAMIFICATION.md` |
| 7.7 | Hệ thống Coin | P2 | `17_FRS_TC_PROGRESS_GAMIFICATION.md` |

## 8. Favorite / History / Notification / Search

| # | Tính năng | Phase | File Test Case |
|---|---|---|---|
| 8.1 | Favorite Course/Deck/Vocabulary | MVP | `18_FRS_TC_FAVORITE_HISTORY.md` |
| 8.2 | Xem danh sách My Favorites | MVP | `18_FRS_TC_FAVORITE_HISTORY.md` |
| 8.3 | Xem lịch sử vừa xem/vừa học/vừa ôn (History) | MVP | `18_FRS_TC_FAVORITE_HISTORY.md` |
| 8.4 | Nhận thông báo trong app (In-app Notification) | MVP | `19_FRS_TC_NOTIFICATION_REMINDER.md` |
| 8.5 | Đánh dấu đã đọc / đọc tất cả | MVP | `19_FRS_TC_NOTIFICATION_REMINDER.md` |
| 8.6 | Đặt giờ nhắc học (Study Reminder) | MVP | `19_FRS_TC_NOTIFICATION_REMINDER.md` |
| 8.7 | Gửi thông báo qua Email/Push thật | P2 | `19_FRS_TC_NOTIFICATION_REMINDER.md` |
| 8.8 | Tìm kiếm toàn hệ thống (Course/Lesson/Vocabulary/Grammar/Public Deck) | MVP | `20_FRS_TC_SEARCH.md` |

## 9. Admin

| # | Tính năng | Phase | File Test Case |
|---|---|---|---|
| 9.1 | Admin Dashboard (số liệu tổng quan) | MVP | `21_FRS_TC_ADMIN.md` |
| 9.2 | CRUD Language | MVP | `21_FRS_TC_ADMIN.md` |
| 9.3 | CRUD Course | MVP | `21_FRS_TC_ADMIN.md` |
| 9.4 | CRUD Lesson | MVP | `21_FRS_TC_ADMIN.md` |
| 9.5 | CRUD Vocabulary | MVP | `21_FRS_TC_ADMIN.md` |
| 9.6 | CRUD Grammar | MVP | `21_FRS_TC_ADMIN.md` |
| 9.7 | CRUD Question (ngân hàng câu hỏi Quiz) | MVP | `21_FRS_TC_ADMIN.md` |
| 9.8 | Quản lý User (Activate/Disable/Lock, xem tiến độ) | MVP | `21_FRS_TC_ADMIN.md` |
| 9.9 | CRUD Achievement | P2 | `21_FRS_TC_ADMIN.md` |
| 9.10 | Quản lý Notification (broadcast) | P2 | `21_FRS_TC_ADMIN.md` |
| 9.11 | Biểu đồ thống kê nâng cao (Learning Trends, Popular Courses) | P2 | `21_FRS_TC_ADMIN.md` |

## 10. Ngoài phạm vi MVP (tham khảo, chưa có Test Case)

Payment/Premium/Subscription (P3) · Study Plan AI-personalized (P3) · Social: Follow/Friends/Comment/Study Group (P3) · Import/Export CSV/Anki (P2) · AI Generate Quiz/Flashcard/Chatbot (P3) · PWA/Mobile App/Offline Mode (P3).

## 11. Tổng số tính năng
- MVP: 47 tính năng
- Phase 2: 13 tính năng
- Phase 3+: liệt kê tham khảo ở mục 10, chưa breakdown chi tiết vì chưa thiết kế kỹ thuật.
