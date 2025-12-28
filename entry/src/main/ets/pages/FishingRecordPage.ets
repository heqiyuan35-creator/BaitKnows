/**
 * 饵知�?- 渔获记录列表�?
 * 展示统计数据和渔获记录列�?
 */
import { ThemeColors } from '../theme/ThemeColors';
import { ThemeConstants } from '../theme/ThemeConstants';
import { Router } from '../router/Router';
import { FishingRecord } from '../common/types/UserTypes';
import { fishingRecordService, RecordStatistics } from '../services/FishingRecordService';
import { StatCard } from '../components/StatCard';
import { EmptyState } from '../components/EmptyState';

// 按月份分组的记录
interface MonthGroup {
  month: string;
  records: FishingRecord[];
}

@Entry
@Component
export struct FishingRecordPage {
  // 刷新触发器，当值变化时重新加载数据（作为子组件时使用）
  @Prop @Watch('onRefreshTriggerChange') refreshTrigger: number = 0;
  @State records: FishingRecord[] = [];
  @State statistics: RecordStatistics = new RecordStatistics();
  @State isLoading: boolean = true;
  @State groupedRecords: MonthGroup[] = [];

  aboutToAppear(): void {
    // 每次组件出现时强制重新加载数�?
    this.loadData(true);
  }

  // 监听刷新触发器变�?
  onRefreshTriggerChange(): void {
    this.loadData(true);
  }

  onPageShow(): void {
    // 页面显示时也刷新（作为独立页面时�?
    this.loadData(true);
  }

  private async loadData(forceReload: boolean = false): Promise<void> {
    this.isLoading = true;
    try {
      if (forceReload) {
        await fishingRecordService.reload();
      } else {
        await fishingRecordService.load();
      }
      this.records = fishingRecordService.records;
      this.statistics = fishingRecordService.getStatistics();
      this.groupRecordsByMonth();
    } catch (error) {
      console.error('加载记录失败:', error);
    }
    this.isLoading = false;
  }

  // 按月份分组记�?
  private groupRecordsByMonth(): void {
    const groups: Map<string, FishingRecord[]> = new Map();

    for (const record of this.records) {
      const date = new Date(record.date);
      const monthKey = `${date.getFullYear()}�?{date.getMonth() + 1}月`;

      if (!groups.has(monthKey)) {
        groups.set(monthKey, []);
      }
      groups.get(monthKey)?.push(record);
    }

    this.groupedRecords = [];
    groups.forEach((records, month) => {
      const group: MonthGroup = { month: month, records: records };
      this.groupedRecords.push(group);
    });
  }

  private formatDate(timestamp: number): string {
    const date = new Date(timestamp);
    const month = date.getMonth() + 1;
    const day = date.getDate();
    const weekDays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    const weekDay = weekDays[date.getDay()];
    return `${month}�?{day}�?${weekDay}`;
  }

  private getWeatherIcon(weather: string): string {
    const icons: Record<string, string> = {
      '晴朗': '☀�?,
      '多云': '�?,
      '阴天': '☁️',
      '小雨': '🌧�?,
      '大风': '💨'
    };
    return icons[weather] || '🌤�?;
  }

  // 截断鱼种名称，最多显�?种鱼
  private formatFishName(name: string): string {
    if (!name) return '未知鱼种';
    const fishList = name.split('�?);
    if (fishList.length <= 2) return name;
    return fishList.slice(0, 2).join('�?) + '�?;
  }

  build() {
    Column() {
      if (this.isLoading) {
        this.LoadingView()
      } else {
        // 内容区域
        Scroll() {
          Column({ space: ThemeConstants.SPACE_MD }) {
            // 状态栏占位
            Row()
              .width('100%')
              .height(36)

            // 顶部标题�?
            this.HeaderBar()

            // 统计卡片区域
            this.StatisticsSection()

            // 渔获分析入口卡片
            Column() {
              this.AnalysisEntryCard()
            }
            .padding({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD })

            // 记录列表
            if (this.records.length === 0) {
              this.EmptyView()
            } else {
              this.RecordListSection()
            }
          }
          .padding({ top: 8, bottom: 100 })
          .alignItems(HorizontalAlign.Start)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
      }

      // 底部添加按钮
      this.AddButton()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeColors.BG_PRIMARY)
  }

  @Builder
  HeaderBar() {
    Row() {
      Text('渔获记录')
        .fontSize(ThemeConstants.FONT_SIZE_XL)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeColors.TEXT_PRIMARY)
    }
    .width('100%')
    .height(48)
    .padding({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD })
  }

  @Builder
  LoadingView() {
    Column() {
      LoadingProgress()
        .width(48)
        .height(48)
        .color(ThemeColors.PRIMARY)
      Text('加载�?..')
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .margin({ top: 12 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  AnalysisEntryCard() {
    Row() {
      // 左侧图标和文�?
      Row({ space: 12 }) {
        Column() {
          Text('📊')
            .fontSize(28)
        }
        .width(52)
        .height(52)
        .linearGradient({
          direction: GradientDirection.RightBottom,
          colors: [['#FFE4B5', 0], ['#FFD700', 1]]
        })
        .borderRadius(14)
        .justifyContent(FlexAlign.Center)

        Column({ space: 4 }) {
          Text('渔获分析')
            .fontSize(ThemeConstants.FONT_SIZE_MD)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.TEXT_PRIMARY)
          Text('查看成就、画像、趣味数�?)
            .fontSize(ThemeConstants.FONT_SIZE_XS)
            .fontColor(ThemeColors.TEXT_SECONDARY)
        }
        .alignItems(HorizontalAlign.Start)
      }

      Blank()

      // 右侧箭头
      Row() {
        Text('�?)
          .fontSize(18)
          .fontColor(ThemeColors.PRIMARY_DARK)
      }
      .width(36)
      .height(36)
      .backgroundColor('rgba(232, 168, 73, 0.15)')
      .borderRadius(18)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .padding(ThemeConstants.SPACE_MD)
    .backgroundColor(ThemeColors.BG_CARD)
    .borderRadius(ThemeConstants.RADIUS_MD)
    .shadow({ radius: 8, color: 'rgba(232, 168, 73, 0.15)', offsetY: 4 })
    .onClick(() => {
      Router.push('pages/RecordAnalysisPage');
    })
  }

  @Builder
  StatisticsSection() {
    Column({ space: ThemeConstants.SPACE_SM }) {
      // 第一行：总渔获、最大单�?
      Row({ space: ThemeConstants.SPACE_SM }) {
        StatCard({
          label: '总渔�?,
          value: this.statistics.totalWeight.toFixed(1),
          unit: 'kg',
          valueColor: ThemeColors.PRIMARY
        })

        StatCard({
          label: '最大单�?,
          value: this.statistics.maxSingle.toFixed(1),
          unit: 'kg',
          valueColor: ThemeColors.SUCCESS
        })
      }
      .width('100%')

      // 第二行：本月出钓、总出钓、总尾�?
      Row({ space: ThemeConstants.SPACE_SM }) {
        StatCard({
          label: '本月出钓',
          value: this.statistics.monthTrips.toString(),
          unit: '�?,
          valueColor: ThemeColors.INFO
        })

        StatCard({
          label: '总出�?,
          value: this.statistics.totalTrips.toString(),
          unit: '�?,
          valueColor: ThemeColors.WARNING
        })

        StatCard({
          label: '总尾�?,
          value: this.statistics.totalCount.toString(),
          unit: '�?,
          valueColor: ThemeColors.PRIMARY
        })
      }
      .width('100%')
    }
    .padding({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD })
  }

  @Builder
  EmptyView() {
    EmptyState({
      icon: '🎣',
      title: '暂无渔获记录',
      subtitle: '记录每一次钓鱼的收获，见证你的成�?
    })
  }

  @Builder
  RecordListSection() {
    Column({ space: ThemeConstants.SPACE_MD }) {
      ForEach(this.groupedRecords, (group: MonthGroup) => {
        Column({ space: ThemeConstants.SPACE_SM }) {
          // 月份标题
          Text(group.month)
            .fontSize(ThemeConstants.FONT_SIZE_SM)
            .fontColor(ThemeColors.TEXT_SECONDARY)
            .fontWeight(FontWeight.Medium)
            .width('100%')
            .padding({ left: ThemeConstants.SPACE_MD })

          // 该月的记�?
          ForEach(group.records, (record: FishingRecord) => {
            this.RecordItem(record)
          }, (record: FishingRecord) => record.id)
        }
      }, (group: MonthGroup) => group.month)
    }
    .padding({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD })
  }

  @Builder
  RecordItem(record: FishingRecord) {
    Column({ space: 10 }) {
      // 第一行：日期和天�?
      Row() {
        Row({ space: 6 }) {
          Text('📅')
            .fontSize(14)
          Text(this.formatDate(record.date))
            .fontSize(ThemeConstants.FONT_SIZE_SM)
            .fontColor(ThemeColors.TEXT_SECONDARY)
        }

        Blank()

        Row({ space: 4 }) {
          Text(this.getWeatherIcon(record.weather))
            .fontSize(14)
          Text(record.weather)
            .fontSize(ThemeConstants.FONT_SIZE_SM)
            .fontColor(ThemeColors.TEXT_SECONDARY)
        }
        .padding({ left: 8, right: 8, top: 2, bottom: 2 })
        .backgroundColor(ThemeColors.BG_TERTIARY)
        .borderRadius(ThemeConstants.RADIUS_FULL)
      }
      .width('100%')

      // 第二行：钓点
      Row({ space: 6 }) {
        Text('📍')
          .fontSize(14)
        Text(record.location || '未填写钓�?)
          .fontSize(ThemeConstants.FONT_SIZE_BASE)
          .fontColor(ThemeColors.TEXT_PRIMARY)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')

      // 第三行：鱼种、数量、重�?
      Row() {
        Row({ space: 6 }) {
          Text('🐟')
            .fontSize(16)
            .flexShrink(0)
          Text(this.formatFishName(record.fishName))
            .fontSize(ThemeConstants.FONT_SIZE_MD)
            .fontWeight(FontWeight.Medium)
            .fontColor(ThemeColors.TEXT_PRIMARY)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .constraintSize({ maxWidth: '45%' })
          Text(`× ${record.count}尾`)
            .fontSize(ThemeConstants.FONT_SIZE_SM)
            .fontColor(ThemeColors.TEXT_SECONDARY)
            .flexShrink(0)
        }
        .flexShrink(1)

        Blank()

        Row() {
          Text(`${record.weight}`)
            .fontSize(ThemeConstants.FONT_SIZE_XL)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.PRIMARY_DARK)
          Text('kg')
            .fontSize(ThemeConstants.FONT_SIZE_SM)
            .fontColor(ThemeColors.TEXT_SECONDARY)
            .margin({ left: 2, top: 4 })
        }
        .flexShrink(0)
      }
      .width('100%')

      // 第四行：配方（如有）
      if (record.recipeName) {
        Row({ space: 6 }) {
          Text('🧪')
            .fontSize(14)
          Text(record.recipeName)
            .fontSize(ThemeConstants.FONT_SIZE_SM)
            .fontColor(ThemeColors.TEXT_SECONDARY)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width('100%')
      }
    }
    .width('100%')
    .padding(ThemeConstants.SPACE_MD)
    .backgroundColor(ThemeColors.BG_CARD)
    .borderRadius(ThemeConstants.RADIUS_MD)
    .shadow({ radius: 4, color: 'rgba(0,0,0,0.05)', offsetY: 2 })
    .onClick(() => {
      Router.goToRecordDetail(record.id);
    })
  }

  @Builder
  AddButton() {
    Row() {
      Button('+ 添加记录')
        .fontSize(ThemeConstants.FONT_SIZE_MD)
        .fontColor(Color.White)
        .backgroundColor(ThemeColors.PRIMARY)
        .borderRadius(ThemeConstants.RADIUS_FULL)
        .height(48)
        .width('90%')
        .shadow({ radius: 8, color: 'rgba(232, 168, 73, 0.3)', offsetY: 4 })
        .onClick(() => {
          Router.goToAddRecord();
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ bottom: 20 })
    .position({ x: 0, y: '100%' })
    .translate({ y: -80 })
  }
}
