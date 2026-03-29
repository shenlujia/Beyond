# 20240122_Scaling Law - AI 商业模式第四篇

作者：周喆吾

[原文链接](https://mp.weixin.qq.com/s/HZpkJyP2q-Isv0pQ8iSZ5w)

前文：

1.&nbsp;[ChatGPT是 AI 时代的 91手机助手](http://mp.weixin.qq.com/s?__biz=MzU2MTgzMjQyMA==&amp;mid=2247484929&amp;idx=1&amp;sn=52d3365cff2e5ecc6e7748dc930a0774&amp;chksm=fc738e8acb04079c4c862feda47781095d1404842701302188b8f2cf8f2e5a56252d00454a5d&amp;scene=21#wechat_redirect)

[<span style="color: rgb(0,0,0)">2. </span>AI 时代错误的商业模式 - “好10倍” 且 “更便宜” 吗？](http://mp.weixin.qq.com/s?__biz=MzU2MTgzMjQyMA==&amp;mid=2247484939&amp;idx=1&amp;sn=3c9537aea57a58b8463ca89109554cbf&amp;chksm=fc738e80cb040796decc8c3e9d0acb79b091cfb5347d4732f8c7e5d38390bd7d67d68e7d4c6e&amp;scene=21#wechat_redirect)

3.&nbsp;[AI 产品的数量级遐想 —— 暴君会怎么做？](http://mp.weixin.qq.com/s?__biz=MzU2MTgzMjQyMA==&amp;mid=2247484952&amp;idx=1&amp;sn=a1eb06a64029a614bc771da8a0434785&amp;chksm=fc738e93cb0407851eb5a521d7be1965c6db30b5347e427a05c5ef74f1833f3620fed7bf572c&amp;scene=21#wechat_redirect)

本篇讨论&nbsp;**<span style="color: rgb(255,76,65)">Scaling Law</span>**

笔者之前翻译过本领域著名的* **The Bitter Lesson***:&nbsp;[过去70年人工智能领域 - 最苦涩的教训](http://mp.weixin.qq.com/s?__biz=MzU2MTgzMjQyMA==&amp;mid=2247484823&amp;idx=1&amp;sn=fbcacddfbc74fb07d9cc52de7f82012f&amp;chksm=fc738d1ccb04040a3e8c999297945c62c452e803d929d3171809b0aa2cdbfc0ead62b499e24c&amp;scene=21#wechat_redirect)，详细讲述了可能是唯一有效的策略：站在指数增长的曲线上“躺赢”，做时间的朋友。

张忠谋从事半导体行业65年，他上个月去MIT演讲的时候，给摩尔定律打了个比方：假设今天你的孩子出生，给他一美金，如果这一块钱能够按照摩尔定律增长，孩子五十岁的时候会有多少钱？

答案是：10亿美金（1 Billion）。

如果孩子到了七十岁，就会有 1万亿美金（1 Trillion）。

以如此惊天动地的指数增长来思考问题，就能够明白为何 Gwern 在2020年就写出 The Scaling Hypothesis (GPT-3刚出来，ChatGPT还没影子)，也能理解 Ilya Sustkever (AlexNet, OpenAI)&nbsp;在 2011 年就在论文里坚定了这一信仰。

![图片](https://mmbiz.qpic.cn/sz_mmbiz_jpg/ERHx76pYjiasuauE5ZW3d7FEU17UPvKfSWiaNZWhNBKINibD2Wnys5DBlLFqQ9EJN6PariaTUWsQnicLtkc08AKTXhA/640?wx_fmt=jpeg&amp;from=appmsg)

Gwern的论证中，智能不是“涌现”的，而是单纯的 "a function of compute and token size in log scale".

![图片](https://mmbiz.qpic.cn/sz_mmbiz_png/ERHx76pYjiasuauE5ZW3d7FEU17UPvKfSD8rQKubXGwj7uto5LBuGUa6et2o2dfq56vCvbFR6qicYxA61OKENKBw/640?wx_fmt=png&amp;from=appmsg)

Dario Amodei (Anthropic) 也有论述，并不是 LLM 体积达到了 10B&nbsp;参数就会数学和推理了，而是更小的 LLM 也能够做数学和推理，只是没那么准确而已！

为什么模型不够大的时候，效果不行呢？

底层原理其实和人类学习很像：小模型&nbsp;“死记硬背” vs 大模型 “举一反三、融会贯通”。

&nbsp;AI 领域有这样一句话：“神经网络很懒惰” ——&nbsp;只是死记硬背训练数据、仅仅捕捉到表面特征的弱鸡子模型，学得最快。

如果模型、数据和算力不够大、不够多样化，那么在粗训的最后，只能得到一个实现了低损失的子模型，一叶障目。&nbsp;

反过来，对于像GPT-3这样足够强大的模型来说，其子模型能够做从诗歌到算术的任何事情；并且**它的训练数据是如此之多，那些浅层模型可能一开始做得不错，但逐渐会落后于更抽象的模型**。

一个死记硬背部分数据的子模型的确比一个编码了真正算术运算的子模型（比如‘加法’）要简单得多（一个神经网络可能可以在存储加法实例的查找表条目中记住数以万计的数据，这些数据占用的空间可能足以编码一个抽象算法），但它不可能记住GPT-3那互联网规模数据集中所有的算术实例（无论是隐式的还是显式的）。

如果一个记忆型子模型试图这样做，它将变得极其庞大并受到惩罚。最终，在足够多的例子和足够多的更新之后，可能会出现一个 Phase Transition（Viering &amp; Loog 2021），**最简单的‘算术’模型准确预测数据，<span style="color: rgb(255,76,65)">就是算术本身！</span>**

随后元学习（Meta-Learning）在见识了足够多的算法实例后，这些算法在每个样本中稍有变化，使得单独学习每个任务变得困难，就是更通用算法的学习，产生的子模型实现的损失比那些要么预测不准确要么过度膨胀的竞争子模型要低。

（GPT-2-1.5b显然太小或者太浅，无法轻易地在编码元学习算法的子模型之间进行集成，或许也没有在足够多的数据上训练足够长的时间来定位元学习者模型；而GPT-3做到了。）

用一个梗图来表达：

![图片](https://mmbiz.qpic.cn/sz_mmbiz_jpg/ERHx76pYjiasuauE5ZW3d7FEU17UPvKfSPiaiaiamla1Mj5QRXD954EIxTvgicAoLqKB4MRvc7kccXs7HK3KCBqExog/640?wx_fmt=jpeg&amp;from=appmsg)

指数增长假说（Scaling Hypothesis）按照 Ilya 和 Dario 的简洁说法是：“模型总是如饥似渴、想要学习！”

正如&nbsp;<span style="color: rgb(0,0,0)">Sutton 所写，</span>根本不需要加入人类知识调优，而只需要**无限怼更高的算力、更大的数据集**，然后拥抱搜索和学习...&nbsp;

粗暴的堆算力、堆数据，给信仰充值 —— 就可以“做时间的朋友”了？！

事实是这样吗？

**指数增长假说，有三大绊脚石：**

人类能够生产的数据集是不是会不够用？

Scaling Law 本身是 "Emprical" 的（经验主义），他真的有道理、能再维持到5个数量级之后吗？

走到商业化落地要多少钱，要多久呢？是否有足够的资源支撑？

在回答这三个问题之前，我们先回来审视一下摩尔定律：

[王川: 为什么摩尔定律一直没死, 但人们还会继续预测摩尔定律要死](http://mp.weixin.qq.com/s?__biz=MzA3MzE5MjM2Mw==&amp;mid=2672247364&amp;idx=1&amp;sn=442a86dd3e90e1271f09bb70aa44229b&amp;chksm=85a12480b2d6ad96a117e69cbbba39cd4c8bf42893813aa35a117590636193b7dab801058e09&amp;scene=21#wechat_redirect)

![图片](https://mmbiz.qpic.cn/sz_mmbiz_jpg/ERHx76pYjiasuauE5ZW3d7FEU17UPvKfSOLf9gEtF1nWre1LyW5HelbkLeak0ttxDRnbvZjglhyp5mRtXTPZxog/640?wx_fmt=jpeg&amp;from=appmsg)

摩尔定律也是经验主义的，但已经维持了60年

"预测摩尔定律要死掉的人数， 每两年翻一番"

摩尔定律是个经济规律， 是一个技术发展、市场扩大、单价降低、利润再回馈到研发的良性循环

第一性来看，Transformer Scaling Law是否成立之争，确实和摩尔定律有诸多相似之处（经验主义、反直觉、反对者众多、经济规律）

OpenAI 和微软在 1.5B -&gt; 1760B 的三个数量级的这波 Scaling 上，站在了历史正确的一边，几十亿美金的豪赌，赚取了微软这两年涨出来的一万亿美金市值。&nbsp;

再往后看五个数量级，Scaling Law是否可以维系呢？

![图片](https://mmbiz.qpic.cn/sz_mmbiz_png/ERHx76pYjiasuauE5ZW3d7FEU17UPvKfSDTD8vfaUUN1icg5Uicbe7mlb2QIgmNbEy58iacFiar8sFTiaUUWpoDrSicuQ/640?wx_fmt=png&amp;from=appmsg)

回到前文提到的三大绊脚石

**1. 人类能够生产的数据集是不是会不够用？**

![图片](https://mmbiz.qpic.cn/sz_mmbiz_jpg/ERHx76pYjiasuauE5ZW3d7FEU17UPvKfSc80FicXVSxowP6hiaUUicmz1SHcGKu6dCB6kFY7hIR0TU3kmCQlUhbJrQ/640?wx_fmt=jpeg&amp;from=appmsg)

问：当前的数据量够用到哪年？答：2025~2040年之间

问：图片和视频数据对于 LLM 训练的可用性有多高？答：高质量数据集可用，多模态本身是一个未经大量开采的富矿

问：Synthetic Data可否用来训练 LLM？答：目前行业内公认不能，但是零星有人在尝试

结论：5个数量级的数据集，似乎是可以看得到的未来

**2.&nbsp;Scaling Law 本身是 "Emprical"&nbsp;的（经验主义），他真的有道理、能再维持到5个数量级之后吗？**

![图片](https://mmbiz.qpic.cn/sz_mmbiz_jpg/ERHx76pYjiasuauE5ZW3d7FEU17UPvKfSFNTLrPXEicn9LiaqtvXdiacQTSvy5xfswL0rBtVQQeK1E4byU66aGlR3w/640?wx_fmt=jpeg&amp;from=appmsg)

Ilya 用 Kolmogorov 压缩的逻辑给出了一个很精巧，但是无法证真或证伪的假说。读过较多的论文、经历了每天对大模型调优的实践，每个从业者应该能得到自己的结论，我倾向于认同 Scaling Law 能够再往前走若干个数量级。

**3. 走到商业化落地要多少钱，要多久呢？是否有足够的资源支撑？**

于是终于来到了本文的主旨：从商业模式角度，到底需要多少成本能够达到能够商业化落地的效果？什么是 LLM 正确的商业模式？

笔者在前文中提到：

****

LLM的正确产品，你需要先找到一个赛道，同时符合这几个特点，缺一不可：1. 赛道本身很大（真需求已验证）
2. 目前体验极为糟糕
3. 当前付费者抱怨很贵，但又不得不用

周喆吾，公众号：周喆吾[AI 时代错误的商业模式 - “好10倍” 且 “更便宜” 吗？](https://mp.weixin.qq.com/s?__biz=MzU2MTgzMjQyMA==&amp;mid=2247484939&amp;idx=1&amp;sn=3c9537aea57a58b8463ca89109554cbf&amp;chksm=fc738e80cb040796decc8c3e9d0acb79b091cfb5347d4732f8c7e5d38390bd7d67d68e7d4c6e&amp;token=1646543379&amp;lang=zh_CN#rd)

同时符合这几个条件的商业模式，Sam Altman已经很清晰的指出了，就是 AGI 白领。

这里要区分一下，AGI 可行的商业模式，打个比方，是L4自动驾驶（没有司机），而不是 L2辅助驾驶（提高司机能力）。

Co-Pilot是没有好的商业模式的，只有革了司机的命，才能同时做到“好10倍”，且“更便宜”。

你的客户只能是白领的雇佣者（资本家），不能是白领。

举个例子，AI律师正在合理的商业模式，一定不能是Harvey —— 从他的定位上就错了！（Gen AI for Elite Law Firms）

![图片](https://mmbiz.qpic.cn/sz_mmbiz_jpg/ERHx76pYjiasuauE5ZW3d7FEU17UPvKfSBJ4Y9B4O8aESoKIrvRmTPDBNzh5rkLIKBbWQ6NbfG8sVx18jZ6PV0Q/640?wx_fmt=jpeg&amp;from=appmsg)

你不能间接地服务律所，而必须要取代律所去服务客户，才有可能好十倍且更便宜！

无论你怎么给律师提效，他都只能从原来的律师工资里掏出一部分，来给这个软件付费。而如果给雇佣律所的公司付费，取代掉律师，那么公司得到的是一个能够帮助起草和谈判合同、能够打赢官司的软件！

医生、律师、老师、理财、管家... AGI的商业模式是取代人类工作。说这不影响白领饭碗的 AI 企业家，大抵不是蠢就是坏，利益驱动吧。

这引出了下一个问题，L4商业模式好是好，中间要穿越多久的&nbsp;L2无人区？

![图片](https://mmbiz.qpic.cn/sz_mmbiz_jpg/ERHx76pYjiasuauE5ZW3d7FEU17UPvKfSicUtTkw6FA5IRcHSiaTZy7QQQlu5JozejfYdyaWbpQlZb0vqTFGHHQYQ/640?wx_fmt=jpeg&amp;from=appmsg)

这周达沃斯论坛上，Mustafa 讲当前的资本对 AI 达到了 Peak Hype，显然是一个泡沫。泡沫法则说，它将收割所有没能参与这次泡沫的，和泡沫爆炸的那一刻还停留在泡沫里的人。同时 Mustafa 又讲，大家对 AI 还是低估了... 主持人问：一件事物怎么能同时 Peak Hype，又被低估呢？他的回答有点磕磕绊绊，但我替他讲出画外音：Scaling Law!

过去十五年零利率的资本周期，让很多难以成立的商业模式支撑了比想象更久的时间，比如 WeWork、OYO，也让一些本来会爆掉的泡沫居然结出了果实。

即使 Scaling Law 最终证真，在当前的高债务资本周期内，所有投资人都想问，L4 要多久？

5&nbsp;OOM Token（多模态）

5 OOM Compute (100P 参数的模型？)

从 1TB 的 GPT-4，到 100P 参数，是否有足够的商业用例能够支撑持续的资本投入呢？

不妨问问前面三个 OOM 坚定投入的话事人盖茨：

![图片](https://mmbiz.qpic.cn/sz_mmbiz_png/ERHx76pYjiasuauE5ZW3d7FEU17UPvKfSbOOhJvyPOyBaySY72NTlgcXn27CbOaFhZIz2icicbMpQcXeTuKuYAg4A/640?wx_fmt=png&amp;from=appmsg)

他认为 GPT-5 可能即将陷入一个瓶颈，一方面推理很贵，另一方面性能又不能大幅提高。

反过来，一部分有权势的人又很上头，比如李广密 总结出 硅谷的从业者对 Scaling Law 的判断：[跨年对谈：千亿美金豪赌开启 AI 新摩尔时代](http://mp.weixin.qq.com/s?__biz=Mzg2OTY0MDk0NQ==&amp;mid=2247505889&amp;idx=1&amp;sn=10e0abe8a8b81bb523f9c74100c86647&amp;chksm=ce9b687ff9ece169d7959efc485e6fea6177219474d519029b244d8bed5db011d44cbe3a8f09&amp;scene=21#wechat_redirect)、[新摩尔时代：拾象 2024 LLM 猜想](http://mp.weixin.qq.com/s?__biz=Mzg2OTY0MDk0NQ==&amp;mid=2247506132&amp;idx=1&amp;sn=8be503aa7f5842964cc85edad6cae023&amp;chksm=ce9b674af9ecee5c2550b2eeaeccb53652e4c5d54f20b6f6c20e97219f6ecf0a61ede0e69e85&amp;scene=21#wechat_redirect)。

回到前文所讲，“摩尔定律是个经济规律， 是一个技术发展、市场扩大、单价降低、利润再回馈到研发的良性循环”。那么 AI 是否有新摩尔时代？目前看来不是很乐观，**因为这个经济规律需要利润**！

**目前显然没有哪家 AI 公司能产生足够的利润。**

而L4之前又只能靠信仰，一路没有足够能产生利润的商业模式可以良性循环！只靠炒股和融资，是无法支撑五个数量级的研发的。

我们只能隔岸观火、静观其变，时刻判断进步的推理能力、和更低的推理成本，能否解锁可行的商业模式。我们的努力，也是为 Scaling Law 成为一个自我实现的寓言（Self-fulfilling Prophecy）添砖加瓦。

最可能的未来？

Scaling Law 为真

所需的时间、资本、数据和算力，**远远超出大家的判断**

可能要 **100P** 的模型才能做出AGI

因此**所需时间可能不是5年，<span style="color: rgb(255,76,65)">甚至不是10年内</span>**

从业的科学家容易一叶障目，正如&nbsp;[王川: 为什么摩尔定律一直没死, 但人们还会继续预测摩尔定律要死](http://mp.weixin.qq.com/s?__biz=MzA3MzE5MjM2Mw==&amp;mid=2672247364&amp;idx=1&amp;sn=442a86dd3e90e1271f09bb70aa44229b&amp;chksm=85a12480b2d6ad96a117e69cbbba39cd4c8bf42893813aa35a117590636193b7dab801058e09&amp;scene=21#wechat_redirect)；AGI 可能是相反的，大家前期的资源获取过于容易，对未来难度预估不足

由于从业者高估速度，低估所需资本，这一轮最终摘桃子的可能是巨头和资本家，而不是创业者（爱迪生、西屋、特斯拉等人全部出局，JP摩根照单全收）

作为应用层创业者，应该如小平同志所讲，在这个赛道里，“冷静观察，沉着应对，韬光养晦，有所作为。”

长期主义、指数增长，做时间的朋友。

我们不求快，贯彻 Presence的企业文化：**更健康、更长久。**

