/**
 * 饵知道 - 胜利结算图页面
 * 生成精美的渔获分享图
 * 
 * 使用 SaveButton 安全控件保存图片到相册，无需申请权限
 */
import { ThemeColors } from '../theme/ThemeColors';
import { ThemeConstants } from '../theme/ThemeConstants';
import { Router } from '../router/Router';
import { FishingRecord } from '../common/types/UserTypes';
import { promptAction, componentSnapshot } from '@kit.ArkUI';
import { image } from '@kit.ImageKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { getCachedWeather, WeatherData } from '../services/WeatherService';
import { LocationService } from '../services/LocationService';
import { site } from '@kit.MapKit';

// 分享卡片样式
interface CardStyle {
  name: string;
  bgColor: string;
  gradientColors: [string, number][];
  textColor: string;
  accentColor: string;
  bgImage?: string;  // 可选的背景图片
}

@Entry
@Component
struct VictorySharePage {
  @State record: FishingRecord | null = null;
  // 实时位置和天气数据
  @State currentLocation: string = '';
  @State currentWeather: string = '';
  @State selectedPhoto: string = '';
  @State selectedStyle: number = 0;
  @State isGenerating: boolean = false;
  @State victoryComment: string = '';
  @State victoryTags: string[] = [];
  @State decorationText: string = '666';
  @State generatedImageUri: string = '';  // 生成的图片URI
  @State showSuccessDialog: boolean = false;  // 显示成功弹窗
  @State customBgImage: string = '';  // 自定义背景图

  // 卡片样式预设
  private cardStyles: CardStyle[] = [
    {
      name: '金色荣耀',
      bgColor: '#1a1a2e',
      gradientColors: [['rgba(232,168,73,0.8)', 0], ['rgba(255,200,100,0.3)', 1]],
      textColor: '#FFFFFF',
      accentColor: '#E8A849'
    },
    {
      name: '海洋蓝',
      bgColor: '#0a1628',
      gradientColors: [['rgba(64,169,255,0.7)', 0], ['rgba(24,144,255,0.2)', 1]],
      textColor: '#FFFFFF',
      accentColor: '#40A9FF'
    },
    {
      name: '森林绿',
      bgColor: '#0d1f0d',
      gradientColors: [['rgba(82,196,26,0.7)', 0], ['rgba(115,209,61,0.2)', 1]],
      textColor: '#FFFFFF',
      accentColor: '#52C41A'
    },
    {
      name: '晚霞紫',
      bgColor: '#1a0a28',
      gradientColors: [['rgba(177,130,255,0.7)', 0], ['rgba(114,46,209,0.2)', 1]],
      textColor: '#FFFFFF',
      accentColor: '#B182FF'
    },
    {
      name: '自定义',
      bgColor: '#1a1a2e',
      gradientColors: [['rgba(0,0,0,0.5)', 0], ['rgba(0,0,0,0.3)', 1]],
      textColor: '#FFFFFF',
      accentColor: '#FFD700'
    }
  ];

  aboutToAppear(): void {
    const params = Router.getParams() as Record<string, Object>;
    if (params && params.record) {
      this.record = params.record as FishingRecord;
      // 默认选择第一张图片
      if (this.record.photos && this.record.photos.length > 0) {
        this.selectedPhoto = this.record.photos[0];
      }
    }
    // 初始化随机内容
    this.refreshRandomContent();
    
    // 获取实时位置和天气数据
    this.loadCurrentLocationAndWeather();
  }

  // 加载当前位置和天气
  private async loadCurrentLocationAndWeather(): Promise<void> {
    // 获取缓存的天气数据
    const weather = getCachedWeather();
    if (weather.isValid) {
      this.currentWeather = weather.weatherText;
    }
    
    // 获取当前位置的精确地址
    const location = LocationService.currentLocation;
    if (location.isValid) {
      try {
        const params: site.ReverseGeocodeParams = {
          location: {
            latitude: location.latitude,
            longitude: location.longitude
          },
          language: 'zh',
          radius: 50  // 小半径获取更精确的位置
        };
        const result = await site.reverseGeocode(params);
        if (result && result.addressComponent) {
          const addr = result.addressComponent;
          // 拼接地址：区 + 街道/道路，获取更精确的位置
          const parts: string[] = [];
          if (addr.adminLevel3) {
            parts.push(addr.adminLevel3);
          }
          if (addr.adminLevel4) {
            parts.push(addr.adminLevel4);
          }
          
          if (parts.length > 0) {
            this.currentLocation = parts.join(' ');
          } else if (addr.adminLevel2) {
            this.currentLocation = addr.adminLevel2;
          } else {
            this.currentLocation = '当前位置';
          }
        }
      } catch (error) {
        console.error('获取位置名称失败:', JSON.stringify(error));
      }
    }
  }

  // 刷新随机内容
  private refreshRandomContent(): void {
    this.victoryComment = this.generateVictoryComment();
    this.victoryTags = this.generateVictoryTags();
    this.decorationText = this.generateDecorationText();
  }

  build() {
    Stack() {
      // 主内容
      Column() {
        this.HeaderBar()

        Scroll() {
          Column({ space: 16 }) {
            // 预览卡片
            this.PreviewCard()

            // 图片选择（如果有多张）
            if (this.record?.photos && this.record.photos.length > 1) {
              this.PhotoSelector()
            }

            // 样式选择
            this.StyleSelector()

            // 操作按钮
            this.ActionButtons()
          }
          .padding({ left: 16, right: 16, bottom: 40 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(ThemeColors.BG_PRIMARY)

      // 成功弹窗 - 全屏覆盖
      if (this.showSuccessDialog) {
        this.SuccessDialog()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  HeaderBar() {
    Column() {
      Row().width('100%').height(36)

      Row() {
        Image($r('app.media.Left'))
          .width(24)
          .height(24)
          .fillColor(ThemeColors.TEXT_PRIMARY)
          .onClick(() => Router.back())

        Blank()

        Text('生成分享图')
          .fontSize(ThemeConstants.FONT_SIZE_LG)
          .fontWeight(FontWeight.Medium)
          .fontColor(ThemeColors.TEXT_PRIMARY)

        Blank()

        Row().width(24)
      }
      .width('100%')
      .height(48)
      .padding({ left: 16, right: 16 })
    }
    .width('100%')
  }

  // 根据渔获数据生成趣味评语 - 更骄傲更随机
  private generateVictoryComment(): string {
    const weight = this.record?.weight || 0;
    const count = this.record?.count || 0;

    // 超级大丰收 (10kg+)
    if (weight >= 10) {
      const comments = [
        '🏆 今天我就是钓神！不接受反驳！',
        '👑 封神之战！这鱼塘我承包了！',
        '🔥 爆护警告！其他钓友已羡慕哭！',
        '💎 王者归来！鱼儿排队上钩！',
        '🚀 起飞！今天的鱼都是我的！'
      ];
      return comments[Math.floor(Math.random() * comments.length)];
    }

    // 大丰收 (5kg+)
    if (weight >= 5) {
      const comments = [
        '💪 666！今天状态拉满！',
        '😎 就这？轻轻松松拿下！',
        '🎯 精准出击，弹无虚发！',
        '⚡ 开挂了属于是！太强了！',
        '🌟 闪耀全场！MVP非我莫属！'
      ];
      return comments[Math.floor(Math.random() * comments.length)];
    }

    // 连竿 (10尾+)
    if (count >= 10) {
      const comments = [
        '🔥 连竿到手软！停不下来！',
        '💥 爆护模式开启！鱼儿疯狂咬钩！',
        '🎪 今天的鱼都想认识我！',
        '⭐ 数量即正义！量大管饱！',
        '🎰 中奖了！今天运气爆棚！'
      ];
      return comments[Math.floor(Math.random() * comments.length)];
    }

    // 不错的收获 (2kg+ 或 3尾+)
    if (weight >= 2 || count >= 3) {
      const comments = [
        '👍 稳如老狗！这波不亏！',
        '😏 小意思，下次更猛！',
        '✨ 今日份的快乐已到账！',
        '🎣 技术在线，渔获满满！',
        '💯 完美收官！明天继续！'
      ];
      return comments[Math.floor(Math.random() * comments.length)];
    }

    // 开张
    const comments = [
      '🎉 开张大吉！好运开始！',
      '🌈 万事开头难，后面全是鱼！',
      '🍀 今天的幸运已签到！',
      '😄 重在参与，快乐钓鱼！',
      '🎈 小试牛刀，大的还在后面！'
    ];
    return comments[Math.floor(Math.random() * comments.length)];
  }

  // 获取趣味标签 - 更多随机标签
  private generateVictoryTags(): string[] {
    const tags: string[] = [];
    const weight = this.record?.weight || 0;
    const count = this.record?.count || 0;

    // 根据重量添加标签
    if (weight >= 10) {
      const heavyTags = ['钓神下凡', '鱼塘终结者', '今日MVP', '渔获之王'];
      tags.push(heavyTags[Math.floor(Math.random() * heavyTags.length)]);
    } else if (weight >= 5) {
      const goodTags = ['钓鱼大师', '技术流', '稳定发挥', '实力派'];
      tags.push(goodTags[Math.floor(Math.random() * goodTags.length)]);
    }

    // 根据数量添加标签
    if (count >= 10) {
      const manyTags = ['连竿王', '爆护达人', '数量担当', '效率之星'];
      tags.push(manyTags[Math.floor(Math.random() * manyTags.length)]);
    } else if (count >= 5) {
      const someTags = ['小有斩获', '渔获满满', '收获颇丰'];
      tags.push(someTags[Math.floor(Math.random() * someTags.length)]);
    }

    // 天气相关标签
    if (this.record?.weather === '小雨') {
      tags.push('风雨无阻');
    } else if (this.record?.weather === '大风') {
      tags.push('迎风作战');
    } else if (this.record?.weather === '晴朗') {
      const sunnyTags = ['阳光钓手', '好天好鱼'];
      tags.push(sunnyTags[Math.floor(Math.random() * sunnyTags.length)]);
    }

    // 随机趣味标签
    const funTags = ['快乐垂钓', '佛系钓鱼', '享受过程', '钓鱼使我快乐', '今日宜钓鱼'];
    if (tags.length < 2) {
      tags.push(funTags[Math.floor(Math.random() * funTags.length)]);
    }

    return tags.slice(0, 3); // 最多3个标签
  }

  // 获取装饰性背景文字
  private generateDecorationText(): string {
    const texts = ['666', 'NICE', '牛!', '6!', '赢!', 'WIN', 'YES'];
    return texts[Math.floor(Math.random() * texts.length)];
  }

  @Builder
  PreviewCard() {
    Column() {
      Text('预览效果')
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .width('100%')
        .margin({ bottom: 8 })

      // 分享卡片预览
      Column() {
        // 顶部标题栏
        Row() {
          Row({ space: 6 }) {
            Text('🎣')
              .fontSize(18)
            Text('渔获战报')
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.cardStyles[this.selectedStyle].textColor)
          }

          Blank()

          Text(this.record?.dateStr || '')
            .fontSize(11)
            .fontColor(this.cardStyles[this.selectedStyle].textColor)
            .opacity(0.7)
        }
        .width('100%')
        .padding({ left: 14, right: 14, top: 14 })

        // 趣味评语
        Row() {
          Text(this.victoryComment)
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.cardStyles[this.selectedStyle].accentColor)
        }
        .width('100%')
        .padding({ left: 14, right: 14, top: 6 })

        // 主图区域 - 保持图片原始比例
        Column() {
          if (this.selectedPhoto) {
            Image(this.selectedPhoto)
              .width('100%')
              .fitOriginalSize(true)
              .objectFit(ImageFit.Contain)
              .borderRadius(10)
          } else {
            // 无图片占位
            Column() {
              Text('🐟')
                .fontSize(40)
              Text('暂无渔获图片')
                .fontSize(12)
                .fontColor(this.cardStyles[this.selectedStyle].textColor)
                .opacity(0.5)
                .margin({ top: 6 })
            }
            .width('100%')
            .height(140)
            .justifyContent(FlexAlign.Center)
            .backgroundColor('rgba(255,255,255,0.08)')
            .borderRadius(10)
          }
        }
        .width('100%')
        .padding({ left: 14, right: 14, top: 10 })

        // 趣味标签
        Row({ space: 6 }) {
          ForEach(this.victoryTags, (tag: string) => {
            Text(`#${tag}`)
              .fontSize(10)
              .fontColor(this.cardStyles[this.selectedStyle].accentColor)
              .padding({ left: 8, right: 8, top: 3, bottom: 3 })
              .backgroundColor(`${this.cardStyles[this.selectedStyle].accentColor}20`)
              .borderRadius(10)
          }, (tag: string) => tag)
        }
        .width('100%')
        .padding({ left: 14, right: 14, top: 10 })

        // 数据展示
        Row() {
          // 鱼种
          Column({ space: 3 }) {
            Text('🐟 鱼种')
              .fontSize(9)
              .fontColor(this.cardStyles[this.selectedStyle].textColor)
              .opacity(0.6)
            Text(this.record?.fishName || '未知')
              .fontSize(13)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.cardStyles[this.selectedStyle].accentColor)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)

          // 分隔线
          Column()
            .width(1)
            .height(30)
            .backgroundColor(this.cardStyles[this.selectedStyle].textColor)
            .opacity(0.2)

          // 重量
          Column({ space: 3 }) {
            Text('⚖️ 总重')
              .fontSize(9)
              .fontColor(this.cardStyles[this.selectedStyle].textColor)
              .opacity(0.6)
            Text(`${this.record?.weight || 0} kg`)
              .fontSize(13)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.cardStyles[this.selectedStyle].accentColor)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)

          // 分隔线
          Column()
            .width(1)
            .height(30)
            .backgroundColor(this.cardStyles[this.selectedStyle].textColor)
            .opacity(0.2)

          // 数量
          Column({ space: 3 }) {
            Text('🔢 数量')
              .fontSize(9)
              .fontColor(this.cardStyles[this.selectedStyle].textColor)
              .opacity(0.6)
            Text(`${this.record?.count || 0} 尾`)
              .fontSize(13)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.cardStyles[this.selectedStyle].accentColor)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        .padding({ left: 14, right: 14, top: 12 })

        // 钓点和天气
        Row() {
          Row({ space: 4 }) {
            Text('📍')
              .fontSize(11)
            Text(this.currentLocation || this.record?.location || '未知钓点')
              .fontSize(11)
              .fontColor(this.cardStyles[this.selectedStyle].textColor)
              .opacity(0.7)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .layoutWeight(1)

          Row({ space: 4 }) {
            Text(this.getWeatherIcon(this.currentWeather || this.record?.weather || ''))
              .fontSize(11)
            Text(this.currentWeather || this.record?.weather || '')
              .fontSize(11)
              .fontColor(this.cardStyles[this.selectedStyle].textColor)
              .opacity(0.7)
          }
        }
        .width('100%')
        .padding({ left: 14, right: 14, top: 10 })

        // 底部水印
        Row() {
          Text('— 饵知道 · 智能钓鱼助手 —')
            .fontSize(9)
            .fontColor(this.cardStyles[this.selectedStyle].textColor)
            .opacity(0.4)
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding({ top: 12, bottom: 12 })
      }
      .width('100%')
      .backgroundImage(this.isCustomStyle() && this.customBgImage ? this.customBgImage : '')
      .backgroundImageSize(ImageSize.Cover)
      .backgroundColor(this.cardStyles[this.selectedStyle].bgColor)
      .linearGradient({
        direction: GradientDirection.RightBottom,
        colors: this.cardStyles[this.selectedStyle].gradientColors
      })
      .borderRadius(16)
      .clip(true)
      .shadow({ radius: 16, color: 'rgba(0,0,0,0.25)', offsetY: 8 })
      .id('victoryCard')
    }
  }

  // 判断是否为自定义样式
  private isCustomStyle(): boolean {
    return this.selectedStyle === this.cardStyles.length - 1;
  }

  // 选择自定义背景图
  private async selectCustomBgImage(): Promise<void> {
    try {
      const photoPicker = new photoAccessHelper.PhotoViewPicker();
      const result = await photoPicker.select({
        MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE,
        maxSelectNumber: 1
      });
      if (result.photoUris && result.photoUris.length > 0) {
        this.customBgImage = result.photoUris[0];
        // 自动切换到自定义样式
        this.selectedStyle = this.cardStyles.length - 1;
      }
    } catch (error) {
      console.error('选择背景图失败:', JSON.stringify(error));
    }
  }

  @Builder
  SuccessDialog() {
    Stack() {
      // 遮罩
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.6)')
        .onClick(() => {
          this.showSuccessDialog = false;
        })

      // 弹窗内容
      Column({ space: 16 }) {
        Text('🎉')
          .fontSize(48)

        Text('分享图已生成')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.TEXT_PRIMARY)

        Text('图片已保存到相册')
          .fontSize(14)
          .fontColor(ThemeColors.TEXT_SECONDARY)
          .textAlign(TextAlign.Center)

        Column({ space: 4 }) {
          Text('✅ 保存成功')
            .fontSize(12)
            .fontColor(ThemeColors.SUCCESS)
          Text('可在相册中查看和分享')
            .fontSize(12)
            .fontColor(ThemeColors.TEXT_SECONDARY)
        }
        .padding(12)
        .backgroundColor(ThemeColors.SUCCESS_LIGHT)
        .borderRadius(8)
        .width('100%')

        Row({ space: 12 }) {
          Button('继续编辑')
            .fontSize(14)
            .fontColor(ThemeColors.TEXT_PRIMARY)
            .backgroundColor(ThemeColors.BG_TERTIARY)
            .borderRadius(20)
            .height(40)
            .layoutWeight(1)
            .onClick(() => {
              this.showSuccessDialog = false;
            })

          Button('完成')
            .fontSize(14)
            .fontColor(ThemeColors.TEXT_PRIMARY)
            .backgroundColor(ThemeColors.PRIMARY)
            .borderRadius(20)
            .height(40)
            .layoutWeight(1)
            .onClick(() => {
              this.showSuccessDialog = false;
              Router.back();
            })
        }
        .width('100%')
        .margin({ top: 8 })
      }
      .width('80%')
      .padding(24)
      .backgroundColor(ThemeColors.BG_CARD)
      .borderRadius(20)
      .shadow({ radius: 20, color: 'rgba(0,0,0,0.3)', offsetY: 10 })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  PhotoSelector() {
    Column({ space: 8 }) {
      Text('选择展示图片')
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .width('100%')

      Row({ space: 8 }) {
        ForEach(this.record?.photos || [], (photo: string, index: number) => {
          Stack() {
            Image(photo)
              .width(72)
              .height(72)
              .objectFit(ImageFit.Cover)
              .borderRadius(8)
              .opacity(this.selectedPhoto === photo ? 1 : 0.6)

            if (this.selectedPhoto === photo) {
              Column()
                .width(72)
                .height(72)
                .borderRadius(8)
                .border({ width: 3, color: ThemeColors.PRIMARY })

              Text('✓')
                .fontSize(16)
                .fontColor(Color.White)
                .backgroundColor(ThemeColors.PRIMARY)
                .borderRadius(12)
                .width(24)
                .height(24)
                .textAlign(TextAlign.Center)
                .position({ x: 48, y: -4 })
            }
          }
          .onClick(() => {
            this.selectedPhoto = photo;
          })
        }, (photo: string, index: number) => `select_${index}`)
      }
    }
  }

  @Builder
  StyleSelector() {
    Column({ space: 8 }) {
      Row() {
        Text('选择卡片样式')
          .fontSize(ThemeConstants.FONT_SIZE_SM)
          .fontColor(ThemeColors.TEXT_SECONDARY)

        Blank()

        // 换一换按钮
        Row({ space: 4 }) {
          Text('🎲')
            .fontSize(14)
          Text('换一换文案')
            .fontSize(ThemeConstants.FONT_SIZE_XS)
            .fontColor(ThemeColors.PRIMARY)
        }
        .padding({ left: 10, right: 10, top: 4, bottom: 4 })
        .backgroundColor(ThemeColors.PRIMARY_LIGHT)
        .borderRadius(12)
        .onClick(() => {
          this.refreshRandomContent();
        })
      }
      .width('100%')

      Scroll() {
        Row({ space: 12 }) {
          ForEach(this.cardStyles, (style: CardStyle, index: number) => {
            Column({ space: 6 }) {
              // 样式预览色块
              Stack() {
                // 自定义样式显示背景图或添加图标
                if (index === this.cardStyles.length - 1) {
                  if (this.customBgImage) {
                    Image(this.customBgImage)
                      .width(60)
                      .height(40)
                      .objectFit(ImageFit.Cover)
                      .borderRadius(8)
                  } else {
                    Column()
                      .width(60)
                      .height(40)
                      .backgroundColor('#333')
                      .borderRadius(8)
                    Text('📷')
                      .fontSize(18)
                  }
                } else {
                  Column()
                    .width(60)
                    .height(40)
                    .backgroundColor(style.bgColor)
                    .borderRadius(8)

                  Column()
                    .width(60)
                    .height(40)
                    .linearGradient({
                      direction: GradientDirection.RightBottom,
                      colors: style.gradientColors
                    })
                    .borderRadius(8)
                }

                if (this.selectedStyle === index) {
                  Text('✓')
                    .fontSize(14)
                    .fontColor(Color.White)
                }
              }
              .border(this.selectedStyle === index ?
                { width: 2, color: ThemeColors.PRIMARY } :
                { width: 1, color: ThemeColors.TEXT_MUTED })
              .borderRadius(8)

              Text(style.name)
                .fontSize(ThemeConstants.FONT_SIZE_XS)
                .fontColor(this.selectedStyle === index ? ThemeColors.PRIMARY : ThemeColors.TEXT_SECONDARY)
            }
            .onClick(() => {
              if (index === this.cardStyles.length - 1) {
                // 自定义样式，选择背景图
                this.selectCustomBgImage();
              } else {
                this.selectedStyle = index;
              }
            })
          }, (style: CardStyle, index: number) => `style_${index}`)
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
    }
  }

  @Builder
  ActionButtons() {
    Column({ space: 12 }) {
      // 使用 SaveButton 安全控件保存到相册
      SaveButton()
        .onClick(async (event: ClickEvent, result: SaveButtonOnClickResult) => {
          if (result === SaveButtonOnClickResult.SUCCESS) {
            await this.saveToGallery();
          } else {
            promptAction.showToast({ message: '需要授权才能保存图片' });
          }
        })

      // 返回按钮
      Button('返回')
        .fontSize(ThemeConstants.FONT_SIZE_MD)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .backgroundColor(ThemeColors.BG_TERTIARY)
        .borderRadius(ThemeConstants.RADIUS_MD)
        .width('100%')
        .height(48)
        .onClick(() => {
          Router.back();
        })
    }
    .margin({ top: 16 })
  }

  // 保存图片到相册 - 使用 SaveButton 获取临时权限
  private async saveToGallery(): Promise<void> {
    if (this.isGenerating) return;

    this.isGenerating = true;

    try {
      const context = getContext(this) as common.UIAbilityContext;
      const helper = photoAccessHelper.getPhotoAccessHelper(context);

      // onClick 触发后 5 秒内通过 createAsset 接口创建图片文件
      const uri = await helper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'jpg');

      // 使用 uri 打开文件
      const file = await fs.open(uri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);

      // 截取组件生成 PixelMap
      const snapshotOptions: componentSnapshot.SnapshotOptions = {
        waitUntilRenderFinished: true
      };
      const pixelMap = await componentSnapshot.get('victoryCard', snapshotOptions);

      if (pixelMap) {
        // 编码并写入文件
        const packOpts: image.PackingOption = { format: 'image/jpeg', quality: 95 };
        const imagePacker = image.createImagePacker();

        await imagePacker.packToFile(pixelMap, file.fd, packOpts);

        imagePacker.release();
        fs.close(file.fd);

        this.generatedImageUri = uri;
        promptAction.showToast({ message: '图片已保存至相册' });
        this.showSuccessDialog = true;
      } else {
        fs.close(file.fd);
        promptAction.showToast({ message: '截图失败，请重试' });
      }
    } catch (error) {
      const err = error as BusinessError;
      console.error(`保存失败: code=${err.code}, message=${err.message}`);
      promptAction.showToast({ message: '保存失败，请重试' });
    } finally {
      this.isGenerating = false;
    }
  }

  private getWeatherIcon(weather: string): string {
    const icons: Record<string, string> = {
      '晴朗': '☀️',
      '多云': '⛅',
      '阴天': '☁️',
      '小雨': '🌧️',
      '大风': '💨'
    };
    return icons[weather] || '🌤️';
  }
}
