# User Flows — Luồng người dùng xuyên nhiều màn hình

> Thể hiện các luồng end-to-end đi qua nhiều module/màn hình, giúp tester hiểu bối cảnh trước khi test từng bước riêng lẻ trong các file `FRS_TC_*.md`. Mỗi flow dưới đây nên được test tối thiểu 1 lần dạng "happy path" đầy đủ (end-to-end) sau khi các module liên quan đã hoàn thành, ngoài các test case chi tiết theo từng module.

## 1. Flow: Người dùng mới — Đăng ký đến bài học đầu tiên

```mermaid
flowchart TD
    A[Truy cập Landing Page] --> B[Đăng ký tài khoản]
    B --> C[Xác thực Email]
    C --> D[Đăng nhập]
    D --> E[Xem Dashboard lần đầu - rỗng]
    E --> F[Chọn ngôn ngữ học]
    F --> G[Duyệt danh sách Course]
    G --> H[Xem chi tiết Course]
    H --> I[Enroll Course]
    I --> J[Vào Lesson đầu tiên]
    J --> K[Học Vocabulary + Grammar]
    K --> L[Làm Quiz cuối Lesson]
    L --> M[Xem kết quả Quiz]
    M --> N[Lesson đánh dấu Completed]
    N --> O[Dashboard cập nhật: XP + Streak Day 1]
```

**Test case tham chiếu:** `11_FRS_TC_AUTH.md` (B→D), `13_FRS_TC_COURSE_LESSON.md` (F→N), `17_FRS_TC_PROGRESS_GAMIFICATION.md` (E, O).

## 2. Flow: Học bằng Deck cá nhân

```mermaid
flowchart TD
    A[Đăng nhập] --> B[Vào My Decks]
    B --> C[Create Deck mới]
    C --> D[Thêm từ vựng vào Deck]
    D --> E{Muốn học ngay?}
    E -->|Có| F[Học Flashcard - chọn chế độ]
    F --> G[Đánh giá Forgot/Hard/Good/Easy từng thẻ]
    G --> H[UserVocabularyProgress được tạo/cập nhật]
    E -->|Không| I[Đặt Deck Public]
    I --> J[Người dùng khác tìm thấy qua Search]
    J --> K[Người dùng khác Clone Deck]
    K --> L[Deck mới xuất hiện trong My Decks của họ]
```

**Test case tham chiếu:** `14_FRS_TC_DECK_FLASHCARD.md`, `15_FRS_TC_SRS_REVIEW.md` (G, H), `20_FRS_TC_SEARCH.md` (J).

## 3. Flow: Ôn tập hằng ngày (Review Today) & duy trì Streak

```mermaid
flowchart TD
    A[Đăng nhập ngày N] --> B[Dashboard hiển thị: X từ cần ôn hôm nay]
    B --> C[Vào Review Today]
    C --> D[Ôn từng từ - xem mặt trước, đoán nghĩa]
    D --> E[Đánh giá mức độ nhớ]
    E --> F[Hệ thống tính lại nextReviewDate theo SM-2]
    F --> G{Còn từ cần ôn?}
    G -->|Có| D
    G -->|Không| H[Hoàn thành Review Today]
    H --> I[UserDailyActivity ngày N được ghi nhận]
    I --> J{Có hoạt động ngày N-1 không?}
    J -->|Có| K[Current Streak += 1]
    J -->|Không| L[Current Streak reset về 1]
    K --> M[Longest Streak cập nhật nếu vượt kỷ lục]
    L --> M
```

**Test case tham chiếu:** `15_FRS_TC_SRS_REVIEW.md`, `17_FRS_TC_PROGRESS_GAMIFICATION.md` (Streak).

## 4. Flow: Làm Quiz và xem kết quả

```mermaid
flowchart TD
    A[Chọn nguồn Quiz: Lesson/Course/Deck] --> B[Chọn số lượng câu: 10/20/50/Tất cả]
    B --> C[Hệ thống generate câu hỏi random]
    C --> D[Người dùng làm từng câu]
    D --> E{Hết câu?}
    E -->|Chưa| D
    E -->|Rồi| F[Nộp bài]
    F --> G[Hệ thống chấm điểm]
    G --> H[Tạo QuizAttempt + QuizAttemptAnswer]
    H --> I[Hiển thị kết quả: điểm, đúng/sai, giải thích]
    I --> J[XP được cộng vào User + XpLog]
    I --> K[Lưu vào Quiz History]
```

**Test case tham chiếu:** `16_FRS_TC_QUIZ.md`.

## 5. Flow: Admin tạo nội dung học tập mới

```mermaid
flowchart TD
    A[Admin đăng nhập] --> B[Vào Admin Dashboard]
    B --> C[Course Management]
    C --> D[Tạo Course mới - status DRAFT]
    D --> E[Vào Lesson Management của Course đó]
    E --> F[Tạo Lesson mới]
    F --> G[Thêm Vocabulary vào Lesson]
    G --> H[Thêm Grammar vào Lesson]
    H --> I[Tạo Question cho Lesson sourceType=LESSON]
    I --> J[Chuyển Course status sang PUBLISHED]
    J --> K[Course xuất hiện trong danh sách User thấy]
```

**Test case tham chiếu:** `21_FRS_TC_ADMIN.md`, `13_FRS_TC_COURSE_LESSON.md` (K — kiểm tra từ phía User).

## 6. Flow: Quên mật khẩu

```mermaid
flowchart TD
    A[Trang Login] --> B[Bấm Forgot Password]
    B --> C[Nhập Email]
    C --> D[Hệ thống tạo VerificationToken type=PASSWORD_RESET]
    D --> E[Gửi link reset - MVP: log ra console/dev]
    E --> F[Người dùng mở link Reset Password]
    F --> G[Nhập mật khẩu mới + xác nhận]
    G --> H[Token bị đánh dấu used_at, hết hiệu lực]
    H --> I[Đăng nhập bằng mật khẩu mới thành công]
    I --> J{Đăng nhập bằng mật khẩu cũ?}
    J -->|Phải thất bại| K[401 Unauthorized]
```

**Test case tham chiếu:** `11_FRS_TC_AUTH.md`.

## 7. Flow: Access Token hết hạn giữa phiên làm việc

```mermaid
flowchart TD
    A[User đang thao tác trên app] --> B[Gọi API với Access Token]
    B --> C{Token còn hạn?}
    C -->|Còn| D[API xử lý bình thường]
    C -->|Hết hạn| E[API trả 401]
    E --> F[FE tự động gọi /api/auth/refresh-token]
    F --> G{Refresh Token còn hợp lệ?}
    G -->|Có| H[Nhận Access Token mới, tự động retry request ban đầu]
    G -->|Không/Revoked| I[Xoá session FE, redirect về Login]
```

**Test case tham chiếu:** `11_FRS_TC_AUTH.md`.
