/**
 * 饵知�?- 统计卡片组件
 */
import { ThemeColors } from '../theme/ThemeColors';
import { ThemeConstants } from '../theme/ThemeConstants';

@Component
export struct StatCard {
  @Prop label: string = '';
  @Prop value: string = '0';
  @Prop unit: string = '';
  @Prop valueColor: string = ThemeColors.PRIMARY;

  build() {
    Column({ space: 4 }) {
      Row() {
        Text(this.value)
          .fontSize(ThemeConstants.FONT_SIZE_2XL)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.valueColor)

        if (this.unit) {
          Text(this.unit)
            .fontSize(ThemeConstants.FONT_SIZE_SM)
            .fontColor(ThemeColors.TEXT_SECONDARY)
            .margin({ left: 2, top: 8 })
        }
      }

      Text(this.label)
        .fontSize(ThemeConstants.FONT_SIZE_XS)
        .fontColor(ThemeColors.TEXT_SECONDARY)
    }
    .layoutWeight(1)
    .padding({ top: 16, bottom: 16 })
    .backgroundColor(ThemeColors.BG_CARD)
    .borderRadius(ThemeConstants.RADIUS_SM)
    .alignItems(HorizontalAlign.Center)
  }
}
