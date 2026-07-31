# Module: User Profile & Settings — Functional Requirements & Test Cases

> **Phần 1 = Đặc tả chức năng (Functional Spec)** — dev đọc phần này để biết cần implement gì, không cần đọc Test Case. **Phần 2 + 3 = Test Scenarios/Test Case** — tester dùng để kiểm thử. File gộp chung 2 mục đích để tránh 2 tài liệu lệch nhau khi sửa rule (xem `CLAUDE.md`).

## Phần 1 — Functional Requirements

### 1.1 Xem hồ sơ cá nhân (My Profile)

**API:** `GET /api/users/me` (protected)
**Main flow:** Trả về thông tin của chính user đang đăng nhập (lấy `userId` từ SecurityContext, không nhận từ param). **Không** trả `passwordHash`.

### 1.2 Chỉnh sửa hồ sơ (Edit Profile)

**API:** `PUT /api/users/me` (protected)
**Business Rules:**
- Các field được sửa: `displayName`, `avatarUrl`, `birthday`, `gender`, `country`, `currentLevel`, `dailyGoalType`, `dailyGoalValue` (2 field cuối bổ sung ở Giai đoạn 7, xem mục 1.4). `nativeLanguageId`/`learningLanguageId` **chưa implement** — 2 field này chưa tồn tại trong entity `User` (kế hoạch Giai đoạn 3 khi có entity `Language`, xem `docs/dev/SCHEMA_CHANGE_LOG.md`), nên TC-PROFILE-005/006 bên dưới chưa test được cho tới khi triển khai Giai đoạn 3.
- **Không** cho sửa qua endpoint này: `username`, `email`, `password`, `xp`, `coin`, `role`, `status` (đây là các field hệ thống quản lý hoặc cần luồng riêng) — Request DTO (`UserUpdateRequest`) cố tình không khai báo các field này nên Jackson tự bỏ qua nếu client cố gửi lên, không cần code chặn thủ công.
- PUT thay toàn bộ field được phép sửa bằng giá trị gửi lên (kể cả null) — không phải PATCH từng phần; field nào không gửi trong JSON sẽ bị set về null.

### 1.3 Đổi mật khẩu (Change Password)

**API:** `PUT /api/users/me/password` (protected)
**Main flow:** Yêu cầu nhập `currentPassword` + `newPassword` + `confirmPassword`. Xác thực `currentPassword` đúng trước khi cho đổi.
**Exception flow:** `currentPassword` sai → **đã chốt: 401**, errorCode `AUTH_INVALID_CREDENTIALS` (dùng chung exception với sai mật khẩu lúc Login, xem `docs/dev/ERROR_CODE_CATALOG.md`). `confirmPassword` không khớp `newPassword` → 400, errorCode `AUTH_PASSWORD_MISMATCH`. `newPassword` không đạt rule độ mạnh (xem `11_FRS_TC_AUTH.md` mục 1.1) → validate error 400. `newPassword` trùng `currentPassword` → **đã chốt khi code: từ chối**, 400 errorCode `AUTH_NEW_PASSWORD_SAME_AS_CURRENT` (ưu tiên bảo mật/UX rõ ràng hơn so với cho phép "đổi" thành cùng 1 mật khẩu).
**Business Rule bảo mật:** Sau khi đổi mật khẩu thành công, revoke toàn bộ Refresh Token cũ (buộc đăng nhập lại ở thiết bị khác) — cùng nguyên tắc với Reset Password. **Đã implement + verify DB thật.**

### 1.4 Learning Settings (Daily Goal, ngôn ngữ học)

**Mô tả:** Phần cài đặt ảnh hưởng trực tiếp tới module Progress/Gamification (`17_FRS_TC_PROGRESS_GAMIFICATION.md`). Đặt `Daily Goal` (theo thời gian: 5/10/20/30 phút, hoặc theo số từ: 10/20 từ). **Đã implement ở Giai đoạn 7** (đặc tả gốc thuộc Giai đoạn 2 nhưng chưa từng được code, chỉ phát hiện khi cần cho `UserDailyActivity.goalMet` — xem `docs/PROJECT_OVERVIEW.md` mục 13) qua `PUT /api/users/me` với 2 field `dailyGoalType` (enum `TIME`/`WORDS`, không giới hạn tập giá trị cố định 5/10/20/30 như mô tả — client tự chọn số nguyên bất kỳ ≥ 1) và `dailyGoalValue` (int ≥ 1). Ngôn ngữ học (`nativeLanguageId`/`learningLanguageId`) vẫn chưa implement, xem mục 1.2.

### 1.5 Settings chung (Theme, Notification)

**Mô tả:** Bật/tắt Light/Dark mode (lưu preference, xem `30_NON_FUNCTIONAL_CHECKLIST.md`), bật/tắt loại thông báo muốn nhận (liên quan `19_FRS_TC_NOTIFICATION_REMINDER.md`).

## Phần 2 — Test Scenarios

1. Xem profile thành công, không lộ password.
2. Sửa profile thành công với dữ liệu hợp lệ.
3. Sửa profile thất bại khi cố sửa field không được phép (username/email/xp/role...).
4. Sửa profile với `learningLanguageId` không tồn tại/không active.
5. Đổi mật khẩu thành công, đăng nhập lại bằng mật khẩu mới.
6. Đổi mật khẩu thất bại — sai mật khẩu hiện tại.
7. Đổi mật khẩu — mật khẩu mới không đạt rule.
8. Đặt Daily Goal và xác nhận được áp dụng vào tính năng Progress.
9. Không cho user A xem/sửa profile của user B qua bất kỳ cách truyền id nào.

## Phần 3 — Test Cases chi tiết

| ID | Tiêu đề | Precondition | Steps | Test Data | Expected Result | Priority |
|---|---|---|---|---|---|---|
| TC-PROFILE-001 | Xem profile thành công | Đã login user01 | `GET /api/users/me` | | 200, đúng dữ liệu user01, không có `passwordHash` | Critical |
| TC-PROFILE-002 | Sửa profile thành công | Đã login | `PUT /api/users/me` với displayName mới | displayName=`Nguyen Van A` | 200, dữ liệu cập nhật đúng | High |
| TC-PROFILE-003 | Sửa profile — cố gắng đổi username qua field lạ | Đã login | Gửi thêm field `username` khác trong body | | Field `username` bị bỏ qua/không đổi, không lỗi 500 | High |
| TC-PROFILE-004 | Sửa profile — cố gắng đổi xp/role qua request | Đã login | Gửi `xp=999999`, `role=ADMIN` trong body | | Bị bỏ qua hoàn toàn, dữ liệu gốc không đổi | Critical |
| TC-PROFILE-005 | Sửa profile — learningLanguageId không tồn tại | Đã login | `learningLanguageId=99999` | | ⏳ **Chưa test được** — field `learningLanguageId` chưa có trong code (kế hoạch Giai đoạn 3, xem mục 1.2) | Medium |
| TC-PROFILE-006 | Sửa profile — learningLanguageId của Language INACTIVE | Language `ko` = INACTIVE (xem `09_TEST_DATA.md`) | `learningLanguageId` = id của `ko` | | ⏳ **Chưa test được** — tương tự TC-PROFILE-005 | Low |
| TC-PROFILE-007 | Đổi mật khẩu thành công | Đã login user01 | `PUT /api/users/me/password` | current=`User@123`, new=`NewPass1` | 200, refreshToken cũ bị revoke (đã verify DB thật) | Critical |
| TC-PROFILE-008 | Đăng nhập lại bằng mật khẩu mới sau đổi | Sau TC-PROFILE-007 | Login | new password | 200 | Critical |
| TC-PROFILE-009 | Đổi mật khẩu — sai mật khẩu hiện tại | Đã login | current=sai | | 401, errorCode `AUTH_INVALID_CREDENTIALS`, mật khẩu không đổi | Critical |
| TC-PROFILE-010 | Đổi mật khẩu — mật khẩu mới quá yếu | Đã login | new=`123` | | 400 validate | Medium |
| TC-PROFILE-011 | Đổi mật khẩu — confirm không khớp | Đã login | new≠confirm | | 400, errorCode `AUTH_PASSWORD_MISMATCH` | Medium |
| TC-PROFILE-012 | Đặt Daily Goal theo thời gian | Đã login | `PUT /api/users/me` | dailyGoalType=`TIME`, dailyGoalValue=20 | 200, lưu đúng `dailyGoalType=TIME, dailyGoalValue=20` — **đã test qua curl (Giai đoạn 7)** | High |
| TC-PROFILE-013 | Đặt Daily Goal theo số từ | Đã login | `PUT /api/users/me` | dailyGoalType=`WORDS`, dailyGoalValue=10 | 200, `dailyGoalType=WORDS, dailyGoalValue=10` — **đã test qua curl (Giai đoạn 7)** | High |
| TC-PROFILE-014 | User không xem được profile user khác qua API `/api/users/me` | Đã login user01 | Gọi `/api/users/me` | | Luôn trả về dữ liệu **của user01**, không có cách truyền id user khác vào endpoint này | Critical |
| TC-PROFILE-015 | Gọi API profile khi chưa login | Chưa login | `GET /api/users/me` | | 401 | Critical |
| TC-PROFILE-016 | Đổi Theme Light/Dark | Đã login | Toggle dark mode | | Giao diện đổi ngay lập tức, preference được lưu (localStorage hoặc user setting) và giữ nguyên sau khi reload | Medium |
| TC-PROFILE-017 | Đổi mật khẩu — mật khẩu mới trùng mật khẩu hiện tại | Đã login | current=new (giống hệt nhau) | | 400, errorCode `AUTH_NEW_PASSWORD_SAME_AS_CURRENT` | Medium |
