# lua-js-benchmark - Lua / JavaScript 引擎性能对比工具

## 1. 项目概述

### 1.1 目标

构建一套**自动化**、**可复现**的脚本引擎性能对比框架，让任何人 clone 本项目后能够：

1. **一键初始化**环境（自动下载源码、检查依赖、编译引擎）
2. **一键运行**全部基准测试
3. **一键生成**对比报告（表格 + 图表），以 **Lua 5.5 为基准**

为技术选型提供客观、量化的决策依据。

### 1.2 被测引擎（第一期）

| 引擎 | 版本 | 语言 | 说明 |
|------|------|------|------|
| **Lua 5.5** | 5.5.x (latest) | Lua | 官方解释器，**所有对比的基准线 (1.0x)** |
| LuaJIT | 2.1 | Lua | 带 JIT 的高性能 Lua |
| QuickJS | latest | JavaScript | 轻量级 JS 引擎 |
| V8 (JIT) | latest stable | JavaScript | d8 shell, JIT 开启 |
| V8 (no-JIT) | latest stable | JavaScript | d8 shell, `--jitless` 模式 |

### 1.3 未来扩展（第二期）

| 引擎 | 语言 | 说明 |
|------|------|------|
| Luau | Lua 方言 | Roblox 开源的 Lua 变体 |
| JavaScriptCore (JSC) | JavaScript | WebKit 的 JS 引擎 |

### 1.4 支持平台

- Linux (x86_64, aarch64)
- macOS (x86_64, Apple Silicon)

---

## 2. 项目结构

仓库中**不包含**任何引擎的源码或预构建二进制。所有引擎源码在运行 `make setup` 时自动下载并编译。

```
lua-js-benchmark/
├── README.md                     # 项目说明、快速开始
├── PROJECT_PLAN.md               # 本文档
├── Makefile                      # 顶层入口：make setup / make bench / make report
│
├── scripts/
│   ├── setup.sh                  # 环境初始化总控：检查依赖 → 下载源码 → 编译引擎
│   ├── check_deps.sh             # 检查系统依赖工具 (curl, git, gcc, make, cmake, python3...)
│   ├── detect_platform.sh        # 平台检测工具函数 (OS, arch, 包管理器)
│   ├── download_sources.sh       # 下载所有引擎源码到 .build/src/
│   ├── build_all.sh              # 编译所有引擎的总控脚本
│   ├── build_lua.sh              # 编译 Lua 5.5
│   ├── build_luajit.sh           # 编译 LuaJIT
│   ├── build_quickjs.sh          # 编译 QuickJS
│   └── build_v8.sh               # 编译 V8 (d8)
│
├── .build/                       # 构建工作目录 (git ignored)
│   ├── src/                      # 下载的源码
│   │   ├── lua-5.5.0/
│   │   ├── LuaJIT/
│   │   ├── quickjs/
│   │   └── v8/
│   └── engines/                  # 编译产物
│       ├── lua/bin/lua
│       ├── luajit/bin/luajit
│       ├── quickjs/bin/qjs
│       └── v8/bin/d8
│
├── benchmarks/                   # 基准测试用例 (仓库内维护)
│   ├── lua/                      # Lua 原生测试脚本
│   │   ├── compute/
│   │   ├── string/
│   │   ├── alloc/
│   │   ├── table/
│   │   ├── coroutine/
│   │   └── startup/
│   ├── js/                       # JavaScript 原生测试脚本
│   │   ├── compute/
│   │   ├── string/
│   │   ├── alloc/
│   │   ├── object/
│   │   ├── async/
│   │   └── startup/
│   └── README.md                 # 测试用例说明及来源
│
├── runner/
│   ├── run.sh                    # 测试运行主脚本
│   ├── measure.sh                # 单次测量包装 (时间、内存)
│   ├── config.sh                 # 运行参数配置 (迭代次数、预热等)
│   └── warmup.sh                 # 预热策略
│
├── results/                      # 原始测试结果 (git ignored)
│   └── {timestamp}/
│       ├── raw.csv               # 原始数据
│       └── system_info.txt       # 系统环境信息
│
├── report/
│   ├── generate.py               # 报告生成脚本
│   ├── templates/                # HTML 报告模板 (含内嵌 JS 图表)
│   └── charts.py                 # 图表生成 (matplotlib for Markdown; Chart.js data for HTML)
│
└── .gitignore                    # 忽略 .build/, results/
```

---

## 3. 环境初始化

### 3.1 设计原则

- **仓库零膨胀**：仓库中只包含脚本和基准测试用例，不包含任何第三方源码或二进制
- **按需下载**：运行 `make setup` 时自动下载所需的引擎源码
- **依赖前检**：在任何操作前检查系统工具是否就绪，缺失时给出明确的安装提示
- **幂等运行**：重复执行 `make setup` 不会重复下载已存在的源码

### 3.2 依赖检查 (`check_deps.sh`)

脚本启动时首先检查以下系统工具是否可用：

| 工具 | 用途 | 必需 |
|------|------|------|
| `bash` | 脚本运行环境 | 是 |
| `curl` 或 `wget` | 下载源码包 | 是 |
| `git` | 克隆 LuaJIT / QuickJS / V8 仓库 | 是 |
| `gcc` 或 `clang` | 编译 C 代码 | 是 |
| `g++` 或 `clang++` | 编译 C++ 代码 (V8) | 是 |
| `make` | 构建工具 | 是 |
| `cmake` | QuickJS 构建 (可选路径) | 否 |
| `python3` | 报告生成 | 是 |
| `pip3` / `venv` | 安装 Python 依赖 (matplotlib 等) | 是 |
| `/usr/bin/time` | 性能测量 (GNU time) | 是 |
| `ninja` | V8 构建 | 仅构建 V8 时 |

**检查失败时的行为**：

```
[ERROR] 以下必需工具未安装:
  - gcc: C 编译器
  - cmake: 构建工具

请根据您的系统安装:
  Ubuntu/Debian:  sudo apt install gcc cmake
  Fedora/RHEL:    sudo dnf install gcc cmake
  macOS:          xcode-select --install && brew install cmake
  Arch Linux:     sudo pacman -S gcc cmake
```

脚本会根据 `detect_platform.sh` 的检测结果，给出对应平台的安装命令，而**不会自动安装**——避免在用户不知情的情况下执行 sudo 操作。

### 3.3 源码下载 (`download_sources.sh`)

| 引擎 | 下载方式 | 目标目录 |
|------|---------|---------|
| Lua 5.5 | `curl` 下载 tarball 并解压 | `.build/src/lua-5.5.0/` |
| LuaJIT | `git clone --depth 1` | `.build/src/LuaJIT/` |
| QuickJS | `git clone --depth 1` | `.build/src/quickjs/` |
| V8 | `depot_tools` + `fetch v8` + `gclient sync` | `.build/src/v8/` |

每个下载步骤前检查目标目录是否已存在，已存在则跳过。V8 的下载最为耗时（约 10-30 分钟），脚本会提前提示用户预计等待时间。

### 3.4 引擎编译

编译产物统一输出到 `.build/engines/<engine>/bin/`。编译策略详见[第 5 章](#5-引擎构建方案)。

### 3.5 完整初始化流程

```
make setup
  │
  ├── check_deps.sh              # 检查 curl, git, gcc, make, python3 等
  │   └── 缺失 → 打印安装提示并退出 (不自动安装)
  │
  ├── detect_platform.sh         # 检测 OS (linux/darwin), 架构 (x86_64/arm64)
  │
  ├── download_sources.sh        # 下载源码 (已存在则跳过)
  │   ├── Lua 5.5 tarball
  │   ├── LuaJIT git clone
  │   ├── QuickJS git clone
  │   └── V8 depot_tools + fetch
  │
  └── build_all.sh               # 编译所有引擎
      ├── build_lua.sh      → .build/engines/lua/bin/lua
      ├── build_luajit.sh   → .build/engines/luajit/bin/luajit
      ├── build_quickjs.sh  → .build/engines/quickjs/bin/qjs
      └── build_v8.sh       → .build/engines/v8/bin/d8
```

---

## 4. 基准测试设计

### 4.1 测试分类

按照计算特征划分为以下类别，每个类别选取 2-4 个代表性用例：

#### 4.1.1 数值计算 (Compute)

测试纯 CPU 计算能力，包括整数和浮点运算。

| 用例 | 来源 | 说明 |
|------|------|------|
| mandelbrot | Benchmarks Game | Mandelbrot 集合计算，密集浮点运算 |
| n-body | Benchmarks Game | N 体问题模拟，浮点 + 数组访问 |
| spectral-norm | Benchmarks Game | 矩阵谱范数，循环 + 浮点 |
| fannkuch-redux | Benchmarks Game | 排列生成 + 整数计算 |

#### 4.1.2 字符串处理 (String)

测试字符串操作性能。

| 用例 | 来源 | 说明 |
|------|------|------|
| fasta | Benchmarks Game | 大量字符串生成与拼接 |
| k-nucleotide | Benchmarks Game | 子串频率统计，哈希表 + 字符串 |
| string-concat | 自编 | 循环字符串拼接，测试 GC 与 buffer 策略 |
| json-parse | 自编 | 纯脚本实现的 JSON 解析器性能 |

#### 4.1.3 内存分配与 GC (Alloc / GC)

测试垃圾回收器在高压力下的表现。

| 用例 | 来源 | 说明 |
|------|------|------|
| binary-trees | Benchmarks Game | 大量短生命周期对象分配与回收 |
| linked-list | 自编 | 链表遍历与修改，GC 压力 |
| object-churn | 自编 | 快速创建销毁对象/table |

#### 4.1.4 表/对象操作 (Table / Object)

测试核心数据结构（Lua table / JS object）的操作性能。

| 用例 | 来源 | 说明 |
|------|------|------|
| table-insert | 自编 | 大量键值插入 |
| table-lookup | 自编 | 随机键查找性能 |
| array-access | 自编 | 数组模式下的顺序/随机访问 |
| property-access | 自编 | 嵌套属性访问链 |

#### 4.1.5 函数调用与递归 (Call / Recursion)

测试函数调用开销。

| 用例 | 来源 | 说明 |
|------|------|------|
| ackermann | Benchmarks Game | 深度递归，函数调用开销 |
| fibonacci | 经典 | 递归 fibonacci（非优化版） |
| n-queens | 经典 | 回溯搜索，递归 + 数组 |

#### 4.1.6 协程 / 异步 (Coroutine / Async)

测试协作式多任务的能力（仅适用于支持该特性的引擎）。

| 用例 | 来源 | 说明 |
|------|------|------|
| producer-consumer | 自编 | 协程/generator 管道模式 |
| scheduler | 自编 | 大量协程切换 |

#### 4.1.7 启动时间 (Startup)

测试引擎冷启动性能。

| 用例 | 说明 |
|------|------|
| empty | 运行空脚本，测量纯启动开销 |
| small-init | 加载少量模块后退出 |

### 4.2 测试脚本来源

优先从以下开源仓库中选取和适配：

1. **[Lua-Benchmarks](https://github.com/gligneul/Lua-Benchmarks)** — 18 个 Lua 基准测试，覆盖计算、字符串、GC
2. **[The Computer Language Benchmarks Game](https://benchmarksgame-team.pages.debian.net/benchmarksgame/)** — 经典跨语言基准集
3. **[Octane](https://chromium.googlesource.com/v8/v8/+/refs/heads/main/test/js-perf-test/)** / **SunSpider** — V8 团队经典 JS 基准测试
4. **自编用例** — 针对特定引擎特性编写的补充测试

### 4.3 跨语言等价性

由于被测引擎分属 Lua 和 JavaScript 两个语言家族，**同一算法需提供 Lua 和 JS 两个版本**，且保证：

- **算法逻辑等价**：相同的数据结构、相同的迭代次数、相同的输出
- **惯用写法**：每个版本使用该语言的惯用写法，不刻意模仿另一种语言
- **输入参数一致**：通过命令行参数传入相同的问题规模
- **输出可校验**：每个用例输出确定性的校验值，用于验证正确性

---

## 5. 测量方案

### 5.1 采集指标

| 指标 | 采集方式 | 单位 | 说明 |
|------|---------|------|------|
| 执行时间 (wall clock) | `/usr/bin/time` 或 `time` 内置 | ms | 最核心指标 |
| 峰值内存 (Peak RSS) | Linux: `/usr/bin/time -v`; macOS: `/usr/bin/time -l` | KB | 内存占用 |
| 启动时间 | 运行空脚本的耗时 | ms | 引擎初始化开销 |
| CPU 用户态时间 | `/usr/bin/time` | ms | 排除 I/O 等待 |
| CPU 系统态时间 | `/usr/bin/time` | ms | 系统调用开销 |

### 5.2 测量策略

```
对每个 (引擎, 用例) 组合：
  1. 预热运行 W 次 (默认 W=2, 丢弃结果)
  2. 正式运行 N 次 (默认 N=5)
  3. 记录每次的所有指标
  4. 统计：中位数、平均值、标准差、最小值、最大值
  5. 校验输出正确性
```

### 5.3 环境控制

为保证结果可复现：

- 记录完整系统信息：OS 版本、内核、CPU 型号、频率、内存大小
- 记录引擎版本和编译参数
- 建议关闭 CPU 频率动态调节（提供脚本辅助设置）
- 结果按时间戳存储，便于对比不同环境/版本

---

## 6. 引擎构建方案

### 6.1 构建策略

所有引擎从源码编译，使用 Release 优化级别，确保公平对比。源码由 `download_sources.sh` 自动下载到 `.build/src/`，编译产物输出到 `.build/engines/`。

#### Lua 5.5

```bash
# download_sources.sh 已将源码下载并解压到 .build/src/lua-5.5.0/
cd .build/src/lua-5.5.0
make $(uname -s | tr A-Z a-z) MYCFLAGS="-O2"
cp src/lua ../../engines/lua/bin/
```

#### LuaJIT

```bash
# download_sources.sh 已将源码 clone 到 .build/src/LuaJIT/
cd .build/src/LuaJIT
make PREFIX=$(pwd)/../../engines/luajit XCFLAGS="-DLUAJIT_ENABLE_LUA52COMPAT"
make install PREFIX=$(pwd)/../../engines/luajit
```

#### QuickJS

```bash
# download_sources.sh 已将源码 clone 到 .build/src/quickjs/
cd .build/src/quickjs
make CONFIG_LTO=y
cp qjs ../../engines/quickjs/bin/
```

#### V8 (d8)

```bash
# download_sources.sh 已通过 depot_tools 获取 V8 源码到 .build/src/v8/
cd .build/src/v8
gn gen out/release --args='
  is_debug=false
  target_cpu="x64"
  v8_monolithic=true
  v8_enable_webassembly=false
  v8_enable_i18n_support=false
  v8_use_external_startup_data=false
  symbol_level=0
'
ninja -C out/release d8
cp out/release/d8 ../../engines/v8/bin/
# JIT vs no-JIT 通过运行时 --jitless 参数区分，无需编译两次
```

V8 精简编译参数说明：

| 参数 | 值 | 说明 |
|------|-----|------|
| `v8_enable_webassembly` | `false` | 关闭 WebAssembly，本项目仅测试 JS 性能 |
| `v8_enable_i18n_support` | `false` | 关闭 ICU 国际化支持，减少编译时间和二进制体积 |
| `v8_use_external_startup_data` | `false` | 不使用外部启动快照文件，d8 单文件即可运行 |
| `symbol_level` | `0` | 剔除调试符号，减小二进制体积 |

### 6.2 构建缓存

- 首次编译后，产物缓存在 `.build/engines/` 目录
- 重复运行 `make setup` 会跳过已完成的步骤
- 提供 `make rebuild` 强制重新编译
- 提供 `make clean` 清理 `.build/` 整个目录（源码 + 产物）

---

## 7. 运行流程

### 7.1 一键使用

```bash
# 初始化环境：检查依赖 → 下载源码 → 编译引擎
make setup

# 运行全部基准测试
make bench

# 生成对比报告 (以 Lua 5.5 为基准)
make report

# 或者一步到位 (setup + bench + report)
make all
```

### 7.2 选择性运行

```bash
# 只构建特定引擎
make setup ENGINES="lua luajit"

# 只运行特定类别的测试
make bench CATEGORY=compute

# 只测试特定引擎
make bench ENGINES="lua luajit"

# 调整迭代次数
make bench RUNS=10 WARMUP=3
```

### 7.3 运行流程图

```
make all
  │
  ├── make setup
  │   ├── check_deps.sh            # 检查 curl, git, gcc, python3...
  │   │   └── 缺失 → 打印安装提示并退出
  │   ├── detect_platform.sh       # 检测 OS、架构
  │   ├── download_sources.sh      # 下载源码 (已存在则跳过)
  │   └── build_all.sh             # 编译所有引擎
  │
  ├── make bench
  │   ├── run.sh
  │   │   ├── 记录系统信息
  │   │   ├── 对每个 (引擎, 用例):
  │   │   │   ├── warmup.sh        # 预热
  │   │   │   ├── measure.sh × N   # 测量 N 次
  │   │   │   └── 校验输出正确性
  │   │   └── 汇总至 raw.csv
  │
  └── make report
      └── generate.py
          ├── 读取 raw.csv
          ├── 以 Lua 5.5 为基准计算相对倍数
          ├── 分类统计 + 综合评分
          ├── 生成图表
          └── 输出 HTML + Markdown 报告
```

---

## 8. 报告输出

### 8.1 报告格式

生成两种格式的报告：

1. **Markdown 报告** — 可直接在 GitHub 上查看，纯文本表格
2. **HTML 报告** — 带交互式图表（Chart.js），可在浏览器中打开

### 8.2 基准线

**所有对比均以 Lua 5.5 作为基准 (1.00x)**：

- 数值 < 1.00x 表示比 Lua 5.5 更快（性能更好）
- 数值 > 1.00x 表示比 Lua 5.5 更慢（性能更差）
- 例：LuaJIT 在 mandelbrot 上为 0.07x，表示耗时仅为 Lua 5.5 的 7%

### 8.3 报告内容

#### A. 综合性能对比（最重要）

全局视角，一眼看出哪个引擎综合性能最强。

**Markdown 版 — 综合评分表**：

| 引擎 | 综合耗时 (ms) | 相对 Lua 5.5 | 综合排名 |
|------|-------------|-------------|---------|
| Lua 5.5 | 12000 | 1.00x (基准) | #4 |
| LuaJIT | 1800 | 0.15x | #2 |
| QuickJS | 15000 | 1.25x | #5 |
| V8 (JIT) | 980 | 0.08x | #1 |
| V8 (no-JIT) | 9500 | 0.79x | #3 |

综合耗时 = 所有测试用例的中位数耗时之和。

**HTML 版 — 堆叠柱状图**：

```
│                           ┌──────┐
│                    ┌──────┤string│
│             ┌──────┤string├──────┤
│      ┌──────┤string├──────┤alloc │
│      │string├──────┤alloc ├──────┤
│      ├──────┤alloc ├──────┤table │
│      │alloc ├──────┤table ├──────┤
│      ├──────┤table ├──────┤call  │
│      │table ├──────┤call  ├──────┤
│ ┌────┼──────┤call  ├──────┤compu.│
│ │comp│compu.├──────┤compu.├──────┤
└─┴────┴──────┴──────┴──────┴──────┴──
  V8JIT LuaJIT V8noJIT Lua5.5 QuickJS
```

- **X 轴**：每个被测引擎对应一根柱子
- **Y 轴**：总耗时 (ms)
- **每根柱子内部分段**：按颜色区分每个测试类别（compute / string / alloc / table / call / coroutine / startup）的耗时占比
- **柱子从低到高排序**：最矮的柱子 = 综合性能最好的引擎
- 鼠标悬停显示具体数值和相对 Lua 5.5 的倍数

#### B. 分类性能对比

每个测试类别单独分析。

**Markdown 版 — 分类汇总表**（以 Lua 5.5 为基准）：

| 类别 | Lua 5.5 | LuaJIT | QuickJS | V8 (JIT) | V8 (no-JIT) |
|------|---------|--------|---------|----------|-------------|
| compute | 1.00x | 0.07x | 0.79x | 0.04x | 0.65x |
| string | 1.00x | 0.12x | 1.10x | 0.08x | 0.85x |
| alloc | 1.00x | 0.25x | 1.35x | 0.10x | 1.20x |
| table | 1.00x | 0.15x | 0.90x | 0.06x | 0.70x |
| call | 1.00x | 0.10x | 1.20x | 0.05x | 0.95x |

**HTML 版 — 分组柱状图**：

- 每个类别一组柱状图，每组内 5 根柱子（各引擎）
- Y 轴显示相对 Lua 5.5 的倍数，Lua 5.5 处标注 1.0x 基准线

#### C. 单用例详细对比

**Markdown 版 — 全量结果表**：

| 用例 | 类别 | Lua 5.5 (ms) | LuaJIT | QuickJS | V8 (JIT) | V8 (no-JIT) |
|------|------|-------------|--------|---------|----------|-------------|
| mandelbrot | compute | 1200 | 0.07x | 0.79x | 0.04x | 0.65x |
| n-body | compute | 980 | 0.09x | 0.85x | 0.03x | 0.72x |
| binary-trees | alloc | 3500 | 0.25x | 1.35x | 0.10x | 1.20x |

- Lua 5.5 列显示绝对耗时（中位数）
- 其他引擎列显示相对 Lua 5.5 的倍数

#### D. 内存使用对比

| 用例 | Lua 5.5 (KB) | LuaJIT | QuickJS | V8 (JIT) | V8 (no-JIT) |
|------|-------------|--------|---------|----------|-------------|
| binary-trees | 25600 | 0.80x | 1.10x | 3.50x | 3.20x |

- 以 Lua 5.5 的峰值 RSS 为基准
- HTML 版提供分组柱状图

#### E. 启动时间对比

| 引擎 | 空脚本启动 (ms) | 相对 Lua 5.5 |
|------|---------------|-------------|
| Lua 5.5 | 2.1 | 1.00x |
| LuaJIT | 3.5 | 1.67x |
| QuickJS | 4.2 | 2.00x |
| V8 (JIT) | 45.0 | 21.4x |
| V8 (no-JIT) | 38.0 | 18.1x |

#### F. 雷达图（HTML 版）

- 按类别维度绘制雷达图
- 每个引擎一条折线
- 值越靠近中心性能越好（使用倒数归一化）
- 直观展示各引擎在不同维度的强项和弱项

### 8.4 HTML 报告技术方案

- 使用 **Chart.js**（CDN 引入），单文件 HTML，无需本地服务器
- 综合堆叠柱状图使用 `type: 'bar'` + `stacked: true`
- 分类对比使用 `type: 'bar'` 分组模式
- 雷达图使用 `type: 'radar'`
- 所有图表支持鼠标悬停 tooltip，显示绝对值和相对 Lua 5.5 的倍数
- `generate.py` 将统计结果注入 HTML 模板中的 `<script>` 标签作为 JSON 数据

---

## 9. 实施计划

详细的实施计划、进度跟踪和人工介入指南已提取到独立文档：

**[IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md)**

包含 6 个阶段的完整任务清单、每步的验收标准、失败场景的应对方式，以及人工介入操作指南。

---

## 10. 技术决策

### 10.1 为什么用 Shell 脚本作为主框架？

- **零依赖**：任何 Linux/macOS 系统都自带 bash
- **透明**：用户可以直接阅读和修改构建/运行流程
- **跨平台**：bash 在两个目标平台上行为一致
- 报告生成使用 Python，因为需要数据处理和图表绘制能力

### 10.2 为什么不用 Docker？

- V8 构建需要大量磁盘空间和时间，Docker 内构建体验差
- 需要测量真实的系统性能，容器会引入额外开销
- 但可以考虑提供可选的 Dockerfile 用于 CI

### 10.3 为什么仓库不包含源码和二进制？

- **体积控制**：V8 源码超过 10GB，LuaJIT/QuickJS 也有数十 MB，放入仓库会导致 clone 极慢
- **版本灵活**：脚本中配置版本号，升级只需改一行配置
- **可审计**：用户可以看到下载的是什么、从哪里下载的

### 10.4 为什么同时提供 Lua 和 JS 版本？

- Lua 引擎只能运行 Lua，JS 引擎只能运行 JS
- 同一算法的两个版本是公平对比的前提
- 每个版本使用该语言的惯用写法，而非机械翻译

### 10.5 为什么以 Lua 5.5 为基准？

- Lua 5.5 是官方标准解释器，无 JIT 优化，代表"朴素"的脚本执行性能
- 作为基准线最直观：用户可以一眼看出 LuaJIT 比标准 Lua 快多少、V8 比标准 Lua 快多少
- 所有引擎与同一个基准对比，横向比较更有意义

### 10.6 V8 JIT vs no-JIT 如何实现？

- 编译同一个 d8 二进制
- JIT 模式：直接运行 `d8 script.js`
- no-JIT 模式：运行 `d8 --jitless script.js`
- 这比编译两个不同的二进制更公平、更简单

### 10.7 综合评分如何计算？

- **方法**：将每个测试用例在各引擎上的中位数耗时求和，得到"综合耗时"
- **排名**：综合耗时最低 = 综合性能最好
- **可视化**：堆叠柱状图中每段代表一个类别的耗时，总高度即综合耗时
- **注意**：综合评分侧重计算吞吐，启动时间和内存作为独立维度单独展示，不纳入综合耗时

---

## 11. 扩展性设计

### 11.1 添加新引擎

1. 在 `scripts/` 下添加 `build_<engine>.sh`
2. 在 `scripts/download_sources.sh` 中添加下载逻辑
3. 在 `runner/config.sh` 中注册引擎名称和二进制路径
4. 如果是新语言家族，在 `benchmarks/` 下添加对应目录和测试脚本
5. 运行 `make bench` 即可自动包含新引擎

### 11.2 添加新测试用例

1. 在 `benchmarks/<lang>/<category>/` 下添加脚本
2. 确保提供所有语言版本（Lua + JS）
3. 脚本接受命令行参数控制问题规模
4. 脚本输出确定性的校验值
5. 运行 `make bench` 即可自动发现新用例

### 11.3 第二期引擎接入预估

| 引擎 | 构建复杂度 | 语言兼容性 | 预计工作量 |
|------|-----------|-----------|-----------|
| Luau | 低 (cmake) | Lua 方言，需少量适配 | 2-3 天 |
| JSC | 高 (需要 WebKit 构建系统) | JS 兼容，无需改测试 | 3-5 天 |

---

## 12. 风险与应对

| 风险 | 影响 | 应对措施 |
|------|------|---------|
| V8 构建复杂、耗时长 | 用户体验差 | 提供详细的构建文档；支持跳过 V8 单独测试其他引擎 |
| V8 源码下载极慢 (>10GB) | 初始化耗时过长 | 提前提示预计时间；支持 `ENGINES` 参数跳过 V8 |
| 跨平台兼容性问题 | 部分平台无法构建 | CI 覆盖 Linux + macOS；社区反馈修复 |
| Lua 5.5 尚未正式发布 | 版本不稳定 | 支持 Lua 5.4 作为备选；版本号可配置 |
| 测试结果受系统负载影响 | 结果不可复现 | 多次运行取中位数；记录系统负载 |
| Lua 与 JS 算法不等价 | 对比不公平 | 代码审查 checklist；输出校验 |
| 缺失系统依赖 | 无法运行 | `check_deps.sh` 在操作前检查，给出安装命令 |

---

## 13. 成功标准

- [ ] 用户 clone 后，`make setup` 自动完成依赖检查 + 源码下载 + 引擎编译
- [ ] 缺失依赖时给出清晰的、按平台区分的安装提示
- [ ] `make all` 能在 Linux 和 macOS 上端到端成功（V8 构建可选）
- [ ] 所有基准测试在所有引擎上输出一致的校验值
- [ ] 报告以 Lua 5.5 为基准，综合堆叠柱状图能一眼看出各引擎的总体性能排名
- [ ] 仓库体积小巧（不含源码/二进制），clone 在 10 秒内完成
- [ ] 新引擎和新测试用例可以在 30 分钟内完成接入
- [ ] README 文档足以让新用户在无外部帮助的情况下使用本项目
