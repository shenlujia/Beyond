在平时开发和调试中，经常遇到C调用栈和汇编，所以这里来统一的了解下这部分内容，本章需要一定的汇编基础才能更好的理解。

## 函数签名

在JavaScript中，我们定义函数和调用函数都是相当自由的：



```js
function func(a, b, c) {
    console.log(a, b, c)
}
func(1)
func(1, 2, 3, 4, 5, 6)
```

这样做完全没有问题。但是在C语言中，方法调用却是非常严格的，如果参数类型或者个数不对，就会直接编译失败（隐式转换除外）。



```c
int arg1_func(int a) {
    return a;
}
int arg2_func(int a, int b) {
    return a+b;
}

arg1_func(1, 2);
arg2_func(1);
```

以上C语言将会直接编译不通过，原因之后再说。这里我们把`int(*)(int)`称为这个函数的`函数签名`。

为什么我们要了解`函数签名`呢？由于C方法的参数传递是和函数签名相关的，而且是编译期就需要确定的。他决定了参数是如何传递给具体方法，并且返回参数是如何返回的。

那么接下来就让我们来了解C语言的参数传递方式。由于不同架构平台拥有不同的处理方式，但大同小异，这里我们就用`AArch64`架构来做介绍。

## Registers

在了解底层之前，我们需要一点ARM的预备知识，这里做一个简单的介绍，具体ARM汇编可以参考官方文档[**armasm_user_guide**](https://link.jianshu.com/?t=http%3A%2F%2Finfocenter.arm.com%2Fhelp%2Ftopic%2Fcom.arm.doc.dui0801g%2FDUI0801G_armasm_user_guide.pdf)和[**ABI**](https://link.jianshu.com/?t=http%3A%2F%2Finfocenter.arm.com%2Fhelp%2Ftopic%2Fcom.arm.doc.den0024a%2FDEN0024A_v8_architecture_PG.pdf)。

##### ARM_ASM (4.1节)

In AArch64 state, the following registers are available:

- Thirty-one 64-bit general-purpose registers X0-X30, the bottom halves of which are accessible as
  W0-W30.
- Four stack pointer registers SP_EL0, SP_EL1, SP_EL2, SP_EL3.
- Three exception link registers ELR_EL1, ELR_EL2, ELR_EL3.
- Three saved program status registers SPSR_EL1, SPSR_EL2, SPSR_EL3.
- One program counter.

##### ABI (9.1节)

For the purposes of function calls, the general-purpose registers are divided into four groups:

1. Argument registers (X0-X7)

   These are used to pass parameters to a function and to return a result. They can be used as scratch registers or as caller-saved register variables that can hold intermediate values within a function, between calls to other functions. The fact that 8 registers are available for passing parameters reduces the need to spill parameters to the stack when compared with AArch32.

2. Caller-saved temporary registers (X9-X15)

   If the caller requires the values in any of these registers to be preserved across a call to another function, the caller must save the affected registers in its own stack frame. They can be modified by the called subroutine without the need to save and restore them before returning to the caller.

3. Callee-saved registers (X19-X29)

   These registers are saved in the callee frame. They can be modified by the called subroutine as long as they are saved and restored before returning.

4. Registers with a special purpose (X8, X16-X18, X29, X30)

   - X8 is the indirect result register. This is used to pass the address location of an indirect result, for example, where a function returns a large structure.
   - X16 and X17 are IP0 and IP1, intra-procedure-call temporary registers. These can be used by call veneers and similar code, or as temporary registers for intermediate values between subroutine calls. They are corruptible by a function. Veneers are small pieces of code which are automatically inserted by the linker, for example when the branch target is out of range of the branch instruction.
   - X18 is the platform register and is reserved for the use of platform ABIs. This is an additional temporary register on platforms that don't assign a special meaning to it.
   - X29 is the frame pointer register (FP).
   - X30 is the link register (LR).

根据官方文档，这里我们需要知道的是X0-X30个通用寄存器，D0-D31个浮点寄存器，堆栈寄存器SP，和独立不可直接操作的PC寄存器。

其中通用寄存器在C语言的ABI定义中，X29作为栈帧FP，X30作为函数返回地址LR，X0-X7作为参数寄存器，X8为`Indirect result location`（和返回值相关），X9-X15为临时寄存器。其他的寄存器和目前我们的内容没有太大的关系，所以不做介绍了。这里有个官方的简要图：



![img](https:////upload-images.jianshu.io/upload_images/1929223-3aa7c335830ce270.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200)

registers.png

在阅读以下内容需要明确上述的几个寄存器，特别是`LR=X30`，`FP=X29`，其中W0和X0代表同一个寄存器，只是W是32位，X是64位。

需要了解的存取指令是LDR（load），STR（store），其他存取指令都是以这两个为基础。相关运算可见`ABI 6.3.4节`，这里介绍下下面会遇到的运算：

| Example | Description |
| --------------------- |
|LDR X0, [X1, #8] |Load from address X1 + 8 |
|LDR X0, [X1, #8]! |Pre-index: Update X1 first (to X1 + #8), then load from the new address |
|LDR X0, [X1], #8 |Post-index: Load from the unmodified address in X1 first, then update X1 (to X1 + #8) |

## Stack Frame

在C语言调用过程中，`SP`和`LR`是成对出现的，他们代表了一个函数的栈区域，也称为`栈帧`。

一个栈帧的大概结构如下：



![img](https:////upload-images.jianshu.io/upload_images/1929223-911c3e6af0d4d293.png?imageMogr2/auto-orient/strip|imageView2/2/w/341)

stack_frame.png

这个结构对我们来说非常重要，也是本次我们讨论的重点。

## 少参数调用

对于一个函数的调用，入参会放入X0-X7中，返回参数会放在X0中返回，那么我们就来分析下一个简单的例子：



```c
int lessArg(int arg1, char *arg2) {
    return 0;
}
```

调用前：



```armasm
caller:
    0x100791c6c <+20>:  mov    w9, #0x0
    0x100791c70 <+24>:  stur   w9, [x29, #-0x14]
    0x100791c74 <+28>:  stur   w0, [x29, #-0x18]
    0x100791c78 <+32>:  str    x1, [x8, #0xa0]
    0x100791c7c <+36>:  mov    x1, #0x0                 ; // 第二个参数 arg2 = 0
    0x100791c80 <+40>:  mov    x0, x9                   ; // 第一个参数 arg1 = 0
    0x100791c84 <+44>:  str    x1, [sp, #0x88]
    0x100791c88 <+48>:  str    x8, [sp, #0x80]
    0x100791c8c <+52>:  str    w9, [sp, #0x7c]
    0x100791c90 <+56>:  bl     0x100791a60               ; CALL 'lessArg'
```



```armasm
cfunction`lessArg:
    0x104491a98 <+0>:  sub    sp, sp, #0x10             ; 由于栈是向下增长的，所以 SP = SP - 0x10
    0x104491a9c <+4>:  mov    w8, #0x0
    0x104491aa0 <+8>:  str    w0, [sp, #0xc]
    0x104491aa4 <+12>: str    x1, [sp]
    0x104491aa8 <+16>: mov    x0, x8                    ; 返回值 X0 = 0
    0x104491aac <+20>: add    sp, sp, #0x10             ; 销毁栈
    0x104491ab0 <+24>: ret    
```

由以上结果看的确按照ABI所描述的，在<=8个参数的时候，参数是放在寄存器中传递。

## 多参数调用

那么如果参数超过8个呢？据ABI描述是通过堆栈的形式来传递，我们来看下结果：



```c
int moreArg(int arg1, int arg2, int arg3, int arg4, int arg5, int arg6, int arg7, int arg8, int arg9, int arg10, int arg11, int arg12, int arg13, char *arg14) {
    return 0;
}
```



```armasm
caller:
    0x100791c9c <+68>:  mov    x1, sp                   ; x1 = SP
    0x100791ca0 <+72>:  ldr    x30, [sp, #0x88]
    0x100791ca4 <+76>:  str    x30, [x1, #0x18]
    0x100791ca8 <+80>:  orr    w9, wzr, #0xc  
    0x100791cac <+84>:  str    w9, [x1, #0x10]          ; SP+0x10 = arg13
    0x100791cb0 <+88>:  mov    w9, #0xb      
    0x100791cb4 <+92>:  str    w9, [x1, #0xc]           ; SP+0xc = arg12
    0x100791cb8 <+96>:  mov    w9, #0xa      
    0x100791cbc <+100>: str    w9, [x1, #0x8]           ; SP+0x8 = arg11
    0x100791cc0 <+104>: mov    w9, #0x9
    0x100791cc4 <+108>: str    w9, [x1, #0x4]           ; SP+0x4 = arg10
    0x100791cc8 <+112>: orr    w9, wzr, #0x8            
    0x100791ccc <+116>: str    w9, [x1]                 ; SP = arg9
    0x100791cd4 <+124>: orr    w2, wzr, #0x2            ; w2 = arg3
    0x100791cd8 <+128>: orr    w3, wzr, #0x3            ; w3 = arg4
    0x100791cdc <+132>: orr    w4, wzr, #0x4            ; w4 = arg5
    0x100791ce0 <+136>: mov    w5, #0x5                 ; w5 = arg6
    0x100791ce4 <+140>: orr    w6, wzr, #0x6            ; w6 = arg7
    0x100791ce8 <+144>: orr    w7, wzr, #0x7            ; w7 = arg8
    0x100791cec <+148>: ldr    w10, [sp, #0x7c]
    0x100791cf0 <+152>: str    w0, [sp, #0x78]
    0x100791cf4 <+156>: mov    x0, x10                  ; w0 = arg1
    0x100791cd0 <+120>: orr    w9, wzr, #0x1
    0x100791cf8 <+160>: mov    x1, x9                   ; w1 = arg2
    0x100791cfc <+164>: str    x8, [sp, #0x70]
    0x100791d00 <+168>: str    w9, [sp, #0x6c]
    0x100791d04 <+172>: bl     0x100791a7c               ; moreArg at main.mm:16
```

从上面可以看出来，arg9以上的入参被存在了`SP ~ (SP+0x10)`的位置，也就是当前栈的栈底，下一层栈帧的栈顶。



```armasm
cfunction`moreArg:
    0x104491ab4 <+0>:  sub    sp, sp, #0x40             ; 申请栈空间，这里我们将原来的sp记作'SP0'
                                                        ; 那么 SP = SP0 - 0x40
    0x104491ab8 <+4>:  ldr    x8, [sp, #0x58]           
    0x104491abc <+8>:  ldr    w9, [sp, #0x50]           ; w9 = SP + 0x50 = SP0 - 0x40 + 0x50 = SP0 + 0x10
                                                        ; 也就是w13 = arg13
                                                        ; 按照这样的推导，下面依次为arg9 ~ arg12
    0x104491ac0 <+12>: ldr    w10, [sp, #0x4c]
    0x104491ac4 <+16>: ldr    w11, [sp, #0x48]
    0x104491ac8 <+20>: ldr    w12, [sp, #0x44]
    0x104491acc <+24>: ldr    w13, [sp, #0x40]          ; w13 = SP + 0x40 = SP0 - 0x40 + 0x40 = SP0
                                                        ; 也就是w13 = arg9
    0x104491ad0 <+28>: mov    w14, #0x0
    0x104491ad4 <+32>: str    w0, [sp, #0x3c]
    0x104491ad8 <+36>: str    w1, [sp, #0x38]
    0x104491adc <+40>: str    w2, [sp, #0x34]
    0x104491ae0 <+44>: str    w3, [sp, #0x30]
    0x104491ae4 <+48>: str    w4, [sp, #0x2c]
    0x104491ae8 <+52>: str    w5, [sp, #0x28]
    0x104491aec <+56>: str    w6, [sp, #0x24]
    0x104491af0 <+60>: str    w7, [sp, #0x20]
    0x104491af4 <+64>: str    w13, [sp, #0x1c]
    0x104491af8 <+68>: str    w12, [sp, #0x18]
    0x104491afc <+72>: str    w11, [sp, #0x14]
    0x104491b00 <+76>: str    w10, [sp, #0x10]
    0x104491b04 <+80>: str    w9, [sp, #0xc]
    0x104491b08 <+84>: str    x8, [sp]
    0x104491b0c <+88>: mov    x0, x14
    0x104491b10 <+92>: add    sp, sp, #0x40             ; =0x40 
    0x104491b14 <+96>: ret    
```

由此可见，大于8个的参数会被放入栈中`SP ~ (SP + count - 8)`，和预期的一样。

## struct参数及返回

上面说了基本类型的传递情况，在C语言中，还有一类不定长数据类型可以直接传递，那就是struct。那么我们来看看struct参数是怎么传递的。

#### 小struct



```c
struct SmallStruct {
    int arg1;
};

struct SmallStruct smallStructFunc(int arg1, struct SmallStruct arg2) {
    struct SmallStruct s = arg2;
    return s;
}
```



```armasm
caller:
    0x100791d24 <+204>: ldur   w9, [x29, #-0x30]
    0x100791d28 <+208>: mov    x1, x9                    ; x1 = arg2 !
                                                         ; 这里struct内容直接赋值给了x1，因为x1的容量完全够用！
    0x100791d2c <+212>: ldr    w9, [sp, #0x7c]
    0x100791d30 <+216>: str    w0, [sp, #0x64]           ; w0 = arg1
    0x100791d34 <+220>: mov    x0, x9
    0x100791d38 <+224>: bl     0x100791b04               ; smallStructFunc at main.mm:32
```



```armasm
cfunction`smallStructFunc:
    0x1003b5b04 <+0>:  sub    sp, sp, #0x20             ; =0x20 
    0x1003b5b08 <+4>:  mov    x8, x1                    ; x8 = arg2
    0x1003b5b0c <+8>:  str    w8, [sp, #0x10]
    0x1003b5b10 <+12>: str    w0, [sp, #0xc]
    0x1003b5b14 <+16>: ldr    w8, [sp, #0x10]
    0x1003b5b18 <+20>: str    w8, [sp, #0x18]
    0x1003b5b1c <+24>: ldr    w8, [sp, #0x18]
    0x1003b5b20 <+28>: mov    x0, x8                    ; x0 = x8 = arg2
                                                        ; 这里直接将x0作为struct返回值
    0x1003b5b24 <+32>: add    sp, sp, #0x20             ; =0x20 
    0x1003b5b28 <+36>: ret     
```

可见，小型struct，可以直接放在寄存器中传递，和普通基本类型的传递没有太大的区别。

#### 大struct

那么struct足够的大呢，导致不能简单的用寄存器容纳struct的数据？

这里就要涉及到X8的一个特殊身份了(XR, indirect result location)，这里我们将`X8`记作`XR`。



```c
struct BigStruct {
    int arg1; int arg2; int arg3; int arg4; int arg5; int arg6; int arg7; int arg8; int arg9; int arg10; int arg11; int arg12; int arg13; char *arg14;
};
struct BigStruct bigStructFunc(int arg1, struct BigStruct arg2) {
    struct BigStruct s = arg2;
    return s;
}
```



```armasm
caller:
    0x100791d3c <+228>: mov    x9, x0
    0x100791d40 <+232>: stur   w9, [x29, #-0x38]
    0x100791d44 <+236>: ldr    x8, [sp, #0x80]
    0x100791d48 <+240>: ldur   q0, [x8, #0x78]
    0x100791d4c <+244>: str    q0, [x8, #0x30]
    0x100791d50 <+248>: ldur   q0, [x8, #0x68]
    0x100791d54 <+252>: stur   q0, [x29, #-0xa0]
    0x100791d58 <+256>: ldur   q0, [x8, #0x58]
    0x100791d5c <+260>: stur   q0, [x29, #-0xb0]
    0x100791d60 <+264>: ldur   q0, [x8, #0x48]
    0x100791d64 <+268>: stur   q0, [x29, #-0xc0]         ; 以上是将临时变量arg2赋值到Callee的参数栈区
                                                         ; 这样子函数修改就不会改动原始数据了
                                                         ; 为方便，后面将已拷贝的数据成为 arg2
    0x100791d68 <+272>: add    x8, sp, #0xb0             ; XR = SP + 0xb0 
                                                         ; Callee save area
                                                         ; 这是一个空的区域，用作返回的临时存储区
    0x100791d6c <+276>: sub    x1, x29, #0xc0            ; x1 = FP - 0xc0 = &arg2
    0x100791d70 <+280>: ldr    w0, [sp, #0x7c]           ; w0 = arg1
    0x100791d74 <+284>: bl     0x100791b2c               ; bigStructFunc at main.mm:36
```



```armasm
cfunction`bigStructFunc:
    0x1003b5b2c <+0>:  sub    sp, sp, #0x20             ; 申请栈空间 SP = SP0 - 0x20
    0x1003b5b30 <+4>:  stp    x29, x30, [sp, #0x10]     ; 这里和以上几个不同，是因为这里有函数调用，所以需要把LR和FP压栈
    0x1003b5b34 <+8>:  add    x29, sp, #0x10            
    0x1003b5b38 <+12>: orr    x2, xzr, #0x40            ; struct 的 size = 0x40，作为第三个参数
    0x1003b5b3c <+16>: stur   w0, [x29, #-0x4]
    0x1003b5b40 <+20>: mov    x0, x8                    ; dst = x0 = XR = SP0 + 0xb0
                                                        ; 第一个入参dst为caller的临时存储区
                                                        ; 第二个参数为x1，也就是caller的 &arg2
    0x1003b5b44 <+24>: bl     0x1003b62f0               ; symbol stub for: memcpy
                                                        ; void *memcpy(void *dst, const void *src, size_t n);
                                                        ; 这里居然直接调用了memcpy，赋值！
    0x1003b5b48 <+28>: ldp    x29, x30, [sp, #0x10]
    0x1003b5b4c <+32>: add    sp, sp, #0x20             ; =0x20 
    0x1003b5b50 <+36>: ret    
```

这样返回值就放在了`*XR`所在的位置，caller只需要再拷贝到临时变量区中即可。

可以看到，在处理大型struct时，就会出现多次内存拷贝，会对性能造成一定影响，所以这类方法尽量不要直接传递大型struct，可以传递指针或者引用，或者采用inline的方案，在优化期去除函数调用。

#### struct参数的分界线

根据[AAPCS 64](https://link.jianshu.com/?t=http%3A%2F%2Finfocenter.arm.com%2Fhelp%2Ftopic%2Fcom.arm.doc.ihi0055c%2FIHI0055C_beta_aapcs64.pdf)的`Parameter Passing Rules`节所述：



```csharp
If the argument is a Composite Type and the size in double-words of the argument is not more than 8 minus NGRN, then the argument is copied into consecutive general-purpose registers, starting at x[NGRN]. The argument is passed as though it had been loaded into the registers from a double-word- aligned address with an appropriate sequence of LDR instructions loading consecutive registers from memory (the contents of any unused parts of the registers are unspecified by this standard). The NGRN is incremented by the number of registers used. The argument has now been allocated.
```

大致说的是如果X0-X8中剩余的寄存器足够去保存该结构，那么就保存到寄存器，否则保存到栈。



```swift
If the type, T, of the result of a function is such that
void func(T arg)
would require that arg be passed as a value in a register (or set of registers) according to the rules in §5.4 Parameter Passing, then the result is returned in the same registers as would be used for such an argument.
```

返回值也遵守以上规则。

这个文档不是最新的，而且是beta版，暂时没有找到正式版本。而且这里还涉及到很多其他的因素，所以这里也就不深究了。

## va_list

以上都是确定参数，那么如果是不确定参数，又是怎么传递的呢？

在`AAPCS 64`文档里有明确的说明，但是这里我们从汇编的角度来看这个问题。



```c
int mutableAragsFunc(int arg, ...) {
    va_list list;
    va_start(list, arg);
    int ret = arg;
    while(int a = va_arg(list, int)) {
        ret += a;
    }
    va_end(list);
    return ret;
}
mutableAragsFunc(1, 2, 3, 0);
```

在函数入口打断点，打印参数寄存器：



```undefined
x0 = 0x0000000000000001
x1 = 0x000000016fce7930
x2 = 0x000000016fce7a18
x3 = 0x000000016fce7a90
x4 = 0x0000000000000000
x5 = 0x0000000000000000
x6 = 0x0000000000000001
x7 = 0x00000000000004b0
```

可以发现除了x0是正确的第一个参数，其他都是随机的，那么说明参数肯定被放到了栈上。



```armasm
cfunction`main:
    0x100121be4 <+0>:   sub    sp, sp, #0xa0             ; =0xa0 
    0x100121be8 <+4>:   stp    x29, x30, [sp, #0x90]
    0x100121bec <+8>:   add    x29, sp, #0x90            ; =0x90 
    0x100121bf0 <+12>:  mov    w8, #0x0
    0x100121bf4 <+16>:  stur   w8, [x29, #-0x4]
    0x100121bf8 <+20>:  stur   w0, [x29, #-0x8]
    0x100121bfc <+24>:  stur   x1, [x29, #-0x10]
    0x100121c00 <+28>:  mov    x1, sp
    0x100121c04 <+32>:  mov    x9, #0x0
    0x100121c08 <+36>:  str    x9, [x1, #0x10]           ; 压栈 0
    0x100121c0c <+40>:  orr    w8, wzr, #0x3
    0x100121c10 <+44>:  mov    x9, x8
    0x100121c14 <+48>:  str    x9, [x1, #0x8]            ; 压栈 3
    0x100121c18 <+52>:  orr    w8, wzr, #0x2
    0x100121c1c <+56>:  mov    x9, x8
    0x100121c20 <+60>:  str    x9, [x1]                  ; 压栈 2
    0x100121c24 <+64>:  orr    w0, wzr, #0x1             ; arg = 1
    0x100121c28 <+68>:  bl     0x1001218d8               ; mutableAragsFunc at main.mm:67
```

也就是表明被明确定义的参数，是按照上面所说的规则传递，而`...`参数全部按照栈方式传递。这从实现原理上也比较容易理解，在取va_arg的时候，只需要将栈指针+sizeof(type)就可以了。

## 错误的函数签名

那么现在，我们回过头来看看第一个问题。C语言为什么会有函数签名？

函数签名决定了参数以及返回值的传递方式，同时还决定了函数栈帧的分布与大小，所以如果不确定函数签名，我们也就无法知道如何去传递参数了。

那么错误的函数签名会导致什么样的后果呢？运行时是否会崩溃？我们来看：



```c
int arg1_func(int a) {
    return a;
}
int arg2_func(int a, int b) {
    return a+b;
}

void arg_test_func() {
    int ret1 = ((int (*)(int, int))arg1_func)(1, 2);
    int ret2 = ((int (*)(int))arg2_func)(1);
    int ret3 = ((int (*)())arg1_func)();
    int ret4 = ((int (*)())arg2_func)();
    
    printf("%d, %d, %d, %d\n", ret1, ret2, ret3, ret4);
}
```

首先说结果，结果是一切运行正常，只是结果值有部分是错误的。那么我们来看看汇编代码：



```armasm
cfunction`arg_test_func:
    0x1003462cc <+0>:   sub    sp, sp, #0x50             ; =0x50 
    0x1003462d0 <+4>:   stp    x29, x30, [sp, #0x40]
    0x1003462d4 <+8>:   add    x29, sp, #0x40            ; =0x40 
                                                         ; 以上都是处理栈帧

    0x1003462d8 <+12>:  orr    w0, wzr, #0x1             ; w0 = 1
    0x1003462dc <+16>:  orr    w1, wzr, #0x2             ; w1 = 2
    0x1003462e0 <+20>:  bl     0x100346298               ; arg1_func at main.mm:87
    0x1003462e4 <+24>:  orr    w1, wzr, #0x1             ; w1 = 1
    0x1003462e8 <+28>:  stur   w0, [x29, #-0x4]          ; 将结果存入临时变量 ret1
                                                         ; 按照寄存器的状态，这里相当于调用了 arg1_func(1)
                                                         ; 其结果是正确的，只是可能没有符合预期

    0x1003462ec <+32>:  mov    x0, x1                    ; x0 = 1
    0x1003462f0 <+36>:  bl     0x1003462ac               ; arg2_func at main.mm:90
    0x1003462f4 <+40>:  stur   w0, [x29, #-0x8]          ; 将结果存入临时变量 ret2
                                                         ; 相当于 arg2_func(1, 1) = 2
                                                         ; 第二个参数取决于上一次x1的状态
                                                         ; 所以结果应该是随机的

    0x1003462f8 <+44>:  bl     0x100346298               ; arg1_func at main.mm:87
    0x1003462fc <+48>:  stur   w0, [x29, #-0xc]          ; 相当于 ret3 = arg1_func(2) = 2

    0x100346300 <+52>:  bl     0x1003462ac               ; arg2_func at main.mm:90
    0x100346304 <+56>:  stur   w0, [x29, #-0x10]         ; 相当于 ret4 = arg2_func(2, 1) = 3
```

所以结果应该是`1, 2, 2, 3`。

这里的结果不能代表任何在其他环境下的结果，可以说其结果是难以预测的。这里没有奔溃也只是随机参数并不会带来奔溃的风险。

所以我们是不能用其他函数签名来传递参数的。

## obj_msgSend

接下来，我们来说说iOS中最著名的函数`obj_msgSend`，可以说，这个函数是objc的核心和基础，没有这个方法，就不存在objc。

根据我们上面的分析，理论上我们不能改变`obj_msgSend`的函数签名，来传递不同类型和个数的参数。那么苹果又是怎么实现的呢？

以前我们一直说`obj_msgSend`用汇编来写是为了速度，但这并不是主要原因，因为retain，release也是非常频繁使用的方法，为什么不把这几个也改为汇编呢。其实更重要的原因是如果用C来写`obj_msgSend`根本实现不了！

我们翻开苹果objc的源码，查看其中arm64.s汇编代码：



```armasm
    ENTRY _objc_msgSend
    MESSENGER_START

    cmp    x0, #0               // nil check and tagged pointer check
    b.le    LNilOrTagged        //  (MSB tagged pointer looks negative)
    ldr    x13, [x0]            // x13 = isa
    and    x9, x13, #ISA_MASK   // x9 = class    
LGetIsaDone:
    CacheLookup NORMAL          // calls imp or objc_msgSend_uncached

LNilOrTagged:
    b.eq    LReturnZero         // nil check

    // tagged
    adrp    x10, _objc_debug_taggedpointer_classes@PAGE
    add    x10, x10, _objc_debug_taggedpointer_classes@PAGEOFF
    ubfx    x11, x0, #60, #4
    ldr    x9, [x10, x11, LSL #3]
    b    LGetIsaDone

LReturnZero:
    // x0 is already zero
    mov    x1, #0
    movi    d0, #0
    movi    d1, #0
    movi    d2, #0
    movi    d3, #0
    MESSENGER_END_NIL
    ret

    END_ENTRY _objc_msgSend
```

看出于上面其他C方法编译出来的汇编的区别了吗？

那就是`obj_msgSend`居然不存在栈帧！同时也没有任何地方修改过`X0-X7`,`X8`,`LR`,`SP`,`FP`！

而且当找到真正对象上的方法的时候，并不像其他方法一样使用`BL`，而是使用了



```armasm
.macro CacheHit
br  x17         // call imp
```

也就是说并没有修改`LR`。这样做的效果就相当于在函数调用的时候插入了一段代码！更像是c语言的宏。

由于`obj_msgSend`并没有改变任何方法调用的上下文，所以真正的objc方法就好像是被直接调用的一样。

可以说，这种想法实在是太精彩了。

## objc_msgSend对nil对象的处理

大家都知道，向空对象发送消息，返回的内容肯定都是0。那么这是为什么呢？

还是来看`obj_msgSend`的源代码部分，第一行就判断了nil：



```armasm
    cmp    x0, #0               // nil check and tagged pointer check
    b.le    LNilOrTagged        //  (MSB tagged pointer looks negative)
```

其中tagged pointer技术并不是我们本期的话题，所以我们直接跳到空对象的处理方法上：



```armasm
LReturnZero:
    // x0 is already zero
    mov    x1, #0
    movi    d0, #0
    movi    d1, #0
    movi    d2, #0
    movi    d3, #0
    MESSENGER_END_NIL
    ret
```

他将可能的保存返回值的寄存器全部写入0！（为什么会有多个寄存器，是因为ARM其实是支持向量运算的，所以在某些条件下会用多个寄存器保存返回值，具体可以去参考ARM官方文档）。

这样我们的返回值就只能是0了！

等等，还缺少一个类型，struct！如果是栈上的返回，上文已经分析过是保存在`X8`中的，可是我们并没有看到任何有关`X8`的操作。那么我们来写一个demo尝试一下：



```objc
void struct_objc_nil(Test *t) {
    struct BigStruct retB;
    printf("stack: %d,%d,%d,%d,%d,%d,\n", retB.arg1, retB.arg2, retB.arg3, retB.arg4, retB.arg5, retB.arg6);
    retB = ((struct BigStruct(*)(Test *, SEL))objc_msgSend)(t, @selector(retStruct));
    printf("msgSend: %d,%d,%d,%d,%d,%d,\n", retB.arg1, retB.arg2, retB.arg3, retB.arg4, retB.arg5, retB.arg6);
    retB = [t retStruct];
    printf("objc: %d,%d,%d,%d,%d,%d,\n", retB.arg1, retB.arg2, retB.arg3, retB.arg4, retB.arg5, retB.arg6);
}
```

首先我们打开编译优化`-os`(非优化状态，栈空间会被清0)。其结果居然是：



```cpp
stack: 50462976,185207048,0,0,0,0,
msgSend: 1,0,992,0,0,0,
objc: 0,0,0,0,0,0,
```

struct类型两者的返回并不一致！按照我们阅读源码来推论，随机数值才是正确的结果，这是为什么呢？

我们还是来看汇编，我将关键部分特意标注了出来：



```armasm
cfunction`struct_objc_nil:
    0x10097e754 <+0>:   sub    sp, sp, #0x90             ; =0x90 
    0x10097e758 <+4>:   stp    x20, x19, [sp, #0x70]
    0x10097e75c <+8>:   stp    x29, x30, [sp, #0x80]
    0x10097e760 <+12>:  add    x29, sp, #0x80            ; =0x80 
    0x10097e764 <+16>:  bl     0x10097e9d4               ; symbol stub for: objc_retain
    0x10097e768 <+20>:  mov    x19, x0
    0x10097e76c <+24>:  adr    x0, #0x1730               ; "stack: %d,%d,%d,%d,%d,%d,\n"
    0x10097e770 <+28>:  nop    
    0x10097e774 <+32>:  bl     0x10097e9f8               ; symbol stub for: printf
    0x10097e778 <+36>:  nop    
    0x10097e77c <+40>:  ldr    x20, #0x262c              ; "retStruct"
    0x10097e780 <+44>:  add    x8, sp, #0x30             ; =0x30 
    0x10097e784 <+48>:  mov    x0, x19
    0x10097e788 <+52>:  mov    x1, x20
    0x10097e78c <+56>:  bl     0x10097e9b0               ; symbol stub for: objc_msgSend
    0x10097e790 <+60>:  ldp    w8, w9, [sp, #0x30]
    0x10097e794 <+64>:  ldp    w10, w11, [sp, #0x38]
    0x10097e798 <+68>:  ldp    w12, w13, [sp, #0x40]
    0x10097e79c <+72>:  stp    x12, x13, [sp, #0x20]
    0x10097e7a0 <+76>:  stp    x10, x11, [sp, #0x10]
    0x10097e7a4 <+80>:  stp    x8, x9, [sp]
    0x10097e7a8 <+84>:  adr    x0, #0x170f               ; "msgSend: %d,%d,%d,%d,%d,%d,\n"
    0x10097e7ac <+88>:  nop    
    0x10097e7b0 <+92>:  bl     0x10097e9f8               ; symbol stub for: printf

    //////////////////////////////////////////////////////////
->  0x10097e7b4 <+96>:  cbz    x19, 0x10097e7d8          ; <+132> at main.mm:134
                                                         ; 这里的意思是：
                                                         ; IF X19 == NULL THEN
                                                         ;    GOTO 0x10097e7d8
                                                         ; 而 0x10097e7d8 就是内存清0的地方！
                                                         ; X19 在 0x10097e768 被赋值为 objc 对象 'nil'
                                                         ; 而在第一次调用 'obj_msgSend' 就没有这一段！
                                                         ; （由于优化，有些逻辑和代码中有变化）
    //////////////////////////////////////////////////////////
    
    0x10097e7b8 <+100>: add    x8, sp, #0x30             ; =0x30 
    0x10097e7bc <+104>: mov    x0, x19
    0x10097e7c0 <+108>: mov    x1, x20
    0x10097e7c4 <+112>: bl     0x10097e9b0               ; symbol stub for: objc_msgSend
    0x10097e7c8 <+116>: ldp    w8, w9, [sp, #0x30]
    0x10097e7cc <+120>: ldp    w10, w11, [sp, #0x38]
    0x10097e7d0 <+124>: ldp    w12, w13, [sp, #0x40]
    0x10097e7d4 <+128>: b      0x10097e800               ; <+172> at main.mm:135


                                                         ; 这里有一段清0的代码！正好就是返回值的局部变量地址
    0x10097e7d8 <+132>: mov    w13, #0x0
    0x10097e7dc <+136>: mov    w12, #0x0
    0x10097e7e0 <+140>: mov    w11, #0x0
    0x10097e7e4 <+144>: mov    w10, #0x0
    0x10097e7e8 <+148>: mov    w9, #0x0
    0x10097e7ec <+152>: mov    w8, #0x0
    0x10097e7f0 <+156>: stp    xzr, xzr, [sp, #0x60]
    0x10097e7f4 <+160>: stp    xzr, xzr, [sp, #0x50]
    0x10097e7f8 <+164>: stp    xzr, xzr, [sp, #0x40]
    0x10097e7fc <+168>: stp    xzr, xzr, [sp, #0x30]
    0x10097e800 <+172>: stp    x12, x13, [sp, #0x20]
    0x10097e804 <+176>: stp    x10, x11, [sp, #0x10]


    0x10097e808 <+180>: stp    x8, x9, [sp]
    0x10097e80c <+184>: adr    x0, #0x16c8               ; "objc: %d,%d,%d,%d,%d,%d,\n"
    0x10097e810 <+188>: nop    
    0x10097e814 <+192>: bl     0x10097e9f8               ; symbol stub for: printf
    0x10097e818 <+196>: mov    x0, x19
    0x10097e81c <+200>: bl     0x10097e9c8               ; symbol stub for: objc_release
    0x10097e820 <+204>: ldp    x29, x30, [sp, #0x80]
    0x10097e824 <+208>: ldp    x20, x19, [sp, #0x70]
    0x10097e828 <+212>: add    sp, sp, #0x90             ; =0x90 
    0x10097e82c <+216>: ret    
    0x10097e830 <+220>: b      0x10097e834               ; <+224> at main.mm
    0x10097e834 <+224>: mov    x20, x0
    0x10097e838 <+228>: mov    x0, x19
    0x10097e83c <+232>: bl     0x10097e9c8               ; symbol stub for: objc_release
    0x10097e840 <+236>: mov    x0, x20
    0x10097e844 <+240>: bl     0x10097e98c               ; symbol stub for: _Unwind_Resume
```

到这里我们就能够明白了，为什么struct返回值也会变成0。是编译器给我们加入了一段判定的代码！

那么'objc空对象的返回值一定是0'这个判定就需要在一定条件下了。

## 总结

对这一部分的探索一直持续了很久，一直是迷糊状态，不过经过长时间的多次探索，慢慢思考，总算有一个比较清晰的认识了。可以说底层的东西真的很多很复杂，这里只是其中很小的一方面，其他方面等有时间了另外再写吧。

## 参考资料

[armasm_user_guide](https://link.jianshu.com/?t=http%3A%2F%2Finfocenter.arm.com%2Fhelp%2Ftopic%2Fcom.arm.doc.dui0801g%2FDUI0801G_armasm_user_guide.pdf)

[ABI](https://link.jianshu.com/?t=http%3A%2F%2Finfocenter.arm.com%2Fhelp%2Ftopic%2Fcom.arm.doc.den0024a%2FDEN0024A_v8_architecture_PG.pdf)

[AAPCS](https://link.jianshu.com/?t=http%3A%2F%2Finfocenter.arm.com%2Fhelp%2Ftopic%2Fcom.arm.doc.ihi0055c%2FIHI0055C_beta_aapcs64.pdf)

[GNU C & ASM](https://link.jianshu.com/?t=https%3A%2F%2Fgcc.gnu.org%2Fonlinedocs%2Fgcc%2FUsing-Assembly-Language-with-C.html%23Using-Assembly-Language-with-C)

[Apple ASM](https://link.jianshu.com/?t=https%3A%2F%2Fdeveloper.apple.com%2Flibrary%2Fcontent%2Fdocumentation%2FDeveloperTools%2FReference%2FAssembler%2F000-Introduction%2Fintroduction.html)