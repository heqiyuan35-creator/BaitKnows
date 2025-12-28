/**
 * 饵知�?- 主页面（合并欢迎页和主Tab�?
 * 添加动画效果
 */
import { ThemeColors } from '../theme/ThemeColors';
import { ThemeConstants } from '../theme/ThemeConstants';
import { AppConstants } from '../common/constants/AppConstants';
import { HomePage } from './HomePage';
import { RecipeBrowserPage } from './RecipeBrowserPage';
import { FishingRecordPage } from './FishingRecordPage';
import { MinePage } from './MinePage';
import { storageService } from '../services/StorageService';
import { userService } from '../services/UserService';
import { fishingRecordService } from '../services/FishingRecordService';
import { userDataService } from '../services/UserDataService';
import { AddMenuSheet, AddMenuItem, ADD_MENU_ITEMS } from '../components/AddMenuSheet';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct WelcomePage {
  @State currentIndex: number = 0;
  @State showWelcome: boolean = true;
  @State bgIndex: number = 0;
  @State loadingAngle: number = 0;
  // 动画状�?
  @State logoOpacity: number = 0;
  @State logoScale: number = 0.5;
  @State textOpacity: number = 0;
  @State loadingOpacity: number = 0;
  // 记录页刷新触发器
  @State recordRefreshTrigger: number = 0;
  // 我的页刷新触发器
  @State mineRefreshTrigger: number = 0;
  // 加号菜单状�?
  @State showAddMenu: boolean = false;

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

    // 初始化数据服�?
    this.initServices();

    // 2.5秒后隐藏欢迎�?
    setTimeout(() => {
      this.showWelcome = false;
    }, 2500);
  }

  // 页面显示时刷新当前Tab数据（从其他页面返回时）
  onPageShow(): void {
    if (!this.showWelcome) {
      // 刷新记录页和我的页数�?
      this.recordRefreshTrigger++;
      this.mineRefreshTrigger++;
    }
  }

  private async initServices(): Promise<void> {
    // 预加载用户数据和记录数据
    await userService.load();
    await fishingRecordService.load();
    await userDataService.load();
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

    // 加载指示器淡�?
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
    .padding({ bottom: 8 })
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
      .onClick(() => {
        this.showAddMenu = true;
      })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ bottom: 8 })
  }

  // 关闭加号菜单
  private closeAddMenu(): void {
    this.showAddMenu = false;
  }

  // 处理菜单项点�?
  private onMenuItemClick(item: AddMenuItem): void {
    this.showAddMenu = false;
    router.pushUrl({ url: item.route }).catch((err: Error) => {
      console.error(`跳转失败: ${err.message}`);
    });
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
    Stack() {
      Column() {
        Tabs({ barPosition: BarPosition.End, index: $$this.currentIndex }) {
          TabContent() {
            HomePage()
          }
          .tabBar(this.TabBarBuilder('首页', $r('app.media.home'), $r('app.media.homes'), 0))

          TabContent() {
            RecipeBrowserPage()
          }
          .tabBar(this.TabBarBuilder('配方', $r('app.media.Recipe'), $r('app.media.Recipes'), 1))

          TabContent() {
            // 中间Tab占位，点击加号按钮弹出菜�?
            Column() {
              Text('点击下方 + 按钮')
                .fontSize(14)
                .fontColor(ThemeColors.TEXT_MUTED)
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Center)
            .backgroundColor(ThemeColors.BG_PRIMARY)
          }
          .tabBar(this.CenterTabBuilder())

          TabContent() {
            FishingRecordPage({ refreshTrigger: this.recordRefreshTrigger })
          }
          .tabBar(this.TabBarBuilder('记录', $r('app.media.time'), $r('app.media.times'), 3))

          TabContent() {
            MinePage({ refreshTrigger: this.mineRefreshTrigger })
          }
          .tabBar(this.TabBarBuilder('我的', $r('app.media.mine'), $r('app.media.mines'), 4))
        }
        .barHeight(56)
        .barBackgroundColor(ThemeColors.BG_SECONDARY)
        .onChange((index: number) => {
          // 中间Tab（index=2）不切换，只弹出菜单
          if (index === 2) {
            this.showAddMenu = true;
            return;
          }
          this.currentIndex = index;
          // 切换到记录Tab时触发刷�?
          if (index === 3) {
            this.recordRefreshTrigger++;
          }
          // 切换到我的Tab时触发刷�?
          if (index === 4) {
            this.mineRefreshTrigger++;
          }
        })
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(ThemeColors.BG_PRIMARY)
      .padding({ bottom: 34 })

      // 加号菜单弹出�?
      if (this.showAddMenu) {
        AddMenuSheet({
          visible: this.showAddMenu,
          onClose: (): void => this.closeAddMenu(),
          onItemClick: (item: AddMenuItem): void => this.onMenuItemClick(item)
        })
      }
    }
    .width('100%')
    .height('100%')
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
