# Module: Progress & Gamification — Functional Requirements & Test Cases

> **Phần 1 = Đặc tả chức năng (Functional Spec)** — dev đọc phần này để biết cần implement gì, không cần đọc Test Case. **Phần 2 + 3 = Test Scenarios/Test Case** — tester dùng để kiểm thử. File gộp chung 2 mục đích để tránh 2 tài liệu lệch nhau khi sửa rule (xem `CLAUDE.md`).

## Phần 1 — Functional Requirements

### 1.1 Dashboard tổng quan

**API:** `GET /api/progress/dashboard` (protected)
**Main flow:** Tổng hợp: lời chào, tiến độ Daily Goal hôm nay, thời gian học, số từ đã học/cần ôn, độ chính xác Quiz, Streak, gợi ý Continue Learning, hoạt động gần đây, Course gợi ý.
**Business Rule:** Toàn bộ số liệu phải khớp với dữ liệu chi tiết ở các module tương ứng (không tính riêng 1 công thức khác cho Dashboard) — vd "Words To Review" trên Dashboard phải bằng đúng số lượng trả về từ `GET /api/review/today`.

### 1.2 Daily Goal & Streak

Xem đầy đủ quy tắc tại `04_BUSINESS_RULES_GLOBAL.md` mục 2. Tóm tắt: `UserDailyActivity` (theo timezone user) là nguồn dữ liệu duy nhất cho Streak/Daily Goal — không có công thức tính riêng nào khác.

### 1.3 XP

Xem đầy đủ quy tắc tại `04_BUSINESS_RULES_GLOBAL.md` mục 1. `User.xp` (all-time) phải luôn bằng `SUM(XpLog.amount)`.

### 1.4 Achievement (Phase 2)

**Main flow:** Hệ thống tự động kiểm tra điều kiện (`conditionType`/`conditionValue`) sau mỗi sự kiện liên quan (hoàn thành Lesson, học đủ N từ, đạt Streak N ngày...) → nếu đạt và chưa có `UserAchievement` tương ứng → tạo mới, cộng `xpReward`/`coinReward`.
**Business Rule:** Achievement chỉ unlock **1 lần duy nhất** cho mỗi user (unique `userId+achievementId`) — đạt lại điều kiện sau đó không unlock thêm lần 2.

### 1.5 Leaderboard (Phase 2)

**API:** `GET /api/leaderboard?period=WEEKLY|MONTHLY|ALL_TIME` (protected)
**Business Rule (xem D8):** Weekly/Monthly tính bằng `SUM(XpLog.amount) WHERE earned_at trong khoảng period`. All-time dùng thẳng `User.xp`. Ranking sắp xếp giảm dần theo tổng XP trong kỳ.

## Phần 2 — Test Scenarios

1. Dashboard hiển thị đúng, đồng bộ với dữ liệu chi tiết từng module.
2. Daily Goal đạt/chưa đạt hiển thị đúng theo tiến độ thực tế trong ngày.
3. Streak tăng đúng khi có hoạt động liên tục, reset đúng khi bỏ lỡ ngày.
4. XP cộng đúng, tổng khớp giữa `User.xp` và `SUM(XpLog)`.
5. Achievement tự động unlock đúng điều kiện, không unlock trùng lần 2.
6. Leaderboard Weekly/Monthly chỉ tính XP trong đúng khoảng thời gian.
7. Leaderboard All-time đúng thứ tự theo `User.xp`.
8. Dashboard/Progress không lộ dữ liệu chi tiết của user khác.

## Phần 3 — Test Cases chi tiết

> **Trạng thái implement (2026-07-30):** `GET /api/progress/dashboard` (mục 1.1, trừ "lời chào" — trivial FE concern — và "hoạt động gần đây"/"Course gợi ý" — module History chưa xây ở Giai đoạn 8, chưa có thuật toán gợi ý), Daily Goal & Streak (mục 1.2), XP (mục 1.3, bất biến `User.xp == SUM(XpLog.amount)` đã verify qua curl+DB) **đã test được**. TC-PROG-001 → 004, 006 → 009 (Dashboard, Words To Review khớp Review Today, Empty State user mới, Daily Goal đạt/reset, XP) **đã test được**. TC-PROG-005 (không cộng XP `DAILY_GOAL_MET` lần 2 trong ngày) đã đúng theo code (check `goalMet` chuyển false→true mới cộng) nhưng chưa test riêng qua curl (đã gián tiếp verify: gọi `recordActivity` nhiều lần trong 1 ngày chỉ gọi `StreakService` 1 lần ở Unit Test `DailyActivityServiceImplTest`). Achievement (mục 1.4) và Leaderboard (mục 1.5) **chưa có trong code** — Phase 2, xem `docs/PROJECT_OVERVIEW.md` mục 11 (quyết định hoãn khi rà lại mục 11 trước khi bắt đầu chunk Giai đoạn 7, cùng cách xử lý với `Tag`/`VocabularyTag`/`VocabularyRelation` ở Giai đoạn 3). `Continue Learning` trong Dashboard chỉ xét khoá học `IN_PROGRESS` cập nhật gần nhất — chưa có nhiều khoá học song song để test tie-break thứ tự.

| ID | Tiêu đề | Precondition | Steps | Test Data | Expected Result | Priority |
|---|---|---|---|---|---|---|
| TC-PROG-001 | Dashboard hiển thị đúng sau login | user01 có dữ liệu mẫu (xem `09_TEST_DATA.md` mục 9) | `GET /api/progress/dashboard` | | Trả đủ: Daily Goal progress, Streak, Words To Review, Quiz Accuracy gần nhất, Continue Learning | Critical |
| TC-PROG-002 | Words To Review trên Dashboard khớp Review Today | | So sánh `GET /api/progress/dashboard` và `GET /api/review/today` | | Số lượng và danh sách khớp nhau tuyệt đối | Critical |
| TC-PROG-003 | Dashboard rỗng cho user mới | Tài khoản vừa đăng ký, chưa học gì | Xem Dashboard | | Hiển thị Empty State hợp lý (gợi ý bắt đầu học), không lỗi khi số liệu = 0 | High |
| TC-PROG-004 | Đặt Daily Goal & đạt mục tiêu trong ngày | Đặt Daily Goal = 10 từ/ngày | Học đủ 10 từ mới trong ngày | | `UserDailyActivity.goalMet = true`, cộng XP reason=DAILY_GOAL_MET đúng 1 lần | Critical |
| TC-PROG-005 | Vượt Daily Goal không cộng thêm XP lần 2 | Sau TC-PROG-004, học thêm từ thứ 11 cùng ngày | Kiểm tra XpLog | | Không có thêm dòng `DAILY_GOAL_MET` thứ 2 trong cùng ngày | High |
| TC-PROG-006 | Streak tăng khi học liên tục 2 ngày | Có hoạt động "hôm qua", học tiếp "hôm nay" | Xem UserStreak sau khi học hôm nay | | `currentStreak += 1` so với trước | Critical |
| TC-PROG-007 | Streak reset khi bỏ lỡ 1 ngày | Có hoạt động cách đây 3 ngày, không có hoạt động 2 ngày gần nhất, học lại hôm nay | Xem UserStreak | | `currentStreak = 1` (reset, không cộng dồn từ streak cũ) | Critical |
| TC-PROG-008 | Longest Streak không giảm | `currentStreak` giảm sau khi reset (TC-PROG-007) | Xem `longestStreak` | | `longestStreak` giữ nguyên giá trị cao nhất trước đó, không bị ghi đè bởi currentStreak thấp hơn | High |
| TC-PROG-009 | Longest Streak cập nhật khi vượt kỷ lục | `currentStreak` mới > `longestStreak` cũ | Học liên tục cho tới khi vượt kỷ lục | | `longestStreak` cập nhật bằng `currentStreak` mới | High |
| TC-PROG-010 | Tổng XP khớp XpLog | user01 đã có nhiều hoạt động | So sánh `User.xp` với `SUM(XpLog.amount) WHERE userId=user01` | | Hai giá trị bằng nhau tuyệt đối | Critical |
| TC-PROG-011 | Achievement tự động unlock | Achievement `FIRST_LESSON` (điều kiện: hoàn thành 1 Lesson) | Hoàn thành Lesson đầu tiên | | `UserAchievement` được tạo, cộng `xpReward` tương ứng, có Notification thông báo (nếu đã tích hợp) | High |
| TC-PROG-012 | Achievement không unlock lại lần 2 | Đã có `UserAchievement(FIRST_LESSON)` | Hoàn thành thêm 1 Lesson khác | | Không tạo thêm `UserAchievement` trùng, không cộng thêm `xpReward` lần 2 | Critical |
| TC-PROG-013 | Leaderboard Weekly chỉ tính XP trong tuần hiện tại | user01 có XpLog cả tuần trước và tuần này (xem `09_TEST_DATA.md` mục 9) | `GET /api/leaderboard?period=WEEKLY` | | Điểm hiển thị chỉ tổng XP phát sinh trong tuần hiện tại, không cộng dồn tuần trước | Critical |
| TC-PROG-014 | Leaderboard Monthly | Tương tự dữ liệu trên | `GET /api/leaderboard?period=MONTHLY` | | Chỉ tính trong tháng hiện tại | High |
| TC-PROG-015 | Leaderboard All-time đúng thứ tự | Nhiều user có `User.xp` khác nhau | `GET /api/leaderboard?period=ALL_TIME` | | Sắp xếp giảm dần theo `User.xp`, thứ tự chính xác | High |
| TC-PROG-016 | Leaderboard không lộ thông tin nhạy cảm | | Xem response | | Chỉ có rank/avatar/username/xp — không có email/password | Critical |
| TC-PROG-017 | Course Progress hiển thị trên Dashboard đúng | user01 đang học dở "English Beginner A1" | Xem Dashboard | | "Continue Learning" trỏ đúng course/lesson đang học dở | High |
| TC-PROG-018 | Timezone khác nhau — Daily Goal tính đúng độc lập theo từng user | `user06_utc` (timezone UTC) và `user01` (Asia/Ho_Chi_Minh) cùng học vào cùng thời điểm UTC | So sánh `activityDate` ghi nhận của 2 user | | Có thể khác ngày nhau tuỳ timezone riêng của từng user — không dùng chung 1 mốc ngày server | Critical |
