# Error Code Catalog

> Nguồn chuẩn duy nhất cho `GlobalExceptionHandler` (Backend), cách Frontend đọc lỗi để hiển thị, và cách tester đối chiếu response lỗi khi viết Bug Report (`docs/testing/10_BUG_REPORT_TEMPLATE.md`). Khi thêm 1 exception mới, thêm vào bảng ở đây **trước**, không tự chế `errorCode` tuỳ tiện trong code.

## 1. Cấu trúc response lỗi chuẩn

Mọi lỗi trả về theo đúng 1 cấu trúc `ApiErrorResponse` (khớp `docs/PROJECT_OVERVIEW.md` mục 7.3):

```json
{
  "code": 400,
  "errorCode": "VALIDATION_ERROR",
  "message": "Dữ liệu không hợp lệ",
  "errors": [
    { "field": "email", "message": "Email không đúng định dạng" }
  ]
}
```

- `code`: HTTP status number — dùng để FE xử lý nhánh chung (redirect Login khi 401, hiển thị 403 page...).
- `errorCode`: chuỗi định danh nghiệp vụ cụ thể — dùng để FE hiển thị message/hành vi chi tiết hơn HTTP status thô (vd phân biệt 401 do token hết hạn với 401 do sai mật khẩu).
- `message`: message người dùng đọc được, tiếng Việt, không lộ chi tiết kỹ thuật (không stack trace, không tên bảng/cột DB).
- `errors[]`: chỉ có khi lỗi validate nhiều field — rỗng/không có ở các lỗi khác.

## 2. Exception hệ thống (dùng chung mọi module)

| Exception class | HTTP `code` | `errorCode` | Khi dùng | Message mẫu |
|---|---|---|---|---|
| `ResourceNotFoundException` | 404 | `RESOURCE_NOT_FOUND` | Truy vấn theo id không tồn tại (hoặc đã soft-delete) | "Không tìm thấy dữ liệu" |
| `BadRequestException` | 400 | `BAD_REQUEST` | Request sai định dạng/logic không khớp `MethodArgumentNotValidException` | "Yêu cầu không hợp lệ" |
| `ValidationException` (từ Bean Validation) | 400 | `VALIDATION_ERROR` | Vi phạm `@NotNull`/`@Size`/`@Email`... trên Request DTO | "Dữ liệu không hợp lệ" + `errors[]` |
| `UnauthorizedException` | 401 | `UNAUTHORIZED` | Không có token / token không hợp lệ | "Vui lòng đăng nhập" |
| `ForbiddenException` | 403 | `FORBIDDEN` | Có token hợp lệ nhưng không đủ quyền (role hoặc ownership) | "Bạn không có quyền thực hiện thao tác này" |
| `DuplicateResourceException` | 409 | `DUPLICATE_RESOURCE` | Vi phạm unique constraint tầng nghiệp vụ (trước khi chạm DB) | "Dữ liệu đã tồn tại" |
| *(fallback)* `Exception` chưa xác định | 500 | `INTERNAL_ERROR` | Lỗi không lường trước — **luôn log đầy đủ phía server**, **không bao giờ** trả message/stack trace chi tiết ra response | "Đã có lỗi xảy ra, vui lòng thử lại sau" |

## 3. Error code riêng theo module (bổ sung dần khi triển khai)

Dùng khi 1 HTTP status có nhiều nguyên nhân khác nhau mà FE cần phân biệt (ví dụ 401 do sai mật khẩu khác với 401 do tài khoản bị khoá — xem `docs/testing/11_FRS_TC_AUTH.md`).

### Auth

| `errorCode` | HTTP `code` | Test Case liên quan |
|---|---|---|
| `AUTH_INVALID_CREDENTIALS` | 401 | TC-AUTH-009, 010 (message phải giống hệt nhau giữa 2 case này), TC-PROFILE-009 (sai currentPassword khi đổi mật khẩu — dùng chung `InvalidCredentialsException`) |
| `AUTH_ACCOUNT_DISABLED` | 401 | TC-AUTH-011 |
| `AUTH_ACCOUNT_LOCKED` | 401 | TC-AUTH-012 |
| `AUTH_EMAIL_NOT_VERIFIED` | 401 | **Tắt từ 2026-08-06** — hạ tầng còn giữ (`EmailNotVerifiedException` chưa xoá) nhưng không còn được ném ra qua flow chuẩn (`login()` xử lý PENDING_VERIFICATION như ACTIVE), vì MVP tắt bước xác thực email. Xem `docs/testing/11_FRS_TC_AUTH.md` mục 1.1/1.2, TC-AUTH-013 |
| `AUTH_TOKEN_EXPIRED` | 401 | TC-AUTH-017 (refresh-token), TC-AUTH-025 (reset-password), TC-AUTH-027 (verify-email) — dùng chung `TokenExpiredException` |
| `AUTH_TOKEN_INVALID` | 401 | TC-AUTH-018, 031 (refresh-token, kể cả thiếu cookie), TC-AUTH-033 (reset-password) — dùng chung `TokenInvalidException` |
| `AUTH_TOKEN_ALREADY_USED` | 400 | TC-AUTH-024 (reset-password token dùng lại), TC-AUTH-034 (verify-email token dùng lại) — dùng chung `TokenAlreadyUsedException` |
| `AUTH_USERNAME_TAKEN` | 409 | TC-AUTH-002 |
| `AUTH_EMAIL_TAKEN` | 409 | TC-AUTH-003 |
| `AUTH_PASSWORD_MISMATCH` | 400 | TC-AUTH-006 (register), TC-AUTH-032 (reset-password), TC-PROFILE-011 (change-password) |
| `AUTH_NEW_PASSWORD_SAME_AS_CURRENT` | 400 | TC-PROFILE-017 (newPassword trùng currentPassword khi đổi mật khẩu — quyết định chốt khi code, xem `docs/testing/12_FRS_TC_USER_PROFILE.md` mục 1.3) |

> **Đã chốt (Giai đoạn 2):** Mọi lỗi liên quan tới trạng thái tài khoản khi đăng nhập (sai mật khẩu, DISABLED, LOCKED, PENDING_VERIFICATION) đều trả **401** thay vì phân biệt 401/403 — vì đây là lỗi "không xác thực được", không phải lỗi "đã xác thực nhưng không đủ quyền". `AuthService.login()` kiểm tra `status` thủ công (không dùng `AuthenticationManager`) để ném đúng exception con tương ứng.

### Ownership (dùng ở Deck, Favorite, StudyReminder, Vocabulary custom...)

| `errorCode` | HTTP `code` | Test Case liên quan |
|---|---|---|
| `OWNERSHIP_VIOLATION` | 403 | TC-DECK-004/006/012, TC-NOTI-007 — ✅ đã implement (Giai đoạn 5, `OwnershipViolationException` dùng chung, đặt ở `exception/` top-level để module sau tái sử dụng). Riêng GET đọc tài nguyên private của người khác (TC-DECK-016/019) dùng `ResourceNotFoundException` (404) thay vì `OwnershipViolationException` — cố ý ẩn sự tồn tại, khớp carve-out ở `docs/testing/04_BUSINESS_RULES_GLOBAL.md` mục 6 |

### Course / Lesson Progress (Giai đoạn 3)

| `errorCode` | HTTP `code` | Test Case liên quan |
|---|---|---|
| `COURSE_NOT_ENROLLED` | 400 | `POST /api/lessons/{id}/complete` khi chưa `POST /api/courses/{id}/enroll` — lỗi nghiệp vụ (thiếu bước tiền đề), không phải lỗi quyền nên dùng 400 thay vì 403 |

### Quiz (Giai đoạn 4)

| `errorCode` | HTTP `code` | Test Case liên quan |
|---|---|---|
| `QUIZ_ANSWER_OUT_OF_SCOPE` | 400 | TC-QUIZ-023 — `POST /api/quizzes/attempts` có `questionId` không thuộc đúng `sourceType`/`sourceId` đã khai báo (chặn gian lận) |
| *(không phải errorCode)* Nguồn không đủ câu theo `questionCount` | 200 | TC-QUIZ-003 — KHÔNG dùng errorCode/exception (vẫn là thành công), trả `QuizGenerateResponse{requestedCount, actualCount}` để FE tự so sánh và hiển thị cảnh báo |

### Deck (Giai đoạn 5 — đã implement, không dùng errorCode riêng)

| `errorCode` | HTTP `code` | Test Case liên quan |
|---|---|---|
| `DUPLICATE_RESOURCE` (dùng chung, không tạo `DECK_CARD_ALREADY_EXISTS` riêng) | 409 | TC-DECK-009 — thêm trùng 1 từ vào cùng Deck, `DeckServiceImpl.addCard` ném `DuplicateResourceException` với message riêng, giữ nguyên errorCode chung |
| `RESOURCE_NOT_FOUND` (dùng chung, không tạo `DECK_CLONE_SOURCE_NOT_PUBLIC` riêng) | 404 | TC-DECK-019 — clone Deck Private của người khác, `DeckServiceImpl.cloneDeck` ném `ResourceNotFoundException` (cùng quy tắc "không tiết lộ tồn tại" như GET) |
| `RESOURCE_NOT_FOUND` (dùng chung) | 404 | TC-DECK-026/027 (2026-10-17) — `POST /api/decks/{id}/cards` với `vocabularyId` là Vocabulary custom của User khác hoặc Vocabulary hệ thống `ARCHIVED`: `DeckServiceImpl.findAddableVocabulary` ném `ResourceNotFoundException` (không tiết lộ tồn tại, cùng quy tắc API public `GET /api/vocabularies/{id}`) |
| `BAD_REQUEST` (dùng chung message riêng `ErrorMessage.DECK_VOCABULARY_LANGUAGE_MISMATCH`) | 400 | TC-DECK-028 (2026-10-17) — `vocabularyId` khác ngôn ngữ với Deck |

### Admin User Management (Giai đoạn 9 — đã implement, không dùng errorCode riêng)

| `errorCode` | HTTP `code` | Test Case liên quan |
|---|---|---|
| `BAD_REQUEST` (dùng chung message riêng, không tạo errorCode mới) | 400 | TC-ADMIN-026 — Admin tự `disable`/`lock` chính tài khoản ADMIN của mình, `AdminUserServiceImpl.requireNotSelf` ném `BadRequestException` (tránh tự khoá bản thân ra khỏi hệ thống) |

### Lesson Vocabulary — Admin gắn/import từ vựng vào Lesson (2026-10-12, không dùng errorCode riêng)

| `errorCode` | HTTP `code` | Test Case liên quan |
|---|---|---|
| `RESOURCE_NOT_FOUND` (dùng chung) | 404 | TC-ADMIN-LESSON-VOCAB-002 — `POST /api/admin/lessons/{lessonId}/vocabularies` với `vocabularyId` là Vocabulary custom của User: `LessonServiceImpl.attachVocabularyToLesson` ném `ResourceNotFoundException` (không tiết lộ tồn tại, cùng quy tắc V64 ở `VocabularyServiceImpl.findVocabularyOrThrow`) |
| `BAD_REQUEST` (dùng chung message riêng `ErrorMessage.LESSON_VOCABULARY_LANGUAGE_MISMATCH`) | 400 | TC-ADMIN-LESSON-VOCAB-003 — Vocabulary khác ngôn ngữ với Course chứa Lesson |
| `BAD_REQUEST` (dùng chung message riêng `ErrorMessage.LESSON_VOCABULARY_ARCHIVED`) | 400 | TC-ADMIN-LESSON-VOCAB-013 (2026-10-17) — gắn Vocabulary hệ thống `ARCHIVED` vào Lesson. Dùng 400 (không ẩn bằng 404) vì Admin vẫn thấy từ ARCHIVED ở màn quản trị. Cùng message này là lỗi dòng khi Import vào Lesson gặp từ chỉ còn bản ARCHIVED (TC-ADMIN-LESSON-VOCAB-014) |
| `DUPLICATE_RESOURCE` (dùng chung message riêng `ErrorMessage.LESSON_VOCABULARY_ALREADY_ATTACHED`) | 409 | Gắn trùng 1 từ vào cùng Lesson (đã có từ Chunk B Admin, nay message chuyển vào `ErrorMessage`) |

### Vocabulary hệ thống — chống trùng + từ đang được Lesson dùng (2026-10-17)

| `errorCode` | HTTP `code` | Test Case liên quan |
|---|---|---|
| `DUPLICATE_RESOURCE` (dùng chung, message riêng `ErrorMessage.VOCABULARY_DUPLICATE_IN_SYSTEM` / `VOCABULARY_DUPLICATE_ARCHIVED`, có kèm Word + id bản trùng) | 409 | TC-ADMIN-VOCAB-DUP-001 → 005 — `POST/PUT /api/admin/vocabularies` trùng Word + ngôn ngữ trong kho hệ thống (bỏ qua hoa/thường, phân biệt dấu, sau trim). Cùng message là lỗi dòng của Admin Import. Race 2 request đồng thời: unique index `uk_vocabulary_system_word_key` → `DataIntegrityViolationException` → 409 `DUPLICATE_RESOURCE` message chung "Dữ liệu đã tồn tại" (handler có sẵn) |
| `VOCABULARY_ARCHIVE_CONFIRMATION_REQUIRED` | 409 | TC-ADMIN-VOCAB-USE-001 — `PUT /api/admin/vocabularies/{id}` chuyển ARCHIVED 1 từ đang được Lesson dùng mà chưa có `confirmArchiveInUse=true`; message liệt kê Lesson bị ảnh hưởng. FE đọc errorCode này để hỏi xác nhận rồi gửi lại (`VocabularyArchiveConfirmationRequiredException`) |
| `VOCABULARY_LANGUAGE_CHANGE_IN_USE` | 409 | TC-ADMIN-VOCAB-USE-003 — đổi ngôn ngữ của từ đang được Lesson dùng: luôn chặn, không có cờ xác nhận (`VocabularyLanguageChangeInUseException`) |

### Import CSV/Excel (Vocabulary hệ thống + Deck Card + Lesson Vocabulary — không dùng errorCode riêng)

| `errorCode` | HTTP `code` | Test Case liên quan |
|---|---|---|
| `BAD_REQUEST` (dùng chung message riêng `ErrorMessage.IMPORT_FILE_TOO_LARGE`) | 400 | File Import vượt `spring.servlet.multipart.max-file-size` (5MB) — `GlobalExceptionHandler.handleMaxUploadSizeExceededException` bắt `MaxUploadSizeExceededException` (Spring ném trước khi vào tới Controller) |
| `BAD_REQUEST` (dùng chung message riêng theo từng lỗi cụ thể) | 400 | Không chọn file/file rỗng (`ErrorMessage.IMPORT_FILE_REQUIRED`), sai đuôi file (`IMPORT_INVALID_CSV_EXTENSION`/`IMPORT_INVALID_EXCEL_EXTENSION`), file không có dữ liệu, sai header/không đúng Template, vượt quá 5.000 dòng — đều do `VocabularyImportFileReader` ném `BadRequestException` (từ 2026-10-12 phần kiểm tra file upload gộp vào đây, dùng chung cho cả 3 luồng Vocabulary/Deck/Lesson) |

> **Cảnh báo theo dòng (2026-10-17)** — Import vào Lesson (Admin) và Deck (User) khi 1 dòng tái sử dụng từ đã có nhưng Meaning trong file khác Meaning hiện tại: **không phải lỗi**, không có errorCode, không chặn Import, không sửa dữ liệu — trả trong `ImportResult.warnings[]` (`row`/`word`/`fileMeaning`/`currentMeaning`). Admin Import vào kho hệ thống **không** có cảnh báo này: trùng Word + ngôn ngữ (kể cả với từ ARCHIVED) vẫn luôn là lỗi duplicate.

> Lỗi validate theo từng dòng dữ liệu (thiếu Word/Meaning, trùng trong file, trùng với dữ liệu đã có, từ đã gắn sẵn trong Lesson, từ chỉ còn bản ARCHIVED khi Import vào Lesson...) **không** đi qua cơ chế exception/`ApiErrorResponse` — trả về bình thường (HTTP 200) qua `ApiResponse<ImportResult>`, `ImportResult.errors[]` liệt kê đủ theo dòng (`row`/`column`/`message`), `ImportResult.success=false` và không lưu dữ liệu nào (all-or-nothing).

> **Quy tắc bổ sung dòng mới:** khi implement 1 module và cần 1 error code chưa có trong bảng, thêm ngay vào đây trong cùng commit — không để `errorCode` "trôi nổi" chỉ tồn tại trong code.

## 4. Nguyên tắc bắt buộc

- `GlobalExceptionHandler` là nơi **duy nhất** map exception → response lỗi cho mọi thứ chạm tới Controller/Service — Controller không tự try/catch để tự trả lỗi riêng lẻ. Ngoại lệ bắt buộc: lỗi xác thực xảy ra ngay ở Security Filter Chain (trước khi request tới `DispatcherServlet`) không đi qua được `@RestControllerAdvice`, nên `JwtAuthenticationEntryPoint` (401) và `JwtAccessDeniedHandler` (403) tự dựng `ApiErrorResponse` cùng cấu trúc — xem `language-learning-backend/.../security/`.
- Không bao giờ để lộ: SQL query, tên bảng/cột, đường dẫn file server, stack trace trong `message`.
- Message đủ rõ để User hiểu (tiếng Việt), nhưng đủ mơ hồ để không tiết lộ thông tin nhạy cảm (xem quy tắc ẩn danh ở `docs/testing/11_FRS_TC_AUTH.md` mục 1.2, 1.5).
- Mọi exception mới thêm vào code phải có dòng tương ứng trong file này — coi đây là một phần của Definition of Done (xem `CLAUDE.md`).
