# PerfTicker for macOS

An unofficial Apple Silicon reimplementation of the stock-terminal-style system monitor [QiuSui1145/PerfTicker](https://github.com/QiuSui1145/PerfTicker), created by **[@QiuSui1145](https://github.com/QiuSui1145)** (QiuSui / QiuSui_Studio).

This project recreates the upstream layout, metric-to-market metaphor, interactions and virtual economy using Swift, C and local WebKit. It is independently maintained and is not endorsed by the upstream author.

## Preview status

Version 0.1.0. Build target: macOS 13+, ARM64 only. Tested locally on one M4 Pro Mac running macOS 27.2. Other OS versions and chips are not yet fully validated. Distributed builds are ad-hoc signed, not Developer ID signed or notarized.

## Features

- Live system and per-core CPU load, memory estimate, swap, disk/network throughput, and per-process CPU/RSS/thread counts.
- GPU utilization and GPU system-memory usage when the driver exposes the relevant statistics.
- OHLC candles, moving averages, watchlist, ranked processes, event tape, filtering and sorting.
- Menu-bar operation, light/dark themes, window pinning, and an experimental fully click-through desktop mode.
- An optional local virtual economy. No real earnings, mining, or trading.

CPU/GPU frequency, temperature, power, fan sensors and per-process GPU attribution are not implemented. Missing data is shown as unavailable, not fabricated.

## Build

Requires Apple Command Line Tools or Xcode and a compatible Swift compiler. The original local build used Swift 6.4 in Swift 5 language mode.

```sh
git clone https://github.com/OhOopsKazuha/PerfTicker-macOS.git
cd PerfTicker-macOS
bash Source/build.sh
open dist/PerfTicker.app
```

Prebuilt downloads, when published, are available under [Releases](https://github.com/OhOopsKazuha/PerfTicker-macOS/releases). No .NET or Node runtime is required. Closing the window keeps the app in the menu bar; press Command-Q to quit.

## Documentation and contributions

See [Chinese user guide](docs/USER_GUIDE.zh-CN.md), [metric definitions](docs/METRICS.md), [development guide](docs/DEVELOPMENT.md), [privacy](docs/PRIVACY.md), [contribution guide](CONTRIBUTING.md), and [upstream attribution](ACKNOWLEDGEMENTS.md).

No network services or telemetry are used by the app. Process names and raw samples can reveal private information; remove them from bug reports. Driver statistics, desktop mode, multi-display setups and long-running behavior need additional validation.

## Credits and license

Thanks to **@QiuSui1145** for the original project. This port was developed with OpenAI Codex assistance; local checks are documented and do not constitute a comprehensive manual audit.

GNU GPL v3.0; see [LICENSE](LICENSE) and [NOTICE](NOTICE). Upstream attribution is preserved. Contributions use the same license, without an additional CLA. This repository makes no claim to ownership of upstream names or trademarks.
