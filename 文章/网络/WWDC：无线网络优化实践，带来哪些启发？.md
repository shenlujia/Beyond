网络技术作为互联网应用赖以存在的技术基础，速度与安全永远是其核心使命，本次WWDC的网络类topic涵盖内容基本还是围绕这两个点来展开。本次WWDC网络类session在基础网络技术上譬如新协议、新算法方面着墨并不多；也未提出新的类似NSURLSession / Network.framework之类的新网络组件。站在应用视角，本次WWDC网络类session可分为两大类：



- - 无线网络体验优化实践在系统层面的标准化；
  - 本地网络应用的权限管控增强。



在第一类议题中，我们看到很多已经在手淘中的类似实践，或标准或自研，说明手淘在网络技术的开发与应用上还是较为深入和前沿的，基本走在全球业界前列。根据我们手淘的业务特点，笔者重点关注第一类session，并简单探讨该新技术可以我们带来什么样启发和变化。





# 

# **使用加密DNS**

------



DNS解析是网络的连接的第一步，这里提到的"加密DNS"是什么、它解决什么问题？



#### **▐**  **解决什么问题**



一是传统Local DNS的查询与回复均基于非加密UDP，我们常见的DNS劫持问题



![image.png](https://mmbiz.qpic.cn/mmbiz_png/33P2FdAnju99Pg7S9548JB5fW3QeRbnzgHtFx1XicCahsdtgnAcgZKJwuda02VicFN53Kpdibib8qV6K0SBFITqVpw/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)



二是Local DNS Server本身不可信，或者本地Local DNS 服务不可用。



![image.png](https://mmbiz.qpic.cn/mmbiz_png/33P2FdAnju99Pg7S9548JB5fW3QeRbnziaq4RBFP3ViajzPagmz2Jp3ryFX5nuU1Y4vQzFricHXdicR2Vz2erbobHQ/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)



其实针对DNS解析过程中以上两个问题，在实践中早就有了解决方案，就是HTTPDNS, 各大云厂商也都有成熟产品售卖，那苹果这里的加密DNS与我们的现有HTTPDNS有何不同呢？



现有HTTPDNS有两个很大的问题：



- 一是对业务的侵入性，即如果某个网络连接需要使用HTTPDNS的能力，首先他需要集成服务商提供的SDK, 引入相应的Class，然后修改网络连接的阶段的代码；
- 二是面临各种技术坑，比如302场景的IP直连处理、WebView下IP直连如何处理Cookie、以及iOS上的老大难的SNI问题等，这些都需要业务开发者付出极大的努力和尝试。



iOS 14 上的 Encrypted DNS 功能很好的解决了现有HTTPDNS的存在的问题。



#### **▐**  **规范与标准**



iOS 14 开始系统原生支持两种标准规范的 Encrypted DNS, 分别是 DNS over TLS 与 DNS over HTTPS.



![image.png](https://mmbiz.qpic.cn/mmbiz_png/33P2FdAnju99Pg7S9548JB5fW3QeRbnzMjibOd7ia2rodwpc2ls3AiajJVZibxx2PicUGRr7gJpNkAI6O8ftgocljMg/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)



具体协议标准可以参见：rfc7858 (DoT) 、rfc8484 (DoH)



#### **▐**  **如何实现**



iOS 14 提供了两种设置加密DNS的方法。第一种方式是选择一个DNS服务器作为系统全局所有App默认的DNS解析器，如果你提供的是一个公共DNS服务器，你可以使用NEDNSSettingsManager API编写一个NetworkExtension App完成系统全局加密DNS设置。或者如果你使用MDM(Mobile Device Management)管理设备的企业设置；你可以推送一个包含DNSSettings paload的profile文件完成加密DNS设置。



![image.png](https://mmbiz.qpic.cn/mmbiz_png/33P2FdAnju99Pg7S9548JB5fW3QeRbnzsLotM4M0hzXbDA74yrQYlMlr8SQTsyXrwZerm96DWHpSv29kHL9nCw/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)



使用NetworkExtension设置系统域全局DNS服务器示例代码：



![图1.png](https://mmbiz.qpic.cn/mmbiz_png/33P2FdAnju99Pg7S9548JB5fW3QeRbnzee42uW7MvTsZuy3ic7bWPdKVunUiaw4bpLMbdptNFlZhDEdKMbDOQ7Vg/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)



上述代码首先通过NEDNSSettingsManager加载配置，加载成功后，创建一个基于DoH协议的NEDNSOverHTTPSSettings实例，对其配置DNS IP地址和域名，DNS IP地址是可选配置的。然后将NEDNSOverHTTPSSettings实例配置到NEDNSSettingsManager共享实例的dnsSettings属性，最后保存配置。



一条DNS配置包括DNS服务器地址、DoT/DoH协议、一组网络规则。网络规则确保DNS设置兼容不同的网络。因为公共DNS服务器是无法解析本地网络的私有域名，比如只有企业WiFi网络内的DNS服务器可以解析员工访问的私有域名，这类情况就需要手动指定网络规则兼容企业WiFi网。



网络规则可以针对不同网络类型定义行为，比如蜂窝网、WiFi、或者具体的WiFi SSID。在匹配的网络下，你可以禁用配置的全局DNS设置，或者对私有域名不使用DNS设置。



而在一些情况下，兼容性会自动处理。比如强制门户网络(captive portal), 手机在连接上某个WiFi的时候，自动弹出一个页面输入账号密码才能连接网络。这种情况下系统域全局DNS配置会做例外处理。相类似的，对于VPN网络，在VPN隧道内的解析将使用VPN的DNS设置，而不使用系统域DNS配置。



网络规则设置示例代码：



![图2.png](https://mmbiz.qpic.cn/mmbiz_png/33P2FdAnju99Pg7S9548JB5fW3QeRbnzSUtcyCDEmTtGoxUqDn2IicTF1naRItQB1olTuBpPCMWubRmgqLS02icA/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)



上述代码设置了三个网络规则，第一个规则表示DNS配置应该在SSID="MyWorkWiFi"的WiFi网络生效，但对私有企业域名enterprise.example.net不开启。第二个规则表示规则在蜂窝网下应该被禁止使用;第三个NEOnDemandRuleConnect表示DNS配置应该默认开启;因为配置DNS是系统支持的，所以在编写NetworkExtension App时不需要实现Extension程序，只需要在Network Extensions中勾选DNS Settings选项。



![图7.png](https://mmbiz.qpic.cn/mmbiz_png/33P2FdAnju99Pg7S9548JB5fW3QeRbnzx3geC8xJNIAyNGyGvUpIp2Kfp5eFQiaJc9zGDPiba7SceYmZZPYv2yBQ/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)



运行NetworkExtension App，DNS配置将会被安装到系统，为了让DNS配置生效，需要前往设置->通用->VPN & Network->DNS手动启用。



![图3.png](https://mmbiz.qpic.cn/mmbiz_png/33P2FdAnju99Pg7S9548JB5fW3QeRbnzuk1tlRxJs17fo4eNwqibiaH91re11WZVAgwpvaZQOWYf42ibAtPV6mrMg/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)



一些网络可能会通过策略阻止你使用加密的DNS服务器。这些网络尝试分析DNS查询请求来过滤流量。对于此类网络，系统会被标记隐私警告提示，在该网络下的网络连接将会失败。



![图4.png](https://mmbiz.qpic.cn/mmbiz_png/33P2FdAnju99Pg7S9548JB5fW3QeRbnzAiaUc9M93UZNZt5iahS12icDFhKhpWHuuKkI4ZAGTflOa9acJQdJVMQTA/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)



第二种方式是针对单个App的所有连接或部分连接启用加密DNS。



![image.png](https://mmbiz.qpic.cn/mmbiz_png/33P2FdAnju99Pg7S9548JB5fW3QeRbnzWseJxMCLlA4qreItkHI0oQBdHWljIVjnpiaqoyPcKGVpMdr8tVPuzRQ/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)



如果你只想为你的App使用加密DNS，而非涉及整个系统域。你可以适配Network framework的PrivacyContext，对你的整个App开启加密DNS，或者仅对某一连接开启。不管使用的是URLSessionTask，或Network framework连接或getaddrinfo的POSIX API，这种方式都有效。



对单个连接使用加密DNS示例代码：



![图5.png](https://mmbiz.qpic.cn/mmbiz_png/33P2FdAnju99Pg7S9548JB5fW3QeRbnzIclPG2UcynWTO7zj2dCGEKbRkQtKHVMW1dP91d7N2LlOoI5vOypIFg/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)



验证请求是否使用加密DNS：



![截屏2020-06-26 上午1.24.27.png](https://mmbiz.qpic.cn/mmbiz_png/33P2FdAnju99Pg7S9548JB5fW3QeRbnzNql558XtzRC02pTI4ibD5mNRyeUMaWTutEqmQX7ibVXrFQA5hx9plprQ/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)



如果你想在App范围内使用加密DNS，你可以配置默认的PrivacyContext；App内发起的每个DNS解析都会使用这个配置。不管是URLSessionTask，还是类似getaddrinfo的底层API。



![图6.png](https://mmbiz.qpic.cn/mmbiz_png/33P2FdAnju99Pg7S9548JB5fW3QeRbnzkTT9D8lj1p5sSjKUCydXYhLSERA7BOTZ840ibIBJvjcTibfz2jSrlL0w/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

##  

#### **▐**  **现有实践对比及启发**



- **与现有实践对比**



上文已经提到过HTTPDNS产品，手淘的域名解析，采用的是类似于HTTPDNS原理，但更加复杂的调度方案。但是相比于这种系统层面的标准化方案，解决了现有实践中的两大难题：



- - 对业务的侵入性：业务必须修改现有网络连接的阶段的代码；
  - 交互的标准兼容性不足：IP直连下的302问题、Cookie问题、SNI问题等  

- **带来的变化**



一是在应用内部，我们可以对业务透明提供提供全局的域名调度或者域名兜底解析能力, 不再是只有用到特定组件或SDK才可以。二是苹果放开系统级别DNS接管后，用户设备上的服务相比原Local DNS的“中立性”如何管控？对特定业务是否甚至会造成恶化？如果对外部应用的这种“中立性”疑问或担心确实存在，则这种系统标准化的加密DNS对手淘这种大型应用则是必选项。



#  

# **受限网络中推送**

------

##  

#### **▐**  **解决什么问题**



当向iOS设备推送消息时，业务服务器需要将消息先发送给APNS服务器，APNS服务器再将消息转换为通知payload推送给目标设备。如果设备所在的WiFi网络没有连接互联网或者当前网络受限，比如在游艇、医院、野营地这些地方，设备没有与APNS服务器建立有效连接，APNS消息投递将会失败。



![截屏2020-06-27 上午12.46.47.png](https://mmbiz.qpic.cn/mmbiz_png/33P2FdAnju99Pg7S9548JB5fW3QeRbnzIwAD4MibW1YM45VHvFBEVom1WKTmBXeY8WKu9UrpwZFbdiasiaM6LOtqw/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)



对于一些App来说，接收推送消息是App的一项非常重要的功能，即使在没有互联网连接的情况下也需要持续稳定工作。为了满足这一需求，iOS 14中增加了本地推送连接(Local Push Connectivity)API，这是NetworkExtension家族中新的API。本地推送连接API允许开发者创建自己的推送连接服务，通过开发一个App Extension，在指定的WiFi网络下可以直接与本地业务服务器通信。



![截屏2020-06-27 上午1.02.19.png](https://mmbiz.qpic.cn/mmbiz_png/33P2FdAnju99Pg7S9548JB5fW3QeRbnzy9T9kDpOhLZcm32VA9aZEibMYZOTcfsVmp4FnjPlxK7J4ZDWT4ULlzQ/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)



上图中，App Extension主要负责保持与本地业务服务器之间的连接，以及接收业务服务器发来的通知。因为没有了APNS，开发者需要为业务服务器与App Extension定义自己的通信协议。主App需要配置具体在哪个WiFi网络下使用本地推送连接。当App加入到指定的WiFi网络，系统会拉起App Extension, 并在后台持续运行。当App断开与指定WiFi网络的连接，系统将停止App Extension运行。



#### **▐**  **如何实现**



本地推送连接对那些推送功能非常重要，而设备所在网络受限的场景非常适合。而对于常规的推送需求，依然推荐使用PushKit或UserNotification API处理APNS推送消息。每台设备和APNS服务器之间只建立一条APNS连接，设备上所有App都公用这一条连接，所以APNS非常省电。



APNS与本地推送连接对比：



![截屏2020-06-27 上午1.25.28.png](https://mmbiz.qpic.cn/mmbiz_png/33P2FdAnju99Pg7S9548JB5fW3QeRbnzJicBHVaMlPicJsNrbIpib8rjJ7d17FtXQEkAxxCTjoTgxVlic5Q16L3kbw/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)



新的本地推送连接API由两个类组成：NEAppPushManager和NEAppPushProvider。NEAppPushManager在主App中使用，主App使用NEAppPushManager创建一个配置，配置中指定具体哪个WiFi网络下运行本地推送连接。你可以使用NEAppPushManager加载/移除/保存配置。NEAppPushProvider则在App Extension使用。在App Extension中实现一个NEAppPushProvider的子类，子类中需要覆盖生命周期管理方法，这些方法在App Extension运行和停止时被调用。



App Extension主要处理两类推送，一类是常规的推送通知，一类是VoIP呼叫通知。如果是常规的推送通知，App Extension收到消息后，可以使用UserNotification API构造一个本地推送显示推送信息。如果是VoIP呼叫通知，App Extension使用NEAppPushProvider类将呼叫信息报告给系统。如果此时主App不在运行，系统将唤醒主App，并将消息投递给它，最后主App再使用CallKit API显示呼叫界面。



![截屏2020-06-27 上午11.40.13.png](https://mmbiz.qpic.cn/mmbiz_png/33P2FdAnju99Pg7S9548JB5fW3QeRbnzM8Nqfuf3wlhbURdReiagzVorOmwD8OzmwfX2NVZldnHpQ6DyF4KWllA/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)



下面是在主App中使用NEAppPushManager的示例代码：



![截屏2020-06-27 上午1.44.40.png](https://mmbiz.qpic.cn/mmbiz_png/33P2FdAnju99Pg7S9548JB5fW3QeRbnzevASSlibtpMNm3WAnPP4HwRmGo7mANlZPlzOEic6yJX7M9759pWhHVvA/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)



上述代码创建了一个NEAppPushManager实例，并配置实例的各个属性值。matchSSIDs表示在指定的WiFi网络下才启用本地推送连接。providerBundleIdentifier表示App Extension的包名，providerConfiguration是传给App Extension的一些配置，在App Extension内可以通过NEAppPushProvider的providerConfiguration属性获取。isEnabled表示使用这个配置开启本地推送连接。最后调用saveToPreferences方法持久化配置。下面是App Extension实现NEAppPushProvider子类的示例代码：



![截屏2020-06-27 上午1.46.47.png](https://mmbiz.qpic.cn/mmbiz_png/33P2FdAnju99Pg7S9548JB5fW3QeRbnz1NBd1GVM62icYGjUSGOYCbNicK1UZVWfzfe4ibvGy855GKXbzvjSKAShA/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)



系统调用start(completionHandler:)方法启动App Extension，在这个方法内App Extension与本地业务服务器建立连接。当App Extension停止运行，系统调用stop(with:)方法, 在这个方法内App Extension断开与业务服务器的连接。handleIncomingVoIPCall(callInfo:)方法在收到VoIP呼叫时被调用，在方法内App Extension调用reportIncomingCall(userInfo:)将该事件上报给系统。随后系统将会唤醒主App，并将呼叫信息传递给主App。主App处理系统传入的呼叫信息示例代码：



![图8.png](https://mmbiz.qpic.cn/mmbiz_png/33P2FdAnju99Pg7S9548JB5fW3QeRbnzKdVwDjENVNxW8k6UjibzaoPXv7icmvWx8BRqsQmg1eG0fGPicPS0MSbBA/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)



以上代码在AppDelegate的didFinishLaunchingWithOptions方法内使用NEAppPushManager加载所有配置，并设置每个NEAppPushManager示例的代理属性。系统会在主线程中将接收到呼叫信息通过didReceiveIncomingCallWithUserInfo方法投递给主App。主App必须通过CallKit API将呼入信息上报给CallKit展示呼叫界面。



#### **▐**  **价值场景**



如果只考虑推送本身，对于手淘或者大部分消费类应用来说，笔者认为价值并不大，因为此类APP不可能在一个封闭的本地网络里去部署资源来提供服务能力。这里一个可应用的点在于：设备一旦进入特定网络环境，触发App Extension, 进而唤起主App，应用可在后台完成一定事务。因为 iOS App 一直缺乏后台服务能力，这种特定网络环境的触发唤醒，极大的补充了这一能力。



#  

# **现代网络技术的应用**

------



苹果在这次WWDC中，把一些较新的网络技术，对应用的体验提升，做了一个简单综述，包括IPv6、HTTP/2、TLS1.3, MTCP、以及HTTP/3。这些技术在手淘基本都有涉及，有些是已经是大规模部署、有些是正在逐步推进中。对各个应用来说，如果已经在应用这些技术了，则云端均尽可能标准化，便于进一步推广和复用。这里简单的对苹果的综述做一个搬运：

##  

#### **▐**  **IPv6**



苹果根据最新统计，苹果全球设备TCP连接占比中，IPv6占比26%，IPv4占比74%，其中74%的占比中有20%是因为服务端没有开启IPv6支持。在建连时间方面，由于减少了NAT使用，提高了路由效率，IPv6的建连时间比IPv4快1.4倍。开发者只需使用URLSession和Network.framework API，IPv6网络适配将自动支持。



![截屏2020-06-29 下午7.44.02.png](https://mmbiz.qpic.cn/mmbiz_png/33P2FdAnju99Pg7S9548JB5fW3QeRbnzdicFe43YR6u5TIibEZK67NNIhSIBPF9WZXYcyicZC2zUxNaKsnK1ZgTlg/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)



以上是苹果的数据。阿里巴巴集团从18年开始大力推进IPv6的建设，目前我们在IPv6整体应用规模上在业界是属于头部大厂。但根据我们应用的实际效果数据，以及业界友商的应用数据，性能提升并不明显。以及工信部的IPv6建设目标来看，性能提升也不是IPv6建设的目标，只要达到IPv4同等水平即可。IPv6 的意义就在解决IPv4地址空间枯竭的问题，更多的在规模、安全，而不是性能提升。就企业而言，例如可以降低IPv4地址的购买费用；就国家而言，IPv6 突破了IPv4中国境内无DNS根结点的风险。IPv6目前阶段在国内尚处于发展中，基础运营商覆盖、家用网络接入设备支持、应用服务的支持，正在快速发展中。



#### **▐**  **HTTP/2**



HTTP/2的多路复用特性使得对同一服务器的多个请求复用到单个连接上，不必等待前一个请求响应结束才能发送下一个请求，不仅节省了时间也提升了性能。头部压缩特性提升了带宽利用率，通过简化消息内容，从而降低消息的大小。根据最新统计，在Safari中HTTP2 Web流量占比79%，HTTP/2比HTTP/1.1快1.8倍。如果服务端支持HTTP/2，URLSession将默认使用HTTP/2。



![截屏2020-06-29 下午11.02.47.png](https://mmbiz.qpic.cn/mmbiz_png/33P2FdAnju99Pg7S9548JB5fW3QeRbnzP8vM0pl6QuiagEzymFyZOOd3TibxokclSIIXAricNDnYx0AJ7m3RPLA6Q/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)



在手淘业务中，全面应用HTTP2已经有三四年之久，其使用规模比苹果统计的结果要高的多，取得了巨大的体验提升收获。手淘的核心流量分为两类：API请求MTOP于图片CDN请求，这两类的HTTP2的流量占比约超过 98%，基本实现核心流量全部长连化。但当前手淘的HTTP2技术在设备支持之前即大规模应用，协议栈完全自研，为进一步提升建联速度，又做了一些预置证书的优化。下一步将逐步使基础网络依赖标准化平台能力，降低对私有协议栈的依赖，可降低包大小以及提升产品复用体验。



#### **▐**  **TLS1.3**



TLS1.3通过减少一次握手减少了建连时间，通过形式化验证(Formal Verification)与减少被错误配置的可能性，提高了通信安全。从iOS 13.4开始，TLS1.3默认在URLSession和Network.framework开启。根据最新统计，在最新的iOS系统上，大约49%的连接使用TLS1.3。使用TLS1.3比使用TLS1.2建连时间快1.3倍。如果服务端支持TLS1.3，URLSession将默认使用TLS1.3。



![截屏2020-06-29 下午11.02.24.png](https://mmbiz.qpic.cn/mmbiz_png/33P2FdAnju99Pg7S9548JB5fW3QeRbnzsicKktfjxFwSwA6OtzRTehpsDiajZibBE1VQ3c6uQvgzibO2V6WBukgoXQ/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)



目前手淘的HTTP/2 的TLS version仍然还是基于TLS1.2，不过为了解决低版本TLS的性能之殇，手淘网络通过预置证书与自定义 SSL 握手流程，创新自研了slight-ssl协议，实现了 0rtt 的效果。TLS 1.3 标准在系统层面的全面支持，对应用来说是一个明确的技术趋势信号，我们的网络协议需尽快标准化，对网络管道两端来说，客户端应用层网络接口需全面升级到NSURLSession或Network.framework, 实现对系统标准能力的应用；云端也许全面支持TLS1.3，可不依赖端侧SDK即可提供更新安全、高效、标准的网连接。



#### **▐**  **MultiPath TCP**



MultiPath TCP 允许在一条TCP链路中建立多个子通道。当设备切换网络时，单个TCP连接依然可以继续使用。苹果的Apple Music与Siri服务都使用了MultiPath TCP。Apple Music在使用MultiPath TCP之后,音乐播放卡顿次数减少了13%,卡顿持续时间减少了22%。开启MultiPath TCP需要客户端和服务端都支持才能生效，服务端支持MultiPath TCP可参考：http://multipath-tcp.org/

其实手淘在这方面也有类似的优化尝试：多网卡：同时通过Wi-Fi与蜂窝网连接目标服务器，提升数据传输速度。其技术原理与MTCP不一样，但也是想在上层起到类似作用：通过多路连接，提升数据交换带宽。业界也有类似的产品，例如华为的 LinkTurbo。



#### **▐**  **HTTP/3**



HTTP/3是下一代HTTP协议，它是构建在新的QUIC传输协议之上，QUIC协议内建了对TLS1.3的支持，并提供了与HTTP/2一样的多路复用功能，并进一步减少了队头阻塞的发生，让单个请求或相应的丢失不影响到其他请求。使用QUIC的HTTP/3还具有较高的保真度信息，以提供改进的拥塞控制和丢包恢复。同时也包括内建的移动性支持，这样网络切换不会导致正在进行的操作失败，可以无缝在不同网络之间切换。不过HTTP/3目前还处于草案阶段，iOS 14和MacOS Big Sur包括了一个对使用URLSession的HTTP/3的实验预览支持，这个功能可以在开发者设置中开启。同时Safari的HTTP/3支持也可在开发者设置中开启。



![截屏2020-06-30 上午12.48.15.png](https://mmbiz.qpic.cn/mmbiz_png/33P2FdAnju99Pg7S9548JB5fW3QeRbnzFmF8hpAJwwicmL2yHrdBAvH1AvLvwT1SribmicxdkDNVuow8hCnGDgzug/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)



在手淘中，我们的QUIC应用应该会早于苹果系统先行支持，目前已经在灰度中。