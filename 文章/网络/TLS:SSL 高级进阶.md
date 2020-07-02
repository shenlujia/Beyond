# TLS/SSL 高级进阶

发布于 2016-10-26

文章摘自: [please call me HR](https://www.villainhr.com/page/2016/10/26/TLS & SSL 快速进阶)

TLS/SLL 是现在网络安全通信比较重要的一环，通过一些列的 key 交换和 key 生成，最终确立加密通道的整个流程。众所周知，TLS/SSL 耗费的时间也是挺可观的，相对于 TCP 的3次 RTT 来说，如果加上 TLS/SSL, 则总的 RTT 时间至少为 4 次。虽然看起来很多，但如果相对于现在的网络环境来说，大概也就每次 20~30ms，这样算下来，估计也就 100ms 左右。这样的时间差还是可以忍受的，不过，这里还没算入 DNS 解析，这个暂时不考虑。而且，TLS/SSL 生成的 sessionkey 如果在有效期内的话，那么这个时间就可以完全忽略掉了。不多说了，我们直接来看下 TLS/SSL 的基本内容。

## TLS 算法

TLS/SSL 其实就是通过非对称加密，生成对称加密的 sessionkey 的过程。对称加密的算法无外乎就 AES，或者使用 Cipher/Decipher 模块。而非对称加密常用的就是 RSA，不过也有使用 Diffie-Hellman (迪菲)。但，较安全性来说，DH 要高一些。因为，RSA 在生成 sessionkey 时，最后是由 browser 生成，然后通过 public key 加密后传给 server 的，这样存在一定的问题是，如果 hacker 得到了 private key，那么，他可以全程监控流量，然后使用 private key 进行解密，那么可想而知，sessionkey 也就暴露了。
但对于 DH 来说，它机制的不同点在于，sessionkey 不会通过网络传输，而是在两端独立生成的。ok~ 这就涉及到两个 key 的一致性问题。DH 还有一个机制，即，前向安全性(perfect forward secrecy--PFS)：server 端的 private key，不能用来代替以前任何一把的 sessionkey，所以，也无法破解以前任何一次的 session 内容。每次连接，DH 都会重新生成一个 key，并且当该次 session 结束时，丢弃它。不过，这并不是很大的问题，因为 DH 能很快的生成 key。因为它耗费在网络上的时间相比于 RSA 来说少了一半。可以从下图简单了解 [DH](https://en.wikipedia.org/wiki/Diffie–Hellman_key_exchange#Forward_secrecy) 的加密算法：

![DH](https://segmentfault.com/img/remote/1460000007283517?w=399&h=599)

简单来说，两边通过一次的信息交换，完成了密钥生成。因为 sessionkey 是独立放在两端的，为了达到一致性，每次连接时，DH 都需要重新协商生成 sessionkey。现在有个问题是： 为什么一定要有 session key，他存在的意义是什么？

### sessionkey 用途

> TLS/SSL 其实就是通过非对称加密，生成对称加密的 session key 的过程

那 session key 主要又干了什么呢？
首先，我们要先明确，session key 是用来进行对称加密的，这种加密方式主要使用到的是 AES 加密算法。这不同于 Elliptic Curve Diffie-Hellman (ECDH) 这种非对称加密算法。两者其实都可以用来对信息进行加密，但由于算法内部的实现机理不同，他们所用的时间也是不一样的。基本上是，ECDH 所用的时间是 AES 的 3 倍。

你可以自行测试一下：

```
openssl speed ecdh
openssl speed aes
```

ok,上面大概简述了 TLS/SSL 所用到的算法。接下来，我们来了解一下，具体 TLS/SSL 密钥交换的过程。

## TLS/SLL 过程

在详述过程之前，我们需要了解一下，在过程中会出现的内容。

- session key: 这是 TLS/SSL 最后协商的结果，用来进行对称加密。
- client random: 是一个 32B 的序列值，每次连接来时，都会动态生成，即，每次连接生成的值都不会一样。因为，他包含了 4B 的时间戳和 28B 的随机数。
- server random: 和 client random 一样，只是是由 server 端生成。
- premaster secret: 这是 48B 的 blob 数据。它能和 client & server random 通过 `pseudorandom` (PRF) 一起生成 session key。
- cipher suite: 用来定义 TLS 连接用到的算法。通常有 4 部分：
  - 非对称加密 (ECDH 或 RSA)
  - 证书验证 (证书的类型)
  - 保密性 (对称加密算法)
  - 数据完整性 (产生 hash 的函数)
    比如 `AES128-SHA` 代表着：
    - RSA 算法进行非对称加密
    - RSA 进行证书验证
    - 128bit AES 对称加密
    - 160bit SHA 数据加密算法
  - 比如 `ECDHE-ECDSA-AES256-GCM-SHA384` 代表着
    - ECDHE 算法进行非对称加密
    - ECDSA 进行证书验证
    - 265bit AES 对称加密
    - 384bit SHA 数据加密算法

相信大家对这张图已经很熟悉了：

![TLS/SSL](https://segmentfault.com/img/remote/1460000007283518?w=649&h=474)

不过，上面不是说了有两种不同的非对称加密方式吗？ RSA & DH？ 那为什么图只是一个嘞？
ok，实际上这图没错，他并没有把传输的内容是什么写出来，这很关键。而两种算法也是在传输内容上区分开的，基本的过程是完全一样的。根据 [wiki](https://en.wikipedia.org/wiki/Transport_Layer_Security#TLS_handshake) 的解释，我们大概能知道整个传输过程需要的内容。

![tls/ssl](https://segmentfault.com/img/remote/1460000007283519?w=526&h=560)

1. 客户端发送 clientHello 信息，包含了客户端支持的最高 TLS 协议版本，random num (上文提到过)，cipher suite。如果，客户端使用 resumed handshake，那么这里发送的就是 sessionID。如果，客户端还支持 ALPN，那么它应该还需要发送它所支持的其他协议，比如 HTTP/2.
2. 在 server 端进行 serverhello 阶段，这里 server 根据 client 发送过来的相关信息，采取不同的策略，同样会发送和 client 端匹配的 TLS 最高版本信息，cipher suite 和 自己产生的 random num. 并且，这里会产生该次连接独一无二的 **sessionID**。
3. 通过 certificate 阶段，会在信息流中加入 public key certification。ServerKeyExchange 该阶段，主要是针对于 ECDH 加密方式，这里就不赘述，后面再进行讲解。
4. serverHelloDone 标识这 server 阶段处理结束，将该阶段产生的信息发送给 client。
5. 在 clientKeyExchange 阶段时，client 会随机生成一串 pre-master secret 序列，并且会经由 public key 加密,然后发送给 server。在 ChangeCipherSpec 阶段，主要是 client 自己，通过 pre-master secret + server random-num + client random-num 生成 sessionKey。这就标识着，此时在 client 端，TLS/SSL 过程已经接近尾声。
6. 后面在 server 端进行的 ChangeCipherSpec 和 client 进行的差不多，通过使用 private key 解密 client 传过来的 pre-master secret ,然后生成 sessionkey。 后面再通过一次验证，使用 session Key 加密 `server finshed`，发送给 client，观察能够成功解密，来表示最终的 TLS/SSL 完成。

上面主要是根据 RSA 加密方式来讲解的。因为 RSA 才会在 TLS/SSL 过程中，将 pre-master secret 显示的进行传输，这样的结果有可能造成，hacker 拿到了 private key 那么他也可以生成一模一样的 sessionKey。即，该次连接的安全性就没了。

接下来，我们主要讲解一下另外一种加密方式 DH。它和 RSA 的主要区别就是，到底传不传 pre-master secret。RSA 传而 DH 不传。

根据 [cloudflare](https://blog.cloudflare.com/keyless-ssl-the-nitty-gritty-technical-details/nwmm4058zw/屏幕快照 2016-10-16 22.38.38.png) 的讲解可以清楚的了解到两者的区别：

这是 RSA 的传输方式，基本过程如上述。

![RSA](https://segmentfault.com/img/remote/1460000007283520?w=1075&h=795)

而 DH 具体区别在下图：

![DH_TLS/SSL](https://segmentfault.com/img/remote/1460000007283521?w=1228&h=857)

这里先补充一下 DH 算法的知识。因为，pre-master secret 就是根据这个生成的。DH 基本过程也不算太难，详情可以参考 [wiki](https://en.wikipedia.org/wiki/Diffie–Hellman_key_exchange#Description)。 它主要运用到的公式就是:

![DH_algorithm](https://segmentfault.com/img/remote/1460000007283522?w=370&h=30)

为了防止在 DH 参数交换时，数据过大，DH 使用的是取模数的方式，这样就能限制传输的值永远在 [1,p-1]。这里，先说明一下 DH 算法的基本条件：

- 公共条件： p 和 g 都是已知，并且公开。即，第三方也可以随便获取到。
- 私有条件： a 和 b 是两端自己生成的，第三方获取不到。

基本流程就是：

![DH_algo](https://segmentfault.com/img/remote/1460000007283523?w=306&h=259)

我们只要把上图的 DH parameter 替换为相对应的 X/Y 即可。而最后的 Z 就是我们想要的 Premaster secret。 之后，就和 RSA 加密算法一致，加上两边的 random-num 生成 sessionKey。通过，我们常常称 DH 也叫作 `Ephemeral Diffie-Hellman handshake`。 因为，他每次一的 sessionKey 都是不同的。

而 RSA 和 DH 两者之间的具体的区别就在于：RSA 会将 premaster secret 显示的传输，这样有可能会造成私钥泄露引起的安全问题。而 DH 不会将 premaster secret 显示的传输。

## TLS/SSL 中的基本概念

上面内容大概讲清楚了基本的 TLS/SSL 的加密过程。不过，其中，还有很多其他的小细节，比如 SNI，ALPN，Forward Secrey。 接下来，我们主要将这些细节将一下，因为他们其实也很重要。

### Forward Secrey

FS(Forward Secrey) 主要是针对 private key 进行描述了。如果你的 private key 能够用来破解以前通信的 session 内容，比如，通过 private key 破解你的 premaster secret ，得到了 sessionKey，就可以解密传输内容了。这种情况就是 non-forward-secrey。那如何做到 FS 呢？ 很简单，上文也已经提到过了，使用 DH 加密方式即可。因为，最后生成的 sessionKey 和 private key 并没有直接关系，premaster secret 是通过 `g(ab) mod P` 得到的。

简单的说就是，如果你想要启用 FS，那么你应该使用的是 DH 加密方式，而放弃 RSA。不过，由于历史原因（TLS 版本问题），RSA 现在还算是主流的加密方式。但，DH 也凭借他 `5S` 的安全性，份额也在增加。

### ALPN

ALPN 全称是 Application Layer Protocol Negotiation（应用层协议协商机制）。看到应用层，程序员们应该都能反应出 OSI 7层网络协议。在应用层中，HTTP 协议应该是重点。不过，由于 HTTP 版本的问题，以及现在 HTTP2 的流行，为了让 client-server 使用相同的协议而出现了 ALPN。ALPN 实际上是从 SPDY 中的 NPN 协议衍生出来的。不过，它们俩的机制正好相反。

- NPN： 由 server 端告诉 client，它支持什么协议，然后 client 确认支持的协议后，开始进行连接。
- ALPN：在 TLS 阶段，由 client 告诉 server，它所支持的所有协议，然后开始进行连接。

总的来说，NPN 已经退出历史的舞台了。。。ALPN 现在是 IETF 指定的标准协议。ALPN 在 TLS 具体的过程是：

- 在 clientHello 阶段，client 会在 message 中，添加一个 ProtocolNameList 字段。用来表示它所支持的协议列表
- server 端在 serverHello 阶段，处理 client 提供的 ProtocolNameList。并且选择最高版本的协议，执行。将选择信息添加到 serverhello 内。

### SNI

SNI 的全称为：Server Name Indication。该机制的提出的意义是，当有一个 server 同时处理了很多个 host 时。相当于，一个 IP 映射多个域名，但，由于证书只能对一个 3 级域名有效，所以，针对于多个 host 来说，server 为了能同时兼顾这些域名。一种简单的办法就是重定向到指定域名，如果都想支持的话，也行，掏钱自己多买几个证书 （真土豪）。如果，你很土豪的话，现在就有这样的情况，一个 IP 服务器下，搭载了支持多个域名的 server，并且每个域名都有合法的 CA 证书。那么，server 怎么判断，哪一个域名用哪一个证书呢？这时候，就需要用到 SNI。相当于在 TLS 阶段，将 host 一并发送过去，然后 server 就知道在 serverhello 阶段该返回啥证书了。
现在，有个问题，为什么一定要用 SNI 呢？
我们回想一下，这里我们仅仅只是建立 TCP + TLS 连接，客户端的一些内容，比如 hostname，我们并不能在 TCP 中获得。而，想要获得的话，就需要等到 HTTP 阶段，获得 client 传过来的 `host` 或 `origin` 字段。所以，为了解决这个比较尴尬的点，就提出了 SNI。

## Session Resumption

感觉能看到这里的人，应该都是闲的蛋疼的人。。。如果让我来看这篇文章，估计看几张图，我基本上就直接关网站了。因为，这实在是复杂。并且，上面说的只是协议上的复杂性，对于计算机来说，只需要记下每一次该发什么东西而已，但真正让 Computer 感到蛋疼的是，key 的计算。特别是 random key 和 premaster secret 动不动就是 32B，48B 的数据量。所以，为了真正减少计算机的工作量（实际上是 server），提出了 Session ID 和 Session Tickets，来将成功进行连接的 session 内容缓存起来。

### Session ID

Session ID 是 server 将上一次成功连接的 session 内容存在自己的硬盘里面。这里，就不涉及对 session data 的二次加密。基本的过程是：

1. client 端在 clientHello 阶段，将 random num，TLS protocol 和通过 hostname 匹配到的最新一次的 session ID 发送给 server 端。（也就是说，client 同样需要存储一份 session data）
2. server 接收到 session ID 后，在缓存中查找，如果找到，则直接进行 ChangeCipher 阶段，开始生成sessionKey。然后，返回相同的 sessionID 即可。

那么相对于完全的 TLS/SSL 连接来说，这里只用到了一次 RTT。那么协议过程就变为了：

![session Resumption](https://segmentfault.com/img/remote/1460000007283524?w=422&h=348)

### Session Ticket

既然 Session ID 是为了解决网络时延和计算机性能问题，那么 Session Ticket 又干了什么呢？
Session Ticket 和 Session ID 做的也是同样的事情，server 将最新一次的 sesion data 通过二次加密，在上一次握手结束时传递过去，然后 client 将传递过来的信息保存。
这样，利不利用缓存的 session data 这时，就取决于 client。如果该次的 session data 没有过期，那么 client 就会在 clientHello 阶段将该数据发送过去，server 接受到之后，便开始进行解密然后，双方生成 sessionKey，握手结束。
那 Session Ticket 和 Session ID 到底用哪一个呢？
这估计得看你的业务情况了，Session ID 注重的是节省性能，而损耗部分空间。Session Ticket 注重的是节省空间，而损耗部分性能。它们两者都能节省一次 RTT 时间，用谁，还是得看你的服务器的具体情况。

## CA 证书详情

前面大致说了 TLS/SSL 是怎样运作的，以及有哪些连接方法。相当于，学画一条线一样，我们现在只知道这条线该画多长，但还不知道，这条线从哪里画。所以，接下来，我们就需要来探讨一下，两端发生了什么。其实也不难，主要还是关于 CA 证书的存放和验证。server 端的很简单，就是把自己的 CA 证书发过来就 ok。但，client 验证这个证书是否可信，会有点复杂。
首先，证书颁发机构就那么一些，换句话理解就是，每个证书颁发机构，就代表着一张 CA 证书。但，现在市面上的 HTTPS 网站，辣么辣么多，难道他们都用同一张证书？难道他们都有一样的 pu/pr key? 那么 HTTPS 安全还有用吗？
所以，按照上面的推理，我们的网站上的 HTTPS 证书，肯定都是各不一样的。一般来说，有 3 种类型的证书： DV（Domain Validation），OV（Organization Validation），EV（Extended Validation）。均价按照顺序上升，所以，最便宜的就是 DV，这应该是我们勤劳的贫苦大众用得起的。它们之间具体的区别在于域名的支持上：

- DV：就是个人证书嘛，基本支持的就是单域名和多域名，不支持泛域名（*.villainhr.com）。不过，看价格，比如我这个就是腾讯云给的一个免费的 DV 证书，所以，就支持一个 3 级域名（[https://www.villainhr.com](https://www.villainhr.com/)）。如果是收费的，单/多域名应该都支持。
- OV：就比较牛逼，面向企业的，多域名/泛域名都支持。
- EV：属于贵族用的，一般人也搞不到，主要它还需要去买个保险。。。

那我们的证书在芸芸证书中，是处于哪一个层级呢？
一般是三级。怎么体现的呢？

![certificate](https://segmentfault.com/img/remote/1460000007283525?w=410&h=90)

那这么多证书，我们用的是哪一个呢？当然是，最下面那个。因为每个证书并不是都被信任，所以客户端首先就要了解一下，你这个证书能否用来进行验证。如果不行的话，那么你这次连接就是不被信任的，就没有`绿色的小锁`。这就需要了解一下，客户端的验证过程。

### CA 链式验证

首先，什么叫做可信的证书呢？
我们先要明白一个道理，HTTPS 是先建立在人与人之间的相互信任上，然后才建立在机器与机器的相互信任上。假如，根证书 A 机构，恶意的将一个以前颁发过的证书，又给了另外一个`不要脸`拦截站点（比如，用来插广告的）。这样，我拿到了这个证书后，就可以自己搭一个服务器，用来进行拦截浏览，监管里你网站，并强行插广告。这就被称为不可信的机构/证书。
而验证的可行性，通常又跟机构的权威性有着极大的关系。它基本的验证过程简述就是（按照上面的层级）：

- www.villainhr.com 问 TrustAsia DV SSL，我的证书可不可信？
- 可信！ok，继续。TrustAsia DV SSL 问 VeriSign Class 3，我的证书可不可信
- 可信！ok，然后便开始 TLS/SSL 连接。

如果上述任一步骤出现问题，那么该次 TLS/SSL 就不会进行，会回退。那么它们在询问的时候，会不会发送网络请求呢？
不会~ 因为，电脑在初始化时，会自带很多可信任的证书机构（即，Root CA），也就是我们刚刚提到的 VeriSign Class 3 的证书机构。以及，能够签发证书的二级机构（比较少）。到时候，浏览器会自动的根据数字签名来进行证书的验证。

### CA 合法验证

上面已经阐述了，CA 证书的合法性是自下而上的验证方式。那么它们具体验证协议是怎样的呢？
在说之前，我们先说几个概念：

- 数字签名：它是用颁发机构的私钥，对下级证书的公钥进行加密生成的值。digital_sign = CA_pr_key + sub_Cer_ppu_key。
- 解密：用颁发机构的公钥对数字签名进行解密，对比下级证书的公钥和解密后的值是否一致。

CA 验证首先需要说一下它的颁发过程：

- 颁发机构 A，用自己的私钥将需要生成的下级证书 B 的公钥进行加密，生成数字签名，然后再带上相关信息：公钥，公钥的指纹，数字签名，证书名，签发机构等。

然后，验证过程就是根据这个来的：

- 浏览器解析下级证书 B 的相关信息，找到签发机构和数字签名。
- 然后，找到签发机构 A，使用 A 的公钥去解密数字签名，然后对比下级证书 B 的公钥。如果成功则合法，反之，不合法。

而上面的三级证书层级，也是同样的道理，自上而下的找就 ok。当然，有时候为了验证的速度，会做一些缓存，这样就不必再进行验证了。所以，根据上面的描述，有童鞋可能会想到，能不能自签证书呢？反正，浏览器也是从本地找的。
当然可以，`openssl` 就可以生成你自己的 CA。不过需要注意的是，你生成的 CA 只是在你自己的电脑上使用，如果你想保证你的 CA 在其他电脑上也能使用的话（这是不可能的），那就用钱砸就 ok。
具体的过程可以参考：[生成自己的 CA 证书](https://jamielinux.com/docs/openssl-certificate-authority/index.html)。
以前，在使用 Charles 和 Fiddler 的时候，一直在想，它们是怎么做到，将自己的证书，变成签发机构证书。

![Charles 签发证书](https://segmentfault.com/img/remote/1460000007283526?w=235&h=42)

后来发现，它是把证书中的相关字段该成它的证书内容。不过，对于某些高级证书，还是会有一些问题，比如，wx.qq.com（微信的）

另外，为了证书的可靠性，提出了 `Certificate Transparency` 项目，实际上，就是让证书机构公开它的签发流水。防止出现重复签发。

### 证书的吊销

现在有个问题，为什么证书有过期时间呢？
这同样是为了安全性，前面说过，如果你的证书发生了泄漏（实际上就是私钥）。那么，其他服务器就可以作为一个代理去拦截你的流量。这时候，由于过期的原因，可能一段时间后，中间恶意的服务器就没用了，另外，如果你发现了你遗失了证书，可以向颁发机构去挂失。
另外，还有一个原因是证书吊销的 `CRL` 机制。简单来说，就是有一个列表来记录当前时间，该颁发机构被吊销的证书 list。如果，没有过期时间的话，那么这个 list，会随时间程指数增长，引入过期机制的话，该 list 只要记录当前没过期但吊销的证书信息即可。
证书的吊销有两种机制：CRL，OCSP

#### CRL

CRL（Certificate Revocation List），即，证书吊销列表。CA 机构会生成一个列表，列表里面是当前周期被吊销证书的序列号，当进行证书验证时，同样也会进行验证该项。如果，已经是吊销证书的话，那么该次 TLS/SSL 连接也会失败。
我们可以从证书信息中找到 CRL URI:

![CRL证书信息](https://segmentfault.com/img/remote/1460000007283527?w=472&h=282)

该协议虽然简单，但，缺陷还是比较多的。

- 下载时间。因为该 list 不是自带的，需要从颁发机构下载，这就造成了网络时延。
- 缓存时间。如果存在缓存，就存在了信息不同步的问题，如果一个证书已经过期，但缓存中显示的是未过期，那么也是一个安全问题。

#### OCSP

OCSP（Online Certificate Status Protocol），即，在线证书状态协议。它通过在线请求的方式来进行验证，不需要下载整个 list，只需要将该证书的序列号发送给 CA 进行验证。当然，验证通过也会有一定的缓存期。不过，由于验证也会存在时延。另外，部署 OCSP 对 CA 也有一定的要求，CA 要搭建的一个服务器来接受验证，并且，该服务器的性能要好（负载很大）。

#### OCSP stapling

OCSP stapling 常称为： TLS Certificate Status Request extension。是 OCSP 的另外一种实现方式，因为前两个（OCSP,CRL）都是由客户端去验证证书是否吊销，并且都会发送请求。而 OCSPs（OCSP stapling）则是直接在 server 端，进行证书的有效性验证。server 会周期性的向 CA 机构发送请求，验证有效性，并在 `certificate` 阶段，发送相应的签名信息。不过，该协议是建立在，我们完全信任 serve 的情况下，这里就排除了一些恶意的中间服务器。详情可以参考：[OCSP stapling](https://en.wikipedia.org/wiki/OCSP_stapling)。

## TLS/SSL 优化

TLS/SSL 主要的性能调优简单包括：启用 False Start, OSCP Stapling, 选择合适 cipher suite, resumption 等。另外，如果你追求 `fashion`, 那么 HTTP/2 应该是个不错的选择。
想要做 TLS/SSL 优化，那么你必须了解，TLS/SSL 握手的整个过程是什么。当然，你可以买个证书，从头自己搭建一个服务器，但是，这样只能证明 `你很有钱`外，其它也证明不了什么。因为，这完全可以自己内网搭一个呀~ 可以参考：[10s 自建证书](https://github.com/JimmyVV/CA). 这里，我们结合 nginx 来具体对 TLS/SSL handshake 优化，做个整体的阐述。

### 设置 session 缓存

session 缓存设置可以让两次的 RTT，变为一次，这相当于快了一倍（不包括，密钥计算等）。不同的 server 设置 session 的办法有很多，这里以 nginx 为例。在 nginx 中，支持的是 Session ID 的形式，即在 server 中缓存以前 session 的加密内容。涉及的字段有两个，`ssl_session_cache `和 `ssl_session_timeout`。

- ssl_session_cache：用来设置 session cache 上限值，以及是否在多个 worker 之间共享
- ssl_session_timeout：用来设置 session cache 存储的时间

看个 demo 吧：

```
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 20m;
```

表示的意思是：session cahce 会在不同的 worker 之间分享，假设 1MB 只能存储 8000 次握手的信息。那么， 10 MB 一共可以存储 80000 次握手信息。如果超出，则不会存储。缓存信息存在时长为 20分钟。
另外，你也可以开启 `session ticket`。ST(session ticket) 需要一个sign 参数，使用 openssl 创建即可。

```
$ openssl rand 48 > ticket.key
# 在 nginx 中开启
ssl_session_tickets on; 
ssl_session_ticket_key ticket.key;
```

### 选择合适的 cipher suite

这里先声明一下，你的证书的内容和你的加密套件实际没有半毛钱关系，这主要还是取决于你的服务器的支持程度以及客户端的支持度。另外，如果你想启用 `False Start`，这也可套件的选择有很大的关系。我们来看一下如果设置吧。在 nginx 中，主要用到两个指令：

```
ssl_prefer_server_ciphers on;
ssl_ciphers xxx;
```

- ssl_prefer_server_ciphers: 用来告诉客户端，要按照我提供的加密套件选择。
- ssl_ciphers: 具体设置的加密套件内容，使用 `:` 分隔。

支持性最高的就是使用：

```
// 让浏览器来决定使用哪一个套件(额。。。最后的手段)
ssl_ciphers  HIGH:!aNULL:!MD5;
```

一般情况，还是应该自己来决定使用哪一个套件，这样安不安全由自己说了算。具体可以参考 [mozilla 的套件配置](https://wiki.mozilla.org/Security/Server_Side_TLS#Recommended_configurations)。这里简单放一个，比较安全的，下面所有的套件都必须支持 Forwar Secrecy

```
ssl_ciphers ECDH+AESGCM:ECDH+AES256:ECDH+AES128:DH+3DES:!ADH:!AECDH:!MD5
```

不过，以下的加密套件，最好不要使用，因为基本上都不安全：

- aNULL: 是一种非标准的 DH 密钥交换套件。容易被`中间人`攻击。
- eNULL: 没有加密方式，明文交换
- EXPORT: 一种弱加密方式，老美那边早期使用的
- RC4: 使用已经废弃的 ARCFOUR 算法
- DES: 使用已经废弃的 Data Encryption 标准
- SSLv2: 老版本 SSL2.0 的加密套件（最少，你也写 SSLv3 嘛）
- MD5: 直接使用 MD5 加密方式

上面那些只能给一些远古浏览器使用，基本上在选择中是作为垫底的选择。

#### False Start

另外，怎么在 nginx 中开启 False Start 呢？ 这其实和服务器并没有多大的关系，关键还是你选择的套件和 NPN/ALPN 协议的作用。

- 首先，你的加密套件必须具有 Forward Secrecy，否则开不了。
- 浏览器需要使用 NPN 或者 ALPN 告诉服务器，该所需的协议版本，然后再决定开不开启。

那么，在 nginx 中，我们只要选择好合适的加密套件即可。这里就放一份现成的吧

```
ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256::DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5';
```

### 使用 DH 密钥交换

DH 的加密过程，上面已经说过了。DH 自带两个公共的参数，所以，这必须手动进行创建(实际上就是将参数 sign 一遍)。

```
// 创建一个 DH param
openssl dhparam 2048 -out dhparam.pem
```

然后，调用该文件

```
ssl_dhparam dhparam.pem;
```

这样，你就正式的开启的 DH 加密模式。如果你使用抓包工具观察一下，此时 DH 应该会在 Server Hello 里：

![server Hello 信息](https://segmentfault.com/img/remote/1460000007283528?w=561&h=219)

不过，由于历史原因，DH param 已经使用的长度是 1024，比如: 采用 `Oakley group 2` 版本。现在，比较流行的 DH 加密方式是 `ECDHE`，它和以前的加密方式（`DHE`）比起来，在密钥生成这块会快很多。同样，由于历史原因，它的基本条件比较高：（其实也还好）

- Android > 3.0.0
- Java > 7
- OpenSSL > 1.0.0

### 开启 OCSP Stapling

OCSP Stapling 是验证证书权威性的一种手段，前面还有两种 CRL 和 OCSP。不过，它们都是让 client 自己去验证。而 OCSP Stapling 则把验证这块放到了 server 里，通过定期检查，来减少网络时间中的消耗。要开启 OCSP Stapling 首先是需要你证书的 chain 文件，该是用来详细说明，从根证书到你的证书中间所要经历的所有验证（和其他两种验证手段一样）。那如何得到 chain 文件呢？直接去问你的证书颁发机构，这个又不是啥秘密文件。如果是自发证书（自己测试用的），那就自己生成。将所有的中间证书按照 `bottom to up` 放到一个文件里：

```
cat intermediate/certs/intermediate.cert.pem \
      certs/ca.cert.pem > intermediate/certs/ca-chain.cert.pem;
```

那么 ca-chain.cert.pem 就是 OSCP stapling 验证文件。然后在 nginx 开启即可。

```
ssl_stapling on;
ssl_stapling_verify on;
ssl_trusted_certificate ca-chain.cert.pem;
resolver 8.8.8.8 8.8.4.4; // 默认使用 Google 的
```

关于 DNS 解析，同样你也需要问一下证书提供商，当然，该值可以不用管。下面也同样适用

```
ssl_stapling on;
ssl_stapling_verify on;
ssl_trusted_certificate ca-chain.cert.pem;
```

开启过后，你可以使用 `openssl s_client -connect www.yourDomainName.com:443` 来测试一下，检测是否开启成功。

### 开启 HSTS

HSTS（HTTP Strict Transport Security） 实际上就是一个响应头，没啥很特别的，具体内容就是，你所有对外部的请求都是 `https`，所以这有一个问题，如果你的图片地址是 http 的，那么最终的结果，会变为 `https://xxx`，有可能会造成资源丢失的情况，所以，开不开启还需要慎用。

```
Strict-Transport-Security: max-age=15768000 # 设定 6 个月的强制期
```

在有效时间内，客户端都会尝试使用 https 访问你的站点，如果在这期限里你的证书过期了，开不了 `https`。那么，呵呵。

### 使用 SNI

SNI 就是针对一个 IP 手握很多张证书时，用到的协议机制，这主要是用来区分，不同的 host，使用不同的证书。SNI 详情上面已经说过了，这里就不赘述了。主要使用格式就是不同的 server_name 搭配不同的 certificate

```
server{
    server_name www.abc.com;
    ssl_certificate abc.crt;
    ssl_certificate_key abc.crt.key;
}
server{
    server_name www.def.com;
    ssl_certificate def.crt;
    ssl_certificate_key def.crt.key;
}
```

如何开启呢？换个高版本的 nginx 就行了。你可以使用 `nginx -V` 检查你的 nginx 是否带有

```
TLS SNI support enabled
```

### 完整示例

最后，放一份完整的吧：

```
server {
        listen 443 ssl http2; # 默认打开 http2
        listen [::]:443 ssl http2;

        ssl_certificate /etc/nginx/cert/bjornjohansen.no.certchain.crt;
        ssl_certificate_key /etc/nginx/cert/bjornjohansen.no.key;

        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 20m;

        ssl_prefer_server_ciphers on;

        ssl_ciphers ECDH+AESGCM:ECDH+AES256:ECDH+AES128:DH+3DES:!ADH:!AECDH:!MD5;

        ssl_dhparam /etc/nginx/cert/dhparam.pem;

        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;

        ssl_stapling on;
        ssl_stapling_verify on;
        ssl_trusted_certificate /etc/nginx/cert/trustchain.crt;
        resolver 8.8.8.8 8.8.4.4; # 看情况选择 DNS IP

        #add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
        # 我一般不开 HSTS
        # add_header Strict-Transport-Security "max-age=31536000" always;
}
```

### 参考列表

这个，配置也很简单，你可以从 Mozilla 里获得更丰富的内容。详情可以参考：

- [https://wiki.mozilla.org/Secu...](https://wiki.mozilla.org/Security/TLS_Configurations)
- [https://wiki.mozilla.org/Secu...](https://wiki.mozilla.org/Security/Server_Side_TLS)
- [https://hpbn.co/transport-lay...](https://hpbn.co/transport-layer-security-tls/)

另外，还有一些测试工具和生成工具,这里也提供一份 list:

- [摸直了 官方测试工具](https://observatory.mozilla.org/)
- [摸直了 官方 tls/ssl 配置生成工具](https://mozilla.github.io/server-side-tls/ssl-config-generator/)
- [SSL lab tls/ssl 测试工具](https://www.ssllabs.com/ssltest/analyze.html)