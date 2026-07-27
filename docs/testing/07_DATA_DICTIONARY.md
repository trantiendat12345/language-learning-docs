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
| status | enum | ✅ | `PENDING_VERIFICATION`/`ACTIVE`/`DISABLED`/`LOCKED` | |

### Role / Permission
| Entity | Field | Ghi chú |
|---|---|---|
| Role | `code` (Unique, vd `ADMIN`/`USER`), `name` | |
| Permission | `code` (Unique, vd `COURSE_CREATE`), `name` | Xem đầy đủ ở `06_ROLES_PERMISSIONS_MATRIX.md` |

### RefreshToken
| Field | Kiểu | Ghi chú |
|---|---|---|
| tokenHash | varchar | Token thật **không** lưu plaintext trong DB |
| expiresAt | datetime | |
| revoked | boolean | Set true khi logout hoặc phát hiện bất thường |

### VerificationToken
| Field | Kiểu | Ghi chú |
|---|---|---|
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
| CourseEnrollment | `userId`, `courseId`, `status`, `progressPercent` (0–100) | Unique `(userId, courseId)` |
| LessonProgress | `userId`, `lessonId`, `status` (`NOT_STARTED`/`IN_PROGRESS`/`COMPLETED`) | Unique `(userId, lessonId)` |
| UserDailyActivity | `userId`, `activityDate` (date, theo timezone user), `studyMinutes`, `wordsLearned`, `xpEarned`, `goalMet` | Unique `(userId, activityDate)` |
| UserStreak | `userId` (PK=FK), `currentStreak`, `longestStreak`, `lastActiveDate` | 1-1 với User |
| XpLog | `userId`, `amount` (có thể âm nếu về sau có trừ XP — MVP chỉ cộng), `reason`, `sourceId`, `earnedAt` | Append-only |
| Achievement | `code` (unique), `conditionType`, `conditionValue`, `xpReward`, `coinReward` | |
| UserAchievement | `userId`, `achievementId`, `unlockedAt` | Unique `(userId, achievementId)` |

## 6. Engagement

| Entity | Field đáng chú ý | Ràng buộc |
|---|---|---|
| Favorite | `userId`, `targetType` (`COURSE`/`DECK`/`VOCABULARY`), `targetId` | Unique `(userId, targetType, targetId)` |
| ActivityHistory | `userId`, `targetType`, `targetId`, `action` (`VIEWED`/`LEARNED`/`REVIEWED`), `occurredAt` | Append-only, có thể giới hạn số bản ghi hiển thị gần nhất (vd 50) |
| Notification | `userId` (nullable = broadcast toàn hệ thống), `type`, `title`, `message`, `linkUrl`, `isRead` | |
| StudyReminder | `userId`, `type` (`STUDY`/`FLASHCARD`/`REVIEW`), `reminderTime`, `daysOfWeek`, `channel` (`IN_APP`/`EMAIL`/`PUSH`), `isActive` | MVP chỉ hiện thực `IN_APP` |

## 7. Trường Audit (áp dụng cho Content/Master data — xem D9)

Các entity ở mục 1–2–3 (trừ log/transaction) đều có thêm các field kế thừa từ `AuditableEntity`:

| Field | Kiểu | Ghi chú |
|---|---|---|
| createdAt | datetime | Tự động set khi tạo |
| createdBy | bigint (FK User) | Lấy từ SecurityContext |
| updatedAt | datetime | Tự động cập nhật mỗi lần sửa |
| updatedBy | bigint (FK User) | |
| deleted | boolean | Cột DB `is_deleted`, default false — filter mặc định trong mọi query danh sách. Field Java tên `deleted` (không phải `isDeleted`) do quy ước Lombok với field boolean, nhưng getter sinh ra vẫn là `isDeleted()` |
| deletedAt | datetime, nullable | |
| deletedBy | bigint, nullable | |

**Không áp dụng** cho: `ReviewLog`, `XpLog`, `ActivityHistory`, `QuizAttemptAnswer`, `RefreshToken`, `VerificationToken` — các bảng này chỉ có `id` + timestamp đơn giản (xem D9 trong `docs/PROJECT_OVERVIEW.md`).
