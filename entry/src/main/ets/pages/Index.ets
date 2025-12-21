/**
 * 启动页
 * BaitKnows - 饵知道
 */
import { router } from '@kit.ArkUI';
import { ThemeColors } from '../theme/ThemeColors';

@Entry
@Component
struct Index {
  aboutToAppear(): void {
    // 直接跳转到欢迎页
    this.navigateToWelcome();
  }

  private navigateToWelcome(): void {
    router.replaceUrl({
      url: 'pages/WelcomePage'
    }).catch((err: Error) => {
      console.error(`跳转欢迎页失败: ${err.message}`);
    });
  }

  build() {
    Column() {
      Blank()

      // Logo 区域
      Column() {
        Image($r('app.media.foreground'))
          .width(120)
          .height(120)

        Text('饵知道')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.PRIMARY)
          .margin({ top: 16 })

        Text('BaitKnows')
          .fontSize(14)
          .fontColor(ThemeColors.TEXT_HINT)
          .margin({ top: 8 })
      }

      Blank()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeColors.BG_PRIMARY)
    .justifyContent(FlexAlign.Center)
  }
}
