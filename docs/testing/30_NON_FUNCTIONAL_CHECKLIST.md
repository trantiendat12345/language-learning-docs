# Non-Functional Checklist — UI/UX, Responsive, Theme, State

> Checklist áp dụng cho **mọi màn hình** (không phải test case theo module) — chạy lại checklist này cho từng trang khi FE của trang đó hoàn thành, và lặp lại toàn bộ ở giai đoạn Regression trước release (xem `32_REGRESSION_SMOKE_CHECKLIST.md`).

## 1. Responsive — Kích thước màn hình

Test tối thiểu ở các breakpoint sau (dùng DevTools responsive mode hoặc thiết bị thật):

| Thiết bị | Độ rộng tham khảo |
|---|---|
| Mobile | 375px (iPhone SE/12/13 chuẩn) |
| Mobile lớn | 428px (iPhone Pro Max) |
| Tablet | 768px (iPad) |
| Laptop | 1366px |
| Desktop | 1920px |

**Checklist mỗi màn hình:**
- [ ] Không có thanh cuộn ngang (horizontal scroll) ngoài ý muốn ở bất kỳ breakpoint nào.
- [ ] Text không bị tràn/cắt chữ, không đè lên phần tử khác.
- [ ] Nút bấm/vùng chạm đủ lớn trên Mobile (tối thiểu ~44x44px theo chuẩn accessibility).
- [ ] Bảng dữ liệu (Admin) hiển thị hợp lý trên Mobile (scroll trong bảng, hoặc chuyển layout card).
- [ ] Modal/Dialog không tràn màn hình trên Mobile, có thể đóng dễ dàng (nút X hoặc tap ngoài).
- [ ] Navigation (menu chính) chuyển đúng sang dạng hamburger/bottom nav trên Mobile nếu thiết kế yêu cầu.
- [ ] Hình ảnh (thumbnail Course/Deck, avatar) tự co giãn đúng tỉ lệ, không vỡ layout.

## 2. Light Mode / Dark Mode

- [ ] Toggle Light/Dark hoạt động ngay lập tức không cần reload.
- [ ] Preference được lưu lại sau khi reload trang / đăng nhập lại.
- [ ] Không có vùng "sót" màu nền sáng trên Dark mode (hoặc ngược lại) — đặc biệt ở Modal, Toast, Dropdown, Tooltip.
- [ ] Độ tương phản chữ/nền đủ đọc được ở cả 2 chế độ (không chữ xám trên nền xám).
- [ ] Icon/hình minh hoạ hiển thị hợp lý ở cả 2 chế độ (không bị "biến mất" do cùng màu nền).

## 3. Trạng thái tải & dữ liệu (Loading / Empty / Error / Success State)

Áp dụng cho mọi màn hình có gọi API:

| Trạng thái | Checklist |
|---|---|
| **Loading** | Hiển thị Skeleton/Spinner rõ ràng khi đang chờ dữ liệu, không hiển thị màn hình trắng/giật layout khi dữ liệu load xong (tránh layout shift) |
| **Empty State** | Khi danh sách rỗng (chưa có Deck, chưa có Course nào phù hợp filter, Review Today không có từ...) hiển thị thông điệp + gợi ý hành động rõ ràng, không chỉ để trống trang |
| **Error State** | Khi API lỗi (mất mạng, 500, timeout) hiển thị thông báo lỗi thân thiện + nút Thử lại, **không** hiển thị stack trace/lỗi kỹ thuật cho người dùng (xem `docs/PROJECT_OVERVIEW.md` mục 10.6) |
| **Success State** | Hành động thành công (lưu Deck, nộp Quiz, đổi mật khẩu...) có phản hồi rõ ràng (Toast/Banner), không im lặng khiến người dùng không chắc đã thành công hay chưa |

## 4. Form & Validation UI

- [ ] Lỗi validate hiển thị ngay tại field bị lỗi (inline), không chỉ ở 1 thông báo chung chung trên đầu form.
- [ ] Nút Submit bị disable hoặc có loading state trong lúc đang gửi request, tránh double-submit (vd bấm 2 lần liên tiếp tạo 2 Deck trùng).
- [ ] Rời khỏi form có thay đổi chưa lưu → cảnh báo xác nhận (tuỳ mức ưu tiên, ít nhất áp dụng cho form dài như tạo Lesson/Course).

## 5. Component chuẩn dùng lại (Bootstrap 5)

Kiểm tra các component dùng xuyên suốt hệ thống hoạt động nhất quán:
- [ ] Card (Course/Deck listing)
- [ ] Progress Bar (Course Progress, Daily Goal, Quiz đang làm dở)
- [ ] Badge (Level, Streak, Achievement)
- [ ] Modal (Confirm Delete, Create Deck nhanh...)
- [ ] Toast (thông báo thành công/lỗi)
- [ ] Tooltip (giải thích thuật ngữ, icon)
- [ ] Pagination (danh sách Course/Deck/Admin)
- [ ] Search bar + Filter + Sort (nhất quán vị trí, hành vi giữa các trang danh sách)

## 6. Animation & Hiệu năng cảm nhận

- [ ] Animation (lật Flashcard, chuyển trang, progress bar) mượt, không giật.
- [ ] Không lạm dụng animation gây chậm cảm nhận (theo đúng tinh thần "animation nhẹ" ở yêu cầu gốc).
- [ ] Trang tải lần đầu (First Load) trong thời gian chấp nhận được trên mạng thường (không có KPI cứng ở MVP, nhưng ghi nhận nếu > 3-5s cảm thấy chậm rõ rệt để báo dev).

## 7. Trình duyệt kiểm thử

| Trình duyệt | Bắt buộc test |
|---|---|
| Chrome (mới nhất) | ✅ Bắt buộc |
| Edge (mới nhất) | ✅ Bắt buộc |
| Firefox (mới nhất) | ✅ Bắt buộc |
| Safari (mới nhất, nếu có máy Mac/iOS) | ✅ Bắt buộc nếu có thiết bị |
| Trình duyệt cũ (IE, Safari cũ) | ❌ Ngoài phạm vi (xem `00_TEST_PLAN.md` mục 2.2) |

## 8. Accessibility cơ bản (tham khảo, không bắt buộc sâu ở MVP)

- [ ] Điều hướng được bằng bàn phím (Tab) qua các phần tử tương tác chính (form, nút bấm).
- [ ] Hình ảnh có `alt text` cơ bản (đặc biệt icon chức năng, không chỉ hình trang trí).
- [ ] Độ tương phản chữ/nền đạt mức đọc được (liên hệ mục 2 Dark Mode ở trên).
