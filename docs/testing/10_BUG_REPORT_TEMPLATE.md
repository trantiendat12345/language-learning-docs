# Bug Report Template & Quy ước

> Chuẩn hoá cách ghi nhận lỗi để Developer xử lý nhanh và không mất thời gian hỏi lại thông tin còn thiếu.

## 1. Mẫu báo cáo bug

```markdown
### [BUG-ID] Tiêu đề ngắn gọn mô tả lỗi

**Module:** (vd: Deck / Quiz / Auth...)
**Liên quan Test Case:** (vd: TC-DECK-014, theo file 14_FRS_TC_DECK_FLASHCARD.md)
**Severity:** Blocker / Critical / Major / Minor / Trivial
**Priority:** P1 / P2 / P3
**Môi trường:** Local / Staging — Trình duyệt & phiên bản (vd Chrome 130) — Thiết bị (Desktop/Tablet/Mobile)
**Tài khoản dùng để test:** (vd user01 — xem 09_TEST_DATA.md)

**Steps to Reproduce:**
1. ...
2. ...
3. ...

**Expected Result:**
(Kết quả đúng phải xảy ra — trích dẫn từ Test Case hoặc Business Rule liên quan)

**Actual Result:**
(Kết quả thực tế xảy ra)

**Screenshot / Log / Response API:**
(Đính kèm ảnh chụp, response JSON lỗi, console log nếu có)

**Ghi chú thêm:**
(Tần suất xảy ra: luôn luôn / thỉnh thoảng / 1 lần duy nhất; có ảnh hưởng chức năng khác không)
```

## 2. Quy ước Severity (Mức độ nghiêm trọng của lỗi)

| Severity | Định nghĩa | Ví dụ |
|---|---|---|
| **Blocker** | Chặn hoàn toàn không thể tiếp tục test module đó | Backend crash khi login, DB không kết nối được |
| **Critical** | Sai lệch dữ liệu nghiêm trọng hoặc lỗ hổng bảo mật | User A sửa được Deck của User B; XP tính sai vĩnh viễn; lộ password trong response |
| **Major** | Chức năng chính hoạt động sai nhưng có thể né tránh tạm thời | Quiz chấm điểm sai 1 loại câu hỏi; Streak không tăng đúng |
| **Minor** | Lỗi nhỏ không ảnh hưởng luồng chính | Label hiển thị sai chính tả, thiếu icon |
| **Trivial** | Vấn đề thẩm mỹ, không ảnh hưởng chức năng | Căn lề lệch 2px, màu sắc chưa chuẩn dark mode |

## 3. Quy ước Priority (Mức độ ưu tiên xử lý)

| Priority | Ý nghĩa |
|---|---|
| **P1** | Phải fix ngay trước khi tiếp tục các test case khác trong module |
| **P2** | Fix trong đợt hiện tại, trước khi module được coi là hoàn thành (Exit Criteria) |
| **P3** | Có thể dời sang đợt sau, ghi nhận như known issue |

**Lưu ý:** Severity và Priority là hai trục độc lập — 1 bug có thể Severity=Minor nhưng Priority=P1 nếu nó nằm chắn ngay đầu luồng đăng ký (ảnh hưởng mọi test case sau đó dù bản thân lỗi nhỏ).

## 4. Vòng đời một bug (Bug Lifecycle)

```
New → Confirmed → In Progress (Dev đang fix) → Fixed → Retest (Tester kiểm tra lại)
  → nếu Pass: Closed
  → nếu vẫn Fail: Reopened → quay lại In Progress
```

- **Retest** phải thực hiện lại đúng **Steps to Reproduce** đã ghi trong bug ban đầu, không chỉ kiểm tra qua loa.
- Sau khi **Closed**, thêm case tương ứng vào `32_REGRESSION_SMOKE_CHECKLIST.md` nếu bug thuộc luồng quan trọng (Blocker/Critical) — để đảm bảo lỗi không quay lại (regression) ở các bản sau.

## 5. Quy tắc đặt Bug-ID

Định dạng đề xuất: `BUG-<MODULE>-<số thứ tự>`, vd `BUG-AUTH-001`, `BUG-DECK-014`. Module code lấy theo tên file test case tương ứng (AUTH, PROFILE, COURSE, DECK, SRS, QUIZ, PROGRESS, FAVORITE, NOTIFICATION, SEARCH, ADMIN).

## 6. Những điều KHÔNG nên làm khi report bug

- Không gộp nhiều lỗi không liên quan vào 1 bug report — mỗi bug 1 vấn đề cụ thể để dev có thể đóng riêng lẻ.
- Không ghi "không hoạt động" chung chung — luôn có Steps to Reproduce cụ thể, tái hiện được.
- Không bỏ qua Expected Result — nếu không trích dẫn rõ được Expected Result từ tài liệu nào (Test Case/Business Rule), cần làm rõ trước khi báo là bug (có thể chỉ là hiểu nhầm behavior).
