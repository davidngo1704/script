#!/bin/bash

# Dừng script nếu có lỗi
set -e

# --- BIẾN CẤU HÌNH ---
APP_NAME="ApiGateway"
URL="https://raw.githubusercontent.com/davidngo1704/script/HEAD/SourceCode"
TEMP_BIN="/root/SourceCode_temp"
INSTALL_DIR="/usr/local/bin/$APP_NAME"
INSTALL_BIN="$INSTALL_DIR/SourceCode"
SERVICE_FILE="/etc/systemd/system/$APP_NAME.service"
DATA_DIR="/var/lib/$APP_NAME"
LOG_DIR="/var/log/$APP_NAME"

echo "--- BẮT ĐẦU QUÁ TRÌNH THIẾT LẬP HỆ THỐNG ---"

# 1. Cấu hình Múi giờ Việt Nam
echo "--- Thiết lập múi giờ Asia/Ho_Chi_Minh ---"
sudo timedatectl set-timezone Asia/Ho_Chi_Minh

# 2. Cập nhật và Cài đặt công cụ
echo "--- Cập nhật gói và cài đặt SSH, Curl, Git, Certificates ---"
sudo apt update -y
sudo apt install -y openssh-server curl git ca-certificates ufw

# 3. Cấu hình SSH & User
echo "--- Cấu hình SSH và Password root ---"
sudo sed -i 's/^#*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sudo sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo "root:dai17041998" | sudo chpasswd
sudo systemctl enable --now ssh

# 4. Cấu hình Tường lửa (UFW)
echo "--- Cấu hình tường lửa: Mở port 22 (SSH) ---"
sudo ufw allow 22/tcp
# sudo ufw allow 80/tcp # Mở port web nếu cần
# sudo ufw allow 443/tcp
sudo ufw --force enable

# 5. Tải và Cài đặt SourceCode
echo "--- Tải SourceCode từ GitHub ---"
sudo curl -L $URL -o $TEMP_BIN
sudo chmod +x $TEMP_BIN

# Tạo thư mục và di chuyển file
sudo mkdir -p "$DATA_DIR" "$LOG_DIR" "$INSTALL_DIR"
sudo mv "$TEMP_BIN" "$INSTALL_BIN"

# Phân quyền
sudo chmod -R 777 "$DATA_DIR"
sudo chown -R root:root "$INSTALL_DIR"
sudo chown -R root:root "$LOG_DIR"

# 6. Tạo và Chạy Systemd Service
echo "--- Thiết lập Systemd Service ---"
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

sudo systemctl daemon-reload
sudo systemctl enable --now "$APP_NAME.service"

echo "----------------------------------------------------"
echo "TẤT CẢ ĐÃ SẴN SÀNG!"
echo "IP của bạn là: $(hostname -I | awk '{print $1}')"
echo "Bạn có thể SSH bằng: root / dai17041998"
echo "----------------------------------------------------"