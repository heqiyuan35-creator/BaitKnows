/**
 * 饵知�?- 收藏页面
 * 展示用户收藏的配�?
 */
import { ThemeColors } from '../theme/ThemeColors';
import { ThemeConstants } from '../theme/ThemeConstants';
import { Router } from '../router/Router';
import { userDataService, CustomRecipe } from '../services/UserDataService';
import { router } from '@kit.ArkUI';

// 收藏配方接口
class FavoriteRecipe {
  id: string = '';
  name: string = '';
  targetFish: string = '';
  rating: number = 4.5;
  usageCount: number = 0;
  addTime: string = '';
  isUserRecipe: boolean = false;
}

// 预设配方简要信息（用于显示收藏的预设配方）
class PresetRecipeInfo {
  id: string = '';
  name: string = '';
  targetFish: string = '';
  rating: number = 4.5;

  constructor(id: string, name: string, fish: string, rating: number) {
    this.id = id;
    this.name = name;
    this.targetFish = fish;
    this.rating = rating;
  }
}

// 预设配方数据库（简化版，用于收藏页显示�?
const PRESET_RECIPES: Map<string, PresetRecipeInfo> = new Map([
  // 池塘
  ['r_001', new PresetRecipeInfo('r_001', '池塘鲫鱼散炮', '鲫鱼', 4.6)],
  ['r_002', new PresetRecipeInfo('r_002', '黑坑鲤鱼颗粒', '鲤鱼', 4.8)],
  ['r_003', new PresetRecipeInfo('r_003', '池塘草鱼青草�?, '草鱼', 4.5)],
  ['r_004', new PresetRecipeInfo('r_004', '池塘鳙鱼酸臭�?, '鳙鱼', 4.6)],
  ['r_005', new PresetRecipeInfo('r_005', '池塘鲢鱼酸饵', '鲢鱼', 4.5)],
  ['r_006', new PresetRecipeInfo('r_006', '南方罗非专用�?, '罗非�?, 4.4)],
  ['r_007', new PresetRecipeInfo('r_007', '黑坑叉尾专用�?, '斑点叉尾�?, 4.5)],
  ['r_008', new PresetRecipeInfo('r_008', '池塘鲶鱼腥饵', '鲶鱼', 4.6)],
  // 河流
  ['r_101', new PresetRecipeInfo('r_101', '野河鲫鱼蚯蚓伴侣', '鲫鱼', 4.7)],
  ['r_102', new PresetRecipeInfo('r_102', '江河鲤鱼玉米�?, '鲤鱼', 4.8)],
  ['r_103', new PresetRecipeInfo('r_103', '河流草鱼嫩草�?, '草鱼', 4.6)],
  ['r_105', new PresetRecipeInfo('r_105', '河流黄颡鱼饵', '黄颡�?, 4.5)],
  ['r_106', new PresetRecipeInfo('r_106', '河流鳊鱼素饵', '鳊鱼', 4.5)],
  ['r_107', new PresetRecipeInfo('r_107', '河流翘嘴路亚�?, '翘嘴', 4.7)],
  // 水库
  ['r_201', new PresetRecipeInfo('r_201', '水库大鲤守钓�?, '鲤鱼', 4.9)],
  ['r_202', new PresetRecipeInfo('r_202', '水库草鱼浮钓�?, '草鱼', 4.7)],
  ['r_205', new PresetRecipeInfo('r_205', '水库青鱼螺蛳�?, '青鱼', 4.8)],
  ['r_206', new PresetRecipeInfo('r_206', '水库鳜鱼活饵', '鳜鱼', 4.9)],
  ['r_207', new PresetRecipeInfo('r_207', '水库武昌鱼素�?, '武昌�?, 4.5)],
  ['r_210', new PresetRecipeInfo('r_210', '南方鲮鱼专用�?, '鲮鱼', 4.6)],
  // 湖泊
  ['r_301', new PresetRecipeInfo('r_301', '湖泊鲫鱼传统�?, '鲫鱼', 4.7)],
  ['r_302', new PresetRecipeInfo('r_302', '湖泊鲤鱼爆炸�?, '鲤鱼', 4.8)],
  ['r_304', new PresetRecipeInfo('r_304', '湖泊鳜鱼活饵', '鳜鱼', 4.9)],
  ['r_305', new PresetRecipeInfo('r_305', '湖泊青鱼螺蛳�?, '青鱼', 4.8)],
  ['r_306', new PresetRecipeInfo('r_306', '湖泊黑鱼雷蛙', '黑鱼', 4.7)],
  ['r_315', new PresetRecipeInfo('r_315', '湖泊鳊鱼素饵', '鳊鱼', 4.5)]
]);

@Entry
@Component
struct FavoritePage {
  @State favorites: FavoriteRecipe[] = [];
  @State isLoading: boolean = true;

  aboutToAppear(): void {
    this.loadFavorites();
  }

  onPageShow(): void {
    this.loadFavorites();
  }

  private async loadFavorites(): Promise<void> {
    this.isLoading = true;
    await userDataService.load(true);

    const favoriteIds = userDataService.getFavoriteRecipes();
    const userRecipes = userDataService.getCustomRecipes();
    const result: FavoriteRecipe[] = [];

    // 遍历收藏ID列表
    for (let i = 0; i < favoriteIds.length; i++) {
      const id = favoriteIds[i];
      
      // 检查是否是预设配方
      const preset = PRESET_RECIPES.get(id);
      if (preset) {
        const fav = new FavoriteRecipe();
        fav.id = preset.id;
        fav.name = preset.name;
        fav.targetFish = preset.targetFish;
        fav.rating = preset.rating;
        fav.usageCount = Math.floor(Math.random() * 10);
        fav.addTime = this.formatDate(Date.now() - Math.random() * 30 * 24 * 60 * 60 * 1000);
        fav.isUserRecipe = false;
        result.push(fav);
        continue;
      }

      // 检查是否是用户配方
      for (let j = 0; j < userRecipes.length; j++) {
        const ur = userRecipes[j];
        if (ur.id === id) {
          const fav = new FavoriteRecipe();
          fav.id = ur.id;
          fav.name = ur.name;
          fav.targetFish = this.getFishName(ur.targetFish);
          fav.rating = 4.5;
          fav.usageCount = 0;
          fav.addTime = this.formatDate(ur.createdAt);
          fav.isUserRecipe = true;
          result.push(fav);
          break;
        }
      }
    }

    this.favorites = result;
    this.isLoading = false;
  }

  // 格式化日�?
  private formatDate(timestamp: number): string {
    const date = new Date(timestamp);
    return `${date.getMonth() + 1}�?{date.getDate()}日`;
  }

  // 获取鱼种名称
  private getFishName(fishIds: string[]): string {
    if (fishIds.length === 0) return '综合';
    const fishMap: Map<string, string> = new Map([
      ['crucian', '鲫鱼'], ['carp', '鲤鱼'], ['grass', '草鱼'],
      ['black_carp', '青鱼'], ['catfish', '鲶鱼'], ['bighead', '鳙鱼'],
      ['silver', '鲢鱼'], ['tilapia', '罗非�?], ['grass_carp', '草鱼'],
      ['silver_carp', '鲢鱼'], ['bighead_carp', '鳙鱼'], ['yellow_catfish', '黄颡�?],
      ['mandarin_fish', '鳜鱼'], ['snakehead', '黑鱼'], ['bream', '鳊鱼'],
      ['topmouth_culter', '翘嘴']
    ]);
    const name = fishMap.get(fishIds[0]);
    return name !== undefined ? name : fishIds[0];
  }

  build() {
    Column() {
      this.HeaderBar()

      if (this.isLoading) {
        Column() {
          LoadingProgress().width(40).height(40)
          Text('加载�?..').fontSize(14).fontColor(ThemeColors.TEXT_SECONDARY).margin({ top: 12 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.favorites.length === 0) {
        this.EmptyState()
      } else {
        Scroll() {
          Column({ space: ThemeConstants.SPACE_SM }) {
            ForEach(this.favorites, (item: FavoriteRecipe) => {
              this.FavoriteCard(item)
            })
          }
          .padding({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD, top: 16, bottom: 40 })
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
      Text('浏览配方库，点击爱心收藏喜欢的配�?)
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
        Image($r('app.media.hook'))
          .width(32)
          .height(32)
      }
      .width(56)
      .height(56)
      .backgroundColor(item.isUserRecipe ? 'rgba(232, 168, 73, 0.15)' : ThemeColors.BG_TERTIARY)
      .borderRadius(ThemeConstants.RADIUS_SM)
      .justifyContent(FlexAlign.Center)

      // 中间信息
      Column({ space: 4 }) {
        Row({ space: 6 }) {
          Text(item.name)
            .fontSize(ThemeConstants.FONT_SIZE_MD)
            .fontWeight(FontWeight.Medium)
            .fontColor(ThemeColors.TEXT_PRIMARY)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)

          if (item.isUserRecipe) {
            Text('我的')
              .fontSize(10)
              .fontColor(ThemeColors.PRIMARY_DARK)
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .backgroundColor('rgba(232, 168, 73, 0.15)')
              .borderRadius(4)
          }
        }
        .width('100%')

        Row({ space: ThemeConstants.SPACE_SM }) {
          Text(`🐟 ${item.targetFish}`)
            .fontSize(ThemeConstants.FONT_SIZE_XS)
            .fontColor(ThemeColors.TEXT_SECONDARY)
          Text(`�?${item.rating.toFixed(1)}`)
            .fontSize(ThemeConstants.FONT_SIZE_XS)
            .fontColor(ThemeColors.PRIMARY_DARK)
        }

        Text(`${item.addTime}收藏`)
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
      router.pushUrl({
        url: 'pages/RecipeDetailPage',
        params: { recipeId: item.id }
      });
    })
  }
}
