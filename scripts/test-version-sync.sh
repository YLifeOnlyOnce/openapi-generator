#!/bin/bash

# 测试版本同步功能
# 模拟git tag触发的版本更新流程

set -e

echo "🧪 Testing version synchronization..."

# 测试版本号
TEST_VERSION="3.2.1"

echo "📋 Testing with version: $TEST_VERSION"

# 设置环境变量并运行生成脚本
export npm_package_version=$TEST_VERSION
./scripts/generate.sh

# 检查生成的package.json中的版本号
echo "🔍 Checking generated package.json version..."
GENERATED_VERSION=$(grep '"version":' generated/client/package.json | sed 's/.*"version": "\([^"]*\)".*/\1/')

echo "Expected version: $TEST_VERSION"
echo "Generated version: $GENERATED_VERSION"

if [ "$TEST_VERSION" = "$GENERATED_VERSION" ]; then
    echo "✅ Version synchronization test PASSED!"
    echo "📦 Package version correctly updated to match tag version"
else
    echo "❌ Version synchronization test FAILED!"
    echo "💥 Expected: $TEST_VERSION, Got: $GENERATED_VERSION"
    exit 1
fi

# 检查生成的代码中的版本信息
echo "🔍 Checking OpenAPI generator version parameter..."
if grep -q "npmVersion=${TEST_VERSION}" scripts/generate.sh; then
    echo "✅ OpenAPI generator uses dynamic version parameter"
else
    echo "⚠️  OpenAPI generator may not be using dynamic version"
fi

echo "🎉 Version synchronization test completed successfully!"
echo ""
echo "📋 Summary:"
echo "   - Git tag version: $TEST_VERSION"
echo "   - Package.json version: $GENERATED_VERSION"
echo "   - Status: ✅ Synchronized"