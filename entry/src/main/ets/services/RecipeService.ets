/**
 * 饵知道 - 配方服务
 * 配方生成、查询、管理
 */
import { StorageService } from './StorageService';
import { AppConstants } from '../common/constants/AppConstants';

// 配方材料接口
export interface Ingredient {
  name: string;
  amount: string;
  unit: string;
}

// 配方接口
export interface Recipe {
  id: string;
  name: string;
  targetFish: string[];
  waterTypes: string[];
  seasons: string[];
  difficulty: string;
  prepTime: string;
  ingredients: Ingredient[];
  steps: string[];
  tips: string[];
  rating: number;
  usageCount: number;
  isGenerated: boolean;
  createTime: number;
}

// 生成配方参数
export interface GenerateParams {
  targetFish: string;
  waterType: string;
  season: string;
  weather: string;
  temperature: number;
}

// 配方库数据
const RECIPE_DATABASE: Recipe[] = [
  // ==================== 池塘鱼种配方 ====================
  // 鲫鱼配方
  {
    id: 'recipe_crucian_001',
    name: '经典野钓鲫鱼饵',
    targetFish: ['鲫鱼'],
    waterTypes: ['池塘', '河流', '湖泊'],
    seasons: ['春季', '秋季'],
    difficulty: '简单',
    prepTime: '10分钟',
    ingredients: [
      { name: '红虫粉', amount: '100', unit: 'g' },
      { name: '拉丝粉', amount: '30', unit: 'g' },
      { name: '麸皮', amount: '50', unit: 'g' },
      { name: '蜂蜜', amount: '10', unit: 'ml' }
    ],
    steps: ['红虫粉与拉丝粉混合', '加入麸皮搅拌均匀', '加入蜂蜜和适量水', '揉成软硬适中的饵团'],
    tips: ['春秋季鲫鱼偏爱腥香', '饵料状态要软糯'],
    rating: 4.8, usageCount: 2356, isGenerated: false, createTime: Date.now()
  },
  {
    id: 'recipe_crucian_002',
    name: '冬季红虫拉饵',
    targetFish: ['鲫鱼'],
    waterTypes: ['池塘', '河流'],
    seasons: ['冬季'],
    difficulty: '中等',
    prepTime: '15分钟',
    ingredients: [
      { name: '红虫粉', amount: '150', unit: 'g' },
      { name: '虾粉', amount: '30', unit: 'g' },
      { name: '拉丝粉', amount: '40', unit: 'g' },
      { name: '蚯蚓膏', amount: '5', unit: 'ml' }
    ],
    steps: ['红虫粉与虾粉混合', '加入拉丝粉', '滴入蚯蚓膏', '加冷水开饵，静置5分钟'],
    tips: ['冬季用腥饵效果最佳', '饵料要轻软，方便鱼吸入'],
    rating: 4.7, usageCount: 1892, isGenerated: false, createTime: Date.now()
  },

  // 鲤鱼配方
  {
    id: 'recipe_carp_001',
    name: '经典玉米酒香饵',
    targetFish: ['鲤鱼'],
    waterTypes: ['池塘', '水库', '湖泊'],
    seasons: ['春季', '秋季'],
    difficulty: '简单',
    prepTime: '15分钟',
    ingredients: [
      { name: '玉米粉', amount: '300', unit: 'g' },
      { name: '面粉', amount: '100', unit: 'g' },
      { name: '红薯粉', amount: '50', unit: 'g' },
      { name: '蜂蜜', amount: '20', unit: 'ml' },
      { name: '药酒', amount: '10', unit: 'ml' }
    ],
    steps: ['玉米粉、面粉、红薯粉混合', '加入蜂蜜和药酒', '加温水搅拌成糊', '揉成面团静置30分钟'],
    tips: ['药酒选用丁香、山奈泡制的效果好', '面团不宜太硬'],
    rating: 4.9, usageCount: 3256, isGenerated: false, createTime: Date.now()
  },
  {
    id: 'recipe_carp_002',
    name: '夏季清淡鲤鱼饵',
    targetFish: ['鲤鱼'],
    waterTypes: ['池塘', '水库'],
    seasons: ['夏季'],
    difficulty: '简单',
    prepTime: '10分钟',
    ingredients: [
      { name: '玉米粉', amount: '200', unit: 'g' },
      { name: '麸皮', amount: '100', unit: 'g' },
      { name: '果酸', amount: '5', unit: 'ml' },
      { name: '白糖', amount: '15', unit: 'g' }
    ],
    steps: ['玉米粉与麸皮混合', '加入果酸和白糖', '加水调成合适状态'],
    tips: ['夏季高温鲤鱼喜清淡', '可适当增加果酸用量'],
    rating: 4.5, usageCount: 1654, isGenerated: false, createTime: Date.now()
  },

  // 草鱼配方
  {
    id: 'recipe_grass_001',
    name: '夏季嫩草饵',
    targetFish: ['草鱼'],
    waterTypes: ['池塘', '水库', '湖泊'],
    seasons: ['夏季'],
    difficulty: '简单',
    prepTime: '5分钟',
    ingredients: [
      { name: '嫩草', amount: '适量', unit: '' },
      { name: '芦苇芯', amount: '3-5', unit: '根' },
      { name: '玉米粒', amount: '50', unit: 'g' }
    ],
    steps: ['采摘新鲜嫩草和芦苇芯', '玉米粒打窝诱鱼', '嫩草或芦苇芯直接挂钩'],
    tips: ['草鱼夏季最爱新鲜嫩草', '选择水边生长的草效果更好'],
    rating: 4.8, usageCount: 2145, isGenerated: false, createTime: Date.now()
  },
  {
    id: 'recipe_grass_002',
    name: '发酵玉米钓草鱼',
    targetFish: ['草鱼'],
    waterTypes: ['水库', '湖泊'],
    seasons: ['夏季', '秋季'],
    difficulty: '中等',
    prepTime: '提前3天',
    ingredients: [
      { name: '发酵玉米', amount: '500', unit: 'g' },
      { name: '麦粒', amount: '200', unit: 'g' },
      { name: '玉米粉', amount: '100', unit: 'g' },
      { name: '蜂蜜', amount: '20', unit: 'ml' }
    ],
    steps: ['玉米粒提前泡发酵3天', '麦粒煮熟备用', '发酵玉米直接挂钩', '玉米粉加蜂蜜做窝料'],
    tips: ['发酵玉米酒香味浓，大草鱼最爱', '打重窝守钓效果好'],
    rating: 4.7, usageCount: 1876, isGenerated: false, createTime: Date.now()
  },

  // 鳙鱼配方
  {
    id: 'recipe_bighead_001',
    name: '夏季酸臭鳙鱼饵',
    targetFish: ['鳙鱼'],
    waterTypes: ['池塘', '水库'],
    seasons: ['夏季'],
    difficulty: '中等',
    prepTime: '20分钟',
    ingredients: [
      { name: '鲢鳙颗粒', amount: '200', unit: 'g' },
      { name: '臭豆腐汁', amount: '30', unit: 'ml' },
      { name: '蒜粉', amount: '10', unit: 'g' },
      { name: '雪花粉', amount: '50', unit: 'g' },
      { name: '藿香正气水', amount: '10', unit: 'ml' }
    ],
    steps: ['鲢鳙颗粒用水泡开', '加入臭豆腐汁和藿香正气水', '加入蒜粉搅拌', '雪花粉调节雾化'],
    tips: ['鳙鱼喜酸臭味，味道越重越好', '浮钓效果最佳'],
    rating: 4.6, usageCount: 1432, isGenerated: false, createTime: Date.now()
  },

  // 鲢鱼配方
  {
    id: 'recipe_silver_001',
    name: '夏季酸香鲢鱼饵',
    targetFish: ['鲢鱼'],
    waterTypes: ['池塘', '水库'],
    seasons: ['夏季'],
    difficulty: '中等',
    prepTime: '15分钟',
    ingredients: [
      { name: '鲢鳙颗粒', amount: '200', unit: 'g' },
      { name: '果酸', amount: '10', unit: 'ml' },
      { name: '白醋', amount: '15', unit: 'ml' },
      { name: '雪花粉', amount: '80', unit: 'g' },
      { name: '轻麸', amount: '30', unit: 'g' }
    ],
    steps: ['鲢鳙颗粒加水泡软', '加入果酸和白醋', '雪花粉和轻麸调节状态', '搅拌均匀即可'],
    tips: ['鲢鱼喜酸味，雾化要好', '高温天气效果最佳'],
    rating: 4.5, usageCount: 1287, isGenerated: false, createTime: Date.now()
  },

  // 罗非鱼配方
  {
    id: 'recipe_tilapia_001',
    name: '南方罗非专用饵',
    targetFish: ['罗非鱼'],
    waterTypes: ['池塘'],
    seasons: ['夏季', '秋季'],
    difficulty: '简单',
    prepTime: '10分钟',
    ingredients: [
      { name: '罗非颗粒', amount: '200', unit: 'g' },
      { name: '虾粉', amount: '50', unit: 'g' },
      { name: '拉丝粉', amount: '30', unit: 'g' },
      { name: '蚯蚓膏', amount: '5', unit: 'ml' }
    ],
    steps: ['罗非颗粒加水泡软', '加入虾粉增腥', '拉丝粉调节状态', '滴入蚯蚓膏增加诱鱼效果'],
    tips: ['罗非鱼喜腥味', '夏季高温活性最强'],
    rating: 4.4, usageCount: 987, isGenerated: false, createTime: Date.now()
  },

  // 斑点叉尾鮰配方
  {
    id: 'recipe_channel_catfish_001',
    name: '黑坑叉尾专用饵',
    targetFish: ['斑点叉尾鮰'],
    waterTypes: ['池塘'],
    seasons: ['夏季', '秋季'],
    difficulty: '简单',
    prepTime: '10分钟',
    ingredients: [
      { name: '鲶鱼颗粒', amount: '200', unit: 'g' },
      { name: '鸡肝粉', amount: '50', unit: 'g' },
      { name: '虾粉', amount: '30', unit: 'g' },
      { name: '拉丝粉', amount: '20', unit: 'g' }
    ],
    steps: ['鲶鱼颗粒泡软', '加入鸡肝粉和虾粉', '拉丝粉调节状态', '搅拌均匀即可'],
    tips: ['叉尾鮰喜重腥味', '夜钓效果更好'],
    rating: 4.5, usageCount: 1123, isGenerated: false, createTime: Date.now()
  },

  // ==================== 河流鱼种配方 ====================
  // 鲶鱼配方
  {
    id: 'recipe_catfish_001',
    name: '夜钓鲶鱼重腥饵',
    targetFish: ['鲶鱼'],
    waterTypes: ['河流', '池塘'],
    seasons: ['夏季', '秋季'],
    difficulty: '简单',
    prepTime: '10分钟',
    ingredients: [
      { name: '鸡肝粉', amount: '100', unit: 'g' },
      { name: '蚯蚓粉', amount: '50', unit: 'g' },
      { name: '血粉', amount: '30', unit: 'g' },
      { name: '面粉', amount: '50', unit: 'g' }
    ],
    steps: ['鸡肝粉与蚯蚓粉混合', '加入血粉增腥', '面粉调节粘度', '加水揉成团'],
    tips: ['鲶鱼喜极腥味，越腥越好', '夜间出钓效果最佳'],
    rating: 4.7, usageCount: 1654, isGenerated: false, createTime: Date.now()
  },
  {
    id: 'recipe_catfish_002',
    name: '活饵钓鲶鱼',
    targetFish: ['鲶鱼'],
    waterTypes: ['河流'],
    seasons: ['夏季', '秋季'],
    difficulty: '简单',
    prepTime: '即用',
    ingredients: [
      { name: '蚯蚓', amount: '若干', unit: '条' },
      { name: '活泥鳅', amount: '3-5', unit: '条' },
      { name: '鸡肝', amount: '100', unit: 'g' }
    ],
    steps: ['蚯蚓整条挂钩', '泥鳅钩背部', '鸡肝切块挂钩'],
    tips: ['活饵效果最好', '选择大号鱼钩'],
    rating: 4.8, usageCount: 2134, isGenerated: false, createTime: Date.now()
  },

  // 黄颡鱼配方
  {
    id: 'recipe_yellow_catfish_001',
    name: '野钓黄颡鱼饵',
    targetFish: ['黄颡鱼'],
    waterTypes: ['河流'],
    seasons: ['夏季', '秋季'],
    difficulty: '简单',
    prepTime: '即用',
    ingredients: [
      { name: '蚯蚓', amount: '若干', unit: '条' },
      { name: '红虫', amount: '适量', unit: '' },
      { name: '鸡肝', amount: '50', unit: 'g' }
    ],
    steps: ['蚯蚓掐段挂钩', '红虫用红虫夹', '鸡肝切小块'],
    tips: ['黄颡鱼喜腥饵', '傍晚和夜间出钓最佳'],
    rating: 4.6, usageCount: 1432, isGenerated: false, createTime: Date.now()
  },

  // 鳊鱼配方
  {
    id: 'recipe_bream_001',
    name: '清香鳊鱼饵',
    targetFish: ['鳊鱼'],
    waterTypes: ['河流', '湖泊'],
    seasons: ['春季', '夏季', '秋季'],
    difficulty: '简单',
    prepTime: '10分钟',
    ingredients: [
      { name: '麸皮', amount: '150', unit: 'g' },
      { name: '玉米粉', amount: '100', unit: 'g' },
      { name: '面粉', amount: '50', unit: 'g' },
      { name: '蜂蜜', amount: '15', unit: 'ml' }
    ],
    steps: ['麸皮与玉米粉混合', '加入面粉调节粘度', '蜂蜜增甜', '加水调成合适状态'],
    tips: ['鳊鱼喜素饵', '钓中上层效果好'],
    rating: 4.5, usageCount: 1234, isGenerated: false, createTime: Date.now()
  },

  // 翘嘴配方
  {
    id: 'recipe_culter_001',
    name: '路亚翘嘴饵',
    targetFish: ['翘嘴'],
    waterTypes: ['河流', '水库', '湖泊'],
    seasons: ['夏季', '秋季'],
    difficulty: '中等',
    prepTime: '即用',
    ingredients: [
      { name: '活虾', amount: '若干', unit: '只' },
      { name: '小鱼', amount: '若干', unit: '条' },
      { name: '亮片', amount: '1', unit: '个' }
    ],
    steps: ['活虾钩尾部', '小鱼钩背部', '亮片抛投收线'],
    tips: ['翘嘴是掠食性鱼类', '晨昏时段最活跃', '路亚效果极佳'],
    rating: 4.7, usageCount: 1876, isGenerated: false, createTime: Date.now()
  },

  // 马口配方
  {
    id: 'recipe_topmouth_001',
    name: '溪流马口饵',
    targetFish: ['马口'],
    waterTypes: ['河流'],
    seasons: ['春季', '夏季', '秋季'],
    difficulty: '简单',
    prepTime: '即用',
    ingredients: [
      { name: '蚂蚱', amount: '若干', unit: '只' },
      { name: '蟋蟀', amount: '若干', unit: '只' },
      { name: '亮片', amount: '1', unit: '个' }
    ],
    steps: ['蚂蚱或蟋蟀直接挂钩', '亮片抛投', '溪流中找急流处'],
    tips: ['马口喜欢昆虫', '溪流路亚效果好', '选择小号亮片'],
    rating: 4.6, usageCount: 1123, isGenerated: false, createTime: Date.now()
  },

  // 鲃鱼配方
  {
    id: 'recipe_barbel_001',
    name: '急流鲃鱼饵',
    targetFish: ['鲃鱼'],
    waterTypes: ['河流'],
    seasons: ['春季', '夏季', '秋季'],
    difficulty: '简单',
    prepTime: '即用',
    ingredients: [
      { name: '蚯蚓', amount: '若干', unit: '条' },
      { name: '活虾', amount: '若干', unit: '只' },
      { name: '螺蛳粉', amount: '30', unit: 'g' }
    ],
    steps: ['蚯蚓整条挂钩', '活虾钩尾', '螺蛳粉可做窝料'],
    tips: ['鲃鱼喜急流', '在石缝处下钩', '力量大注意遛鱼'],
    rating: 4.4, usageCount: 876, isGenerated: false, createTime: Date.now()
  },

  // 赤眼鳟配方
  {
    id: 'recipe_chub_001',
    name: '河钓赤眼鳟饵',
    targetFish: ['赤眼鳟'],
    waterTypes: ['河流'],
    seasons: ['春季', '夏季', '秋季'],
    difficulty: '简单',
    prepTime: '10分钟',
    ingredients: [
      { name: '蚯蚓', amount: '若干', unit: '条' },
      { name: '玉米粉', amount: '100', unit: 'g' },
      { name: '面粉', amount: '50', unit: 'g' },
      { name: '蜂蜜', amount: '10', unit: 'ml' }
    ],
    steps: ['玉米粉面粉混合', '加蜂蜜和水揉成团', '蚯蚓也可直接挂钩'],
    tips: ['赤眼鳟杂食性', '素饵荤饵都可以'],
    rating: 4.3, usageCount: 765, isGenerated: false, createTime: Date.now()
  },

  // 泥鳅配方
  {
    id: 'recipe_loach_001',
    name: '钓泥鳅专用饵',
    targetFish: ['泥鳅'],
    waterTypes: ['河流', '池塘'],
    seasons: ['夏季', '秋季'],
    difficulty: '简单',
    prepTime: '即用',
    ingredients: [
      { name: '蚯蚓', amount: '若干', unit: '条' },
      { name: '红虫', amount: '适量', unit: '' }
    ],
    steps: ['蚯蚓掐小段挂钩', '红虫用细钩', '选择泥底水域'],
    tips: ['泥鳅喜泥底', '用小钩细线', '夜间效果好'],
    rating: 4.2, usageCount: 543, isGenerated: false, createTime: Date.now()
  },

  // 河鳜配方
  {
    id: 'recipe_mandarin_river_001',
    name: '活饵钓河鳜',
    targetFish: ['河鳜'],
    waterTypes: ['河流'],
    seasons: ['春季', '秋季'],
    difficulty: '中等',
    prepTime: '即用',
    ingredients: [
      { name: '活泥鳅', amount: '若干', unit: '条' },
      { name: '活虾', amount: '若干', unit: '只' },
      { name: '小鱼', amount: '若干', unit: '条' }
    ],
    steps: ['泥鳅钩背部', '活虾钩尾', '小鱼钩背鳍下方'],
    tips: ['鳜鱼只吃活饵', '选择清澈水域', '晨昏时段最佳'],
    rating: 4.7, usageCount: 1234, isGenerated: false, createTime: Date.now()
  },

  // ==================== 水库鱼种配方 ====================
  // 青鱼配方
  {
    id: 'recipe_black_carp_001',
    name: '螺蛳钓青鱼',
    targetFish: ['青鱼'],
    waterTypes: ['水库', '湖泊'],
    seasons: ['夏季', '秋季'],
    difficulty: '中等',
    prepTime: '30分钟',
    ingredients: [
      { name: '田螺', amount: '500', unit: 'g' },
      { name: '螺蛳粉', amount: '200', unit: 'g' },
      { name: '蚌肉粉', amount: '100', unit: 'g' },
      { name: '玉米粉', amount: '100', unit: 'g' }
    ],
    steps: ['田螺砸碎做窝料', '螺蛳粉蚌肉粉混合做饵', '玉米粉调节状态', '整颗螺蛳也可挂钩'],
    tips: ['青鱼最爱螺蛳', '打重窝守钓', '需要耐心等待'],
    rating: 4.8, usageCount: 1567, isGenerated: false, createTime: Date.now()
  },

  // 鳜鱼配方
  {
    id: 'recipe_mandarin_001',
    name: '活饵钓鳜鱼',
    targetFish: ['鳜鱼'],
    waterTypes: ['水库', '湖泊'],
    seasons: ['春季', '秋季'],
    difficulty: '中等',
    prepTime: '即用',
    ingredients: [
      { name: '活泥鳅', amount: '若干', unit: '条' },
      { name: '活虾', amount: '若干', unit: '只' },
      { name: '小鱼', amount: '若干', unit: '条' }
    ],
    steps: ['泥鳅钩背部保持活性', '活虾钩尾部', '小鱼钩背鳍下方'],
    tips: ['鳜鱼只认活饵', '选择水质清澈处', '晨昏时段出钓'],
    rating: 4.9, usageCount: 2345, isGenerated: false, createTime: Date.now()
  },

  // 武昌鱼配方
  {
    id: 'recipe_wuchang_001',
    name: '清香武昌鱼饵',
    targetFish: ['武昌鱼'],
    waterTypes: ['水库', '湖泊'],
    seasons: ['春季', '夏季', '秋季'],
    difficulty: '简单',
    prepTime: '10分钟',
    ingredients: [
      { name: '麸皮', amount: '150', unit: 'g' },
      { name: '玉米粉', amount: '100', unit: 'g' },
      { name: '面粉', amount: '50', unit: 'g' },
      { name: '蜂蜜', amount: '15', unit: 'ml' }
    ],
    steps: ['麸皮玉米粉混合', '面粉调节粘度', '蜂蜜增甜', '加水调成软饵'],
    tips: ['武昌鱼喜素饵', '钓中层效果好'],
    rating: 4.5, usageCount: 1123, isGenerated: false, createTime: Date.now()
  },

  // 巨鲤配方
  {
    id: 'recipe_giant_carp_001',
    name: '水库巨鲤重窝饵',
    targetFish: ['巨鲤'],
    waterTypes: ['水库'],
    seasons: ['春季', '秋季'],
    difficulty: '困难',
    prepTime: '提前1天',
    ingredients: [
      { name: '发酵玉米', amount: '2000', unit: 'g' },
      { name: '红薯', amount: '500', unit: 'g' },
      { name: '玉米粉', amount: '500', unit: 'g' },
      { name: '药酒', amount: '50', unit: 'ml' },
      { name: '蜂蜜', amount: '50', unit: 'ml' }
    ],
    steps: ['发酵玉米提前泡制', '红薯蒸熟捣泥', '玉米粉加药酒蜂蜜', '混合做窝料和钓饵'],
    tips: ['钓巨鲤需要重窝', '提前打窝养窝', '耐心守钓是关键'],
    rating: 4.8, usageCount: 876, isGenerated: false, createTime: Date.now()
  },

  // 黄尾鲴配方
  {
    id: 'recipe_yellow_cheek_001',
    name: '水库黄尾鲴饵',
    targetFish: ['黄尾鲴'],
    waterTypes: ['水库'],
    seasons: ['春季', '夏季', '秋季'],
    difficulty: '简单',
    prepTime: '10分钟',
    ingredients: [
      { name: '混合颗粒', amount: '150', unit: 'g' },
      { name: '麸皮', amount: '50', unit: 'g' },
      { name: '拉丝粉', amount: '30', unit: 'g' },
      { name: '蚯蚓粉', amount: '20', unit: 'g' }
    ],
    steps: ['颗粒泡软', '加入麸皮和蚯蚓粉', '拉丝粉调节状态'],
    tips: ['黄尾鲴喜刮食藻类', '选择有石头的钓点'],
    rating: 4.4, usageCount: 765, isGenerated: false, createTime: Date.now()
  },

  // 鲮鱼配方
  {
    id: 'recipe_catla_001',
    name: '南方鲮鱼专用饵',
    targetFish: ['鲮鱼'],
    waterTypes: ['水库'],
    seasons: ['夏季', '秋季'],
    difficulty: '简单',
    prepTime: '10分钟',
    ingredients: [
      { name: '花生粉', amount: '150', unit: 'g' },
      { name: '麸皮', amount: '100', unit: 'g' },
      { name: '玉米粉', amount: '50', unit: 'g' },
      { name: '拉丝粉', amount: '30', unit: 'g' }
    ],
    steps: ['花生粉与麸皮混合', '加入玉米粉', '拉丝粉调节状态', '加水开饵'],
    tips: ['鲮鱼最爱花生麸', '南方水库常见鱼种'],
    rating: 4.6, usageCount: 1234, isGenerated: false, createTime: Date.now()
  },

  // 大口黑鲈配方
  {
    id: 'recipe_bass_001',
    name: '路亚黑鲈饵',
    targetFish: ['大口黑鲈'],
    waterTypes: ['水库', '湖泊'],
    seasons: ['春季', '夏季', '秋季'],
    difficulty: '中等',
    prepTime: '即用',
    ingredients: [
      { name: '软虫', amount: '若干', unit: '个' },
      { name: '活虾', amount: '若干', unit: '只' },
      { name: '小鱼', amount: '若干', unit: '条' }
    ],
    steps: ['软虫德州钓组', '活虾直接挂钩', '小鱼钩背部'],
    tips: ['黑鲈是路亚热门对象鱼', '晨昏时段最活跃', '障碍物旁是好钓点'],
    rating: 4.8, usageCount: 2567, isGenerated: false, createTime: Date.now()
  },

  // ==================== 湖泊鱼种配方 ====================
  // 黑鱼配方
  {
    id: 'recipe_snakehead_001',
    name: '雷蛙钓黑鱼',
    targetFish: ['黑鱼'],
    waterTypes: ['湖泊', '池塘'],
    seasons: ['夏季', '秋季'],
    difficulty: '中等',
    prepTime: '即用',
    ingredients: [
      { name: '雷蛙', amount: '1', unit: '个' },
      { name: '活青蛙', amount: '若干', unit: '只' },
      { name: '活泥鳅', amount: '若干', unit: '条' }
    ],
    steps: ['雷蛙抛投到水草区', '青蛙钩背部', '泥鳅钩背部'],
    tips: ['黑鱼喜藏水草中', '雷蛙打黑效果极佳', '夏季最活跃'],
    rating: 4.9, usageCount: 2876, isGenerated: false, createTime: Date.now()
  },

  // 狗鱼配方
  {
    id: 'recipe_pike_001',
    name: '北方狗鱼饵',
    targetFish: ['狗鱼'],
    waterTypes: ['湖泊'],
    seasons: ['春季', '秋季', '冬季'],
    difficulty: '困难',
    prepTime: '即用',
    ingredients: [
      { name: '大型软虫', amount: '若干', unit: '个' },
      { name: '小鱼', amount: '若干', unit: '条' },
      { name: '亮片', amount: '1', unit: '个' }
    ],
    steps: ['大型软虫挂钩', '小鱼钩背部', '亮片快速收线'],
    tips: ['狗鱼是顶级掠食者', '北方湖泊特有', '冬季冰钓也可'],
    rating: 4.6, usageCount: 543, isGenerated: false, createTime: Date.now()
  },

  // 鲈鱼配方
  {
    id: 'recipe_perch_001',
    name: '湖钓鲈鱼饵',
    targetFish: ['鲈鱼'],
    waterTypes: ['湖泊'],
    seasons: ['春季', '秋季'],
    difficulty: '中等',
    prepTime: '即用',
    ingredients: [
      { name: '活虾', amount: '若干', unit: '只' },
      { name: '小鱼', amount: '若干', unit: '条' },
      { name: '蚯蚓', amount: '若干', unit: '条' }
    ],
    steps: ['活虾钩尾部', '小鱼钩背部', '蚯蚓整条挂钩'],
    tips: ['鲈鱼喜清澈水质', '活饵效果最好'],
    rating: 4.5, usageCount: 876, isGenerated: false, createTime: Date.now()
  },

  // 银鱼配方
  {
    id: 'recipe_whitebait_001',
    name: '银鱼专用饵',
    targetFish: ['银鱼'],
    waterTypes: ['湖泊'],
    seasons: ['春季', '秋季'],
    difficulty: '困难',
    prepTime: '即用',
    ingredients: [
      { name: '红虫', amount: '适量', unit: '' },
      { name: '小虫', amount: '若干', unit: '只' }
    ],
    steps: ['红虫用极细钩', '小虫直接挂钩', '用极细线组'],
    tips: ['银鱼体型极小', '需要专门钓组', '太湖特产'],
    rating: 4.2, usageCount: 234, isGenerated: false, createTime: Date.now()
  },

  // 红鳍鲌配方
  {
    id: 'recipe_redfin_001',
    name: '红鳍鲌路亚饵',
    targetFish: ['红鳍鲌'],
    waterTypes: ['湖泊', '河流'],
    seasons: ['夏季', '秋季'],
    difficulty: '中等',
    prepTime: '即用',
    ingredients: [
      { name: '亮片', amount: '1', unit: '个' },
      { name: '活虾', amount: '若干', unit: '只' },
      { name: '小鱼', amount: '若干', unit: '条' }
    ],
    steps: ['亮片抛投收线', '活虾钩尾', '小鱼钩背部'],
    tips: ['红鳍鲌攻击性强', '路亚效果好', '表层作钓'],
    rating: 4.5, usageCount: 765, isGenerated: false, createTime: Date.now()
  },

  // 甲鱼配方
  {
    id: 'recipe_turtle_001',
    name: '夜钓甲鱼饵',
    targetFish: ['甲鱼'],
    waterTypes: ['湖泊', '池塘'],
    seasons: ['夏季', '秋季'],
    difficulty: '中等',
    prepTime: '即用',
    ingredients: [
      { name: '鸡肝', amount: '200', unit: 'g' },
      { name: '猪肝粉', amount: '50', unit: 'g' },
      { name: '蚯蚓', amount: '若干', unit: '条' }
    ],
    steps: ['鸡肝切块挂钩', '猪肝粉可做窝料', '蚯蚓也可使用'],
    tips: ['甲鱼夜间活动', '喜极腥味', '需要专门钓组'],
    rating: 4.4, usageCount: 654, isGenerated: false, createTime: Date.now()
  },

  // 黄鳝配方
  {
    id: 'recipe_eel_001',
    name: '钓黄鳝专用饵',
    targetFish: ['黄鳝'],
    waterTypes: ['湖泊', '池塘', '河流'],
    seasons: ['夏季', '秋季'],
    difficulty: '中等',
    prepTime: '即用',
    ingredients: [
      { name: '蚯蚓', amount: '若干', unit: '条' },
      { name: '小鱼', amount: '若干', unit: '条' }
    ],
    steps: ['蚯蚓整条挂钩', '小鱼切段', '找洞穴下钩'],
    tips: ['黄鳝穴居', '夜间出洞觅食', '需要专门钓法'],
    rating: 4.3, usageCount: 432, isGenerated: false, createTime: Date.now()
  },

  // 河蟹配方
  {
    id: 'recipe_crab_001',
    name: '秋季钓河蟹',
    targetFish: ['河蟹'],
    waterTypes: ['湖泊'],
    seasons: ['秋季'],
    difficulty: '简单',
    prepTime: '即用',
    ingredients: [
      { name: '鸡肝', amount: '100', unit: 'g' },
      { name: '鱼肉', amount: '100', unit: 'g' },
      { name: '玉米粒', amount: '50', unit: 'g' }
    ],
    steps: ['鸡肝切块放蟹笼', '鱼肉做诱饵', '玉米粒辅助'],
    tips: ['秋季河蟹最肥', '夜间活动', '用蟹笼效果好'],
    rating: 4.5, usageCount: 876, isGenerated: false, createTime: Date.now()
  },

  // 河虾配方
  {
    id: 'recipe_shrimp_001',
    name: '钓河虾饵料',
    targetFish: ['河虾'],
    waterTypes: ['湖泊', '河流'],
    seasons: ['夏季', '秋季'],
    difficulty: '简单',
    prepTime: '即用',
    ingredients: [
      { name: '蚯蚓', amount: '若干', unit: '条' },
      { name: '红虫', amount: '适量', unit: '' },
      { name: '面粉团', amount: '少量', unit: '' }
    ],
    steps: ['蚯蚓掐小段', '红虫直接用', '面粉团做窝'],
    tips: ['河虾夜间活动', '用虾笼效果好', '可作为钓饵'],
    rating: 4.2, usageCount: 543, isGenerated: false, createTime: Date.now()
  }
];


export class RecipeService {
  private static instance: RecipeService;
  private recipes: Recipe[] = RECIPE_DATABASE;
  private favorites: string[] = [];

  private constructor() {}

  public static getInstance(): RecipeService {
    if (!RecipeService.instance) {
      RecipeService.instance = new RecipeService();
    }
    return RecipeService.instance;
  }

  // 获取所有配方
  public getAllRecipes(): Recipe[] {
    return this.recipes;
  }

  // 根据水域类型筛选
  public getRecipesByWaterType(waterType: string): Recipe[] {
    if (waterType === 'all') {
      return this.recipes;
    }
    return this.recipes.filter((r: Recipe) => r.waterTypes.includes(waterType));
  }

  // 根据目标鱼种筛选
  public getRecipesByFish(fishName: string): Recipe[] {
    if (fishName === 'all') {
      return this.recipes;
    }
    return this.recipes.filter((r: Recipe) => r.targetFish.includes(fishName));
  }

  // 根据ID获取配方
  public getRecipeById(id: string): Recipe | undefined {
    return this.recipes.find((r: Recipe) => r.id === id);
  }

  // 智能生成配方
  public generateRecipe(params: GenerateParams): Recipe {
    const id = `gen_${Date.now()}`;
    const baseIngredients = this.getBaseIngredients(params);
    const steps = this.generateSteps(params);
    const tips = this.generateTips(params);

    const recipe: Recipe = {
      id: id,
      name: `${params.season}${params.targetFish}专用饵`,
      targetFish: [params.targetFish],
      waterTypes: [params.waterType],
      seasons: [params.season],
      difficulty: '中等',
      prepTime: '15分钟',
      ingredients: baseIngredients,
      steps: steps,
      tips: tips,
      rating: 0,
      usageCount: 0,
      isGenerated: true,
      createTime: Date.now()
    };

    return recipe;
  }

  private getBaseIngredients(params: GenerateParams): Ingredient[] {
    const ingredients: Ingredient[] = [];

    // 基础饵料
    if (params.targetFish === '鲤鱼' || params.targetFish === '草鱼') {
      ingredients.push({ name: '玉米粉', amount: '200', unit: 'g' });
      ingredients.push({ name: '麦麸', amount: '100', unit: 'g' });
    } else if (params.targetFish === '鲫鱼') {
      ingredients.push({ name: '红虫粉', amount: '150', unit: 'g' });
      ingredients.push({ name: '拉丝粉', amount: '50', unit: 'g' });
    } else {
      ingredients.push({ name: '商品饵', amount: '200', unit: 'g' });
    }

    // 季节调整
    if (params.season === '夏季') {
      ingredients.push({ name: '果酸', amount: '5', unit: 'ml' });
    } else if (params.season === '冬季' || params.season === '秋季') {
      ingredients.push({ name: '虾粉', amount: '30', unit: 'g' });
    }

    ingredients.push({ name: '蜂蜜', amount: '20', unit: 'ml' });

    return ingredients;
  }

  private generateSteps(params: GenerateParams): string[] {
    return [
      '将主料混合均匀',
      '加入适量温水，搅拌成糊状',
      '加入辅料，充分搅拌',
      '揉成软硬适中的面团',
      '静置10-15分钟后使用'
    ];
  }

  private generateTips(params: GenerateParams): string[] {
    const tips: string[] = [];

    if (params.season === '夏季') {
      tips.push('夏季鱼偏爱清淡口味，可适当增加果酸');
    } else if (params.season === '冬季') {
      tips.push('冬季鱼活性低，饵料要软，味道要浓');
    }

    if (params.waterType === '水库') {
      tips.push('水库水深，建议搭配打窝料使用');
    }

    tips.push('根据实际情况调整饵料软硬度');

    return tips;
  }

  // 收藏管理
  public addFavorite(recipeId: string): void {
    if (!this.favorites.includes(recipeId)) {
      this.favorites.push(recipeId);
    }
  }

  public removeFavorite(recipeId: string): void {
    const index = this.favorites.indexOf(recipeId);
    if (index > -1) {
      this.favorites.splice(index, 1);
    }
  }

  public isFavorite(recipeId: string): boolean {
    return this.favorites.includes(recipeId);
  }

  public getFavorites(): Recipe[] {
    return this.recipes.filter((r: Recipe) => this.favorites.includes(r.id));
  }
}
