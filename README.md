# lua-js-benchmark

Lua / JavaScript 引擎性能对比工具。自动化构建、运行、生成可视化报告。

## 被测引擎

| 引擎 | 语言 | 说明 |
|------|------|------|
| Lua 5.4 | Lua | 官方解释器（基准线） |
| LuaJIT 2.1 | Lua | 带 JIT 的高性能 Lua |
| QuickJS | JavaScript | 轻量级 JS 引擎 |
| V8 (JIT) | JavaScript | Chrome 的 JS 引擎，JIT 模式 |
| V8 (no-JIT) | JavaScript | Chrome 的 JS 引擎，解释模式 |

## 快速开始

```bash
# 初始化环境（检查依赖 → 下载源码 → 编译引擎）
make setup

# 运行基准测试 + 生成报告
make bench
make report

# 或一步到位
make all
```

## 系统要求

**支持平台**: Linux (x86_64, aarch64), macOS (x86_64, Apple Silicon)

**必需工具**:
- bash, make, git
- curl 或 wget
- gcc 或 clang (C 编译器)
- python3
- /usr/bin/time (GNU time)

**可选工具** (构建 V8 时需要):
- g++ 或 clang++ (C++ 编译器)
- ninja

运行 `make setup` 时会自动检查依赖，缺失时给出安装命令。

### 各平台安装依赖

**Ubuntu / Debian**:
```bash
sudo apt update && sudo apt install -y build-essential git curl python3 python3-pip python3-venv time ninja-build
```

**Fedora / RHEL**:
```bash
sudo dnf install -y gcc gcc-c++ make git curl python3 python3-pip time ninja-build
```

**macOS**:
```bash
xcode-select --install
brew install git curl python3 ninja
```

## 选择性运行

```bash
# 只构建部分引擎（跳过 V8）
make setup ENGINES="lua luajit quickjs"

# 只测试特定类别
make bench CATEGORY=compute

# 只测试特定引擎
make bench ENGINES="lua luajit"

# 调整测试次数
make bench RUNS=10 WARMUP=3
```

## 失败恢复

单个引擎下载或编译失败不会阻止其他引擎。可单独重试：

```bash
make download-lua       # 重试下载 Lua
make download-v8        # 重试下载 V8
make build-lua          # 重试编译 Lua
make build-v8           # 重试编译 V8
```

也可手动下载源码放入 `.build/src/` 目录，再执行对应的 build 命令。

## 项目结构

```
lua-js-benchmark/
├── scripts/            # 环境初始化和引擎构建脚本
├── benchmarks/         # 基准测试用例 (Lua + JS)
├── runner/             # 测试运行框架
├── report/             # 报告生成
├── .build/             # 下载的源码和编译产物 (git ignored)
└── results/            # 测试结果 (git ignored)
```

## 文档

- [PROJECT_PLAN.md](PROJECT_PLAN.md) — 项目规划书
- [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md) — 实施计划与进度跟踪
