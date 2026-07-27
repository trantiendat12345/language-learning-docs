# Test Environment Setup

> Hướng dẫn dựng môi trường để tester tự chạy hệ thống trên máy local và thực thi test case. Cập nhật tài liệu này ngay khi cấu hình thực tế thay đổi (vd thêm Docker Compose ở Giai đoạn 10).

## 1. Thành phần hệ thống cần chạy

| Thành phần | Công nghệ | Port mặc định |
|---|---|---|
| Backend API | Java 21 + Spring Boot 3 | `8080` |
| Frontend | React + Vite | `5173` |
| Database | MySQL | `3306` |

## 2. Yêu cầu cài đặt trước (Prerequisites)

- Java 21 (JDK)
- Maven (hoặc dùng `./mvnw` có sẵn trong repo)
- Node.js LTS (khuyến nghị bản mới nhất tương thích Vite 8) + npm
- MySQL Server 8.x đang chạy local
- Postman hoặc công cụ tương đương để test API thủ công
- Trình duyệt: Chrome/Edge/Firefox bản mới nhất (bắt buộc), Safari mới nhất (nếu có máy Mac)

## 3. Cấu hình biến môi trường Backend

> **Không** dùng giá trị hardcode trong `application.properties` để test — theo quyết định bảo mật ở `docs/PROJECT_OVERVIEW.md` mục 3, các giá trị nhạy cảm phải đọc từ biến môi trường.

Các biến môi trường cần thiết lập trước khi chạy Backend:

| Biến | Ví dụ giá trị (local) | Mô tả |
|---|---|---|
| `DB_URL` | `jdbc:mysql://localhost:3306/language_learning` | |
| `DB_USERNAME` | `root` | |
| `DB_PASSWORD` | *(giá trị thật, không commit)* | |
| `JWT_SECRET` | *(chuỗi bí mật đủ dài, không dùng giá trị mẫu cũ đã lộ trong git)* | |
| `JWT_EXPIRATION` | `86400000` (ms, 24h) | Access token |
| `JWT_REFRESH_EXPIRATION` | vd `604800000` (7 ngày) | Refresh token |

Cách thiết lập (chọn 1 trong 2, tuỳ cấu hình dev thực tế của backend):
```bash
export DB_URL="jdbc:mysql://localhost:3306/language_learning"
export DB_USERNAME="root"
export DB_PASSWORD="your_local_password"
export JWT_SECRET="your_local_secret"
```
Hoặc dùng file `application-local.properties` (đã thêm vào `.gitignore`, **không** commit).

## 4. Khởi tạo Database

```bash
# Tạo database (nếu chưa có)
mysql -u root -p -e "CREATE DATABASE language_learning CHARACTER SET utf8mb4;"
```

Backend dùng `spring.jpa.hibernate.ddl-auto=update` — schema tự tạo/cập nhật khi backend khởi động lần đầu. Không cần chạy migration script thủ công ở giai đoạn MVP (chưa dùng Flyway).

**Lưu ý cho tester:** vì không dùng Flyway, khi có thay đổi lớn về entity giữa các lần build, nên **xoá và tạo lại database** thay vì tin tưởng `ddl-auto=update` xử lý đúng mọi thay đổi (đổi kiểu cột, đổi tên...).

```bash
mysql -u root -p -e "DROP DATABASE IF EXISTS language_learning; CREATE DATABASE language_learning CHARACTER SET utf8mb4;"
```

Sau khi tạo lại DB, seed dữ liệu test theo `09_TEST_DATA.md`.

## 5. Chạy Backend

```bash
cd language-learning-backend
./mvnw spring-boot:run
```
Kiểm tra backend đã chạy: mở `http://localhost:8080/actuator/health` (nếu có bật Actuator) hoặc gọi thử 1 API public, vd `GET http://localhost:8080/api/languages`.

**Swagger UI** (đã có sẵn từ Giai đoạn 1): `http://localhost:8080/swagger-ui/index.html` (mở công khai, không cần token) — dùng để test API thủ công không cần Postman. Danh sách API sẽ trống cho tới khi có Controller đầu tiên (Giai đoạn 2). JSON đặc tả: `http://localhost:8080/v3/api-docs`.

## 6. Chạy Frontend

```bash
cd language-learning-client
npm install
npm run dev
```
Mặc định chạy tại `http://localhost:5173`. Frontend gọi API qua `axiosClient` trỏ tới `http://localhost:8080` — kiểm tra file cấu hình biến môi trường FE (vd `.env` với `VITE_API_BASE_URL`) khớp với port Backend đang chạy.

## 7. Tài khoản test mặc định

Xem danh sách đầy đủ tài khoản/dữ liệu mẫu tại `09_TEST_DATA.md`. Tối thiểu cần có:
- 1 tài khoản `ADMIN` để test toàn bộ chức năng quản trị.
- Ít nhất 2 tài khoản `USER` (để test các case "User A không được sửa dữ liệu User B" — xem `06_ROLES_PERMISSIONS_MATRIX.md`).

## 8. Công cụ test API thủ công

| Công cụ | Dùng khi nào |
|---|---|
| Swagger UI | Test nhanh 1 API đơn lẻ, xem rõ schema request/response |
| Postman | Test luồng nhiều bước cần lưu biến (vd lưu Access Token sau Login để dùng cho request tiếp theo), test case phức tạp cần lưu lại (collection) để chạy lại nhiều lần |

Gợi ý thiết lập Postman:
1. Tạo **Environment** với biến `baseUrl = http://localhost:8080`, `accessToken`.
2. Ở request Login, dùng tab **Tests** để tự động lưu access token vào biến environment, ví dụ:
   ```javascript
   const res = pm.response.json();
   pm.environment.set("accessToken", res.data.accessToken);
   ```
   `refreshToken` **không** nằm trong JSON response (`data`) — backend set qua header `Set-Cookie` httpOnly (xem `docs/PROJECT_OVERVIEW.md` mục 8/9), Postman tự lưu vào Cookie Jar của workspace (bật **Automatically follow redirects** + **Send cookies** trong Settings), không cần lưu thủ công vào biến environment.
3. Ở các request `protected`, thêm header `Authorization: Bearer {{accessToken}}`.

## 9. Reset môi trường trước một phiên test quan trọng

1. Dừng Backend/Frontend.
2. Xoá và tạo lại database (mục 4).
3. Chạy lại Backend để tạo schema.
4. Seed dữ liệu test (`09_TEST_DATA.md`).
5. Chạy Frontend.
6. Xoá cache trình duyệt / dùng cửa sổ ẩn danh nếu nghi ngờ token/localStorage cũ gây nhiễu kết quả.

## 10. Kiểm tra timezone khi test (liên quan Streak/Daily Goal)

Vì quy tắc Streak phụ thuộc `timezone` của từng User (xem `04_BUSINESS_RULES_GLOBAL.md` mục 2), khi test các case liên quan ngày/giờ:
- Xác nhận rõ `timezone` của tài khoản test đang dùng (mục 9 trong `09_TEST_DATA.md`).
- Nếu cần giả lập "qua ngày mới", có thể cần chỉnh giờ hệ thống máy test hoặc chờ dev cung cấp cơ chế test riêng (vd endpoint debug set ngày — chỉ dùng ở môi trường test, không bao giờ có ở production).

## 11. Tài khoản MySQL riêng cho tester (dùng cho `34_DATABASE_VERIFICATION_CHECKLIST.md`)

Tester cần truy cập DB trực tiếp để xác minh dữ liệu (không chỉ tin vào response API). Vì đây là DB local dùng riêng cho test (không phải môi trường chia sẻ/production), tạo 2 tài khoản MySQL tách biệt với tài khoản `root` mà Backend dùng:

```sql
-- Tài khoản chỉ đọc — dùng cho phần lớn việc xác minh dữ liệu (mục 2, 4, 5 trong file 34)
CREATE USER 'tester_ro'@'localhost' IDENTIFIED BY 'ChangeMe_RO123';
GRANT SELECT ON language_learning.* TO 'tester_ro'@'localhost';

-- Tài khoản có quyền ghi trong transaction — chỉ dùng cho test ràng buộc (mục 3 trong file 34), luôn ROLLBACK sau khi test
CREATE USER 'tester_rw'@'localhost' IDENTIFIED BY 'ChangeMe_RW123';
GRANT SELECT, INSERT, UPDATE, DELETE ON language_learning.* TO 'tester_rw'@'localhost';

FLUSH PRIVILEGES;
```

**Nguyên tắc dùng:**

- Việc xác minh dữ liệu hằng ngày (99% trường hợp) dùng `tester_ro` — không có rủi ro làm sai lệch dữ liệu test.
- `tester_rw` chỉ dùng khi cố tình test ràng buộc DB (thử insert vi phạm UNIQUE/FK/NOT NULL) — luôn bọc trong `START TRANSACTION; ... ROLLBACK;` để không để lại dữ liệu rác, trừ khi mục đích là test xong rồi reset toàn bộ DB theo mục 9 ở trên.
- Không dùng tài khoản `root`/tài khoản Backend đang dùng để tránh nhầm lẫn giữa "dữ liệu do app tạo" và "dữ liệu do tester thao tác tay".
