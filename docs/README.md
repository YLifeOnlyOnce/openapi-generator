# API Documentation

本目录包含自动生成的 API 文档相关文件。

## GitHub Pages 设置

为了让用户能够在线查看 API 文档，需要启用 GitHub Pages：

### 1. 启用 GitHub Pages

1. 进入 GitHub 仓库设置页面
2. 滚动到 "Pages" 部分
3. 在 "Source" 下选择 "GitHub Actions"
4. 保存设置

### 2. 权限设置

确保 GitHub Actions 有足够的权限：

1. 进入仓库设置 → Actions → General
2. 在 "Workflow permissions" 部分选择 "Read and write permissions"
3. 勾选 "Allow GitHub Actions to create and approve pull requests"
4. 保存设置

## 文档访问

启用 GitHub Pages 后，API 文档将在以下地址可用：

- **主页**: `https://{username}.github.io/{repository-name}/`
- **最新文档**: `https://{username}.github.io/{repository-name}/api-docs/latest/`
- **版本文档**: `https://{username}.github.io/{repository-name}/api-docs/{version}/`

## 自动化流程

每次创建新的 release 标签时：

1. **生成文档**: 使用 OpenAPI Generator 生成 HTML 文档
2. **部署到 Pages**: 自动部署到 GitHub Pages
3. **版本管理**: 
   - 在 `api-docs/{version}/` 保存特定版本的文档
   - 在 `api-docs/latest/` 更新最新版本的文档
4. **保留历史**: 之前版本的文档会被保留，用户可以查看历史版本

## 文件结构

```
docs/
├── index.html          # 主页面，提供文档导航
├── README.md          # 本说明文件
└── (GitHub Pages 部署后)
    └── api-docs/
        ├── latest/    # 最新版本文档
        ├── 1.0.8/     # 版本 1.0.8 文档
        ├── 1.0.7/     # 版本 1.0.7 文档
        └── ...
```

## 自定义

如需自定义文档样式或内容：

1. 修改 `index.html` 来更改主页面
2. 修改 `.github/workflows/release.yml` 来调整部署流程
3. 修改 `scripts/generate.sh` 来自定义文档生成过程

## 故障排除

### GitHub Pages 未启用
- 检查仓库设置中的 Pages 配置
- 确保选择了 "GitHub Actions" 作为源

### 文档未更新
- 检查 GitHub Actions 的执行日志
- 确保 release workflow 成功完成
- 检查 `gh-pages` 分支是否存在且有内容

### 权限错误
- 确保 Actions 有 "Read and write permissions"
- 检查 `GITHUB_TOKEN` 是否有足够权限

## 手动部署

如需手动触发文档部署，可以在 Actions 页面运行 "Deploy GitHub Pages" workflow。