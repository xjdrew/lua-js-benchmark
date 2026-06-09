# lua-js-benchmark 实施计划

> 从 [PROJECT_PLAN.md](PROJECT_PLAN.md) 中提取，便于逐步执行和跟踪进度。

## 进度总览

| 阶段 | 描述 | 状态 |
|------|------|------|
| Phase 1 | 项目骨架与环境初始化 | **已完成** |
| Phase 2 | 源码下载与引擎构建 | **已完成** (V8 脚本已写好，未实际测试编译) |
| Phase 3 | 测试框架与首批用例 | 未开始 |
| Phase 4 | 完整用例集 | 未开始 |
| Phase 5 | 报告生成 | 未开始 |
| Phase 6 | 打磨与文档 | 未开始 |

---

## Phase 1: 项目骨架与环境初始化

**目标**：搭建项目结构，完成依赖检查和平台检测。

### 1.1 初始化项目结构

- [x] 创建目录结构（scripts/, benchmarks/, runner/, report/, .gitignore 等）
- [x] 编写顶层 Makefile（定义 setup / bench / report / all / clean 等目标）
- [x] 配置 .gitignore（忽略 .build/, results/）

### 1.2 平台检测 `scripts/detect_platform.sh`

- [x] 检测操作系统（linux / darwin）
- [x] 检测 CPU 架构（x86_64 / arm64）
- [x] 检测包管理器（apt / dnf / pacman / brew）
- [x] 导出环境变量供后续脚本使用

### 1.3 依赖检查 `scripts/check_deps.sh`

- [x] 逐项检查必需工具：bash, curl/wget, git, gcc/clang, g++/clang++, make, python3, /usr/bin/time
- [x] 逐项检查可选工具：cmake, ninja（仅构建 V8 时必需）
- [x] 检查失败时，根据检测到的包管理器给出对应的安装命令
- [x] 返回非零退出码以阻止后续步骤

### 1.4 README.md

- [x] 编写项目简介、快速开始（make setup && make all）
- [x] 列出系统要求和支持平台

**Phase 1 验收**：在一台干净的 Linux 或 macOS 上执行 `make setup`，能正确检测平台并报告缺失依赖。

---

## Phase 2: 源码下载与引擎构建

**目标**：实现所有引擎的自动下载和编译。

> **注意**：本阶段涉及大量网络下载和编译操作，V8 尤其耗时（源码 >10GB，编译 30-60 分钟）。
> 每个步骤设计为**可独立重试**，失败后可手动干预再继续。

### 2.1 源码下载 `scripts/download_sources.sh`

每个引擎的下载是独立的，支持单独重试。脚本在每个引擎下载前检查目标目录是否已存在，已存在则跳过。

#### 2.1.1 下载 Lua 5.5

- [ ] 从 lua.org 下载 tarball 并解压到 `.build/src/lua-5.5.0/`
- [ ] 校验解压后的目录结构

**失败应对**：网络问题导致下载中断 → 删除不完整的 tarball，重新执行 `make setup ENGINES=lua` 或手动下载 tarball 放入 `.build/src/`。

#### 2.1.2 下载 LuaJIT

- [ ] `git clone --depth 1` 到 `.build/src/LuaJIT/`

**失败应对**：clone 中断 → 删除 `.build/src/LuaJIT/` 目录后重试。

#### 2.1.3 下载 QuickJS

- [ ] `git clone --depth 1` 到 `.build/src/quickjs/`

**失败应对**：同 LuaJIT。

#### 2.1.4 下载 V8

- [ ] 克隆 depot_tools 到 `.build/src/depot_tools/`
- [ ] 通过 `fetch v8` 获取 V8 源码到 `.build/src/v8/`
- [ ] 执行 `gclient sync`

**失败应对**：这是最容易失败的步骤（网络、磁盘空间、depot_tools 兼容性）。

| 失败场景 | 人工介入方式 |
|---------|------------|
| 网络超时 / 中断 | 重新执行 `make download-v8`，gclient sync 支持断点续传 |
| 磁盘空间不足 (需 >15GB) | 清理磁盘后重试；或跳过 V8：`make setup ENGINES="lua luajit quickjs"` |
| depot_tools 版本不兼容 | 手动更新 depot_tools：`cd .build/src/depot_tools && git pull` |
| 用户所在网络无法访问 chromium 仓库 | 用户手动通过代理下载 V8 源码，放入 `.build/src/v8/`，再执行 `make build-v8` |

### 2.2 引擎编译

每个引擎的编译脚本独立，支持单独执行和重试。

#### 2.2.1 编译 Lua 5.5 `scripts/build_lua.sh`

- [ ] 检测平台，选择 `make linux` 或 `make macosx`
- [ ] 使用 `MYCFLAGS="-O2"` 编译
- [ ] 将 `lua` 二进制复制到 `.build/engines/lua/bin/`
- [ ] 验证：`.build/engines/lua/bin/lua -v` 输出版本号

**预计耗时**：< 1 分钟。几乎不会失败。

#### 2.2.2 编译 LuaJIT `scripts/build_luajit.sh`

- [ ] 编译（macOS arm64 需设置 `MACOSX_DEPLOYMENT_TARGET=11.0`）
- [ ] 安装到 `.build/engines/luajit/`
- [ ] 验证：`.build/engines/luajit/bin/luajit -v` 输出版本号

**预计耗时**：< 1 分钟。

**失败应对**：macOS 上如果缺少 Xcode command line tools → 提示 `xcode-select --install`。

#### 2.2.3 编译 QuickJS `scripts/build_quickjs.sh`

- [ ] `make CONFIG_LTO=y` 编译
- [ ] 将 `qjs` 二进制复制到 `.build/engines/quickjs/bin/`
- [ ] 验证：`.build/engines/quickjs/bin/qjs --help` 正常输出

**预计耗时**：< 1 分钟。

#### 2.2.4 编译 V8 `scripts/build_v8.sh`

- [ ] 根据平台设置 `target_cpu`（x64 / arm64）
- [ ] 使用精简参数执行 `gn gen`（关闭 wasm、ICU、外部启动数据、调试符号）
- [ ] 执行 `ninja -C out/release d8`
- [ ] 将 `d8` 二进制复制到 `.build/engines/v8/bin/`
- [ ] 验证：`.build/engines/v8/bin/d8 --version` 输出版本号

**预计耗时**：30-60 分钟（首次编译）。

**失败应对**：

| 失败场景 | 人工介入方式 |
|---------|------------|
| gn 或 ninja 未找到 | 确认 depot_tools 在 PATH 中：`export PATH=.build/src/depot_tools:$PATH` |
| 编译内存不足 (OOM) | 限制并行度：`ninja -C out/release -j4 d8` 或 `-j2` |
| C++ 编译错误 | 检查 clang/gcc 版本是否满足 V8 要求 (通常需要较新版本) |
| 用户放弃编译 V8 | `make setup ENGINES="lua luajit quickjs"` 跳过 V8，其余引擎照常测试 |

### 2.3 构建总控 `scripts/build_all.sh` + `scripts/setup.sh`

- [ ] `setup.sh` 串联：check_deps → detect_platform → download_sources → build_all
- [ ] `build_all.sh` 遍历引擎列表，逐个调用 build 脚本
- [ ] 每个引擎编译前检查产物是否已存在，已存在则跳过
- [ ] 编译失败时记录失败引擎，继续编译其他引擎，最后汇总报告
- [ ] 支持 `ENGINES` 参数过滤

**Phase 2 验收**：

- [ ] Linux 上 `make setup` 成功构建全部 5 个引擎（含 V8）
- [ ] macOS 上 `make setup` 成功构建全部 5 个引擎（含 V8）
- [ ] `make setup ENGINES="lua luajit quickjs"` 仅构建指定引擎
- [ ] 重复执行 `make setup` 跳过已完成步骤，秒级完成

---

## Phase 3: 测试框架与首批用例

**目标**：完成测量框架，移植首批基准测试用例。

### 3.1 运行参数配置 `runner/config.sh`

- [ ] 定义默认参数（RUNS=5, WARMUP=2）
- [ ] 定义引擎注册表（名称、二进制路径、运行命令模板）
- [ ] 定义测试用例发现规则（自动扫描 benchmarks/ 目录）
- [ ] 支持环境变量覆盖

### 3.2 单次测量 `runner/measure.sh`

- [ ] 封装 `/usr/bin/time` 调用（兼容 Linux GNU time 和 macOS BSD time）
- [ ] 采集：wall clock、user time、sys time、peak RSS
- [ ] 捕获被测脚本的 stdout 用于正确性校验
- [ ] 输出结构化结果（CSV 行）

### 3.3 测试运行主脚本 `runner/run.sh`

- [ ] 记录系统信息到 `results/{timestamp}/system_info.txt`
- [ ] 遍历 (引擎, 用例) 组合
- [ ] 对每个组合执行预热 + N 次测量
- [ ] 校验每次运行的输出与期望值一致
- [ ] 汇总结果到 `results/{timestamp}/raw.csv`
- [ ] 支持 ENGINES / CATEGORY 过滤参数

### 3.4 首批 compute 类测试用例

每个用例需同时提供 Lua 和 JS 版本。

- [ ] `mandelbrot` — 密集浮点运算
  - [ ] Lua 版本 (`benchmarks/lua/compute/mandelbrot.lua`)
  - [ ] JS 版本 (`benchmarks/js/compute/mandelbrot.js`)
  - [ ] 验证两版本输出一致
- [ ] `n-body` — N 体问题模拟
  - [ ] Lua 版本
  - [ ] JS 版本
  - [ ] 验证输出一致
- [ ] `spectral-norm` — 矩阵谱范数
  - [ ] Lua 版本
  - [ ] JS 版本
  - [ ] 验证输出一致
- [ ] `fannkuch-redux` — 排列生成 + 整数计算
  - [ ] Lua 版本
  - [ ] JS 版本
  - [ ] 验证输出一致

**Phase 3 验收**：`make bench CATEGORY=compute` 成功在所有引擎上运行 4 个 compute 用例，输出 raw.csv。

---

## Phase 4: 完整用例集

**目标**：补齐所有类别的基准测试用例。

### 4.1 字符串处理 (String)

- [ ] `fasta` — Lua + JS 版本
- [ ] `k-nucleotide` — Lua + JS 版本
- [ ] `string-concat` — Lua + JS 版本
- [ ] `json-parse` — Lua + JS 版本

### 4.2 内存分配与 GC (Alloc)

- [ ] `binary-trees` — Lua + JS 版本
- [ ] `linked-list` — Lua + JS 版本
- [ ] `object-churn` — Lua + JS 版本

### 4.3 表/对象操作 (Table / Object)

- [ ] `table-insert` — Lua + JS 版本
- [ ] `table-lookup` — Lua + JS 版本
- [ ] `array-access` — Lua + JS 版本
- [ ] `property-access` — Lua + JS 版本

### 4.4 函数调用与递归 (Call)

- [ ] `ackermann` — Lua + JS 版本
- [ ] `fibonacci` — Lua + JS 版本
- [ ] `n-queens` — Lua + JS 版本

### 4.5 协程 / 异步 (Coroutine / Async)

- [ ] `producer-consumer` — Lua (coroutine) + JS (generator) 版本
- [ ] `scheduler` — Lua (coroutine) + JS (generator) 版本
- [ ] 标记不支持该特性的引擎，运行时自动跳过

### 4.6 启动时间 (Startup)

- [ ] `empty` — 空脚本 (Lua + JS)
- [ ] `small-init` — 少量模块加载 (Lua + JS)

### 4.7 全量验证

- [ ] 所有用例在所有引擎上的输出正确性校验通过
- [ ] `make bench` 全量运行成功

**Phase 4 验收**：`make bench` 运行全部 ~20 个用例 × 5 个引擎，raw.csv 数据完整。

---

## Phase 5: 报告生成

**目标**：自动化生成可视化报告，以 Lua 5.5 为基准。

### 5.1 数据处理 `report/generate.py`

- [ ] 读取 raw.csv
- [ ] 以 Lua 5.5 的中位数耗时为基准 (1.00x)，计算其他引擎的相对倍数
- [ ] 按类别汇总各引擎的耗时
- [ ] 计算综合耗时（所有用例的中位数耗时之和）和综合排名

### 5.2 Markdown 报告

- [ ] 综合评分表（综合耗时、相对 Lua 5.5 倍数、排名）
- [ ] 分类汇总表（每类的相对倍数）
- [ ] 单用例详细表（Lua 5.5 绝对值 + 其他引擎相对倍数）
- [ ] 内存使用对比表
- [ ] 启动时间对比表

### 5.3 HTML 报告

- [ ] 单文件 HTML（Chart.js 通过 CDN 引入，无需本地服务器）
- [ ] **综合堆叠柱状图**
  - [ ] X 轴：各引擎，按总耗时从低到高排序
  - [ ] Y 轴：总耗时 (ms)
  - [ ] 每根柱子内部分段：按颜色区分各测试类别的耗时
  - [ ] tooltip：悬停显示该类别的绝对耗时和相对 Lua 5.5 的倍数
- [ ] **分类分组柱状图**
  - [ ] 每个类别一组，组内每引擎一根柱子
  - [ ] Lua 5.5 处标注 1.0x 基准线
- [ ] **雷达图**
  - [ ] 每引擎一条折线，按类别维度展开
  - [ ] 值越靠近中心性能越好
- [ ] **内存使用柱状图** + **启动时间柱状图**

### 5.4 HTML 模板 `report/templates/`

- [ ] 基础 HTML 结构 + CSS 样式
- [ ] Chart.js 图表初始化代码
- [ ] `generate.py` 将 JSON 数据注入模板中 `<script>` 标签

**Phase 5 验收**：`make report` 生成 Markdown + HTML 报告，浏览器打开 HTML 报告能看到综合堆叠柱状图和各分类图表。

---

## Phase 6: 打磨与文档

**目标**：完善文档、CI 集成、端到端验证。

### 6.1 文档完善

- [ ] 完善 README.md
  - [ ] 详细使用说明（setup / bench / report / 选择性运行）
  - [ ] 系统要求和各平台依赖安装指南
  - [ ] 如何添加新引擎 / 新测试用例
  - [ ] FAQ（V8 编译常见问题、如何跳过特定引擎等）
- [ ] 添加 benchmarks/README.md（测试用例来源、算法说明、等价性保证）

### 6.2 CI 集成

- [ ] 添加 GitHub Actions workflow
  - [ ] Linux (ubuntu-latest)：至少验证 Lua + LuaJIT + QuickJS 的构建和测试
  - [ ] macOS (macos-latest)：同上
  - [ ] V8 构建可选（CI 耗时过长时跳过）

### 6.3 端到端验证

- [ ] 在全新 Linux 环境中从 clone 到报告生成
- [ ] 在全新 macOS 环境中从 clone 到报告生成
- [ ] 验证缺失依赖时的提示信息正确性
- [ ] 验证 `ENGINES` 过滤参数在所有步骤中正常工作

### 6.4 收尾

- [ ] 审查所有脚本的错误处理和边界情况
- [ ] 确保所有路径使用相对路径，支持项目目录在任意位置
- [ ] 更新 PROJECT_PLAN.md 中的进度总览表

**Phase 6 验收**：一个从未接触本项目的人，按照 README.md 操作，能成功完成全流程。

---

## 人工介入指南

以下场景需要人工介入，脚本会暂停并给出操作指引：

### 场景 1：系统依赖缺失

**表现**：`check_deps.sh` 报告缺失工具并退出。

**操作**：按脚本提示安装对应工具，然后重新执行 `make setup`。

### 场景 2：源码下载失败

**表现**：`download_sources.sh` 在某个引擎的下载步骤报错。

**操作**：

```bash
# 方式 1：重试下载该引擎
make download-lua       # 单独重试 Lua
make download-v8        # 单独重试 V8

# 方式 2：手动下载并放入指定位置
# Lua：将 lua-5.5.0.tar.gz 解压到 .build/src/lua-5.5.0/
# LuaJIT：git clone 到 .build/src/LuaJIT/
# QuickJS：git clone 到 .build/src/quickjs/
# V8：确保 .build/src/v8/ 中有完整的 V8 源码

# 方式 3：跳过该引擎，只测试其余引擎
make setup ENGINES="lua luajit quickjs"
```

### 场景 3：V8 编译失败

**表现**：`build_v8.sh` 在 gn gen 或 ninja 步骤报错。

**操作**：

```bash
# 内存不足 → 降低并行度
cd .build/src/v8
ninja -C out/release -j2 d8

# 编译器版本不够 → 升级 gcc/clang
# V8 通常要求 gcc >= 10 或 clang >= 12

# 彻底放弃 V8 → 跳过
make bench ENGINES="lua luajit quickjs"
```

### 场景 4：编译成功但验证失败

**表现**：引擎二进制存在但 `-v` 或 `--version` 输出异常。

**操作**：清理该引擎的构建产物后重新编译。

```bash
rm -rf .build/engines/lua/      # 清理产物
rm -rf .build/src/lua-5.5.0/    # 可选：同时清理源码
make setup ENGINES=lua          # 重新下载 + 编译
```
