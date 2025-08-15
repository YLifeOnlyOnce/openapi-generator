#!/bin/bash

# 测试动态包名功能
set -e

echo "🧪 Testing dynamic package name functionality..."

# 备份当前模板
cp templates/client-package.json templates/client-package.json.backup

# 测试不同的包名
test_package_names=(
  "@test/example-api-client"
  "my-api-client"
  "@company/special-api"
)

for package_name in "${test_package_names[@]}"; do
  echo "\n📦 Testing with package name: $package_name"
  
  # 更新模板中的包名
  node -e "
    const fs = require('fs');
    const pkg = JSON.parse(fs.readFileSync('templates/client-package.json', 'utf8'));
    pkg.name = '$package_name';
    fs.writeFileSync('templates/client-package.json', JSON.stringify(pkg, null, 2));
  "
  
  # 运行生成脚本
  export npm_package_version="1.0.0"
  ./scripts/generate.sh > /dev/null 2>&1
  
  # 检查生成的package.json
  generated_name=$(node -p "require('./generated/client/package.json').name")
  if [ "$generated_name" = "$package_name" ]; then
    echo "✅ Package.json name: $generated_name"
  else
    echo "❌ Package.json name mismatch: expected $package_name, got $generated_name"
    exit 1
  fi
  
  # 检查README中的包名
  readme_count=$(grep -c "$package_name" generated/client/README.md || echo "0")
  if [ "$readme_count" -ge "3" ]; then
    echo "✅ README contains package name $readme_count times"
  else
    echo "❌ README package name count: $readme_count (expected >= 3)"
    exit 1
  fi
  
  # 检查release.yml中的动态包名获取
  if grep -q "get_package_name" .github/workflows/release.yml; then
    echo "✅ Release workflow has dynamic package name step"
  else
    echo "❌ Release workflow missing dynamic package name step"
    exit 1
  fi
done

# 恢复原始模板
mv templates/client-package.json.backup templates/client-package.json

echo "\n🎉 All dynamic package name tests passed!"
echo "✅ Package names are correctly retrieved from templates"
echo "✅ Generated files use dynamic package names"
echo "✅ CI/CD workflows support dynamic package names"