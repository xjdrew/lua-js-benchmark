# 基准测试

[English](README.md)

本目录包含 7 个分类、共 16 个基准测试用例。每个用例同时有 Lua 和 JavaScript 两个实现，对相同输入产生**完全一致的输出**，确保公平对比。

## 目录结构

```
benchmarks/
├── lua/                  # Lua 实现（主目录，用于自动发现测试）
│   ├── compute/
│   ├── string/
│   ├── alloc/
│   ├── table/
│   ├── call/
│   ├── coroutine/
│   └── startup/
├── js/                   # JavaScript 实现
│   ├── compute/
│   ├── string/
│   ├── alloc/
│   ├── object/           # ← 对应 Lua 的 "table" 分类
│   ├── call/
│   ├── async/            # ← 对应 Lua 的 "coroutine" 分类
│   └── startup/
└── expected/             # 预期输出文件（正确性校验）
```

Runner 以 `lua/` 目录为准自动发现测试用例，通过分类映射（`table` → `object`、`coroutine` → `async`）找到对应的 JS 脚本。

## 测试用例

### compute — CPU 密集型数值计算

| 用例 | 来源 | 说明 |
|------|------|------|
| mandelbrot | [Benchmarks Game](https://benchmarksgame-team.pages.debian.net/benchmarksgame/) | Mandelbrot 集合：遍历复平面，统计集合内的像素数 |
| nbody | [Benchmarks Game](https://benchmarksgame-team.pages.debian.net/benchmarksgame/) | N 体模拟：木星行星轨道的蛙跳积分模拟 |
| spectral_norm | [Benchmarks Game](https://benchmarksgame-team.pages.debian.net/benchmarksgame/) | 谱范数：计算无穷矩阵的最大奇异值 |
| fannkuch | [Benchmarks Game](https://benchmarksgame-team.pages.debian.net/benchmarksgame/) | Fannkuch-redux：生成排列并计算翻饼次数 |

### string — 字符串操作

| 用例 | 来源 | 说明 |
|------|------|------|
| fasta | 原创 | 使用线性同余生成器生成随机 DNA 序列 |
| json_parse | 原创 | 构建 N 个对象的 JSON 字符串，用递归下降解析器解析 |
| string_concat | 原创 | 字符串拼接 N 次（使用 `table.concat` / 数组 join） |

### alloc — GC 压力与内存分配

| 用例 | 来源 | 说明 |
|------|------|------|
| binary_trees | [Benchmarks Game](https://benchmarksgame-team.pages.debian.net/benchmarksgame/) | 分配和释放递增深度的二叉树 |
| object_churn | 原创 | 创建 N 个含 3 个字段的小表/对象并求和 |

### table — 哈希表 / 对象属性操作

| 用例 | 来源 | 说明 |
|------|------|------|
| table_insert | 原创 | 向表/对象插入 N 个键值对，然后求和 |
| array_access | 原创 | 创建数组、求和、原地反转、再求和 |

### call — 函数调用开销与递归

| 用例 | 来源 | 说明 |
|------|------|------|
| ackermann | 经典 | Ackermann 函数 `ack(3, 9)` — 深度递归压力测试 |
| fibonacci | 经典 | 朴素递归斐波那契 — 函数调用开销测量 |
| queens | 经典 | N 皇后问题 — 求 N=12 的所有解 |

### coroutine — 协程 / 生成器上下文切换

| 用例 | 来源 | 说明 |
|------|------|------|
| scheduler | 原创 | 100 个协程/生成器各计数到 N/100，轮询调度 |

Lua 使用 `coroutine.create`/`coroutine.resume`/`coroutine.yield`，JavaScript 使用生成器函数（`function*`/`yield`）。

### startup — 引擎冷启动时间

| 用例 | 来源 | 说明 |
|------|------|------|
| empty | 原创 | 空脚本 — 测量纯引擎启动开销 |

## 输出等价性

每个测试通过命令行参数接收问题规模（Lua 中的 `arg[1]`，JS 中的 `scriptArgs[1]` 或 `process.argv[2]`），并输出确定性结果。

同一测试的 Lua 和 JS 实现必须对相同输入产生**字节级一致**的输出。`expected/` 中的预期输出文件由 Lua 版本生成，在测试运行时与所有引擎的输出进行校验。

重新生成预期输出：

```bash
lua benchmarks/lua/<分类>/<名称>.lua [参数] > benchmarks/expected/<分类>/<名称>.txt
```

## JS 兼容性

JavaScript 测试必须同时兼容 QuickJS 和 V8 (d8)。使用以下跨平台写法：

```js
const print = typeof console !== 'undefined' ? console.log.bind(console) : globalThis.print;
const N = parseInt(typeof scriptArgs !== 'undefined' ? scriptArgs[1]
    : (typeof process !== 'undefined' ? process.argv[2] : '0')) || DEFAULT;
```

## 添加新测试

1. 编写 `benchmarks/lua/<分类>/<名称>.lua`
2. 编写 `benchmarks/js/<JS 分类>/<名称>.js`
3. 确保两者对相同输入产生完全一致的输出
4. 生成预期输出：`lua benchmarks/lua/<分类>/<名称>.lua > benchmarks/expected/<分类>/<名称>.txt`
5. 在所有可用引擎上验证
6. Runner 会自动发现新测试
