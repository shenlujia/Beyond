需要提前了解一下HLS协议 [官方](https://tools.ietf.org/html/draft-pantos-http-live-streaming-23) [民间](http://akagi201.org/post/hls-explained/)

## HLS最优体验

1.内容可编辑 - 可以选择播放列表多码率适配，支持新媒体格式（iframe），新的编解码器

2.应用程序设计 - 使用AVFoundation API开发整个Apple生态的应用程序

3.交付 - 服务器配置方便而且性能友好

结合你的内容、程序或者交付变化，理解和量化用户体验

可以通过方法找到最优的配置

## 您将学习到什么？

1.创建一个通用语言来描述流媒体服务质量

2.如何客观衡量你的应用程序流媒体服务质量

3.定位并解决影响流媒体服务质量的问题

4.正确使用主播放列表(Master Playlists)

### 一、流媒体直播回放过程解刨



![img](https:////upload-images.jianshu.io/upload_images/1322721-b26774e172be3543.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200)



- 播放启动时长：从获取m3u8的主播列表,根据主播放列表信息获取符合当前播放环境的播放资源地址，然后下载对应TS切片（两级m3u8播放列表：第一级用于支持多码率适配，第二级是才是播放切片列表），直到第一帧缓冲结束并可以播放的时长。即是isPlaybackLikelyToKeepUp等于true的时候，启动完成

  

  ```objectivec
  AVPlayerItem.isPlaybackLikelyToKeepUp == true 
  ```

- 播放中断(stall)时长：网络不佳的时候，缓冲区没有可播放的内容，等待缓冲完成达到重新可播放的间隔

- 正常播放

### 二、量化流媒体播放体验主要指标

- 播放启动时长

  

  ![img](https:////upload-images.jianshu.io/upload_images/1322721-19f8c587d46b073d.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200)

  

  当AVPlayer.status == .readyToPlay或者AVPlayerItem.status == .readyToPlay时，并不是可以立马播放。官方建议当AVPlayer.timeControlStatus == .playing 或者 监听到AVPlayerItem.timebase的kCMTimebaseNotification_EffectiveRateChanged通知且CMTimebaseGetRate(AVPlayerItem.timebase) > 0时，即是真正可以播放的状态。

  因此，点击播放到AVPlayer.timeControlStatus == .playing或者CMTimebaseGetRate(AVPlayerItem.timebase) > 0的间隔即是播放启动时长。

- 播放中断频率

  性能指标：中断次数/总观看时长。监听AVPlayerItemPlaybackStalled通知，统计中断的频次。

- 播放中断时长

  性能指标：全部中断时长/总观看时长。监听AVPlayerItemPlaybackStalled发生到收到kCMTimebaseNotification_EffectiveRateChanged通知的间隔，即是一次中断的时长。

  

  ```csharp
  //总观看时长计算代码
  var totalDurationWatched = 0.0
  
  if let accessLog = playerItem.accessLog() {
      for event in accessLog.events {
          if event.durationWatched > 0 {
              totalDurationWatched += event.durationWatched
          }
      }
  }
  ```

  什么是AVPlayerItemAccessLog（上面代码中的playerItem.accessLog）？

  

  ```objectivec
  AVPlayerItemAccessLog - 整个播放过程的日志信息
  当收到AVPlayerItemNewAccessLogEntry通知时，就可以获取到日志
  AVPlayerItemAccessLog包含一组AVPlayerItemAccessLogEvent日志事件
  每个事件中记录了如下信息：
  URI 默认值nil
  indicatedBitrate 默认值-1
  observedBitrate 默认值-1
  numberOfBytesTransferred 默认值-1
  durationWatched 默认值-1
  ```

- 整个流媒体质量

  性能指标：时间加权指示比特率(Time-weighted Indicated Bitrate)，即是正常整个播放时长内比特率时间加权平均值

  

  ![img](https:////upload-images.jianshu.io/upload_images/1322721-129c3622ebd3de5b.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200)

  

  

  ```csharp
  //时间加权指示比特率计算代码
  var timeWeightedIBR = 0.0
  if let accessLog = playerItem.accessLog(), totalDurationWatched > 0 {
      for event in accessLog.events {
          if event.durationWatched > 0 && event.indicatedBitrate > 0 {
              let eventTimeWeight = event.durationWatched / totalDurationWatched
              timeWeightedIBR += event.indicatedBitrate * eventTimeWeight
          }
      }
  }
  ```

- 流媒体播放发送错误的频次

  性能指标：发生错误的次数/全部播放次数。当AVPlayerItem.status == .failed，记录错误频次bing并并可通过AVPlayerItem.error获取错误信息

  AVPlayerItemErrorLog：通过错误日志衡量播放失败对用户的影响。AVPlayerItemErrorLog里包含一组AVPlayerItemErrorLogEvent，每个event记录了错误产生的具体信息如下：

  

  ```bash
  date = 2018-06-16 15:04:41
  errorStatusCode = -12889
  errorDomain = "CoreMediaErrorDomain"
  errorComment = "No response for media file in 9.9767s"
  ```

#### 用户体验总结

|    用户体验    |    度量    |          主要性能指标           |
| :------------: | :--------: | :-----------------------------: |
|  等待播放开始  |  启动时长  |       每次播放的启动时长        |
|    播放中断    |  中断次数  | 中断频率（中断次数/总观看时长） |
|    中断等待    |  中断时长  |     全部中断时长/总观看时长     |
| 流媒体整体质量 | 指示比特率 |       时间加权指示比特率        |
|    播放失败    |  播放错误  |   发生错误的次数/全部播放次数   |

备注：（1）主要性能指标在不同设备和使用场景下是不可比较的
（2）收集流媒体度量信息时需要同时收集上下文信息（3）对收集的信息进行分类，找出对你的程序有益的信息

### 三、提升HLS的性能

提升途径

- 减少播放启动时长
- 分析中断的原因，减少中断次数
- 分析播放出错的原因，减少出错次数

#### 播放启动时长优化

##### 影响播放启动的因素



![img](https:////upload-images.jianshu.io/upload_images/1322721-8d5609a1852d2194.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200)



1. AVAsset获取远程一级和二级m3u8文件，一级是主播放列表，根据当前播放环境选择最适合当前播放环境的播放列表地址（播放TS切片列表），即是二级m3u8文件地址，然后请求二级m3u8里的资源列表
2. 下载资源缓冲
3. 如果是加密流媒体，需要获取解密秘钥
4. 如果有继续上一次播放功能，重新定位播放时间点再次缓冲
5. 可选配置，如选择切换语言或者清晰度，需要重新获取对应的资源

##### 测量播放启动时长

- 记录API调用和监听Player和PlayerItem状态变化时间戳，计算时间消耗
- 通过系统提供的AVPlayerItemAccessLogEvent.startupTime获取启动时长
- 从开始下载到AVPlayerItem.isPlaybackLikelyToKeepUp == true 的时间间隔

##### 减少播放时长可选方法

- 在用户点击播放之前创建AVAsset，去除上面影响因素1的时间开销
- 去除加密环节或者采用苹果提供的AVContentKeySession API进行秘钥处理
- 如果能预知用户什么时候会触发播放，可以提前seek历史进度。如果能预知用户的可选配置选项，可以提前配置对应的信息的资源
- 如果播放多个内容，建议使用AVQueuePlayer。AVQueuePlayer会在前一个播放内容下载完成后，提前下载下一个播放内容

总的来说提前创建AVPlayItem和在创建AVPlayItem前设置播放器的播放速率，在用户点击播放前提前设置预知信息，减少用户不必要的等待时长。

##### 影响网络缓冲时间的因素

- 提供多样性的播放列表，如多种码率，分辨率和编码方式等
- 播放内容的比特率（bitrate）
- 目标播放列表的时长（每个TS切片的播放时长）
- 网络带宽

那么减少启动网络缓冲的方法如下：

（1）启动阶段可以选择先获取低比特率的内容减少网络缓冲时间但是需要牺牲初始的视频质量
（2）启动阶段选择合适的流媒体格式（HDR / SDR, HEVC / H.264, Stereo / DD / DD+）

#### 播放中断优化

##### 中断分析方法

1. 中断消息监听

   

   ```csharp
   //监听状态代码
   notificationCenter.addObserver(self,
   selector: #selector(handlePlaybackStalled(_:)),
   name: .AVPlayerItemPlaybackStalled, object: playerItem)
   ```

2. 检测AVPlayerItem的状态，如AVPlayerItem.isPlaybackLikelyToKeepUp AVPlayerItemErrorLog

3. AVPlayerItemErrorLog

4. AVPlayerItemAccessLog

##### 例子分析

1. 网络带宽导致中断例子：

   

   ![img](https:////upload-images.jianshu.io/upload_images/1322721-a52b704945252461.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200)

   

解决：提供全套比特率层级适配，每个编解码器组合都需要自己的全套比特率层级

1. 内容创作和服务配置导致中断的例子

   

   ![img](https:////upload-images.jianshu.io/upload_images/1322721-65a7799a583d70c0.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200)

   

   解决：你的服务器和CND必须具有如下能力

   （1）无延迟地传送媒体播放列表，内容切片和密钥

   （2）至少在每个目标持续时间更新播放列表

   （3）可以同步播放列表之间的不连续序号

   （4）可以清楚的指出服务端的错误信息

#### 播放错误优化

##### 播放错误分析方法

1. 通过AVPlayerItem的AVPlayerItemErrorLog和AVPlayerItemAccessLog获取错误日志

2. 监测AVPlayer和AVPlayerItem的错误属性，如AVPlayerItem.status and AVPlayerItem.error

   

   ```swift
   playerItemObserver = playerItem?.observe(\AVPlayerItem.status, options: [.new, .initial]) { 
       [weak self] (item, _) in
       guard let strongSelf = self else { return }
       if item.status == .failed {
           let error = item.error
           print(“AVPlayerItem Error: \(String(describing: error?.localizedDescription))”)
           let errorLog = item.errorLog()
           let lastErrorEvent = errorLog?.events.last
       }
      print(“ErrorLog: \(String(describing: lastErrorEvent?.description))”)
   }
   ```

   

   ```css
   HDCP（High-bandwidth Digital Content Protection）高带宽数码内容保护流媒体错误
   监测AVPlayer.isOutputObscuredDueToInsufficientExternalProtection属性
   以下几种情况isOutputObscuredDueToInsufficientExternalProtection会发生改变
   1.当前播放内容需要外部保护
   2.当前设备跟保护等级不匹配
   3.用户观察视频内容丢失
   
   解决：（1）需要适配非HDCP （2）App用户界面能够反馈属性发生变化
   ```

3. 媒体流验证错误 -- 使用开发者网站上的媒体流验证器进行验证

### 四、Master Playlists正确打开姿势



```undefined
HLS协议通过URI来获取playlist，playlist分为两级：
第一级是Master PlayList 
第二级是Media Playlist
Master PlayList可以理解成是配置列表，根据播放环境匹配最适合的Media Playlist。
Media Playlist即是资源的播放TS切片。
```

#### 正确使用Master Playlists能够提供流畅的播放体验 -- “正确的做法是给我们提供你所拥有的一切“

媒体播放列表的峰值比特率是任何连续组片段的最大比特率，其总持续时间在目标持续时间的0.5和1.5倍之间。

1. 如何保证播放器选择正确的播放流

   Master playList里的EXT-X-STREAM-INF tag需要提供下图中的信息。确保播放器能够根据这些参数选择最适合播放环境的播放流

   

   ![img](https:////upload-images.jianshu.io/upload_images/1322721-9e1cc4a3b8879202.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200)

   

   

   ![img](https:////upload-images.jianshu.io/upload_images/1322721-c91928ee05e72e42.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200)

   

1. 为什么快进或者在当焦点停留Apple TV的进度条看不到图像

   EXT-X-I-FRAME-STREAM-INF：需要提供I帧(视频编解码独立的帧，解压时不依赖其他帧)，I帧间隔越均匀，每帧之间的间隔越近，体验越好

   

   ![img](https:////upload-images.jianshu.io/upload_images/1322721-e24fbfbbdd7fcd1a.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200)

   

1. 如何支持多种语言

   支持两种语言例子

   

   ![img](https:////upload-images.jianshu.io/upload_images/1322721-7cb9d819285d07c1.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200)

   

   AUTOSELECT和DEFAULT的区别

   AUTOSELECT：
   该次播放可以自动选择
   通常，您希望将此设置设置为YES
   类似评论跟踪的场景可以设置成NO

   DEFAULT:
   本次播放播放器的默认选择项
   一组中只有一个选项能设置DEFAULT=YES
   前提必须AUTOSELECT=YES
   跟默认参数没有任何关系

2. 如何支持多声道音频

   两种语言两种音频格式

   

   ![img](https:////upload-images.jianshu.io/upload_images/1322721-837af48a1be4e2af.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200)

   

3. 如何支持多种音频比特率和多种格式

   

   ![img](https:////upload-images.jianshu.io/upload_images/1322721-f3d078d7b15ff2c9.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200)

   

4. 如何支持多种视频编解码格式

   设置CODECS参数

   

   ![img](https:////upload-images.jianshu.io/upload_images/1322721-1881ce7762293e9d.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200)

   

   

   ![img](https:////upload-images.jianshu.io/upload_images/1322721-e610a568b3254453.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200)

   

   

   ![img](https:////upload-images.jianshu.io/upload_images/1322721-57fa966510e6f9c0.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200)

   

5. 如何支持副标题和隐藏字幕

   TYPE=SUBTITLES
   TYPE=CLOSED-CAPTIONS

   

   ![img](https:////upload-images.jianshu.io/upload_images/1322721-a1db9dd1350501ed.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200)

   

## 总结

- 通过分析关键性能指标（播放启动时长、中断频率、中断时长占比、时间加权指示比特率和发生播放错误频率）来确定HLS性能。
- 正确使用系统提供的API(如AVPlayerItemAccessLog)来收集HLS播放日志，记得收集环境信息。
- 正确使用HLS的Master Playlists能够提高用户观看体验