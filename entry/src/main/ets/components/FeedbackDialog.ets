/**
 * 换一换反馈对话框组件
 * 用于收集用户对配方不满意的原�?
 */
import { ThemeColors } from '../theme/ThemeColors';
import { FEEDBACK_OPTIONS, FeedbackOption, FeedbackType } from '../common/types/PreciseMatchTypes';

@Component
export struct FeedbackDialog {
  @Prop visible: boolean = false;
  @State selectedFeedbacks: FeedbackType[] = [];
  onClose?: () => void;
  onConfirm?: (feedbacks: FeedbackType[]) => void;

  // 切换反馈选项
  private toggleFeedback(type: FeedbackType): void {
    const index = this.selectedFeedbacks.indexOf(type);
    if (index >= 0) {
      this.selectedFeedbacks.splice(index, 1);
    } else {
      this.selectedFeedbacks.push(type);
    }
    this.selectedFeedbacks = [...this.selectedFeedbacks];
  }

  // 确认
  private handleConfirm(): void {
    if (this.onConfirm) {
      this.onConfirm(this.selectedFeedbacks);
    }
    this.selectedFeedbacks = [];
  }

  // 取消
  private handleClose(): void {
    if (this.onClose) {
      this.onClose();
    }
    this.selectedFeedbacks = [];
  }

  build() {
    if (this.visible) {
      Stack() {
        // 遮罩�?
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0,0,0,0.5)')
          .onClick(() => this.handleClose())

        // 对话框内�?
        Column({ space: 20 }) {
          // 标题
          Row() {
            Text('不满意的地方')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1A1A1A')
            Blank()
            Text('�?)
              .fontSize(20)
              .fontColor('#999')
              .onClick(() => this.handleClose())
          }
          .width('100%')

          // 选项列表
          Column({ space: 12 }) {
            ForEach(FEEDBACK_OPTIONS, (option: FeedbackOption) => {
              Row({ space: 12 }) {
                Text(option.icon).fontSize(20)
                Text(option.label)
                  .fontSize(15)
                  .fontColor('#1A1A1A')
                  .layoutWeight(1)

                if (this.selectedFeedbacks.includes(option.id)) {
                  Row() {
                    Text('�?).fontSize(14).fontColor(Color.White)
                  }
                  .width(22)
                  .height(22)
                  .borderRadius(11)
                  .backgroundColor(ThemeColors.PRIMARY)
                  .justifyContent(FlexAlign.Center)
                } else {
                  Row()
                    .width(22)
                    .height(22)
                    .borderRadius(11)
                    .border({ width: 2, color: '#E0E0E0' })
                }
              }
              .width('100%')
              .padding(14)
              .backgroundColor(this.selectedFeedbacks.includes(option.id) ? '#FFF5E6' : '#F8F8F8')
              .borderRadius(12)
              .border({
                width: this.selectedFeedbacks.includes(option.id) ? 1 : 0,
                color: ThemeColors.PRIMARY
              })
              .onClick(() => this.toggleFeedback(option.id))
            })
          }
          .width('100%')

          // 提示文字
          Text('选择后将根据您的反馈重新生成配方')
            .fontSize(12)
            .fontColor('#999')

          // 按钮
          Row({ space: 12 }) {
            Button('取消')
              .fontSize(15)
              .fontColor('#666')
              .backgroundColor('#F5F5F5')
              .layoutWeight(1)
              .height(48)
              .borderRadius(24)
              .onClick(() => this.handleClose())

            Button('重新生成')
              .fontSize(15)
              .fontColor(Color.White)
              .backgroundColor(this.selectedFeedbacks.length > 0 ? ThemeColors.PRIMARY : '#CCC')
              .layoutWeight(1)
              .height(48)
              .borderRadius(24)
              .enabled(this.selectedFeedbacks.length > 0)
              .onClick(() => this.handleConfirm())
          }
          .width('100%')
        }
        .width('90%')
        .padding(24)
        .backgroundColor(Color.White)
        .borderRadius(20)
        .shadow({ radius: 20, color: 'rgba(0,0,0,0.1)', offsetY: 4 })
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
    }
  }
}
