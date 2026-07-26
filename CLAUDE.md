# CLAUDE.md

Hướng dẫn bắt buộc khi code trong repo này. Đọc trước khi viết bất kỳ dòng code nào; nếu có mâu thuẫn giữa yêu cầu tức thời và file này, dừng lại hỏi thay vì tự ý phá vỡ kiến trúc đã chốt.

## Dự án

Website học ngoại ngữ (MVP: tiếng Anh, kiến trúc mở rộng đa ngôn ngữ). Backend Java 21 + Spring Boot 3 + MySQL + JWT. Frontend React + Vite + TypeScript + Bootstrap 5. Hai repo con: `language-learning-backend/`, `language-learning-client/` (mỗi repo có `.git` riêng).

## Đọc trước khi code

| Cần biết gì | File |
|---|---|
| Kiến trúc tổng thể, ERD, package structure, API list, roadmap | `docs/PROJECT_OVERVIEW.md` |
| Quyết định thiết kế cốt lõi (D1–D12) — **bắt buộc tuân theo, không tự ý đổi** | `docs/PROJECT_OVERVIEW.md` mục 2 |
| Naming convention, Git workflow, Definition of Done | `docs/dev/CODING_CONVENTIONS.md` |
| Danh mục exception/error code chuẩn | `docs/dev/ERROR_CODE_CATALOG.md` |
| Lịch sử thay đổi schema (vì chưa dùng Flyway) | `docs/dev/SCHEMA_CHANGE_LOG.md` |
| Field-level chi tiết từng entity | `docs/testing/07_DATA_DICTIONARY.md` |
| Test Case mô tả hành vi đúng của từng chức năng — dùng như đặc tả khi không chắc 1 flow nên xử lý ra sao | `docs/testing/11_FRS_TC_AUTH.md` → `docs/testing/21_FRS_TC_ADMIN.md` |

## Quy tắc bắt buộc (không thương lượng)

Đây là các quyết định đã chốt sau khi review kỹ kiến trúc — vi phạm bất kỳ điều nào dưới đây coi như bug thiết kế, không phải "cách làm khác":

1. **Vocabulary dùng chung** — `Lesson`/`Deck` chỉ liên kết tới `Vocabulary` qua bảng join, không bao giờ copy dữ liệu từ vựng.
2. **SRS khoá theo `(user, vocabulary)`** — không bao giờ theo deck/lesson. `UserVocabularyProgress` unique composite `(userId, vocabularyId)`.
3. **Không có entity `Exercise` riêng** — bài tập trong Lesson = `Question` với `sourceType=LESSON`.
4. **Không có entity `Quiz` tĩnh** — Quiz luôn generate động từ ngân hàng `Question`, kết quả lưu vào `QuizAttempt`.
5. **Không có entity `Flashcard` riêng** — chỉ là chế độ hiển thị của `Vocabulary`.
6. **Ownership check bắt buộc** ở Service layer cho mọi API sửa/xoá dữ liệu cá nhân — `currentUserId` luôn lấy từ `SecurityContext`, không bao giờ nhận `userId` từ request body/param.
7. **Controller không chứa business logic** — chỉ nhận request, gọi Service, trả `ApiResponse<T>`.
8. **Không trả Entity trực tiếp** ra API — luôn qua DTO Response.
9. **XP** cộng vào `User.xp` (denormalized) **và** ghi 1 dòng `XpLog` cùng lúc, trong cùng transaction — không bao giờ chỉ cập nhật 1 trong 2.
10. **Soft delete** chỉ áp dụng cho Content/Master data (User, Course, Lesson, Vocabulary, Deck...) — **không** áp dụng cho log/transaction data (`XpLog`, `ReviewLog`, `ActivityHistory`, `QuizAttemptAnswer`).
11. **Streak/Daily Goal** tính theo `activityDate` = ngày theo **timezone của User**, không theo UTC/giờ server.
12. **Không hardcode secret** — `DB_PASSWORD`, `JWT_SECRET` luôn qua biến môi trường (xem `.env.example` ở mỗi repo). Không bao giờ commit giá trị thật.

Chi tiết đầy đủ + lý do từng quyết định: `docs/PROJECT_OVERVIEW.md` mục 2 (D1–D12).

## Cấm tuyệt đối

- `CascadeType.ALL` tuỳ tiện (đánh giá cascade cụ thể theo từng quan hệ).
- EAGER loading tuỳ tiện (mặc định LAZY, dùng `@EntityGraph`/JPQL projection khi cần tránh N+1).
- Hardcode ID, hardcode user hiện tại.
- Tạo Entity mới trùng lặp khi đã có entity tương tự — kiểm tra `docs/PROJECT_OVERVIEW.md` mục 6 (ERD) trước khi thêm entity.
- Để lại `TODO`/pseudo-code khi báo cáo 1 phần việc là "xong".
- Bỏ qua `docs/dev/ERROR_CODE_CATALOG.md` khi thêm exception mới — luôn thêm dòng tương ứng vào catalog cùng lúc.

## Backend

Package theo domain đã chốt ở `docs/PROJECT_OVERVIEW.md` mục 7.1 — không tự tạo package ngoài danh sách đó. Trong mỗi module: `controller/ service/ service/impl/ repository/ entity/ dto/{request,response}/ mapper/`. Naming đầy đủ ở `docs/dev/CODING_CONVENTIONS.md` mục 1.

Lệnh thường dùng:
```bash
cd language-learning-backend
./mvnw spring-boot:run          # chạy dev
./mvnw test                     # chạy unit test
```

## Frontend

Cấu trúc thư mục đã chốt ở `docs/PROJECT_OVERVIEW.md` mục 8. Component không tự gọi axios — luôn qua `services/`. Naming đầy đủ ở `docs/dev/CODING_CONVENTIONS.md` mục 2.

Lệnh thường dùng:
```bash
cd language-learning-client
npm run dev                     # chạy dev server
npm run lint                    # bắt buộc chạy sạch trước khi coi 1 tính năng là xong
npm run build                   # kiểm tra build production không lỗi type
```

## Database

`ddl-auto=update` đang bật (chưa dùng Flyway) — mọi thay đổi entity **phải** ghi vào `docs/dev/SCHEMA_CHANGE_LOG.md` trong cùng commit, và đối chiếu lại `docs/testing/07_DATA_DICTIONARY.md` nếu ảnh hưởng tới field tester đang dùng để test.

## Trước khi báo 1 module đã xong

Chạy qua checklist Definition of Done ở `docs/dev/CODING_CONVENTIONS.md` mục 5. Không tự ý bỏ qua bước nào trong đó khi báo cáo hoàn thành với người dùng.

## Không tự ý thay đổi

Không đổi kiến trúc/kiến quyết đã chốt (package structure, entity design, D1–D12) mà không giải thích lý do và được xác nhận — kể cả khi cách khác "gọn hơn". Nếu phát hiện vấn đề với thiết kế hiện tại, nêu ra và đề xuất, không tự ý sửa `docs/PROJECT_OVERVIEW.md` rồi code theo hướng mới trong cùng 1 lượt.
