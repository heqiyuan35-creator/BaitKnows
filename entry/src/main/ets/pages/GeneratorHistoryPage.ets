/**
 * 饵知�?- 配方生成历史页面
 */
import { ThemeColors } from '../theme/ThemeColors';
import { ThemeConstants } from '../theme/ThemeConstants';
import { Router } from '../router/Router';
import { GeneratedRecipe } from '../common/types/RecipeTypes';
import { generatorHistoryService } from '../services/GeneratorHistoryService';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct GeneratorHistoryPage {
  @State historyList: GeneratedRecipe[] = [];
  @State isLoading: boolean = true;
  @State showClearDialog: boolean = false;

  aboutToAppear(): void {
    this.loadHistory();
  }

  private async loadHistory(): Promise<void> {
    this.isLoading = true;
    await generatorHistoryService.load();
    this.historyList = generatorHistoryService.history;
    this.isLoading = false;
  }

  private formatDate(timestamp: number): string {
    const date = new Date(timestamp);
    const month = date.getMonth() + 1;
    const day = date.getDate();
    const hour = date.getHours().toString().padStart(2, '0');
    const minute = date.getMinutes().toString().padStart(2, '0');
    return `${month}�?{day}�?${hour}:${minute}`;
  }

  private getWaterTypeName(type: string): string {
    const names: Record<string, string> = {
      'river': '河流',
      'pond': '黑坑',
      'reservoir': '水库',
      'wild_pond': '野塘'
    };
    return names[type] || '未知';
  }

  private getSeasonName(season: string): string {
    const names: Record<string, string> = {
      'spring': '春季',
      'summer': '夏季',
      'autumn': '秋季',
      'winter': '冬季'
    };
    return names[season] || '未知';
  }

  private getModeName(mode: string): string {
    const names: Record<string, string> = {
      'conservative': '保守',
      'balanced': '均衡',
      'aggressive': '激�?
    };
    return names[mode] || '均衡';
  }

  private async deleteItem(recipeId: string): Promise<void> {
    const success = await generatorHistoryService.deleteHistory(recipeId);
    if (success) {
      this.historyList = generatorHistoryService.history;
      promptAction.showToast({ message: '已删�? });
    }
  }

  private async clearAllHistory(): Promise<void> {
    await generatorHistoryService.clearAll();
    this.historyList = [];
    this.showClearDialog = false;
    promptAction.showToast({ message: '已清空历史记�? });
  }

  build() {
    Stack() {
      Column() {
        // 顶部导航�?
        this.HeaderBar()

        if (this.isLoading) {
          this.LoadingView()
        } else if (this.historyList.length === 0) {
          this.EmptyView()
        } else {
          this.HistoryList()
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(ThemeColors.BG_PRIMARY)

      // 清空确认弹窗
      if (this.showClearDialog) {
        this.ClearDialog()
      }
    }
    .width('100%')
    .height('100%')
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

      Text('生成历史')
        .fontSize(ThemeConstants.FONT_SIZE_LG)
        .fontWeight(FontWeight.Medium)
        .fontColor(ThemeColors.TEXT_PRIMARY)

      Blank()

      if (this.historyList.length > 0) {
        Text('清空')
          .fontSize(ThemeConstants.FONT_SIZE_SM)
          .fontColor('#FF4444')
          .onClick(() => { this.showClearDialog = true; })
      } else {
        Row().width(24)
      }
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16, top: 40 })
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
  EmptyView() {
    Column({ space: 12 }) {
      Text('📋')
        .fontSize(48)
      Text('暂无生成历史')
        .fontSize(ThemeConstants.FONT_SIZE_BASE)
        .fontColor(ThemeColors.TEXT_SECONDARY)
      Text('生成配方后会自动保存到这�?)
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_MUTED)
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  HistoryList() {
    Scroll() {
      Column({ space: ThemeConstants.SPACE_SM }) {
        ForEach(this.historyList, (recipe: GeneratedRecipe) => {
          this.HistoryCard(recipe)
        })
      }
      .padding({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD, top: ThemeConstants.SPACE_MD, bottom: 40 })
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder
  HistoryCard(recipe: GeneratedRecipe) {
    Column({ space: 10 }) {
      // 标题�?
      Row() {
        Column({ space: 4 }) {
          Text(recipe.name)
            .fontSize(ThemeConstants.FONT_SIZE_MD)
            .fontWeight(FontWeight.Medium)
            .fontColor(ThemeColors.TEXT_PRIMARY)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(this.formatDate(recipe.createTime))
            .fontSize(ThemeConstants.FONT_SIZE_XS)
            .fontColor(ThemeColors.TEXT_MUTED)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        // 味型标签
        Text(`${recipe.flavorProfile.primary}${recipe.flavorProfile.secondary}`)
          .fontSize(ThemeConstants.FONT_SIZE_XS)
          .fontColor(ThemeColors.PRIMARY_DARK)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor('rgba(232, 168, 73, 0.15)')
          .borderRadius(ThemeConstants.RADIUS_FULL)
      }
      .width('100%')

      // 条件标签
      Row({ space: 6 }) {
        this.TagItem(`🌡�?${recipe.conditions.temperature}°C`)
        this.TagItem(`💧 ${this.getWaterTypeName(recipe.conditions.waterType)}`)
        this.TagItem(`🍂 ${this.getSeasonName(recipe.conditions.season)}`)
      }

      // 底部信息
      Row() {
        Text(`${recipe.ingredients.length} 种原�?· ${recipe.totalWeight}g`)
          .fontSize(ThemeConstants.FONT_SIZE_SM)
          .fontColor(ThemeColors.TEXT_SECONDARY)

        Blank()

        Text('删除')
          .fontSize(ThemeConstants.FONT_SIZE_SM)
          .fontColor(ThemeColors.ERROR)
          .onClick(() => { this.deleteItem(recipe.id); })
      }
      .width('100%')
    }
    .width('100%')
    .padding(ThemeConstants.SPACE_MD)
    .backgroundColor(ThemeColors.BG_CARD)
    .borderRadius(ThemeConstants.RADIUS_MD)
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.05)', offsetY: 2 })
  }

  @Builder
  TagItem(text: string) {
    Text(text)
      .fontSize(ThemeConstants.FONT_SIZE_XS)
      .fontColor(ThemeColors.TEXT_SECONDARY)
      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
      .backgroundColor(ThemeColors.BG_TERTIARY)
      .borderRadius(4)
  }

  @Builder
  ClearDialog() {
    Stack() {
      // 遮罩
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.5)')
        .onClick(() => { this.showClearDialog = false; })

      // 弹窗
      Column({ space: 16 }) {
        Text('清空历史')
          .fontSize(ThemeConstants.FONT_SIZE_LG)
          .fontWeight(FontWeight.Medium)
          .fontColor(ThemeColors.TEXT_PRIMARY)

        Text('确定要清空所有生成历史吗？此操作不可恢复�?)
          .fontSize(ThemeConstants.FONT_SIZE_BASE)
          .fontColor(ThemeColors.TEXT_SECONDARY)
          .textAlign(TextAlign.Center)

        Row({ space: 12 }) {
          Button('取消')
            .fontSize(ThemeConstants.FONT_SIZE_BASE)
            .fontColor(ThemeColors.TEXT_PRIMARY)
            .backgroundColor(ThemeColors.BG_TERTIARY)
            .layoutWeight(1)
            .height(44)
            .onClick(() => { this.showClearDialog = false; })

          Button('清空')
            .fontSize(ThemeConstants.FONT_SIZE_BASE)
            .fontColor(Color.White)
            .backgroundColor('#FF4444')
            .layoutWeight(1)
            .height(44)
            .onClick(() => { this.clearAllHistory(); })
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
    .position({ x: 0, y: 0 })
  }
}
