# 上游关系与移植差异

- 上游仓库：https://github.com/QiuSui1145/PerfTicker
- 原作者：@QiuSui1145 / QiuSui / QiuSui_Studio。
- 参考版本：v1.4.0；提交 6a3533e8066b5bc4fbfff1569debd1bc87ce9a54。
- 许可证：保留上游 GNU GPL v3.0 全文；本实现同样按 GPL v3.0 发布。
- 修改/重新实现日期：2026-11-02；发布维护账号：@OhOopsKazuha。

## 保留的设计与规则

证券软件式布局、指标代码和分组、涨跌呈现、OHLC 与 MA、自选/指数/排行/事件/进程表结构，以及虚拟收益的 1.7 次幂公式和基础收益/盈亏平衡参数。

## 重新实现的部分

Windows WinForms/GDI+ 界面改为 AppKit 窗口加本地 WKWebView/Canvas；Windows NTDLL/PDH/NVML 采集改为 Mach/libproc/IOKit 和网络接口字节统计。配置从 Windows JSON 文件改为本地 WebKit 存储。Windows 托盘改为 macOS 菜单栏。

没有将原仓库的 Windows C# 源文件、宣传片、录屏素材或截图复制到此仓库；原项目提交历史没有伪装成本仓库的开发历史。

## 行为差异

- CPU 逐核行显示负载，频率等未实现字段显示不可用。
- GPU 内存为驱动统计的统一内存使用，不能当作独立显存。
- 无可靠进程归因的指标不会以 CPU 排行冒充。
- 采样量柱显示点数；营收按实际时间差结算，未包含上游硬件权重和温度惩罚。
- 进程操作发送 SIGTERM，并二次确认、校验 PID/启动时间；不提权。
- 桌面模式全窗口点击穿透，需菜单栏恢复，不复刻局部点击穿透。

本仓库采用独立名称和独立维护流程。涉及 Windows 原版的问题请访问上游；本移植问题请在本仓库反馈。
