#!/usr/bin/env bash
# Khởi động Backend + Frontend + Cloudflare Tunnel để demo cho người khác test.
# Dùng: ./start-demo.sh
# Dừng:  ./stop-demo.sh

set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$ROOT_DIR/language-learning-backend"
CLIENT_DIR="$ROOT_DIR/language-learning-client"
LOG_DIR="$ROOT_DIR/.demo-logs"
PID_FILE="$LOG_DIR/pids"

mkdir -p "$LOG_DIR"
: > "$PID_FILE"

# Nếu có tiến trình demo cũ còn sống (chạy start-demo.sh 2 lần liên tiếp), dừng trước để tránh
# đụng port / tunnel cũ chiếm URL.
if [ -x "$ROOT_DIR/stop-demo.sh" ] && (lsof -ti:8080 >/dev/null 2>&1 || lsof -ti:5173 >/dev/null 2>&1 || pgrep -f "cloudflared tunnel --url" >/dev/null 2>&1); then
    echo "==> Phát hiện tiến trình demo cũ đang chạy, dừng trước..."
    "$ROOT_DIR/stop-demo.sh"
    sleep 1
fi

echo "==> Kiểm tra MySQL (port 3306)..."
if ! nc -z localhost 3306 2>/dev/null; then
    echo "    MySQL chưa chạy, đang khởi động..."
    mysql.server start
    sleep 3
fi
echo "    OK."

echo "==> Khởi động Backend (port 8080)..."
cd "$BACKEND_DIR"
COOKIE_SECURE=true nohup ./mvnw spring-boot:run > "$LOG_DIR/backend.log" 2>&1 &
BACKEND_PID=$!
echo "$BACKEND_PID" >> "$PID_FILE"
cd "$ROOT_DIR"

for i in $(seq 1 60); do
    if grep -q "Started LanguageLearningBackendApplication" "$LOG_DIR/backend.log" 2>/dev/null; then
        echo "    Backend đã sẵn sàng."
        break
    fi
    if ! kill -0 "$BACKEND_PID" 2>/dev/null; then
        echo "    Backend thoát bất thường. Xem log: $LOG_DIR/backend.log"
        exit 1
    fi
    if [ "$i" -eq 60 ]; then
        echo "    Backend khởi động quá lâu (>2 phút). Xem log: $LOG_DIR/backend.log"
        exit 1
    fi
    sleep 2
done

echo "==> Khởi động Frontend (port 5173)..."
cd "$CLIENT_DIR"
nohup npm run dev -- --host > "$LOG_DIR/frontend.log" 2>&1 &
FRONTEND_PID=$!
echo "$FRONTEND_PID" >> "$PID_FILE"
cd "$ROOT_DIR"

for i in $(seq 1 30); do
    if grep -q "Local:" "$LOG_DIR/frontend.log" 2>/dev/null; then
        echo "    Frontend đã sẵn sàng."
        break
    fi
    if ! kill -0 "$FRONTEND_PID" 2>/dev/null; then
        echo "    Frontend thoát bất thường. Xem log: $LOG_DIR/frontend.log"
        exit 1
    fi
    if [ "$i" -eq 30 ]; then
        echo "    Frontend khởi động quá lâu (>30s). Xem log: $LOG_DIR/frontend.log"
        exit 1
    fi
    sleep 1
done

echo "==> Mở Cloudflare Tunnel..."
nohup cloudflared tunnel --url http://localhost:5173 > "$LOG_DIR/tunnel.log" 2>&1 &
TUNNEL_PID=$!
echo "$TUNNEL_PID" >> "$PID_FILE"

URL=""
for i in $(seq 1 30); do
    URL=$(grep -o 'https://[a-zA-Z0-9.-]*\.trycloudflare\.com' "$LOG_DIR/tunnel.log" 2>/dev/null | head -1)
    if [ -n "$URL" ]; then
        break
    fi
    sleep 1
done

if [ -z "$URL" ]; then
    echo "    Không lấy được link tunnel. Xem log: $LOG_DIR/tunnel.log"
    exit 1
fi

echo ""
echo "================================================================"
echo " Link demo (gửi cho người test):"
echo " $URL"
echo "================================================================"
echo ""
echo "Log:   $LOG_DIR/backend.log | frontend.log | tunnel.log"
echo "Dừng:  ./stop-demo.sh"
