#!/bin/bash

cd /var/lib/ApiGateway/source_code/script

TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

COMMIT_MSG="auto commit at $TIMESTAMP"

git add .

git commit -m "$COMMIT_MSG"

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

git push origin "$CURRENT_BRANCH"

echo "Đã commit & push với message: $COMMIT_MSG"
