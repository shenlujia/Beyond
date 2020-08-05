Runtime，也就是所谓的运行时，是Objective-C语言一个非常重要的特性。了解Runtime，对理解Objective-C这门语言有很大的帮助。苹果官方提供的有Runtime源码，不幸的是官方提供的源码是不能编译运行的。如果有一个可以编译运行的Runtime源码，我们就可以打断点调试，这对于理解Runtime机制，理解Runtime源码是大有裨益的。因此，这篇文章介绍下如何编译官方提供的Runtime源码。
## 可编译的Runtime源码
由于编译Runtime源码步骤比较多，我在[github](https://github.com/acBool/RuntimeSourceCode)上放了可以直接编译运行、调试的Runtime源码，大家可以从这里下载。不过建议还是亲自动手编译一遍。
## 环境介绍
1. Xcode版本：10.1
2. macOS版本：10.14
3. Runtime版本：objc4-750.1

Runtime源码可以从[苹果开源代码网站](https://opensource.apple.com/release/macos-10141.html)下载。在该页面搜索objc，找到最新的objc4下载即可。
## 编译Runtime源码
下载好Runtime源码之后，就可以开始编译Runtime源码了。编译过程中会遇到很多错误信息，这篇文章主要是我在编译过程中遇到的错误信息以及解决方案，如果大家没有遇到对应的错误信息，直接跳过即可。

下载后的Runtime源码目录结构如下图：

![image](https://note.youdao.com/yws/public/resource/bba39d75a3d87a96f65a409a0b99df90/xmlnote/WEBRESOURCE1bb5fda19d6f9a08fadde71eef2945d2/16984)

双击打开objc.xcodeproj，编译运行即可。

Xcode打开之后如下图：

![image](https://note.youdao.com/yws/public/resource/bba39d75a3d87a96f65a409a0b99df90/xmlnote/WEBRESOURCE9628a6e52d57409b9d903c26924cbd98/16986)

我们的目的就是编译出Products目录下的libobjc.A.dylib。

### 提示i386架构被废弃
编译Runtime源码，遇到的第一个错误信息是i386架构被废弃。
#### 错误信息
错误信息如下：
```
The i386 architecture is deprecated. You should update your ARCHS build setting to remove the i386 architecture. (in target 'objc')
```

```
The i386 architecture is deprecated. You should update your ARCHS build setting to remove the i386 architecture. (in target 'objc-trampolines')
```
target分别是objc和objc-trampolines,意思是i386架构已经被废弃了，需要移出i386架构。
#### 解决方案
解决方案就是移出对应的i386架构。

进入"TARGETS->objc-trampolines->Architecture",将Debug中的 $(ARCHS_STANDARD_32_64_BIT) 改为 $(ARCHS_STANDARD)，如下图：

![image](https://note.youdao.com/yws/public/resource/bba39d75a3d87a96f65a409a0b99df90/xmlnote/WEBRESOURCE0415be8caa82c3cc46570bdea43dacff/16988)

同理，对应的TARGETS objc也是做同样的操作，只不过是在TARGETS下面选择objc，所修改的内容是一样的。

### 提示缺少头文件
在编译过程中，会提示缺少很多头文件，我们要做的就是加入这些头文件。我把需要用到的头文件做了个整理，可以从这里[下载](http://note.youdao.com/yws/public/resource/bba39d75a3d87a96f65a409a0b99df90/xmlnote/WEBRESOURCEaba94c033568545a7b6e005abee7b7ee/17066)。
#### 错误信息
错误信息如下：
```
sys/reason.h file not found
```
sys是文件夹，reason.h是文件名。
#### 解决方案
解决方案就是按照Xcode给的错误提示信息，新建对应的文件夹和头文件。
##### 新建CommonHeaders目录
因为缺少的头文件比较多，为了方便，我们在工程目录下首先新建一个文件夹CommonHeaders，所缺少的文件可以全部放倒该目录下。新建好CommonHeaders之后如下图：

![image](https://note.youdao.com/yws/public/resource/bba39d75a3d87a96f65a409a0b99df90/xmlnote/WEBRESOURCE53431ffb1fefd996767a179b7896e250/16990)

为了让Xcode能找到我们添加的头文件，需要将CommonHeaders添加到Header Search Paths中，步骤："TARGETS->objc->Build Settings",搜索header search，加入$(SRCROOT)/CommonHeaders，DEBUG和RELEASE都要添加。如下图：

![image](https://note.youdao.com/yws/public/resource/bba39d75a3d87a96f65a409a0b99df90/xmlnote/WEBRESOURCE0522bb93f5249880c45ea17cea4f5c82/16992)
##### 添加对应的头文件
在CommonHeaders下新建sys文件夹，并且从刚才下载的头文件中找到reason.h，放到sys文件夹下。编译，对应的错误信息应该就没有了。

除了reason.h，还会提示缺少一些其他的头文件，解决方案是一样的，只是在CommonHeaders下新建不同的文件夹和拷贝不同的文件。提示的错误信息有：
```
'mach-o/dyld_priv.h' file not found
'os/lock_private.h' file not found
'os/base_private.h' file not found
'pthread/tsd_private.h' file not found
'System/machine/cpu_capabilities.h' file not found
'os/tsd.h' file not found
'pthread/spinlock_private.h' file not found
'System/pthread_machdep.h' file not found
'Block_private.h' file not found
'objc-shared-cache.h' file not found
'_simple.h' file not found
```
### pthread_machdep.h编译错误
pthread_machdep.h是我们后续加入的，里面有一些定义和原Runtime源码定义重复了，需要将pthread_machdep.h中的重复定义注释。
#### 错误信息
错误信息如下：
```
Static declaration of '_pthread_has_direct_tsd' follows non-static declaration
```
```
Static declaration of '_pthread_getspecific_direct' follows non-static declaration
```
```
Static declaration of '_pthread_setspecific_direct' follows non-static declaration
```
#### 解决方案
分别将pthread_machdep.h文件中的_pthread_has_direct_tsd、_pthread_setspecific_direct、_pthread_getspecific_direct注释即可。
### 缺少CrashReporterClient.h文件
由于该文件的处理方式较为特别，所以单独说一下。
#### 错误信息如下：
```
'CrashReporterClient.h' file not found
```
#### 解决方案
##### 拷贝CrashReporterClient.h文件
首先将CrashReporterClient.h文件放到CommonHeaders目录下。
##### 修改Preprocessor Macros
"TARGETS->objc->Build Settings",搜索"preprocessor",在Preprocessor Macros中添加 LIBC_NO_LIBCRASHREPORTERCLIENT，DEBUG和RELEASE都添加。
##### 重启Xcode
在我电脑上做完上述操作后，编译，还是提示缺少CrashReporterClient.h文件。这时可以重启下Xcode，应该就没有这个错误信息了。
### objc-runtime-new.mm编译错误
#### 错误信息
错误信息如下：
```
Use of undeclared identifier 'DYLD_MACOSX_VERSION_10_11'
```
使用了未定义的宏。
#### 解决方案
在dyld_priv.h文件头部添加宏：
```
#define DYLD_MACOSX_VERSION_10_11 0x000A0B00
#define DYLD_MACOSX_VERSION_10_12 0x000A0C00
#define DYLD_MACOSX_VERSION_10_13 0x000A0D00
#define DYLD_MACOSX_VERSION_10_14 0x000A0E00
```
dyld_priv.h是我们添加的，在CommonHeaders文件夹下找就可以。
### 缺少isa.h文件
#### 错误信息
错误信息如下：
```
'isa.h' file not found
```
#### 解决方案
之所以将isa.h单独拿出来，是因为isa.h文件的位于最开始我们下载的Runtime源码中，在runtime文件夹下。我们需要把runtime文件夹下的isa.h文件拷贝到CommonHeaders文件夹下。isa.h文件的位置如下图：

![image](https://note.youdao.com/yws/public/resource/bba39d75a3d87a96f65a409a0b99df90/xmlnote/WEBRESOURCEfb557c04c59d74abef3ae9e6b409e52c/16994)

### can't open order file
#### 错误信息
Xcode提示
```
linker command failed with exit code 1(use -v to see invocation)
```
点击之后能看到详细的错误信息：
```
can't open order file: /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.14.sdk/AppleInternal/OrderFiles/libobjc.order
```
#### 解决方案
"TARGETS->objc->Build Settings->Linking->Order File"修改为$(SRCROOT)/libobjc.order
### not found -lCrashReporterClient
#### 错误信息
Xcode提示
```
linker command failed with exit code 1(use -v to see invocation)
```
点击后会看到错误信息：
```
 library not found for -lCrashReporterClient
```
#### 解决方案
"TARGETS->objc->Build Settings->Linking->Other Linker Flags"中删除lCrashReporterClient，DEBUG和RELEASE都删除，如下图：

![image](https://note.youdao.com/yws/public/resource/bba39d75a3d87a96f65a409a0b99df90/xmlnote/WEBRESOURCEfedc94d239897848f4568e5a81db4e3b/16996)
### macosx.internal 不能被加载
#### 错误信息
错误信息如下：
```
SDK "macosx.internal" cannot be located 和  unable to find utility "clang++", not a developer tool or in PATH
```
#### 解决方案
"TARGETS->objc->Build Phases->Run Script"，将脚本里面的macosx.internal改为macosx。如下图：

![image](https://note.youdao.com/yws/public/resource/bba39d75a3d87a96f65a409a0b99df90/xmlnote/WEBRESOURCEfab68f609ad557b06687d8ed620f6283/16998)

### 缺少Public Header File
#### 错误信息
错误信息如下：
```
no such public header file: '/tmp/objc.dst/usr/include/objc/ObjectiveC.apinotes'
```
#### 解决方案
1. "TARGETS->objc->Build Settinngs->Text-Based API->Other Text-Based InstallAPI Flags"，将里面的内容设置为空。如下图
 
![image](https://note.youdao.com/yws/public/resource/bba39d75a3d87a96f65a409a0b99df90/xmlnote/WEBRESOURCEe04a86efdfe97ff59fa1986bc57c2400/17000)

![image](https://note.youdao.com/yws/public/resource/bba39d75a3d87a96f65a409a0b99df90/xmlnote/WEBRESOURCEeae928bf18fb14a355bc988b747c5460/17002)
2. 将Text-Based InstallAPI Verification Mode改为Errors Only，如下图

![image](https://note.youdao.com/yws/public/resource/bba39d75a3d87a96f65a409a0b99df90/xmlnote/WEBRESOURCE5506845e5c59461bcb4fe23e48095dc8/17004)

## 编译完成
做完上述操作后，再次编译，应该就可以编译通过了，编译通过后的项目如下图：

![image](https://note.youdao.com/yws/public/resource/bba39d75a3d87a96f65a409a0b99df90/xmlnote/WEBRESOURCE3c3604de102f285a4563d470dc781d63/17006)

注意看Products目录下的libobjc.A.dylib和libobjc-trampolines.dylib现在都不是红色了，说明这两个动态库都已经编译成功了。

最终CommonHeaders下面的目录如下图：

![image](https://note.youdao.com/yws/public/resource/bba39d75a3d87a96f65a409a0b99df90/xmlnote/WEBRESOURCE5546f78d7bb4e21bd27d24e9d33e841e/17008)

## 调试Runtime
编译Runtime的目的是为了调试Runtime,为了调试Runtime，需要在Runtime工程下增加一个新的Target。
### 添加新的Target
Xcode->File->New->Target,选择macOS->Command Line Tool，如下图：

![image](https://note.youdao.com/yws/public/resource/bba39d75a3d87a96f65a409a0b99df90/xmlnote/WEBRESOURCEaa5279a858ea70ff6e03536d12c2c73e/17010)

比如命名为runtimeTest。

添加新的Target后的项目截图如下：

![image](https://note.youdao.com/yws/public/resource/bba39d75a3d87a96f65a409a0b99df90/xmlnote/WEBRESOURCE43b8e1dcdb985a16b928658ffd4355f3/17012)

### 为新的Target添加依赖
为runtimeTest添加依赖，使用我们自己编译的动态库。

Targets->runtimeTest->Build Phase->Target Dependencies，选择objc。选择完之后如下图

![image](https://note.youdao.com/yws/public/resource/bba39d75a3d87a96f65a409a0b99df90/xmlnote/WEBRESOURCE8932a421992376fff8c45fd34e48ff4f/17014)

### 运行runtimeTest
现在就可以在runtimeTest目录下的main.m文件中添加代码，并在Runtime源码中加断点了，运行main.m，会走到Runtime源码的断点中。运行runtimeTest之前，需要将Xcode顶部的Target改为runtimeTest，如下图

![image](https://note.youdao.com/yws/public/resource/bba39d75a3d87a96f65a409a0b99df90/xmlnote/WEBRESOURCE78b309f2b193a214274411df2966e7c1/17205)