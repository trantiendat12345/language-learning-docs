#!/usr/bin/env bash
# Dừng toàn bộ Backend + Frontend + Cloudflare Tunnel khởi động bởi start-demo.sh.
# Dùng port/pattern-based kill thay vì chỉ tin PID lưu lại, vì `mvnw spring-boot:run` fork ra
# JVM con - kill đúng PID cha đôi khi không kill được JVM con.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$ROOT_DIR/.demo-logs"
PID_FILE="$LOG_DIR/pids"

echo "==> Tắt caffeinate..."
pkill -f "caffeinate -s" 2>/dev/null && echo "    Đã dừng." || echo "    Không có tiến trình nào đang chạy."

echo "==> Dừng Cloudflare Tunnel..."
pkill -f "cloudflared tunnel --url" 2>/dev/null && echo "    Đã dừng." || echo "    Không có tiến trình nào đang chạy."

echo "==> Dừng Frontend (port 5173)..."
FRONTEND_PIDS=$(lsof -ti:5173 2>/dev/null)
if [ -n "$FRONTEND_PIDS" ]; then
    kill -9 $FRONTEND_PIDS 2>/dev/null
    echo "    Đã dừng."
else
    echo "    Không có tiến trình nào đang chạy."
fi

echo "==> Dừng Backend (port 8080)..."
BACKEND_PIDS=$(lsof -ti:8080 2>/dev/null)
if [ -n "$BACKEND_PIDS" ]; then
    kill -9 $BACKEND_PIDS 2>/dev/null
    echo "    Đã dừng."
else
    echo "    Không có tiến trình nào đang chạy."
fi

rm -f "$PID_FILE"
echo "==> Xong. (MySQL vẫn để chạy - dùng mysql.server stop nếu muốn tắt luôn)"
