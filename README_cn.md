# lua-js-benchmark

[![CI](https://github.com/xjdrew/lua-js-benchmark/actions/workflows/ci.yml/badge.svg)](https://github.com/xjdrew/lua-js-benchmark/actions/workflows/ci.yml)

[English](README.md)

自动化对比 Lua 与 JavaScript 引擎的性能。从源码构建、运行标准化基准测试、生成可视化报告——一条命令搞定。

## 引擎

| 引擎 | 语言 | 说明 |
|------|------|------|
| **Lua 5.4** | Lua | PUC-Rio 官方解释器（所有对比的基准线） |
| Lua 5.5 | Lua | PUC-Rio 最新版解释器 |
| LuaJIT 2.1 | Lua | 高性能 JIT 编译的 Lua |
| QuickJS | JavaScript | 轻量级可嵌入 JS 引擎（Fabrice Bellard） |
| V8 (JIT) | JavaScript | Chrome 的 JS 引擎，开启 JIT |
| V8 (no-JIT) | JavaScript | Chrome 的 JS 引擎，仅解释器模式（`--jitless`） |

**计划中：** Luau、JavaScriptCore (JSC)

## 快速开始

```bash
git clone https://github.com/xjdrew/lua-js-benchmark.git
cd lua-js-benchmark

# 一条命令完成所有事：检查依赖 → 下载源码 → 编译 → 跑测试 → 生成报告
make all
```

或分步执行：

```bash
make setup    # 下载并编译所有引擎
make bench    # 运行基准测试（默认 5 次，2 次预热）
make report   # 生成 Markdown + HTML 报告
```

报告保存在 `results/<时间戳>/`：
- `report.md` — Markdown 表格，可在 GitHub 上直接查看
- `report.html` — 交互式图表（Chart.js），用浏览器打开即可

## 基准测试分类

| 分类 | 测试用例 | 测试内容 |
|------|---------|---------|
| **compute** | mandelbrot, n-body, spectral-norm, fannkuch-redux, matrix, sieve | CPU 密集型数值计算 |
| **string** | fasta, json-parse, string-concat | 字符串操作 |
| **alloc** | binary-trees, object-churn, gc-stress | GC 压力与内存分配 |
| **table** | table-insert, array-access, table-ops | 哈希表 / 对象属性操作 |
| **call** | ackermann, fibonacci, n-queens, method-dispatch, tak, closure | 函数调用、递归与闭包 |
| **coroutine** | scheduler | 协程 / 生成器上下文切换 |
| **startup** | empty | 引擎冷启动时间 |

每个测试用例都有 Lua 和 JavaScript 两个版本，且输出完全一致。详见 [benchmarks/README_cn.md](benchmarks/README_cn.md) 了解每个用例的来源、算法说明和编写规范。

## 系统要求

**平台：** Linux (x86_64, aarch64)、macOS (x86_64, Apple Silicon)

**必需工具：**

| 工具 | 用途 |
|------|------|
| bash (4.0+), make | 构建系统 |
| git | 克隆引擎源码 |
| curl 或 wget | 下载 Lua 压缩包 |
| gcc 或 clang | C 编译器 |
| python3 | 生成报告 |
| /usr/bin/time | 性能测量 |

**可选**（仅 V8 需要）：g++/clang++, ninja

执行 `make setup` 会自动检查依赖。缺失的工具会给出对应平台的安装命令。

<details>
<summary>各平台安装依赖</summary>

**Ubuntu / Debian：**
```bash
sudo apt update && sudo apt install -y build-essential git curl python3 python3-venv time ninja-build
```

**Fedora / RHEL：**
```bash
sudo dnf install -y gcc gcc-c++ make git curl python3 python3-pip time ninja-build
```

**Arch Linux：**
```bash
sudo pacman -S --needed base-devel git curl python python-pip time ninja
```

**macOS：**
```bash
xcode-select --install
brew install bash git curl python3 ninja
```
</details>

## 进阶用法

### 选择引擎

```bash
# 跳过 V8（避免大量下载）
make setup ENGINES="lua luajit quickjs"
make bench ENGINES="lua luajit quickjs"
```

### 选择测试分类

```bash
make bench CATEGORY=compute
make bench CATEGORY=string
```

### 调整迭代次数

```bash
make bench RUNS=10 WARMUP=3
```

### 重试下载或编译

```bash
make download-lua       # 重试 Lua 源码下载
make download-v8        # 重试 V8 源码下载
make build-lua          # 重试 Lua 编译
make build-v8           # 重试 V8 编译
```

也可以手动将源码放入 `.build/src/`，然后运行对应的编译命令。

### 清理

```bash
make clean              # 删除 .build/ 和 results/
make rebuild            # 清理后重新构建
```

## 报告

所有对比以 **Lua 5.4 为基准**（1.00x）。低于 1.00x 表示比 Lua 快，高于表示更慢。

HTML 报告包含：

- **堆叠柱状图** — 综合性能。每根柱子代表一个引擎，分段为各类别。柱子越短 = 引擎越快。
- **分类对比** — 按类别分组的柱状图，带 1.0x 基准线。
- **雷达图** — 多维度展示各引擎的优势。
- **内存使用** — 峰值 RSS 对比。
- **详细表格** — 每个测试的绝对耗时和相对倍数。

## 添加新引擎

1. 创建 `scripts/build_<engine>.sh`（下载 + 编译）
2. 在 `scripts/download_sources.sh` 中添加下载逻辑
3. 在 `runner/config.sh` 中注册：二进制路径、语言、运行参数
4. 执行 `make setup && make bench`

## 添加新测试用例

1. 将 Lua 脚本放到 `benchmarks/lua/<分类>/<名称>.lua`
2. 将 JS 脚本放到 `benchmarks/js/<JS 分类>/<名称>.js`
3. 确保两者对相同输入产生完全一致的输出
4. 生成预期输出：`lua benchmarks/lua/<分类>/<名称>.lua > benchmarks/expected/<分类>/<名称>.txt`
5. 执行 `make bench` — 新测试会被自动发现

## 项目结构

```
lua-js-benchmark/
├── Makefile                # 顶层入口
├── scripts/                # 环境初始化和引擎构建脚本
│   ├── setup.sh            # 主编排脚本
│   ├── check_deps.sh       # 依赖检查
│   ├── detect_platform.sh  # OS/架构检测
│   ├── download_sources.sh # 源码下载
│   ├── build_lua.sh        # Lua 构建脚本
│   ├── build_luajit.sh     # LuaJIT 构建脚本
│   ├── build_quickjs.sh    # QuickJS 构建脚本
│   └── build_v8.sh         # V8 构建脚本（精简版：无 wasm/ICU/调试符号）
├── benchmarks/
│   ├── lua/                # Lua 测试脚本
│   ├── js/                 # JavaScript 测试脚本
│   └── expected/           # 预期输出（正确性校验）
├── runner/
│   ├── config.sh           # 引擎注册表与参数
│   ├── measure.sh          # 单次测量封装
│   └── run.sh              # 测试运行器
├── report/
│   ├── generate.py         # 报告生成器
│   └── templates/          # HTML 模板（含 Chart.js）
├── docs/                   # 项目规划文档
├── .build/                 # 下载的源码和编译产物（git 忽略）
└── results/                # 测试结果和报告（git 忽略）
```

## 文档

- [项目规划](docs/PROJECT_PLAN.md) — 设计决策、架构和理由
- [实施计划](docs/IMPLEMENTATION_PLAN.md) — 分阶段进度追踪

## 贡献

参见 [CONTRIBUTING.md](CONTRIBUTING.md) 了解贡献指南。

## 许可证

本项目采用 MIT 许可证。详见 [LICENSE](LICENSE)。
