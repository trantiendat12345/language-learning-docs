# Test Plan — Language Learning Platform

> Tài liệu đầu tiên tester nên đọc. Xác định phạm vi, chiến lược, môi trường và lịch trình kiểm thử cho toàn bộ dự án.

## 1. Giới thiệu

### 1.1 Mục đích tài liệu
Xác định phạm vi, cách tiếp cận, nguồn lực và lịch trình cho hoạt động kiểm thử thủ công (manual testing) của dự án Language Learning Platform. Tài liệu này là điểm khởi đầu — mọi bộ Test Case trong `docs/testing/11_*.md` → `21_*.md` đều triển khai theo chiến lược mô tả ở đây.

### 1.2 Tài liệu liên quan
| Tài liệu | Vai trò |
|---|---|
| `docs/PROJECT_OVERVIEW.md` | Kiến trúc kỹ thuật, ERD, API, roadmap |
| `01_BUSINESS_REQUIREMENTS.md` | Mục tiêu nghiệp vụ, đối tượng người dùng |
| `02_FEATURE_LIST.md` | Danh sách toàn bộ tính năng cần test |
| `03_GLOSSARY.md` | Thuật ngữ nghiệp vụ |
| `06_ROLES_PERMISSIONS_MATRIX.md` | Ma trận phân quyền dùng để test authorization |
| `33_TRACEABILITY_MATRIX.md` | Theo dõi độ phủ test theo từng yêu cầu |

## 2. Phạm vi kiểm thử (Scope)

### 2.1 Trong phạm vi (In Scope)
- Toàn bộ chức năng MVP: Auth, Course/Lesson/Vocabulary/Grammar, Deck/Flashcard, Spaced Repetition, Quiz, Progress/Gamification cơ bản (Streak/XP/Daily Goal), Favorite/History, Notification/Reminder, Search, Admin CRUD & Dashboard.
- Kiểm thử chức năng (Functional), phân quyền (Authorization), dữ liệu biên (Boundary/Validation), giao diện responsive, dark/light mode, và một số kiểm tra bảo mật cơ bản ở mức thủ công (không phải pentest chuyên sâu).
- Kiểm thử API thủ công qua Swagger UI / Postman cho các luồng quan trọng (Auth, Quiz, SRS).

### 2.2 Ngoài phạm vi (Out of Scope) ở giai đoạn hiện tại
- Automation test (UI/API tự động), Performance/Load test quy mô lớn, Penetration Testing chuyên sâu.
- Các tính năng Phase 2/3 chưa triển khai: Achievement/Leaderboard nâng cao, Payment/Premium, AI Features, Social, Mobile App, Import/Export.
- Test đa trình duyệt cũ (IE, Safari < 14) — chỉ test trên Chrome/Edge/Firefox bản mới nhất và Safari mới nhất.

## 3. Đối tượng & Vai trò tham gia test

| Vai trò | Trách nhiệm |
|---|---|
| Tester (Manual QA) | Thiết kế/thực thi test case, report bug, xác nhận fix (retest), cập nhật Traceability Matrix |
| Developer | Fix bug theo Severity/Priority, hỗ trợ tester hiểu logic khi cần |
| Product Owner (chính người yêu cầu dự án) | Duyệt phạm vi, quyết định mức độ ưu tiên khi có tranh cãi Severity |

## 4. Chiến lược kiểm thử (Test Strategy)

### 4.1 Loại kiểm thử áp dụng
| Loại | Mô tả | Áp dụng khi nào |
|---|---|---|
| Smoke Test | Kiểm tra nhanh các luồng sống còn (login, xem course, học flashcard...) | Sau mỗi lần deploy/build mới |
| Functional Test | Kiểm tra chi tiết từng chức năng theo Test Case | Sau khi 1 module hoàn thành (theo Giai đoạn ở roadmap) |
| Regression Test | Đảm bảo thay đổi mới không phá vỡ chức năng cũ | Trước mỗi lần release / sau khi fix bug lớn |
| Authorization Test | User A không thao tác được dữ liệu User B; USER không vào được trang ADMIN | Áp dụng cho mọi API/UI có ownership hoặc role check |
| Boundary/Validation Test | Input rỗng, quá dài, sai định dạng, ký tự đặc biệt | Áp dụng cho mọi form nhập liệu |
| UI/Responsive Test | Desktop/Laptop/Tablet/Mobile, Light/Dark mode | Áp dụng cho mọi trang khi FE hoàn thành |
| Security Test (cơ bản) | Theo `31_SECURITY_CHECKLIST.md` | Khi module liên quan Auth/dữ liệu cá nhân hoàn thành |

### 4.2 Mức độ ưu tiên test theo giai đoạn
Test bám theo roadmap ở `docs/PROJECT_OVERVIEW.md` mục 12 — module nào code xong trước, test trước. Thứ tự ưu tiên:
1. Auth (nền tảng toàn hệ thống)
2. Course/Lesson/Vocabulary/Grammar + Admin CRUD tương ứng
3. Deck/Flashcard
4. Spaced Repetition
5. Quiz
6. Progress/Gamification
7. Favorite/History/Notification/Search
8. Admin Dashboard & Analytics

## 5. Môi trường kiểm thử

Chi tiết dựng môi trường ở `08_TEST_ENVIRONMENT_SETUP.md`. Tóm tắt:
- **Local**: Backend `localhost:8080`, Frontend `localhost:5173` (Vite dev), MySQL local.
- Chưa có môi trường Staging/Production ở giai đoạn MVP — mọi test thực hiện trên Local với dữ liệu seed (`09_TEST_DATA.md`).

## 6. Tiêu chí Entry / Exit

### 6.1 Entry Criteria (bắt đầu test 1 module)
- Module đã build thành công (BE chạy được, FE render được trang liên quan).
- Có ít nhất API cơ bản hoạt động qua Swagger hoặc tính năng hiển thị được trên UI.
- Test Case của module đã có trong file `FRS_TC_*.md` tương ứng.

### 6.2 Exit Criteria (kết thúc test 1 module / release)
- 100% Test Case mức độ **Critical/High** đã thực thi.
- Không còn bug **Blocker/Critical** mở (open).
- Bug **Major** còn tồn tại phải được Product Owner chấp nhận (accepted risk) trước khi release.
- `33_TRACEABILITY_MATRIX.md` được cập nhật đầy đủ cho module đó.

## 7. Quản lý rủi ro

| Rủi ro | Ảnh hưởng | Giảm thiểu |
|---|---|---|
| Dự án 1 người code, không có môi trường Staging riêng | Test và Dev dùng chung DB local, dễ nhiễu dữ liệu | Luôn seed lại dữ liệu test theo `09_TEST_DATA.md` trước mỗi phiên test quan trọng |
| Chưa có automation | Regression test tốn thời gian thủ công | Dùng `32_REGRESSION_SMOKE_CHECKLIST.md` để rút gọn phạm vi regression |
| UI/Wireframe chưa có trước khi code | Test Case ở mức kịch bản, chưa có bước UI chính xác | Cập nhật bổ sung bước UI vào Test Case ngay khi FE của module hoàn thành |
| Không dùng Flyway — schema có thể thay đổi ngầm giữa các lần chạy `ddl-auto=update` | Dữ liệu test cũ có thể không tương thích | Xoá và tạo lại DB khi có thay đổi entity lớn, seed lại theo `09_TEST_DATA.md` |

## 8. Định nghĩa Pass/Fail cho một Test Case
- **Pass**: Kết quả thực tế khớp hoàn toàn với Expected Result.
- **Fail**: Kết quả thực tế khác Expected Result → tạo bug theo `10_BUG_REPORT_TEMPLATE.md`, liên kết Test Case ID vào bug.
- **Blocked**: Không thể thực thi vì phụ thuộc chức năng khác chưa sẵn sàng — ghi rõ lý do, không tính vào tỉ lệ Pass/Fail.
- **N/A**: Test case không áp dụng được ở phiên bản hiện tại (tính năng Phase 2 chưa triển khai).

## 9. Lịch trình (tham chiếu theo Giai đoạn phát triển)

| Giai đoạn phát triển | Module cần test | File Test Case |
|---|---|---|
| 2. Authentication | Auth, User Profile cơ bản | `11_FRS_TC_AUTH.md`, `12_FRS_TC_USER_PROFILE.md` |
| 3. Course System | Course/Lesson/Vocabulary/Grammar + Admin | `13_FRS_TC_COURSE_LESSON.md`, `21_FRS_TC_ADMIN.md` (phần liên quan) |
| 4. Quiz | Quiz generate/submit/history | `16_FRS_TC_QUIZ.md` |
| 5. Deck | Deck/DeckCard/Flashcard | `14_FRS_TC_DECK_FLASHCARD.md` |
| 6. Spaced Repetition | Review Today, SM-2 | `15_FRS_TC_SRS_REVIEW.md` |
| 7. Progress & Gamification | Dashboard, Streak, XP, Achievement, Leaderboard | `17_FRS_TC_PROGRESS_GAMIFICATION.md` |
| 8. Engagement | Favorite, History, Notification, Search | `18_FRS_TC_FAVORITE_HISTORY.md`, `19_FRS_TC_NOTIFICATION_REMINDER.md`, `20_FRS_TC_SEARCH.md` |
| 9. Admin & Analytics | Admin Dashboard đầy đủ | `21_FRS_TC_ADMIN.md` |
| 10. Production | Regression toàn hệ thống + Security + Non-functional | `30_`, `31_`, `32_` |

Lịch trình không gắn ngày cụ thể (dự án cá nhân, tiến độ linh hoạt) — tester bắt đầu test một module ngay khi module đó thoả Entry Criteria (mục 6.1).
