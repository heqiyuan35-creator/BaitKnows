/**
 * 饵知道 - 主页面（合并欢迎页和主Tab）
 * 添加动画效果
 */
import { ThemeColors } from '../theme/ThemeColors';
import { ThemeConstants } from '../theme/ThemeConstants';
import { AppConstants } from '../common/constants/AppConstants';
import { HomePage } from './HomePage';
import { RecipeBrowserPage } from './RecipeBrowserPage';
import { GeneratorPage } from './GeneratorPage';
import { FishingRecordPage } from './FishingRecordPage';
import { MinePage } from './MinePage';
import { storageService } from '../services/StorageService';
import { userService } from '../services/UserService';
import { fishingRecordService } from '../services/FishingRecordService';

@Entry
@Component
struct WelcomePage {
  @State currentIndex: number = 0;
  @State showWelcome: boolean = true;
  @State bgIndex: number = 0;
  @State loadingAngle: number = 0;
  // 动画状态
  @State logoOpacity: number = 0;
  @State logoScale: number = 0.5;
  @State textOpacity: number = 0;
  @State loadingOpacity: number = 0;

  private backgrounds: Resource[] = [
    $r('app.media.Welcomebackground1'),
    $r('app.media.Welcomebackground2'),
    $r('app.media.Welcomebackground3'),
    $r('app.media.Welcomebackground4')
  ];

  aboutToAppear(): void {
    this.bgIndex = Math.floor(Math.random() * 4);
    this.startLoadingAnimation();
    this.startEntranceAnimation();

    // 初始化数据服务
    this.initServices();

    // 2.5秒后隐藏欢迎页
    setTimeout(() => {
      this.showWelcome = false;
    }, 2500);
  }

  private async initServices(): Promise<void> {
    // 预加载用户数据和记录数据
    await userService.load();
    await fishingRecordService.load();
  }

  private startEntranceAnimation(): void {
    // Logo 淡入 + 缩放动画
    setTimeout(() => {
      animateTo({ duration: 500, curve: Curve.EaseOut }, () => {
        this.logoOpacity = 1;
        this.logoScale = 1;
      });
    }, 200);

    // 文字淡入
    setTimeout(() => {
      animateTo({ duration: 400, curve: Curve.EaseOut }, () => {
        this.textOpacity = 1;
      });
    }, 500);

    // 加载指示器淡入
    setTimeout(() => {
      animateTo({ duration: 300, curve: Curve.EaseOut }, () => {
        this.loadingOpacity = 1;
      });
    }, 800);
  }

  private startLoadingAnimation(): void {
    const animate = (): void => {
      if (this.showWelcome) {
        this.loadingAngle = (this.loadingAngle + 10) % 360;
        setTimeout(() => animate(), 50);
      }
    };
    animate();
  }

  @Builder
  TabBarBuilder(title: string, icon: Resource, iconActive: Resource, index: number) {
    Column({ space: 4 }) {
      Image(this.currentIndex === index ? iconActive : icon)
        .width(24)
        .height(24)
        .fillColor(this.currentIndex === index ? ThemeColors.PRIMARY : ThemeColors.TEXT_MUTED)

      Text(title)
        .fontSize(ThemeConstants.FONT_SIZE_XS)
        .fontColor(this.currentIndex === index ? ThemeColors.PRIMARY : ThemeColors.TEXT_MUTED)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  CenterTabBuilder() {
    Column() {
      Row() {
        Text('+')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.TEXT_PRIMARY)
      }
      .width(44)
      .height(44)
      .backgroundColor(ThemeColors.PRIMARY)
      .borderRadius(22)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  WelcomeContent() {
    Stack() {
      Image(this.backgrounds[this.bgIndex])
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)

      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [['rgba(0,0,0,0.3)', 0], ['rgba(0,0,0,0.6)', 0.5], ['rgba(0,0,0,0.8)', 1]]
        })

      Column() {
        Blank()
        Column({ space: 16 }) {
          Row() {
            Image($r('app.media.hooks'))
              .width(48)
              .height(48)
          }
          .width(80)
          .height(80)
          .backgroundColor(ThemeColors.BG_SECONDARY)
          .borderRadius(16)
          .justifyContent(FlexAlign.Center)
          .opacity(this.logoOpacity)
          .scale({ x: this.logoScale, y: this.logoScale })

          Text(AppConstants.APP_NAME)
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.TEXT_PRIMARY)
            .opacity(this.textOpacity)

          Text(AppConstants.APP_SLOGAN)
            .fontSize(14)
            .fontColor(ThemeColors.TEXT_SECONDARY)
            .opacity(this.textOpacity)
        }
        Blank()
        Column({ space: 8 }) {
          LoadingProgress()
            .width(32)
            .height(32)
            .color(ThemeColors.PRIMARY)

          Text(AppConstants.APP_VERSION)
            .fontSize(12)
            .fontColor(ThemeColors.TEXT_MUTED)
        }
        .margin({ bottom: 60 })
        .opacity(this.loadingOpacity)
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  MainContent() {
    Column() {
      Tabs({ barPosition: BarPosition.End, index: this.currentIndex }) {
        TabContent() {
          HomePage()
        }
        .tabBar(this.TabBarBuilder('首页', $r('app.media.home'), $r('app.media.homes'), 0))

        TabContent() {
          RecipeBrowserPage()
        }
        .tabBar(this.TabBarBuilder('配方', $r('app.media.Recipe'), $r('app.media.Recipes'), 1))

        TabContent() {
          GeneratorPage()
        }
        .tabBar(this.CenterTabBuilder())

        TabContent() {
          FishingRecordPage()
        }
        .tabBar(this.TabBarBuilder('记录', $r('app.media.time'), $r('app.media.times'), 3))

        TabContent() {
          MinePage()
        }
        .tabBar(this.TabBarBuilder('我的', $r('app.media.mine'), $r('app.media.mines'), 4))
      }
      .barHeight(56)
      .barBackgroundColor(ThemeColors.BG_SECONDARY)
      .onChange((index: number) => {
        this.currentIndex = index;
      })
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeColors.BG_PRIMARY)
    .padding({ bottom: 34 })
  }

  build() {
    Stack() {
      if (this.showWelcome) {
        this.WelcomeContent()
      } else {
        this.MainContent()
      }
    }
    .width('100%')
    .height('100%')
  }
}
