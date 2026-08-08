# Hướng dẫn sử dụng — Language Learning Platform

> Tài liệu này hướng dẫn **người dùng cuối** cách sử dụng website học ngoại ngữ, không phải tài liệu kỹ thuật. Nếu bạn là lập trình viên đang tìm hiểu kiến trúc hệ thống, xem `docs/PROJECT_OVERVIEW.md`.

## Mục lục

1. [Giới thiệu](#1-giới-thiệu)
2. [Đăng ký và đăng nhập](#2-đăng-ký-và-đăng-nhập)
3. [Trang chủ](#3-trang-chủ)
4. [Dashboard — Trang tổng quan học tập](#4-dashboard--trang-tổng-quan-học-tập)
5. [Khoá học](#5-khoá-học)
6. [Bài học](#6-bài-học)
7. [Học từ vựng theo bài học](#7-học-từ-vựng-theo-bài-học)
8. [Deck & Flashcard — Bộ thẻ từ vựng tự tạo](#8-deck--flashcard--bộ-thẻ-từ-vựng-tự-tạo)
9. [Quiz — Làm bài kiểm tra](#9-quiz--làm-bài-kiểm-tra)
10. [Ôn tập (Review) — Ôn từ theo trí nhớ](#10-ôn-tập-review--ôn-từ-theo-trí-nhớ)
11. [Hồ sơ cá nhân](#11-hồ-sơ-cá-nhân)
12. [Chế độ sáng / tối](#12-chế-độ-sáng--tối)
13. [Dành cho Quản trị viên (Admin)](#13-dành-cho-quản-trị-viên-admin)
14. [Câu hỏi thường gặp](#14-câu-hỏi-thường-gặp)

---

## 1. Giới thiệu

Đây là nền tảng học ngoại ngữ trực tuyến (hiện tại tập trung **tiếng Anh**, kiến trúc sẵn sàng mở rộng thêm ngôn ngữ khác trong tương lai). Website cung cấp **hai cách học song song**, bạn có thể dùng riêng lẻ hoặc kết hợp:

- **Học theo lộ trình khoá học**: đi theo `Khoá học → Bài học`, mỗi bài học có sẵn từ vựng, ngữ pháp, video/audio và bài Quiz do đội ngũ biên soạn.
- **Học theo Deck tự tạo**: tự tạo bộ thẻ từ vựng của riêng bạn, học bằng Flashcard theo nhiều chế độ, hoặc mượn (nhân bản) Deck công khai của người khác.

Dù học theo cách nào, hệ thống đều **tự động ghi nhớ mức độ thuộc từ của bạn** theo phương pháp lặp lại ngắt quãng (Spaced Repetition System - SRS) và nhắc bạn ôn lại đúng lúc trước khi quên, thông qua trang **Ôn tập**.

---

## 2. Đăng ký và đăng nhập

### Đăng ký tài khoản mới

1. Vào trang chủ, bấm **"Đăng ký"** ở góc trên bên phải (hoặc nút "Đăng ký miễn phí" ở giữa trang).
2. Điền **Username**, **Email**, **Mật khẩu** (tối thiểu 8 ký tự, có ít nhất 1 chữ và 1 số) và **Xác nhận mật khẩu**.
3. Bấm **Đăng ký**. Tài khoản được kích hoạt ngay — bạn không cần xác thực email để bắt đầu sử dụng.
4. Đăng nhập ngay bằng username/email và mật khẩu vừa tạo.

### Đăng nhập

1. Bấm **"Đăng nhập"** ở góc trên bên phải.
2. Nhập **username hoặc email** cùng **mật khẩu**.
3. Phiên đăng nhập được giữ tự động — bạn không cần đăng nhập lại mỗi khi tải lại trang, trừ khi chủ động bấm **Đăng xuất** hoặc phiên hết hạn.

### Quên mật khẩu

1. Ở trang Đăng nhập, bấm **"Quên mật khẩu?"**.
2. Nhập email đã đăng ký, hệ thống gửi liên kết đặt lại mật khẩu.
3. Mở liên kết, nhập mật khẩu mới. Sau khi đổi thành công, mọi phiên đăng nhập cũ (trên các thiết bị khác) đều bị đăng xuất để đảm bảo an toàn.

---

## 3. Trang chủ

Trang chủ (`/`) là trang giới thiệu công khai, ai cũng xem được kể cả chưa đăng nhập, gồm:

- **Phần giới thiệu** với nút kêu gọi hành động: "Đăng ký miễn phí" (nếu chưa đăng nhập) hoặc "Vào Dashboard" (nếu đã đăng nhập).
- **Các tính năng nổi bật**: Học từ vựng có hệ thống, Flashcard & Deck cá nhân hoá, Ôn tập thông minh (SRS), Quiz đa dạng, Theo dõi tiến độ, Sẵn sàng đa ngôn ngữ.
- **Khoá học nổi bật**: vài khoá học mới nhất đang mở, bấm vào để xem chi tiết ngay cả khi chưa đăng nhập.

---

## 4. Dashboard — Trang tổng quan học tập

Truy cập qua menu **"Dashboard"** (chỉ hiện khi đã đăng nhập). Đây là trang tổng quan mỗi lần bạn quay lại học:

- **4 thẻ số liệu nhanh**: Streak hiện tại (số ngày học liên tục), Tổng XP tích luỹ, Số phút học hôm nay, Số từ cần ôn tập hôm nay (bấm vào thẻ này để vào thẳng trang **Ôn tập**).
- **Mục tiêu hôm nay**: vòng tròn tiến độ theo mục tiêu bạn đặt (theo số từ mới hoặc theo số phút học, chỉnh trong **Hồ sơ cá nhân**).
- **Tiếp tục học**: gợi ý bài học kế tiếp trong khoá học bạn đang học dở, bấm để học tiếp ngay.
- **Khoá học gợi ý**: vài khoá học mới để khám phá thêm.
- **Hoạt động gần đây**: nhật ký các hành động học tập gần nhất (xem khoá học, hoàn thành bài học, ôn từ vựng...).
- **Biểu đồ tiến độ tuần** và mục **Thành tích / Bảng xếp hạng**: hiện đang ở dạng xem trước, được đánh dấu rõ **"Sắp ra mắt"** — đây là các tính năng dự kiến bổ sung sau, số liệu hiển thị hiện chưa phải dữ liệu thật của bạn.

---

## 5. Khoá học

### Danh sách khoá học (`/courses`)

- Vào menu **"Khoá học"** để xem toàn bộ khoá học đang mở, không cần đăng nhập.
- Có thể lọc theo **từ khoá** (tên khoá học), **ngôn ngữ**, và **trình độ** (vd A1, B2...).
- Kết quả hiển thị dạng thẻ (ảnh bìa, ngôn ngữ, trình độ, thời lượng ước tính), có phân trang nếu danh sách dài.

### Chi tiết khoá học

Bấm vào 1 khoá học để xem:

- Mô tả khoá học, danh sách bài học theo đúng thứ tự học.
- Thông tin bên cạnh: ngôn ngữ, trình độ, tổng thời lượng, tổng số bài học.
- Nút **"Ghi danh khoá học"** — cần đăng nhập trước; nếu chưa đăng nhập, hệ thống sẽ đưa bạn tới trang Đăng nhập. Ghi danh là **miễn phí và không giới hạn số khoá học**.
- Sau khi ghi danh, bấm vào bất kỳ bài học nào trong danh sách để bắt đầu học.

> **Lưu ý:** Nếu bạn chưa ghi danh, vẫn có thể xem trước (preview) một phần nội dung bài học, nhưng để xem đầy đủ từ vựng/ngữ pháp và đánh dấu hoàn thành, bạn cần ghi danh khoá học chứa bài học đó trước.

---

## 6. Bài học

Mỗi bài học gồm các phần:

- **Video/Audio bài giảng** (nếu có).
- **Từ vựng** của bài — hiển thị dạng lưới, mỗi từ có ảnh minh hoạ (nếu có), phiên âm và nghĩa.
- **Ngữ pháp** của bài — mỗi điểm ngữ pháp có mẫu câu (pattern), giải thích, và các câu ví dụ minh hoạ.
- **Nút "Học từ vựng"** — đưa bạn sang trang học từ vựng chi tiết của riêng bài học này (xem mục 7).
- **Nút "Làm Quiz"** — làm bài kiểm tra generate động từ nội dung bài học này (xem mục 9). Nút này luôn dùng được miễn bạn đã đăng nhập, không cần ghi danh khoá học.
- **Nút "Hoàn thành bài học"** ở cuối trang — chỉ bấm được khi đã ghi danh khoá học. Hoàn thành bài học sẽ cộng thêm XP và cập nhật % tiến độ khoá học của bạn. Bấm lại nút này khi đã hoàn thành sẽ không bị cộng XP trùng.

---

## 7. Học từ vựng theo bài học

Truy cập qua nút **"Học từ vựng"** trong trang Bài học (yêu cầu đã ghi danh khoá học).

- Từng từ hiển thị dạng danh sách cuộn dọc: ảnh minh hoạ, từ, phiên âm, loại từ, nút **nghe phát âm** (nếu có), nghĩa tiếng Việt, và câu ví dụ (nếu có).
- Vòng tròn tiến độ ở đầu trang cho biết bạn đã học bao nhiêu từ trong bài.
- Với mỗi từ, bấm **"Đánh dấu đã học"** để ghi nhận bạn đã học từ đó — hệ thống sẽ bắt đầu theo dõi mức độ ghi nhớ của từ này và sẽ nhắc bạn ôn lại ở trang **Ôn tập** khi tới hạn.
- Học hết toàn bộ từ trong bài sẽ hiện màn hình chúc mừng hoàn thành.

---

## 8. Deck & Flashcard — Bộ thẻ từ vựng tự tạo

Truy cập qua menu **"Deck"**.

### Danh sách Deck (`/decks`)

Có 2 tab:

- **Khám phá**: xem các Deck **công khai** do người dùng khác tạo và chia sẻ, có thể tìm theo tên. Không cần đăng nhập để xem.
- **Deck của tôi**: các Deck của chính bạn (cả công khai lẫn riêng tư) — cần đăng nhập.

Bấm **"Tạo Deck mới"** để tạo bộ thẻ của riêng bạn: đặt tên, chọn ngôn ngữ, chọn chế độ hiển thị (**Riêng tư** — chỉ mình bạn thấy, hoặc **Công khai** — mọi người tìm và học/nhân bản được), và mô tả ngắn (tuỳ chọn).

### Chi tiết Deck

- Xem danh sách toàn bộ thẻ (từ + nghĩa) trong Deck.
- Nếu bạn là **chủ sở hữu** Deck: có thể **Sửa thông tin Deck**, **Xoá Deck**, **Thêm từ mới** vào Deck (nhập từ + nghĩa, có thể kèm phiên âm/ảnh), và **xoá từng thẻ**.
- Nếu Deck là của người khác và đang **Công khai**: có nút **"Nhân bản Deck"** — tạo một bản sao riêng của Deck đó vào tài khoản bạn (bản sao luôn ở chế độ Riêng tư), để bạn có thể tự học và tuỳ chỉnh mà không ảnh hưởng tới Deck gốc.
- Nút **"Học Flashcard"** — bắt đầu học bộ thẻ này (chỉ bật khi Deck có ít nhất 1 thẻ).

### Học Flashcard

- Có 3 chế độ chọn ở đầu trang: **Xuôi** (mặt trước là từ, mặt sau là nghĩa), **Ngược** (mặt trước là nghĩa, mặt sau là từ), **Xáo trộn** (thứ tự thẻ ngẫu nhiên).
- Bấm vào thẻ để **lật** xem đáp án.
- Sau khi lật, chọn mức độ nhớ của bạn với từ đó: **Quên rồi / Khó / Tốt / Dễ** — hệ thống dùng đánh giá này để tính lại lịch ôn tập tiếp theo cho từ đó (giống hệt cơ chế ở mục Ôn tập).
- Học hết bộ thẻ sẽ hiện bảng tổng kết theo từng mức đánh giá, có thể bấm **"Học lại"** để lặp lại phiên học (nếu đang ở chế độ Xáo trộn, thứ tự sẽ được xáo lại mới).

---

## 9. Quiz — Làm bài kiểm tra

Vào bằng nút **"Làm Quiz"** trong trang Bài học. Cần đăng nhập, không cần ghi danh khoá học.

1. **Chọn số câu**: 10 / 20 / 50 / Tất cả câu có trong ngân hàng câu hỏi của bài học đó. Nếu bài học không đủ số câu bạn chọn, hệ thống sẽ báo và tự dùng hết số câu hiện có.
2. **Làm từng câu**: tuỳ loại câu hỏi sẽ là trắc nghiệm (chọn 1 đáp án) hoặc điền từ (gõ câu trả lời). Có thể bấm **"Bỏ qua câu này"** nếu không chắc đáp án.
3. Sau khi làm hết, bấm **"Nộp bài"** (ở câu cuối) để xem **kết quả ngay lập tức**: phần trăm đúng, số câu đúng/tổng số câu, XP nhận được, thời gian làm bài, và chi tiết đúng/sai kèm giải thích cho từng câu.
4. Bấm **"Làm lại"** để làm một lượt Quiz mới (câu hỏi và thứ tự đáp án được xáo trộn ngẫu nhiên mỗi lần), hoặc **"Xem lịch sử làm Quiz"** để xem lại các lần làm trước.

### Lịch sử làm Quiz (`/quiz-history`)

Danh sách tất cả các lần bạn đã làm Quiz, mới nhất trước, mỗi dòng hiện tên bài học, thời gian, điểm số. Bấm vào 1 dòng để xem lại chi tiết từng câu (lưu ý: với câu trắc nghiệm, phần xem lại lịch sử chỉ hiện đúng/sai chứ không hiện lại nội dung bạn đã chọn, do giới hạn lưu trữ dữ liệu).

---

## 10. Ôn tập (Review) — Ôn từ theo trí nhớ

Vào bằng menu **"Ôn tập"** (chỉ hiện khi đã đăng nhập) hoặc bấm vào thẻ **"Từ cần ôn tập"** trên Dashboard.

Đây là nơi tổng hợp **tất cả từ vựng bạn đã học** (dù học qua Bài học hay qua Deck) mà **đã tới hạn cần ôn lại** theo thuật toán lặp lại ngắt quãng — ưu tiên hiện từ quá hạn lâu nhất trước.

- Bấm vào thẻ để lật xem nghĩa, rồi chọn mức độ nhớ: **Quên rồi / Khó / Tốt / Dễ**.
- Đánh giá càng chính xác, hệ thống càng tính lịch ôn tiếp theo phù hợp với bạn (quên → ôn lại sớm; nhớ tốt → giãn thời gian ôn ra xa hơn).
- Nếu không còn từ nào cần ôn hôm nay, trang sẽ hiện thông báo **"Bạn đã ôn hết rồi!"** — đây là dấu hiệu tốt, không phải lỗi.

---

## 11. Hồ sơ cá nhân

Vào bằng cách bấm vào **tên/avatar của bạn** ở góc trên bên phải.

- **Xem nhanh**: avatar, tên hiển thị, email, XP, streak, trình độ hiện tại.
- **Sửa hồ sơ**: tên hiển thị, URL ảnh đại diện, ngày sinh, giới tính, quốc gia, trình độ hiện tại, và **mục tiêu học hằng ngày** (chọn theo số từ mới/ngày hoặc theo số phút học/ngày, cùng chỉ tiêu cụ thể — mục tiêu này hiển thị lại ở vòng tròn tiến độ trên Dashboard).
- **Đổi mật khẩu**: cần nhập đúng mật khẩu hiện tại. Đổi thành công sẽ đăng xuất khỏi mọi thiết bị khác.

---

## 12. Chế độ sáng / tối

Bấm biểu tượng **mặt trăng/mặt trời** trên thanh điều hướng để chuyển đổi giao diện Sáng ↔ Tối. Lựa chọn được ghi nhớ cho lần truy cập sau.

---

## 13. Dành cho Quản trị viên (Admin)

Mục này chỉ áp dụng cho tài khoản có quyền **Quản trị viên (ADMIN)**. Nếu tài khoản của bạn có quyền này, menu sẽ xuất hiện thêm mục **"Admin"**.

### Cấp quyền Admin cho một tài khoản

Hiện tại hệ thống **chưa có trang hay nút bấm nào để tự cấp quyền Admin** — không có tài khoản nào tự nhiên trở thành Admin qua đăng ký thông thường (mọi tài khoản đăng ký mới đều chỉ có quyền USER). Việc cấp quyền Admin phải nhờ người quản trị hệ thống (dev/DBA) thao tác trực tiếp vào cơ sở dữ liệu: thêm 1 dòng vào bảng `user_role` nối `id` của user đó với `id` của role có `code = 'ADMIN'` trong bảng `role` (2 role có sẵn trong hệ thống là `ADMIN` và `USER`). Nếu bạn tự quản lý server, có thể làm qua phpMyAdmin hoặc dòng lệnh MySQL, ví dụ:

```sql
INSERT INTO user_role (user_id, role_id)
SELECT u.id, r.id FROM users u, role r
WHERE u.username = 'ten_dang_nhap_can_cap_quyen' AND r.code = 'ADMIN';
```

Sau khi được cấp quyền, tài khoản cần **đăng nhập lại** thì quyền Admin mới có hiệu lực (quyền được đọc từ phiên đăng nhập hiện tại, không tự cập nhật cho phiên đang mở).

### Tổng quan quản trị (`/admin`)

Số liệu tổng quan toàn hệ thống: tổng số người dùng, số người dùng đang hoạt động, tổng số khoá học, bài học, từ vựng, Deck, và lượt làm Quiz.

### Quản lý người dùng (`/admin/users`)

- Tìm kiếm người dùng theo username hoặc email.
- Bấm vào 1 người dùng để xem tiến độ học tập của họ (XP, streak, danh sách khoá học đã ghi danh và % hoàn thành).
- Thao tác trạng thái tài khoản: **Vô hiệu hoá**, **Khoá**, hoặc **Kích hoạt lại** — người dùng bị vô hiệu hoá/khoá sẽ bị đăng xuất ngay lập tức và không đăng nhập lại được cho tới khi Admin kích hoạt lại.
- Vì lý do an toàn, Admin **không thể** tự thay đổi trạng thái tài khoản của chính mình.

---

## 14. Câu hỏi thường gặp

**Tôi cần xác thực email sau khi đăng ký không?**
Không. Tài khoản được kích hoạt ngay sau khi đăng ký, dùng được luôn.

**Tôi có thể học nhiều khoá học cùng lúc không?**
Có, không giới hạn số khoá học được ghi danh.

**"Học từ vựng", "Flashcard" và "Ôn tập" khác nhau thế nào?**
- **Học từ vựng**: học từ mới lần đầu theo đúng nội dung 1 bài học cụ thể.
- **Flashcard**: ôn luyện theo Deck do bạn tự tạo, có nhiều chế độ (Xuôi/Ngược/Xáo trộn).
- **Ôn tập**: gộp toàn bộ từ vựng bạn đã học (từ mọi nguồn) đang **tới hạn cần ôn lại** theo trí nhớ thực tế của bạn — không cần tự chọn nguồn, hệ thống tự nhắc.

**Vì sao tôi không đánh dấu "Hoàn thành bài học" được?**
Bạn cần ghi danh khoá học chứa bài học đó trước. Làm Quiz thì không cần ghi danh, nhưng hoàn thành bài học thì cần.

**Nhân bản (Clone) Deck của người khác thì Deck gốc có bị ảnh hưởng không?**
Không. Bản sao là độc lập hoàn toàn — bạn sửa/xoá thẻ trong bản sao của mình không ảnh hưởng gì tới Deck gốc, và ngược lại.

**Đổi mật khẩu xong tôi có bị đăng xuất trên điện thoại không?**
Có — đây là hành vi bảo mật chủ đích: đổi mật khẩu sẽ đăng xuất mọi phiên đăng nhập khác đang mở trên các thiết bị khác.
