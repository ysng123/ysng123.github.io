# 本地运行（Windows）

在项目根目录打开 PowerShell：

```powershell
powershell -ExecutionPolicy Bypass -File .\start-local.ps1
```

打开 <http://127.0.0.1:4000>。修改页面后 Jekyll 会自动重新构建，刷新浏览器查看结果。按 Ctrl+C 停止服务。

端口被占用时可以指定 `-Port 4001`。只构建、不启动服务：

```powershell
powershell -ExecutionPolicy Bypass -File .\start-local.ps1 -BuildOnly
```

本地环境使用 `.local` 中的便携版 Ruby 和依赖，`Gemfile.local` 单独声明本地 Jekyll 依赖。根目录的 `Gemfile` 和 `Gemfile.lock` 仍用于原有 GitHub Pages 环境。本地构建输出到 `_site`，运行环境和构建产物不会提交到 Git。为兼容中文目录，脚本会自动分配一个临时盘符，并在正常退出时清理映射。

首次访问默认英文；导航栏可切换中文，浏览器会保存选择。需要重新验证首次访问时，可在浏览器控制台运行 `localStorage.removeItem('profile-language')` 后刷新。

## 重建依赖

将 [官方 RubyInstaller 3.3.12-1 x64 便携版](https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.3.12-1/rubyinstaller-3.3.12-1-x64.7z)解压到 `.local/rubyinstaller-3.3.12-1-x64`。Windows 原生依赖需要 [MSYS2](https://www.msys2.org/docs/installer/) 和 UCRT64 编译工具，放在 `.local/msys64`。在 MSYS2 中安装 `mingw-w64-ucrt-x86_64-gcc` 和 `make` 后，运行：

```powershell
powershell -ExecutionPolicy Bypass -File .\start-local.ps1 -Install -BuildOnly
```
