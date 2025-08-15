import { createApiClient } from '@yaoyaoyu/og-example-api-client';

// 创建客户端实例
const client = createApiClient({
  basePath: 'https://api.example.com/v1'
});

const response = await client.users.deleteUser({id:'123'});
console.log(response)
