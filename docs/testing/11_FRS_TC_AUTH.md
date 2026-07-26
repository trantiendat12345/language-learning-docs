# Module: Authentication — Functional Requirements & Test Cases

> **Phần 1 = Đặc tả chức năng (Functional Spec)** — dev đọc phần này để biết cần implement gì, không cần đọc Test Case. **Phần 2 + 3 = Test Scenarios/Test Case** — tester dùng để kiểm thử. File gộp chung 2 mục đích để tránh 2 tài liệu lệch nhau khi sửa rule (xem `CLAUDE.md`).

## Phần 1 — Functional Requirements

### 1.1 Đăng ký (Register)

**Mô tả:** Người dùng chưa có tài khoản tạo tài khoản mới bằng username/email/password.

**API liên quan:** `POST /api/auth/register` (public)

**Use Case:**
- **Actor:** Guest
- **Precondition:** Chưa đăng nhập
- **Main flow:** Nhập username, email, password, confirm password → submit → hệ thống tạo `User` với `status = PENDING_VERIFICATION` (hoặc `ACTIVE` nếu MVP bỏ qua verify — xác nhận theo triển khai thực tế), gửi email xác thực (MVP: log link ra console) → trả về thông báo thành công.
- **Exception flow:** username/email đã tồn tại → lỗi 400 "đã tồn tại"; password không khớp confirm → lỗi validate; thiếu field bắt buộc → lỗi validate.
- **Postcondition:** Bản ghi `User` mới + `VerificationToken` type `EMAIL_VERIFY` được tạo.

**Business Rules riêng module:**
- Username: 3–50 ký tự, không chứa khoảng trắng, unique không phân biệt hoa/thường.
- Email: đúng định dạng, unique.
- Password: tối thiểu 8 ký tự, có ít nhất 1 chữ và 1 số (mức tối thiểu hợp lý — điều chỉnh nếu rule thực tế khác khi code).
- Password không bao giờ được trả về trong bất kỳ response nào, kể cả dạng hash.

### 1.2 Đăng nhập (Login)

**API liên quan:** `POST /api/auth/login` (public)

**Use Case:**
- **Main flow:** Nhập username/email + password → hệ thống xác thực bằng BCrypt → nếu đúng và `status = ACTIVE` → trả về Access Token + Refresh Token.
- **Exception flow:**
  - Sai username/password → 401, thông báo chung chung "Sai thông tin đăng nhập" (không tiết lộ username tồn tại hay không, tránh dò tài khoản).
  - `status = DISABLED` → lỗi rõ ràng "Tài khoản đã bị vô hiệu hoá".
  - `status = LOCKED` → lỗi rõ ràng "Tài khoản đang bị khoá".
  - `status = PENDING_VERIFICATION` → tuỳ thiết kế: chặn đăng nhập hoặc cho đăng nhập với tính năng giới hạn — xác nhận khi code xong.

### 1.3 Đăng xuất (Logout)

**API liên quan:** `POST /api/auth/logout` (protected)

**Main flow:** Revoke Refresh Token hiện tại trong DB (`revoked = true`). FE xoá Access Token khỏi bộ nhớ (Context/state), xoá cookie Refresh Token nếu có.

### 1.4 Refresh Token

**API liên quan:** `POST /api/auth/refresh-token` (public, nhưng cần Refresh Token hợp lệ trong request/cookie)

**Main flow:** Gửi Refresh Token hợp lệ, chưa hết hạn, chưa revoke → nhận Access Token mới.
**Exception flow:** Refresh Token hết hạn/đã revoke/không tồn tại → 401, FE phải logout và chuyển về trang Login (xem flow ở `05_USER_FLOWS.md` mục 7).

### 1.5 Quên mật khẩu / Đặt lại mật khẩu

**API liên quan:** `POST /api/auth/forgot-password`, `POST /api/auth/reset-password` (public)

**Main flow:**
1. Nhập email → hệ thống tạo `VerificationToken` type `PASSWORD_RESET`, hạn sử dụng ngắn (vd 15–30 phút) → gửi link (MVP: log console).
2. Người dùng mở link, nhập password mới + confirm → hệ thống xác thực token còn hạn, chưa dùng → cập nhật password mới, đánh dấu token `usedAt`.

**Business Rules:**
- Không tiết lộ email có tồn tại trong hệ thống hay không (luôn trả thông báo chung "Nếu email tồn tại, link đã được gửi").
- Token dùng 1 lần — dùng lại phải bị từ chối.
- Sau khi reset thành công, tất cả Refresh Token cũ của user nên bị revoke (bảo mật — buộc đăng nhập lại trên mọi thiết bị).

### 1.6 Xác thực Email (Email Verification)

**API liên quan:** `GET /api/auth/verify-email` (public, kèm token qua query param)

**Main flow:** Người dùng bấm link trong email → token hợp lệ → `User.status` chuyển từ `PENDING_VERIFICATION` sang `ACTIVE`.
**Exception flow:** Token hết hạn/không hợp lệ/đã dùng → thông báo lỗi rõ ràng, có tuỳ chọn gửi lại email xác thực (nếu có tính năng resend).

## Phần 2 — Test Scenarios

1. Đăng ký thành công với dữ liệu hợp lệ.
2. Đăng ký thất bại với dữ liệu không hợp lệ (thiếu field, sai định dạng, trùng username/email, password không khớp).
3. Đăng nhập thành công/thất bại theo từng trạng thái tài khoản (ACTIVE/DISABLED/LOCKED/PENDING_VERIFICATION).
4. Đăng xuất và xác nhận token cũ không dùng lại được.
5. Refresh Token thành công/thất bại (hết hạn, revoked).
6. Quên mật khẩu → đặt lại mật khẩu → đăng nhập bằng mật khẩu mới thành công, mật khẩu cũ thất bại.
7. Token đặt lại mật khẩu dùng 2 lần → lần 2 phải thất bại.
8. Xác thực email thành công/thất bại (token hết hạn).
9. Không lộ thông tin nhạy cảm (password, token thật) trong bất kỳ response nào.
10. Rate-limit/chống brute-force đăng nhập (nếu đã triển khai — nếu chưa, ghi nhận là gap cần đề xuất dev bổ sung).

## Phần 3 — Test Cases chi tiết

| ID | Tiêu đề | Precondition | Steps | Test Data | Expected Result | Priority |
|---|---|---|---|---|---|---|
| TC-AUTH-001 | Đăng ký thành công | Chưa có tài khoản trùng | 1. Gọi `POST /api/auth/register` với dữ liệu hợp lệ | username=`newuser01`, email hợp lệ chưa tồn tại, password=`Passw0rd1`, confirm khớp | 200, `code=200`, User được tạo với status PENDING_VERIFICATION (hoặc ACTIVE tuỳ thiết kế), không có password trong response | Critical |
| TC-AUTH-002 | Đăng ký thất bại — username đã tồn tại | Đã có `user01` (xem `09_TEST_DATA.md`) | Đăng ký với username=`user01` | username=`user01` | 400, message rõ ràng "username đã tồn tại", không tạo user mới | High |
| TC-AUTH-003 | Đăng ký thất bại — email đã tồn tại | user01@test.com đã tồn tại | Đăng ký với email=`user01@test.com` | email trùng | 400 | High |
| TC-AUTH-004 | Đăng ký thất bại — email sai định dạng | — | Nhập email=`abc123` | email không hợp lệ | 400 validate error, field `email` | Medium |
| TC-AUTH-005 | Đăng ký thất bại — password quá ngắn | — | password=`123` | password 3 ký tự | 400 validate error | Medium |
| TC-AUTH-006 | Đăng ký thất bại — confirm password không khớp | — | password≠confirmPassword | | 400 validate error | Medium |
| TC-AUTH-007 | Đăng ký thất bại — thiếu field bắt buộc | — | Bỏ trống username | | 400, liệt kê field lỗi trong `errors[]` | Medium |
| TC-AUTH-008 | Đăng nhập thành công | Tài khoản `user01` ACTIVE | `POST /api/auth/login` đúng username/password | user01 / User@123 | 200, trả `accessToken` + `refreshToken`, không có password trong response | Critical |
| TC-AUTH-009 | Đăng nhập thất bại — sai password | — | Đúng username, sai password | user01 / sai_pass | 401, message chung chung, không tiết lộ username đúng hay sai | Critical |
| TC-AUTH-010 | Đăng nhập thất bại — username không tồn tại | — | username lạ | `khong_ton_tai` | 401, message giống hệt TC-AUTH-009 (không phân biệt được) | High |
| TC-AUTH-011 | Đăng nhập thất bại — tài khoản DISABLED | Dùng `user04_disabled` | Login đúng password | user04_disabled | 401/403, message rõ "tài khoản bị vô hiệu hoá" | High |
| TC-AUTH-012 | Đăng nhập thất bại — tài khoản LOCKED | Dùng `user05_locked` | Login đúng password | user05_locked | 401/403, message rõ "tài khoản bị khoá" | High |
| TC-AUTH-013 | Đăng nhập — tài khoản PENDING_VERIFICATION | Dùng `user03_pending` | Login | user03_pending | Theo thiết kế thực tế đã xác nhận (chặn hoặc giới hạn tính năng) — verify đúng behavior đã thống nhất | Medium |
| TC-AUTH-014 | Đăng xuất thành công | Đã login, có accessToken/refreshToken | `POST /api/auth/logout` | | 200, refreshToken bị revoke | High |
| TC-AUTH-015 | Dùng lại Refresh Token đã logout | Sau TC-AUTH-014 | `POST /api/auth/refresh-token` với token cũ | | 401 | Critical |
| TC-AUTH-016 | Refresh Token thành công | AccessToken hết hạn, RefreshToken còn hạn | `POST /api/auth/refresh-token` | | 200, trả accessToken mới | Critical |
| TC-AUTH-017 | Refresh Token thất bại — token hết hạn | RefreshToken quá hạn (chỉnh test data hoặc chờ hết hạn) | `POST /api/auth/refresh-token` | | 401 | High |
| TC-AUTH-018 | Refresh Token thất bại — token không hợp lệ/giả mạo | — | Gửi chuỗi token ngẫu nhiên | | 401 | High |
| TC-AUTH-019 | Quên mật khẩu — email tồn tại | user01@test.com tồn tại | `POST /api/auth/forgot-password` | email=user01@test.com | 200, message chung chung, VerificationToken PASSWORD_RESET được tạo | High |
| TC-AUTH-020 | Quên mật khẩu — email không tồn tại | — | `POST /api/auth/forgot-password` | email lạ | 200 (message giống TC-AUTH-019, không tiết lộ), **không** tạo token | Critical |
| TC-AUTH-021 | Đặt lại mật khẩu thành công | Có token PASSWORD_RESET hợp lệ | `POST /api/auth/reset-password` | token hợp lệ, password mới | 200, password đổi thành công, token `usedAt` được set | Critical |
| TC-AUTH-022 | Đăng nhập bằng mật khẩu cũ sau khi reset | Sau TC-AUTH-021 | Login bằng password cũ | | 401 | Critical |
| TC-AUTH-023 | Đăng nhập bằng mật khẩu mới sau khi reset | Sau TC-AUTH-021 | Login bằng password mới | | 200 | Critical |
| TC-AUTH-024 | Dùng lại token reset đã dùng | Sau TC-AUTH-021, dùng lại cùng token | `POST /api/auth/reset-password` lần 2 | token đã used | 400/401, "token đã được sử dụng hoặc hết hạn" | Critical |
| TC-AUTH-025 | Đặt lại mật khẩu — token hết hạn | Token quá thời gian hiệu lực | `POST /api/auth/reset-password` | | 400/401 | High |
| TC-AUTH-026 | Xác thực email thành công | User PENDING_VERIFICATION có token EMAIL_VERIFY hợp lệ | `GET /api/auth/verify-email?token=...` | | 200, `User.status` chuyển ACTIVE | High |
| TC-AUTH-027 | Xác thực email — token hết hạn | | `GET /api/auth/verify-email` với token hết hạn | | 400/401, status User không đổi | Medium |
| TC-AUTH-028 | Kiểm tra response Login không lộ password/hash | Sau TC-AUTH-008 | Xem toàn bộ JSON response | | Không có field `password`/`passwordHash` ở bất kỳ đâu trong response | Critical |
| TC-AUTH-029 | Đăng ký — SQL Injection cơ bản trong field text | — | Nhập username=`' OR '1'='1` | | Không gây lỗi 500, không đăng nhập được bằng chuỗi đó, dữ liệu được xử lý như chuỗi thường (ORM tham số hoá) | Critical |
| TC-AUTH-030 | Gọi API protected không có token | Chưa login | Gọi bất kỳ API protected nào không kèm Authorization header | | 401 Unauthorized | Critical |

**Ghi chú:** Bổ sung Test Case cho rate-limit đăng nhập sai nhiều lần liên tiếp nếu tính năng này được triển khai (hiện `docs/PROJECT_OVERVIEW.md` chỉ liệt kê "Rate Limiting nếu cần" — xác nhận với dev trước khi viết case chi tiết).
