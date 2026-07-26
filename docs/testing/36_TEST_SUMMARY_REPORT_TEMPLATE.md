# Test Summary Report Template

> Viết **sau khi kết thúc** một chu kỳ test (1 module hoàn thành, hoặc trước 1 lần release) — khác với Test Plan (`00_TEST_PLAN.md`, viết **trước** khi test). Mục đích: cho Product Owner (người ra quyết định release) một bức tranh rõ ràng để quyết định Go/No-Go, dựa trên số liệu tổng hợp từ `35_TEST_EXECUTION_LOG_TEMPLATE.md`.

## Mẫu báo cáo (copy để dùng cho mỗi chu kỳ)

```markdown
# Test Summary Report — [Tên module/Release] — [Ngày]

## 1. Thông tin chung
- **Phạm vi test:** (vd "Module Auth — Giai đoạn 2" hoặc "Release v0.3 — Regression toàn hệ thống")
- **Thời gian test:** từ ... đến ...
- **Build/Commit:** ...
- **Người thực hiện:** ...
- **Tài liệu tham chiếu:** File Test Case đã dùng, Test Execution Log tương ứng

## 2. Số liệu tổng hợp

| Chỉ số | Giá trị |
|---|---|
| Tổng số Test Case trong phạm vi | ... |
| Đã thực thi | ... (...%) |
| Pass | ... (...%) |
| Fail | ... |
| Blocked | ... |
| Skipped | ... |

## 3. Phân bổ theo Priority (đối chiếu 00_TEST_PLAN.md mục 6.2 — Exit Criteria)

| Priority | Tổng | Pass | Fail | Blocked |
|---|---|---|---|---|
| Critical | | | | |
| High | | | | |
| Medium | | | | |
| Low | | | | |

## 4. Bug phát sinh trong chu kỳ này

| Bug ID | Tiêu đề | Severity | Priority | Trạng thái |
|---|---|---|---|---|
| BUG-XXX-001 | | | | Open/Fixed/Retested/Closed |

**Tổng hợp theo Severity:** Blocker: ... · Critical: ... · Major: ... · Minor: ... · Trivial: ...

## 5. Đối chiếu Exit Criteria (00_TEST_PLAN.md mục 6.2)

- [ ] 100% Test Case Critical/High đã thực thi
- [ ] Không còn bug Blocker/Critical mở
- [ ] Bug Major còn tồn tại đã được xác nhận Accepted Risk (nếu có — liệt kê ở mục 6)
- [ ] `33_TRACEABILITY_MATRIX.md` đã cập nhật cho phạm vi này

**Kết luận:** Đạt / Chưa đạt Exit Criteria.

## 6. Known Issues / Accepted Risk (nếu có)

| Bug ID | Mô tả ngắn | Lý do chấp nhận | Người chấp nhận |
|---|---|---|---|
| | | | |

## 7. Đánh giá & Khuyến nghị

(Nhận định ngắn gọn về chất lượng module/release: ổn định hay còn rủi ro, có nên release/tiếp tục sang giai đoạn tiếp theo không, cần thêm gì trước khi release)

**Khuyến nghị:** ☐ Go (đạt điều kiện release/tiếp tục) ☐ No-Go (cần fix thêm trước khi tiếp tục) ☐ Go có điều kiện (liệt kê điều kiện)
```

## Ví dụ điền mẫu (xoá khi bắt đầu dùng thật)

```markdown
# Test Summary Report — Module Auth — 2026-08-02

## 1. Thông tin chung
- Phạm vi test: Module Auth (11_FRS_TC_AUTH.md), 30 test case
- Thời gian test: 2026-08-01 đến 2026-08-02
- Build/Commit: a1b2c3d
- Người thực hiện: (tester)
- Tài liệu tham chiếu: 35_TEST_EXECUTION_LOG_TEMPLATE.md — Run "Auth — Test lần đầu"

## 2. Số liệu tổng hợp
| Chỉ số | Giá trị |
|---|---|
| Tổng số Test Case | 30 |
| Đã thực thi | 30 (100%) |
| Pass | 28 (93%) |
| Fail | 1 |
| Blocked | 1 |

## 4. Bug phát sinh
| Bug ID | Tiêu đề | Severity | Priority | Trạng thái |
|---|---|---|---|---|
| BUG-AUTH-001 | Forgot Password lộ email tồn tại qua status code | Critical | P1 | Open |

## 5. Đối chiếu Exit Criteria
- [x] 100% Test Case Critical/High đã thực thi
- [ ] Không còn bug Blocker/Critical mở → **chưa đạt** (BUG-AUTH-001 đang mở)
- [x] TC-AUTH-013 (Blocked) đã xác nhận behavior với dev, chờ retest

**Kết luận:** Chưa đạt Exit Criteria — cần fix BUG-AUTH-001 trước khi coi module Auth hoàn thành.

## 7. Đánh giá & Khuyến nghị
Module Auth cơ bản ổn định, chỉ còn 1 lỗi Critical liên quan bảo mật (lộ thông tin qua Forgot Password) cần fix ngay trước khi chuyển sang test module tiếp theo.

**Khuyến nghị:** ☐ Go ☒ No-Go — chờ fix BUG-AUTH-001 và retest.
```

## Lưu ý khi dùng

- Không cần viết report này cho mọi lần chạy nhỏ lẻ (vd chỉ retest 1-2 case sau fix) — chỉ viết khi **kết thúc trọn 1 module** hoặc **trước 1 lần release**, theo đúng lịch trình ở `00_TEST_PLAN.md` mục 9.
- Report này là đầu vào chính để cập nhật cột "Trạng thái" ở `33_TRACEABILITY_MATRIX.md` — sau khi viết xong report, quay lại cập nhật Traceability Matrix ngay.
