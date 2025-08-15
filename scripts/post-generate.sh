#!/bin/bash

# 设置错误时退出
set -e

echo "🔧 Starting post-generation processing..."

# 获取包名（从模板文件或生成的package.json中获取）
if [ -f "templates/client-package.json" ]; then
  PACKAGE_NAME=$(node -p "require('./templates/client-package.json').name")
elif [ -f "generated/client/package.json" ]; then
  PACKAGE_NAME=$(node -p "require('./generated/client/package.json').name")
else
  PACKAGE_NAME="example-api-client"
fi

echo "📦 Package name: $PACKAGE_NAME"

# 检查生成的客户端目录是否存在
if [ ! -d "generated/client" ]; then
    echo "❌ Generated client directory not found!"
    exit 1
fi

cd generated/client

# 备份原始的 package.json（如果存在）
if [ -f "package.json" ]; then
    echo "📦 Backing up original package.json..."
    mv package.json package.json.bak
fi

# 复制自定义的 package.json
echo "📋 Copying custom package.json..."
cp ../../templates/client-package.json package.json

# 更新版本号（如果提供了环境变量）
if [ ! -z "$npm_package_version" ]; then
    echo "🔢 Updating package version to $npm_package_version..."
    # 使用 sed 更新版本号
    sed -i.bak "s/\"version\": \"[^\"]*\"/\"version\": \"$npm_package_version\"/" package.json
    rm package.json.bak
fi

# 复制 TypeScript 配置
echo "⚙️ Copying TypeScript configuration..."
cp ../../templates/tsconfig.json tsconfig.json

# 创建自定义的 index.ts 文件，支持外部 axios 实例
echo "📝 Creating custom index.ts..."
cat > index.ts << 'EOF'
// 导出所有生成的 API 和类型
export * from './api';
export * from './base';
export * from './common';
export * from './configuration';

// 导入必要的类型和类
import { Configuration } from './configuration';
import { AxiosInstance } from 'axios';

// 导入所有 API 类
import {
  DefaultApi,
} from './api';

/**
 * API 客户端工厂函数
 * 允许消费方提供自己的 axios 实例
 */
export interface ApiClientOptions {
  basePath?: string;
  axiosInstance?: AxiosInstance;
  accessToken?: string | (() => string);
  username?: string;
  password?: string;
  apiKey?: string | (() => string);
}

export class ApiClient {
  private configuration: Configuration;
  
  // API 实例
  public readonly users: DefaultApi;

  constructor(options: ApiClientOptions = {}) {
    this.configuration = new Configuration({
      basePath: options.basePath,
      accessToken: options.accessToken,
      username: options.username,
      password: options.password,
      apiKey: options.apiKey,
    });

    // 初始化所有 API 实例
    this.users = new DefaultApi(this.configuration, undefined, options.axiosInstance);
  }

  /**
   * 更新配置
   */
  updateConfiguration(newConfig: Partial<ApiClientOptions>) {
    this.configuration = new Configuration({
      ...this.configuration,
      ...newConfig,
    });
  }
}

/**
 * 创建 API 客户端实例的便捷函数
 */
export function createApiClient(options: ApiClientOptions = {}): ApiClient {
  return new ApiClient(options);
}

// 默认导出
export default ApiClient;
EOF

# 创建 README.md
echo "📖 Creating README.md..."
cat > README.md << 'EOF'
# Example API Client

TypeScript/JavaScript client library for Example API, generated from OpenAPI specification.

## Installation

```bash
npm install PACKAGE_NAME_PLACEHOLDER
```

## Usage

### Basic Usage

```typescript
import { createApiClient } from 'PACKAGE_NAME_PLACEHOLDER';

// 创建客户端实例
const client = createApiClient({
  basePath: 'https://api.example.com/v1'
});

// 使用 API
async function getUsers() {
  try {
    const response = await client.users.getUsers();
    console.log(response.data);
  } catch (error) {
    console.error('Error fetching users:', error);
  }
}
```

### Using Custom Axios Instance

```typescript
import axios from 'axios';
import { createApiClient } from 'PACKAGE_NAME_PLACEHOLDER';

// 创建自定义 axios 实例
const axiosInstance = axios.create({
  timeout: 10000,
  headers: {
    'Custom-Header': 'value'
  }
});

// 添加请求拦截器
axiosInstance.interceptors.request.use((config) => {
  // 添加认证 token
  config.headers.Authorization = `Bearer ${getAuthToken()}`;
  return config;
});

// 添加响应拦截器
axiosInstance.interceptors.response.use(
  (response) => response,
  (error) => {
    // 处理错误
    console.error('API Error:', error);
    return Promise.reject(error);
  }
);

// 使用自定义 axios 实例创建客户端
const client = createApiClient({
  basePath: 'https://api.example.com/v1',
  axiosInstance
});
```

### Authentication

```typescript
// API Key 认证
const client = createApiClient({
  basePath: 'https://api.example.com/v1',
  apiKey: 'your-api-key'
});

// Bearer Token 认证
const client = createApiClient({
  basePath: 'https://api.example.com/v1',
  accessToken: 'your-access-token'
});

// 动态 Token
const client = createApiClient({
  basePath: 'https://api.example.com/v1',
  accessToken: () => getAuthToken()
});
```

## API Reference

### Users API

- `getUsers(params?)` - Get all users
- `createUser(data)` - Create a new user
- `getUserById(id)` - Get user by ID
- `updateUser(id, data)` - Update user
- `deleteUser(id)` - Delete user

## Types

All TypeScript types are exported from the main module:

```typescript
import { User, CreateUserRequest, UpdateUserRequest } from 'PACKAGE_NAME_PLACEHOLDER';
```

## Error Handling

```typescript
import { AxiosError } from 'axios';

try {
  const response = await client.users.getUsers();
} catch (error) {
  if (error instanceof AxiosError) {
    console.error('HTTP Error:', error.response?.status, error.response?.data);
  } else {
    console.error('Unknown Error:', error);
  }
}
```

## License

MIT
EOF

# 替换README中的包名占位符
echo "🔄 Updating package name in README..."
# 转义包名中的特殊字符
ESCAPED_PACKAGE_NAME=$(echo "$PACKAGE_NAME" | sed 's/[[\/.*^$()+?{|]/\\&/g')
sed -i.bak "s/PACKAGE_NAME_PLACEHOLDER/$ESCAPED_PACKAGE_NAME/g" README.md
rm -f README.md.bak

echo "✅ Post-generation processing completed!"

# 返回根目录
cd ../..