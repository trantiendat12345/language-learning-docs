# Module: Notification & Study Reminder — Functional Requirements & Test Cases

> **Phần 1 = Đặc tả chức năng (Functional Spec)** — dev đọc phần này để biết cần implement gì, không cần đọc Test Case. **Phần 2 + 3 = Test Scenarios/Test Case** — tester dùng để kiểm thử. File gộp chung 2 mục đích để tránh 2 tài liệu lệch nhau khi sửa rule (xem `CLAUDE.md`).

## Phần 1 — Functional Requirements

### 1.1 Notification (In-app)

**API:** `GET /api/notifications`, `PUT /api/notifications/{id}/read`, `PUT /api/notifications/read-all` (protected)
**Main flow:** Hệ thống tạo `Notification` khi có sự kiện liên quan (Achievement unlock, Course mới, nhắc học...). `userId = null` nghĩa là thông báo broadcast (mọi user đều thấy). Người dùng xem danh sách, đánh dấu đã đọc từng cái hoặc tất cả.
**Business Rule:** Notification broadcast (`userId=null`) hiển thị cho **mọi** user, nhưng trạng thái "đã đọc" phải theo dõi **riêng theo từng user** — không được để user A đánh dấu đọc rồi user B tự động thấy đã đọc theo (cần cơ chế theo dõi trạng thái đọc độc lập per-user cho thông báo broadcast — lưu ý điểm này khi thiết kế, vì bảng `Notification` ở `docs/PROJECT_OVERVIEW.md` có field `isRead` đơn — cần xác nhận với dev cách xử lý broadcast + đã đọc riêng biệt, có thể cần bảng phụ `NotificationRead(userId, notificationId)` nếu có broadcast).

### 1.2 Study Reminder

**API:** `GET/POST/PUT/DELETE /api/notifications/reminders` (protected, hoặc endpoint riêng tuỳ thiết kế cuối)
**Main flow:** Người dùng đặt giờ nhắc học (`reminderTime`, `daysOfWeek`), loại nhắc (`STUDY`/`FLASHCARD`/`REVIEW`), kênh (`channel` — MVP chỉ `IN_APP`).
**Business Rule:** MVP chưa gửi Email/Push thật (Phase 2) — chỉ lưu cấu hình và hiển thị nhắc nhở dạng in-app khi người dùng mở app đúng khung giờ đã đặt (hoặc hiển thị badge/banner). Không kỳ vọng có thông báo đẩy ngoài trình duyệt/app ở MVP.

## Phần 2 — Test Scenarios

1. Nhận Notification khi có sự kiện tương ứng (vd unlock Achievement — Phase 2).
2. Đánh dấu đã đọc 1 Notification / đọc tất cả.
3. Notification broadcast hiển thị cho mọi user, trạng thái đọc độc lập theo từng user.
4. Notification cá nhân của user A không hiển thị cho user B.
5. Tạo/sửa/xoá Study Reminder.
6. Không cho user sửa/xoá Study Reminder của người khác.
7. Reminder hiển thị đúng theo `daysOfWeek`/`reminderTime` đã đặt.

## Phần 3 — Test Cases chi tiết

> **Trạng thái implement (2026-08-01):** Mục 1.2 Study Reminder **đã test được đầy đủ** — TC-NOTI-008 → 012 test qua curl thật (tạo/sửa/toggle `isActive`/xoá, ownership 403 khi user khác thao tác). Mục 1.1 Notification **đã test được phần cá nhân** — TC-NOTI-001 → 003, 006, 007, 013, 014 test qua curl thật (list/mark-read/mark-all-read, không lộ giữa 2 user, ownership 403 khi mark-read của người khác, 401 chưa login, rỗng cho user mới); Notification được seed trực tiếp qua DB vì **chưa có trigger MVP nào tạo Notification tự động** (Achievement unlock là Phase 2, "Course mới" chỉ là ví dụ minh hoạ trong FRS, không có TC cụ thể). TC-NOTI-004, 005 (broadcast + trạng thái đọc độc lập theo user) **chưa implement** — chính TC-NOTI-004 tự ghi "(Phase 2)" vì cần Admin Notification management (`02_FEATURE_LIST.md` mục 9.10); `userId` trên `Notification` vẫn nullable đúng ERD nhưng chunk này chỉ dùng cho cá nhân, bảng phụ theo dõi đã đọc riêng theo user cho broadcast (gợi ý `NotificationRead` ở mục 1.1) chưa xây, xem `docs/dev/SCHEMA_CHANGE_LOG.md`.

| ID | Tiêu đề | Precondition | Steps | Test Data | Expected Result | Priority |
|---|---|---|---|---|---|---|
| TC-NOTI-001 | Xem danh sách Notification | Đã login, có sẵn Notification | `GET /api/notifications` | | Trả danh sách đúng của user hiện tại, sắp xếp mới nhất trước | High |
| TC-NOTI-002 | Đánh dấu đã đọc 1 Notification | Có Notification chưa đọc | `PUT /api/notifications/{id}/read` | | 200, `isRead=true` | High |
| TC-NOTI-003 | Đánh dấu đọc tất cả | Có nhiều Notification chưa đọc | `PUT /api/notifications/read-all` | | 200, toàn bộ `isRead=true` | Medium |
| TC-NOTI-004 | Notification broadcast hiển thị cho mọi user | Admin gửi 1 Notification `userId=null` (Phase 2) | user01 và user02 cùng xem danh sách | | Cả 2 đều thấy thông báo đó | High |
| TC-NOTI-005 | Trạng thái đọc broadcast độc lập theo user | Sau TC-NOTI-004, user01 đánh dấu đã đọc | user02 xem lại danh sách | | Notification đó vẫn hiển thị **chưa đọc** với user02 | Critical |
| TC-NOTI-006 | Notification cá nhân không lộ sang user khác | user01 có Notification cá nhân (vd nhắc ôn tập) | user02 gọi `GET /api/notifications` | | Không thấy Notification cá nhân của user01 | Critical |
| TC-NOTI-007 | Đánh dấu đã đọc Notification của người khác | user02 cố đánh dấu đọc notification cá nhân của user01 | `PUT /api/notifications/{user01NotiId}/read` bằng token user02 | | 403/404 | Critical |
| TC-NOTI-008 | Tạo Study Reminder | Đã login user01 | `POST` reminder | type=STUDY, reminderTime=20:00, daysOfWeek=hàng ngày | 200, tạo thành công | High |
| TC-NOTI-009 | Sửa Study Reminder của chính mình | Đã tạo reminder | `PUT` đổi giờ | reminderTime=21:00 | 200 | Medium |
| TC-NOTI-010 | Xoá Study Reminder | | `DELETE` reminder | | 200, không còn trong danh sách | Medium |
| TC-NOTI-011 | Sửa/Xoá Study Reminder của người khác | user02 cố thao tác reminder của user01 | `PUT/DELETE` | | 403 Forbidden | Critical |
| TC-NOTI-012 | Tắt Reminder (isActive=false) | Reminder đang active | `PUT` isActive=false | | 200, reminder không còn kích hoạt (không hiển thị nhắc nhở) | Medium |
| TC-NOTI-013 | Notification khi chưa login | Chưa login | `GET /api/notifications` | | 401 | Critical |
| TC-NOTI-014 | Notification rỗng cho user mới | Tài khoản mới | `GET /api/notifications` | | Mảng rỗng, Empty State phù hợp | Low |
