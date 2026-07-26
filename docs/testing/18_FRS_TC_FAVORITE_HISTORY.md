# Module: Favorite & History — Functional Requirements & Test Cases

> **Phần 1 = Đặc tả chức năng (Functional Spec)** — dev đọc phần này để biết cần implement gì, không cần đọc Test Case. **Phần 2 + 3 = Test Scenarios/Test Case** — tester dùng để kiểm thử. File gộp chung 2 mục đích để tránh 2 tài liệu lệch nhau khi sửa rule (xem `CLAUDE.md`).

## Phần 1 — Functional Requirements

### 1.1 Favorite

**API:** `GET/POST/DELETE /api/favorites/**` (protected)
**Main flow:** Người dùng đánh dấu yêu thích Course/Deck/Vocabulary (`Favorite(targetType, targetId)`). Unique `(userId, targetType, targetId)` — bấm Favorite lần 2 vào cùng đối tượng không tạo bản ghi trùng (thường FE sẽ toggle: bấm lần 2 = bỏ favorite).
**Business Rule:** Favorite một Deck Private của người khác — không được phép (chỉ favorite được Deck Public hoặc Deck của chính mình). Favorite một Course/Vocabulary đã bị xoá mềm — không hiển thị trong danh sách My Favorites (ẩn kèm nội dung gốc), nhưng không crash.

### 1.2 History (Recently Viewed/Learned/Reviewed)

**API:** `GET /api/history/recent` (protected)
**Main flow:** Mỗi lần xem/học/ôn tập một đối tượng (Course/Lesson/Deck/Vocabulary), ghi 1 dòng `ActivityHistory(targetType, targetId, action)`. Trang History hiển thị danh sách gần nhất, sắp xếp theo `occurredAt` giảm dần, có thể giới hạn số lượng hiển thị (vd 50 gần nhất) hoặc lọc theo `action`.
**Business Rule:** Đây là dữ liệu log (không audit/soft-delete — xem D9), không cho phép user chỉnh sửa thủ công, chỉ được tạo tự động bởi hệ thống khi có hành động tương ứng.

## Phần 2 — Test Scenarios

1. Favorite/Unfavorite Course/Deck/Vocabulary thành công.
2. Không favorite trùng lặp cùng 1 đối tượng.
3. Không favorite được Deck Private của người khác.
4. Xem danh sách My Favorites — chỉ của chính mình.
5. History ghi nhận đúng khi xem/học/ôn tập.
6. History sắp xếp đúng theo thời gian gần nhất.
7. History không lẫn dữ liệu giữa các user.
8. Favorite/History không crash khi đối tượng gốc đã bị xoá mềm.

## Phần 3 — Test Cases chi tiết

| ID | Tiêu đề | Precondition | Steps | Test Data | Expected Result | Priority |
|---|---|---|---|---|---|---|
| TC-FAV-001 | Favorite 1 Course | Đã login user01 | `POST /api/favorites` targetType=COURSE, targetId | | 200, tạo bản ghi Favorite mới | High |
| TC-FAV-002 | Favorite trùng lặp | Sau TC-FAV-001, gọi lại y hệt | | | Không tạo bản ghi trùng — trả 200 idempotent hoặc 400 rõ ràng (xác nhận behavior cụ thể khi code) | Medium |
| TC-FAV-003 | Bỏ Favorite (Unfavorite) | Đã favorite | `DELETE /api/favorites/{id}` | | 200, bản ghi bị xoá, không còn trong danh sách | High |
| TC-FAV-004 | Favorite Deck Public của người khác | "TOEIC 600 Words" (public, của user01) | user02 favorite deck đó | | 200, thành công | High |
| TC-FAV-005 | Favorite Deck Private của người khác | "user02's Private Deck" | user01 cố favorite deck đó | | 403/404, không tạo được | Critical |
| TC-FAV-006 | Favorite Vocabulary | | `POST /api/favorites` targetType=VOCABULARY | | 200 | Medium |
| TC-FAV-007 | Xem My Favorites — chỉ của chính mình | user01 và user02 đều có favorite riêng | user01 gọi `GET /api/favorites` | | Chỉ thấy favorite của user01 | Critical |
| TC-FAV-008 | Favorite khi chưa login | Chưa login | `POST /api/favorites` | | 401 | Critical |
| TC-FAV-009 | Favorite đối tượng đã bị Admin xoá mềm | Course đã bị Admin soft-delete sau khi user01 đã favorite trước đó | Xem My Favorites | | Không crash — có thể ẩn item đó hoặc hiển thị trạng thái "nội dung không còn tồn tại" | Medium |
| TC-FAV-010 | History ghi nhận khi xem Course Detail | Đã login | Vào xem chi tiết 1 Course | | Có dòng `ActivityHistory(action=VIEWED, targetType=COURSE)` mới | High |
| TC-FAV-011 | History ghi nhận khi hoàn thành Lesson | Đã login | Hoàn thành 1 Lesson | | Có dòng `ActivityHistory(action=LEARNED)` | High |
| TC-FAV-012 | History ghi nhận khi ôn tập | Đã login | Đánh giá 1 từ ở Review Today | | Có dòng `ActivityHistory(action=REVIEWED)` | Medium |
| TC-FAV-013 | History sắp xếp đúng theo thời gian | Có ≥ 3 hoạt động ở các thời điểm khác nhau | `GET /api/history/recent` | | Sắp xếp giảm dần theo `occurredAt`, mới nhất trên đầu | High |
| TC-FAV-014 | History không lẫn giữa các user | user01, user02 đều có hoạt động | user02 gọi `GET /api/history/recent` | | Chỉ thấy hoạt động của user02 | Critical |
| TC-FAV-015 | History rỗng cho user mới | Tài khoản mới, chưa hoạt động gì | `GET /api/history/recent` | | Trả mảng rỗng, Empty State phù hợp | Low |
