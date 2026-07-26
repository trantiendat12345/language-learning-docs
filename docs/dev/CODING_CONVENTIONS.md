# Coding Conventions

> Quy ước đặt tên, tổ chức code và quy trình Git — giữ code nhất quán xuyên suốt nhiều phiên làm việc (kể cả khi có nhiều người/nhiều phiên AI hỗ trợ code). Kiến trúc package/layer chi tiết xem `docs/PROJECT_OVERVIEW.md` mục 5, 7; file này chỉ bổ sung quy ước đặt tên & quy trình chưa có ở đó.

## 1. Backend (Java / Spring Boot)

### 1.1 Naming theo layer

| Layer | Suffix/Pattern | Ví dụ |
|---|---|---|
| Entity | Tên danh từ số ít, không suffix | `Vocabulary`, `Deck`, `UserVocabularyProgress` |
| Repository | `<Entity>Repository` | `VocabularyRepository` |
| Service (interface) | `<Entity>Service` | `VocabularyService` |
| Service (implementation) | `<Entity>ServiceImpl` | `VocabularyServiceImpl` |
| Controller | `<Entity>Controller` (thêm `Admin` prefix nếu thuộc `/api/admin/**`) | `VocabularyController`, `AdminVocabularyController` |
| Request DTO | `<Entity><Action>Request` | `VocabularyCreateRequest`, `VocabularyUpdateRequest` |
| Response DTO | `<Entity>Response` (đầy đủ) / `<Entity>SummaryResponse` (rút gọn cho danh sách) | `VocabularyResponse`, `VocabularySummaryResponse` |
| Mapper (MapStruct) | `<Entity>Mapper` | `VocabularyMapper` |
| Custom Exception | `<LýDo>Exception`, kế thừa từ exception hệ thống tương ứng ở `docs/dev/ERROR_CODE_CATALOG.md` | `DeckOwnershipViolationException` |

### 1.2 Quy tắc bổ sung

- Package: giữ đúng cấu trúc domain đã chốt ở `docs/PROJECT_OVERVIEW.md` mục 7.1 — không tạo package mới ngoài danh sách đó khi chưa cập nhật tài liệu.
- Enum: đặt tên `SCREAMING_SNAKE_CASE` cho giá trị (`PUBLISHED`, `IN_PROGRESS`), tên class enum là danh từ số ít (`CourseStatus`, không phải `CourseStatuses`).
- DTO không bao giờ chứa logic nghiệp vụ — chỉ field + validation annotation (`@NotNull`, `@Size`...).
- Constructor injection cho mọi dependency (không dùng `@Autowired` trên field) — dùng Lombok `@RequiredArgsConstructor`.
- Không dùng `System.out.println` — dùng SLF4J (`@Slf4j` của Lombok).
- **Message hiển thị cho người dùng (exception message, response message, validation message...) không hardcode trực tiếp trong code** — đặt trong class hằng số riêng dưới `common/constant/` (vd `ErrorMessage.java`, `ErrorCode.java`, `CommonMessage.java`). Mục đích: sửa nội dung message chỉ cần sửa 1 chỗ, tránh copy-paste sai lệch giữa các nơi dùng cùng 1 message, và tránh gõ nhầm `errorCode` không khớp `docs/dev/ERROR_CODE_CATALOG.md`.

### 1.3 Định dạng code

- Chuẩn format mặc định của IntelliJ/Java (indent 4 space). Nếu sau này thêm Checkstyle/Spotless, cấu hình sẽ ghi bổ sung tại đây.
- Import: không dùng wildcard import (`import x.y.*`).

### 1.4 Comment & Javadoc

- Mọi class và mọi method `public` nên có comment mô tả **class/method đó dùng để làm gì** — không viết comment kiểu chỉ trỏ sang tài liệu khác mà không giải thích gì tại chỗ (vd tránh `// xem docs/xxx.md` là toàn bộ nội dung comment — phải mô tả trước, có thể trỏ thêm tài liệu tham khảo sau nếu cần).
- Comment viết tiếng Việt có dấu đầy đủ (pom.xml đã cấu hình `UTF-8`, không còn rủi ro lỗi encoding).
- Không bắt buộc comment cho method `private` đơn giản, hiển nhiên qua tên hàm.

## 2. Frontend (React / TypeScript)

### 2.1 Naming

| Loại | Pattern | Ví dụ |
|---|---|---|
| Component | PascalCase, tên file trùng tên component | `DeckCard.tsx`, `FlashcardViewer.tsx` |
| Hook custom | `use<Tên>` | `useAuth.ts`, `useReviewToday.ts` |
| Service (gọi API) | `<domain>Service.ts`, export các hàm async | `deckService.ts` → `getDecks()`, `createDeck()` |
| Type/Interface | PascalCase, khớp tên Response DTO backend | `VocabularyResponse`, `DeckSummaryResponse` |
| Context | `<Tên>Context.tsx` + `use<Tên>Context` hook đi kèm | `AuthContext.tsx` → `useAuthContext()` |

### 2.2 Quy tắc bổ sung

- `types/` khớp 1-1 với Response/Request DTO của Backend — khi Backend đổi DTO, cập nhật type tương ứng ngay trong cùng thay đổi (tránh lệch type âm thầm).
- Component không tự gọi `axios` trực tiếp — luôn qua lớp `services/`.
- State toàn cục dùng Context API (`AuthContext`, `ThemeContext`) — chỉ cân nhắc state management library ngoài (Zustand/Redux) nếu Context thực sự không đáp ứng được (ghi rõ lý do vào đây nếu đổi).
- Form dùng `react-hook-form` nhất quán cho mọi form nhập liệu (không tự quản lý state form bằng `useState` rời rạc).

### 2.3 ESLint

Dùng cấu hình đã có sẵn trong `eslint.config.js` của repo — chạy `npm run lint` trước khi coi 1 tính năng là hoàn thành.

## 3. Environment Variables

Tham chiếu `.env.example` ở mỗi repo (`language-learning-backend/.env.example`, `language-learning-client/.env.example`).

**Backend:** Spring Boot không tự đọc file `.env`. Wiring vào `application.properties` bằng placeholder:
```properties
spring.datasource.url=${DB_URL}
spring.datasource.password=${DB_PASSWORD}
jwt.secret=${JWT_SECRET}
```
Giá trị thật lấy từ: (a) biến môi trường hệ điều hành thật (`export DB_URL=...`), hoặc (b) file `application-local.properties` (gitignored) chứa các dòng ghi đè, chạy với profile `local` (`spring.profiles.active=local`).

**Frontend:** Vite đọc trực tiếp file `.env.local` (gitignored) — copy từ `.env.example`, biến phải có prefix `VITE_` mới lộ ra `import.meta.env`.

## 4. Git Workflow

Repo cá nhân, không có team lớn — quy ước ở mức tối thiểu để lịch sử commit dễ đọc lại sau này:

- **Branch:** `feature/<mô-tả-ngắn>` (vd `feature/deck-clone`), `fix/<mô-tả-ngắn>` cho sửa bug.
- **Commit message:** theo dạng `[V<số>] <type>: <mô tả>`, `type` ∈ `feat`, `fix`, `refactor`, `docs`, `test`, `chore`. Ví dụ: `[V7] feat: add deck clone endpoint`, `[V8] fix: streak reset off-by-one khi qua ngày mới`.
- **Tiền tố `[V<số>]`:** đánh số tăng dần tuần tự, **riêng theo từng repo** (`language-learning-backend`, `language-learning-client`, và repo docs mỗi cái có bộ đếm V độc lập, không dùng chung số). Trước khi commit, chạy `git log --oneline -5` ở đúng repo đó để biết số `[V?]` gần nhất rồi lấy số tiếp theo — không tự đoán.
- **Commit theo từng function/chức năng** — không gộp nhiều chức năng không liên quan vào 1 commit lớn. Các file **bắt buộc phải đi cùng nhau mới build được** (vd 1 class kế thừa class khác vừa tạo trong cùng thay đổi) được gộp vào cùng 1 commit atomic; các phần độc lập nhau tách commit riêng.
- Mỗi commit nên ứng với 1 thay đổi hoàn chỉnh có thể build được (không commit code dở dang gây lỗi build).
- **Tuyệt đối không tự ý commit/push** — đây là rule cứng, xem `CLAUDE.md`. Chỉ commit/push khi được yêu cầu rõ ràng cho đúng lần thay đổi đó, kể cả khi đã được cho phép ở lần trước.

## 5. Definition of Done (mỗi module/tính năng)

Trước khi coi 1 module đã hoàn thành (theo đúng tinh thần "mỗi giai đoạn phải hoàn chỉnh, chạy và test được" ở yêu cầu gốc dự án):

- [ ] Code tuân theo layer/naming convention ở file này và `docs/PROJECT_OVERVIEW.md` mục 7.2.
- [ ] Không còn `TODO`/code giả (pseudo-code) trong phần đã khai báo "xong".
- [ ] Exception mới (nếu có) đã được thêm vào `docs/dev/ERROR_CODE_CATALOG.md`.
- [ ] Entity mới/đổi field đã được ghi vào `docs/dev/SCHEMA_CHANGE_LOG.md` và đối chiếu lại `docs/testing/07_DATA_DICTIONARY.md`.
- [ ] API mới đã kiểm tra thủ công qua Swagger/Postman ít nhất 1 lần (happy path + 1 case lỗi).
- [ ] Test Case liên quan ở `docs/testing/FRS_TC_*.md` đã chạy qua ở mức tối thiểu Critical/High (không cần chờ tester riêng nếu code 1 mình, nhưng phải tự chạy).
- [ ] `npm run lint` (frontend) không có lỗi mới phát sinh.
- [ ] Nếu trong lúc làm có việc phát sinh ngoài kế hoạch ban đầu và đã được đồng ý áp dụng (vd thêm 1 config/dependency chưa có trong roadmap) — tài liệu `.md` liên quan đã được cập nhật để khớp đúng với code thực tế.
- [ ] `docs/PROJECT_OVERVIEW.md` mục 12 (roadmap) đã đổi trạng thái Giai đoạn vừa xong thành ✅, mục 13 (Bước tiếp theo) đã trỏ sang bước kế tiếp — xem `CLAUDE.md` mục "Cập nhật tài liệu song song với code".
