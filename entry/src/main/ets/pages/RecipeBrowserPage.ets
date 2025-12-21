/**
 * 饵知道 - 配方库页面
 * 水域Tab、鱼种筛选、配方列表
 */
import { ThemeColors } from '../theme/ThemeColors';
import { ThemeConstants } from '../theme/ThemeConstants';
import { Router } from '../router/Router';
import { ALL_FISH_DATA, FishData, getFishByWaterType } from '../data/FishData';
import { userDataService, CustomRecipe } from '../services/UserDataService';

// 水域Tab类
class WaterTab {
  type: string = '';
  label: string = '';

  constructor(type: string = '', label: string = '') {
    this.type = type;
    this.label = label;
  }
}

// 鱼种筛选类
class FishFilter {
  id: string = '';
  name: string = '';
  icon: Resource = $r('app.media.Fishs');

  constructor(id: string = '', name: string = '', icon: Resource = $r('app.media.Fishs')) {
    this.id = id;
    this.name = name;
    this.icon = icon;
  }
}

// 配方卡片类
class RecipeCard {
  id: string = '';
  name: string = '';
  targetFish: string = '';
  waterType: string = '';
  tags: string[] = [];
  ingredients: string[] = [];
  rating: number = 0;
  catchRate: number = 0;
  isBeginnerFriendly: boolean = false;
  isFavorite: boolean = false;
  isUserRecipe: boolean = false;

  constructor() {}

  static create(
    id: string, name: string, targetFish: string, waterType: string,
    tags: string[], ingredients: string[], rating: number, catchRate: number,
    isBeginnerFriendly: boolean, isFavorite: boolean, isUserRecipe: boolean = false
  ): RecipeCard {
    const card = new RecipeCard();
    card.id = id;
    card.name = name;
    card.targetFish = targetFish;
    card.waterType = waterType;
    card.tags = tags;
    card.ingredients = ingredients;
    card.rating = rating;
    card.catchRate = catchRate;
    card.isBeginnerFriendly = isBeginnerFriendly;
    card.isFavorite = isFavorite;
    card.isUserRecipe = isUserRecipe;
    return card;
  }
}

@Component
export struct RecipeBrowserPage {
  @State currentWaterTab: number = 0;
  @State selectedFishFilter: string = 'all';
  @State allRecipes: RecipeCard[] = [];  // 所有配方
  @State recipes: RecipeCard[] = [];     // 筛选后的配方
  @State fishFilters: FishFilter[] = []; // 动态鱼种筛选

  // 水域Tab（四大类：池塘、河流、水库、湖泊）
  private waterTabs: WaterTab[] = [
    new WaterTab('pond', '池塘'),
    new WaterTab('river', '河流'),
    new WaterTab('reservoir', '水库'),
    new WaterTab('lake', '湖泊')
  ];

  aboutToAppear(): void {
    this.loadAllData();
  }

  // 加载所有数据
  private async loadAllData(): Promise<void> {
    await userDataService.load();
    this.loadRecipes();
    this.updateFishFilters();
  }

  // 更新当前水域可用的鱼种（使用统一数据源）
  private updateFishFilters(): void {
    const waterType = this.waterTabs[this.currentWaterTab].type;

    // 从统一数据源获取该水域的鱼种
    const fishList = getFishByWaterType(waterType);

    // 构建鱼种筛选列表
    const filters: FishFilter[] = [new FishFilter('all', '全部', $r('app.media.Fishs'))];

    fishList.forEach((fish: FishData) => {
      filters.push(new FishFilter(fish.id, fish.name, fish.icon));
    });

    this.fishFilters = filters;
  }

  // 根据鱼种ID获取中文名
  private getFishName(fishId: string): string {
    const fish = ALL_FISH_DATA.find((f: FishData) => f.id === fishId);
    return fish ? fish.name : fishId;
  }

  private loadRecipes(): void {
    // 各水域配方数据 - 使用RecipeCard.create()创建
    this.allRecipes = [
      // ==================== 池塘配方 ====================
      RecipeCard.create('r_001', '池塘鲫鱼散炮', '鲫鱼', 'pond', ['春季', '浅水'], ['麸皮', '雪花粉', '拉丝粉'], 4.6, 88, true, false),
      // 鲤鱼
      RecipeCard.create('r_002', '黑坑鲤鱼颗粒', '鲤鱼', 'pond', ['四季', '黑坑'], ['原塘颗粒', '小药', '状态粉'], 4.8, 92, false, true),
      // 草鱼
      RecipeCard.create('r_003', '池塘草鱼青草饵', '草鱼', 'pond', ['夏季', '浮钓'], ['嫩草', '玉米', '麦麸'], 4.5, 85, true, false),
      // 鳙鱼
      RecipeCard.create('r_004', '池塘鳙鱼酸臭饵', '鳙鱼', 'pond', ['夏季', '浮钓'], ['臭豆腐汁', '蒜粉', '雪花粉'], 4.6, 86, false, false),
      // 鲢鱼
      RecipeCard.create('r_005', '池塘鲢鱼酸饵', '鲢鱼', 'pond', ['夏季', '浮钓'], ['果酸', '白醋', '雪花粉'], 4.5, 84, false, false),
      // 罗非鱼
      RecipeCard.create('r_006', '南方罗非专用饵', '罗非鱼', 'pond', ['夏季', '底钓'], ['罗非颗粒', '虾粉', '蚯蚓膏'], 4.4, 82, true, false),
      // 斑点叉尾鮰
      RecipeCard.create('r_007', '黑坑叉尾专用饵', '斑点叉尾鮰', 'pond', ['夜钓', '底钓'], ['鲶鱼颗粒', '鸡肝粉', '虾粉'], 4.5, 85, false, false),
      // 鲶鱼
      RecipeCard.create('r_008', '池塘鲶鱼腥饵', '鲶鱼', 'pond', ['夜钓', '底钓'], ['鸡肝', '蚯蚓', '血粉'], 4.6, 88, false, false),
      // 泥鳅
      RecipeCard.create('r_009', '池塘泥鳅饵', '泥鳅', 'pond', ['夏季', '底钓'], ['蚯蚓', '红虫'], 4.2, 75, true, false),
      // 黑鱼
      RecipeCard.create('r_010', '池塘黑鱼雷蛙', '黑鱼', 'pond', ['夏季', '路亚'], ['雷蛙', '软虫', '泥鳅'], 4.7, 85, false, false),
      // 甲鱼
      RecipeCard.create('r_011', '池塘甲鱼饵', '甲鱼', 'pond', ['夜钓', '底钓'], ['鸡肝', '猪肝', '蚯蚓'], 4.4, 78, false, false),

      // ==================== 河流配方 ====================
      // 鲫鱼
      RecipeCard.create('r_101', '野河鲫鱼蚯蚓伴侣', '鲫鱼', 'river', ['四季', '走水'], ['蚯蚓粉', '红虫', '酒米'], 4.7, 90, true, true),
      // 鲤鱼
      RecipeCard.create('r_102', '江河鲤鱼玉米饵', '鲤鱼', 'river', ['夏秋', '深水'], ['发酵玉米', '蜂蜜', '麦粒'], 4.8, 95, false, false),
      // 草鱼
      RecipeCard.create('r_103', '河流草鱼嫩草饵', '草鱼', 'river', ['夏季', '浮钓'], ['嫩草', '芦苇芯', '玉米粒'], 4.6, 85, true, false),
      // 鲶鱼
      RecipeCard.create('r_104', '河流鲶鱼腥饵', '鲶鱼', 'river', ['夜钓', '深潭'], ['鸡肝', '蚯蚓', '泥鳅'], 4.6, 88, false, false),
      // 黄颡鱼
      RecipeCard.create('r_105', '河流黄颡鱼饵', '黄颡鱼', 'river', ['夜钓', '石缝'], ['蚯蚓', '鸡肝', '红虫'], 4.5, 85, true, false),
      // 鳊鱼
      RecipeCard.create('r_106', '河流鳊鱼素饵', '鳊鱼', 'river', ['春夏', '中层'], ['麸皮', '玉米粉', '蜂蜜'], 4.5, 82, true, false),
      // 翘嘴
      RecipeCard.create('r_107', '河流翘嘴路亚饵', '翘嘴', 'river', ['夏秋', '路亚'], ['亮片', '活虾', '小鱼'], 4.7, 82, false, false),
      // 马口
      RecipeCard.create('r_108', '溪流马口饵', '马口', 'river', ['夏季', '路亚'], ['蚂蚱', '蟋蟀', '亮片'], 4.6, 80, false, false),
      // 鲃鱼
      RecipeCard.create('r_109', '急流鲃鱼饵', '鲃鱼', 'river', ['夏季', '急流'], ['蚯蚓', '活虾', '螺蛳'], 4.4, 78, false, false),
      // 赤眼鳟
      RecipeCard.create('r_110', '河钓赤眼鳟饵', '赤眼鳟', 'river', ['春夏', '中层'], ['蚯蚓', '玉米粉', '面粉'], 4.3, 76, true, false),
      // 泥鳅
      RecipeCard.create('r_111', '河流泥鳅饵', '泥鳅', 'river', ['夏季', '泥底'], ['蚯蚓', '红虫'], 4.2, 72, true, false),
      // 河鳜
      RecipeCard.create('r_112', '河流鳜鱼活饵', '河鳜', 'river', ['春秋', '活饵'], ['活泥鳅', '活虾', '小鱼'], 4.7, 85, false, false),

      // ==================== 水库配方 ====================
      // 鲤鱼
      RecipeCard.create('r_201', '水库大鲤守钓饵', '鲤鱼', 'reservoir', ['秋季', '守大物'], ['发酵玉米', '红薯', '药酒'], 4.9, 98, false, true),
      // 草鱼
      RecipeCard.create('r_202', '水库草鱼浮钓饵', '草鱼', 'reservoir', ['夏季', '浮钓'], ['嫩玉米', '青草', '麦麸'], 4.7, 90, true, false),
      // 鳙鱼
      RecipeCard.create('r_203', '水库鳙鱼浮钓饵', '鳙鱼', 'reservoir', ['夏季', '浮钓'], ['藿香正气水', '臭豆腐汁', '轻麸'], 4.6, 88, false, false),
      // 鲢鱼
      RecipeCard.create('r_204', '水库鲢鱼手竿饵', '鲢鱼', 'reservoir', ['夏季', '浮钓'], ['果酸', '白醋', '雪花粉'], 4.5, 85, true, false),
      // 青鱼
      RecipeCard.create('r_205', '水库青鱼螺蛳饵', '青鱼', 'reservoir', ['四季', '底钓'], ['田螺', '螺蛳粉', '蚌肉粉'], 4.8, 92, false, false),
      // 鳜鱼
      RecipeCard.create('r_206', '水库鳜鱼活饵', '鳜鱼', 'reservoir', ['春秋', '活饵'], ['活泥鳅', '活虾', '小鱼'], 4.9, 95, false, true),
      // 武昌鱼
      RecipeCard.create('r_207', '水库武昌鱼素饵', '武昌鱼', 'reservoir', ['春夏', '中层'], ['麸皮', '玉米粉', '蜂蜜'], 4.5, 82, true, false),
      // 巨鲤
      RecipeCard.create('r_208', '水库巨鲤重窝饵', '巨鲤', 'reservoir', ['春秋', '守大物'], ['发酵玉米', '红薯', '药酒'], 4.8, 90, false, false),
      // 黄尾鲴
      RecipeCard.create('r_209', '水库黄尾鲴饵', '黄尾鲴', 'reservoir', ['春夏', '底钓'], ['混合颗粒', '麸皮', '蚯蚓粉'], 4.4, 78, true, false),
      // 鲮鱼
      RecipeCard.create('r_210', '南方鲮鱼专用饵', '鲮鱼', 'reservoir', ['夏秋', '底钓'], ['花生粉', '麸皮', '玉米粉'], 4.6, 85, true, false),
      // 大口黑鲈
      RecipeCard.create('r_211', '水库黑鲈路亚饵', '大口黑鲈', 'reservoir', ['春夏秋', '路亚'], ['软虫', '活虾', '小鱼'], 4.8, 88, false, false),
      // 翘嘴
      RecipeCard.create('r_212', '水库翘嘴路亚饵', '翘嘴', 'reservoir', ['夏秋', '路亚'], ['亮片', '活虾', '小鱼'], 4.7, 85, false, false),

      // ==================== 湖泊配方 ====================
      // 鲫鱼
      RecipeCard.create('r_301', '湖泊鲫鱼传统钓', '鲫鱼', 'lake', ['四季', '传统钓'], ['酒米', '蚯蚓', '红虫'], 4.7, 90, true, true),
      // 鲤鱼
      RecipeCard.create('r_302', '湖泊鲤鱼爆炸钩', '鲤鱼', 'lake', ['夏秋', '海竿'], ['糠饼', '玉米', '麦粒'], 4.8, 92, false, false),
      // 草鱼
      RecipeCard.create('r_303', '湖泊草鱼浮钓饵', '草鱼', 'lake', ['夏季', '浮钓'], ['嫩草', '芦苇芯', '玉米粒'], 4.6, 85, true, false),
      // 鳜鱼
      RecipeCard.create('r_304', '湖泊鳜鱼活饵', '鳜鱼', 'lake', ['夏秋', '活饵'], ['活泥鳅', '活虾', '小鱼'], 4.9, 95, false, true),
      // 青鱼
      RecipeCard.create('r_305', '湖泊青鱼螺蛳饵', '青鱼', 'lake', ['夏秋', '底钓'], ['田螺', '螺蛳粉', '蚌肉'], 4.8, 90, false, false),
      // 黑鱼
      RecipeCard.create('r_306', '湖泊黑鱼雷蛙', '黑鱼', 'lake', ['夏季', '路亚'], ['雷蛙', '软虫', '泥鳅'], 4.7, 85, false, false),
      // 狗鱼
      RecipeCard.create('r_307', '北方狗鱼饵', '狗鱼', 'lake', ['春秋冬', '路亚'], ['大型软虫', '小鱼', '亮片'], 4.6, 80, false, false),
      // 鲈鱼
      RecipeCard.create('r_308', '湖钓鲈鱼饵', '鲈鱼', 'lake', ['春秋', '活饵'], ['活虾', '小鱼', '蚯蚓'], 4.5, 82, false, false),
      // 银鱼
      RecipeCard.create('r_309', '银鱼专用饵', '银鱼', 'lake', ['春秋', '细线'], ['红虫', '小虫'], 4.2, 70, false, false),
      // 红鳍鲌
      RecipeCard.create('r_310', '红鳍鲌路亚饵', '红鳍鲌', 'lake', ['夏秋', '路亚'], ['亮片', '活虾', '小鱼'], 4.5, 80, false, false),
      // 甲鱼
      RecipeCard.create('r_311', '湖泊甲鱼饵', '甲鱼', 'lake', ['夜钓', '底钓'], ['鸡肝', '猪肝', '蚯蚓'], 4.4, 75, false, false),
      // 黄鳝
      RecipeCard.create('r_312', '湖泊黄鳝饵', '黄鳝', 'lake', ['夜钓', '洞穴'], ['蚯蚓', '小鱼'], 4.3, 72, false, false),
      // 河蟹
      RecipeCard.create('r_313', '秋季河蟹饵', '河蟹', 'lake', ['秋季', '蟹笼'], ['鸡肝', '鱼肉', '玉米'], 4.5, 85, true, false),
      // 河虾
      RecipeCard.create('r_314', '湖泊河虾饵', '河虾', 'lake', ['夏秋', '虾笼'], ['蚯蚓', '红虫', '面粉'], 4.2, 75, true, false),
      // 鳊鱼
      RecipeCard.create('r_315', '湖泊鳊鱼素饵', '鳊鱼', 'lake', ['春夏', '浮钓'], ['麸皮', '玉米粉', '拉丝粉'], 4.5, 82, true, false),
      // 武昌鱼
      RecipeCard.create('r_318', '湖泊武昌鱼素饵', '武昌鱼', 'lake', ['春夏', '中层'], ['麸皮', '玉米粉', '蜂蜜'], 4.5, 82, true, false),
      // 大口黑鲈
      RecipeCard.create('r_316', '湖泊黑鲈路亚饵', '大口黑鲈', 'lake', ['春夏秋', '路亚'], ['软虫', '活虾', '小鱼'], 4.8, 88, false, false),
      // 翘嘴
      RecipeCard.create('r_317', '湖泊翘嘴路亚饵', '翘嘴', 'lake', ['夏秋', '路亚'], ['亮片', '活虾', '小鱼'], 4.7, 85, false, false)
    ];

    // 加载用户保存的配方
    this.loadUserRecipes();

    this.filterRecipes();
  }

  // 加载用户保存的配方
  private loadUserRecipes(): void {
    const userRecipes = userDataService.getCustomRecipes();

    for (let i = 0; i < userRecipes.length; i++) {
      const ur = userRecipes[i];

      // 转换水域类型
      let waterType = 'pond';
      if (ur.waterType === 'river' || ur.waterType === 'wild_pond') {
        waterType = 'river';
      } else if (ur.waterType === 'reservoir') {
        waterType = 'reservoir';
      } else if (ur.waterType === 'pond') {
        waterType = 'pond';
      }

      // 获取鱼种名称
      let targetFishName = '鲫鱼';
      if (ur.targetFish.length > 0) {
        targetFishName = this.getFishName(ur.targetFish[0]);
      }

      // 获取季节标签
      let seasonTag = '四季';
      if (ur.season === 'spring') seasonTag = '春季';
      else if (ur.season === 'summer') seasonTag = '夏季';
      else if (ur.season === 'autumn') seasonTag = '秋季';
      else if (ur.season === 'winter') seasonTag = '冬季';

      // 获取配料名称列表
      const ingredientNames: string[] = [];
      for (let j = 0; j < Math.min(3, ur.ingredients.length); j++) {
        ingredientNames.push(ur.ingredients[j].name);
      }

      const card = RecipeCard.create(
        ur.id, ur.name, targetFishName, waterType,
        [seasonTag, '自定义'], ingredientNames,
        4.5, 80, false, true, true
      );

      this.allRecipes.unshift(card);  // 用户配方放在最前面
    }
  }

  // 筛选配方
  private filterRecipes(): void {
    const waterType = this.waterTabs[this.currentWaterTab].type;
    const fishFilter = this.selectedFishFilter;

    this.recipes = this.allRecipes.filter((recipe: RecipeCard) => {
      // 水域筛选
      if (recipe.waterType !== waterType) return false;
      // 鱼种筛选
      if (fishFilter !== 'all') {
        const targetFishName = this.getFishName(fishFilter);
        if (!recipe.targetFish.includes(targetFishName)) return false;
      }
      return true;
    });
  }

  build() {
    Column() {
      // 顶部标题栏
      this.HeaderBar()

      // 水域Tab
      this.WaterTabBar()

      // 内容区域
      Row() {
        // 左侧鱼种筛选
        this.FishFilterSidebar()

        // 右侧配方列表
        this.RecipeList()
      }
      .width('100%')
      .layoutWeight(1)
      .alignItems(VerticalAlign.Top)  // 顶部对齐
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeColors.BG_PRIMARY)
  }

  @Builder
  HeaderBar() {
    Row() {
      Text('鱼饵配方库')
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
  WaterTabBar() {
    Row() {
      ForEach(this.waterTabs, (tab: WaterTab, index: number) => {
        Column() {
          Text(tab.label)
            .fontSize(ThemeConstants.FONT_SIZE_BASE)
            .fontColor(this.currentWaterTab === index ? ThemeColors.PRIMARY : ThemeColors.TEXT_SECONDARY)
            .fontWeight(this.currentWaterTab === index ? FontWeight.Medium : FontWeight.Normal)
            .padding({ left: 16, right: 16, top: 12, bottom: 8 })

          // 选中指示条
          Row()
            .width(24)
            .height(3)
            .backgroundColor(this.currentWaterTab === index ? ThemeColors.PRIMARY : Color.Transparent)
            .borderRadius(2)
        }
        .onClick(() => {
          this.currentWaterTab = index;
          this.selectedFishFilter = 'all';  // 切换水域时重置鱼种筛选
          this.updateFishFilters();  // 更新可用鱼种
          this.filterRecipes();
        })
      })
    }
    .width('100%')
    .padding({ bottom: 4 })
    .backgroundColor(ThemeColors.BG_SECONDARY)
  }

  @Builder
  FishFilterSidebar() {
    Scroll() {
      Column({ space: 4 }) {
        ForEach(this.fishFilters, (filter: FishFilter) => {
          this.FishFilterItem(filter)
        })
      }
      .padding({ top: 8, bottom: 8 })
    }
    .width(72)
    .height('100%')
    .backgroundColor(ThemeColors.BG_SECONDARY)
    .scrollBar(BarState.Off)
  }

  @Builder
  FishFilterItem(filter: FishFilter) {
    Column({ space: 4 }) {
      Row() {
        Image(filter.icon)
          .width(28)
          .height(28)
          .objectFit(ImageFit.Contain)
      }
      .width(44)
      .height(44)
      .backgroundColor(this.selectedFishFilter === filter.id ? 'rgba(232, 168, 73, 0.15)' : ThemeColors.BG_TERTIARY)
      .borderRadius(12)
      .justifyContent(FlexAlign.Center)
      .border({
        width: this.selectedFishFilter === filter.id ? 2 : 0,
        color: ThemeColors.PRIMARY
      })

      Text(filter.name)
        .fontSize(ThemeConstants.FONT_SIZE_XS)
        .fontColor(this.selectedFishFilter === filter.id ? ThemeColors.PRIMARY : ThemeColors.TEXT_SECONDARY)
        .fontWeight(this.selectedFishFilter === filter.id ? FontWeight.Medium : FontWeight.Normal)
    }
    .width('100%')
    .padding({ top: 10, bottom: 10 })
    .onClick(() => {
      this.selectedFishFilter = filter.id;
      this.filterRecipes();
    })
  }

  @Builder
  RecipeList() {
    Scroll() {
      Column({ space: ThemeConstants.SPACE_MD }) {
        // 热门推荐标题
        Row() {
          Text('热门推荐')
            .fontSize(ThemeConstants.FONT_SIZE_MD)
            .fontWeight(FontWeight.Medium)
            .fontColor(ThemeColors.TEXT_PRIMARY)
          Blank()
          Text(`共 ${this.recipes.length} 个配方`)
            .fontSize(ThemeConstants.FONT_SIZE_SM)
            .fontColor(ThemeColors.TEXT_MUTED)
        }
        .width('100%')

        // 配方卡片列表
        ForEach(this.recipes, (recipe: RecipeCard) => {
          this.RecipeCardBuilder(recipe)
        })
      }
      .padding(ThemeConstants.SPACE_MD)
    }
    .layoutWeight(1)
    .height('100%')
    .scrollBar(BarState.Off)
  }

  @Builder
  RecipeCardBuilder(recipe: RecipeCard) {
    Column({ space: ThemeConstants.SPACE_SM }) {
      // 用户配方标识
      if (recipe.isUserRecipe) {
        Row({ space: 4 }) {
          Text('⭐')
            .fontSize(12)
          Text('我的配方')
            .fontSize(ThemeConstants.FONT_SIZE_XS)
            .fontColor(ThemeColors.PRIMARY)
        }
        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        .backgroundColor('rgba(232, 168, 73, 0.15)')
        .borderRadius(ThemeConstants.RADIUS_XS)
      }
      // 上鱼率标签
      else if (recipe.catchRate >= 90) {
        Row({ space: 4 }) {
          Text('🔥')
            .fontSize(12)
          Text(`${recipe.catchRate}% 上鱼率`)
            .fontSize(ThemeConstants.FONT_SIZE_XS)
            .fontColor(ThemeColors.SUCCESS)
        }
        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        .backgroundColor('rgba(76, 175, 80, 0.15)')
        .borderRadius(ThemeConstants.RADIUS_XS)
      }

      // 配方名称和收藏
      Row() {
        Text(recipe.name)
          .fontSize(ThemeConstants.FONT_SIZE_MD)
          .fontWeight(FontWeight.Medium)
          .fontColor(ThemeColors.TEXT_PRIMARY)
        Blank()
        Image(recipe.isFavorite ? $r('app.media.heartfill') : $r('app.media.heartfill'))
          .width(20)
          .height(20)
          .fillColor(recipe.isFavorite ? ThemeColors.PRIMARY : ThemeColors.TEXT_MUTED)
      }
      .width('100%')

      // 标签
      Row({ space: 6 }) {
        ForEach(recipe.tags, (tag: string) => {
          Text(tag)
            .fontSize(ThemeConstants.FONT_SIZE_XS)
            .fontColor(ThemeColors.TEXT_SECONDARY)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor(ThemeColors.BG_TERTIARY)
            .borderRadius(ThemeConstants.RADIUS_XS)
        })
      }

      // 配料
      Row({ space: 6 }) {
        ForEach(recipe.ingredients, (ing: string) => {
          Row({ space: 4 }) {
            Circle()
              .width(6)
              .height(6)
              .fill(ThemeColors.PRIMARY)
            Text(ing)
              .fontSize(ThemeConstants.FONT_SIZE_SM)
              .fontColor(ThemeColors.TEXT_PRIMARY)
          }
        })
      }

      // 新手友好标签
      if (recipe.isBeginnerFriendly) {
        Row({ space: 4 }) {
          Text('👍')
            .fontSize(10)
          Text('新手友好')
            .fontSize(ThemeConstants.FONT_SIZE_XS)
            .fontColor(ThemeColors.INFO)
        }
        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        .backgroundColor('rgba(33, 150, 243, 0.15)')
        .borderRadius(ThemeConstants.RADIUS_XS)
      }

      // 查看详情按钮
      Button('查看详情 →')
        .width('100%')
        .height(ThemeConstants.HEIGHT_BASE)
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_PRIMARY)
        .backgroundColor(ThemeColors.PRIMARY)
        .borderRadius(ThemeConstants.RADIUS_SM)
        .margin({ top: 8 })
        .onClick(() => {
          Router.goToRecipeDetail(recipe.id);
        })
    }
    .width('100%')
    .padding(ThemeConstants.SPACE_MD)
    .backgroundColor(ThemeColors.BG_CARD)
    .borderRadius(ThemeConstants.RADIUS_MD)
  }
}

