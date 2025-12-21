/**
 * 饵知�?- 配方库页�?
 * 水域Tab、鱼种筛选、配方列�?
 */
import { ThemeColors } from '../theme/ThemeColors';
import { ThemeConstants } from '../theme/ThemeConstants';
import { Router } from '../router/Router';
import { ALL_FISH_DATA, FishData, getFishByWaterType } from '../data/FishData';
import { userDataService, CustomRecipe } from '../services/UserDataService';

// 水域Tab接口
interface WaterTab {
  type: string;
  label: string;
}

// 鱼种筛选接�?
interface FishFilter {
  id: string;
  name: string;
  icon: Resource;
}

// 配方卡片接口
interface RecipeCard {
  id: string;
  name: string;
  targetFish: string;
  waterType: string;  // 水域类型
  tags: string[];
  ingredients: string[];
  rating: number;
  catchRate: number;
  isBeginnerFriendly: boolean;
  isFavorite: boolean;
  isUserRecipe: boolean;  // 是否为用户配�?
}

@Component
export struct RecipeBrowserPage {
  @State currentWaterTab: number = 0;
  @State selectedFishFilter: string = 'all';
  @State allRecipes: RecipeCard[] = [];  // 所有配�?
  @State recipes: RecipeCard[] = [];     // 筛选后的配�?
  @State fishFilters: FishFilter[] = []; // 动态鱼种筛�?

  // 水域Tab（四大类：池塘、河流、水库、湖泊）
  private waterTabs: WaterTab[] = [
    { type: 'pond', label: '池塘' },
    { type: 'river', label: '河流' },
    { type: 'reservoir', label: '水库' },
    { type: 'lake', label: '湖泊' }
  ];

  aboutToAppear(): void {
    this.loadAllData();
  }

  // 加载所有数�?
  private async loadAllData(): Promise<void> {
    await userDataService.load();
    this.loadRecipes();
    this.updateFishFilters();
  }

  // 更新当前水域可用的鱼种（使用统一数据源）
  private updateFishFilters(): void {
    const waterType = this.waterTabs[this.currentWaterTab].type;

    // 从统一数据源获取该水域的鱼�?
    const fishList = getFishByWaterType(waterType);

    // 构建鱼种筛选列�?
    const filters: FishFilter[] = [{ id: 'all', name: '全部', icon: $r('app.media.Fishs') }];

    fishList.forEach((fish: FishData) => {
      filters.push({
        id: fish.id,
        name: fish.name,
        icon: fish.icon
      });
    });

    this.fishFilters = filters;
  }

  // 根据鱼种ID获取中文�?
  private getFishName(fishId: string): string {
    const fish = ALL_FISH_DATA.find((f: FishData) => f.id === fishId);
    return fish ? fish.name : fishId;
  }

  private loadRecipes(): void {
    // 各水域配方数�?- 每个配方都有独特的配料和属�?
    this.allRecipes = [
      // ==================== 池塘配方 ====================
      // 鲫鱼
      { id: 'r_001', name: '池塘鲫鱼散炮', targetFish: '鲫鱼', waterType: 'pond',
        tags: ['春季', '浅水'], ingredients: ['麸皮', '雪花�?, '拉丝�?],
        rating: 4.6, catchRate: 88, isBeginnerFriendly: true, isFavorite: false, isUserRecipe: false },
      // 鲤鱼
      { id: 'r_002', name: '黑坑鲤鱼颗粒', targetFish: '鲤鱼', waterType: 'pond',
        tags: ['四季', '黑坑'], ingredients: ['原塘颗粒', '小药', '状态粉'],
        rating: 4.8, catchRate: 92, isBeginnerFriendly: false, isFavorite: true, isUserRecipe: false },
      // 草鱼
      { id: 'r_003', name: '池塘草鱼青草�?, targetFish: '草鱼', waterType: 'pond',
        tags: ['夏季', '浮钓'], ingredients: ['嫩草', '玉米', '麦麸'],
        rating: 4.5, catchRate: 85, isBeginnerFriendly: true, isFavorite: false, isUserRecipe: false },
      // 鳙鱼
      { id: 'r_004', name: '池塘鳙鱼酸臭�?, targetFish: '鳙鱼', waterType: 'pond',
        tags: ['夏季', '浮钓'], ingredients: ['臭豆腐汁', '蒜粉', '雪花�?],
        rating: 4.6, catchRate: 86, isBeginnerFriendly: false, isFavorite: false, isUserRecipe: false },
      // 鲢鱼
      { id: 'r_005', name: '池塘鲢鱼酸饵', targetFish: '鲢鱼', waterType: 'pond',
        tags: ['夏季', '浮钓'], ingredients: ['果酸', '白醋', '雪花�?],
        rating: 4.5, catchRate: 84, isBeginnerFriendly: false, isFavorite: false, isUserRecipe: false },
      // 罗非�?
      { id: 'r_006', name: '南方罗非专用�?, targetFish: '罗非�?, waterType: 'pond',
        tags: ['夏季', '底钓'], ingredients: ['罗非颗粒', '虾粉', '蚯蚓�?],
        rating: 4.4, catchRate: 82, isBeginnerFriendly: true, isFavorite: false, isUserRecipe: false },
      // 斑点叉尾�?
      { id: 'r_007', name: '黑坑叉尾专用�?, targetFish: '斑点叉尾�?, waterType: 'pond',
        tags: ['夜钓', '底钓'], ingredients: ['鲶鱼颗粒', '鸡肝�?, '虾粉'],
        rating: 4.5, catchRate: 85, isBeginnerFriendly: false, isFavorite: false, isUserRecipe: false },
      // 鲶鱼
      { id: 'r_008', name: '池塘鲶鱼腥饵', targetFish: '鲶鱼', waterType: 'pond',
        tags: ['夜钓', '底钓'], ingredients: ['鸡肝', '蚯蚓', '血�?],
        rating: 4.6, catchRate: 88, isBeginnerFriendly: false, isFavorite: false, isUserRecipe: false },
      // 泥鳅
      { id: 'r_009', name: '池塘泥鳅�?, targetFish: '泥鳅', waterType: 'pond',
        tags: ['夏季', '底钓'], ingredients: ['蚯蚓', '红虫'],
        rating: 4.2, catchRate: 75, isBeginnerFriendly: true, isFavorite: false, isUserRecipe: false },
      // 黑鱼
      { id: 'r_010', name: '池塘黑鱼雷蛙', targetFish: '黑鱼', waterType: 'pond',
        tags: ['夏季', '路亚'], ingredients: ['雷蛙', '软虫', '泥鳅'],
        rating: 4.7, catchRate: 85, isBeginnerFriendly: false, isFavorite: false, isUserRecipe: false },
      // 甲鱼
      { id: 'r_011', name: '池塘甲鱼�?, targetFish: '甲鱼', waterType: 'pond',
        tags: ['夜钓', '底钓'], ingredients: ['鸡肝', '猪肝', '蚯蚓'],
        rating: 4.4, catchRate: 78, isBeginnerFriendly: false, isFavorite: false, isUserRecipe: false },

      // ==================== 河流配方 ====================
      // 鲫鱼
      { id: 'r_101', name: '野河鲫鱼蚯蚓伴侣', targetFish: '鲫鱼', waterType: 'river',
        tags: ['四季', '走水'], ingredients: ['蚯蚓�?, '红虫', '酒米'],
        rating: 4.7, catchRate: 90, isBeginnerFriendly: true, isFavorite: true, isUserRecipe: false },
      // 鲤鱼
      { id: 'r_102', name: '江河鲤鱼玉米�?, targetFish: '鲤鱼', waterType: 'river',
        tags: ['夏秋', '深水'], ingredients: ['发酵玉米', '蜂蜜', '麦粒'],
        rating: 4.8, catchRate: 95, isBeginnerFriendly: false, isFavorite: false, isUserRecipe: false },
      // 草鱼
      { id: 'r_103', name: '河流草鱼嫩草�?, targetFish: '草鱼', waterType: 'river',
        tags: ['夏季', '浮钓'], ingredients: ['嫩草', '芦苇�?, '玉米�?],
        rating: 4.6, catchRate: 85, isBeginnerFriendly: true, isFavorite: false, isUserRecipe: false },
      // 鲶鱼
      { id: 'r_104', name: '河流鲶鱼腥饵', targetFish: '鲶鱼', waterType: 'river',
        tags: ['夜钓', '深潭'], ingredients: ['鸡肝', '蚯蚓', '泥鳅'],
        rating: 4.6, catchRate: 88, isBeginnerFriendly: false, isFavorite: false, isUserRecipe: false },
      // 黄颡�?
      { id: 'r_105', name: '河流黄颡鱼饵', targetFish: '黄颡�?, waterType: 'river',
        tags: ['夜钓', '石缝'], ingredients: ['蚯蚓', '鸡肝', '红虫'],
        rating: 4.5, catchRate: 85, isBeginnerFriendly: true, isFavorite: false, isUserRecipe: false },
      // 鳊鱼
      { id: 'r_106', name: '河流鳊鱼素饵', targetFish: '鳊鱼', waterType: 'river',
        tags: ['春夏', '中层'], ingredients: ['麸皮', '玉米�?, '蜂蜜'],
        rating: 4.5, catchRate: 82, isBeginnerFriendly: true, isFavorite: false, isUserRecipe: false },
      // 翘嘴
      { id: 'r_107', name: '河流翘嘴路亚�?, targetFish: '翘嘴', waterType: 'river',
        tags: ['夏秋', '路亚'], ingredients: ['亮片', '活虾', '小鱼'],
        rating: 4.7, catchRate: 82, isBeginnerFriendly: false, isFavorite: false, isUserRecipe: false },
      // 马口
      { id: 'r_108', name: '溪流马口�?, targetFish: '马口', waterType: 'river',
        tags: ['夏季', '路亚'], ingredients: ['蚂蚱', '蟋蟀', '亮片'],
        rating: 4.6, catchRate: 80, isBeginnerFriendly: false, isFavorite: false, isUserRecipe: false },
      // 鲃鱼
      { id: 'r_109', name: '急流鲃鱼�?, targetFish: '鲃鱼', waterType: 'river',
        tags: ['夏季', '急流'], ingredients: ['蚯蚓', '活虾', '螺蛳'],
        rating: 4.4, catchRate: 78, isBeginnerFriendly: false, isFavorite: false, isUserRecipe: false },
      // 赤眼�?
      { id: 'r_110', name: '河钓赤眼鳟饵', targetFish: '赤眼�?, waterType: 'river',
        tags: ['春夏', '中层'], ingredients: ['蚯蚓', '玉米�?, '面粉'],
        rating: 4.3, catchRate: 76, isBeginnerFriendly: true, isFavorite: false, isUserRecipe: false },
      // 泥鳅
      { id: 'r_111', name: '河流泥鳅�?, targetFish: '泥鳅', waterType: 'river',
        tags: ['夏季', '泥底'], ingredients: ['蚯蚓', '红虫'],
        rating: 4.2, catchRate: 72, isBeginnerFriendly: true, isFavorite: false, isUserRecipe: false },
      // 河鳜
      { id: 'r_112', name: '河流鳜鱼活饵', targetFish: '河鳜', waterType: 'river',
        tags: ['春秋', '活饵'], ingredients: ['活泥�?, '活虾', '小鱼'],
        rating: 4.7, catchRate: 85, isBeginnerFriendly: false, isFavorite: false, isUserRecipe: false },

      // ==================== 水库配方 ====================
      // 鲤鱼
      { id: 'r_201', name: '水库大鲤守钓�?, targetFish: '鲤鱼', waterType: 'reservoir',
        tags: ['秋季', '守大�?], ingredients: ['发酵玉米', '红薯', '药酒'],
        rating: 4.9, catchRate: 98, isBeginnerFriendly: false, isFavorite: true, isUserRecipe: false },
      // 草鱼
      { id: 'r_202', name: '水库草鱼浮钓�?, targetFish: '草鱼', waterType: 'reservoir',
        tags: ['夏季', '浮钓'], ingredients: ['嫩玉�?, '青草', '麦麸'],
        rating: 4.7, catchRate: 90, isBeginnerFriendly: true, isFavorite: false, isUserRecipe: false },
      // 鳙鱼
      { id: 'r_203', name: '水库鳙鱼浮钓�?, targetFish: '鳙鱼', waterType: 'reservoir',
        tags: ['夏季', '浮钓'], ingredients: ['藿香正气�?, '臭豆腐汁', '轻麸'],
        rating: 4.6, catchRate: 88, isBeginnerFriendly: false, isFavorite: false, isUserRecipe: false },
      // 鲢鱼
      { id: 'r_204', name: '水库鲢鱼手竿�?, targetFish: '鲢鱼', waterType: 'reservoir',
        tags: ['夏季', '浮钓'], ingredients: ['果酸', '白醋', '雪花�?],
        rating: 4.5, catchRate: 85, isBeginnerFriendly: true, isFavorite: false, isUserRecipe: false },
      // 青鱼
      { id: 'r_205', name: '水库青鱼螺蛳�?, targetFish: '青鱼', waterType: 'reservoir',
        tags: ['四季', '底钓'], ingredients: ['田螺', '螺蛳�?, '蚌肉�?],
        rating: 4.8, catchRate: 92, isBeginnerFriendly: false, isFavorite: false, isUserRecipe: false },
      // 鳜鱼
      { id: 'r_206', name: '水库鳜鱼活饵', targetFish: '鳜鱼', waterType: 'reservoir',
        tags: ['春秋', '活饵'], ingredients: ['活泥�?, '活虾', '小鱼'],
        rating: 4.9, catchRate: 95, isBeginnerFriendly: false, isFavorite: true, isUserRecipe: false },
      // 武昌�?
      { id: 'r_207', name: '水库武昌鱼素�?, targetFish: '武昌�?, waterType: 'reservoir',
        tags: ['春夏', '中层'], ingredients: ['麸皮', '玉米�?, '蜂蜜'],
        rating: 4.5, catchRate: 82, isBeginnerFriendly: true, isFavorite: false, isUserRecipe: false },
      // 巨鲤
      { id: 'r_208', name: '水库巨鲤重窝�?, targetFish: '巨鲤', waterType: 'reservoir',
        tags: ['春秋', '守大�?], ingredients: ['发酵玉米', '红薯', '药酒'],
        rating: 4.8, catchRate: 90, isBeginnerFriendly: false, isFavorite: false, isUserRecipe: false },
      // 黄尾�?
      { id: 'r_209', name: '水库黄尾鲴饵', targetFish: '黄尾�?, waterType: 'reservoir',
        tags: ['春夏', '底钓'], ingredients: ['混合颗粒', '麸皮', '蚯蚓�?],
        rating: 4.4, catchRate: 78, isBeginnerFriendly: true, isFavorite: false, isUserRecipe: false },
      // 鲮鱼
      { id: 'r_210', name: '南方鲮鱼专用�?, targetFish: '鲮鱼', waterType: 'reservoir',
        tags: ['夏秋', '底钓'], ingredients: ['花生�?, '麸皮', '玉米�?],
        rating: 4.6, catchRate: 85, isBeginnerFriendly: true, isFavorite: false, isUserRecipe: false },
      // 大口黑鲈
      { id: 'r_211', name: '水库黑鲈路亚�?, targetFish: '大口黑鲈', waterType: 'reservoir',
        tags: ['春夏�?, '路亚'], ingredients: ['软虫', '活虾', '小鱼'],
        rating: 4.8, catchRate: 88, isBeginnerFriendly: false, isFavorite: false, isUserRecipe: false },
      // 翘嘴
      { id: 'r_212', name: '水库翘嘴路亚�?, targetFish: '翘嘴', waterType: 'reservoir',
        tags: ['夏秋', '路亚'], ingredients: ['亮片', '活虾', '小鱼'],
        rating: 4.7, catchRate: 85, isBeginnerFriendly: false, isFavorite: false, isUserRecipe: false },

      // ==================== 湖泊配方 ====================
      // 鲫鱼
      { id: 'r_301', name: '湖泊鲫鱼传统�?, targetFish: '鲫鱼', waterType: 'lake',
        tags: ['四季', '传统�?], ingredients: ['酒米', '蚯蚓', '红虫'],
        rating: 4.7, catchRate: 90, isBeginnerFriendly: true, isFavorite: true, isUserRecipe: false },
      // 鲤鱼
      { id: 'r_302', name: '湖泊鲤鱼爆炸�?, targetFish: '鲤鱼', waterType: 'lake',
        tags: ['夏秋', '海竿'], ingredients: ['糠饼', '玉米', '麦粒'],
        rating: 4.8, catchRate: 92, isBeginnerFriendly: false, isFavorite: false, isUserRecipe: false },
      // 草鱼
      { id: 'r_303', name: '湖泊草鱼浮钓�?, targetFish: '草鱼', waterType: 'lake',
        tags: ['夏季', '浮钓'], ingredients: ['嫩草', '芦苇�?, '玉米�?],
        rating: 4.6, catchRate: 85, isBeginnerFriendly: true, isFavorite: false, isUserRecipe: false },
      // 鳜鱼
      { id: 'r_304', name: '湖泊鳜鱼活饵', targetFish: '鳜鱼', waterType: 'lake',
        tags: ['夏秋', '活饵'], ingredients: ['活泥�?, '活虾', '小鱼'],
        rating: 4.9, catchRate: 95, isBeginnerFriendly: false, isFavorite: true, isUserRecipe: false },
      // 青鱼
      { id: 'r_305', name: '湖泊青鱼螺蛳�?, targetFish: '青鱼', waterType: 'lake',
        tags: ['夏秋', '底钓'], ingredients: ['田螺', '螺蛳�?, '蚌肉'],
        rating: 4.8, catchRate: 90, isBeginnerFriendly: false, isFavorite: false, isUserRecipe: false },
      // 黑鱼
      { id: 'r_306', name: '湖泊黑鱼雷蛙', targetFish: '黑鱼', waterType: 'lake',
        tags: ['夏季', '路亚'], ingredients: ['雷蛙', '软虫', '泥鳅'],
        rating: 4.7, catchRate: 85, isBeginnerFriendly: false, isFavorite: false, isUserRecipe: false },
      // 狗鱼
      { id: 'r_307', name: '北方狗鱼�?, targetFish: '狗鱼', waterType: 'lake',
        tags: ['春秋�?, '路亚'], ingredients: ['大型软虫', '小鱼', '亮片'],
        rating: 4.6, catchRate: 80, isBeginnerFriendly: false, isFavorite: false, isUserRecipe: false },
      // 鲈鱼
      { id: 'r_308', name: '湖钓鲈鱼�?, targetFish: '鲈鱼', waterType: 'lake',
        tags: ['春秋', '活饵'], ingredients: ['活虾', '小鱼', '蚯蚓'],
        rating: 4.5, catchRate: 82, isBeginnerFriendly: false, isFavorite: false, isUserRecipe: false },
      // 银鱼
      { id: 'r_309', name: '银鱼专用�?, targetFish: '银鱼', waterType: 'lake',
        tags: ['春秋', '细线'], ingredients: ['红虫', '小虫'],
        rating: 4.2, catchRate: 70, isBeginnerFriendly: false, isFavorite: false, isUserRecipe: false },
      // 红鳍�?
      { id: 'r_310', name: '红鳍鲌路亚饵', targetFish: '红鳍�?, waterType: 'lake',
        tags: ['夏秋', '路亚'], ingredients: ['亮片', '活虾', '小鱼'],
        rating: 4.5, catchRate: 80, isBeginnerFriendly: false, isFavorite: false, isUserRecipe: false },
      // 甲鱼
      { id: 'r_311', name: '湖泊甲鱼�?, targetFish: '甲鱼', waterType: 'lake',
        tags: ['夜钓', '底钓'], ingredients: ['鸡肝', '猪肝', '蚯蚓'],
        rating: 4.4, catchRate: 75, isBeginnerFriendly: false, isFavorite: false, isUserRecipe: false },
      // 黄鳝
      { id: 'r_312', name: '湖泊黄鳝�?, targetFish: '黄鳝', waterType: 'lake',
        tags: ['夜钓', '洞穴'], ingredients: ['蚯蚓', '小鱼'],
        rating: 4.3, catchRate: 72, isBeginnerFriendly: false, isFavorite: false, isUserRecipe: false },
      // 河蟹
      { id: 'r_313', name: '秋季河蟹�?, targetFish: '河蟹', waterType: 'lake',
        tags: ['秋季', '蟹笼'], ingredients: ['鸡肝', '鱼肉', '玉米'],
        rating: 4.5, catchRate: 85, isBeginnerFriendly: true, isFavorite: false, isUserRecipe: false },
      // 河虾
      { id: 'r_314', name: '湖泊河虾�?, targetFish: '河虾', waterType: 'lake',
        tags: ['夏秋', '虾笼'], ingredients: ['蚯蚓', '红虫', '面粉'],
        rating: 4.2, catchRate: 75, isBeginnerFriendly: true, isFavorite: false, isUserRecipe: false },
      // 鳊鱼
      { id: 'r_315', name: '湖泊鳊鱼素饵', targetFish: '鳊鱼', waterType: 'lake',
        tags: ['春夏', '浮钓'], ingredients: ['麸皮', '玉米�?, '拉丝�?],
        rating: 4.5, catchRate: 82, isBeginnerFriendly: true, isFavorite: false, isUserRecipe: false },
      // 武昌�?
      { id: 'r_318', name: '湖泊武昌鱼素�?, targetFish: '武昌�?, waterType: 'lake',
        tags: ['春夏', '中层'], ingredients: ['麸皮', '玉米�?, '蜂蜜'],
        rating: 4.5, catchRate: 82, isBeginnerFriendly: true, isFavorite: false, isUserRecipe: false },
      // 大口黑鲈
      { id: 'r_316', name: '湖泊黑鲈路亚�?, targetFish: '大口黑鲈', waterType: 'lake',
        tags: ['春夏�?, '路亚'], ingredients: ['软虫', '活虾', '小鱼'],
        rating: 4.8, catchRate: 88, isBeginnerFriendly: false, isFavorite: false, isUserRecipe: false },
      // 翘嘴
      { id: 'r_317', name: '湖泊翘嘴路亚�?, targetFish: '翘嘴', waterType: 'lake',
        tags: ['夏秋', '路亚'], ingredients: ['亮片', '活虾', '小鱼'],
        rating: 4.7, catchRate: 85, isBeginnerFriendly: false, isFavorite: false, isUserRecipe: false }
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

      const card: RecipeCard = {
        id: ur.id,
        name: ur.name,
        targetFish: targetFishName,
        waterType: waterType,
        tags: [seasonTag, '自定义'],
        ingredients: ingredientNames,
        rating: 4.5,
        catchRate: 80,
        isBeginnerFriendly: false,
        isFavorite: true,
        isUserRecipe: true
      };

      this.allRecipes.unshift(card);  // 用户配方放在最前面
    }
  }

  // 筛选配方
  private filterRecipes(): void {
    const waterType = this.waterTabs[this.currentWaterTab].type;
    const fishFilter = this.selectedFishFilter;

    this.recipes = this.allRecipes.filter((recipe: RecipeCard) => {
      // 水域筛�?
      if (recipe.waterType !== waterType) return false;
      // 鱼种筛�?
      if (fishFilter !== 'all') {
        const targetFishName = this.getFishName(fishFilter);
        if (!recipe.targetFish.includes(targetFishName)) return false;
      }
      return true;
    });
  }

  build() {
    Column() {
      // 顶部标题�?
      this.HeaderBar()

      // 水域Tab
      this.WaterTabBar()

      // 内容区域
      Row() {
        // 左侧鱼种筛�?
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
      Text('鱼饵配方�?)
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

          // 选中指示�?
          Row()
            .width(24)
            .height(3)
            .backgroundColor(this.currentWaterTab === index ? ThemeColors.PRIMARY : Color.Transparent)
            .borderRadius(2)
        }
        .onClick(() => {
          this.currentWaterTab = index;
          this.selectedFishFilter = 'all';  // 切换水域时重置鱼种筛�?
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
          Text(`�?${this.recipes.length} 个配方`)
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

      // 配方名称和收�?
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
      Button('查看详情 �?)
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
