# Roles & Permissions Matrix

> Dùng để thiết kế và thực thi các test case về **Authorization** (mọi test case dạng "User A không được phép làm X", "User thường không vào được trang Admin"...). MVP chỉ có 2 role: `ADMIN`, `USER`. Cột "Permission code" tham chiếu schema `role/permission` đã thiết kế sẵn (D7 trong `docs/PROJECT_OVERVIEW.md`) — MVP chưa dùng permission chi tiết, chỉ check Role.

## 1. Quy ước chung

- **Guest** (chưa đăng nhập): chỉ truy cập được endpoint/trang `public`.
- **USER**: vai trò mặc định sau khi đăng ký, truy cập được toàn bộ tính năng học tập cho chính mình.
- **ADMIN**: có toàn quyền USER + quyền quản trị nội dung/hệ thống dưới `/api/admin/**`.
- Không có vai trò trung gian (Editor/Moderator) ở MVP — schema đã sẵn sàng mở rộng qua bảng `role_permission` (xem D7) nhưng chưa có UI/logic gán permission riêng lẻ.

## 2. Ma trận theo module

Ký hiệu: ✅ = được phép · ❌ = bị chặn (401/403) · 🔒 = chỉ với dữ liệu **của chính mình** (ownership check).

| Module / Hành động | Guest | USER | ADMIN | Permission code liên quan |
|---|---|---|---|---|
| Xem danh sách Language/Course/Lesson (nội dung public) | ✅ | ✅ | ✅ | — |
| Xem chi tiết Lesson đầy đủ (đã enroll) | ❌ | 🔒 (chỉ Course đã enroll) | ✅ | — |
| Enroll Course | ❌ | ✅ | ✅ | — |
| Đánh dấu hoàn thành Lesson | ❌ | 🔒 (của chính mình) | ✅ | — |
| Tạo/Sửa/Xoá Language | ❌ | ❌ | ✅ | `LANGUAGE_MANAGE` |
| Tạo/Sửa/Xoá Course | ❌ | ❌ | ✅ | `COURSE_CREATE`, `COURSE_UPDATE`, `COURSE_DELETE` |
| Tạo/Sửa/Xoá Lesson | ❌ | ❌ | ✅ | `LESSON_MANAGE` |
| Tạo/Sửa/Xoá Vocabulary hệ thống (owner=null) | ❌ | ❌ | ✅ | `VOCABULARY_MANAGE` |
| Tạo/Sửa/Xoá Vocabulary custom của chính mình | ❌ | 🔒 | ✅ (của mình) | — |
| Tạo/Sửa/Xoá Grammar | ❌ | ❌ | ✅ | `GRAMMAR_MANAGE` |
| Tạo/Sửa/Xoá Question (ngân hàng câu hỏi) | ❌ | ❌ | ✅ | `QUESTION_MANAGE` |
| Tạo Deck | ❌ | ✅ | ✅ | — |
| Sửa/Xoá Deck | ❌ | 🔒 (chỉ Deck của mình) | ✅ (của mình) — **không** được sửa Deck của USER khác | — |
| Xem Public Deck của người khác | ✅ (nếu public API cho phép) | ✅ | ✅ | — |
| Clone Public Deck | ❌ | ✅ | ✅ | — |
| Học Flashcard / Review / Quiz | ❌ | 🔒 (dữ liệu tiến độ của chính mình) | ✅ (của mình) | — |
| Xem Quiz History của người khác | ❌ | ❌ (chỉ xem của mình) | ❌ (Admin cũng không xem chi tiết bài làm của User qua API thường — chỉ qua Admin User Progress riêng nếu có) | — |
| Favorite / History / Notification / Reminder cá nhân | ❌ | 🔒 | ✅ (của mình) | — |
| Xem Admin Dashboard | ❌ | ❌ | ✅ | `ADMIN_DASHBOARD_VIEW` |
| Quản lý User (activate/disable/lock) | ❌ | ❌ | ✅ | `USER_MANAGE` |
| Xem tiến độ học của User bất kỳ (Admin) | ❌ | ❌ | ✅ | `USER_MANAGE` |
| Quản lý Achievement (P2) | ❌ | ❌ | ✅ | `ACHIEVEMENT_MANAGE` |
| Gửi Notification broadcast (P2) | ❌ | ❌ | ✅ | `NOTIFICATION_MANAGE` |

## 3. Nguyên tắc test Authorization (checklist áp dụng cho MỌI API)

Với mỗi API mới hoàn thành, tối thiểu chạy 4 case sau (tham chiếu chi tiết ở từng file `FRS_TC_*.md`, mục "Authorization Test Cases"):

1. **Không có token** → gọi API `protected` → phải trả **401 Unauthorized**.
2. **Token hết hạn / bị revoke** → gọi API `protected` → phải trả **401 Unauthorized**.
3. **USER thường gọi API `/api/admin/**`** → phải trả **403 Forbidden**.
4. **USER A gọi API sửa/xoá tài nguyên thuộc User B** (Deck, Favorite, StudyReminder...) → phải trả **403 Forbidden**, dữ liệu của User B không bị thay đổi.

## 4. Trạng thái tài khoản (User.status) ảnh hưởng đến quyền truy cập

| Status | Ý nghĩa | Có đăng nhập được không? |
|---|---|---|
| `PENDING_VERIFICATION` | Vừa đăng ký, chưa xác thực email | Tuỳ thiết kế: MVP có thể cho đăng nhập nhưng giới hạn tính năng, hoặc chặn hẳn — xác nhận cụ thể khi test `11_FRS_TC_AUTH.md` |
| `ACTIVE` | Bình thường | ✅ |
| `DISABLED` | Admin vô hiệu hoá | ❌ — trả lỗi rõ ràng (không phải lỗi sai mật khẩu chung chung) |
| `LOCKED` | Bị khoá (vd do vi phạm hoặc quá nhiều lần đăng nhập sai) | ❌ |

Test case chi tiết cho từng trạng thái nằm ở `11_FRS_TC_AUTH.md` và `21_FRS_TC_ADMIN.md` (phần quản lý User).
