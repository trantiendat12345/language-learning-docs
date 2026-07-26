# Security Checklist — Kiểm thử bảo mật thủ công (mức cơ bản)

> **Phạm vi:** đây là checklist kiểm thử bảo mật thủ công ở mức tester thông thường có thể thực hiện — **không thay thế** Penetration Testing chuyên sâu (ngoài phạm vi MVP, xem `00_TEST_PLAN.md` mục 2.2). Mục tiêu: bắt các lỗi bảo mật cơ bản và dễ mắc phải nhất trong một dự án cá nhân.

## 1. Authentication & Session

- [ ] Không đăng nhập được với mật khẩu sai bất kể số lần thử (kiểm tra không có cách bypass qua request thủ công/Postman).
- [ ] Access Token hết hạn đúng thời gian cấu hình (`JWT_EXPIRATION`) — dùng token cũ sau khi hết hạn phải bị từ chối (401).
- [ ] Refresh Token bị revoke (sau logout/đổi mật khẩu/reset mật khẩu) không dùng lại được.
- [ ] Không thể dùng Access Token của người dùng này để giả mạo request thay người dùng khác (token không thể chỉnh sửa `userId` từ phía client — mọi thông tin user lấy từ token đã ký, không từ param/body).
- [ ] JWT không chứa dữ liệu nhạy cảm (password, số điện thoại...) khi decode thủ công (dán token vào jwt.io để kiểm tra payload).

## 2. Authorization (tham chiếu đầy đủ tại `06_ROLES_PERMISSIONS_MATRIX.md`)

- [ ] Test toàn bộ API `protected` với: không có token / token hết hạn / token của role khác → đúng 401/403 theo từng trường hợp.
- [ ] User A không thể sửa/xoá dữ liệu sở hữu bởi User B (Deck, Favorite, StudyReminder, Vocabulary custom...) — thử với **ID thật lấy từ user khác**, không chỉ ID ngẫu nhiên.
- [ ] Không có cách nào (qua param, header, body) để một USER tự nâng quyền thành ADMIN hoặc mạo danh `userId` khác.
- [ ] Toàn bộ `/api/admin/**` chặn đúng với USER thường.

## 3. Input Validation & Injection

- [ ] SQL Injection: thử các chuỗi kinh điển (`' OR '1'='1`, `'; DROP TABLE users;--`) vào mọi field text (username, email, search keyword, title Deck/Course...) → không gây lỗi 500, không trả dữ liệu bất thường, không có bằng chứng câu lệnh được thực thi trực tiếp (nhờ JPA/Hibernate tham số hoá).
- [ ] XSS cơ bản: nhập `<script>alert(1)</script>` vào các field hiển thị lại cho người khác xem (Deck title/description, Course description, displayName...) → khi hiển thị lại (đặc biệt ở Public Deck mà người khác xem), script **không được thực thi** (kiểm tra FE có escape/sanitize đúng, không dùng `dangerouslySetInnerHTML` không kiểm soát).
- [ ] Input quá dài (vượt giới hạn `varchar`) → bị chặn ở tầng validate (400), không gây lỗi 500 ở tầng DB.
- [ ] Upload/URL ảnh (avatar, thumbnail, cover Deck) — nếu cho nhập URL tự do, kiểm tra không cho phép `javascript:` URL scheme gây XSS khi render `<img src>`.

## 4. Lộ dữ liệu nhạy cảm (Sensitive Data Exposure)

- [ ] Rà soát **toàn bộ** response API (đặc biệt Login, Register, Get Profile, Admin Get Users) — không có field `password`/`passwordHash` dưới bất kỳ tên field nào.
- [ ] Refresh Token thật không xuất hiện trong response body nếu thiết kế dùng httpOnly cookie (chỉ set qua header `Set-Cookie`, không lặp lại trong JSON).
- [ ] Thông báo lỗi (403/401/400) không tiết lộ thông tin nội bộ (không có stack trace, không lộ tên bảng/cấu trúc DB, không lộ đường dẫn file server).
- [ ] Thông báo "sai username/password" và "username không tồn tại" giống hệt nhau (tránh dò tài khoản — xem TC-AUTH-009/010).
- [ ] Forgot Password không tiết lộ email có tồn tại trong hệ thống hay không (xem TC-AUTH-020).

## 5. CORS & Cấu hình

- [ ] Gọi API từ origin lạ (không phải `localhost:5173` cấu hình) bị chặn bởi CORS policy (test bằng cách đổi tạm `VITE_API_BASE_URL` sang domain khác hoặc dùng công cụ gọi thử từ origin khác).
- [ ] Không có secret (JWT_SECRET, DB_PASSWORD) xuất hiện trong bất kỳ response nào, log lỗi trả về client, hoặc bundle JS phía Frontend (kiểm tra Network tab và view-source).
- [ ] File `.env`/`application-local.properties` chứa secret không được commit vào git (xem `08_TEST_ENVIRONMENT_SETUP.md` mục 3) — kiểm tra `.gitignore` có che đúng.

## 6. Business Logic Abuse (lạm dụng logic nghiệp vụ)

- [ ] Gửi trực tiếp `xp`/`coin`/`role` trong request body khi sửa Profile — bị bỏ qua hoàn toàn, không có cách nào tự cộng XP/đổi role qua request thủ công (xem TC-PROFILE-004).
- [ ] Nộp bài Quiz với `questionId` không thuộc bộ câu hỏi đã generate cho attempt đó — bị từ chối, không chấm điểm gian lận (xem TC-QUIZ-023).
- [ ] Gọi trực tiếp API cộng XP/hoàn thành Lesson nhiều lần liên tiếp — không cộng dồn XP vô hạn (xem TC-COURSE-015, TC-PROG-005).
- [ ] Clone Deck của chính mình liên tục — không gây lỗi logic (không bắt buộc chặn, nhưng không được phá vỡ dữ liệu).

## 7. Cách ghi nhận kết quả

Mỗi mục không đạt trong checklist này **luôn** báo cáo với `Severity` tối thiểu **Major**, và **Critical** nếu thuộc nhóm 2 (Authorization) hoặc 4 (lộ dữ liệu nhạy cảm) — theo quy ước tại `10_BUG_REPORT_TEMPLATE.md`. Dùng đúng mẫu Bug Report, mục "Steps to Reproduce" phải đủ chi tiết để Dev tái hiện được (payload cụ thể đã gửi, header, response nhận được).
