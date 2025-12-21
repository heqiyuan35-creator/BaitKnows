/**
 * 饵知道 - 设置页面
 */
import { ThemeColors } from '../theme/ThemeColors';
import { ThemeConstants } from '../theme/ThemeConstants';
import { Router } from '../router/Router';
import { AppConstants } from '../common/constants/AppConstants';

// 设置项接口
interface SettingItem {
  title: string;
  subtitle: string;
  type: string;
  value: boolean | string;
}

@Entry
@Component
struct SettingsPage {
  @State notificationEnabled: boolean = true;
  @State autoSaveEnabled: boolean = true;
  @State cacheSize: string = '12.5 MB';

  build() {
    Column() {
      this.HeaderBar()

      Scroll() {
        Column({ space: ThemeConstants.SPACE_MD }) {
          // 通用设置
          this.SettingSection('通用设置', [
            { title: '消息通知', subtitle: '接收钓鱼天气提醒', type: 'switch', value: this.notificationEnabled },
            { title: '自动保存', subtitle: '自动保存配方修改', type: 'switch', value: this.autoSaveEnabled }
          ])

          // 数据管理
          this.DataSection()

          // 关于
          this.AboutSection()
        }
        .padding({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD, bottom: 40 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeColors.BG_PRIMARY)
  }

  @Builder
  HeaderBar() {
    Row() {
      Image($r('app.media.Left'))
        .width(24)
        .height(24)
        .fillColor(ThemeColors.TEXT_PRIMARY)
        .onClick(() => Router.back())

      Blank()

      Text('设置')
        .fontSize(ThemeConstants.FONT_SIZE_LG)
        .fontWeight(FontWeight.Medium)
        .fontColor(ThemeColors.TEXT_PRIMARY)

      Blank()

      Row().width(24)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16, top: 40 })
  }

  @Builder
  SettingSection(title: string, items: SettingItem[]) {
    Column({ space: 1 }) {
      Text(title)
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .width('100%')
        .margin({ bottom: 8 })

      Column({ space: 1 }) {
        ForEach(items, (item: SettingItem, index: number) => {
          this.SettingItemRow(item, index === 0, index === items.length - 1)
        })
      }
      .borderRadius(ThemeConstants.RADIUS_MD)
      .clip(true)
    }
  }

  @Builder
  SettingItemRow(item: SettingItem, isFirst: boolean, isLast: boolean) {
    Row() {
      Column({ space: 2 }) {
        Text(item.title)
          .fontSize(ThemeConstants.FONT_SIZE_MD)
          .fontColor(ThemeColors.TEXT_PRIMARY)
        Text(item.subtitle)
          .fontSize(ThemeConstants.FONT_SIZE_XS)
          .fontColor(ThemeColors.TEXT_SECONDARY)
      }
      .alignItems(HorizontalAlign.Start)

      Blank()

      if (item.type === 'switch') {
        Toggle({ type: ToggleType.Switch, isOn: item.value as boolean })
          .selectedColor(ThemeColors.PRIMARY)
          .onChange((isOn: boolean) => {
            if (item.title === '消息通知') {
              this.notificationEnabled = isOn;
            } else if (item.title === '自动保存') {
              this.autoSaveEnabled = isOn;
            }
          })
      } else {
        Text('>')
          .fontSize(ThemeConstants.FONT_SIZE_MD)
          .fontColor(ThemeColors.TEXT_MUTED)
      }
    }
    .width('100%')
    .height(64)
    .padding({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD })
    .backgroundColor(ThemeColors.BG_CARD)
  }


  @Builder
  DataSection() {
    Column({ space: 1 }) {
      Text('数据管理')
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .width('100%')
        .margin({ bottom: 8 })

      Column({ space: 1 }) {
        // 清除缓存
        Row() {
          Column({ space: 2 }) {
            Text('清除缓存')
              .fontSize(ThemeConstants.FONT_SIZE_MD)
              .fontColor(ThemeColors.TEXT_PRIMARY)
            Text(`当前缓存: ${this.cacheSize}`)
              .fontSize(ThemeConstants.FONT_SIZE_XS)
              .fontColor(ThemeColors.TEXT_SECONDARY)
          }
          .alignItems(HorizontalAlign.Start)

          Blank()

          Text('清除')
            .fontSize(ThemeConstants.FONT_SIZE_SM)
            .fontColor(ThemeColors.PRIMARY)
        }
        .width('100%')
        .height(64)
        .padding({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD })
        .backgroundColor(ThemeColors.BG_CARD)
        .onClick(() => {
          this.cacheSize = '0 MB';
        })

        // 导出数据
        Row() {
          Column({ space: 2 }) {
            Text('导出数据')
              .fontSize(ThemeConstants.FONT_SIZE_MD)
              .fontColor(ThemeColors.TEXT_PRIMARY)
            Text('导出配方和记录')
              .fontSize(ThemeConstants.FONT_SIZE_XS)
              .fontColor(ThemeColors.TEXT_SECONDARY)
          }
          .alignItems(HorizontalAlign.Start)

          Blank()

          Text('>')
            .fontSize(ThemeConstants.FONT_SIZE_MD)
            .fontColor(ThemeColors.TEXT_MUTED)
        }
        .width('100%')
        .height(64)
        .padding({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD })
        .backgroundColor(ThemeColors.BG_CARD)

        // 重置数据
        Row() {
          Column({ space: 2 }) {
            Text('重置数据')
              .fontSize(ThemeConstants.FONT_SIZE_MD)
              .fontColor(ThemeColors.ERROR)
            Text('清除所有本地数据')
              .fontSize(ThemeConstants.FONT_SIZE_XS)
              .fontColor(ThemeColors.TEXT_SECONDARY)
          }
          .alignItems(HorizontalAlign.Start)

          Blank()

          Text('>')
            .fontSize(ThemeConstants.FONT_SIZE_MD)
            .fontColor(ThemeColors.TEXT_MUTED)
        }
        .width('100%')
        .height(64)
        .padding({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD })
        .backgroundColor(ThemeColors.BG_CARD)
      }
      .borderRadius(ThemeConstants.RADIUS_MD)
      .clip(true)
    }
  }

  @Builder
  AboutSection() {
    Column({ space: 1 }) {
      Text('关于')
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .width('100%')
        .margin({ bottom: 8 })

      Column({ space: 1 }) {
        Row() {
          Text('版本')
            .fontSize(ThemeConstants.FONT_SIZE_MD)
            .fontColor(ThemeColors.TEXT_PRIMARY)
          Blank()
          Text(AppConstants.APP_VERSION)
            .fontSize(ThemeConstants.FONT_SIZE_MD)
            .fontColor(ThemeColors.TEXT_SECONDARY)
        }
        .width('100%')
        .height(52)
        .padding({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD })
        .backgroundColor(ThemeColors.BG_CARD)

        Row() {
          Text('隐私政策')
            .fontSize(ThemeConstants.FONT_SIZE_MD)
            .fontColor(ThemeColors.TEXT_PRIMARY)
          Blank()
          Text('>')
            .fontSize(ThemeConstants.FONT_SIZE_MD)
            .fontColor(ThemeColors.TEXT_MUTED)
        }
        .width('100%')
        .height(52)
        .padding({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD })
        .backgroundColor(ThemeColors.BG_CARD)

        Row() {
          Text('用户协议')
            .fontSize(ThemeConstants.FONT_SIZE_MD)
            .fontColor(ThemeColors.TEXT_PRIMARY)
          Blank()
          Text('>')
            .fontSize(ThemeConstants.FONT_SIZE_MD)
            .fontColor(ThemeColors.TEXT_MUTED)
        }
        .width('100%')
        .height(52)
        .padding({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD })
        .backgroundColor(ThemeColors.BG_CARD)
      }
      .borderRadius(ThemeConstants.RADIUS_MD)
      .clip(true)
    }
  }
}
