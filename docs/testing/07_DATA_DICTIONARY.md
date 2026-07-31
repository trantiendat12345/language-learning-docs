# Data Dictionary

> Mô tả chi tiết từng field của các entity chính — dùng để tester biết chính xác kiểu dữ liệu, ràng buộc, và ý nghĩa khi thiết kế test case validation (boundary, required, unique...). Xem sơ đồ quan hệ tổng thể (ERD) tại `docs/PROJECT_OVERVIEW.md` mục 6 — file này chỉ bổ sung chi tiết field-level, không lặp lại diagram.

**Quy ước đọc bảng:** `Required` = bắt buộc khi tạo mới · `Unique` = không được trùng trong toàn bảng (hoặc trong phạm vi ghi chú) · `Nullable` = được phép để trống.

## 1. Identity & Auth

### User
| Field | Kiểu | Bắt buộc | Ràng buộc | Mô tả |
|---|---|---|---|---|
| id | bigint | — | PK, auto-increment | |
| username | varchar(50) | ✅ | Unique | Dùng để đăng nhập, không phân biệt hoa/thường khi kiểm tra unique |
| email | varchar(255) | ✅ | Unique, format email | Dùng để đăng nhập/khôi phục mật khẩu |
| passwordHash | varchar(255) | ✅ | — | **Không bao giờ** trả ra API response |
| displayName | varchar(100) | ❌ | — | Tên hiển thị, mặc định = username nếu để trống |
| avatarUrl | varchar(500) | ❌ | Nullable | |
| birthday | date | ❌ | Nullable | |
| gender | varchar(20) | ❌ | Nullable | |
| country | varchar(100) | ❌ | Nullable | |
| nativeLanguageId | bigint (FK Language) | ❌ | Nullable | ⏳ **Chưa có trong code** — thiết kế cho Giai đoạn 3 khi entity `Language` tồn tại, xem `docs/dev/SCHEMA_CHANGE_LOG.md` |
| learningLanguageId | bigint (FK Language) | ❌ | Nullable | ⏳ **Chưa có trong code** — tương tự, Ngôn ngữ đang học chính hiện tại (Giai đoạn 3) |
| currentLevel | varchar(20) | ❌ | Nullable | vd A1/B2 |
| xp | int | — | Default 0, ≥ 0 | Denormalized, phải khớp SUM(XpLog) — xem `04_BUSINESS_RULES_GLOBAL.md` mục 1 |
| currentStreak | int | — | Default 0, ≥ 0 | |
| longestStreak | int | — | Default 0, ≥ 0 | |
| coin | int | — | Default 0, ≥ 0 | |
| timezone | varchar(50) | ✅ | Default theo hệ thống nếu không chọn | vd `Asia/Ho_Chi_Minh` |
| lastActiveDate | date | ❌ | Nullable — null nếu chưa từng có hoạt động | Dùng tính `currentStreak`/`longestStreak` (Giai đoạn 7, xem `StreakService`) |
| dailyGoalType | enum | ✅ | `TIME`/`WORDS`, default `WORDS` | Giai đoạn 7 — đặc tả gốc thuộc Giai đoạn 2 (mục 1.4) nhưng phát hiện chưa được code khi làm Progress Dashboard, bổ sung ngay |
| dailyGoalValue | int | ✅ | Default 10, ≥ 1 | Đơn vị theo `dailyGoalType` (phút nếu TIME, số từ nếu WORDS) |
| status | enum | ✅ | `PENDING_VERIFICATION`/`ACTIVE`/`DISABLED`/`LOCKED` | |

### Role / Permission
| Entity | Field | Ghi chú |
|---|---|---|
| Role | `code` (Unique, vd `ADMIN`/`USER`), `name` | |
| Permission | `code` (Unique, vd `COURSE_CREATE`), `name` | Xem đầy đủ ở `06_ROLES_PERMISSIONS_MATRIX.md` |

### RefreshToken
| Field | Kiểu | Ghi chú |
|---|---|---|
| userId | bigint FK | Bắt buộc — 1 User có thể có nhiều RefreshToken (nhiều thiết bị) |
| tokenHash | varchar | Token thật **không** lưu plaintext trong DB |
| expiresAt | datetime | |
| revoked | boolean | Set true khi logout hoặc phát hiện bất thường |

### VerificationToken
| Field | Kiểu | Ghi chú |
|---|---|---|
| userId | bigint FK | Bắt buộc |
| type | enum | `EMAIL_VERIFY` / `PASSWORD_RESET` |
| expiresAt | datetime | Test boundary: dùng token sau khi hết hạn phải bị từ chối |
| usedAt | datetime, nullable | Token dùng 1 lần — sau khi có `usedAt`, dùng lại phải bị từ chối |

## 2. Content: Language / Course / Lesson / Vocabulary / Grammar

### Language
| Field | Kiểu | Bắt buộc | Ràng buộc |
|---|---|---|---|
| code | varchar(10) | ✅ | Unique, vd `en`, `ja` |
| name | varchar(100) | ✅ | |
| flagIconUrl | varchar(500) | ❌ | |
| status | enum | ✅ | `ACTIVE`/`INACTIVE` |

### Course
| Field | Kiểu | Bắt buộc | Ràng buộc |
|---|---|---|---|
| languageId | bigint FK | ✅ | |
| title | varchar(200) | ✅ | |
| slug | varchar(200) | ✅ | Unique, dùng cho URL |
| description | text | ❌ | |
| thumbnailUrl | varchar(500) | ❌ | |
| difficulty | varchar(20) | ✅ | vd `A1`..`C2` hoặc `BEGINNER`..`ADVANCED` |
| estimatedMinutes | int | ❌ | ≥ 0 |
| displayOrder | int | ❌ | Dùng để sắp xếp trong danh sách |
| status | enum | ✅ | `DRAFT`/`PUBLISHED`/`ARCHIVED` — chỉ `PUBLISHED` hiển thị cho USER |

### Lesson
| Field | Kiểu | Bắt buộc | Ràng buộc |
|---|---|---|---|
| courseId | bigint FK | ✅ | |
| title | varchar(200) | ✅ | |
| displayOrder | int | ✅ | Xác định thứ tự học trong Course |
| videoUrl / audioUrl | varchar(500) | ❌ | Nullable |
| estimatedMinutes | int | ❌ | |
| status | enum | ✅ | `DRAFT`/`PUBLISHED`/`ARCHIVED` |

### Vocabulary
| Field | Kiểu | Bắt buộc | Ràng buộc |
|---|---|---|---|
| languageId | bigint FK | ✅ | |
| ownerId | bigint FK User | ❌ | Null = từ hệ thống (Admin); có giá trị = từ custom của User |
| word | varchar(200) | ✅ | |
| meaning | varchar(500) | ✅ | Tiếng Việt (MVP — xem quy tắc mục 8, `04_BUSINESS_RULES_GLOBAL.md`) |
| ipa | varchar(100) | ❌ | |
| pronunciationAudioUrl | varchar(500) | ❌ | |
| wordType | varchar(30) | ❌ | vd noun/verb/adjective |
| imageUrl | varchar(500) | ❌ | |
| difficulty | varchar(20) | ❌ | |
| exampleSentence / exampleTranslation | text | ❌ | |
| frequencyRank | int | ❌ | Độ phổ biến của từ, dùng cho gợi ý học |
| status | enum | ✅ | `ACTIVE`/`ARCHIVED` |

### LessonVocabulary (join)
| Field | Ghi chú |
|---|---|
| lessonId, vocabularyId | Composite unique — 1 từ chỉ xuất hiện 1 lần trong 1 Lesson |
| displayOrder | Thứ tự hiển thị trong Lesson |

### Grammar / GrammarExample
| Entity | Field chính | Ghi chú |
|---|---|---|
| Grammar | `lessonId`, `title`, `pattern`, `explanation`, `difficulty`, `displayOrder` | |
| GrammarExample | `grammarId`, `exampleText`, `translation`, `note` | 1 Grammar có nhiều example |

### Tag / VocabularyTag / VocabularyRelation
⏳ **Chưa có trong code** — hoãn sang Phase 2 (`docs/testing/02_FEATURE_LIST.md` mục 3.10 ghi rõ P2), quyết định chốt khi code Giai đoạn 3, xem `docs/PROJECT_OVERVIEW.md` mục 11/12/13. Bảng dưới đây là thiết kế dự kiến, chưa có entity/migration nào tương ứng.

| Entity | Ghi chú |
|---|---|
| Tag | `name` unique |
| VocabularyTag (join) | `vocabularyId`, `tagId` — composite unique, 1 từ không gắn trùng 1 tag 2 lần |
| VocabularyRelation | `vocabularyId`, `relatedVocabularyId`, `relationType` (`SYNONYM`/`ANTONYM`) — không cho phép `vocabularyId == relatedVocabularyId` |

## 3. Deck / Flashcard / SRS

### Deck
| Field | Kiểu | Bắt buộc | Ràng buộc |
|---|---|---|---|
| ownerId | bigint FK User | ✅ | |
| languageId | bigint FK | ✅ | |
| title | varchar(200) | ✅ | |
| description | text | ❌ | |
| coverImageUrl | varchar(500) | ❌ | |
| visibility | enum | ✅ | `PRIVATE`/`PUBLIC`, default `PRIVATE` |
| clonedFromDeckId | bigint FK Deck | ❌ | Nullable — null nếu deck tự tạo, có giá trị nếu clone |
| status | enum | ✅ | `ACTIVE`/`ARCHIVED` |

### DeckCard
| Field | Ghi chú |
|---|---|
| deckId, vocabularyId | Composite unique — 1 từ không lặp lại trong cùng 1 Deck |
| displayOrder | |

### UserVocabularyProgress
| Field | Kiểu | Ràng buộc |
|---|---|---|
| userId, vocabularyId | — | **Unique composite** — nền tảng của Quy tắc D2 |
| easeFactor | float | Thường khởi tạo 2.5, sàn tối thiểu ~1.3 |
| intervalDays | int | ≥ 0 |
| repetitionCount | int | ≥ 0 |
| nextReviewDate | date | |
| lastReviewDate | date | Nullable nếu chưa ôn lần nào |
| forgotCount | int | ≥ 0, chỉ tăng |
| masteryLevel | enum | `NEW`/`LEARNING`/`FAMILIAR`/`MASTERED` |

### ReviewLog
| Field | Ghi chú |
|---|---|
| userId, vocabularyId, rating, reviewedAt | Append-only, không sửa/xoá qua API thông thường |

## 4. Quiz

### Question
| Field | Kiểu | Bắt buộc | Ràng buộc |
|---|---|---|---|
| sourceType | enum | ✅ | `LESSON`/`COURSE`/`DECK`/`VOCAB_LIST` |
| sourceId | bigint | ✅ | Trỏ tới id tương ứng với sourceType |
| languageId | bigint FK | ✅ | |
| type | enum | ✅ | `MULTIPLE_CHOICE`/`FILL_BLANK`/`TYPING`/`LISTENING`/`MATCHING`/`REORDER`/`IMAGE_CHOICE`/`AUDIO_CHOICE` |
| vocabularyId | bigint FK | ❌ | Nullable — có khi câu hỏi gắn trực tiếp với 1 từ |
| promptText | text | ✅ (trừ loại thuần audio/image) | |
| promptAudioUrl | varchar(500) | ❌ | Nullable — dùng cho `LISTENING`/`AUDIO_CHOICE` |
| promptImageUrl | varchar(500) | ❌ | Nullable — dùng cho `IMAGE_CHOICE` |
| explanation | text | ❌ | Hiển thị sau khi trả lời |
| difficulty | varchar(20) | ❌ | |

### QuestionOption
| Field | Ghi chú |
|---|---|
| questionId, optionText/optionImageUrl, isCorrect, displayOrder | Với `MULTIPLE_CHOICE` phải có đúng 1 option `isCorrect = true` (trừ dạng multi-select nếu về sau hỗ trợ) |

### QuizAttempt
| Field | Kiểu | Ràng buộc |
|---|---|---|
| userId | bigint FK | ✅ |
| sourceType, sourceId | — | Giống nguồn của Question dùng để generate |
| totalQuestions, correctAnswers, wrongAnswers | int | `correctAnswers + wrongAnswers = totalQuestions` |
| score, accuracy | float | 0–100 |
| durationSeconds | int | ≥ 0 |
| xpEarned | int | ≥ 0 |
| completedAt | datetime | |

### QuizAttemptAnswer
| Field | Ghi chú |
|---|---|
| quizAttemptId, questionId | |
| selectedOptionId | Nullable — dùng cho câu trắc nghiệm |
| typedAnswer | Nullable — dùng cho Fill Blank/Typing |
| isCorrect | boolean |

## 5. Progress & Gamification

| Entity | Field đáng chú ý | Ràng buộc |
|---|---|---|
| CourseEnrollment | `userId`, `courseId`, `status`, `progressPercent` (0–100), `enrolledAt`, `updatedAt` | Unique `(userId, courseId)` |
| LessonProgress | `userId`, `lessonId`, `status` (`NOT_STARTED`/`IN_PROGRESS`/`COMPLETED`), `completedAt` (nullable) | Unique `(userId, lessonId)` |
| UserDailyActivity | `userId`, `activityDate` (date, theo timezone user), `studyMinutes`, `wordsLearned`, `xpEarned` (chỉ cộng dồn phần XP thưởng `DAILY_GOAL_MET`, không phải tổng mọi XP kiếm được trong ngày), `goalMet` | Unique `(userId, activityDate)` |
| XpLog | `userId`, `amount` (có thể âm nếu về sau có trừ XP — MVP chỉ cộng), `reason` (`VOCAB_LEARNED`/`LESSON_COMPLETED`/`QUIZ_COMPLETED`/`REVIEW_DONE`/`DAILY_GOAL_MET`/`ACHIEVEMENT`), `sourceId`, `earnedAt` | Append-only |
| Achievement | `code` (unique), `conditionType`, `conditionValue`, `xpReward`, `coinReward` | ⏳ **Chưa có trong code** — Phase 2, xem `docs/PROJECT_OVERVIEW.md` mục 11 |
| UserAchievement | `userId`, `achievementId`, `unlockedAt` | Unique `(userId, achievementId)` — ⏳ **Chưa có trong code** — Phase 2 |

**Không có bảng `UserStreak` riêng** — `currentStreak`/`longestStreak`/`lastActiveDate` giữ nguyên denormalized trên `User` (mục 1) thay vì tách bảng 1-1, tránh 2 nguồn sự thật cho cùng giá trị (quyết định chốt khi code Giai đoạn 7, xem Javadoc `User.java` + `docs/dev/SCHEMA_CHANGE_LOG.md`).

## 6. Engagement

| Entity | Field đáng chú ý | Ràng buộc |
|---|---|---|
| Favorite | `userId`, `targetType` (`COURSE`/`DECK`/`VOCABULARY`), `targetId`, `favoritedAt` | Unique `(userId, targetType, targetId)` — ✅ **đã có trong code** (Giai đoạn 8) |
| ActivityHistory | `userId`, `targetType`, `targetId`, `action` (`VIEWED`/`LEARNED`/`REVIEWED`), `occurredAt` | Append-only, có thể giới hạn số bản ghi hiển thị gần nhất (vd 50) — ⏳ **Chưa có trong code** |
| Notification | `userId` (nullable = broadcast toàn hệ thống), `type`, `title`, `message`, `linkUrl`, `isRead` | ⏳ **Chưa có trong code** |
| StudyReminder | `userId`, `type` (`STUDY`/`FLASHCARD`/`REVIEW`), `reminderTime`, `daysOfWeek`, `channel` (`IN_APP`/`EMAIL`/`PUSH`), `isActive` | MVP chỉ hiện thực `IN_APP` — ⏳ **Chưa có trong code** |

## 7. Trường Audit (áp dụng cho Content/Master data — xem D9)

Áp dụng cho các entity thuộc nhóm **Content/Master data** (không phải theo số thứ tự mục — 1 mục có thể trộn cả 2 loại): `User`, `Role`, `Permission`, `Language`, `Course`, `Lesson`, `Vocabulary`, `Grammar`, `GrammarExample`, `Deck`, `Question`, `QuestionOption` — các entity này kế thừa `AuditableEntity`, có thêm các field:

| Field | Kiểu | Ghi chú |
|---|---|---|
| createdAt | datetime | Tự động set khi tạo |
| createdBy | bigint (FK User) | Lấy từ SecurityContext |
| updatedAt | datetime | Tự động cập nhật mỗi lần sửa |
| updatedBy | bigint (FK User) | |
| deleted | boolean | Cột DB `is_deleted`, default false — filter mặc định trong mọi query danh sách. Field Java tên `deleted` (không phải `isDeleted`) do quy ước Lombok với field boolean, nhưng getter sinh ra vẫn là `isDeleted()` |
| deletedAt | datetime, nullable | |
| deletedBy | bigint, nullable | |

**Không áp dụng** — các entity dưới đây kế thừa `BaseEntity` (chỉ có `id`), KHÔNG có 7 field audit ở trên, chia làm 2 nhóm theo lý do:

- **Log/Transaction data thật** (append-only, D9 liệt kê rõ tên): `ReviewLog`, `XpLog`, `QuizAttempt`, `QuizAttemptAnswer`, `RefreshToken`, `VerificationToken`. `ActivityHistory` (Giai đoạn 8, chưa có trong code) khi triển khai cũng sẽ thuộc nhóm này.
- **State/join thuần** (không phải log, nhưng cũng không cần soft-delete/audit vì user chỉ tự thao tác trên bản ghi của chính mình hoặc gỡ = xoá cứng): `LessonVocabulary`, `DeckCard`, `UserVocabularyProgress`, `CourseEnrollment`, `LessonProgress`, `UserDailyActivity`, `Favorite` — xem Javadoc từng entity hoặc `docs/dev/SCHEMA_CHANGE_LOG.md` để biết lý do cụ thể từng trường hợp.
