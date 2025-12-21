/**
 * 饵知道 - 收藏页面
 * 展示用户收藏的配方
 */
import { ThemeColors } from '../theme/ThemeColors';
import { ThemeConstants } from '../theme/ThemeConstants';
import { Router } from '../router/Router';
import { AppConstants } from '../common/constants/AppConstants';

// 收藏配方接口
interface FavoriteRecipe {
  id: string;
  name: string;
  targetFish: string;
  rating: number;
  usageCount: number;
  addTime: string;
}

@Entry
@Component
struct FavoritePage {
  @State favorites: FavoriteRecipe[] = [];

  aboutToAppear(): void {
    this.loadFavorites();
  }

  private loadFavorites(): void {
    // 模拟数据
    this.favorites = [
      { id: 'fav_001', name: '经典玉米酒香饵', targetFish: '鲤鱼', rating: 4.8, usageCount: 12, addTime: '10月20日' },
      { id: 'fav_002', name: '秋季红虫粉', targetFish: '鲫鱼', rating: 4.5, usageCount: 8, addTime: '10月15日' },
      { id: 'fav_003', name: '野钓万能饵', targetFish: '草鱼', rating: 4.6, usageCount: 5, addTime: '10月10日' }
    ];
  }

  build() {
    Column() {
      this.HeaderBar()

      if (this.favorites.length === 0) {
        this.EmptyState()
      } else {
        Scroll() {
          Column({ space: ThemeConstants.SPACE_SM }) {
            ForEach(this.favorites, (item: FavoriteRecipe) => {
              this.FavoriteCard(item)
            })
          }
          .padding({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD, bottom: 40 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
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

      Text('我的收藏')
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
  EmptyState() {
    Column({ space: ThemeConstants.SPACE_MD }) {
      Text('📦')
        .fontSize(60)
      Text('暂无收藏')
        .fontSize(ThemeConstants.FONT_SIZE_MD)
        .fontColor(ThemeColors.TEXT_SECONDARY)
      Text('浏览配方库，收藏喜欢的配方')
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_MUTED)
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  FavoriteCard(item: FavoriteRecipe) {
    Row({ space: ThemeConstants.SPACE_MD }) {
      // 左侧图标
      Column() {
        Text('🎣')
          .fontSize(28)
      }
      .width(56)
      .height(56)
      .backgroundColor(ThemeColors.BG_TERTIARY)
      .borderRadius(ThemeConstants.RADIUS_SM)
      .justifyContent(FlexAlign.Center)

      // 中间信息
      Column({ space: 4 }) {
        Text(item.name)
          .fontSize(ThemeConstants.FONT_SIZE_MD)
          .fontWeight(FontWeight.Medium)
          .fontColor(ThemeColors.TEXT_PRIMARY)

        Row({ space: ThemeConstants.SPACE_SM }) {
          Text(`🐟 ${item.targetFish}`)
            .fontSize(ThemeConstants.FONT_SIZE_XS)
            .fontColor(ThemeColors.TEXT_SECONDARY)
          Text(`⭐ ${item.rating}`)
            .fontSize(ThemeConstants.FONT_SIZE_XS)
            .fontColor(ThemeColors.PRIMARY)
        }

        Text(`已使用 ${item.usageCount} 次 · ${item.addTime}收藏`)
          .fontSize(ThemeConstants.FONT_SIZE_XS)
          .fontColor(ThemeColors.TEXT_MUTED)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 右侧箭头
      Text('>')
        .fontSize(ThemeConstants.FONT_SIZE_MD)
        .fontColor(ThemeColors.TEXT_MUTED)
    }
    .width('100%')
    .padding(ThemeConstants.SPACE_MD)
    .backgroundColor(ThemeColors.BG_CARD)
    .borderRadius(ThemeConstants.RADIUS_MD)
    .onClick(() => {
      Router.push(AppConstants.ROUTE_RECIPE_DETAIL, { id: item.id });
    })
  }
}
