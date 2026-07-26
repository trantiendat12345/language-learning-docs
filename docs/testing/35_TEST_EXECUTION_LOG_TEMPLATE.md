# Test Execution Log Template

> Khác với Test Case (thiết kế — nằm trong `FRS_TC_*.md`, mô tả **nên** làm gì và kết quả **nên** ra sao), file này ghi lại **thực tế đã chạy** test case đó lần nào, kết quả ra sao, trên build nào. Mỗi chu kỳ test (test lần đầu 1 module, retest sau khi fix bug, regression trước release) tạo **1 log run mới** — không ghi đè lên log cũ, để giữ lịch sử.

## 1. Cách dùng file này

1. Khi bắt đầu 1 chu kỳ test (vd "Test module Auth lần đầu", "Regression trước release v0.3"), copy mẫu bảng ở mục 3 xuống cuối file, đặt tiêu đề rõ ràng kèm ngày và build/commit đang test.
2. Điền kết quả **ngay khi thực thi từng TC**, không dồn lại cuối ngày mới ghi (dễ quên/nhớ nhầm).
3. Khi 1 TC Fail → tạo bug theo `10_BUG_REPORT_TEMPLATE.md`, dán Bug ID vào cột tương ứng.
4. Khi retest sau fix → tạo **dòng log mới** cho cùng TC-ID ở lần chạy hiện tại (không sửa lại kết quả Fail cũ — giữ lại để biết lịch sử bug này từng fail bao nhiêu lần).
5. Sau khi hoàn thành 1 chu kỳ, cập nhật trạng thái tổng hợp vào `33_TRACEABILITY_MATRIX.md` và viết báo cáo theo `36_TEST_SUMMARY_REPORT_TEMPLATE.md`.

## 2. Quy ước cột "Kết quả"

| Giá trị | Ý nghĩa |
|---|---|
| `Pass` | Kết quả thực tế khớp Expected Result |
| `Fail` | Sai khác — phải có Bug ID kèm theo |
| `Blocked` | Không thể thực thi vì phụ thuộc chức năng/dữ liệu khác chưa sẵn sàng — ghi rõ lý do ở cột Ghi chú |
| `Skipped` | Chủ động bỏ qua ở chu kỳ này (vd không liên quan tới thay đổi đang test) — ghi lý do |

## 3. Mẫu bảng log (copy xuống dưới cho mỗi chu kỳ test)

```markdown
### Run: [Tên chu kỳ, vd "Auth — Test lần đầu"]
- **Ngày:** YYYY-MM-DD
- **Build/Commit:** (vd git short hash hoặc mô tả version)
- **Người test:** ...
- **Phạm vi:** (vd toàn bộ 11_FRS_TC_AUTH.md, hoặc chỉ TC-AUTH-001 → 015)

| TC-ID | Kết quả | Bug ID (nếu Fail) | Ghi chú |
|---|---|---|---|
| TC-AUTH-001 | Pass | | |
| TC-AUTH-002 | Pass | | |
| TC-AUTH-009 | Fail | BUG-AUTH-003 | Message trả về tiết lộ username không tồn tại, vi phạm rule ẩn thông tin |
| TC-AUTH-013 | Blocked | | Chưa xác nhận behavior PENDING_VERIFICATION với dev |

**Tóm tắt run:** X Pass / Y Fail / Z Blocked / Tổng N case.
```

## 4. Ví dụ log thực tế (điền mẫu để tester hình dung, xoá khi bắt đầu dùng thật)

### Run: Auth — Test lần đầu (VÍ DỤ MẪU)
- **Ngày:** 2026-08-01
- **Build/Commit:** `a1b2c3d` (sau khi hoàn thành Giai đoạn 2 — Authentication)
- **Người test:** (tên tester)
- **Phạm vi:** `11_FRS_TC_AUTH.md` — TC-AUTH-001 → TC-AUTH-030

| TC-ID | Kết quả | Bug ID (nếu Fail) | Ghi chú |
|---|---|---|---|
| TC-AUTH-001 | Pass | | |
| TC-AUTH-008 | Pass | | |
| TC-AUTH-020 | Fail | BUG-AUTH-001 | API trả 404 thay vì 200 khi email không tồn tại — lộ thông tin, vi phạm rule ẩn danh |
| TC-AUTH-028 | Pass | | Đã kiểm tra kỹ response Login, không có passwordHash |

**Tóm tắt run:** 28 Pass / 1 Fail / 1 Blocked / Tổng 30 case.

---

*(Bắt đầu thêm log run thật của bạn phía dưới dòng này, theo mẫu ở mục 3)*
