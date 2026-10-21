# Deployment Guide — Production (Oracle Cloud Free Tier)

Hướng dẫn deploy app lên môi trường thật, chạy 24/7, có domain + HTTPS, hoàn toàn miễn phí. Đọc kèm `docker-compose.yml`, `.env.production.example`, `deploy.sh`, `deploy/nginx-languagelearning.conf` ở root repo.

## Kiến trúc

```
Browser ──HTTPS──▶ Nginx (host, Ubuntu VM)
                     ├─ serve static: language-learning-client/dist (frontend build)
                     └─ reverse proxy /api/** ──▶ 127.0.0.1:8080 (container "backend")
                                                        │
                                                        ▼
                                              container "mysql" (volume persist)
```

Nginx đóng vai trò same-origin proxy giống Vite dev proxy — browser chỉ thấy 1 origin duy nhất, tránh toàn bộ vấn đề CORS/cookie SameSite. Backend + MySQL chạy trong Docker; Nginx cài trực tiếp trên host (không Docker hoá) để dùng được `certbot --nginx` — cách cấp/renew SSL free chuẩn và đơn giản nhất.

## Giai đoạn A — Setup hạ tầng (làm 1 lần)

### A1. Tạo Oracle Cloud Free Tier VM

1. Đăng ký tài khoản tại https://www.oracle.com/cloud/free/ (cần thẻ để xác minh danh tính — Always Free không bị trừ tiền).
2. Tạo Compute Instance: **Create a VM instance** → Image: **Ubuntu 24.04**, Shape: đổi sang **VM.Standard.A1.Flex** (Ampere, Always Free eligible) → chọn **2 OCPU / 12 GB RAM** (đủ cho MySQL + Spring Boot, còn dư quota Always Free 4 OCPU/24GB nếu sau cần thêm).
3. Tải/lưu SSH key được cấp lúc tạo instance, ghi lại **Public IP**.
4. Vào **Networking → Virtual Cloud Network → Security Lists** (subnet của instance) → **Add Ingress Rules**: mở **TCP 80** và **TCP 443** (source `0.0.0.0/0`). Port 22 mặc định đã mở.

### A2. Domain free (DuckDNS)

1. Vào https://www.duckdns.org, đăng nhập bằng GitHub/Google, tạo subdomain (vd `mylanguageapp` → `mylanguageapp.duckdns.org`).
2. Trỏ **IP** của subdomain = Public IP của VM (điền vào ô "current ip" trên trang DuckDNS).
3. (Nên làm) Cài cron cập nhật IP tự động trên VM đề phòng IP đổi — DuckDNS có script mẫu ở trang "install" của họ.

### A3. SSH vào VM, cài Docker + Nginx + Certbot

```bash
ssh -i /path/to/key.pem ubuntu@<PUBLIC_IP>

# Docker
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker $USER
newgrp docker

# Nginx + Certbot
sudo apt update
sudo apt install -y nginx certbot python3-certbot-nginx git
```

### A4. Mở firewall nội bộ Ubuntu

Image Oracle mặc định có `iptables` chặn hầu hết traffic ngoài SSH — cần mở thêm 80/443 ở tầng OS (khác với Security List ở bước A1, cả 2 đều phải mở):

```bash
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 443 -j ACCEPT
sudo netfilter-persistent save   # nếu có cài netfilter-persistent, không thì: sudo apt install -y iptables-persistent
```

## Giai đoạn B — Clone code + cấu hình lần đầu

```bash
git clone <URL_ROOT_REPO> languagelearning
cd languagelearning
git clone <URL_BACKEND_REPO> language-learning-backend
git clone <URL_CLIENT_REPO> language-learning-client

cp .env.production.example .env.production
```

Sửa `.env.production`:
- `MYSQL_ROOT_PASSWORD`, `DB_PASSWORD`: random mạnh (`openssl rand -base64 32`).
- `JWT_SECRET`: random mạnh, **khác** giá trị đang dùng ở local dev (`openssl rand -base64 64`).
- `FRONTEND_URL`: `https://<subdomain>.duckdns.org` (đúng subdomain đã tạo ở A2).

## Giai đoạn C — Deploy lần đầu

```bash
# Backend + MySQL
docker compose --env-file .env.production up -d mysql backend
docker compose logs -f backend   # Ctrl+C khi thấy "Started LanguageLearningBackendApplication"

# Frontend (build ra language-learning-client/dist)
docker compose --env-file .env.production run --rm frontend-build
```

Cấu hình Nginx (HTTP trước, Certbot sẽ tự nâng cấp lên HTTPS ở bước sau):

```bash
sudo cp deploy/nginx-languagelearning.conf /etc/nginx/sites-available/languagelearning
# Sửa <SUBDOMAIN> và <REPO_ROOT> trong file vừa copy cho đúng giá trị thật
sudo nano /etc/nginx/sites-available/languagelearning

sudo ln -s /etc/nginx/sites-available/languagelearning /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default   # bỏ site mặc định của Nginx
sudo nginx -t && sudo systemctl reload nginx
```

Test tạm qua HTTP: `curl -I http://<subdomain>.duckdns.org` phải trả 200.

Cấp SSL free:

```bash
sudo certbot --nginx -d <subdomain>.duckdns.org
```

Certbot tự sửa `/etc/nginx/sites-available/languagelearning` (thêm `listen 443 ssl`, đường dẫn cert, redirect HTTP→HTTPS) và tự cài systemd timer renew — không cần làm gì thêm để gia hạn.

## Deploy các lần sau (sửa bug / thêm tính năng xong, muốn đưa lên production)

Quy trình đầy đủ từ lúc sửa code trên máy cá nhân tới lúc thấy thay đổi trên domain thật.

### Bước 1 — Sửa code + test local

Sửa bug/tính năng như bình thường, chạy thử qua `start-demo.sh`/`./mvnw spring-boot:run`/`npm run dev` ở local trước — **không đẩy thẳng code chưa test lên production**.

- Backend: `cd language-learning-backend && ./mvnw test` phải pass.
- Frontend: `cd language-learning-client && npm run lint && npm run build` phải sạch (đúng Definition of Done ở `docs/dev/CODING_CONVENTIONS.md`).

### Bước 2 — Commit + push code lên GitHub

Theo đúng quy tắc CLAUDE.md: commit tách theo repo bị ảnh hưởng (chỉ sửa Backend thì chỉ commit/push repo Backend), message có tiền tố `[V<số>]` (chạy `git log --oneline -5` ở đúng repo để lấy số tiếp theo). Ví dụ sửa 1 bug ở Backend:

```bash
cd language-learning-backend
git add <file cụ thể>
git commit -m "[V70] fix: <mô tả bug đã sửa>"
git push
```

Nếu có sửa cả `docs/` (bắt buộc khi thay đổi schema hoặc hoàn thành 1 phần việc — xem CLAUDE.md), commit riêng ở root repo tương tự.

### Bước 3 — SSH vào VM, chạy `deploy.sh`

```bash
ssh -i /path/to/key.pem ubuntu@<PUBLIC_IP>
cd languagelearning
./deploy.sh
```

### Bước 4 — `deploy.sh` làm gì bên trong (để hiểu/debug khi cần)

Script chạy tuần tự các lệnh sau (xem file `deploy.sh` để đối chiếu):

1. `git pull` ở cả 3 repo (root + backend + client) — kéo đúng code vừa push ở Bước 2.
2. `docker compose --env-file .env.production build backend` — build lại image Backend từ Dockerfile (chỉ rebuild nếu `language-learning-backend/` có thay đổi, Docker tự cache layer không đổi).
3. `docker compose --env-file .env.production up -d mysql backend` — khởi động lại container Backend với image mới (MySQL không bị ảnh hưởng, data trong volume giữ nguyên).
4. `docker compose --env-file .env.production run --rm frontend-build` — chạy `npm ci && npm run build` trong container tạm, ghi đè `language-learning-client/dist` bằng bản build mới.
5. `sudo systemctl reload nginx` — Nginx đọc lại, phục vụ bản `dist` mới ngay (không cần restart, không downtime).
6. `curl` vào Backend qua `127.0.0.1:8080` để xác nhận server phản hồi (không phải "Connection refused").

**Nếu chỉ sửa Frontend** (không đụng Backend), có thể chạy tay nhanh hơn thay vì cả script:

```bash
git -C language-learning-client pull
docker compose --env-file .env.production run --rm frontend-build
sudo systemctl reload nginx
```

**Nếu chỉ sửa Backend**, tương tự bỏ qua bước frontend-build:

```bash
git -C language-learning-backend pull
docker compose --env-file .env.production build backend
docker compose --env-file .env.production up -d backend
```

### Bước 5 — Verify trên trình duyệt thật

Mở `https://<subdomain>.duckdns.org`, kiểm tra đúng luồng vừa sửa (hard refresh `Cmd+Shift+R` để chắc chắn không dính cache trình duyệt cũ). Nếu sửa API, kiểm tra thêm `docker compose logs -f backend` không có lỗi khởi động.

### Bước 6 — Nếu deploy lỗi, cách rollback nhanh

- **Backend lỗi** (container crash/log lỗi): quay lại commit trước đó rồi build lại.
  ```bash
  git -C language-learning-backend log --oneline -5   # xem commit trước đó
  git -C language-learning-backend checkout <commit_hash_cũ>
  docker compose --env-file .env.production build backend
  docker compose --env-file .env.production up -d backend
  ```
- **Frontend lỗi** (build fail hoặc UI vỡ): tương tự, `git -C language-learning-client checkout <commit_hash_cũ>` rồi chạy lại `frontend-build` + reload Nginx.
- Sau khi rollback xong và đã sửa lỗi ở nhánh chính, nhớ `git checkout main` (hoặc branch đang dùng) lại trước khi pull code mới ở lần deploy tiếp theo — tránh bị kẹt ở trạng thái "detached HEAD".

## Vận hành

- **Xem log backend:** `docker compose logs -f backend`
- **Backup MySQL:** `docker compose exec mysql mysqldump -u root -p"$MYSQL_ROOT_PASSWORD" language_learning > backup_$(date +%F).sql`
- **Rotate JWT_SECRET:** sửa `.env.production` → `docker compose --env-file .env.production up -d backend` (lưu ý: mọi refresh token cũ sẽ mất hiệu lực, user phải login lại).
- **SSL tự renew:** Certbot cài sẵn systemd timer, kiểm tra: `sudo systemctl status certbot.timer`.

## Giới hạn hiện tại / việc để sau

- Chưa có health-check endpoint chuẩn (`/actuator/health`) — `deploy.sh` chỉ check HTTP có phản hồi hay không. Thêm Spring Boot Actuator là cải tiến Phase sau, không nằm trong phạm vi lần deploy đầu này.
- Chưa có CI/CD tự động (deploy vẫn chạy tay `./deploy.sh` trên VM) — có thể làm GitHub Actions tự SSH+deploy khi push `main` ở giai đoạn sau nếu cần.
- Chưa có monitoring/alerting khi service down.
