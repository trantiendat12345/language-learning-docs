# Module: Course & Lesson (Course-based Learning) — Functional Requirements & Test Cases

> **Phần 1 = Đặc tả chức năng (Functional Spec)** — dev đọc phần này để biết cần implement gì, không cần đọc Test Case. **Phần 2 + 3 = Test Scenarios/Test Case** — tester dùng để kiểm thử. File gộp chung 2 mục đích để tránh 2 tài liệu lệch nhau khi sửa rule (xem `CLAUDE.md`).

## Phần 1 — Functional Requirements

### 1.1 Xem danh sách Course

**API:** `GET /api/courses?languageId=&level=&keyword=&page=` (public)
**Main flow:** Trả danh sách Course có `status=PUBLISHED`, hỗ trợ filter theo `languageId`, `difficulty`, tìm theo `keyword` (title), phân trang.
**Business Rule:** Course `DRAFT`/`ARCHIVED` **không** được xuất hiện trong danh sách này dù gọi bởi bất kỳ ai (kể cả không truyền filter).

### 1.2 Xem chi tiết Course & Enroll

**API:** `GET /api/courses/{id}` (public), `POST /api/courses/{id}/enroll` (protected)
**Main flow:** Xem chi tiết Course kèm danh sách Lesson (chỉ tiêu đề/tóm tắt nếu chưa enroll). Bấm Enroll → tạo `CourseEnrollment(status=IN_PROGRESS, progressPercent=0)`.
**Exception flow:** Enroll khi đã enroll rồi → không tạo bản ghi trùng (idempotent hoặc trả lỗi rõ ràng "đã đăng ký"). Course `DRAFT` → 404 khi truy cập trực tiếp bằng id (không tiết lộ nội dung chưa publish).

### 1.3 Học nội dung Lesson

**API:** `GET /api/lessons/{id}` (public nhưng nội dung đầy đủ chỉ khi đã enroll), `POST /api/lessons/{id}/complete` (protected)
**Business Rule quan trọng:**
- Nếu **chưa enroll** Course chứa Lesson đó → chỉ thấy preview (không thấy đầy đủ Vocabulary/Grammar/Question), hoặc bị chặn tuỳ thiết kế — xác nhận cụ thể khi code, nhưng phải nhất quán.
- Vocabulary/Grammar hiển thị trong Lesson lấy qua bảng join `LessonVocabulary` — sửa 1 `Vocabulary` (Admin sửa) phải phản ánh ngay ở mọi Lesson đang dùng từ đó (xem D1/D9 mục 9 ở `04_BUSINESS_RULES_GLOBAL.md`).
- Hoàn thành Lesson (`POST .../complete`) chỉ tính 1 lần — hoàn thành lại (học lại) không cộng thêm XP (xem `04_BUSINESS_RULES_GLOBAL.md` mục 1) nhưng vẫn cho phép học lại nội dung.
- Sau khi hoàn thành hết các Lesson `PUBLISHED` trong 1 Course → `CourseEnrollment.status` chuyển `COMPLETED`, `progressPercent = 100`.

### 1.4 Continue Learning

**Mô tả:** Từ Dashboard, dẫn thẳng tới Lesson tiếp theo chưa hoàn thành trong Course đang học gần nhất (dựa trên `LessonProgress`/`displayOrder`).

## Phần 2 — Test Scenarios

1. Danh sách Course chỉ hiện `PUBLISHED`, filter đúng theo Language/Level/keyword, phân trang đúng.
2. Xem chi tiết Course — thấy đủ Lesson theo đúng thứ tự `displayOrder`.
3. Enroll thành công, không tạo trùng khi enroll lại.
4. Học Lesson — nội dung Vocabulary/Grammar hiển thị đúng, đúng thứ tự.
5. Hoàn thành Lesson → cập nhật LessonProgress, CourseEnrollment.progressPercent, XP.
6. Hoàn thành lại Lesson đã complete → không cộng thêm XP.
7. Hoàn thành hết Lesson trong Course → CourseEnrollment chuyển COMPLETED.
8. Truy cập Lesson thuộc Course chưa enroll — đúng behavior đã thống nhất (preview hoặc chặn).
9. Admin sửa Vocabulary hệ thống → phản ánh đúng ở Lesson đang dùng.
10. Continue Learning dẫn đúng tới Lesson tiếp theo.
11. Course/Lesson DRAFT không lộ ra ngoài dưới mọi hình thức truy cập trực tiếp bằng id.

## Phần 3 — Test Cases chi tiết

> **Trạng thái implement (2026-07-29):** TC-COURSE-001 → 008, 021, 022 (Course/Lesson Admin CRUD + xem public, filter/pagination, DRAFT không lộ) **đã test được**. TC-COURSE-009 → 017, 019, 020 (Enroll, Complete Lesson, Continue Learning, Course Progress, audio phát âm) **chưa test được** — cần `CourseEnrollment`/`LessonProgress` (chunk sau của Giai đoạn 3) và `Vocabulary` (Vocabulary/Grammar chưa gắn vào Lesson). TC-COURSE-018 (sửa Vocabulary phản ánh vào Lesson) chưa test được vì `Vocabulary` và bảng join `LessonVocabulary` chưa tồn tại.

| ID | Tiêu đề | Precondition | Steps | Test Data | Expected Result | Priority |
|---|---|---|---|---|---|---|
| TC-COURSE-001 | Danh sách Course chỉ hiện PUBLISHED | Có course DRAFT "Business English" (xem `09_TEST_DATA.md`) | `GET /api/courses` | | Danh sách không chứa "Business English" | Critical |
| TC-COURSE-002 | Filter Course theo languageId | | `GET /api/courses?languageId={id của en}` | | Chỉ trả course tiếng Anh | High |
| TC-COURSE-003 | Filter Course theo difficulty | | `GET /api/courses?level=A1` | | Chỉ trả course A1 | High |
| TC-COURSE-004 | Search Course theo keyword | | `GET /api/courses?keyword=IELTS` | | Trả "IELTS Vocabulary Booster" | Medium |
| TC-COURSE-005 | Phân trang danh sách Course | Có ≥ 5 course | `GET /api/courses?page=0&size=2` | | Trả đúng 2 kết quả trang đầu, có `totalElements`/`totalPages` đúng | Medium |
| TC-COURSE-006 | Truy cập Course DRAFT trực tiếp bằng id | Biết id của "Business English" (DRAFT) | `GET /api/courses/{id}` bởi USER | | 404 (không lộ tồn tại) | Critical |
| TC-COURSE-007 | Admin xem được Course DRAFT | Đăng nhập ADMIN | `GET /api/admin/courses/{id}` | | 200, thấy đầy đủ | High |
| TC-COURSE-008 | Xem chi tiết Course PUBLISHED | | `GET /api/courses/{id}` course "English Beginner A1" | | 200, danh sách Lesson đúng thứ tự displayOrder | High |
| TC-COURSE-009 | Enroll Course thành công | Đã login user01, chưa enroll | `POST /api/courses/{id}/enroll` | | 200, `CourseEnrollment` tạo mới, status=IN_PROGRESS, progressPercent=0 | Critical |
| TC-COURSE-010 | Enroll lại Course đã enroll | Sau TC-COURSE-009 | Gọi lại enroll cùng course | | Không tạo bản ghi trùng, trả kết quả hợp lý (200 idempotent hoặc 400 rõ ràng) | High |
| TC-COURSE-011 | Enroll khi chưa login | Chưa login | `POST /api/courses/{id}/enroll` | | 401 | Critical |
| TC-COURSE-012 | Xem Lesson đã enroll — đủ nội dung | Đã enroll course chứa Lesson 1 | `GET /api/lessons/{lesson1Id}` | | 200, đầy đủ Vocabulary + Grammar + Question | Critical |
| TC-COURSE-013 | Xem Lesson chưa enroll | Chưa enroll | `GET /api/lessons/{lesson1Id}` | | Theo đúng behavior đã xác nhận (preview rút gọn hoặc 403) — verify nhất quán giữa các Lesson | High |
| TC-COURSE-014 | Hoàn thành Lesson lần đầu | Đã enroll, chưa complete Lesson 1 | `POST /api/lessons/{id}/complete` | | 200, `LessonProgress.status=COMPLETED`, XP cộng đúng (`LESSON_COMPLETED` trong XpLog), `CourseEnrollment.progressPercent` tăng | Critical |
| TC-COURSE-015 | Hoàn thành lại Lesson đã complete | Sau TC-COURSE-014 | Gọi lại complete cùng Lesson | | 200, **không** cộng thêm XP, không tạo thêm XpLog cho sự kiện này | Critical |
| TC-COURSE-016 | Hoàn thành hết Lesson trong Course | Đã complete toàn bộ Lesson PUBLISHED của "English Beginner A1" | Xem lại CourseEnrollment | | `status=COMPLETED`, `progressPercent=100` | High |
| TC-COURSE-017 | Continue Learning dẫn đúng Lesson tiếp theo | Đã hoàn thành Lesson 1, chưa học Lesson 2 | Vào Dashboard, bấm Continue Learning | | Điều hướng tới Lesson 2 | High |
| TC-COURSE-018 | Sửa Vocabulary hệ thống phản ánh vào Lesson | Admin sửa nghĩa từ "apple" | Xem lại Lesson 1 (chứa từ apple) | meaning mới | Nghĩa hiển thị trong Lesson cập nhật đúng ngay lập tức, không cần thao tác gì thêm ở Lesson | High |
| TC-COURSE-019 | Nghe audio phát âm từ vựng trong Lesson | Vocabulary có `pronunciationAudioUrl` | Bấm icon loa | | Audio phát đúng, không lỗi 404 file | Medium |
| TC-COURSE-020 | Course Progress hiển thị đúng % | Đã hoàn thành 1/3 Lesson của 1 Course có 3 Lesson PUBLISHED | Xem Course Detail | | `progressPercent` ≈ 33% | High |
| TC-COURSE-021 | Lesson DRAFT không xuất hiện trong danh sách Lesson của Course (phía USER) | Course có Lesson 3 DRAFT (xem `09_TEST_DATA.md`) | `GET /api/courses/{courseId}/lessons` (USER) | | Danh sách không chứa Lesson 3 | High |
| TC-COURSE-022 | Admin thấy cả Lesson DRAFT | Đăng nhập ADMIN | `GET /api/admin/courses/{id}/lessons` | | Thấy đủ kể cả DRAFT | Medium |
