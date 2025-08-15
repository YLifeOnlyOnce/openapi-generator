# 部署指南

本文档详细说明如何配置和使用 CI/CD 流程来自动发布 API 客户端到 npm。

## 前置条件

1. **GitHub 仓库**: 项目需要托管在 GitHub 上
2. **npm 账户**: 需要有 npm 账户来发布包
3. **Java 环境**: 确保运行环境有 Java 8+ 用于运行 OpenAPI Generator

## 配置步骤

### 1. 获取 npm 访问令牌

1. 登录 [npmjs.com](https://www.npmjs.com/)
2. 点击头像 → "Access Tokens"
3. 点击 "Generate New Token"
4. 选择 "Automation" 类型
5. 复制生成的令牌

### 2. 配置 GitHub Secrets

在 GitHub 仓库中配置以下 Secrets：

1. 进入仓库设置页面
2. 点击 "Secrets and variables" → "Actions"
3. 添加以下 Secret：
   - **Name**: `NPM_TOKEN`
   - **Value**: 从步骤 1 获取的 npm 令牌

### 3. 更新包配置

编辑 `templates/client-package.json` 文件，更新以下字段：

```json
{
  "name": "your-api-client-name",
  "author": "Your Name <your.email@example.com>",
  "repository": {
    "type": "git",
    "url": "https://github.com/your-username/your-repo.git"
  },
  "bugs": {
    "url": "https://github.com/your-username/your-repo/issues"
  },
  "homepage": "https://github.com/your-username/your-repo#readme"
}
```

### 4. 验证包名可用性

在发布前，确保包名在 npm 上可用：

```bash
npm view your-api-client-name
```

如果返回 404 错误，说明包名可用。

## 发布流程

### 自动发布（推荐）

1. **准备发布**:
   ```bash
   # 确保所有更改已提交
   git add .
   git commit -m "feat: update API specification"
   git push origin main
   ```

2. **创建版本标签**:
   ```bash
   # 创建新版本标签（遵循语义化版本）
   git tag v1.0.0
   git push origin v1.0.0
   ```

3. **监控发布过程**:
   - 进入 GitHub 仓库的 "Actions" 页面
   - 查看 "Release API Client" 工作流的执行状态
   - 发布成功后，包将自动发布到 npm

### 手动发布

如果需要手动发布：

```bash
# 1. 生成客户端代码
./scripts/generate.sh
./scripts/post-generate.sh

# 2. 进入客户端目录
cd generated/client

# 3. 设置版本号
npm version 1.0.0 --no-git-tag-version

# 4. 构建
npm run build

# 5. 发布到 npm
npm publish --access public
```

## 版本管理

### 语义化版本

遵循 [语义化版本](https://semver.org/lang/zh-CN/) 规范：

- **主版本号 (MAJOR)**: 不兼容的 API 修改
- **次版本号 (MINOR)**: 向下兼容的功能性新增
- **修订号 (PATCH)**: 向下兼容的问题修正

### 版本标签格式

使用 `v` 前缀的标签格式：
- `v1.0.0` - 主要版本
- `v1.1.0` - 次要版本
- `v1.0.1` - 补丁版本
- `v2.0.0-beta.1` - 预发布版本

## 故障排除

### 常见问题

#### 1. npm 发布失败

**错误**: `403 Forbidden`

**解决方案**:
- 检查 npm token 是否正确配置
- 确保 token 有发布权限
- 验证包名是否已被占用

#### 2. 构建失败

**错误**: TypeScript 编译错误

**解决方案**:
- 检查 OpenAPI 规范是否有效
- 验证生成的代码是否正确
- 查看 CI 日志获取详细错误信息

#### 3. 工作流权限错误

**错误**: `GITHUB_TOKEN` 权限不足

**解决方案**:
- 确保仓库设置中启用了 Actions 权限
- 检查工作流文件中的权限配置

### 调试步骤

1. **本地测试**:
   ```bash
   # 验证 OpenAPI 规范
   ./scripts/validate.sh
   
   # 本地生成测试
   ./scripts/generate.sh
   ./scripts/post-generate.sh
   ```

2. **检查 CI 日志**:
   - 进入 GitHub Actions 页面
   - 查看失败的工作流详细日志
   - 根据错误信息进行修复

3. **验证生成的包**:
   ```bash
   cd generated/client
   npm pack
   # 检查生成的 .tgz 文件内容
   ```

## 最佳实践

### 1. API 规范管理

- 使用版本控制管理 OpenAPI 规范文件
- 在修改 API 规范前进行验证
- 保持 API 规范的向下兼容性

### 2. 发布策略

- 使用分支保护规则
- 在发布前进行代码审查
- 使用预发布版本进行测试

### 3. 监控和维护

- 定期检查依赖更新
- 监控包的下载量和使用情况
- 及时响应用户反馈和问题

## 安全注意事项

1. **保护敏感信息**:
   - 不要在代码中硬编码 API 密钥
   - 使用 GitHub Secrets 存储敏感信息
   - 定期轮换访问令牌

2. **权限管理**:
   - 使用最小权限原则
   - 定期审查访问权限
   - 启用双因素认证

3. **依赖安全**:
   - 定期更新依赖包
   - 使用 `npm audit` 检查安全漏洞
   - 配置自动安全更新

## 支持和帮助

如果遇到问题，可以：

1. 查看项目的 [README.md](../README.md)
2. 检查 [GitHub Issues](https://github.com/your-username/your-repo/issues)
3. 参考 [OpenAPI Generator 文档](https://openapi-generator.tech/docs/)
4. 联系项目维护者