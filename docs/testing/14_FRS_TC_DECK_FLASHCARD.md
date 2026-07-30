# Module: Deck & Flashcard (Deck-based Learning) — Functional Requirements & Test Cases

> **Phần 1 = Đặc tả chức năng (Functional Spec)** — dev đọc phần này để biết cần implement gì, không cần đọc Test Case. **Phần 2 + 3 = Test Scenarios/Test Case** — tester dùng để kiểm thử. File gộp chung 2 mục đích để tránh 2 tài liệu lệch nhau khi sửa rule (xem `CLAUDE.md`).

## Phần 1 — Functional Requirements

### 1.1 CRUD Deck

**API:** `POST/GET/PUT/DELETE /api/decks/**` (protected, trừ tìm kiếm Public Deck)
**Business Rules (Ownership — xem `04_BUSINESS_RULES_GLOBAL.md` mục 6):**
- Chỉ chủ sở hữu (`Deck.ownerId == currentUserId`) mới được sửa/xoá Deck của mình.
- Xoá Deck = soft delete (D9) — không mất dữ liệu `UserVocabularyProgress` của các từ trong deck (vì progress khoá theo `(user, vocabulary)`, độc lập với Deck).
- Deck mới tạo mặc định `visibility=PRIVATE`.

### 1.2 Quản lý từ vựng trong Deck

**API:** `POST /api/decks/{id}/cards`, `DELETE /api/decks/{id}/cards/{cardId}` (protected)
**Business Rule:** Thêm từ vào Deck = tạo `DeckCard` tham chiếu `Vocabulary` có sẵn (không copy dữ liệu — xem D1). Nếu từ chưa tồn tại trong hệ thống, cho phép tạo `Vocabulary` custom mới (`ownerId = currentUserId`) rồi liên kết vào Deck. 1 từ không được thêm trùng lặp vào cùng 1 Deck (unique `deckId+vocabularyId`).

### 1.3 Public Deck — Tìm kiếm, Clone

**API:** `GET /api/decks?visibility=PUBLIC&keyword=` (public), `POST /api/decks/{id}/clone` (protected)
**Business Rule (D3 — xem chi tiết `04_BUSINESS_RULES_GLOBAL.md` mục 4):**
- Chỉ Deck `visibility=PUBLIC` xuất hiện trong tìm kiếm công khai.
- Clone tạo Deck mới độc lập, `clonedFromDeckId` trỏ về gốc, `DeckCard` trỏ cùng `Vocabulary`.
- Sau khi clone, sửa/xoá deck gốc không ảnh hưởng bản clone.
- Deck Private của người khác **không** được tìm thấy/xem/clone dù biết id trực tiếp.

### 1.4 Học Flashcard

**Mô tả:** Không phải entity riêng — là chế độ hiển thị `Vocabulary` (qua `DeckCard`) dạng thẻ lật. Các chế độ: Normal (từ→nghĩa), Reverse (nghĩa→từ), Shuffle/Random (xáo trộn thứ tự). Sau mỗi thẻ, người dùng đánh giá Forgot/Hard/Good/Easy → cập nhật `UserVocabularyProgress` (chi tiết thuật toán ở `15_FRS_TC_SRS_REVIEW.md`).

## Phần 2 — Test Scenarios

1. CRUD Deck thành công (tạo/sửa/xoá) bởi chủ sở hữu.
2. User khác không sửa/xoá được Deck không phải của mình (kể cả Public Deck).
3. Thêm/sửa/xoá từ vựng trong Deck.
4. Không thêm trùng 1 từ 2 lần vào cùng Deck.
5. Đặt Deck Public/Private, kiểm tra hiển thị đúng phạm vi.
6. Tìm kiếm Public Deck theo keyword.
7. Clone Public Deck — deck mới độc lập với gốc.
8. Sửa/xoá deck gốc sau khi đã bị clone — không ảnh hưởng bản clone.
9. Không clone được Deck Private của người khác.
10. Học Flashcard đủ các chế độ Normal/Reverse/Shuffle.
11. Đánh giá Flashcard tạo/cập nhật đúng UserVocabularyProgress.

## Phần 3 — Test Cases chi tiết

> **Trạng thái implement (2026-07-30):** TC-DECK-001 → 020 (CRUD Deck + ownership, thêm/xoá từ vào Deck kể cả tạo từ custom, Public search, Clone + độc lập với gốc) **đã test được**. TC-DECK-021 → 025 (Flashcard learning modes Normal/Reverse/Shuffle, đánh giá Forgot/Hard/Good/Easy) **chưa test được** — cần `UserVocabularyProgress`/thuật toán SM-2 (Giai đoạn 6, xem `docs/PROJECT_OVERVIEW.md` mục 13 và `15_FRS_TC_SRS_REVIEW.md`).

| ID | Tiêu đề | Precondition | Steps | Test Data | Expected Result | Priority |
|---|---|---|---|---|---|---|
| TC-DECK-001 | Tạo Deck thành công | Đã login user01 | `POST /api/decks` | title="My New Deck", languageId=en | 200, Deck tạo với ownerId=user01, visibility=PRIVATE mặc định | Critical |
| TC-DECK-002 | Tạo Deck thiếu title | Đã login | title rỗng | | 400 validate | Medium |
| TC-DECK-003 | Sửa Deck của chính mình | user01 sở hữu "My First Deck" | `PUT /api/decks/{id}` | title mới | 200, cập nhật thành công | High |
| TC-DECK-004 | Sửa Deck của người khác | user02 cố sửa Deck của user01 | `PUT /api/decks/{user01DeckId}` bằng token user02 | | 403 Forbidden, dữ liệu deck của user01 không đổi | Critical |
| TC-DECK-005 | Xoá Deck của chính mình | user01 sở hữu deck | `DELETE /api/decks/{id}` | | 200, deck soft-delete, không còn trong danh sách My Decks | High |
| TC-DECK-006 | Xoá Deck của người khác | user02 cố xoá deck user01 | `DELETE /api/decks/{user01DeckId}` bằng token user02 | | 403 Forbidden | Critical |
| TC-DECK-007 | Xoá Deck không tồn tại | | `DELETE /api/decks/999999` | | 404 | Low |
| TC-DECK-008 | Thêm từ vựng có sẵn vào Deck | Deck của user01 tồn tại, từ "family" có sẵn | `POST /api/decks/{id}/cards` | vocabularyId=id của "family" | 200, DeckCard tạo mới | High |
| TC-DECK-009 | Thêm trùng 1 từ vào cùng Deck | Sau TC-DECK-008 | Thêm lại đúng vocabularyId đó | | 400, "từ đã có trong deck" hoặc bị bỏ qua idempotent — không tạo bản ghi trùng | High |
| TC-DECK-010 | Thêm từ mới (custom) vào Deck | Đã login user01 | Nhập từ chưa tồn tại trong hệ thống + nghĩa | word="testword123" | 200, tạo `Vocabulary(ownerId=user01)` mới + `DeckCard` liên kết | High |
| TC-DECK-011 | Xoá từ khỏi Deck | DeckCard tồn tại | `DELETE /api/decks/{id}/cards/{cardId}` | | 200, DeckCard bị xoá, Vocabulary gốc **không** bị xoá (vẫn dùng ở nơi khác) | High |
| TC-DECK-012 | User khác thêm/xoá từ trong Deck không phải của mình | user02 thao tác lên deck user01 | `POST/DELETE .../cards` | | 403 Forbidden | Critical |
| TC-DECK-013 | Đặt Deck sang Public | user01 sở hữu deck PRIVATE | `PUT /api/decks/{id}` visibility=PUBLIC | | 200, deck xuất hiện trong tìm kiếm Public | High |
| TC-DECK-014 | Tìm kiếm Public Deck theo keyword | Deck "TOEIC 600 Words" đã PUBLIC (xem `09_TEST_DATA.md`) | `GET /api/decks?visibility=PUBLIC&keyword=TOEIC` | | Trả về đúng deck, không trả deck PRIVATE của ai khác dù trùng keyword | Critical |
| TC-DECK-015 | Deck Private không xuất hiện trong tìm kiếm Public | "user02's Private Deck" là PRIVATE | `GET /api/decks?visibility=PUBLIC` | | Không có mặt trong kết quả | Critical |
| TC-DECK-016 | Truy cập trực tiếp Deck Private của người khác bằng id | user01 biết id deck PRIVATE của user02 | `GET /api/decks/{user02PrivateDeckId}` bằng token user01 | | 403/404 (không lộ nội dung) | Critical |
| TC-DECK-017 | Clone Public Deck thành công | user02 xem "TOEIC 600 Words" (public, của user01) | `POST /api/decks/{id}/clone` bằng token user02 | | 200, Deck mới tạo với ownerId=user02, clonedFromDeckId=id gốc, chứa đủ DeckCard tham chiếu cùng Vocabulary | Critical |
| TC-DECK-018 | Deck đã clone độc lập với deck gốc khi gốc bị sửa | Sau TC-DECK-017, user01 sửa/xoá deck gốc | Xem lại deck đã clone của user02 | | Deck của user02 vẫn nguyên vẹn, không bị ảnh hưởng | Critical |
| TC-DECK-019 | Không clone được Deck Private | user02 cố clone deck PRIVATE của user01 | `POST /api/decks/{privateDeckId}/clone` | | 403/404 | Critical |
| TC-DECK-020 | Clone khi chưa login | Chưa login | `POST /api/decks/{publicDeckId}/clone` | | 401 | High |
| TC-DECK-021 | Học Flashcard — chế độ Normal | Deck có ≥ 3 từ | Vào Deck, chọn Normal | | Hiển thị mặt trước = từ, bấm để lật xem nghĩa/IPA/ví dụ | High |
| TC-DECK-022 | Học Flashcard — chế độ Reverse | Cùng deck | Chọn Reverse | | Hiển thị mặt trước = nghĩa, đoán từ | High |
| TC-DECK-023 | Học Flashcard — chế độ Shuffle | Cùng deck, học 2 lượt liên tiếp | Chọn Shuffle | | Thứ tự thẻ khác nhau giữa 2 lượt (xác suất cao, không cố định) | Medium |
| TC-DECK-024 | Đánh giá Flashcard — Good | Từ chưa có UserVocabularyProgress | Học flashcard, chọn "Good" | | Tạo mới `UserVocabularyProgress`, `nextReviewDate` được set theo interval mặc định (xem `15_FRS_TC_SRS_REVIEW.md`) | Critical |
| TC-DECK-025 | Deck rỗng — trạng thái Empty State | Deck mới tạo, chưa có từ nào | Vào học Flashcard | | Hiển thị Empty State rõ ràng, không lỗi trắng trang/500 | Medium |
