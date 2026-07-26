# Test Data — Dữ liệu kiểm thử mẫu

> Dữ liệu cụ thể cần seed vào database trước khi thực thi các file `FRS_TC_*.md`. Giữ file này đồng bộ với thực tế — khi thêm/sửa test case cần dữ liệu mới, cập nhật vào đây trước.

## 1. Tài khoản người dùng (User)

| Username | Email | Password | Role | Status | Timezone | Ghi chú |
|---|---|---|---|---|---|---|
| `admin01` | admin01@test.com | `Admin@123` | ADMIN | ACTIVE | Asia/Ho_Chi_Minh | Tài khoản quản trị chính |
| `user01` | user01@test.com | `User@123` | USER | ACTIVE | Asia/Ho_Chi_Minh | Tài khoản chính để test luồng học tập |
| `user02` | user02@test.com | `User@123` | USER | ACTIVE | Asia/Ho_Chi_Minh | Dùng cho test Ownership (user02 KHÔNG được sửa dữ liệu của user01) |
| `user03_pending` | user03@test.com | `User@123` | USER | PENDING_VERIFICATION | Asia/Ho_Chi_Minh | Test luồng chưa xác thực email |
| `user04_disabled` | user04@test.com | `User@123` | USER | DISABLED | Asia/Ho_Chi_Minh | Test đăng nhập khi tài khoản bị vô hiệu hoá |
| `user05_locked` | user05@test.com | `User@123` | USER | LOCKED | Asia/Ho_Chi_Minh | Test đăng nhập khi tài khoản bị khoá |
| `user06_utc` | user06@test.com | `User@123` | USER | ACTIVE | UTC | Test boundary Streak/Daily Goal ở timezone khác |

> Mật khẩu mẫu tuân thủ rule validate ở `11_FRS_TC_AUTH.md` (tối thiểu độ dài + có chữ/số). Không dùng các tài khoản này ngoài môi trường test.

## 2. Language

| Code | Name | Status |
|---|---|---|
| `en` | English | ACTIVE |
| `ja` | Japanese | ACTIVE |
| `ko` | Korean | INACTIVE |

> `ko` cố tình để `INACTIVE` — dùng để test filter danh sách Language/Course chỉ hiển thị ngôn ngữ `ACTIVE` (xem TC-COURSE-002 và các case filter tương tự).

## 3. Course

| Title | Language | Difficulty | Status | Ghi chú |
|---|---|---|---|---|
| English Beginner A1 | en | A1 | PUBLISHED | Course chính dùng test luồng học |
| English Elementary A2 | en | A2 | PUBLISHED | |
| IELTS Vocabulary Booster | en | B2 | PUBLISHED | |
| Business English (Draft) | en | B1 | DRAFT | Test: USER không được thấy course DRAFT |
| Japanese N5 | ja | N5 | PUBLISHED | Test đa ngôn ngữ |

## 4. Lesson (thuộc course "English Beginner A1")

| Title | Order | Status |
|---|---|---|
| Lesson 1: Introductions | 1 | PUBLISHED |
| Lesson 2: Family Members | 2 | PUBLISHED |
| Lesson 3: Numbers & Time (Draft) | 3 | DRAFT |

## 5. Vocabulary mẫu (language = en)

| Word | Meaning | Type | Owner | Ghi chú |
|---|---|---|---|---|
| apple | quả táo | noun | null (system) | Gắn vào Lesson 1 |
| hello | xin chào | interjection | null (system) | Gắn vào Lesson 1 |
| family | gia đình | noun | null (system) | Gắn vào Lesson 2, cũng thêm vào Deck mẫu của user01 |
| my_custom_word | (từ tự tạo) | noun | user01 | Test Vocabulary custom, chỉ user01 thấy/sửa được |

## 6. Grammar mẫu (thuộc Lesson 1)

| Title | Pattern |
|---|---|
| Simple Present — to be | S + am/is/are + ... |

## 7. Deck mẫu

| Title | Owner | Visibility | Ghi chú |
|---|---|---|---|
| My First Deck | user01 | PRIVATE | Chứa từ "family", dùng test Flashcard/SRS |
| TOEIC 600 Words | user01 | PUBLIC | Dùng để user02 test tìm kiếm & clone |
| user02's Private Deck | user02 | PRIVATE | Dùng test: user01 KHÔNG được thấy/sửa deck này |

## 8. Question mẫu (sourceType = LESSON, sourceId = Lesson 1)

| Type | Prompt | Đáp án đúng |
|---|---|---|
| MULTIPLE_CHOICE | "Apple" nghĩa là gì? | quả táo |
| FILL_BLANK | Hello, my name ___ John. | is |

Tối thiểu cần **≥ 10 Question** cho Lesson 1 để test đầy đủ case chọn "10 câu/20 câu/50 câu/Tất cả" ở `16_FRS_TC_QUIZ.md`.

## 9. Dữ liệu Progress/Gamification mẫu (cho user01)

| Dữ liệu | Giá trị mẫu | Mục đích |
|---|---|---|
| UserVocabularyProgress cho từ "family" | `nextReviewDate = hôm nay` | Test hiển thị trong Review Today |
| UserDailyActivity | có bản ghi cho "hôm qua" (theo timezone Asia/Ho_Chi_Minh) | Test tăng Streak khi học tiếp "hôm nay" |
| UserStreak | `currentStreak = 3`, `longestStreak = 5` | Test hiển thị Dashboard, test reset khi bỏ lỡ 1 ngày |
| XpLog | vài bản ghi trong tuần hiện tại và tuần trước | Test Leaderboard Weekly chỉ tính đúng tuần hiện tại |

## 10. Achievement mẫu (Phase 2, chuẩn bị trước)

| Code | Điều kiện | XP Reward |
|---|---|---|
| `FIRST_LESSON` | Hoàn thành 1 Lesson | 10 |
| `STREAK_7_DAYS` | Đạt Streak 7 ngày | 50 |
| `LEARN_100_WORDS` | Học 100 từ | 100 |

## 11. Quy tắc đặt lại dữ liệu test

- Trước mỗi phiên test **Regression** đầy đủ (`32_REGRESSION_SMOKE_CHECKLIST.md`), reset toàn bộ theo hướng dẫn `08_TEST_ENVIRONMENT_SETUP.md` mục 9, seed lại đúng bộ dữ liệu ở file này.
- Khi thêm Test Case mới cần dữ liệu chưa có trong danh sách trên, **bổ sung vào file này trước**, không tự tạo dữ liệu ad-hoc rồi quên không ghi lại — tester khác sẽ không tái hiện được kết quả test.
