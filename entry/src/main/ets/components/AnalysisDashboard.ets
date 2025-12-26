/**
 * 分析仪表盘组件 - 纯ArkTS实现
 */
import { ThemeColors } from '../theme/ThemeColors';
import { DimensionScores, IngredientRatio, ParameterWeight } from '../common/types/PreciseMatchTypes';

type ChartType = 'radar' | 'pie' | 'bar';
const DIMENSION_COLORS: string[] = ['#E6A23C', '#67C23A', '#409EFF', '#F56C6C', '#909399'];

@Component
export struct AnalysisDashboard {
  @Prop dimensionScores: DimensionScores = new DimensionScores();
  @Prop ingredientRatios: IngredientRatio[] = [];
  @Prop parameterWeights: ParameterWeight[] = [];
  @State currentChart: ChartType = 'radar';

  build() {
    Column({ space: 12 }) {
      Row({ space: 0 }) {
        this.ChartTab('维度评分', 'radar')
        this.ChartTab('原料配比', 'pie')
        this.ChartTab('参数权重', 'bar')
      }
      .width('100%')
      .backgroundColor('#F5F5F5')
      .borderRadius(8)
      .padding(4)

      if (this.currentChart === 'radar') {
        this.RadarChartView()
      } else if (this.currentChart === 'pie') {
        this.PieChartView()
      } else {
        this.BarChartView()
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(16)
  }

  @Builder
  ChartTab(title: string, type: ChartType) {
    Text(title)
      .fontSize(14)
      .fontColor(this.currentChart === type ? Color.White : '#666')
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor(this.currentChart === type ? ThemeColors.PRIMARY : Color.Transparent)
      .borderRadius(6)
      .layoutWeight(1)
      .textAlign(TextAlign.Center)
      .onClick(() => { this.currentChart = type; })
  }

  @Builder
  RadarChartView() {
    Column({ space: 12 }) {
      Text('五维能力分析').fontSize(14).fontColor('#999')
      Row({ space: 16 }) {
        Stack() {
          Progress({ value: this.getAverageScore(), total: 100, type: ProgressType.Ring })
            .width(90).height(90).color(ThemeColors.PRIMARY).backgroundColor('#F0F0F0').style({ strokeWidth: 10 })
          Column() {
            Text(`${this.getAverageScore()}`).fontSize(24).fontWeight(FontWeight.Bold).fontColor(ThemeColors.PRIMARY)
            Text('综合').fontSize(11).fontColor('#999')
          }
        }.width(90).height(90)

        Column({ space: 8 }) {
          this.DimensionBar('诱鱼性', this.dimensionScores.attraction, DIMENSION_COLORS[0])
          this.DimensionBar('适口性', this.dimensionScores.palatability, DIMENSION_COLORS[1])
          this.DimensionBar('状态', this.dimensionScores.state, DIMENSION_COLORS[2])
          this.DimensionBar('留鱼性', this.dimensionScores.retention, DIMENSION_COLORS[3])
          this.DimensionBar('性价比', this.dimensionScores.costEffective, DIMENSION_COLORS[4])
        }.layoutWeight(1)
      }.width('100%')
    }.width('100%').padding({ top: 8 })
  }

  @Builder
  DimensionBar(name: string, score: number, color: string) {
    Row() {
      Row().width(8).height(8).borderRadius(4).backgroundColor(color)
      Text(name).fontSize(12).fontColor('#666').margin({ left: 6 }).width(42)
      Stack({ alignContent: Alignment.Start }) {
        Row().width('100%').height(10).backgroundColor('#F5F5F5').borderRadius(5)
        Row().width(`${score}%`).height(10).backgroundColor(color).borderRadius(5)
      }.layoutWeight(1).margin({ left: 6, right: 6 })
      Text(`${score}`).fontSize(12).fontWeight(FontWeight.Medium).fontColor(color).width(24).textAlign(TextAlign.End)
    }.width('100%')
  }

  @Builder
  PieChartView() {
    Column({ space: 12 }) {
      Text('原料配比分析').fontSize(14).fontColor('#999')
      Row({ space: 16 }) {
        Stack() {
          Progress({ value: 100, total: 100, type: ProgressType.Ring })
            .width(100).height(100).color('#F5F5F5').backgroundColor('#F5F5F5').style({ strokeWidth: 18 })
          Progress({
            value: this.ingredientRatios.length > 0 ? this.ingredientRatios[0].percentage : 40,
            total: 100, type: ProgressType.Ring
          }).width(100).height(100)
            .color(this.ingredientRatios.length > 0 ? this.ingredientRatios[0].color : '#E6A23C')
            .backgroundColor(Color.Transparent).style({ strokeWidth: 18 })
          Column() {
            Text('500g').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#1A1A1A')
            Text('总量').fontSize(10).fontColor('#999')
          }
        }.width(100).height(100)

        Column({ space: 8 }) {
          ForEach(this.ingredientRatios, (ratio: IngredientRatio) => {
            Row() {
              Row().width(10).height(10).borderRadius(2).backgroundColor(ratio.color)
              Column({ space: 2 }) {
                Text(ratio.name).fontSize(12).fontColor('#1A1A1A').maxLines(1)
                Text(ratio.category).fontSize(10).fontColor('#999')
              }.alignItems(HorizontalAlign.Start).margin({ left: 6 }).layoutWeight(1)
              Text(`${ratio.percentage}%`).fontSize(13).fontWeight(FontWeight.Medium).fontColor(ratio.color)
            }.width('100%')
          })
        }.layoutWeight(1)
      }.width('100%')
    }.width('100%').padding({ top: 8 })
  }

  @Builder
  BarChartView() {
    Column({ space: 12 }) {
      Text('参数影响分析').fontSize(14).fontColor('#999')
      Column({ space: 10 }) {
        ForEach(this.parameterWeights, (weight: ParameterWeight) => {
          Column({ space: 4 }) {
            Row() {
              Text(weight.name).fontSize(12).fontColor('#1A1A1A')
              Blank()
              Text(`${weight.weight}%`).fontSize(12).fontWeight(FontWeight.Medium).fontColor(ThemeColors.PRIMARY)
            }.width('100%')
            Stack({ alignContent: Alignment.Start }) {
              Row().width('100%').height(14).backgroundColor('#F5F5F5').borderRadius(7)
              Row().width(`${Math.min(weight.weight * 4, 100)}%`).height(14)
                .linearGradient({ direction: GradientDirection.Right, colors: [[ThemeColors.PRIMARY, 0], ['#F5C77E', 1]] })
                .borderRadius(7)
            }.width('100%')
          }.width('100%')
        })
      }.width('100%')
    }.width('100%').padding({ top: 8 })
  }

  private getAverageScore(): number {
    return Math.round((this.dimensionScores.attraction + this.dimensionScores.palatability +
      this.dimensionScores.state + this.dimensionScores.retention + this.dimensionScores.costEffective) / 5);
  }
}
