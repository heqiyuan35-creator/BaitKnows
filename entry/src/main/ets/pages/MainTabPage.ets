/**
 * 饵知�?- 主Tab页面
 * 底部5个Tab：首页、配方�?、日记、我�?
 */
import { ThemeColors } from '../theme/ThemeColors';
import { ThemeConstants } from '../theme/ThemeConstants';

@Entry
@Component
struct MainTabPage {
  @State currentIndex: number = 0;

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
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.TEXT_PRIMARY)
      }
      .width(48)
      .height(48)
      .backgroundColor(ThemeColors.PRIMARY)
      .borderRadius(24)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .offset({ y: -10 })
  }

  @Builder
  PlaceholderPage(title: string, desc: string) {
    Column({ space: 8 }) {
      Text(title)
        .fontSize(ThemeConstants.FONT_SIZE_2XL)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeColors.TEXT_PRIMARY)
      Text(desc)
        .fontSize(ThemeConstants.FONT_SIZE_BASE)
        .fontColor(ThemeColors.TEXT_SECONDARY)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor(ThemeColors.BG_PRIMARY)
  }

  build() {
    Tabs({ barPosition: BarPosition.End, index: this.currentIndex }) {
      // 首页
      TabContent() {
        this.PlaceholderPage('首页', '天气信息 · 智能配方生成')
      }
      .tabBar(this.TabBarBuilder('首页', $r('app.media.home'), $r('app.media.homes'), 0))

      // 配方
      TabContent() {
        this.PlaceholderPage('配方�?, '浏览鱼饵配方')
      }
      .tabBar(this.TabBarBuilder('配方', $r('app.media.Recipe'), $r('app.media.Recipes'), 1))

      // 中间+按钮
      TabContent() {
        this.PlaceholderPage('智能生成', '一键生成配�?)
      }
      .tabBar(this.CenterTabBuilder())

      // 日记
      TabContent() {
        this.PlaceholderPage('渔获日记', '记录每一次收�?)
      }
      .tabBar(this.TabBarBuilder('日记', $r('app.media.time'), $r('app.media.times'), 3))

      // 我的
      TabContent() {
        this.PlaceholderPage('我的', '个人中心')
      }
      .tabBar(this.TabBarBuilder('我的', $r('app.media.mine'), $r('app.media.mines'), 4))
    }
    .barHeight(ThemeConstants.TAB_BAR_HEIGHT)
    .barBackgroundColor(ThemeColors.BG_SECONDARY)
    .onChange((index: number) => {
      this.currentIndex = index;
    })
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeColors.BG_PRIMARY)
  }
}
