#!/bin/bash

# Dừng script ngay lập tức nếu có lỗi xảy ra
set -e

# --- CẤU HÌNH BIẾN ---
APP_NAME="ApiGateway"
URL="https://raw.githubusercontent.com/davidngo1704/script/HEAD/SourceCode"
TEMP_BIN="/root/SourceCode"
INSTALL_DIR="/usr/local/bin/$APP_NAME"
INSTALL_BIN="$INSTALL_DIR/SourceCode"
SERVICE_FILE="/etc/systemd/system/$APP_NAME.service"
DATA_DIR="/var/lib/$APP_NAME"
LOG_DIR="/var/log/$APP_NAME"

# 1. CẬP NHẬT HỆ THỐNG & CÀI ĐẶT CÔNG CỤ
echo "--- 1. Đang cập nhật hệ thống và cài đặt SSH, Curl, Git ---"
sudo apt update -y
sudo apt install openssh-server curl git -y

# 2. CẤU HÌNH SSH (Cho phép đăng nhập root và password)
echo "--- 2. Đang cấu hình SSH ---"
sudo sed -i 's/^#*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sudo sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Đặt mật khẩu cho root
echo "root:dai17041998" | sudo chpasswd

# Khởi động lại dịch vụ SSH
sudo systemctl enable ssh
sudo systemctl restart ssh || sudo systemctl restart sshd

# 3. TẢI FILE SOURCE CODE
echo "--- 3. Đang tải file SourceCode từ GitHub ---"
curl -L $URL -o $TEMP_BIN
chmod +x $TEMP_BIN

# 4. THIẾT LẬP MÔI TRƯỜNG VÀ DỊCH VỤ (TỪ CREATE_API_GATEWAY)
echo "--- 4. Đang cài đặt dịch vụ $APP_NAME ---"

# Tạo thư mục hệ thống
sudo mkdir -p "$DATA_DIR" "$LOG_DIR" "$INSTALL_DIR"

# Copy binary vào nơi cài đặt chính thức
sudo cp "$TEMP_BIN" "$INSTALL_BIN"
sudo chmod +x "$INSTALL_BIN"

# Phân quyền (Giữ 777 theo yêu cầu ban đầu của bạn cho data dir)
sudo chown -R root:root "$INSTALL_DIR"
sudo chown -R root:root "$DATA_DIR" "$LOG_DIR"
sudo chmod -R 777 "$DATA_DIR"

# 5. TẠO FILE SYSTEMD SERVICE
echo "--- 5. Đang cấu hình Systemd Service ---"
sudo tee "$SERVICE_FILE" > /dev/null <<EOF
[Unit]
Description=$APP_NAME Service
After=network.target

[Service]
ExecStart=$INSTALL_BIN
WorkingDirectory=$DATA_DIR
Restart=always
RestartSec=5
User=root
Environment=DOTNET_ENVIRONMENT=Production
Environment=DOTNET_DATAPATH=$DATA_DIR
StandardOutput=append:$LOG_DIR/output.log
StandardError=append:$LOG_DIR/error.log

[Install]
WantedBy=multi-user.target
EOF

# 6. KÍCH HOẠT VÀ CHẠY SERVICE
echo "--- 6. Khởi chạy dịch vụ ---"
sudo systemctl daemon-reload
sudo systemctl enable "$APP_NAME.service"
sudo systemctl start "$APP_NAME.service"

echo "----------------------------------------------------"
echo "HOÀN TẤT CÀI ĐẶT!"
echo "- SSH: Đã mở (Root login: yes, Pass: dai17041998)"
echo "- Service: $APP_NAME đang chạy."
echo "- Log: $LOG_DIR/output.log"
echo "----------------------------------------------------"