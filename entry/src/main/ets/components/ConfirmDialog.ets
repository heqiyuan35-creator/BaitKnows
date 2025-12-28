/**
 * 饵知�?- 确认弹窗组件
 */
import { ThemeColors } from '../theme/ThemeColors';
import { ThemeConstants } from '../theme/ThemeConstants';

@Component
export struct ConfirmDialog {
  @Prop title: string = '确认';
  @Prop message: string = '';
  @Prop confirmText: string = '确定';
  @Prop cancelText: string = '取消';
  @Prop confirmColor: string = ThemeColors.PRIMARY;
  @Prop isDanger: boolean = false;
  onConfirm?: () => void;
  onCancel?: () => void;

  build() {
    Stack() {
      // 遮罩
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.5)')
        .onClick(() => {
          if (this.onCancel) {
            this.onCancel();
          }
        })

      // 弹窗内容
      Column({ space: 16 }) {
        Text(this.title)
          .fontSize(ThemeConstants.FONT_SIZE_LG)
          .fontWeight(FontWeight.Medium)
          .fontColor(ThemeColors.TEXT_PRIMARY)

        Text(this.message)
          .fontSize(ThemeConstants.FONT_SIZE_BASE)
          .fontColor(ThemeColors.TEXT_SECONDARY)
          .textAlign(TextAlign.Center)

        Row({ space: 12 }) {
          Button(this.cancelText)
            .fontSize(ThemeConstants.FONT_SIZE_BASE)
            .fontColor(ThemeColors.TEXT_PRIMARY)
            .backgroundColor(ThemeColors.BG_TERTIARY)
            .layoutWeight(1)
            .height(44)
            .onClick(() => {
              if (this.onCancel) {
                this.onCancel();
              }
            })

          Button(this.confirmText)
            .fontSize(ThemeConstants.FONT_SIZE_BASE)
            .fontColor(Color.White)
            .backgroundColor(this.isDanger ? '#FF4444' : this.confirmColor)
            .layoutWeight(1)
            .height(44)
            .onClick(() => {
              if (this.onConfirm) {
                this.onConfirm();
              }
            })
        }
        .width('100%')
      }
      .width('80%')
      .padding(24)
      .backgroundColor(ThemeColors.BG_CARD)
      .borderRadius(ThemeConstants.RADIUS_LG)
    }
    .width('100%')
    .height('100%')
  }
}
