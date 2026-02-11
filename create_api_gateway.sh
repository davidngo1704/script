set -e

APP_NAME="ApiGateway"
APP_BIN="/root/SourceCode"
INSTALL_BIN="/usr/local/bin/$APP_NAME/SourceCode"
SERVICE_FILE="/etc/systemd/system/$APP_NAME.service"

DATA_DIR="/var/lib/$APP_NAME"
LOG_DIR="/var/log/$APP_NAME"


# 1. Kiểm tra binary tồn tại
if [ ! -f "$APP_BIN" ]; then
    exit 1
fi

# 2. Tạo thư mục hệ thống
sudo mkdir -p "$DATA_DIR" "$LOG_DIR" "/usr/local/bin/$APP_NAME"

# 3. Copy binary
sudo cp "$APP_BIN" "$INSTALL_BIN"
sudo chmod +x "$INSTALL_BIN"

# 4. Phân quyền
sudo chown -R root:root "$INSTALL_BIN"
sudo chown -R root:root "$DATA_DIR" "$LOG_DIR"

# 5. Tạo file systemd service
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
Environment=DOTNET_DATAPATH=/var/lib/$APP_NAME
StandardOutput=append:$LOG_DIR/output.log
StandardError=append:$LOG_DIR/error.log

[Install]
WantedBy=multi-user.target
EOF

# 6. Reload systemd & enable service
sudo systemctl daemon-reload
sudo systemctl enable "$APP_NAME.service"

# 7. Start service
sudo systemctl start "$APP_NAME.service"