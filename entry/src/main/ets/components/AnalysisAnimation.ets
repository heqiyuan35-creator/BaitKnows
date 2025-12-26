/**
 * 分析过程动画组件
 * 展示精确匹配的5步分析过程
 */
import { ThemeColors } from '../theme/ThemeColors';

interface AnalysisStepData {
  step: number;
  title: string;
  description: string;
  icon: string;
}

const ANALYSIS_STEPS: AnalysisStepData[] = [
  { step: 1, title: '参数解析', description: '解析钓况参数', icon: '📊' },
  { step: 2, title: '习性匹配', description: '匹配鱼种习性', icon: '🐟' },
  { step: 3, title: '原料筛选', description: '智能筛选原料', icon: '🎣' },
  { step: 4, title: '配比优化', description: '计算最优配比', icon: '⚖️' },
  { step: 5, title: '方案生成', description: '生成最优方案', icon: '✨' }
];

@Component
export struct AnalysisAnimation {
  @Prop currentStep: number = 0;
  @Prop fishName: string = '目标鱼';

  build() {
    Column({ space: 24 }) {
      // 标题
      Column({ space: 8 }) {
        Text('正在精确分析')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')

        Text(`为您匹配最适合${this.fishName}的配方`)
          .fontSize(14)
          .fontColor('#666')
      }

      // 进度指示器
      Row({ space: 8 }) {
        ForEach([1, 2, 3, 4, 5], (step: number) => {
          Row()
            .width(this.currentStep >= step ? 24 : 8)
            .height(8)
            .borderRadius(4)
            .backgroundColor(this.currentStep >= step ? ThemeColors.PRIMARY : '#E0E0E0')
            .animation({
              duration: 300,
              curve: Curve.EaseOut
            })
        })
      }
      .margin({ top: 8, bottom: 16 })

      // 步骤列表
      Column({ space: 12 }) {
        ForEach(ANALYSIS_STEPS, (stepData: AnalysisStepData) => {
          this.StepItem(stepData)
        })
      }
      .width('100%')
      .padding(20)
      .backgroundColor(Color.White)
      .borderRadius(16)
      .shadow({ radius: 10, color: 'rgba(0,0,0,0.05)', offsetY: 2 })
    }
    .width('100%')
    .padding(20)
  }

  @Builder
  StepItem(stepData: AnalysisStepData) {
    Row({ space: 14 }) {
      // 步骤图标
      Stack() {
        if (this.currentStep > stepData.step) {
          // 已完成
          Row() {
            Text('✓').fontSize(14).fontColor(Color.White)
          }
          .width(36)
          .height(36)
          .borderRadius(18)
          .backgroundColor(ThemeColors.PRIMARY)
          .justifyContent(FlexAlign.Center)
        } else if (this.currentStep === stepData.step) {
          // 进行中
          Row() {
            LoadingProgress()
              .width(20)
              .height(20)
              .color(Color.White)
          }
          .width(36)
          .height(36)
          .borderRadius(18)
          .backgroundColor(ThemeColors.PRIMARY)
          .justifyContent(FlexAlign.Center)
        } else {
          // 未开始
          Row() {
            Text(stepData.icon).fontSize(16)
          }
          .width(36)
          .height(36)
          .borderRadius(18)
          .backgroundColor('#F5F5F5')
          .justifyContent(FlexAlign.Center)
        }
      }

      // 步骤信息
      Column({ space: 4 }) {
        Text(stepData.title)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.currentStep >= stepData.step ? '#1A1A1A' : '#999')

        Text(stepData.description)
          .fontSize(12)
          .fontColor('#999')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 状态标签
      if (this.currentStep > stepData.step) {
        Text('完成')
          .fontSize(12)
          .fontColor(ThemeColors.PRIMARY)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor('#FFF5E6')
          .borderRadius(10)
      } else if (this.currentStep === stepData.step) {
        Text('进行中')
          .fontSize(12)
          .fontColor(Color.White)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor(ThemeColors.PRIMARY)
          .borderRadius(10)
      }
    }
    .width('100%')
    .padding({ top: 10, bottom: 10 })
    .opacity(this.currentStep >= stepData.step ? 1 : 0.5)
  }
}
