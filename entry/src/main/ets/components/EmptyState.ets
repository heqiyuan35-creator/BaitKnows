/**
 * 饵知�?- 空状态组�?
 * 用于列表无数据时的展�?
 */
import { ThemeColors } from '../theme/ThemeColors';
import { ThemeConstants } from '../theme/ThemeConstants';

@Component
export struct EmptyState {
  @Prop icon: string = '📭';
  @Prop title: string = '暂无数据';
  @Prop subtitle: string = '';
  @Prop actionText: string = '';
  onAction?: () => void;

  build() {
    Column({ space: 12 }) {
      Text(this.icon)
        .fontSize(56)

      Text(this.title)
        .fontSize(ThemeConstants.FONT_SIZE_MD)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .fontWeight(FontWeight.Medium)

      if (this.subtitle) {
        Text(this.subtitle)
          .fontSize(ThemeConstants.FONT_SIZE_SM)
          .fontColor(ThemeColors.TEXT_MUTED)
          .textAlign(TextAlign.Center)
          .padding({ left: 40, right: 40 })
      }

      if (this.actionText && this.onAction) {
        Button(this.actionText)
          .fontSize(ThemeConstants.FONT_SIZE_SM)
          .fontColor(ThemeColors.TEXT_PRIMARY)
          .backgroundColor(ThemeColors.PRIMARY)
          .borderRadius(ThemeConstants.RADIUS_SM)
          .height(36)
          .padding({ left: 24, right: 24 })
          .margin({ top: 8 })
          .onClick(() => {
            if (this.onAction) {
              this.onAction();
            }
          })
      }
    }
    .width('100%')
    .padding({ top: 60, bottom: 60 })
    .justifyContent(FlexAlign.Center)
  }
}
