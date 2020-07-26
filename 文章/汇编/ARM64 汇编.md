寄存器

汇编指令栈栗子

逆向工程绕不过的一部分就是汇编指令的分析。我们iPhone里面用到的是ARM汇编,但是不同的设备也有差异,因CPU的架构不同。

| 架构   | 设备                                                         |
| ------ | ------------------------------------------------------------ |
| armv6  | iPhone, iPhone2, iPhone3G, 第一代、第二代 iPod Touch         |
| armv7  | iPhone3GS, iPhone4, iPhone4S,iPad, iPad2, iPad3(The New iPad), iPad mini, iPod Touch 3G, iPod Touch4 |
| armv7s | iPhone5, iPhone5C, iPad4(iPad with Retina Display)           |
| arm64  | iPhone5S 及以后版本                                          |

从iPhone5s之后的苹果手机都是ARM64位操作系统了，所以我们直接从ARM64汇编指令开始。

寄存器

我们都知道CPU的典型构成中有寄存器、控制器和运算器等组成，部件之间通过总线连接。运算器负责信息处理，控制器负责控制其他期间进行工作，寄存器用于信息存储。对我们程序员来说寄存器是最主要部件，可以通过改变寄存器的内容来实现对CPU的控制。

不同的CPU，寄存器的个数和结构不相同。像8086CPU有14个寄存器。ARM64 有34个寄存器，包括31个通用寄存器、SP、PC、CPSR。

| 寄存器   | 位数  | 描述                                                   |
| -------- | ----- | ------------------------------------------------------ |
| X0-X30   | 64bit | 通用寄存器，如果有需要可以当做32bit使用：WO-W30        |
| FP(x29)  | 64bit | 保存栈帧地址(栈底指针)                                 |
| LR (X30) | 64bit | 通常称X30为程序链接寄存器，保存跳转返回信息地址        |
| SP       | 64bit | 保存栈指针                                             |
| PC       | 64bit | 程序计数器，俗称PC指针，总是指向即将要执行的下一条指令 |

X0-X7: 用于子程序调用时的参数传递，X0还用于返回值传递

X8: 间接寻址结果

LR: 保存子程序结束后需要执行的下一条指令

Xcode在真机中运行项目，然后在viewWillAppear添加断点，lldb中查看各寄存器状态register read

![img](http://5b0988e595225.cdn.sohucs.com/images/20171226/ab10bf1ee12e44aabece51ffe086506c.jpeg)

![img](http://5b0988e595225.cdn.sohucs.com/images/20171226/ac060ac9543c4ddeba6ee90b3e3ca098.jpeg)

汇编指令

下面介绍ARM64经常用到的汇编指令

MOV X1，X0 ; 将寄存器X0的值传送到寄存器X1

ADD X0，X1，X2 ; 寄存器X1和X2的值相加后传送到X0

SUB X0，X1，X2 ; 寄存器X1和X2的值相减后传送到X0

AND X0，X0，#0xF ; X0的值与0xF相位与后的值传送到X0

ORR X0，X0，#9 ; X0的值与9相或后的值传送到X0

EOR X0，X0，#0xF ; X0的值与0xF相异或后的值传送到X0

LDR X5，[X6，#0x08] ；X6寄存器加0x08的和的地址值内的数据传送到X5

STR X0, [SP, #0x8] ；X0寄存器的数据传送到SP+0x8地址值指向的存储空间

STP x29, x30, [sp, #0x10] ; 入栈指令

LDP x29, x30, [sp, #0x10] ; 出栈指令

CBZ ; 比较（Compare），如果结果为零（Zero）就转移（只能跳到后面的指令）

CBNZ ; 比较，如果结果非零（Non Zero）就转移（只能跳到后面的指令）

CMP ; 比较指令，相当于SUBS，影响程序状态寄存器

CPSR B/BL ; 绝对跳转#imm， 返回地址保存到LR（X30）

RET ; 子程序返回指令，返回地址默认保存在LR（X30）

 

AND R0, R1, R2 ; R0 = R1 & R2

ORR R0, R1, R2 ; R0 = R1 | R2 

EOR R0, R1, R2 ; R0 = R1 ^ R2 

BIC R0, R1, R2 ; R0 = R1 &~ R2 

MOV R0, R2 ; R0 = R2

 

NZCV是状态寄存器中存的几个状态值，分别代表运算过程中产生的状态，其中：

- N, negative condition flag，一般代表运算结果是负数
- Z, zero condition flag, 运算结果为0
- C, carry condition flag, 无符号运算有溢出时，C=1。
- V, oVerflow condition flag 有符号运算有溢出时，V=1。

栈

栈就是指令执行时存放临时变量的内存空间，具有特殊的访问方式：后进先出， Last In Out Firt。

- 栈是从高地址到低地址存储数据的，栈底是高地址，栈顶是高地址。
- FP指向栈底
- SP指向栈顶

栗子

下面我们写一个简单求和的子函数调用，看看编译成ARM64汇编指令是什么样子的。

- testarm.m的内容如下：

​      \#include<stdio.h>

​      int mySum(inta , intb) 

　　{

　　 　　intc=a+b;

　　 　　returnc; 

　　} 

　　int main (intargc, char*argv[])

　　 {

　　　　 int outA = 10;

　　　　 int outB = 20;

　　　　 int result = mySum(10, 20);

　　　　 printf("%d",result);

　　　　return0; 

　　}

- 用clang编译成arm64汇编代码

  编译命令如下：

  clang -O0-archarm64 -isysroot`xcrun --sdk iphoneos --show-sdk-path`-otestarm01 testarm.m

  testarm01： 输出文件名

  testarm.m： 需要编译的文件

  arm64：输出汇编类型

- 分析汇编

  使用IDA或者Hopper查看汇编代码，下面我粘贴处主要汇编代码分析。

- - mySum对应的汇编：

    ![img](http://5b0988e595225.cdn.sohucs.com/images/20171226/7236072e6c4c49a09be0f21cfbe0270f.jpeg)

    从SUB SP, SP, #0x10开始分析

    SUB SP, SP, #0x10 ; 分配栈控件16个字节; 下面是先存储参数，然后取出来用 

  - STR W0, [SP,#0x10+var_4] ; 把W0入栈，即a

  - STR W1, [SP,#0x10+var_8] ; 把W1入栈，即b

  - LDR W0, [SP,#0x10+var_4] ;出栈a，存储到W0

  - LDR W1, [SP,#0x10+var_8] ;出栈b，存储到W1;

  - 主代码到了，求和ADD W0, W0, W1 ;求和，并把和存储到W0，相当于int c = a + b;;

  - 返回值处理 STR W0, [SP,#0x10+var_C] ;把和W0入栈

  - LDR W0, [SP,#0x10+var_C] ; 把和W0出栈，现在W0存储的就是结果了。

  - ADD SP, SP, #0x10 ;平栈，采用平栈方式是add

  - RET ;子程序结束

  - 下面是main函数的汇编代码：

    想必通过上边sum函数的讲解，大家也能基本能看懂main函数的汇编

    ![img](http://5b0988e595225.cdn.sohucs.com/images/20171226/60d137931eca441cbac10147bdcba0b8.jpeg)

    主要代码解释

    MOV X0, X8 ;实参outA: #0xA = 10

  - MOV X1, X9 ;实参outB: #0x14 = 20

  - BL _mySum ;调用mySum子函数