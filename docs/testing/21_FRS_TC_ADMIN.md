# Module: Admin — Functional Requirements & Test Cases

> **Phần 1 = Đặc tả chức năng (Functional Spec)** — dev đọc phần này để biết cần implement gì, không cần đọc Test Case. **Phần 2 + 3 = Test Scenarios/Test Case** — tester dùng để kiểm thử. File gộp chung 2 mục đích để tránh 2 tài liệu lệch nhau khi sửa rule (xem `CLAUDE.md`).

## Phần 1 — Functional Requirements

### 1.1 Nguyên tắc chung cho mọi Admin CRUD

Toàn bộ endpoint `/api/admin/**` áp dụng chung các quy tắc sau (áp dụng cho Language, Course, Lesson, Vocabulary, Grammar, Question, Achievement — xem `06_ROLES_PERMISSIONS_MATRIX.md`):

- Chỉ Role `ADMIN` gọi được — USER gọi phải trả **403 Forbidden**, Guest phải trả **401 Unauthorized**.
- Xoá = soft delete (D9) — bản ghi biến mất khỏi danh sách User thấy nhưng vẫn tồn tại trong DB, không phá vỡ dữ liệu tiến độ học của User đã tương tác trước đó (xem `04_BUSINESS_RULES_GLOBAL.md` mục 7).
- Tạo/sửa đều phải qua validate (field bắt buộc, độ dài, định dạng) — không cho lưu dữ liệu rác.
- Danh sách quản trị hỗ trợ phân trang, tìm kiếm/lọc cơ bản.
- Trường `createdBy`/`updatedBy` tự động lấy từ Admin đang thao tác (SecurityContext), không nhận từ request body.

### 1.2 Quản lý Language / Course / Lesson / Vocabulary / Grammar / Question

**API:** `POST/GET/PUT/DELETE /api/admin/{languages|courses|lessons|vocabularies|grammars|questions}/**`

**Business Rule riêng theo entity:**
- **Course/Lesson:** chuyển `status` từ `DRAFT` → `PUBLISHED` mới hiển thị cho USER (xem `13_FRS_TC_COURSE_LESSON.md`). Xoá 1 Course không được tự động xoá cứng Lesson con — Lesson con cũng soft-delete theo hoặc bị ẩn tương ứng (xác nhận cascade rule cụ thể khi code, tránh `CascadeType.ALL` tuỳ tiện theo `docs/PROJECT_OVERVIEW.md` mục 5).
- **Vocabulary:** Admin chỉ quản lý được Vocabulary hệ thống (`ownerId = null`) — **không** được sửa/xoá Vocabulary custom do User tạo (`ownerId` khác null) qua màn hình quản trị này (đây là dữ liệu cá nhân người dùng).
- **Question:** gắn với `sourceType/sourceId` — xoá 1 Lesson/Course/Deck không tự động xoá Question liên quan (soft-delete riêng biệt), cần kiểm tra Question "mồ côi" không gây lỗi khi generate Quiz (xem `16_FRS_TC_QUIZ.md`).

### 1.3 Quản lý User

**API:** `GET /api/admin/users`, `PUT /api/admin/users/{id}/activate`, `PUT /api/admin/users/{id}/disable`, `PUT /api/admin/users/{id}/lock`, `GET /api/admin/users/{id}/progress`

**Business Rule:**
- Admin xem được danh sách/tiến độ học của mọi User nhưng **không** xem được password (kể cả dạng hash).
- Đổi `status` User (activate/disable/lock) có hiệu lực ngay — user đang có phiên đăng nhập active phải bị chặn ở request tiếp theo (không đợi token hết hạn tự nhiên) nếu chuyển sang DISABLED/LOCKED — mức độ ưu tiên: ít nhất Refresh Token phải bị revoke ngay khi Admin disable/lock.
- Admin không tự disable/lock chính tài khoản ADMIN của mình qua giao diện thường (tránh tự khoá mình ra khỏi hệ thống) — cần xác nhận rule này khi code, đây là rủi ro thiết kế cần lưu ý.

### 1.4 Admin Dashboard

**API:** `GET /api/admin/dashboard`

**Main flow:** Tổng hợp số liệu: Total Users, Active Users, Total Courses, Total Lessons, Total Vocabulary, Total Decks, Total Quizzes, biểu đồ hoạt động học tập.
**Business Rule:** Số liệu đếm phải loại trừ bản ghi đã soft-delete (`is_deleted=false`) trừ khi có yêu cầu hiển thị riêng.

## Phần 2 — Test Scenarios

1. CRUD từng loại nội dung (Language/Course/Lesson/Vocabulary/Grammar/Question) đầy đủ vòng đời (tạo → sửa → xoá → kiểm tra không còn hiển thị phía User).
2. USER thường không truy cập được bất kỳ endpoint `/api/admin/**` nào.
3. Xoá Course không phá vỡ dữ liệu tiến độ User đã học trước đó.
4. Admin không sửa/xoá Vocabulary custom của User.
5. Quản lý User: activate/disable/lock có hiệu lực ngay lập tức.
6. Admin xem tiến độ học của User cụ thể.
7. Admin Dashboard hiển thị đúng số liệu tổng hợp, loại trừ dữ liệu đã xoá mềm.
8. Validate dữ liệu khi tạo/sửa (field bắt buộc, độ dài, định dạng, unique).

## Phần 3 — Test Cases chi tiết

### 3.1 CRUD nội dung (mẫu áp dụng chung — lặp lại cho từng entity: Language, Course, Lesson, Vocabulary, Grammar, Question)

| ID | Tiêu đề | Precondition | Steps | Test Data | Expected Result | Priority |
|---|---|---|---|---|---|---|
| TC-ADMIN-001 | Tạo mới thành công | Đăng nhập ADMIN | `POST /api/admin/{entity}` dữ liệu hợp lệ | vd Course title="New Course" | 200, bản ghi tạo mới, `createdBy` = id admin hiện tại | Critical |
| TC-ADMIN-002 | Tạo mới — thiếu field bắt buộc | Đăng nhập ADMIN | Bỏ trống field required (vd title) | | 400 validate error | High |
| TC-ADMIN-003 | Tạo mới — trùng unique field | vd Course.slug đã tồn tại | Tạo với slug trùng | | 400 | Medium |
| TC-ADMIN-004 | Sửa bản ghi thành công | Bản ghi tồn tại | `PUT /api/admin/{entity}/{id}` | | 200, cập nhật đúng, `updatedBy`/`updatedAt` thay đổi | High |
| TC-ADMIN-005 | Sửa bản ghi không tồn tại | | `PUT /api/admin/{entity}/999999` | | 404 | Medium |
| TC-ADMIN-006 | Xoá (soft delete) bản ghi | Bản ghi tồn tại | `DELETE /api/admin/{entity}/{id}` | | 200, `isDeleted=true`, biến mất khỏi danh sách User/Admin danh sách thường | High |
| TC-ADMIN-007 | Xem danh sách sau khi xoá (phía Admin, không filter) | Sau TC-ADMIN-006 | `GET /api/admin/{entity}` | | Bản ghi đã xoá không xuất hiện trong danh sách mặc định | High |
| TC-ADMIN-008 | USER thường gọi API tạo | Đăng nhập USER (user01) | `POST /api/admin/{entity}` | | 403 Forbidden | Critical |
| TC-ADMIN-009 | USER thường gọi API xoá | Đăng nhập USER | `DELETE /api/admin/{entity}/{id}` | | 403 Forbidden, dữ liệu không đổi | Critical |
| TC-ADMIN-010 | Gọi API admin khi chưa login | Chưa login | Bất kỳ API `/api/admin/**` | | 401 Unauthorized | Critical |

> Áp dụng bảng trên cho: `languages`, `courses`, `lessons`, `vocabularies`, `grammars`, `questions` — nhân bản ID theo entity khi thực thi thực tế (vd `TC-ADMIN-COURSE-001`, `TC-ADMIN-VOCAB-001`...).

### 3.2 Test Case đặc thù theo entity

| ID | Tiêu đề | Precondition | Steps | Expected Result | Priority |
|---|---|---|---|---|---|
| TC-ADMIN-011 | Course DRAFT → PUBLISHED hiển thị cho User | Course vừa tạo, status=DRAFT | Đổi status sang PUBLISHED | Course xuất hiện ngay trong `GET /api/courses` (phía USER) | Critical |
| TC-ADMIN-012 | Xoá Course không phá vỡ CourseEnrollment cũ | user01 đã enroll + hoàn thành 1 phần Course X | Admin xoá (soft-delete) Course X | user01 xem lại Progress/History cũ vẫn hoạt động, không lỗi 500, dù Course X không còn hiện trong danh sách mới | Critical |
| TC-ADMIN-013 | Xoá Lesson — Question liên quan không gây lỗi Quiz cũ | Lesson đã bị xoá, đã có QuizAttempt cũ dùng Question của Lesson đó | user01 xem lại Quiz History cũ | Vẫn xem được chi tiết attempt cũ bình thường, không lỗi khi Lesson gốc đã bị xoá | High |
| TC-ADMIN-014 | Admin không sửa được Vocabulary custom của User | "my_custom_word" thuộc user01 | Admin `PUT /api/admin/vocabularies/{id}` lên từ đó | 403/404 — Admin không có quyền qua kênh quản trị nội dung hệ thống với dữ liệu cá nhân User | Critical |
| TC-ADMIN-015 | Tạo Question cho Lesson (sourceType=LESSON) | Lesson tồn tại | `POST /api/admin/questions` sourceType=LESSON, sourceId=lessonId | 200, Question tạo mới, xuất hiện khi generate Quiz từ Lesson đó | High |
| TC-ADMIN-016 | Tạo QuestionOption — đúng 1 đáp án đúng | Question MULTIPLE_CHOICE | Tạo 4 option, chỉ 1 option `isCorrect=true` | 200 | High |
| TC-ADMIN-017 | Tạo QuestionOption — 0 hoặc >1 đáp án đúng (dữ liệu sai) | | Tạo 4 option với 0 hoặc 2 option `isCorrect=true` | 400 validate — không cho lưu câu hỏi Multiple Choice thiếu/thừa đáp án đúng | High |

### 3.3 Quản lý User

| ID | Tiêu đề | Precondition | Steps | Expected Result | Priority |
|---|---|---|---|---|---|
| TC-ADMIN-018 | Xem danh sách User | Đăng nhập ADMIN | `GET /api/admin/users` | 200, danh sách đầy đủ, **không** có field password/passwordHash | Critical |
| TC-ADMIN-019 | Tìm kiếm User theo username/email | | `GET /api/admin/users?keyword=user01` | Trả đúng user01 | Medium |
| TC-ADMIN-020 | Vô hiệu hoá (Disable) User | user01 đang ACTIVE | `PUT /api/admin/users/{id}/disable` | 200, `status=DISABLED`, RefreshToken của user01 bị revoke ngay | Critical |
| TC-ADMIN-021 | User bị Disable không đăng nhập được ngay | Sau TC-ADMIN-020 | user01 thử login | 401/403 rõ ràng ngay lập tức | Critical |
| TC-ADMIN-022 | User bị Disable đang có phiên — request tiếp theo bị chặn | user01 đang login (có accessToken), sau đó bị Admin disable | user01 gọi tiếp 1 API protected bằng accessToken cũ | Tối thiểu: refresh-token tiếp theo phải thất bại (401); accessToken cũ có thể còn hiệu lực tới khi hết hạn tự nhiên — xác nhận mức độ chặn ngay lập tức cần thiết với dev | High |
| TC-ADMIN-023 | Kích hoạt lại (Activate) User | user01 đang DISABLED | `PUT /api/admin/users/{id}/activate` | 200, `status=ACTIVE`, đăng nhập lại bình thường | High |
| TC-ADMIN-024 | Khoá (Lock) User | | `PUT /api/admin/users/{id}/lock` | 200, `status=LOCKED` | High |
| TC-ADMIN-025 | Xem tiến độ học của 1 User | user01 có dữ liệu học tập | `GET /api/admin/users/{id}/progress` | Trả đúng Course Progress, XP, Streak... của user01, không lẫn user khác | High |
| TC-ADMIN-026 | Admin tự disable chính mình | Đăng nhập admin01 | `PUT /api/admin/users/{admin01Id}/disable` | Cần xác nhận rule: nên bị chặn (tránh tự khoá hệ thống) hoặc cho phép nhưng cảnh báo rõ — ghi nhận behavior thực tế khi test | Medium |
| TC-ADMIN-027 | USER thường gọi API quản lý User | Đăng nhập user01 | `GET /api/admin/users` | 403 Forbidden | Critical |

### 3.4 Admin Dashboard

| ID | Tiêu đề | Precondition | Steps | Expected Result | Priority |
|---|---|---|---|---|---|
| TC-ADMIN-028 | Dashboard hiển thị đúng Total Users | Biết chính xác số user ACTIVE trong DB test | `GET /api/admin/dashboard` | Số liệu khớp, không đếm cả user đã bị soft-delete (nếu có khái niệm này cho User) | High |
| TC-ADMIN-029 | Dashboard hiển thị đúng Total Courses | | | Số liệu khớp, loại trừ Course đã soft-delete | High |
| TC-ADMIN-030 | Dashboard không truy cập được bởi USER | Đăng nhập user01 | `GET /api/admin/dashboard` | 403 Forbidden | Critical |
| TC-ADMIN-031 | Dashboard cập nhật sau khi có dữ liệu mới | Tạo thêm 1 Course mới | Xem lại Dashboard | Total Courses tăng +1 | Medium |
