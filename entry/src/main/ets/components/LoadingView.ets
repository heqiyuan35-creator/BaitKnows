/**
 * 饵知�?- 加载状态组�?
 */
import { ThemeColors } from '../theme/ThemeColors';
import { ThemeConstants } from '../theme/ThemeConstants';

@Component
export struct LoadingView {
  @Prop message: string = '加载�?..';

  build() {
    Column({ space: 12 }) {
      LoadingProgress()
        .width(40)
        .height(40)
        .color(ThemeColors.PRIMARY)

      Text(this.message)
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
    }
    .width('100%')
    .padding({ top: 60, bottom: 60 })
    .justifyContent(FlexAlign.Center)
  }
}
