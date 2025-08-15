#!/bin/bash

# 设置错误时退出
set -e

# 设置版本号（从环境变量获取，默认为1.0.0）
npm_package_version=${npm_package_version:-1.0.0}

# 从模板文件中获取包名
if [ -f "templates/client-package.json" ]; then
  npm_package_name=$(node -p "require('./templates/client-package.json').name")
else
  npm_package_name="example-api-client"
fi

echo "🚀 Starting API client and documentation generation..."
echo "📦 Package: $npm_package_name"
echo "📦 Version: $npm_package_version"

# 确保使用 Node.js 20
if command -v nvm &> /dev/null; then
    echo "📦 Switching to Node.js 20..."
    nvm use 20
fi

# 检查 Node.js 版本
node_version=$(node -v)
echo "📋 Using Node.js version: $node_version"

# 清理之前的生成文件
echo "🧹 Cleaning previous generated files..."
rm -rf generated/client generated/docs

# 创建输出目录
mkdir -p generated/client generated/docs

# 检查本地 jar 文件
JAR_FILE="openapi-generator-cli-7.14.0.jar"
if [ ! -f "$JAR_FILE" ]; then
    echo "❌ OpenAPI Generator JAR file not found: $JAR_FILE"
    echo "Please download it from: https://repo1.maven.org/maven2/org/openapitools/openapi-generator-cli/7.14.0/openapi-generator-cli-7.14.0.jar"
    exit 1
fi

# 生成 TypeScript Axios 客户端
echo "🔧 Generating TypeScript Axios client..."
java -jar $JAR_FILE generate \
  -i spec/example-api.yaml \
  -g typescript-axios \
  -o generated/client \
  --additional-properties=npmName=$npm_package_name,npmVersion=${npm_package_version:-1.0.0},supportsES6=true,withInterfaces=true,useSingleRequestParameter=true,stringEnums=true,enumNameSuffix=Enum,modelPropertyNaming=camelCase,removeOperationIdPrefix=true

# 生成 HTML 文档
echo "📚 Generating HTML documentation..."
java -jar $JAR_FILE generate \
  -i spec/example-api.yaml \
  -g html2 \
  -o generated/docs

# 运行后处理脚本
echo "🔧 Running post-generation processing..."
./scripts/post-generate.sh

echo "✅ Generation completed successfully!"
echo "📁 Client code: generated/client"
echo "📖 Documentation: generated/docs"

# 返回根目录
cd ../..