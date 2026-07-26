# Module: Global Search — Functional Requirements & Test Cases

> **Phần 1 = Đặc tả chức năng (Functional Spec)** — dev đọc phần này để biết cần implement gì, không cần đọc Test Case. **Phần 2 + 3 = Test Scenarios/Test Case** — tester dùng để kiểm thử. File gộp chung 2 mục đích để tránh 2 tài liệu lệch nhau khi sửa rule (xem `CLAUDE.md`).

## Phần 1 — Functional Requirements

### 1.1 Tìm kiếm toàn hệ thống

**API:** `GET /api/search?q=&type=&page=` (public cho nội dung public; kết quả Deck chỉ gồm Public Deck)
**Main flow:** Tìm theo `keyword` trên các loại nội dung: Course, Lesson, Vocabulary, Grammar, Public Deck. Tham số `type` lọc theo 1 loại cụ thể nếu có, nếu không trả kết quả tổng hợp theo từng nhóm. Hỗ trợ phân trang.
**Business Rule (MVP — xem `docs/PROJECT_OVERVIEW.md` mục 10):** Dùng `LIKE '%keyword%'` + index MySQL, chưa cần full-text/Elasticsearch. Kết quả chỉ gồm nội dung `PUBLISHED`/`ACTIVE` (không lộ DRAFT, không lộ Deck Private, không lộ Vocabulary custom của người khác).

### 1.2 Admin Search User

**API:** `GET /api/admin/search?q=` hoặc tương đương trong `/api/admin/users` (admin only)
**Main flow:** Admin tìm kiếm user theo username/email — xem chi tiết ở `21_FRS_TC_ADMIN.md`.

## Phần 2 — Test Scenarios

1. Tìm kiếm ra đúng kết quả theo từng loại nội dung (Course/Lesson/Vocabulary/Grammar/Public Deck).
2. Tìm kiếm không trả về nội dung DRAFT/Private/không thuộc phạm vi công khai.
3. Tìm kiếm với keyword rỗng/quá ngắn.
4. Tìm kiếm không phân biệt hoa/thường, có dấu/không dấu (nếu yêu cầu — xác nhận mức hỗ trợ khi code).
5. Tìm kiếm với ký tự đặc biệt không gây lỗi 500 / SQL Injection.
6. Phân trang kết quả tìm kiếm.
7. Không có kết quả — Empty State phù hợp.

## Phần 3 — Test Cases chi tiết

| ID | Tiêu đề | Precondition | Steps | Test Data | Expected Result | Priority |
|---|---|---|---|---|---|---|
| TC-SEARCH-001 | Tìm Course theo keyword | Course "IELTS Vocabulary Booster" tồn tại PUBLISHED | `GET /api/search?q=IELTS&type=COURSE` | | Trả đúng course đó | High |
| TC-SEARCH-002 | Tìm không ra Course DRAFT | Course "Business English" là DRAFT | `GET /api/search?q=Business` | | Không xuất hiện trong kết quả | Critical |
| TC-SEARCH-003 | Tìm Vocabulary theo keyword | Từ "apple" tồn tại | `GET /api/search?q=apple&type=VOCABULARY` | | Trả đúng từ "apple" | High |
| TC-SEARCH-004 | Tìm không ra Vocabulary custom của người khác | "my_custom_word" thuộc user01 | user02 tìm với keyword liên quan | | Không xuất hiện trong kết quả của user02 | High |
| TC-SEARCH-005 | Tìm Public Deck | "TOEIC 600 Words" đã PUBLIC | `GET /api/search?q=TOEIC&type=DECK` | | Trả đúng deck | High |
| TC-SEARCH-006 | Tìm không ra Deck Private | "user02's Private Deck" | Tìm với keyword khớp title | | Không xuất hiện trong kết quả tìm kiếm chung | Critical |
| TC-SEARCH-007 | Tìm kiếm tổng hợp không truyền `type` | | `GET /api/search?q=english` | | Trả kết quả gộp/nhóm theo từng loại nội dung | Medium |
| TC-SEARCH-008 | Tìm với keyword rỗng | | `GET /api/search?q=` | | 400 hoặc trả rỗng có kiểm soát (không trả toàn bộ dữ liệu hệ thống) | Medium |
| TC-SEARCH-009 | Tìm với keyword không có kết quả | | `q=zzzzzxxxxx123` | | Trả mảng rỗng, không lỗi | Low |
| TC-SEARCH-010 | Tìm với ký tự đặc biệt/SQL injection | | `q=' OR '1'='1` | | Không lỗi 500, không trả toàn bộ dữ liệu bất thường (ORM tham số hoá xử lý an toàn) | Critical |
| TC-SEARCH-011 | Tìm không phân biệt hoa/thường | Từ "Apple" (viết hoa A) trong DB | `q=apple` (thường) | | Vẫn tìm ra kết quả | Medium |
| TC-SEARCH-012 | Phân trang kết quả tìm kiếm | Có nhiều kết quả khớp keyword phổ biến (vd "a") | `q=a&page=0&size=5` rồi `page=1&size=5` | | 2 trang trả kết quả khác nhau, không trùng lặp/không thiếu | Medium |
| TC-SEARCH-013 | Grammar search | Grammar "Simple Present — to be" tồn tại | `q=Simple Present&type=GRAMMAR` | | Trả đúng kết quả | Medium |
