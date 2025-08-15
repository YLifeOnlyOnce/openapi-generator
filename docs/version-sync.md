# 版本同步机制

本文档说明了项目中git tag版本与生成的API客户端包版本的同步机制。

## 🔄 工作流程

### 1. Git Tag 触发
当推送符合 `v*.*.*` 格式的git tag时（如 `v1.2.3`），会自动触发GitHub Actions工作流程。

### 2. 版本提取
```yaml
- name: Get version from tag
  id: get_version
  run: |
    VERSION=${GITHUB_REF#refs/tags/v}
    echo "VERSION=$VERSION" >> $GITHUB_OUTPUT
```

### 3. 环境变量设置
```yaml
- name: Generate API client and docs
  run: |
    export npm_package_version=${{ steps.get_version.outputs.VERSION }}
    ./scripts/generate.sh
```

### 4. 代码生成与版本更新

#### OpenAPI Generator 版本参数
在 `scripts/generate.sh` 中：
```bash
java -jar $JAR_FILE generate \
  --additional-properties=npmVersion=${npm_package_version:-1.0.0}
```

#### Package.json 版本更新
在 `scripts/post-generate.sh` 中：
```bash
if [ ! -z "$npm_package_version" ]; then
    echo "🔢 Updating package version to $npm_package_version..."
    sed -i.bak "s/\"version\": \"[^\"]*\"/\"version\": \"$npm_package_version\"/" package.json
fi
```

## 📋 版本同步点

| 位置 | 更新方式 | 说明 |
|------|----------|------|
| `generated/client/package.json` | 自动 | 通过post-generate.sh脚本更新 |
| OpenAPI生成的代码注释 | 自动 | 通过npmVersion参数传递 |
| GitHub Release | 自动 | 使用相同的tag版本 |
| NPM包版本 | 自动 | 发布时使用package.json中的版本 |

## 🧪 测试版本同步

运行测试脚本来验证版本同步功能：

```bash
./scripts/test-version-sync.sh
```

该脚本会：
1. 设置测试版本号（如 3.2.1）
2. 运行完整的生成流程
3. 验证生成的package.json版本是否正确
4. 检查OpenAPI generator是否使用了动态版本

## 📦 手动版本更新

如果需要手动更新版本，可以设置环境变量：

```bash
# 设置版本号
export npm_package_version=2.1.0

# 运行生成脚本
./scripts/generate.sh
```

## 🔍 版本验证

### 检查当前版本
```bash
# 查看生成的包版本
grep '"version":' generated/client/package.json

# 查看最新的git tag
git describe --tags --abbrev=0
```

### 验证版本一致性
```bash
# 运行版本同步测试
./scripts/test-version-sync.sh
```

## ⚠️ 注意事项

1. **Tag格式**：必须使用 `v*.*.*` 格式（如 `v1.0.0`、`v2.1.3`）
2. **环境变量**：`npm_package_version` 变量会覆盖默认版本 `1.0.0`
3. **备份**：原始package.json会备份为 `package.json.bak`
4. **自动化**：版本更新完全自动化，无需手动干预

## 🚀 发布流程

1. 确保代码已提交并推送到主分支
2. 创建并推送git tag：
   ```bash
   git tag v1.2.3
   git push origin v1.2.3
   ```
3. GitHub Actions自动执行：
   - 提取版本号
   - 生成API客户端
   - 更新版本号
   - 构建和测试
   - 发布到NPM
   - 创建GitHub Release

## 🔧 故障排除

### 版本不匹配
如果发现版本不匹配，检查：
1. Git tag格式是否正确
2. 环境变量是否正确设置
3. post-generate.sh脚本是否正常执行

### 测试失败
运行详细测试：
```bash
bash -x scripts/test-version-sync.sh
```

这将显示每个步骤的详细执行过程，帮助定位问题。