# Schema Change Log

> Vì dự án **chưa dùng Flyway** (`spring.jpa.hibernate.ddl-auto=update` — rủi ro đã ghi ở `docs/PROJECT_OVERVIEW.md` mục 10.3), không có migration script nào tự động ghi lại lịch sử thay đổi schema. File này là nơi **ghi tay thủ công** mỗi khi entity thay đổi, để: (1) không mất dấu vết vì sao 1 cột tồn tại, (2) có sẵn tư liệu viết migration script thật khi chuyển sang Flyway ở Giai đoạn 10, (3) tester dùng để biết khi nào cần đối chiếu lại `docs/testing/07_DATA_DICTIONARY.md`.

## Cách dùng

Mỗi khi thêm/sửa/xoá entity (thêm bảng, thêm/xoá/đổi kiểu cột, thêm constraint), thêm 1 dòng vào bảng dưới đây **trong cùng commit** với thay đổi code. Sau đó cập nhật `docs/testing/07_DATA_DICTIONARY.md` nếu field đó ảnh hưởng tới hợp đồng dữ liệu mà tester cần biết.

| Ngày | Entity/Bảng | Thay đổi | Lý do | Giai đoạn |
|---|---|---|---|---|
| 2026-07-27 | `users` | Tạo bảng mới (không có `native_language_id`/`learning_language_id` — cố tình hoãn tới Giai đoạn 3 vì `Language` chưa tồn tại, xem comment trong `User.java`) | Entity tài khoản người dùng | Giai đoạn 2 |
| 2026-07-27 | `role`, `permission`, `role_permission` | Tạo bảng mới, quan hệ many-to-many | Schema RBAC đầy đủ theo D7, MVP chỉ dùng Role | Giai đoạn 2 |
| 2026-07-27 | `user_role` | Tạo bảng join mới | Quan hệ many-to-many User–Role | Giai đoạn 2 |
| 2026-07-27 | `refresh_token` | Tạo bảng mới (kế thừa BaseEntity, không audit fields — D9) | Cấp lại Access Token không cần đăng nhập lại | Giai đoạn 2 |
| 2026-07-27 | `verification_token` | Tạo bảng mới (kế thừa BaseEntity, không audit fields — D9) | Token xác thực email + đặt lại mật khẩu | Giai đoạn 2 |

## Mẫu dòng ghi

```
| 2026-08-05 | vocabulary | Thêm cột frequency_rank (int, nullable) | Cần để sắp xếp gợi ý học từ phổ biến trước | Giai đoạn 3 |
| 2026-08-12 | deck_card | Thêm unique constraint (deck_id, vocabulary_id) | Chặn thêm trùng từ vào cùng deck (TC-DECK-009) | Giai đoạn 5 |
```

## Lưu ý khi chuyển sang Flyway (Giai đoạn 10)

Khi tới lúc thêm Flyway: dùng chính log này làm checklist để viết lại toàn bộ lịch sử thành các file `V1__init.sql`, `V2__add_frequency_rank.sql`... theo đúng thứ tự thời gian đã ghi — đảm bảo baseline migration khớp với schema thực tế đang chạy (`ddl-auto=update` đã tạo ra), không viết migration "tưởng tượng" khác với DB thật đang có.
