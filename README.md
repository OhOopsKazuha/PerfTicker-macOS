# PerfTicker for macOS

把 Mac 的系统运行状态做成证券行情终端。面向 Apple Silicon 的非官方移植预览版。

**来源：[QiuSui1145/PerfTicker](https://github.com/QiuSui1145/PerfTicker) · 原作者 [@QiuSui1145](https://github.com/QiuSui1145)（QiuSui / QiuSui_Studio） · GPL-3.0**

本项目参考原作的布局、行情映射、交互和虚拟营收规则，使用 Swift / C / WebKit 重新实现 macOS 窗口、系统采集和绘图。原作不是本项目维护者，也未表示认可或提供支持。Windows 用户请使用原仓库。

[English](README.en.md) · [使用说明](docs/USER_GUIDE.zh-CN.md) · [数据口径](docs/METRICS.md) · [来源与致谢](ACKNOWLEDGEMENTS.md) · [版本下载](https://github.com/OhOopsKazuha/PerfTicker-macOS/releases)

## 当前状态

**v0.1.0 Preview**。已在一台 M4 Pro / 12 核 / 24 GB / macOS 27.2 上运行验证。构建目标为 macOS 13+ ARM64；这不代表已经验证所有旧系统或 M 系列机型。暂无 Intel 版本。

应用尚未经过 Apple Developer ID 签名与公证。适合体验和继续开发，暂不作为专业诊断工具。

## 功能

| 模块 | 已实现 |
| --- | --- |
| 行情界面 | 指数条、自选行情、主图、主力动向、逐笔事件、进程表 |
| 实时采集 | CPU 总负载、逐核负载、内存估计、交换空间、磁盘读写、网络吞吐、进程 CPU / RSS / 线程 |
| GPU | 驱动提供字段时，读取整机占用和 GPU 使用的系统内存 |
| 图表 | 2 / 5 / 10 / 30 / 60 秒 OHLC K线、MA5/10/20、十字光标、最近一小时历史 |
| 交互 | 搜索、排序、右键置顶、复制名称、二次确认后发送进程终止请求 |
| 桌面 | 菜单栏常驻、窗口置顶、深浅主题、红涨/绿涨切换、实验性全窗口穿透桌面模式 |
| 娱乐 | 本地虚拟营收、设置保存 |

CPU/GPU 频率、温度、功耗、风扇、逐进程 GPU 尚未实现，显示“—”。逐核行显示真实负载。磁盘、网络和 GPU 缺少进程归因时不会用 CPU 排行代替。虚拟营收没有真实收益，也不代表生产效率。

## 安装与运行

1. 从 [Releases](https://github.com/OhOopsKazuha/PerfTicker-macOS/releases) 下载 ARM64 应用 ZIP。
2. 解压，将 `PerfTicker.app` 放入“应用程序”，双击运行。无需安装 .NET 或 Node。
3. 关闭窗口后仍在菜单栏运行；点击 `▥ PT` 恢复。`⌘Q` 完全退出。

如果系统阻止未公证的应用启动，请先核对下载来源；也可以按下文自行构建。不要关闭 Gatekeeper 或系统完整性保护。仓库未承诺提供签名、公证或 App Store 上架。

## 从源码构建

需要 macOS 上的 Apple Command Line Tools 或 Xcode，及支持当前源码的 Swift 工具链。实际本地构建使用 Swift 6.4 的 Swift 5 语言模式；其他工具链由 CI 和后续反馈验证。

```sh
git clone https://github.com/OhOopsKazuha/PerfTicker-macOS.git
cd PerfTicker-macOS
bash Source/build.sh
open dist/PerfTicker.app
```

输出为 `dist/PerfTicker.app`。构建产物不会提交进源码仓库。[构建、验证与发布说明](docs/DEVELOPMENT.md)。

## 快捷键

`⌘F` 搜索 · 空格暂停/继续 · `1–5` K线周期 · `E` 营收 · `T` 置顶 · `C` 红涨/绿涨 · `Esc` 关闭弹层 · `⌘Q` 退出。

## 隐私与已知限制

应用不上传数据，不依赖远端服务。采样包含进程名称、PID 和资源使用，排障时请勿直接上传原始采样文件或完整桌面截图。[隐私说明](docs/PRIVACY.md)。

GPU 统计依赖驱动字段，系统升级后可能失效；进程可见性受权限限制。CPU 与内存统计口径与活动监视器不完全相同。桌面模式、多屏、Spaces 和长时间后台运行尚未完整回归。[数据口径](docs/METRICS.md) · [验证记录](docs/TESTING.zh-CN.md)。

## 贡献、来源与许可

欢迎复现报告和小范围 PR，请先阅读 [CONTRIBUTING.md](CONTRIBUTING.md)。功能请求和 macOS 移植问题请提交到本仓库，避免给上游作者增加无关支持负担。

感谢 **@QiuSui1145** 开源原始 PerfTicker。完整来源、参考版本和移植差异见 [ACKNOWLEDGEMENTS.md](ACKNOWLEDGEMENTS.md) 与 [docs/UPSTREAM.md](docs/UPSTREAM.md)。开发过程使用 OpenAI Codex 辅助编写代码和文档；已执行的验证与仍待验证的部分分别记录，不承诺完成全面人工审计。

本仓库按 **GNU GPL v3.0** 发布，全文见 [LICENSE](LICENSE)。保留原作者署名与来源说明。贡献按同一许可提交；无额外 CLA。商标、项目名称及第三方系统组件的权利属于各自权利人。
