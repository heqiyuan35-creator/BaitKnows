/**
 * 饵知�?- 渔获记录卡片组件
 * 用于在列表中展示单条渔获记录
 */
import { ThemeColors } from '../theme/ThemeColors';
import { ThemeConstants } from '../theme/ThemeConstants';
import { FishingRecord } from '../common/types/UserTypes';

@Component
export struct RecordCard {
  @Prop record: FishingRecord = new FishingRecord();
  onClick?: () => void;
  onDelete?: () => void;

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
    Column({ space: 8 }) {
      // 第一行：日期和天�?
      Row() {
        Row({ space: 6 }) {
          Text('📅')
            .fontSize(14)
          Text(this.formatDate(this.record.date))
            .fontSize(ThemeConstants.FONT_SIZE_SM)
            .fontColor(ThemeColors.TEXT_SECONDARY)
        }

        Blank()

        Row({ space: 4 }) {
          Text(this.getWeatherIcon(this.record.weather))
            .fontSize(14)
          Text(this.record.weather)
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
        Text(this.record.location || '未填写钓�?)
          .fontSize(ThemeConstants.FONT_SIZE_BASE)
          .fontColor(ThemeColors.TEXT_PRIMARY)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
      }
      .width('100%')

      // 第三行：鱼种 + 数量 + 重量（一行显示）
      Row() {
        // 左侧：鱼种和数量
        Row({ space: 6 }) {
          Text('🐟')
            .fontSize(16)
            .flexShrink(0)
          Text(this.formatFishName(this.record.fishName))
            .fontSize(ThemeConstants.FONT_SIZE_MD)
            .fontWeight(FontWeight.Medium)
            .fontColor(ThemeColors.TEXT_PRIMARY)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .constraintSize({ maxWidth: '45%' })
          Text(`×${this.record.count}尾`)
            .fontSize(ThemeConstants.FONT_SIZE_SM)
            .fontColor(ThemeColors.TEXT_SECONDARY)
            .flexShrink(0)
        }
        .flexShrink(1)

        Blank()

        // 右侧：重�?
        Row() {
          Text(`${this.record.weight}`)
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
      if (this.record.recipeName) {
        Row({ space: 6 }) {
          Text('🧪')
            .fontSize(14)
          Text(this.record.recipeName)
            .fontSize(ThemeConstants.FONT_SIZE_SM)
            .fontColor(ThemeColors.TEXT_SECONDARY)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
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
      if (this.onClick) {
        this.onClick();
      }
    })
  }
}
