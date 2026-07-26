# Business Requirements — Language Learning Platform

> Mô tả **hệ thống tồn tại để làm gì** và **cho ai** — khác với `docs/PROJECT_OVERVIEW.md` (nói về kiến trúc kỹ thuật "làm như thế nào"). Tester đọc file này để hiểu giá trị nghiệp vụ trước khi đi vào chi tiết chức năng.

## 1. Bối cảnh & Vấn đề cần giải quyết

Người học ngoại ngữ hiện tại thường phải dùng nhiều công cụ tách rời: một app học từ vựng theo flashcard (kiểu Quizlet/Anki), một app học theo lộ trình bài bản (kiểu Duolingo), và tự quản lý tiến độ ôn tập thủ công. Không có nền tảng nào kết hợp **cả lộ trình học có cấu trúc lẫn học tự do bằng flashcard cá nhân hoá**, cùng với cơ chế ôn tập ngắt quãng (spaced repetition) khoa học.

## 2. Mục tiêu kinh doanh

1. Xây dựng một nền tảng học ngoại ngữ độc lập, không phụ thuộc vào bên thứ ba, có thể vận hành và mở rộng lâu dài.
2. Ưu tiên trải nghiệm học tiếng Anh trước, nhưng kiến trúc không giới hạn — sẵn sàng mở rộng sang Nhật/Hàn/Trung/Pháp/Đức mà không cần thiết kế lại.
3. Giữ chân người học bằng cơ chế gamification (XP, Streak, Achievement, Leaderboard) và nhắc nhở học tập đều đặn.
4. Tạo nền tảng đủ vững để tương lai mở rộng thương mại hoá (Premium/Subscription) mà không phải viết lại hệ thống.

## 3. Đối tượng người dùng (User Personas)

| Persona | Mô tả | Nhu cầu chính |
|---|---|---|
| **Người học mới bắt đầu (Beginner)** | Chưa có nền tảng, muốn học theo lộ trình rõ ràng | Course có cấu trúc từ A1, hướng dẫn từng bước, không bị choáng ngợp |
| **Người tự học chủ động (Self-learner)** | Đã có nền tảng, muốn tự xây bộ từ vựng riêng theo nhu cầu (TOEIC, giao tiếp, chuyên ngành...) | Tạo Deck riêng, thêm từ tự do, ôn tập theo trí nhớ cá nhân |
| **Người ôn thi (Test-prep)** | Cần học theo mục tiêu cụ thể (IELTS, TOEIC) | Course/Deck chuyên đề, Quiz sát mục tiêu, theo dõi tiến độ rõ ràng |
| **Admin/Content Manager** | Người xây dựng & quản lý nội dung học tập | Công cụ CRUD hiệu quả, xem thống kê để biết nội dung nào hiệu quả |

## 4. Hai phương pháp học — giá trị nghiệp vụ

### 4.1 Course-based Learning
**Giá trị:** người mới không biết bắt đầu từ đâu → hệ thống dẫn dắt theo lộ trình `Language → Course → Lesson → (Vocabulary + Grammar + Quiz)` đã được Admin thiết kế sẵn, đảm bảo tính sư phạm (từ dễ đến khó, có ngữ cảnh).

### 4.2 Deck-based Learning (Flashcard cá nhân hoá)
**Giá trị:** người học chủ động tự xây dựng nội dung theo đúng nhu cầu cá nhân, không bị giới hạn bởi nội dung Admin cung cấp. Deck Public cho phép cộng đồng chia sẻ bộ từ chất lượng, giảm công sức tạo lại từ đầu.

### 4.3 Ôn tập ngắt quãng (Spaced Repetition)
**Giá trị cốt lõi khác biệt so với học thuộc lòng thông thường:** hệ thống tự tính thời điểm ôn tập tối ưu cho từng từ dựa trên mức độ ghi nhớ thực tế của người dùng (thuật toán SM-2), thay vì học lại tất cả hoặc học theo cảm tính.

## 5. Giá trị mang lại cho người dùng cuối
- Học một cách có hệ thống nhưng vẫn linh hoạt tự do.
- Không quên từ đã học nhờ cơ chế ôn tập khoa học.
- Được thúc đẩy duy trì thói quen học đều đặn (Streak, Daily Goal, Achievement).
- Có thể học nhiều ngôn ngữ trên cùng một nền tảng trong tương lai.

## 6. Phạm vi MVP theo góc nhìn nghiệp vụ

Người dùng MVP có thể hoàn thành trọn vẹn hành trình:
> Đăng ký → Đăng nhập → Chọn khoá học → Học Lesson (Từ vựng/Ngữ pháp) → Làm Quiz → Xem kết quả → Ôn tập từ đã học → Duy trì Streak.

Song song đó:
> Tạo Deck cá nhân → Thêm từ vựng → Học Flashcard → Ôn tập → Theo dõi mức độ ghi nhớ.

Admin có thể:
> Quản lý toàn bộ nội dung học tập (Language/Course/Lesson/Vocabulary/Grammar/Quiz) và quản lý người dùng.

Những gì **không** thuộc mục tiêu nghiệp vụ MVP (xem thêm `02_FEATURE_LIST.md` cột Phase): thanh toán/Premium, tính năng xã hội (follow/comment/chat), AI, ứng dụng di động.

## 7. Thước đo thành công (Success Metrics — tham khảo, không bắt buộc test)
- Tỷ lệ người dùng quay lại học liên tục ≥ 3 ngày (đo qua Streak).
- Tỷ lệ hoàn thành Lesson đã bắt đầu.
- Số từ vựng trung bình mỗi người dùng ôn tập mỗi ngày qua Review Today.

> Các chỉ số này không phải là test case, nhưng giúp tester hiểu **tại sao** một số chức năng (Streak, Review Today, Daily Goal) được xem là quan trọng/critical khi xác định Severity của bug liên quan.
