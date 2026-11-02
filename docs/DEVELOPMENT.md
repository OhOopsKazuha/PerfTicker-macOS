# 构建、验证与发布

## 目录

- `Source/Probe.c` / `.h`：Mach/libproc/网络计数采样。
- `Source/main.swift`：原生窗口、菜单栏、IOKit 统计、WebKit 消息桥。
- `Source/Resources/index.html`：本地行情界面、K线与虚拟经济。
- `scripts/`：构建产物检查与发布打包。
- `dist/`：本地产物，受 .gitignore 排除。

## 构建

```sh
bash Source/build.sh
bash scripts/check.sh
open dist/PerfTicker.app
```

构建脚本优先使用显式设置的 DEVELOPER_DIR，否则选择已安装的 Command Line Tools，最后回退到 xcode-select 的目录。输出 ARM64，最低目标 macOS 13，Swift 5 语言模式；无第三方包下载。

脚本会执行本地 ad-hoc 签名。它不等同于 Apple Developer ID 签名和公证，当前无分发证书配置。原始本地构建使用 Swift 6.4；CI 的结果以 Actions 页面实际记录为准。

## 检查

`bash scripts/check.sh` 检查签名、Info.plist、ARM64 架构和真实采样的数值范围。只输出摘要，不在公开构建日志打印进程名称或完整采样。

本机 GUI 冒烟检查：

```sh
PT_SCREENSHOT=/tmp/perfticker-preview.png dist/PerfTicker.app/Contents/MacOS/PerfTicker --smoke
```

它运行约 30 秒，使用非持久化存储，检查搜索、渲染、主题、K线、暂停与结算，生成真实窗口截图后退出。截图及诊断输出可能包含进程信息，应仅在本地查看。测试不终止任何用户工作进程。

CI 仅运行构建和采样检查；虚拟机可能没有 GPU 驱动统计，不据此判定 GPU 支持失败。它不证明桌面模式、传感器准确性或长期稳定性。

## 发布

1. 更新 CHANGELOG 和版本元数据，核对上游署名及功能限制。
2. 执行构建、检查、GUI 验证和 `bash scripts/package.sh`。
3. 创建与源码对应的版本标签；发布应用 ZIP、匹配的源码归档和 SHA256SUMS.txt。
4. 将版本标为 Preview/Prerelease；说明无公证及已验证环境。
5. 在发布页面提供匹配的完整源码。不得只分发二进制而遗漏对应源码。

构建不会自动创建发布或使用发布凭据。GitHub Actions 只自动构建并上传短期构建附件，不申请仓库写入权限；正式 Release 由维护者操作。
