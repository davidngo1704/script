#!/bin/bash
set -e

APP_NAME="ApiGateway"
APP_BIN="/usr/local/bin/$APP_NAME/SourceCode"
TMP_FILE="/root/SourceCode"
SERVICE_NAME="$APP_NAME.service"


# Stop service
sudo systemctl stop $SERVICE_NAME || true

# Copy file mới vào vị trí chính
sudo cp "$TMP_FILE" "$APP_BIN"
sudo chmod +x "$APP_BIN"
sudo chown root:root "$APP_BIN"

# Reload systemd & start lại
sudo systemctl daemon-reload
sudo systemctl start $SERVICE_NAME

