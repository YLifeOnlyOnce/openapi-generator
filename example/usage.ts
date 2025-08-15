import axios from 'axios';
import { createApiClient, ApiClient } from '../generated/client';

// 示例 1: 基本使用
async function basicUsage() {
  const client = createApiClient({
    basePath: 'https://api.example.com/v1'
  });

  try {
    // 获取用户列表
    const usersResponse = await client.users.getUsers();
    console.log('Users:', usersResponse.data);

    // 创建新用户
    const newUser = await client.users.createUser({
      createUserRequest: {
        email: 'test@example.com',
        name: 'Test User'
      }
    });
    console.log('Created user:', newUser.data);

    // 获取特定用户
    const user = await client.users.getUserById({ id: '123' });
    console.log('User:', user.data);

  } catch (error) {
    console.error('API Error:', error);
  }
}

// 示例 2: 使用自定义 axios 实例
async function customAxiosUsage() {
  // 创建自定义 axios 实例
  const axiosInstance = axios.create({
    timeout: 10000,
    headers: {
      'Custom-Header': 'MyApp/1.0'
    }
  });

  // 添加请求拦截器
  axiosInstance.interceptors.request.use((config) => {
    // 添加认证 token
    const token = getAuthToken(); // 假设这是获取 token 的函数
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    console.log('Request:', config.method?.toUpperCase(), config.url);
    return config;
  });

  // 添加响应拦截器
  axiosInstance.interceptors.response.use(
    (response) => {
      console.log('Response:', response.status, response.statusText);
      return response;
    },
    (error) => {
      console.error('API Error:', error.response?.status, error.response?.data);
      return Promise.reject(error);
    }
  );

  // 使用自定义 axios 实例创建客户端
  const client = createApiClient({
    basePath: 'https://api.example.com/v1',
    axiosInstance
  });

  try {
    const users = await client.users.getUsers();
    console.log('Users with custom axios:', users.data);
  } catch (error) {
    console.error('Error with custom axios:', error);
  }
}

// 示例 3: 使用 API Key 认证
async function apiKeyUsage() {
  const client = createApiClient({
    basePath: 'https://api.example.com/v1',
    apiKey: 'your-api-key-here'
  });

  try {
    const users = await client.users.getUsers();
    console.log('Users with API key:', users.data);
  } catch (error) {
    console.error('Error with API key:', error);
  }
}

// 示例 4: 动态 token
async function dynamicTokenUsage() {
  const client = createApiClient({
    basePath: 'https://api.example.com/v1',
    accessToken: () => {
      // 每次请求时动态获取 token
      return getAuthToken();
    }
  });

  try {
    const users = await client.users.getUsers();
    console.log('Users with dynamic token:', users.data);
  } catch (error) {
    console.error('Error with dynamic token:', error);
  }
}

// 模拟获取认证 token 的函数
function getAuthToken(): string {
  // 在实际应用中，这里会从存储中获取 token
  return 'your-auth-token-here';
}

// 运行示例
async function runExamples() {
  console.log('=== Basic Usage ===');
  await basicUsage();

  console.log('\n=== Custom Axios Usage ===');
  await customAxiosUsage();

  console.log('\n=== API Key Usage ===');
  await apiKeyUsage();

  console.log('\n=== Dynamic Token Usage ===');
  await dynamicTokenUsage();
}

// 导出运行函数供外部调用
export { runExamples };

export {
  basicUsage,
  customAxiosUsage,
  apiKeyUsage,
  dynamicTokenUsage
};