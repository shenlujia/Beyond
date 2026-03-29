
# easy_math

## 简介

生成小孩子数学题目的技能，支持加法、减法、乘法、除法等多种题型。

## 目录结构

```
easy_math/
├── SKILL.md
├── scripts/
│   ├── __init__.py
│   ├── generator.py
│   └── cli.py
├── references/
└── tmp_files/
```

## 模块架构

### 1. generator.py - 题目生成器
- **功能**：生成各种数学题目
- **主要函数**：
  - `generate_addition()`: 生成加法题目
  - `generate_subtraction()`: 生成减法题目
  - `generate_multiplication()`: 生成乘法题目
  - `generate_division()`: 生成除法题目
  - `generate_mixed()`: 生成混合运算题目

### 2. cli.py - 命令行入口
- **功能**：提供命令行接口
- **主要命令**：
  - `generate`: 生成数学题目
  - `--type`: 题目类型 (add/sub/mul/div/mixed)
  - `--count`: 题目数量
  - `--difficulty`: 难度等级 (1-5)
  - `--output`: 输出文件

## 使用示例

```bash
# 生成 10 道加法题，难度 2
python3 cli.py generate --type add --count 10 --difficulty 2

# 生成 20 道混合运算题，难度 3
python3 cli.py generate --type mixed --count 20 --difficulty 3

# 生成题目并保存到文件
python3 cli.py generate --type mul --count 15 --output math_questions.txt
```

## 难度说明

- **1**: 10 以内的加减法
- **2**: 20 以内的加减法
- **3**: 100 以内的加减法，九九乘法表
- **4**: 多位数加减法，表内除法
- **5**: 多位数乘除法，简单混合运算
