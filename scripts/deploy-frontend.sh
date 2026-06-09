#!/bin/bash
# Script para copiar o build local para o container Docker
set -e

echo "🔨 Building locally..."
cd /home/bruno/workspace/school-management/school-management-ui
npm run build 2>&1 | tail -3

echo "📦 Copying to container..."
docker cp /home/bruno/workspace/school-management/school-management-ui/dist/school-management-app/browser/. school-management-api-frontend-1:/usr/share/nginx/html/

echo "✅ Done! Frontend updated."
