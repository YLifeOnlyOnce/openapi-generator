#!/bin/bash

# 设置错误时退出
set -e

echo "🔍 Validating OpenAPI specification..."

# 检查 OpenAPI 规范文件是否存在
if [ ! -f "spec/example-api.yaml" ]; then
    echo "❌ OpenAPI specification file not found: spec/example-api.yaml"
    exit 1
fi

# 安装验证工具（如果未安装）
if ! command -v swagger-parser &> /dev/null; then
    echo "📦 Installing swagger-parser..."
    npm install -g @apidevtools/swagger-parser
fi

# 验证 OpenAPI 规范
echo "📋 Validating spec/example-api.yaml..."
npx @apidevtools/swagger-parser validate spec/example-api.yaml

if [ $? -eq 0 ]; then
    echo "✅ OpenAPI specification is valid!"
else
    echo "❌ OpenAPI specification validation failed!"
    exit 1
fi

# 检查必需的字段
echo "🔍 Checking required fields..."

# 检查是否有 info.title
if ! grep -q "title:" spec/example-api.yaml; then
    echo "⚠️  Warning: No title found in info section"
fi

# 检查是否有 info.version
if ! grep -q "version:" spec/example-api.yaml; then
    echo "⚠️  Warning: No version found in info section"
fi

# 检查是否有 paths
if ! grep -q "paths:" spec/example-api.yaml; then
    echo "❌ Error: No paths section found"
    exit 1
fi

echo "✅ All checks passed!"
echo "📊 Specification summary:"
echo "   - Title: $(grep 'title:' spec/example-api.yaml | head -1 | sed 's/.*title: *//')"
echo "   - Version: $(grep 'version:' spec/example-api.yaml | head -1 | sed 's/.*version: *//')"
echo "   - Paths: $(grep -c '^  /' spec/example-api.yaml || echo '0') endpoints"
echo "   - Schemas: $(grep -c '^    [A-Z].*:$' spec/example-api.yaml || echo '0') models"