/**
 * 饵知道 - 渔获记录页面
 * 统计数据、记录列表
 */
import { ThemeColors } from '../theme/ThemeColors';
import { ThemeConstants } from '../theme/ThemeConstants';
import { Router } from '../router/Router';
import { FishingRecord } from '../common/types/UserTypes';
import { fishingRecordService, RecordStatistics } from '../services/FishingRecordService';
import { AppConstants } from '../common/constants/AppConstants';

@Component
export struct FishingRecordPage {
  @State stats: RecordStatistics = new RecordStatistics();
  @State records: FishingRecord[] = [];
  @State isLoading: boolean = true;
  @State isRefreshing: boolean = false;

  aboutToAppear(): void {
    this.loadData();
  }

  private async loadData(): Promise<void> {
    this.isLoading = true;
    await fishingRecordService.load();
    this.records = fishingRecordService.getRecentRecords(20);
    this.stats = fishingRecordService.getStatistics();
    this.isLoading = false;
  }

  private async refreshData(): Promise<void> {
    this.isRefreshing = true;
    await fishingRecordService.load();
    this.records = fishingRecordService.getRecentRecords(20);
    this.stats = fishingRecordService.getStatistics();
    this.isRefreshing = false;
  }

  private formatDate(timestamp: number): string {
    const date = new Date(timestamp);
    const month = date.getMonth() + 1;
    const day = date.getDate();
    return `${month}月${day}日`;
  }

  private getWeatherIcon(weather: string): string {
    const icons: Record<string, string> = {
      '晴朗': '☀️',
      '多云': '⛅',
      '阴天': '☁️',
      '小雨': '🌧️',
      '大风': '💨'
    };
    return icons[weather] || '🌤️';
  }

  build() {
    Column() {
      // 顶部标题栏
      this.HeaderBar()

      if (this.isLoading) {
        Column() {
          LoadingProgress().width(40).height(40).color(ThemeColors.PRIMARY)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Refresh({ refreshing: $$this.isRefreshing }) {
          Scroll() {
            Column({ space: ThemeConstants.SPACE_MD }) {
              // 统计卡片
              this.StatsCards()

              // 最近记录标题
              Row() {
                Text('最近记录')
                  .fontSize(ThemeConstants.FONT_SIZE_MD)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(ThemeColors.TEXT_PRIMARY)
                Blank()
                if (this.records.length > 0) {
                  Text(`共 ${this.stats.totalTrips} 条`)
                    .fontSize(ThemeConstants.FONT_SIZE_SM)
                    .fontColor(ThemeColors.TEXT_SECONDARY)
                }
              }
              .width('100%')
              .padding({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD })

              // 记录列表
              if (this.records.length === 0) {
                this.EmptyView()
              } else {
                ForEach(this.records, (record: FishingRecord) => {
                  this.RecordCard(record)
                })
              }
            }
            .padding({ bottom: 100 })
          }
          .scrollBar(BarState.Off)
        }
        .onRefreshing(() => {
          this.refreshData();
        })
        .layoutWeight(1)
      }
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
    .height(56)
    .padding({ left: 16, right: 16 })
    .margin({ top: 44 })
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  StatsCards() {
    Row({ space: ThemeConstants.SPACE_SM }) {
      this.StatItem('总渔获', `${this.stats.totalWeight}`, 'kg', ThemeColors.PRIMARY)
      this.StatItem('最大单尾', `${this.stats.maxSingle}`, 'kg', ThemeColors.TEXT_PRIMARY)
      this.StatItem('本月出钓', `${this.stats.monthTrips}`, '次', ThemeColors.TEXT_PRIMARY)
    }
    .width('100%')
    .padding({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD })
  }

  @Builder
  StatItem(label: string, value: string, unit: string, valueColor: string) {
    Column({ space: 4 }) {
      Row() {
        Text(value)
          .fontSize(ThemeConstants.FONT_SIZE_2XL)
          .fontWeight(FontWeight.Bold)
          .fontColor(valueColor)
        Text(unit)
          .fontSize(ThemeConstants.FONT_SIZE_XS)
          .fontColor(ThemeColors.TEXT_MUTED)
          .margin({ left: 2, top: 8 })
      }
      Text(label)
        .fontSize(ThemeConstants.FONT_SIZE_XS)
        .fontColor(ThemeColors.TEXT_SECONDARY)
    }
    .layoutWeight(1)
    .padding({ top: 14, bottom: 14 })
    .backgroundColor(ThemeColors.BG_CARD)
    .borderRadius(ThemeConstants.RADIUS_SM)
    .shadow({ radius: 6, color: 'rgba(0,0,0,0.04)', offsetY: 2 })
  }

  @Builder
  EmptyView() {
    Column({ space: 12 }) {
      Text('🎣')
        .fontSize(48)
      Text('暂无渔获记录')
        .fontSize(ThemeConstants.FONT_SIZE_BASE)
        .fontColor(ThemeColors.TEXT_SECONDARY)
      Text('点击底部 + 按钮添加第一条记录')
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_MUTED)
    }
    .width('100%')
    .padding({ top: 60, bottom: 60 })
  }

  @Builder
  RecordCard(record: FishingRecord) {
    Row({ space: 12 }) {
      // 左侧日期
      Column({ space: 2 }) {
        Text(this.formatDate(record.date).split('月')[0])
          .fontSize(ThemeConstants.FONT_SIZE_2XL)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.PRIMARY)
        Text('月')
          .fontSize(ThemeConstants.FONT_SIZE_XS)
          .fontColor(ThemeColors.TEXT_MUTED)
      }
      .width(48)
      .alignItems(HorizontalAlign.Center)

      // 分割线
      Column()
        .width(1)
        .height(60)
        .backgroundColor(ThemeColors.DIVIDER)

      // 中间信息
      Column({ space: 6 }) {
        Row({ space: 6 }) {
          Text(record.fishName || '未知鱼种')
            .fontSize(ThemeConstants.FONT_SIZE_MD)
            .fontWeight(FontWeight.Medium)
            .fontColor(ThemeColors.TEXT_PRIMARY)

          Row({ space: 4 }) {
            Text(this.getWeatherIcon(record.weather))
              .fontSize(12)
            Text(record.weather)
              .fontSize(ThemeConstants.FONT_SIZE_XS)
              .fontColor(ThemeColors.TEXT_MUTED)
          }
        }

        Row({ space: 8 }) {
          Text(`📍 ${record.location || '未知地点'}`)
            .fontSize(ThemeConstants.FONT_SIZE_SM)
            .fontColor(ThemeColors.TEXT_SECONDARY)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
        }

        Row({ space: 12 }) {
          Text(`🐟 ${record.count}尾`)
            .fontSize(ThemeConstants.FONT_SIZE_XS)
            .fontColor(ThemeColors.TEXT_MUTED)

          if (record.recipeName) {
            Text(`🧪 ${record.recipeName}`)
              .fontSize(ThemeConstants.FONT_SIZE_XS)
              .fontColor(ThemeColors.TEXT_MUTED)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 右侧重量
      Column({ space: 2 }) {
        Text(`${record.weight}`)
          .fontSize(ThemeConstants.FONT_SIZE_XL)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.PRIMARY)
        Text('kg')
          .fontSize(ThemeConstants.FONT_SIZE_XS)
          .fontColor(ThemeColors.TEXT_MUTED)
      }
      .alignItems(HorizontalAlign.End)

      // 箭头
      Text('›')
        .fontSize(20)
        .fontColor(ThemeColors.TEXT_MUTED)
    }
    .width('100%')
    .padding(ThemeConstants.SPACE_MD)
    .margin({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD })
    .backgroundColor(ThemeColors.BG_CARD)
    .borderRadius(ThemeConstants.RADIUS_MD)
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.05)', offsetY: 2 })
    .onClick(() => {
      Router.goToRecordDetail(record.id);
    })
  }
}
