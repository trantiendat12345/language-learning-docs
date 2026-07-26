# Regression & Smoke Test Checklist

> Danh sách rút gọn, chạy nhanh (thường < 1 giờ) để xác nhận các luồng sống còn của hệ thống chưa bị hỏng — dùng **sau mỗi lần deploy/build mới** (Smoke) và **trước mỗi lần release** (Regression). Không thay thế việc chạy đầy đủ các file `FRS_TC_*.md` — đây là tập con trọng yếu nhất.

## 1. Khi nào chạy checklist này

| Loại | Khi nào | Phạm vi |
|---|---|---|
| **Smoke Test** | Ngay sau mỗi lần build/deploy mới, trước khi bắt đầu test chi tiết | Mục 2 — chỉ các luồng tối thiểu để xác nhận hệ thống "sống" |
| **Regression Test** | Trước mỗi lần release, hoặc sau khi fix 1 bug Critical/Blocker | Toàn bộ mục 2, 3, 4 |

## 2. Smoke Test — Luồng sống còn (Must Pass)

- [ ] Backend khởi động thành công, kết nối DB không lỗi.
- [ ] Frontend build/chạy dev server thành công, không lỗi console khi load trang chủ.
- [ ] Đăng ký tài khoản mới thành công.
- [ ] Đăng nhập thành công với tài khoản hợp lệ (`user01` — xem `09_TEST_DATA.md`).
- [ ] Đăng nhập ADMIN thành công.
- [ ] Xem danh sách Course (public API) trả về dữ liệu, không lỗi 500.
- [ ] Enroll 1 Course, vào học 1 Lesson thành công.
- [ ] Tạo 1 Deck mới, thêm 1 từ vựng thành công.
- [ ] Học Flashcard (Normal mode) hiển thị đúng.
- [ ] Generate + làm 1 Quiz ngắn (10 câu), nộp bài nhận kết quả.
- [ ] Review Today hiển thị danh sách (hoặc Empty State đúng nếu không có từ đến hạn).
- [ ] Dashboard sau đăng nhập hiển thị không lỗi.
- [ ] Admin Dashboard truy cập được, USER thường bị chặn 403.
- [ ] Đăng xuất thành công.

Nếu **bất kỳ mục nào ở Smoke Test fail** → dừng lại, báo bug Priority P1 ngay, không tiếp tục test chi tiết cho tới khi được fix (theo Entry Criteria ở `00_TEST_PLAN.md`).

## 3. Regression — Theo từng module đã hoàn thành (chọn lọc case Critical/High)

Tham chiếu: chỉ chạy lại các Test Case có `Priority = Critical` trong từng file, cụ thể ưu tiên các nhóm sau (thường là nơi hay phát sinh regression khi sửa code):

| Nhóm rủi ro cao | Test Case tham chiếu (Critical) |
|---|---|
| Authorization/Ownership (mọi module) | TC-DECK-004/006/012/016/019, TC-QUIZ-020, TC-FAV-005/007, TC-ADMIN-008/009/027 |
| Token & phiên đăng nhập | TC-AUTH-008/009/015/016/030 |
| SRS — khoá theo (user, vocabulary) | TC-SRS-011 (đây là rule dễ vỡ nhất khi refactor Deck/Lesson) |
| Deck Clone độc lập với gốc | TC-DECK-017/018 |
| XP/Streak nhất quán | TC-PROG-006/007/010 |
| Quiz chấm điểm đúng | TC-QUIZ-009/010/015 |
| Không lộ dữ liệu nhạy cảm | TC-AUTH-028, `31_SECURITY_CHECKLIST.md` mục 4 |

## 4. Regression — Non-functional nhanh

- [ ] Kiểm tra nhanh Responsive ở 2 breakpoint chính (Mobile 375px, Desktop 1920px) cho các trang vừa thay đổi.
- [ ] Kiểm tra nhanh Dark Mode ở các trang vừa thay đổi.
- [ ] Không có lỗi console (JS error) mới xuất hiện ở các trang chính.

## 5. Ghi nhận kết quả Regression

Sau mỗi lần chạy, ghi lại tóm tắt (không cần chi tiết từng bước, chỉ cần liên kết tới bug nếu fail):

```markdown
### Regression Run — [ngày chạy]
Build/commit: ...
Kết quả: X/Y case pass
Bug phát sinh: BUG-XXX-001, BUG-XXX-002 (nếu có)
Kết luận: Đạt / Chưa đạt Exit Criteria (xem 00_TEST_PLAN.md mục 6.2)
```

## 6. Lưu ý known issues đã chấp nhận (Accepted Risk)

Nếu có bug Major được Product Owner chấp nhận tồn tại tạm thời (theo Exit Criteria ở `00_TEST_PLAN.md`), liệt kê ở đây để tránh báo lại trùng lặp mỗi lần Regression:

| Bug ID | Mô tả ngắn | Lý do chấp nhận | Ngày chấp nhận |
|---|---|---|---|
| *(chưa có)* | | | |
