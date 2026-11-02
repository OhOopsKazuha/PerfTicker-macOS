# 来源与致谢

## 原始项目

感谢 **[@QiuSui1145](https://github.com/QiuSui1145)**（QiuSui，QiuSui_Studio）开源 [PerfTicker](https://github.com/QiuSui1145/PerfTicker)。

本项目的证券行情终端视觉、性能指标的“个股”映射、自选列表、OHLC 主图、主力动向、逐笔事件、进程行情表及虚拟营收规则均参考该项目。参考基线为 **v1.4.0 / commit [`6a3533e8066b5bc4fbfff1569debd1bc87ce9a54`](https://github.com/QiuSui1145/PerfTicker/commit/6a3533e8066b5bc4fbfff1569debd1bc87ce9a54)**，该提交日期为 2026-11-02。

这是一份非官方 macOS 移植/重新实现，不是原作者发布的 Mac 版本。上游作者没有参与本移植开发，也未表示认可或承担维护责任。GPL 许可全文保留在 LICENSE，来源和差异见 docs/UPSTREAM.md。

## 系统技术与参考

- Apple 的 Swift、AppKit、WebKit、Mach、libproc 与 IOKit 提供本机窗口、渲染和采集能力；使用系统自带框架，不在仓库中复制分发这些框架。
- [vladkens/macmon](https://github.com/vladkens/macmon) 在可行性调研中提供了 Apple Silicon 监控的参考。本版本没有复制、集成或依赖其代码，也不使用其二进制程序。不将其列为本项目贡献者或担保方。
- 开发使用 OpenAI Codex 辅助完成代码、文档与本地验证；这不替代后续代码审查和跨设备测试。

## macOS 版本维护

由本仓库维护者 [@OhOopsKazuha](https://github.com/OhOopsKazuha) 发布与维护。欢迎实际贡献者通过 PR 参与；不预先把未参与者添加为贡献者或共同作者。

在此文档中提及原作者用于公开署名和感谢，不代表已向对方发送私信、提交 Issue 或建立合作关系。
