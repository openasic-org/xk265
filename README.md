# H.265 Video Encoder IP Core 
> ### 开源H.265 硬件视频编码器

H.265 Video Encoder IP Core 是开源的H.265硬件视频编码器，实现了H.265（或叫HEVC）的大部分功能。它由[复旦大学](http://fudan.edu.cn/)[专用集成电路与系统国家重点实验室](http://sme.fudan.edu.cn/)（State Key Lab of ASIC & System，Fudan University）[视频图像处理器实验室](http://viplab.fudan.edu.cn)（Video&Image Processor, VIP Lab）[范益波](https://sme.fudan.edu.cn/info/detail?id=132)教授研究团队开发完成，并开放源代码。任何组织个人可以无偿使用上述代码用于研究和生产目的，VIP Lab将会持续更新并维护H.265硬件视频编码器的开发。

> ### 基本Feature
* HEVC/H.265 Main Profile
* YUV 4:2:0
* Bitdepth 8
* 4K@30fps, 400MHz
* GOP: I/P
* CTU: 64x64
* CU: 8x8~64x64
* PU: 4x4~64x64
* TU: 4x4/8x8/16x16/32x32
* 1/4 Sub-pixel
* Search range 64
* All 35 Intra prediction mode
* CABAC
* Deblocking Filter
* SAO (Sample Adaptive Offset)
* Rate control: CBR/VBR (Software-based)
* Rate control: CTU level (Hardware-based)
* SKIP/MERGE
* Intra CTU in Inter frame

> ### 关于VIP Lab

复旦大学VIP实验室专注于从事下一代视频、图像硬件处器研究，包括超高清视频编码器（H.264/H.265 Video Encoder IP），图像去雾（Dehazing）处理器，双目视觉处理器（Stereo Matching）等。
实验室网站 http://viplab.fudan.edu.cn

> ### 项目论坛

http://www.openasic.org
