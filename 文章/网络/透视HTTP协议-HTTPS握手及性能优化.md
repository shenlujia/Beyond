### HTTPS建立连接

当你在浏览器地址栏里键入”https“开头的URI，再按下回车，会发生什么呢？

浏览器首先要从URI里提取出协议名和域名。因为协议名是”https“，所以浏览器就知道了端口号是默认的443，它再用DNS解析域名，得到目标的IP地址，然后就可以使用三次握手与网站建立TCP连接了。

在HTTP协议里，建立连接后，浏览器会立即发送请求报文。但现在是HTTPS协议，它需要再用另外一个”握手“过程，在TCP上建立安全连接，之后才是收发HTTP报文。

这个”握手“过程与TCP有些类似，是HTTPS和TLS协议里最重要、最核心的部分，懂了它，你就可以自豪地说自己”掌握了HTTPS“。

#### TLS协议的组成

TLS包含几个子协议，比较常用的有记录协议、警报协议、握手协议、变更密码规范协议等：

- 记录协议（Record Protocol）规定了TLS收发数据的基本单位：记录（record）。它有点像是TCP里的segment，所有的其他子协议都需要通过记录协议发出。但多个记录数据可以在一个TCP包里一次性发出，也并不需要像TCP那样返回ACK。
- 警报协议（Alert Protocol）的职责是向对方发出警报信息，有点像是HTTP协议里的状态码。比如，protocol_version就是不支持旧版本，bad_certificate就是证书有问题，收到警报后另一方可以选择继续，也可以立即终止连接。
- 握手协议（Handshake Protocol）是TLS里最复杂的子协议，要比TCP的SYN/ACK复杂的多，浏览器和服务器会在握手过程中协商TLS版本号、随机数、密码套件等信息，然后交换证书和密钥参数，最终双方协商得到会话密钥，用于后续的混合加密系统。
- 变更密码规范协议（Change Cipher Spec Protocol），它非常简单，就是一个”通知“，告诉对方，后续的数据都将使用加密保护。那么反过来，在它之前，数据都是明文的。

下面的这张图简要地描述了TLS的握手过程，其中每一个”框“都是一个记录，多个记录组合成一个TCP包发送。所以，最多经过两次消息往返（4个消息）就是完成握手，然后就可以在安全的通信环境里发送HTTP报文，实现HTTPS协议。



![img](https://user-gold-cdn.xitu.io/2020/6/19/172ccbbbc1ed1422?imageView2/0/w/1280/h/960/ignore-error/1)



#### ECDHE握手过程

握手的详细图如下：



![img](https://user-gold-cdn.xitu.io/2020/6/19/172ccbc0c720a914?imageView2/0/w/1280/h/960/ignore-error/1)



在TCP建立连接之后，浏览器会首先发一个”Client Hello“消息，也就是跟服务器”打招呼“。里面有客户端的版本号、支持的密码套件，还有一个随机数（Client Random），用于后续生成会话密钥。

```
Handshake Protocol: Client Hello
    Version: TLS 1.2 (0x0303)
    Random: 1cbf803321fd2623408dfe…
    Cipher Suites (17 suites)
        Cipher Suite: TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256 (0xc02f)
        Cipher Suite: TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384 (0xc030)
复制代码
```

这个的意思就是：“我这边有这些这些信息，你看看哪些是能用的，关键的随机数可得留着”

作为“礼尚往来”，服务器收到“Client Hello”后，会返回一个“Server Hello”消息。把版本号对一下，也给出一个随机数（Server Random），然后从客户端的列表里选一个作为本次通信使用的密码套件，在这里它选择了“TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384”。

```
Handshake Protocol: Server Hello
    Version: TLS 1.2 (0x0303)
    Random: 0e6320f21bae50842e96…
    Cipher Suite: TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384 (0xc030)
复制代码
```

这个的意思就是：“版本号对上了，可以加密，你的密码套件挺多，我选一个最合适的吧，用椭圆曲线加RSA、AES、SHA384。我也给你一个随机数，你也得留着。”

然后，服务器为了证明自己的身份，就把证书也发给了客户端（Server Certificate）。

接下来是一个关键的操作，因为服务器选择了ECDHE算法，所以它会在证书后发送“Server Key Exchange”消息，里面是椭圆曲线的公钥（Server Params），用来实现密钥交换算法，再加上自己的私钥签名认证。

```
Handshake Protocol: Server Key Exchange
    EC Diffie-Hellman Server Params
        Curve Type: named_curve (0x03)
        Named Curve: x25519 (0x001d)
        Pubkey: 3b39deaf00217894e...
        Signature Algorithm: rsa_pkcs1_sha512 (0x0601)
        Signature: 37141adac38ea4...
复制代码
```

这相当于说：“刚才我选的密码套件有点复杂，所以再给你个算法的参数，和刚才的随机数一样有用，别丢了。为了防止别人冒充，我又盖了个章。”

之后是“Server Hello Done”消息，服务器说：“我的信息就是这些，打招呼完毕。”

这样第一个消息往返就结束了（两个TCP包），结果是客户端和服务器通过明文共享了三个信息：Client Random、Server Random和Server Params。

客户端这时也拿到了服务器的证书，开始走证书链逐级验证，确认证书的真实性，再用证书公钥验证签名，就确认了服务器的身份：“刚才跟我打招呼的不是骗子，可以接着往下走。”

然后，客户端按照密码套件的要求，也生成一个椭圆曲线的公钥（Client Params），用“Client Key Exchange”消息发给服务器。

```
Handshake Protocol: Client Key Exchange
    EC Diffie-Hellman Client Params
        Pubkey: 8c674d0e08dc27b5eaa…
复制代码
```

现在客户端和服务器手里都拿到了密钥交换算法的两个参数（Client Params、Server Params），就用ECDHE算法一阵算，算出了一个新的东西，叫“Pre-Master”，其实也是一个随机数。

现在客户端和服务器手里有了三个随机数：Client Random、Server Random和Pre-Master。用这三个作为原始材料，就可以生成用于加密会话的主密钥，叫“Master Secret”。而黑客因为拿不到“Pre-Master”，所以也就得不到主密钥。

主密钥有48字节，但它也不是最终用于通信的会话密钥，还会再用PRF扩展出更多的密钥，比如客户端发送用的会话密钥（client_write_key）、服务器发送用的会话密钥（server_write_key）等等，避免只用一个密钥带来的安全隐患。

有了主密钥和派生的会话密钥，握手就快结束了。客户端发一个”Change Cipher Spec“，然后再发一个”Finished“消息，把之前所有发送的数据做个摘要，再加密一下，让服务器做个验证。

意思就是告诉服务器：“后面都改用对称算法加密通信了啊，用的就是打招呼时说的 AES，加密对不对还得你测一下。”

服务器也是同样的操作，发“Change Cipher Spec”和“Finished”消息，双方都验证加密解密 OK，握手正式结束，后面就收发被加密的 HTTP 请求和响应了。

#### RSA握手过程

刚才说的其实是如今主流的 TLS 握手过程，这与传统的握手有两点不同。

第一个，使用 ECDHE 实现密钥交换，而不是 RSA，所以会在服务器端发出“Server Key Exchange”消息。

第二个，因为使用了 ECDHE，客户端可以不用等到服务器发回“Finished”确认握手完毕，立即就发出 HTTP 报文，省去了一个消息往返的时间浪费。这个叫“TLS False Start”，意思就是“抢跑”，和“TCP Fast Open”有点像，都是不等连接完全建立就提前发应用数据，提高传输的效率。



![img](https://user-gold-cdn.xitu.io/2020/6/19/172ccbc71bb82bfb?imageView2/0/w/1280/h/960/ignore-error/1)



流程如上图所示，大体没有变，只是”Pre-Master“不再需要用算法生成，而是客户端直接生成随机数，然后用服务器的公钥加密，通过”Client Key Exchange“消息发给服务器。服务器再用私钥解密，这样双方也实现了共享三个随机数，就可以生成主密钥。

#### 双向认证

不过上面说的是“单向认证”握手过程，只认证了服务器的身份，而没有认证客户端的身份。这是因为通常单向认证通过后已经建立了安全通信，用账号、密码等简单的手段就能够确认用户的真实身份。

但为了防止账号、密码被盗，有的时候（比如网上银行）还会使用 U 盾给用户颁发客户端证书，实现“双向认证”，这样会更加安全。

双向认证的流程也没有太多变化，只是在“Server Hello Done”之后，“Client Key Exchange”之前，客户端要发送“Client Certificate”消息，服务器收到后也把证书链走一遍，验证客户端的身份。

### TLS1.3特性解析

首先我们来了解下TLS1.3的三个主要改进目标：兼容、安全与性能

#### 1. 最大化兼容性

在早期的实验中发现，一旦变更了记录头字段里的版本号，也就是由0x303（TLS1.2）改为0x304（TLS1.3）的话，大量的代理服务器、网关都无法正确处理，最终导致TLS握手失败。

为了保证这些被广泛部署的”老设备“能够继续使用，避免新协议带来的”冲击“，TLS1.3不得不作出妥协，保持现有的记录格式不变，通过”伪装“来实现兼容，使得TLS1.3看上去”像是“TLS1.2。

那么，如何区分1.2和1.3呢？

这要用到一个新的扩展协议（Extension Protocol），通过在记录末尾添加一系列的”扩展字段“来增加新的功能，老版本的TLS不认识它可以直接忽略，这就实现了”后向兼容“。

在记录头的Version字段被兼容性”固定“的情况下，只要是TLS1.3协议，握手的”Hello“消息后面就必须有”supported_Versions“扩展，它标记了TLS的版本号，使用它就能区分新旧协议。

#### 强化安全

TLS1.3在协议里修补了TLS1.2的一些不安全因素：

- 伪随机数函数由PRF升级为HKDF（HMAC-based Extract-and-Expand Key Derivation Function）;
- 明确禁止在记录协议里使用压缩；
- 废除了RC4、DES对称加密算法；
- 废除了ECB、CBC等传统分组模式；
- 废除了MD5、SHA1、SHA-224摘要算法；
- 废除了RSA、DH密钥交换算法和许多命名曲线。 经过这一番“减肥瘦身”之后，TLS1.3 里只保留了 AES、ChaCha20 对称加密算法，分组模式只能用 AEAD 的 GCM、CCM 和 Poly1305，摘要算法只能用 SHA256、SHA384，密钥交换算法只有 ECDHE 和 DHE，椭圆曲线也被“砍”到只剩 P-256 和 x25519 等 5 种。导致现在的TLS1.3里只有5个套件，无论是客户端还是服务器都不会再犯”选择困难症“了。



![img](https://user-gold-cdn.xitu.io/2020/6/19/172ccbcbeec60453?imageView2/0/w/1280/h/960/ignore-error/1)



这里说明下废除RSA和DH密钥交换算法的原因。

浏览器默认会使用ECDHS而不是RSA做密钥交换，是因为它不具有”前向安全“（Forward Secrecy）。一旦私钥泄露或被解出来，那么黑客就能够使用私钥解密出之前所有报文的”Pre-Master“，再算出会话密钥，解出所有密文。这就是所谓的“今日截获，明日解密”。

而ECDHE算法在每次握手时都会生成一对临时的公钥和私钥，每次通信的密钥对都是不同的，也就是“一次一密”，即使黑客花大力气解出了这一次的会话密钥，也只是这次通信被攻击，之前的历史消息不会受到影响，仍然是安全的。

所以现在主流的服务器和浏览器在握手阶段都已经不再使用RSA，改用ECDHE，而TLS1.3在协议里明确废除RSA和DH则在标准层面保证了“前向安全”。

#### 提升性能

HTTPS建立连接时除了要做TCP握手，还要做TLS握手，在1.2中会多花两个消息往返（2-RTT），可能导致几十毫秒甚至上百毫秒的延迟，在移动网络中延迟还会更严重。

现在因为密码套件大幅度简化，也就没有必要再像以前那样走复杂的协商流程了。TLS1.3压缩了以前的“Hello”协商过程，删除了“Key Exchange”消息，把握手时间减少到了“1-RTT”，效率提高了一倍。

![img](https://user-gold-cdn.xitu.io/2020/6/19/172ccbcfb498b056?imageView2/0/w/1280/h/960/ignore-error/1)



其实具体的做法还是利用了扩展。客户端在“Client Hello”消息里直接用“supported_groups”带上支持的曲线，比如P-256、x25519，用“key_share”带上曲线对应的客户端公钥参数，用“signature_algorithms”带上签名算法。

服务器收到后在这些扩展里选定一个曲线和参数，再用“key_share”扩展返回服务器这边的公钥参数，就实现了双方的密钥交换。

#### 握手分析

TLS1.3握手的过程如下图：



![img](https://user-gold-cdn.xitu.io/2020/6/19/172ccbdbbea110e1?imageView2/0/w/1280/h/960/ignore-error/1)



在TCP建立连接之后，浏览器首先还是发一个“Client Hello”。

因为1.3的消息兼容1.2，所以开头的版本号、支持的密码套件和随机数（Client Random）结构都是一样的（不过这时的随机数是32个字节）。

```
Handshake Protocol: Client Hello
    Version: TLS 1.2 (0x0303)
    Random: cebeb6c05403654d66c2329…
    Cipher Suites (18 suites)
        Cipher Suite: TLS_AES_128_GCM_SHA256 (0x1301)
        Cipher Suite: TLS_CHACHA20_POLY1305_SHA256 (0x1303)
        Cipher Suite: TLS_AES_256_GCM_SHA384 (0x1302)
    Extension: supported_versions (len=9)
        Supported Version: TLS 1.3 (0x0304)
        Supported Version: TLS 1.2 (0x0303)
    Extension: supported_groups (len=14)
        Supported Groups (6 groups)
            Supported Group: x25519 (0x001d)
            Supported Group: secp256r1 (0x0017)
    Extension: key_share (len=107)
        Key Share extension
            Client Key Share Length: 105
            Key Share Entry: Group: x25519
            Key Share Entry: Group: secp256r1
复制代码
```

注意“Client Hello”里的扩展，“supported_versions”表示这是TLS1.3，“supported_groups”是支持的曲线，“key_share”是曲线对应的参数。

服务器收到“Client Hello”同样返回“Server Hello”消息，还是要给出一个随机数（Server Random）和选定密码套件。

```
Handshake Protocol: Server Hello
    Version: TLS 1.2 (0x0303)
    Random: 12d2bce6568b063d3dee2…
    Cipher Suite: TLS_AES_128_GCM_SHA256 (0x1301)
    Extension: supported_versions (len=2)
        Supported Version: TLS 1.3 (0x0304)
    Extension: key_share (len=36)
        Key Share extension
            Key Share Entry: Group: x25519, Key Exchange length: 32
复制代码
```

表面上看跟TLS1.2是一样的，重点是后面的扩展。“supported_versions”里确认使用的是TLS1.3，然后在“key_share”扩展带上曲线和对应的公钥参数。

这时只交换了两条消息，客户端和服务器就拿到了四个共享信息：Client Random和Server Random、Client Params和Server Params，两边就可以各自用ECDHE算出“Pre-Master”，再用HKDF生成主密钥“Master Secret”，效率比TLS1.2提高了一大截。

在算出主密钥后，服务器立刻发出“Change Cipher Spec”消息，比TLS1.2提早进入加密通信，后面的证书等就都是加密的了，减少了握手时的明文信息泄露。

这里TLS1.3还有一个安全强化措施，多了个“Certificate Verify”消息，用服务器的私钥把前面的曲线、套件、参数等握手数据加了签名，作用和“Finished”消息差不多。但由于是私钥签名，所以强化了身份认证和防篡改。

这两个“Hello”消息之后，客户端验证服务器证书，再发“Finished”消息，就正式完成了握手，开始收发HTTP报文。

### HTTPS的优化

HTTPS连接大致可以划分成两个部分，第一个是建立连接时的非对称加密握手，第二个是握手后的对称加密报文传输。

由于目前流行的AES、ChaCha20性能都很好，还有硬件优化，报文传输的性能损耗可以说是非常地小，小到几乎可以忽略不计了。所以，通常所说的“HTTPS连接慢”指的就是刚开始建立连接的那段时间。

而TLS影响性能部分如下图：

![img](https://user-gold-cdn.xitu.io/2020/6/19/172ccbe218f64094?imageView2/0/w/1280/h/960/ignore-error/1)



性能优化分硬件优化和软件优化。软件方面的优化还可以再分成两部分：一个是软件升级，一个是协议优化。

软件升级实施起来比较简单，就是把现在正在使用的软件尽量升级到最新版本。

#### 协议优化

应当尽量采用TLS1.3，它大幅度简化了握手的过程，完全握手只要1-RTT，而且更加安全。 如果暂时不能升级到1.3，只能用1.2，那么握手时使用的密钥交换协议应当尽量选用椭圆曲线的ECDHE算法。它不仅运算速度快，安全性高，还支持“False Start”，能够把握手的消息往返由 2-RTT 减少到 1-RTT，达到与 TLS1.3 类似的效果。

另外，椭圆曲线也要选择高性能的曲线，最好是 x25519，次优选择是 P-256。对称加密算法方面，也可以选用“AES_128_GCM”，它能比“AES_256_GCM”略快一点点。

在 Nginx 里可以用“ssl_ciphers”“ssl_ecdh_curve”等指令配置服务器使用的密码套件和椭圆曲线，把优先使用的放在前面，例如：

```
ssl_ciphers   TLS13-AES-256-GCM-SHA384:TLS13-CHACHA20-POLY1305-SHA256:EECDH+CHACHA20；
ssl_ecdh_curve              X25519:P-256;
复制代码
```

#### 证书优化

这里就有两个优化点，一个是证书传输，一个是证书验证。

服务器的证书可以选择椭圆曲线（ECDSA）证书而不是 RSA 证书，因为 224 位的 ECC 相当于 2048 位的 RSA，所以椭圆曲线证书的“个头”要比 RSA 小很多，即能够节约带宽也能减少客户端的运算量，可谓“一举两得”。

客户端的证书验证其实是个很复杂的操作，除了要公钥解密验证多个证书签名外，因为证书还有可能会被撤销失效，客户端有时还会再去访问 CA，下载 CRL 或者 OCSP 数据，这又会产生 DNS 查询、建立连接、收发数据等一系列网络通信，增加好几个 RTT。

CRL（Certificate revocation list，证书吊销列表）由 CA 定期发布，里面是所有被撤销信任的证书序号，查询这个列表就可以知道证书是否有效。但 CRL 因为是“定期”发布，就有“时间窗口”的安全隐患，而且随着吊销证书的增多，列表会越来越大，一个 CRL 经常会上 MB。想象一下，每次需要预先下载几 M 的“无用数据”才能连接网站，实用性实在是太低了。

所以，现在 CRL 基本上不用了，取而代之的是 OCSP（在线证书状态协议，Online Certificate Status Protocol），向 CA 发送查询请求，让 CA 返回证书的有效状态。但 OCSP 也要多出一次网络请求的消耗，而且还依赖于 CA 服务器，如果 CA 服务器很忙，那响应延迟也是等不起的

于是又出来了一个“补丁”，叫“OCSP Stapling”（OCSP 装订），它可以让服务器预先访问 CA 获取 OCSP 响应，然后在握手时随着证书一起发给客户端，免去了客户端连接 CA 服务器查询的时间。

#### 会话复用

我们再回想一下 HTTPS 建立连接的过程：先是 TCP 三次握手，然后是 TLS 一次握手。这后一次握手的重点是算出主密钥“Master Secret”，而主密钥每次连接都要重新计算，未免有点太浪费了，如果能够把“辛辛苦苦”算出来的主密钥缓存一下“重用”，不就可以免去了握手和计算的成本了吗？

这种做法就叫“会话复用”（TLS session resumption），和 HTTP Cache 一样，也是提高 HTTPS 性能的“大杀器”，被浏览器和服务器广泛应用。

会话复用分两种，第一种叫“Session ID”，就是客户端和服务器首次连接后各自保存一个会话的 ID 号，内存里存储主密钥和其他相关的信息。当客户端再次连接时发一个 ID 过来，服务器就在内存里找，找到就直接用主密钥恢复会话状态，跳过证书验证和密钥交换，只用一个消息往返就可以建立安全通信。

#### 会话票证

“Session ID”是最早出现的会话复用技术，也是应用最广的，但它也有缺点，服务器必须保存每一个客户端的会话数据，对于拥有百万、千万级别用户的网站来说存储量就成了大问题，加重了服务器的负担。

于是，又出现了第二种“Session Ticket”方案。它有点类似 HTTP 的 Cookie，存储的责任由服务器转移到了客户端，服务器加密会话信息，用“New Session Ticket”消息发给客户端，让客户端保存。重连的时候，客户端使用扩展“session_ticket”发送“Ticket”而不是“Session ID”，服务器解密后验证有效期，就可以恢复会话，开始加密通信。

#### 预共享密钥

“False Start”“Session ID”“Session Ticket”等方式只能实现 1-RTT，而 TLS1.3 更进一步实现了“0-RTT”，原理和“Session Ticket”差不多，但在发送 Ticket 的同时会带上应用数据（Early Data），免去了 1.2 里的服务器确认步骤，这种方式叫“Pre-shared Key”，简称为“PSK”。

### Q&A

Q：密码套件里的那些算法分别在握手过程中起了什么作用？

Q：你能完整地描述一下 RSA 的握手过程吗？

Q：你能画出双向认证的流程图吗？

Q：TLS1.3 里的密码套件没有指定密钥交换算法和签名算法，那么在握手的时候会不会有问题呢？

Q：结合 RSA 握手过程，解释一下为什么 RSA 密钥交换不具有“前向安全”。

Q：TLS1.3 的握手过程与 TLS1.2 的“False Start”有什么异同？

Q：你能比较一下“Session ID”“Session Ticket”“PSK”这三种会话复用手段的异同吗？


作者：laity0828链接：https://juejin.im/post/6844904195351396360来源：掘金著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。