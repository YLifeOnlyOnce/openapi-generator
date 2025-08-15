# OpenAPI Generator Project

这个项目使用 OpenAPI Generator CLI 自动生成 TypeScript Axios API 客户端代码和 HTML 文档。当推送新的 git tag 时，CI/CD 流程会自动将生成的客户端发布到 npm。

## 项目结构

```
.
├── .github/
│   └── workflows/
│       ├── ci.yml              # CI 验证工作流
│       └── release.yml         # 发布工作流
├── generated/                  # 生成的文件（git 忽略）
│   ├── client/                # TypeScript Axios 客户端
│   └── docs/                  # HTML 文档
├── scripts/
│   ├── generate.sh            # 生成脚本
│   └── post-generate.sh       # 后处理脚本
├── spec/
│   └── example-api.yaml       # OpenAPI 规范文件
├── templates/
│   ├── client-package.json    # 客户端 package.json 模板
│   └── tsconfig.json          # TypeScript 配置模板
├── package.json               # 项目配置
├── openapitools.json          # OpenAPI Generator 配置
└── README.md
```

## 快速开始

### 1. 安装依赖

```bash
npm install
```

### 2. 生成客户端和文档

```bash
# 确保使用 Node.js 20
nvm use 20

# 生成客户端和文档
./scripts/generate.sh
```

### 3. 查看生成的文件

- **API 客户端**: `generated/client/`
- **API 文档**: `generated/docs/index.html`

## 发布流程

### 自动发布（推荐）

1. 确保你的更改已经合并到主分支
2. 创建并推送新的版本标签：

```bash
# 创建新版本标签
git tag v1.0.0
git push origin v1.0.0
```

3. GitHub Actions 会自动：
   - 生成 API 客户端和文档
   - 构建 TypeScript 代码
   - 发布到 npm
   - 创建 GitHub Release

### 手动发布

```bash
# 生成代码
./scripts/generate.sh
./scripts/post-generate.sh

# 进入客户端目录
cd generated/client

# 设置版本号
npm version 1.0.0 --no-git-tag-version

# 构建
npm run build

# 发布到 npm
npm publish --access public
```

## 配置说明

### 1. OpenAPI 规范

编辑 `spec/example-api.yaml` 文件来定义你的 API。

### 2. 客户端配置

在 `templates/client-package.json` 中配置：
- 包名称
- 描述
- 作者信息
- 仓库地址

### 3. 生成器配置

在 `openapitools.json` 中配置：
- 生成器版本
- 输出目录
- 额外属性

## 客户端使用方法

生成的客户端支持外部提供 axios 实例，这样消费方可以自定义请求配置：

```typescript
import axios from 'axios';
import { createApiClient } from 'example-api-client';

// 创建自定义 axios 实例
const axiosInstance = axios.create({
  timeout: 10000,
  headers: {
    'Authorization': 'Bearer your-token'
  }
});

// 使用自定义 axios 实例创建客户端
const client = createApiClient({
  basePath: 'https://api.example.com/v1',
  axiosInstance
});

// 使用 API
const users = await client.users.getUsers();
```

## CI/CD 配置

### 必需的 GitHub Secrets

在 GitHub 仓库设置中添加以下 secrets：

- `NPM_TOKEN`: npm 发布令牌
- `GITHUB_TOKEN`: GitHub 访问令牌（自动提供）

### 获取 NPM Token

1. 登录 [npmjs.com](https://www.npmjs.com/)
2. 进入 Access Tokens 页面
3. 创建新的 Automation token
4. 将 token 添加到 GitHub Secrets

## 开发指南

### 修改 API 规范

1. 编辑 `spec/example-api.yaml`
2. 运行 `./scripts/generate.sh` 验证更改
3. 提交更改并推送

### 自定义生成的代码

1. 修改 `scripts/post-generate.sh` 脚本
2. 更新 `templates/` 目录中的模板文件
3. 测试生成过程

### 添加新的 API 端点

1. 在 `spec/example-api.yaml` 中添加新的路径和操作
2. 重新生成客户端
3. 更新客户端的 `index.ts` 文件（如果需要）

## 故障排除

### 生成失败

1. 检查 OpenAPI 规范是否有效：
   ```bash
   npx @apidevtools/swagger-parser validate spec/example-api.yaml
   ```

2. 检查 Node.js 版本：
   ```bash
   node --version  # 应该是 v20.x.x
   ```

### 发布失败

1. 检查 npm token 是否有效
2. 确保包名称在 npm 上可用
3. 检查版本号格式是否正确

### 权限问题

```bash
# 确保脚本有执行权限
chmod +x scripts/*.sh
```

## 许可证

MIT License