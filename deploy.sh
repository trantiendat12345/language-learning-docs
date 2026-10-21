#!/usr/bin/env bash
# Deploy bản mới nhất lên VM production. Chạy trực tiếp trên VM, trong thư mục đã clone sẵn cả
# 3 repo (root + language-learning-backend + language-learning-client).
# Set up lần đầu (VM mới, chưa có Nginx/SSL/`.env.production`) xem docs/dev/DEPLOYMENT.md.
# Dùng: ./deploy.sh

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

if [ ! -f "$ROOT_DIR/.env.production" ]; then
    echo "Chưa có .env.production. Copy từ .env.production.example rồi điền giá trị thật trước khi chạy."
    exit 1
fi

echo "==> Pull code mới nhất (3 repo)..."
git pull
git -C language-learning-backend pull
git -C language-learning-client pull

echo "==> Build lại Backend image..."
docker compose --env-file .env.production build backend

echo "==> Khởi động/khởi động lại MySQL + Backend..."
docker compose --env-file .env.production up -d mysql backend

echo "==> Build lại Frontend tĩnh (npm ci && npm run build trong container)..."
docker compose --env-file .env.production run --rm frontend-build

echo "==> Reload Nginx..."
sudo systemctl reload nginx

echo "==> Health check Backend (chờ container sẵn sàng)..."
sleep 5
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8080/api/auth/login || echo "000")
if [ "$HTTP_CODE" = "000" ]; then
    echo "    Backend KHÔNG phản hồi. Xem log: docker compose logs -f backend"
    exit 1
fi
echo "    Backend phản hồi HTTP $HTTP_CODE (server đang chạy)."

echo "==> Xong."
