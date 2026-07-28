# Requirement Traceability Matrix (RTM)

> Đảm bảo **mọi tính năng trong `02_FEATURE_LIST.md` đều có Test Case tương ứng**, và theo dõi độ phủ kiểm thử theo thời gian. Đây là tài liệu **sống** — cập nhật cột "Trạng thái" mỗi khi thực thi test, không phải viết 1 lần rồi bỏ.

**Quy ước Trạng thái:** `Not Started` · `In Progress` · `Passed` · `Failed` · `Blocked` · `N/A` (tính năng Phase 2/3 chưa triển khai).

## 1. Authentication & Account

| Feature # | Tính năng | Test Case ID | Trạng thái |
|---|---|---|---|
| 1.1 | Đăng ký | TC-AUTH-001 → 007, 029 | Not Started |
| 1.2 | Đăng nhập | TC-AUTH-008 → 013 | Not Started |
| 1.3 | Đăng xuất | TC-AUTH-014, 015, 035 | Not Started |
| 1.4 | Refresh Token | TC-AUTH-016 → 018, 031 | Not Started |
| 1.5/1.6 | Quên/Đặt lại mật khẩu | TC-AUTH-019 → 025, 032, 033 | Not Started |
| 1.7 | Xác thực Email | TC-AUTH-026, 027, 034 | Not Started |
| — | Không lộ dữ liệu nhạy cảm | TC-AUTH-028 | Not Started |
| — | Chặn truy cập không token | TC-AUTH-030 | Not Started |

## 2. User Profile & Settings

| Feature # | Tính năng | Test Case ID | Trạng thái |
|---|---|---|---|
| 2.1/2.2 | Xem/Sửa Profile | TC-PROFILE-001 → 006, 014, 015 | Not Started |
| 2.3 | Đổi mật khẩu | TC-PROFILE-007 → 011 | Not Started |
| 2.4 | Daily Goal | TC-PROFILE-012, 013 | Not Started |
| 2.5 | Theme | TC-PROFILE-016 | Not Started |

## 3. Course / Lesson / Vocabulary / Grammar

| Feature # | Tính năng | Test Case ID | Trạng thái |
|---|---|---|---|
| 3.1/3.2 | Danh sách/Filter/Search Course | TC-COURSE-001 → 007 | Not Started |
| 3.3 | Chi tiết Course | TC-COURSE-008 | Not Started |
| 3.4 | Enroll | TC-COURSE-009 → 011 | Not Started |
| 3.5 | Continue Learning | TC-COURSE-017 | Not Started |
| 3.6 | Course Progress | TC-COURSE-020 | Not Started |
| 3.7/3.8 | Học & Hoàn thành Lesson | TC-COURSE-012 → 016, 021, 022 | Not Started |
| 3.9 | Audio phát âm | TC-COURSE-019 | Not Started |
| — | Đồng bộ Vocabulary dùng chung | TC-COURSE-018 | Not Started |

## 4. Deck & Flashcard

| Feature # | Tính năng | Test Case ID | Trạng thái |
|---|---|---|---|
| 4.1–4.3 | CRUD Deck | TC-DECK-001 → 007 | Not Started |
| 4.4/4.5 | Quản lý từ trong Deck | TC-DECK-008 → 012 | Not Started |
| 4.6 | Public/Private | TC-DECK-013 → 016 | Not Started |
| 4.7 | Tìm kiếm Public Deck | TC-DECK-014 | Not Started |
| 4.8 | Clone Deck | TC-DECK-017 → 020 | Not Started |
| 4.9/4.10 | Flashcard modes | TC-DECK-021 → 025 | Not Started |
| 4.11 | Audio/Image flashcard | *(P2 — chưa có TC)* | N/A |

## 5. Spaced Repetition

| Feature # | Tính năng | Test Case ID | Trạng thái |
|---|---|---|---|
| 5.1 | Review Today | TC-SRS-001 → 003 | Not Started |
| 5.2/5.3 | Đánh giá & SM-2 | TC-SRS-004 → 010, 015, 016, 018 | Not Started |
| 5.4 | Mastery Level | TC-SRS-017 | Not Started |
| — | Progress dùng chung (user,vocabulary) | TC-SRS-011 | Not Started |
| — | ReviewLog/XP/DailyActivity | TC-SRS-012 → 014 | Not Started |

## 6. Quiz

| Feature # | Tính năng | Test Case ID | Trạng thái |
|---|---|---|---|
| 6.1/6.2 | Generate Quiz | TC-QUIZ-001 → 008 | Not Started |
| 6.3/6.4 | Làm bài (MC/Fill Blank) | TC-QUIZ-009 → 014 | Not Started |
| 6.5 | Loại câu hỏi nâng cao | *(P2 — chưa có TC)* | N/A |
| 6.6 | Chấm điểm | TC-QUIZ-015 → 017 | Not Started |
| 6.7/6.8 | Kết quả & Lịch sử | TC-QUIZ-018 → 023 | Not Started |

## 7. Progress & Gamification

| Feature # | Tính năng | Test Case ID | Trạng thái |
|---|---|---|---|
| 7.1 | Dashboard | TC-PROG-001 → 003, 017 | Not Started |
| 7.2 | Daily Goal | TC-PROG-004, 005 | Not Started |
| 7.3 | Streak | TC-PROG-006 → 009, 018 | Not Started |
| 7.4 | XP | TC-PROG-010 | Not Started |
| 7.5 | Achievement | TC-PROG-011, 012 | N/A *(P2)* |
| 7.6 | Leaderboard | TC-PROG-013 → 016 | N/A *(P2)* |
| 7.7 | Coin | *(P2 — chưa có TC)* | N/A |

## 8. Favorite / History / Notification / Search

| Feature # | Tính năng | Test Case ID | Trạng thái |
|---|---|---|---|
| 8.1/8.2 | Favorite & My Favorites | TC-FAV-001 → 009 | Not Started |
| 8.3 | History | TC-FAV-010 → 015 | Not Started |
| 8.4/8.5 | Notification & Mark Read | TC-NOTI-001 → 007, 013, 014 | Not Started |
| 8.6 | Study Reminder | TC-NOTI-008 → 012 | Not Started |
| 8.7 | Email/Push thật | *(P2 — chưa có TC)* | N/A |
| 8.8 | Global Search | TC-SEARCH-001 → 013 | Not Started |

## 9. Admin

| Feature # | Tính năng | Test Case ID | Trạng thái |
|---|---|---|---|
| 9.1 | Admin Dashboard | TC-ADMIN-028 → 031 | Not Started |
| 9.2–9.7 | CRUD nội dung | TC-ADMIN-001 → 017 (mẫu, nhân bản theo entity) | Not Started |
| 9.8 | Quản lý User | TC-ADMIN-018 → 027 | Not Started |
| 9.9 | CRUD Achievement | *(P2 — chưa có TC)* | N/A |
| 9.10 | Notification broadcast | TC-NOTI-004, 005 | Not Started |
| 9.11 | Biểu đồ nâng cao | *(P2 — chưa có TC)* | N/A |

## 10. Non-functional & Security

| Hạng mục | File tham chiếu | Trạng thái |
|---|---|---|
| Responsive / Theme / State | `30_NON_FUNCTIONAL_CHECKLIST.md` | Not Started |
| Security cơ bản | `31_SECURITY_CHECKLIST.md` | Not Started |
| Regression/Smoke | `32_REGRESSION_SMOKE_CHECKLIST.md` | Not Started |
| Database Verification (TC-DB-001 → 007 + query xác minh business rule) | `34_DATABASE_VERIFICATION_CHECKLIST.md` | Not Started |

## 11. Tổng kết độ phủ (cập nhật định kỳ)

| Chỉ số | Giá trị |
|---|---|
| Tổng số tính năng MVP (từ `02_FEATURE_LIST.md`) | 47 |
| Tính năng đã có Test Case | 47 (100% — mọi feature MVP đều map được tới ≥ 1 Test Case ID ở trên) |
| Tính năng đã Test Passed | *(cập nhật khi bắt đầu test)* |
| Tính năng Failed đang mở | *(cập nhật khi bắt đầu test)* |
| Tính năng Phase 2 (N/A ở MVP) | 13 |

**Cách cập nhật file này:** sau mỗi phiên test 1 module, vào đúng bảng tương ứng, đổi cột "Trạng thái" theo kết quả tổng thể của nhóm Test Case đó (nếu có case Failed, để `Failed` và ghi Bug ID kèm theo trong ngoặc, ví dụ `Failed (BUG-DECK-014)`).

**Quan hệ với các file khác:** file này chỉ ghi trạng thái **tổng hợp theo nhóm tính năng**. Kết quả thực thi **chi tiết theo từng TC-ID, theo từng lần chạy** (lần đầu, retest sau fix, regression) ghi vào `35_TEST_EXECUTION_LOG_TEMPLATE.md`. Sau mỗi chu kỳ test, tổng hợp số liệu thành báo cáo theo `36_TEST_SUMMARY_REPORT_TEMPLATE.md`.
