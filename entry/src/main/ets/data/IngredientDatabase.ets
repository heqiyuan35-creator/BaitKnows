/**
 * 原材料数据库
 * 包含饵料制作所需的各类原材料（含民间偏方/邪修）
 */
import { FlavorProfile } from '../common/types/FishTypes';

// ==================== 类型定义 ====================

// 原料大类
export type IngredientCategory = 'base' | 'protein' | 'additive' | 'state' | 'binder' | 'natural' | 'pellet' | 'live' | 'folk';

// 原料子分类
export type IngredientSubCategory = 'grain' | 'tuber' | 'bean' | 'aquatic' | 'insect' | 'animal' | 'essence' | 'attractant' | 'acid' | 'atomizer' | 'weight' | 'plant' | 'seed' | 'worm' | 'baitfish' | 'medicine' | 'beverage' | 'condiment' | 'oil' | 'fermented' | 'other';

// 季节
export type Season = 'spring' | 'summer' | 'autumn' | 'winter';

// 风险等级
export type RiskLevel = 'safe' | 'caution' | 'experimental';

// 原料来源
export type IngredientSource = 'commercial' | 'homemade' | 'natural' | 'pharmacy';

// 存储方式
export type StorageMethod = 'dry' | 'frozen' | 'refrigerated' | 'live' | 'sealed';

// ==================== 属性类 ====================

export class PhysicalProperties {
  atomization: number = 5;
  viscosity: number = 5;
  weight: number = 5;
  dispersal: number = 5;
  constructor() {}
  static create(a: number, v: number, w: number, d: number): PhysicalProperties {
    const p = new PhysicalProperties();
    p.atomization = a; p.viscosity = v; p.weight = w; p.dispersal = d;
    return p;
  }
}

export class DosageRange {
  min: number = 0;
  max: number = 100;
  unit: string = 'g';
  constructor() {}
  static create(minVal: number, maxVal: number, u: string = 'g'): DosageRange {
    const d = new DosageRange();
    d.min = minVal; d.max = maxVal; d.unit = u;
    return d;
  }
}

export class SimpleTemperatureRange {
  min: number = 0;
  max: number = 40;
  constructor() {}
  static create(minVal: number, maxVal: number): SimpleTemperatureRange {
    const t = new SimpleTemperatureRange();
    t.min = minVal; t.max = maxVal;
    return t;
  }
}


// ==================== 原材料主类 ====================

export class Ingredient {
  id: string = '';
  name: string = '';
  alias: string[] = [];
  category: IngredientCategory = 'base';
  subCategory: IngredientSubCategory = 'grain';
  flavorProfile: FlavorProfile = new FlavorProfile();
  physical: PhysicalProperties = new PhysicalProperties();
  targetFish: string[] = [];
  suitableSeason: Season[] = [];
  temperatureRange: SimpleTemperatureRange = new SimpleTemperatureRange();
  dosageRange: DosageRange = new DosageRange();
  source: IngredientSource = 'commercial';
  storageMethod: StorageMethod = 'dry';
  isFolk: boolean = false;
  riskLevel: RiskLevel = 'safe';
  folkOrigin: string = '';
  warnings: string[] = [];
  notes: string = '';
  price: number = 0;
  availability: number = 5;
  constructor() {}
}

// 创建原料的辅助函数
function makeIng(
  id: string, name: string, cat: IngredientCategory, sub: IngredientSubCategory,
  fp: FlavorProfile, phys: PhysicalProperties,
  fish: string[], seasons: Season[],
  temp: SimpleTemperatureRange, dose: DosageRange,
  notes: string, price: number
): Ingredient {
  const ing = new Ingredient();
  ing.id = id; ing.name = name; ing.category = cat; ing.subCategory = sub;
  ing.flavorProfile = fp; ing.physical = phys;
  for (let i = 0; i < fish.length; i++) ing.targetFish.push(fish[i]);
  for (let i = 0; i < seasons.length; i++) ing.suitableSeason.push(seasons[i]);
  ing.temperatureRange = temp; ing.dosageRange = dose;
  ing.notes = notes; ing.price = price;
  return ing;
}

function makeFolkIng(
  id: string, name: string, sub: IngredientSubCategory,
  fp: FlavorProfile, phys: PhysicalProperties,
  fish: string[], seasons: Season[],
  temp: SimpleTemperatureRange, dose: DosageRange,
  folkOrigin: string, riskLevel: RiskLevel, notes: string, price: number
): Ingredient {
  const ing = new Ingredient();
  ing.id = id; ing.name = name; ing.category = 'folk'; ing.subCategory = sub;
  ing.flavorProfile = fp; ing.physical = phys;
  for (let i = 0; i < fish.length; i++) ing.targetFish.push(fish[i]);
  for (let i = 0; i < seasons.length; i++) ing.suitableSeason.push(seasons[i]);
  ing.temperatureRange = temp; ing.dosageRange = dose;
  ing.isFolk = true; ing.riskLevel = riskLevel; ing.folkOrigin = folkOrigin;
  ing.notes = notes; ing.price = price;
  return ing;
}


// ==================== 基础饵料数据 ====================
function getBaseIngredients(): Ingredient[] {
  const list: Ingredient[] = [];
  // 谷物类
  list.push(makeIng('corn_flour', '玉米粉', 'base', 'grain',
    FlavorProfile.create(60, 0, 50, 0, 0, 0, 20, 0, 0), PhysicalProperties.create(6, 4, 5, 7),
    ['carp', 'crucian', 'grass_carp', 'bream'], ['spring', 'summer', 'autumn'],
    SimpleTemperatureRange.create(10, 35), DosageRange.create(20, 50, 'g'),
    '基础甜香料，四季可用', 5));
  list.push(makeIng('wheat_bran', '麸皮', 'base', 'grain',
    FlavorProfile.create(30, 0, 40, 0, 0, 0, 0, 0, 10), PhysicalProperties.create(8, 2, 3, 9),
    ['crucian', 'carp', 'bream', 'grass_carp'], ['spring', 'summer', 'autumn', 'winter'],
    SimpleTemperatureRange.create(5, 35), DosageRange.create(10, 30, 'g'),
    '雾化好，诱鱼快', 4));
  list.push(makeIng('wheat_flour', '面粉', 'base', 'grain',
    FlavorProfile.create(20, 0, 30, 0, 0, 5, 0, 0, 0), PhysicalProperties.create(3, 8, 6, 4),
    ['crucian', 'carp', 'bream'], ['spring', 'summer', 'autumn', 'winter'],
    SimpleTemperatureRange.create(0, 40), DosageRange.create(10, 30, 'g'),
    '增加粘性，调节状态', 3));
  list.push(makeIng('millet', '小米', 'base', 'grain',
    FlavorProfile.create(40, 0, 50, 0, 0, 0, 0, 0, 0), PhysicalProperties.create(2, 1, 7, 3),
    ['crucian', 'carp'], ['spring', 'summer', 'autumn', 'winter'],
    SimpleTemperatureRange.create(0, 35), DosageRange.create(20, 100, 'g'),
    '打窝神器，留鱼效果好', 8));
  // 薯类
  list.push(makeIng('sweet_potato_flour', '红薯粉', 'base', 'tuber',
    FlavorProfile.create(80, 0, 55, 0, 0, 15, 30, 0, 0), PhysicalProperties.create(4, 6, 5, 7),
    ['carp', 'grass_carp', 'bream'], ['summer', 'autumn'],
    SimpleTemperatureRange.create(15, 35), DosageRange.create(15, 35, 'g'),
    '甜香味浓，钓鲤鱼效果极佳', 8));
  list.push(makeIng('potato_flour', '土豆粉', 'base', 'tuber',
    FlavorProfile.create(30, 0, 25, 0, 0, 10, 0, 0, 0), PhysicalProperties.create(3, 7, 6, 4),
    ['carp', 'crucian'], ['spring', 'summer', 'autumn'],
    SimpleTemperatureRange.create(10, 30), DosageRange.create(10, 25, 'g'),
    '增粘效果好', 6));
  // 豆类
  list.push(makeIng('soybean_flour', '黄豆粉', 'base', 'bean',
    FlavorProfile.create(25, 0, 60, 0, 10, 20, 0, 0, 0), PhysicalProperties.create(5, 5, 5, 6),
    ['crucian', 'carp', 'grass_carp', 'bream'], ['spring', 'summer', 'autumn'],
    SimpleTemperatureRange.create(10, 35), DosageRange.create(10, 25, 'g'),
    '豆香浓郁，蛋白质含量高', 6));
  list.push(makeIng('peanut_flour', '花生粉', 'base', 'bean',
    FlavorProfile.create(35, 0, 70, 0, 0, 10, 0, 0, 0), PhysicalProperties.create(5, 4, 5, 6),
    ['carp', 'grass_carp', 'catla'], ['spring', 'summer', 'autumn'],
    SimpleTemperatureRange.create(15, 35), DosageRange.create(10, 30, 'g'),
    '南方钓鲮鱼必备，香味浓郁', 10));
  list.push(makeIng('sesame_flour', '芝麻粉', 'base', 'bean',
    FlavorProfile.create(20, 0, 85, 0, 0, 0, 0, 0, 0), PhysicalProperties.create(6, 3, 4, 7),
    ['crucian', 'carp', 'bream'], ['spring', 'summer', 'autumn', 'winter'],
    SimpleTemperatureRange.create(5, 35), DosageRange.create(5, 15, 'g'),
    '香味穿透力强', 15));
  // 特殊基础饵
  list.push(makeIng('bread_crumb', '面包糠', 'base', 'grain',
    FlavorProfile.create(35, 0, 40, 0, 0, 10, 0, 0, 0), PhysicalProperties.create(7, 2, 3, 8),
    ['crucian', 'carp', 'bream'], ['spring', 'summer', 'autumn', 'winter'],
    SimpleTemperatureRange.create(5, 35), DosageRange.create(10, 40, 'g'),
    '雾化好，增加蓬松度', 8));
  list.push(makeIng('rice_bran', '米糠', 'base', 'grain',
    FlavorProfile.create(20, 0, 35, 0, 5, 0, 0, 0, 5), PhysicalProperties.create(8, 1, 2, 9),
    ['crucian', 'carp', 'bream', 'grass_carp'], ['spring', 'summer', 'autumn', 'winter'],
    SimpleTemperatureRange.create(5, 35), DosageRange.create(15, 50, 'g'),
    '极轻，雾化极好，打窝常用', 3));
  list.push(makeIng('soybean_cake', '豆饼', 'base', 'bean',
    FlavorProfile.create(20, 0, 55, 0, 15, 10, 0, 0, 0), PhysicalProperties.create(5, 4, 5, 6),
    ['carp', 'crucian', 'grass_carp', 'bream'], ['spring', 'summer', 'autumn', 'winter'],
    SimpleTemperatureRange.create(5, 35), DosageRange.create(20, 60, 'g'),
    '经典基础饵，发酵后效果更佳', 5));
  return list;
}

// ==================== 蛋白质类原料 ====================
function getProteinIngredients(): Ingredient[] {
  const list: Ingredient[] = [];
  // 水产类
  list.push(makeIng('fish_meal', '鱼粉', 'protein', 'aquatic',
    FlavorProfile.create(0, 100, 0, 0, 30, 0, 0, 0, 0), PhysicalProperties.create(5, 5, 6, 5),
    ['catfish', 'snakehead', 'mandarin_fish', 'yellow_catfish', 'carp'], ['spring', 'summer', 'autumn', 'winter'],
    SimpleTemperatureRange.create(5, 35), DosageRange.create(5, 20, 'g'),
    '腥味浓郁，肉食性鱼类最爱', 15));
  list.push(makeIng('shrimp_powder', '虾粉', 'protein', 'aquatic',
    FlavorProfile.create(0, 90, 0, 0, 20, 0, 0, 0, 0), PhysicalProperties.create(6, 4, 5, 6),
    ['crucian', 'carp', 'bream', 'catfish', 'yellow_catfish'], ['spring', 'summer', 'autumn', 'winter'],
    SimpleTemperatureRange.create(5, 35), DosageRange.create(5, 15, 'g'),
    '鲜腥味，诱鱼效果极佳', 25));
  list.push(makeIng('snail_powder', '螺蛳粉', 'protein', 'aquatic',
    FlavorProfile.create(0, 85, 0, 0, 25, 0, 0, 0, 5), PhysicalProperties.create(4, 5, 7, 4),
    ['black_carp', 'carp', 'crucian', 'bream'], ['spring', 'summer', 'autumn'],
    SimpleTemperatureRange.create(10, 35), DosageRange.create(10, 30, 'g'),
    '青鱼最爱，腥味独特', 12));
  list.push(makeIng('crab_powder', '蟹粉', 'protein', 'aquatic',
    FlavorProfile.create(0, 80, 0, 0, 15, 0, 0, 0, 0), PhysicalProperties.create(5, 4, 5, 5),
    ['carp', 'crucian', 'catfish', 'yellow_catfish'], ['summer', 'autumn'],
    SimpleTemperatureRange.create(15, 35), DosageRange.create(3, 10, 'g'),
    '鲜味浓郁，价格较高', 40));
  list.push(makeIng('squid_powder', '鱿鱼粉', 'protein', 'aquatic',
    FlavorProfile.create(0, 85, 0, 0, 20, 0, 0, 0, 0), PhysicalProperties.create(5, 5, 5, 5),
    ['catfish', 'snakehead', 'mandarin_fish', 'carp'], ['spring', 'summer', 'autumn'],
    SimpleTemperatureRange.create(10, 35), DosageRange.create(5, 15, 'g'),
    '海鲜腥味，穿透力强', 30));
  list.push(makeIng('clam_powder', '蚬子粉', 'protein', 'aquatic',
    FlavorProfile.create(0, 75, 0, 0, 15, 0, 0, 0, 0), PhysicalProperties.create(5, 4, 6, 5),
    ['crucian', 'carp', 'bream', 'black_carp'], ['spring', 'summer', 'autumn'],
    SimpleTemperatureRange.create(10, 35), DosageRange.create(5, 20, 'g'),
    '河鲜味，野钓效果好', 18));
  // 昆虫类
  list.push(makeIng('silkworm_pupa_powder', '蚕蛹粉', 'protein', 'insect',
    FlavorProfile.create(0, 95, 0, 0, 35, 0, 0, 0, 0), PhysicalProperties.create(5, 5, 5, 5),
    ['carp', 'crucian', 'grass_carp', 'bream', 'catfish'], ['spring', 'summer', 'autumn'],
    SimpleTemperatureRange.create(10, 35), DosageRange.create(5, 20, 'g'),
    '腥味极浓，蛋白质含量高', 20));
  list.push(makeIng('earthworm_powder', '蚯蚓粉', 'protein', 'insect',
    FlavorProfile.create(0, 90, 0, 0, 40, 0, 0, 0, 5), PhysicalProperties.create(5, 5, 5, 5),
    ['crucian', 'carp', 'catfish', 'yellow_catfish', 'eel'], ['spring', 'summer', 'autumn', 'winter'],
    SimpleTemperatureRange.create(5, 35), DosageRange.create(5, 15, 'g'),
    '万能腥饵，四季可用', 25));
  list.push(makeIng('bloodworm_powder', '红虫粉', 'protein', 'insect',
    FlavorProfile.create(0, 95, 0, 0, 30, 0, 0, 0, 0), PhysicalProperties.create(5, 5, 5, 5),
    ['crucian', 'carp', 'bream'], ['autumn', 'winter', 'spring'],
    SimpleTemperatureRange.create(0, 20), DosageRange.create(3, 10, 'g'),
    '冬季神饵，低温效果极佳', 35));
  list.push(makeIng('fly_maggot_powder', '蝇蛆粉', 'protein', 'insect',
    FlavorProfile.create(0, 85, 0, 0, 45, 0, 0, 0, 10), PhysicalProperties.create(5, 5, 5, 5),
    ['catfish', 'yellow_catfish', 'snakehead', 'carp'], ['summer', 'autumn'],
    SimpleTemperatureRange.create(15, 35), DosageRange.create(5, 15, 'g'),
    '腥臭味重，肉食鱼最爱', 15));
  // 动物类
  list.push(makeIng('bone_meal', '骨粉', 'protein', 'animal',
    FlavorProfile.create(0, 60, 0, 0, 20, 0, 0, 0, 0), PhysicalProperties.create(3, 5, 8, 3),
    ['catfish', 'snakehead', 'carp'], ['spring', 'summer', 'autumn'],
    SimpleTemperatureRange.create(10, 35), DosageRange.create(5, 15, 'g'),
    '增加比重，补充钙质', 8));
  list.push(makeIng('blood_meal', '血粉', 'protein', 'animal',
    FlavorProfile.create(0, 100, 0, 0, 50, 0, 0, 0, 0), PhysicalProperties.create(4, 6, 6, 4),
    ['catfish', 'snakehead', 'yellow_catfish', 'mandarin_fish'], ['spring', 'summer', 'autumn'],
    SimpleTemperatureRange.create(10, 35), DosageRange.create(3, 10, 'g'),
    '血腥味极浓，肉食鱼专用', 20));
  list.push(makeIng('liver_powder', '肝粉', 'protein', 'animal',
    FlavorProfile.create(0, 90, 0, 0, 35, 0, 0, 0, 0), PhysicalProperties.create(4, 5, 6, 4),
    ['catfish', 'yellow_catfish', 'snakehead', 'carp'], ['spring', 'summer', 'autumn'],
    SimpleTemperatureRange.create(10, 35), DosageRange.create(5, 15, 'g'),
    '腥味浓郁，营养丰富', 25));
  list.push(makeIng('egg_yolk_powder', '蛋黄粉', 'protein', 'animal',
    FlavorProfile.create(30, 50, 40, 0, 10, 0, 0, 0, 0), PhysicalProperties.create(4, 6, 5, 4),
    ['crucian', 'carp', 'bream'], ['spring', 'summer', 'autumn', 'winter'],
    SimpleTemperatureRange.create(5, 35), DosageRange.create(5, 15, 'g'),
    '蛋香味，增加适口性', 20));
  list.push(makeIng('milk_powder', '奶粉', 'protein', 'animal',
    FlavorProfile.create(50, 30, 30, 0, 0, 0, 20, 0, 0), PhysicalProperties.create(5, 5, 4, 6),
    ['crucian', 'carp', 'bream', 'grass_carp'], ['spring', 'summer', 'autumn', 'winter'],
    SimpleTemperatureRange.create(5, 35), DosageRange.create(5, 20, 'g'),
    '奶香味，增加诱鱼效果', 30));
  return list;
}


// ==================== 添加剂类原料 ====================
function getAdditiveIngredients(): Ingredient[] {
  const list: Ingredient[] = [];
  // 诱食剂
  list.push(makeIng('dmpt', 'DMPT诱食剂', 'additive', 'attractant',
    FlavorProfile.create(0, 50, 0, 0, 0, 0, 0, 0, 0), PhysicalProperties.create(10, 1, 1, 10),
    ['crucian', 'carp', 'bream', 'grass_carp', 'catfish'], ['spring', 'summer', 'autumn', 'winter'],
    SimpleTemperatureRange.create(0, 40), DosageRange.create(0.5, 3, 'g'),
    '强效诱食剂，用量要控制', 50));
  list.push(makeIng('betaine', '甜菜碱', 'additive', 'attractant',
    FlavorProfile.create(30, 20, 0, 0, 0, 0, 0, 0, 0), PhysicalProperties.create(10, 1, 1, 10),
    ['crucian', 'carp', 'bream', 'grass_carp'], ['spring', 'summer', 'autumn', 'winter'],
    SimpleTemperatureRange.create(0, 40), DosageRange.create(1, 5, 'g'),
    '天然诱食剂，安全有效', 40));
  list.push(makeIng('amino_acid', '氨基酸', 'additive', 'attractant',
    FlavorProfile.create(20, 40, 0, 0, 0, 0, 0, 0, 0), PhysicalProperties.create(10, 1, 1, 10),
    ['crucian', 'carp', 'bream', 'grass_carp', 'catfish'], ['spring', 'summer', 'autumn', 'winter'],
    SimpleTemperatureRange.create(0, 40), DosageRange.create(1, 5, 'g'),
    '增强饵料鲜味', 35));
  // 香精类
  list.push(makeIng('vanilla_essence', '香草香精', 'additive', 'essence',
    FlavorProfile.create(80, 0, 60, 0, 0, 0, 30, 0, 0), PhysicalProperties.create(10, 1, 1, 10),
    ['crucian', 'carp', 'bream'], ['spring', 'summer', 'autumn'],
    SimpleTemperatureRange.create(10, 35), DosageRange.create(1, 5, 'ml'),
    '甜香味，夏季效果好', 15));
  list.push(makeIng('strawberry_essence', '草莓香精', 'additive', 'essence',
    FlavorProfile.create(90, 0, 50, 0, 0, 0, 40, 0, 0), PhysicalProperties.create(10, 1, 1, 10),
    ['crucian', 'carp', 'bream', 'grass_carp'], ['spring', 'summer', 'autumn'],
    SimpleTemperatureRange.create(10, 35), DosageRange.create(1, 5, 'ml'),
    '果香浓郁，鲫鱼最爱', 15));
  list.push(makeIng('banana_essence', '香蕉香精', 'additive', 'essence',
    FlavorProfile.create(85, 0, 55, 0, 0, 0, 35, 0, 0), PhysicalProperties.create(10, 1, 1, 10),
    ['crucian', 'carp', 'grass_carp'], ['summer', 'autumn'],
    SimpleTemperatureRange.create(15, 35), DosageRange.create(1, 5, 'ml'),
    '热天效果好', 15));
  list.push(makeIng('honey_essence', '蜂蜜香精', 'additive', 'essence',
    FlavorProfile.create(95, 0, 40, 0, 0, 0, 50, 0, 0), PhysicalProperties.create(10, 1, 1, 10),
    ['crucian', 'carp', 'bream', 'grass_carp'], ['spring', 'summer', 'autumn'],
    SimpleTemperatureRange.create(10, 35), DosageRange.create(1, 5, 'ml'),
    '蜜甜香，诱鱼效果极佳', 20));
  list.push(makeIng('garlic_essence', '蒜香香精', 'additive', 'essence',
    FlavorProfile.create(0, 30, 0, 0, 0, 0, 0, 80, 0), PhysicalProperties.create(10, 1, 1, 10),
    ['crucian', 'carp', 'grass_carp', 'bream'], ['spring', 'summer', 'autumn', 'winter'],
    SimpleTemperatureRange.create(5, 35), DosageRange.create(1, 5, 'ml'),
    '蒜香味，穿透力强', 12));
  list.push(makeIng('anise_essence', '茴香香精', 'additive', 'essence',
    FlavorProfile.create(20, 0, 30, 0, 0, 0, 0, 70, 0), PhysicalProperties.create(10, 1, 1, 10),
    ['crucian', 'carp', 'bream'], ['autumn', 'winter', 'spring'],
    SimpleTemperatureRange.create(0, 25), DosageRange.create(1, 3, 'ml'),
    '冬季效果好', 15));
  list.push(makeIng('fishy_essence', '腥香香精', 'additive', 'essence',
    FlavorProfile.create(0, 90, 0, 0, 20, 0, 0, 0, 0), PhysicalProperties.create(10, 1, 1, 10),
    ['catfish', 'yellow_catfish', 'snakehead', 'carp'], ['spring', 'summer', 'autumn', 'winter'],
    SimpleTemperatureRange.create(5, 35), DosageRange.create(1, 5, 'ml'),
    '浓腥味，肉食鱼专用', 20));
  // 酸类
  list.push(makeIng('citric_acid', '柠檬酸', 'additive', 'acid',
    FlavorProfile.create(30, 0, 0, 80, 0, 0, 0, 0, 0), PhysicalProperties.create(10, 1, 1, 10),
    ['silver_carp', 'bighead_carp', 'crucian'], ['summer', 'autumn'],
    SimpleTemperatureRange.create(15, 35), DosageRange.create(1, 5, 'g'),
    '酸味，鲢鳙最爱', 10));
  list.push(makeIng('lactic_acid', '乳酸', 'additive', 'acid',
    FlavorProfile.create(20, 0, 0, 70, 0, 0, 0, 0, 0), PhysicalProperties.create(10, 1, 1, 10),
    ['silver_carp', 'bighead_carp'], ['summer', 'autumn'],
    SimpleTemperatureRange.create(15, 35), DosageRange.create(1, 5, 'ml'),
    '发酵酸味，鲢鳙专用', 15));
  list.push(makeIng('acetic_acid', '醋酸', 'additive', 'acid',
    FlavorProfile.create(0, 0, 0, 90, 0, 0, 0, 0, 10), PhysicalProperties.create(10, 1, 1, 10),
    ['silver_carp', 'bighead_carp'], ['summer', 'autumn'],
    SimpleTemperatureRange.create(15, 35), DosageRange.create(1, 3, 'ml'),
    '酸臭味，大头鱼最爱', 5));
  // 调味料
  list.push(makeIng('white_sugar', '白糖', 'additive', 'condiment',
    FlavorProfile.create(100, 0, 0, 0, 0, 0, 50, 0, 0), PhysicalProperties.create(10, 1, 1, 10),
    ['crucian', 'carp', 'bream', 'grass_carp'], ['spring', 'summer', 'autumn'],
    SimpleTemperatureRange.create(10, 35), DosageRange.create(5, 20, 'g'),
    '增加甜味，诱鱼效果好', 3));
  list.push(makeIng('brown_sugar', '红糖', 'additive', 'condiment',
    FlavorProfile.create(90, 0, 20, 0, 0, 0, 40, 0, 0), PhysicalProperties.create(10, 1, 1, 10),
    ['crucian', 'carp', 'bream'], ['spring', 'summer', 'autumn'],
    SimpleTemperatureRange.create(10, 35), DosageRange.create(5, 20, 'g'),
    '红糖香甜，效果独特', 5));
  list.push(makeIng('honey', '蜂蜜', 'additive', 'condiment',
    FlavorProfile.create(95, 0, 30, 0, 0, 0, 60, 0, 0), PhysicalProperties.create(8, 3, 2, 8),
    ['crucian', 'carp', 'bream', 'grass_carp'], ['spring', 'summer', 'autumn'],
    SimpleTemperatureRange.create(10, 35), DosageRange.create(5, 20, 'ml'),
    '天然甜味，增加粘性', 30));
  list.push(makeIng('salt', '食盐', 'additive', 'condiment',
    FlavorProfile.create(0, 20, 0, 0, 0, 0, 0, 0, 0), PhysicalProperties.create(10, 1, 1, 10),
    ['crucian', 'carp', 'bream', 'catfish'], ['spring', 'summer', 'autumn', 'winter'],
    SimpleTemperatureRange.create(0, 40), DosageRange.create(1, 5, 'g'),
    '少量增鲜，过量有害', 2));
  list.push(makeIng('msg', '味精', 'additive', 'condiment',
    FlavorProfile.create(20, 50, 0, 0, 0, 0, 0, 0, 0), PhysicalProperties.create(10, 1, 1, 10),
    ['crucian', 'carp', 'bream', 'catfish'], ['spring', 'summer', 'autumn', 'winter'],
    SimpleTemperatureRange.create(5, 35), DosageRange.create(1, 5, 'g'),
    '增加鲜味', 5));
  list.push(makeIng('chicken_powder', '鸡精', 'additive', 'condiment',
    FlavorProfile.create(20, 60, 20, 0, 0, 0, 0, 0, 0), PhysicalProperties.create(10, 1, 1, 10),
    ['crucian', 'carp', 'bream', 'catfish'], ['spring', 'summer', 'autumn', 'winter'],
    SimpleTemperatureRange.create(5, 35), DosageRange.create(2, 8, 'g'),
    '复合鲜味，效果好', 8));
  // 油类
  list.push(makeIng('sesame_oil', '香油', 'additive', 'oil',
    FlavorProfile.create(10, 0, 90, 0, 0, 0, 0, 0, 0), PhysicalProperties.create(8, 2, 2, 8),
    ['crucian', 'carp', 'bream'], ['spring', 'summer', 'autumn', 'winter'],
    SimpleTemperatureRange.create(5, 35), DosageRange.create(2, 10, 'ml'),
    '香味浓郁，增加诱鱼效果', 25));
  list.push(makeIng('peanut_oil', '花生油', 'additive', 'oil',
    FlavorProfile.create(10, 0, 70, 0, 0, 0, 0, 0, 0), PhysicalProperties.create(8, 2, 2, 8),
    ['carp', 'grass_carp', 'catla'], ['spring', 'summer', 'autumn'],
    SimpleTemperatureRange.create(10, 35), DosageRange.create(2, 10, 'ml'),
    '花生香，南方常用', 15));
  list.push(makeIng('fish_oil', '鱼油', 'additive', 'oil',
    FlavorProfile.create(0, 80, 0, 0, 20, 0, 0, 0, 0), PhysicalProperties.create(8, 2, 2, 8),
    ['catfish', 'snakehead', 'yellow_catfish', 'carp'], ['spring', 'summer', 'autumn', 'winter'],
    SimpleTemperatureRange.create(5, 35), DosageRange.create(2, 10, 'ml'),
    '腥味浓，肉食鱼专用', 30));
  return list;
}


// ==================== 状态调节类原料 ====================
function getStateIngredients(): Ingredient[] {
  const list: Ingredient[] = [];
  // 雾化类
  list.push(makeIng('drawing_powder', '拉丝粉', 'state', 'atomizer',
    FlavorProfile.create(0, 0, 0, 0, 0, 0, 0, 0, 0), PhysicalProperties.create(2, 9, 5, 3),
    ['crucian', 'carp', 'bream'], ['spring', 'summer', 'autumn', 'winter'],
    SimpleTemperatureRange.create(0, 40), DosageRange.create(5, 20, 'g'),
    '增加拉丝效果，必备状态饵', 15));
  list.push(makeIng('snowflake_powder', '雪花粉', 'state', 'atomizer',
    FlavorProfile.create(10, 0, 10, 0, 0, 0, 0, 0, 0), PhysicalProperties.create(9, 1, 2, 10),
    ['crucian', 'carp', 'bream', 'grass_carp'], ['spring', 'summer', 'autumn', 'winter'],
    SimpleTemperatureRange.create(0, 40), DosageRange.create(10, 40, 'g'),
    '极轻，雾化极好', 12));
  list.push(makeIng('light_bran', '轻麸', 'state', 'atomizer',
    FlavorProfile.create(15, 0, 20, 0, 0, 0, 0, 0, 0), PhysicalProperties.create(9, 1, 1, 10),
    ['crucian', 'carp', 'bream'], ['spring', 'summer', 'autumn', 'winter'],
    SimpleTemperatureRange.create(0, 40), DosageRange.create(10, 30, 'g'),
    '超轻雾化，钓浮必备', 18));
  list.push(makeIng('puffed_corn', '膨化玉米', 'state', 'atomizer',
    FlavorProfile.create(50, 0, 40, 0, 0, 0, 15, 0, 0), PhysicalProperties.create(8, 2, 2, 9),
    ['crucian', 'carp', 'grass_carp', 'bream'], ['spring', 'summer', 'autumn'],
    SimpleTemperatureRange.create(10, 35), DosageRange.create(15, 40, 'g'),
    '玉米香，雾化好', 10));
  // 增重类
  list.push(makeIng('sticky_powder', '粘粉', 'state', 'weight',
    FlavorProfile.create(0, 0, 0, 0, 0, 0, 0, 0, 0), PhysicalProperties.create(1, 10, 7, 1),
    ['crucian', 'carp', 'bream', 'catfish'], ['spring', 'summer', 'autumn', 'winter'],
    SimpleTemperatureRange.create(0, 40), DosageRange.create(5, 20, 'g'),
    '增加粘性，钓底必备', 10));
  list.push(makeIng('heavy_powder', '比重粉', 'state', 'weight',
    FlavorProfile.create(0, 0, 0, 0, 0, 0, 0, 0, 0), PhysicalProperties.create(1, 5, 10, 1),
    ['carp', 'bream', 'catfish', 'black_carp'], ['spring', 'summer', 'autumn', 'winter'],
    SimpleTemperatureRange.create(0, 40), DosageRange.create(10, 30, 'g'),
    '增加比重，快速到底', 8));
  list.push(makeIng('pellet_powder', '颗粒粉', 'state', 'weight',
    FlavorProfile.create(30, 40, 30, 0, 10, 0, 0, 0, 0), PhysicalProperties.create(4, 5, 6, 5),
    ['carp', 'crucian', 'grass_carp', 'bream'], ['spring', 'summer', 'autumn', 'winter'],
    SimpleTemperatureRange.create(5, 35), DosageRange.create(20, 50, 'g'),
    '颗粒饲料磨粉，养殖塘必备', 8));
  // 粘合剂
  list.push(makeIng('glutinous_rice_flour', '糯米粉', 'binder', 'grain',
    FlavorProfile.create(25, 0, 20, 0, 0, 10, 0, 0, 0), PhysicalProperties.create(2, 9, 6, 2),
    ['crucian', 'carp', 'bream'], ['spring', 'summer', 'autumn', 'winter'],
    SimpleTemperatureRange.create(0, 40), DosageRange.create(5, 20, 'g'),
    '天然粘合剂，增加粘性', 6));
  list.push(makeIng('tapioca_starch', '木薯粉', 'binder', 'tuber',
    FlavorProfile.create(15, 0, 10, 0, 0, 5, 0, 0, 0), PhysicalProperties.create(2, 8, 5, 2),
    ['crucian', 'carp', 'bream'], ['spring', 'summer', 'autumn', 'winter'],
    SimpleTemperatureRange.create(0, 40), DosageRange.create(5, 15, 'g'),
    '粘性强，透明度高', 8));
  list.push(makeIng('corn_starch', '玉米淀粉', 'binder', 'grain',
    FlavorProfile.create(20, 0, 15, 0, 0, 5, 0, 0, 0), PhysicalProperties.create(2, 8, 5, 2),
    ['crucian', 'carp', 'bream', 'grass_carp'], ['spring', 'summer', 'autumn', 'winter'],
    SimpleTemperatureRange.create(0, 40), DosageRange.create(5, 15, 'g'),
    '增加粘性，调节状态', 5));
  return list;
}


// ==================== 天然原料 ====================
function getNaturalIngredients(): Ingredient[] {
  const list: Ingredient[] = [];
  // 谷物种子类
  list.push(makeIng('corn_kernel', '玉米粒', 'natural', 'seed',
    FlavorProfile.create(70, 0, 40, 0, 0, 0, 30, 0, 0), PhysicalProperties.create(1, 1, 8, 1),
    ['carp', 'grass_carp', 'bream', 'crucian'], ['spring', 'summer', 'autumn'],
    SimpleTemperatureRange.create(15, 35), DosageRange.create(20, 100, 'g'),
    '钓大鱼神饵，可发酵使用', 3));
  list.push(makeIng('wheat_kernel', '麦粒', 'natural', 'seed',
    FlavorProfile.create(40, 0, 35, 0, 0, 0, 10, 0, 0), PhysicalProperties.create(1, 1, 7, 1),
    ['carp', 'crucian', 'bream', 'grass_carp'], ['spring', 'summer', 'autumn'],
    SimpleTemperatureRange.create(10, 35), DosageRange.create(20, 100, 'g'),
    '发酵后效果极佳', 3));
  list.push(makeIng('rice_grain', '米粒', 'natural', 'seed',
    FlavorProfile.create(30, 0, 25, 0, 0, 0, 0, 0, 0), PhysicalProperties.create(1, 1, 6, 1),
    ['crucian', 'carp', 'bream'], ['spring', 'summer', 'autumn', 'winter'],
    SimpleTemperatureRange.create(5, 35), DosageRange.create(20, 80, 'g'),
    '打窝常用，留鱼效果好', 4));
  list.push(makeIng('sorghum', '高粱', 'natural', 'seed',
    FlavorProfile.create(35, 0, 30, 0, 0, 0, 0, 0, 0), PhysicalProperties.create(1, 1, 7, 1),
    ['carp', 'crucian', 'bream'], ['summer', 'autumn'],
    SimpleTemperatureRange.create(15, 35), DosageRange.create(20, 80, 'g'),
    '发酵后酒香浓郁', 4));
  // 植物类
  list.push(makeIng('tender_grass', '嫩草', 'natural', 'plant',
    FlavorProfile.create(20, 0, 30, 0, 0, 0, 0, 0, 0), PhysicalProperties.create(1, 1, 2, 1),
    ['grass_carp'], ['spring', 'summer', 'autumn'],
    SimpleTemperatureRange.create(15, 35), DosageRange.create(50, 200, 'g'),
    '草鱼最爱，新鲜为佳', 0));
  list.push(makeIng('reed_core', '芦苇芯', 'natural', 'plant',
    FlavorProfile.create(25, 0, 25, 0, 0, 0, 0, 0, 0), PhysicalProperties.create(1, 1, 2, 1),
    ['grass_carp'], ['spring', 'summer'],
    SimpleTemperatureRange.create(15, 35), DosageRange.create(30, 100, 'g'),
    '草鱼专用，嫩芯效果最好', 0));
  list.push(makeIng('water_hyacinth', '水葫芦', 'natural', 'plant',
    FlavorProfile.create(15, 0, 20, 0, 0, 0, 0, 0, 0), PhysicalProperties.create(1, 1, 2, 1),
    ['grass_carp', 'bream'], ['summer', 'autumn'],
    SimpleTemperatureRange.create(20, 35), DosageRange.create(30, 100, 'g'),
    '水生植物，草鱼喜欢', 0));
  list.push(makeIng('mulberry_leaf', '桑叶', 'natural', 'plant',
    FlavorProfile.create(20, 0, 25, 0, 0, 0, 0, 0, 0), PhysicalProperties.create(1, 1, 2, 1),
    ['grass_carp'], ['spring', 'summer'],
    SimpleTemperatureRange.create(15, 35), DosageRange.create(20, 80, 'g'),
    '草鱼喜欢，嫩叶为佳', 0));
  list.push(makeIng('pumpkin_flower', '南瓜花', 'natural', 'plant',
    FlavorProfile.create(40, 0, 30, 0, 0, 0, 20, 0, 0), PhysicalProperties.create(1, 1, 1, 1),
    ['grass_carp', 'crucian'], ['summer', 'autumn'],
    SimpleTemperatureRange.create(20, 35), DosageRange.create(10, 50, 'g'),
    '花香味，草鱼喜欢', 0));
  // 果实类
  list.push(makeIng('mulberry', '桑葚', 'natural', 'seed',
    FlavorProfile.create(80, 0, 40, 10, 0, 0, 50, 0, 0), PhysicalProperties.create(2, 2, 4, 2),
    ['grass_carp', 'carp', 'crucian'], ['spring', 'summer'],
    SimpleTemperatureRange.create(15, 35), DosageRange.create(20, 80, 'g'),
    '桑葚季节神饵，草鱼最爱', 10));
  list.push(makeIng('grape', '葡萄', 'natural', 'seed',
    FlavorProfile.create(85, 0, 35, 5, 0, 0, 45, 0, 0), PhysicalProperties.create(1, 1, 5, 1),
    ['grass_carp', 'carp'], ['summer', 'autumn'],
    SimpleTemperatureRange.create(20, 35), DosageRange.create(10, 50, 'g'),
    '果香浓郁，大鱼喜欢', 15));
  list.push(makeIng('cherry', '樱桃', 'natural', 'seed',
    FlavorProfile.create(80, 0, 30, 5, 0, 0, 40, 0, 0), PhysicalProperties.create(1, 1, 4, 1),
    ['grass_carp', 'carp'], ['spring', 'summer'],
    SimpleTemperatureRange.create(15, 35), DosageRange.create(10, 40, 'g'),
    '果香味，季节性使用', 20));
  return list;
}


// ==================== 活饵类 ====================
function getLiveIngredients(): Ingredient[] {
  const list: Ingredient[] = [];
  // 蠕虫类
  list.push(makeIng('earthworm', '蚯蚓', 'live', 'worm',
    FlavorProfile.create(0, 100, 0, 0, 50, 0, 0, 0, 10), PhysicalProperties.create(1, 1, 5, 1),
    ['crucian', 'carp', 'catfish', 'yellow_catfish', 'eel', 'snakehead'], ['spring', 'summer', 'autumn', 'winter'],
    SimpleTemperatureRange.create(0, 35), DosageRange.create(5, 30, '条'),
    '万能饵，四季可用', 5));
  list.push(makeIng('bloodworm', '红虫', 'live', 'worm',
    FlavorProfile.create(0, 100, 0, 0, 40, 0, 0, 0, 0), PhysicalProperties.create(1, 1, 3, 1),
    ['crucian', 'carp', 'bream'], ['autumn', 'winter', 'spring'],
    SimpleTemperatureRange.create(0, 20), DosageRange.create(10, 50, '条'),
    '冬季神饵，低温效果极佳', 20));
  list.push(makeIng('maggot', '蛆虫', 'live', 'worm',
    FlavorProfile.create(0, 90, 0, 0, 60, 0, 0, 0, 20), PhysicalProperties.create(1, 1, 3, 1),
    ['catfish', 'yellow_catfish', 'snakehead', 'carp'], ['summer', 'autumn'],
    SimpleTemperatureRange.create(15, 35), DosageRange.create(10, 50, '条'),
    '腥臭味重，肉食鱼最爱', 8));
  list.push(makeIng('mealworm', '面包虫', 'live', 'worm',
    FlavorProfile.create(0, 85, 0, 0, 35, 0, 0, 0, 0), PhysicalProperties.create(1, 1, 4, 1),
    ['crucian', 'carp', 'catfish', 'yellow_catfish'], ['spring', 'summer', 'autumn'],
    SimpleTemperatureRange.create(10, 35), DosageRange.create(5, 30, '条'),
    '蛋白质高，效果好', 15));
  list.push(makeIng('leech', '蚂蟥', 'live', 'worm',
    FlavorProfile.create(0, 95, 0, 0, 55, 0, 0, 0, 15), PhysicalProperties.create(1, 1, 4, 1),
    ['catfish', 'snakehead', 'yellow_catfish', 'eel'], ['summer', 'autumn'],
    SimpleTemperatureRange.create(15, 35), DosageRange.create(3, 15, '条'),
    '肉食鱼专用，效果极佳', 25));
  // 水生类
  list.push(makeIng('live_shrimp', '活虾', 'live', 'aquatic',
    FlavorProfile.create(0, 95, 0, 0, 30, 0, 0, 0, 0), PhysicalProperties.create(1, 1, 5, 1),
    ['mandarin_fish', 'snakehead', 'catfish', 'carp', 'bass'], ['spring', 'summer', 'autumn'],
    SimpleTemperatureRange.create(10, 35), DosageRange.create(5, 20, '只'),
    '鲜活诱鱼，效果极佳', 30));
  list.push(makeIng('live_loach', '活泥鳅', 'live', 'baitfish',
    FlavorProfile.create(0, 100, 0, 0, 40, 0, 0, 0, 0), PhysicalProperties.create(1, 1, 6, 1),
    ['snakehead', 'mandarin_fish', 'catfish', 'pike'], ['spring', 'summer', 'autumn'],
    SimpleTemperatureRange.create(10, 35), DosageRange.create(3, 10, '条'),
    '钓大型肉食鱼神饵', 40));
  list.push(makeIng('live_crucian', '活鲫鱼', 'live', 'baitfish',
    FlavorProfile.create(0, 100, 0, 0, 35, 0, 0, 0, 0), PhysicalProperties.create(1, 1, 7, 1),
    ['snakehead', 'mandarin_fish', 'catfish', 'pike'], ['spring', 'summer', 'autumn'],
    SimpleTemperatureRange.create(10, 35), DosageRange.create(1, 5, '条'),
    '钓大型肉食鱼', 50));
  list.push(makeIng('snail', '螺蛳', 'live', 'aquatic',
    FlavorProfile.create(0, 80, 0, 0, 30, 0, 0, 0, 5), PhysicalProperties.create(1, 1, 9, 1),
    ['black_carp', 'carp', 'crucian'], ['spring', 'summer', 'autumn'],
    SimpleTemperatureRange.create(10, 35), DosageRange.create(10, 50, '个'),
    '青鱼最爱，砸碎使用', 5));
  list.push(makeIng('river_mussel', '河蚌', 'live', 'aquatic',
    FlavorProfile.create(0, 85, 0, 0, 35, 0, 0, 0, 5), PhysicalProperties.create(1, 1, 8, 1),
    ['black_carp', 'carp', 'catfish'], ['spring', 'summer', 'autumn'],
    SimpleTemperatureRange.create(10, 35), DosageRange.create(5, 20, '个'),
    '青鱼、鲤鱼喜欢', 8));
  list.push(makeIng('crayfish', '小龙虾', 'live', 'aquatic',
    FlavorProfile.create(0, 90, 0, 0, 35, 0, 0, 0, 0), PhysicalProperties.create(1, 1, 7, 1),
    ['snakehead', 'catfish', 'mandarin_fish', 'carp'], ['summer', 'autumn'],
    SimpleTemperatureRange.create(15, 35), DosageRange.create(3, 15, '只'),
    '去壳使用，肉食鱼喜欢', 15));
  // 昆虫类
  list.push(makeIng('grasshopper', '蚂蚱', 'live', 'insect',
    FlavorProfile.create(0, 80, 0, 0, 30, 0, 0, 0, 0), PhysicalProperties.create(1, 1, 3, 1),
    ['grass_carp', 'carp', 'crucian'], ['summer', 'autumn'],
    SimpleTemperatureRange.create(15, 35), DosageRange.create(5, 20, '只'),
    '草鱼最爱，秋季效果好', 0));
  list.push(makeIng('cricket', '蟋蟀', 'live', 'insect',
    FlavorProfile.create(0, 75, 0, 0, 25, 0, 0, 0, 0), PhysicalProperties.create(1, 1, 3, 1),
    ['grass_carp', 'carp', 'crucian'], ['summer', 'autumn'],
    SimpleTemperatureRange.create(15, 35), DosageRange.create(5, 20, '只'),
    '草鱼喜欢', 0));
  list.push(makeIng('silkworm', '蚕宝宝', 'live', 'insect',
    FlavorProfile.create(0, 85, 0, 0, 35, 0, 0, 0, 0), PhysicalProperties.create(1, 1, 4, 1),
    ['grass_carp', 'carp', 'crucian', 'catfish'], ['spring', 'summer'],
    SimpleTemperatureRange.create(15, 35), DosageRange.create(5, 20, '条'),
    '蛋白质高，效果好', 20));
  return list;
}


// ==================== 颗粒饲料类 ====================
function getPelletIngredients(): Ingredient[] {
  const list: Ingredient[] = [];
  list.push(makeIng('crucian_pellet', '鲫鱼颗粒', 'pellet', 'other',
    FlavorProfile.create(40, 50, 30, 0, 15, 0, 0, 0, 0), PhysicalProperties.create(3, 5, 7, 4),
    ['crucian', 'carp', 'bream'], ['spring', 'summer', 'autumn', 'winter'],
    SimpleTemperatureRange.create(5, 35), DosageRange.create(30, 100, 'g'),
    '养殖塘必备，鲫鱼专用', 10));
  list.push(makeIng('carp_pellet', '鲤鱼颗粒', 'pellet', 'other',
    FlavorProfile.create(35, 55, 35, 0, 20, 0, 0, 0, 0), PhysicalProperties.create(3, 5, 8, 4),
    ['carp', 'crucian', 'bream', 'grass_carp'], ['spring', 'summer', 'autumn', 'winter'],
    SimpleTemperatureRange.create(5, 35), DosageRange.create(30, 100, 'g'),
    '养殖塘必备，鲤鱼专用', 10));
  list.push(makeIng('grass_carp_pellet', '草鱼颗粒', 'pellet', 'other',
    FlavorProfile.create(45, 40, 35, 0, 10, 0, 10, 0, 0), PhysicalProperties.create(3, 5, 7, 4),
    ['grass_carp', 'carp', 'bream'], ['spring', 'summer', 'autumn'],
    SimpleTemperatureRange.create(10, 35), DosageRange.create(30, 100, 'g'),
    '草鱼专用颗粒', 12));
  list.push(makeIng('catfish_pellet', '鲶鱼颗粒', 'pellet', 'other',
    FlavorProfile.create(10, 80, 20, 0, 40, 0, 0, 0, 0), PhysicalProperties.create(3, 5, 8, 4),
    ['catfish', 'yellow_catfish', 'snakehead'], ['spring', 'summer', 'autumn'],
    SimpleTemperatureRange.create(10, 35), DosageRange.create(30, 100, 'g'),
    '肉食鱼专用，腥味重', 15));
  list.push(makeIng('tilapia_pellet', '罗非颗粒', 'pellet', 'other',
    FlavorProfile.create(30, 60, 25, 0, 25, 0, 0, 0, 0), PhysicalProperties.create(3, 5, 7, 4),
    ['tilapia', 'carp', 'crucian'], ['spring', 'summer', 'autumn'],
    SimpleTemperatureRange.create(15, 35), DosageRange.create(30, 100, 'g'),
    '南方常用，罗非专用', 8));
  list.push(makeIng('mixed_pellet', '混合颗粒', 'pellet', 'other',
    FlavorProfile.create(35, 50, 30, 0, 15, 0, 0, 0, 0), PhysicalProperties.create(3, 5, 7, 4),
    ['crucian', 'carp', 'bream', 'grass_carp'], ['spring', 'summer', 'autumn', 'winter'],
    SimpleTemperatureRange.create(5, 35), DosageRange.create(30, 100, 'g'),
    '通用颗粒，适合多种鱼', 8));
  list.push(makeIng('floating_pellet', '浮水颗粒', 'pellet', 'other',
    FlavorProfile.create(40, 45, 30, 0, 10, 0, 0, 0, 0), PhysicalProperties.create(8, 3, 1, 7),
    ['grass_carp', 'carp', 'crucian'], ['summer', 'autumn'],
    SimpleTemperatureRange.create(15, 35), DosageRange.create(20, 80, 'g'),
    '钓浮专用，草鱼喜欢', 12));
  list.push(makeIng('sinking_pellet', '沉底颗粒', 'pellet', 'other',
    FlavorProfile.create(35, 55, 30, 0, 20, 0, 0, 0, 0), PhysicalProperties.create(2, 6, 9, 3),
    ['carp', 'bream', 'catfish', 'black_carp'], ['spring', 'summer', 'autumn', 'winter'],
    SimpleTemperatureRange.create(5, 35), DosageRange.create(30, 100, 'g'),
    '钓底专用，快速到底', 10));
  return list;
}


// ==================== 邪修类原料（民间偏方） ====================
function getFolkIngredients(): Ingredient[] {
  const list: Ingredient[] = [];
  // 药品类
  list.push(makeFolkIng('huoxiang_zhengqi', '藿香正气水', 'medicine',
    FlavorProfile.create(10, 30, 40, 0, 0, 0, 0, 90, 20), PhysicalProperties.create(10, 1, 1, 10),
    ['crucian', 'carp', 'bream', 'grass_carp'], ['summer', 'autumn'],
    SimpleTemperatureRange.create(20, 35), DosageRange.create(5, 20, 'ml'),
    '民间偏方', 'caution', '夏季高温效果好，药味独特', 5));
  list.push(makeFolkIng('awei', '阿魏', 'medicine',
    FlavorProfile.create(0, 50, 0, 0, 0, 0, 0, 100, 80), PhysicalProperties.create(10, 1, 1, 10),
    ['crucian', 'carp', 'bream', 'catfish'], ['spring', 'summer', 'autumn', 'winter'],
    SimpleTemperatureRange.create(5, 35), DosageRange.create(0.5, 3, 'g'),
    '古方秘药', 'caution', '臭味极重，穿透力极强，用量要极少', 30));
  list.push(makeFolkIng('vitamin_b', '维生素B', 'medicine',
    FlavorProfile.create(10, 20, 0, 0, 0, 0, 0, 30, 0), PhysicalProperties.create(10, 1, 1, 10),
    ['crucian', 'carp', 'bream', 'grass_carp'], ['spring', 'summer', 'autumn', 'winter'],
    SimpleTemperatureRange.create(5, 35), DosageRange.create(2, 10, '片'),
    '钓鱼论坛', 'safe', '据说能增加诱鱼效果', 5));
  list.push(makeFolkIng('fengyoujing', '风油精', 'medicine',
    FlavorProfile.create(0, 0, 0, 0, 0, 0, 0, 95, 0), PhysicalProperties.create(10, 1, 1, 10),
    ['crucian', 'carp', 'grass_carp'], ['summer'],
    SimpleTemperatureRange.create(25, 35), DosageRange.create(1, 5, '滴'),
    '民间偏方', 'experimental', '清凉味，夏季高温尝试', 3));
  list.push(makeFolkIng('qingliangyu', '清凉油', 'medicine',
    FlavorProfile.create(0, 0, 0, 0, 0, 0, 0, 90, 0), PhysicalProperties.create(8, 2, 2, 8),
    ['crucian', 'carp', 'grass_carp'], ['summer'],
    SimpleTemperatureRange.create(25, 35), DosageRange.create(1, 3, 'g'),
    '民间偏方', 'experimental', '清凉味，高温天气尝试', 5));
  list.push(makeFolkIng('niuhuang_jiedu', '牛黄解毒片', 'medicine',
    FlavorProfile.create(0, 20, 0, 0, 0, 0, 0, 70, 30), PhysicalProperties.create(10, 1, 1, 10),
    ['crucian', 'carp', 'bream'], ['summer', 'autumn'],
    SimpleTemperatureRange.create(20, 35), DosageRange.create(1, 3, '片'),
    '民间偏方', 'experimental', '苦味药香，效果存疑', 8));
  // 饮料类
  list.push(makeFolkIng('beer', '啤酒', 'beverage',
    FlavorProfile.create(30, 20, 40, 10, 0, 0, 0, 50, 10), PhysicalProperties.create(10, 1, 1, 10),
    ['crucian', 'carp', 'bream', 'grass_carp'], ['summer', 'autumn'],
    SimpleTemperatureRange.create(15, 35), DosageRange.create(50, 200, 'ml'),
    '民间常用', 'safe', '酒香味，开饵常用', 5));
  list.push(makeFolkIng('baijiu', '白酒', 'beverage',
    FlavorProfile.create(20, 10, 50, 0, 0, 0, 0, 80, 0), PhysicalProperties.create(10, 1, 1, 10),
    ['crucian', 'carp', 'bream', 'grass_carp'], ['spring', 'summer', 'autumn', 'winter'],
    SimpleTemperatureRange.create(5, 35), DosageRange.create(10, 50, 'ml'),
    '传统方法', 'safe', '泡制酒米必备，曲香浓郁', 15));
  list.push(makeFolkIng('cola', '可乐', 'beverage',
    FlavorProfile.create(90, 0, 30, 20, 0, 0, 60, 0, 0), PhysicalProperties.create(10, 1, 1, 10),
    ['crucian', 'carp', 'grass_carp'], ['summer', 'autumn'],
    SimpleTemperatureRange.create(15, 35), DosageRange.create(30, 100, 'ml'),
    '网络偏方', 'safe', '甜味浓，据说草鱼喜欢', 3));
  list.push(makeFolkIng('sprite', '雪碧', 'beverage',
    FlavorProfile.create(85, 0, 20, 30, 0, 0, 55, 0, 0), PhysicalProperties.create(10, 1, 1, 10),
    ['crucian', 'carp', 'grass_carp'], ['summer', 'autumn'],
    SimpleTemperatureRange.create(15, 35), DosageRange.create(30, 100, 'ml'),
    '网络偏方', 'safe', '柠檬甜味，夏季尝试', 3));
  list.push(makeFolkIng('redbull', '红牛', 'beverage',
    FlavorProfile.create(70, 0, 20, 10, 0, 0, 40, 30, 0), PhysicalProperties.create(10, 1, 1, 10),
    ['crucian', 'carp', 'grass_carp'], ['summer', 'autumn'],
    SimpleTemperatureRange.create(15, 35), DosageRange.create(30, 100, 'ml'),
    '网络偏方', 'experimental', '功能饮料，效果存疑', 8));
  list.push(makeFolkIng('milk', '牛奶', 'beverage',
    FlavorProfile.create(50, 30, 30, 0, 0, 0, 20, 0, 0), PhysicalProperties.create(9, 2, 2, 9),
    ['crucian', 'carp', 'bream'], ['spring', 'summer', 'autumn'],
    SimpleTemperatureRange.create(10, 35), DosageRange.create(30, 100, 'ml'),
    '民间偏方', 'safe', '奶香味，开饵使用', 5));
  list.push(makeFolkIng('yogurt', '酸奶', 'beverage',
    FlavorProfile.create(60, 20, 25, 40, 0, 0, 30, 0, 0), PhysicalProperties.create(8, 3, 2, 8),
    ['crucian', 'carp', 'bream', 'silver_carp'], ['summer', 'autumn'],
    SimpleTemperatureRange.create(15, 35), DosageRange.create(30, 100, 'ml'),
    '民间偏方', 'safe', '酸奶香，鲢鳙也喜欢', 8));
  list.push(makeFolkIng('coconut_milk', '椰汁', 'beverage',
    FlavorProfile.create(70, 0, 50, 0, 0, 0, 40, 0, 0), PhysicalProperties.create(9, 2, 2, 9),
    ['crucian', 'carp', 'grass_carp'], ['summer', 'autumn'],
    SimpleTemperatureRange.create(15, 35), DosageRange.create(30, 100, 'ml'),
    '网络偏方', 'safe', '椰香味，夏季尝试', 8));
  // 调味品类
  list.push(makeFolkIng('stinky_tofu_juice', '臭豆腐汁', 'fermented',
    FlavorProfile.create(0, 60, 0, 20, 0, 0, 0, 50, 100), PhysicalProperties.create(10, 1, 1, 10),
    ['crucian', 'carp', 'catfish', 'silver_carp', 'bighead_carp'], ['summer', 'autumn'],
    SimpleTemperatureRange.create(15, 35), DosageRange.create(10, 50, 'ml'),
    '民间偏方', 'caution', '臭味极重，鲢鳙最爱', 10));
  list.push(makeFolkIng('fermented_bean_curd', '腐乳汁', 'fermented',
    FlavorProfile.create(20, 40, 30, 10, 0, 0, 0, 60, 40), PhysicalProperties.create(9, 2, 2, 9),
    ['crucian', 'carp', 'bream', 'silver_carp'], ['spring', 'summer', 'autumn'],
    SimpleTemperatureRange.create(10, 35), DosageRange.create(10, 40, 'ml'),
    '民间常用', 'safe', '发酵香味，效果不错', 5));
  list.push(makeFolkIng('soy_sauce', '酱油', 'condiment',
    FlavorProfile.create(30, 50, 20, 0, 0, 0, 0, 40, 0), PhysicalProperties.create(10, 1, 1, 10),
    ['crucian', 'carp', 'bream'], ['spring', 'summer', 'autumn', 'winter'],
    SimpleTemperatureRange.create(5, 35), DosageRange.create(5, 20, 'ml'),
    '民间偏方', 'safe', '酱香味，少量使用', 3));
  list.push(makeFolkIng('oyster_sauce', '蚝油', 'condiment',
    FlavorProfile.create(20, 70, 30, 0, 15, 0, 0, 30, 0), PhysicalProperties.create(8, 3, 2, 8),
    ['crucian', 'carp', 'bream', 'catfish'], ['spring', 'summer', 'autumn', 'winter'],
    SimpleTemperatureRange.create(5, 35), DosageRange.create(5, 20, 'ml'),
    '民间偏方', 'safe', '鲜味浓，增加诱鱼效果', 8));
  list.push(makeFolkIng('shrimp_paste', '虾酱', 'fermented',
    FlavorProfile.create(0, 90, 0, 0, 30, 0, 0, 40, 30), PhysicalProperties.create(7, 4, 3, 7),
    ['crucian', 'carp', 'catfish', 'yellow_catfish'], ['spring', 'summer', 'autumn'],
    SimpleTemperatureRange.create(10, 35), DosageRange.create(5, 20, 'g'),
    '沿海地区', 'safe', '腥味浓郁，效果好', 15));
  list.push(makeFolkIng('fish_sauce', '鱼露', 'fermented',
    FlavorProfile.create(0, 95, 0, 0, 35, 0, 0, 30, 20), PhysicalProperties.create(10, 1, 1, 10),
    ['crucian', 'carp', 'catfish', 'yellow_catfish'], ['spring', 'summer', 'autumn'],
    SimpleTemperatureRange.create(10, 35), DosageRange.create(5, 15, 'ml'),
    '东南亚调料', 'safe', '鱼腥味极浓', 20));
  list.push(makeFolkIng('doubanjiang', '豆瓣酱', 'fermented',
    FlavorProfile.create(20, 40, 30, 0, 0, 0, 0, 70, 10), PhysicalProperties.create(7, 4, 3, 7),
    ['crucian', 'carp', 'bream'], ['spring', 'summer', 'autumn'],
    SimpleTemperatureRange.create(10, 35), DosageRange.create(5, 20, 'g'),
    '四川偏方', 'safe', '酱香味，川渝地区常用', 5));
  // 其他邪修
  list.push(makeFolkIng('pig_blood', '猪血', 'animal',
    FlavorProfile.create(0, 100, 0, 0, 60, 0, 0, 0, 20), PhysicalProperties.create(5, 5, 6, 5),
    ['catfish', 'snakehead', 'yellow_catfish', 'carp'], ['spring', 'summer', 'autumn'],
    SimpleTemperatureRange.create(10, 35), DosageRange.create(20, 100, 'g'),
    '民间偏方', 'caution', '血腥味极浓，肉食鱼专用', 5));
  list.push(makeFolkIng('chicken_intestine', '鸡肠', 'animal',
    FlavorProfile.create(0, 95, 0, 0, 55, 0, 0, 0, 30), PhysicalProperties.create(2, 3, 6, 2),
    ['catfish', 'snakehead', 'yellow_catfish', 'eel'], ['spring', 'summer', 'autumn'],
    SimpleTemperatureRange.create(10, 35), DosageRange.create(20, 100, 'g'),
    '民间偏方', 'safe', '腥臭味，钓鲶鱼神饵', 5));
  list.push(makeFolkIng('duck_liver', '鸭肝', 'animal',
    FlavorProfile.create(0, 90, 0, 0, 45, 0, 0, 0, 15), PhysicalProperties.create(2, 4, 7, 2),
    ['catfish', 'snakehead', 'yellow_catfish'], ['spring', 'summer', 'autumn'],
    SimpleTemperatureRange.create(10, 35), DosageRange.create(20, 80, 'g'),
    '民间偏方', 'safe', '腥味浓，肉食鱼喜欢', 8));
  list.push(makeFolkIng('soap', '肥皂水', 'other',
    FlavorProfile.create(30, 0, 50, 0, 0, 0, 0, 80, 0), PhysicalProperties.create(10, 1, 1, 10),
    ['crucian', 'carp'], ['summer'],
    SimpleTemperatureRange.create(25, 35), DosageRange.create(5, 15, 'ml'),
    '网络偏方', 'experimental', '香皂味，效果存疑，慎用', 2));
  list.push(makeFolkIng('toothpaste', '牙膏', 'other',
    FlavorProfile.create(40, 0, 30, 0, 0, 0, 0, 90, 0), PhysicalProperties.create(8, 3, 2, 8),
    ['crucian', 'carp'], ['summer'],
    SimpleTemperatureRange.create(25, 35), DosageRange.create(3, 10, 'g'),
    '网络偏方', 'experimental', '薄荷味，效果存疑，慎用', 3));
  list.push(makeFolkIng('garlic_juice', '蒜汁', 'condiment',
    FlavorProfile.create(0, 30, 0, 0, 0, 0, 0, 100, 10), PhysicalProperties.create(10, 1, 1, 10),
    ['crucian', 'carp', 'grass_carp', 'bream'], ['spring', 'summer', 'autumn', 'winter'],
    SimpleTemperatureRange.create(5, 35), DosageRange.create(5, 20, 'ml'),
    '民间常用', 'safe', '蒜香味，穿透力强', 3));
  list.push(makeFolkIng('ginger_juice', '姜汁', 'condiment',
    FlavorProfile.create(10, 20, 0, 0, 0, 0, 0, 80, 0), PhysicalProperties.create(10, 1, 1, 10),
    ['crucian', 'carp', 'catfish'], ['autumn', 'winter', 'spring'],
    SimpleTemperatureRange.create(5, 25), DosageRange.create(5, 15, 'ml'),
    '民间偏方', 'safe', '姜辣味，冬季效果好', 3));
  list.push(makeFolkIng('chili_oil', '辣椒油', 'oil',
    FlavorProfile.create(0, 20, 40, 0, 0, 0, 0, 90, 0), PhysicalProperties.create(8, 2, 2, 8),
    ['crucian', 'carp'], ['summer', 'autumn'],
    SimpleTemperatureRange.create(15, 35), DosageRange.create(3, 10, 'ml'),
    '四川偏方', 'experimental', '辣味刺激，效果存疑', 5));
  list.push(makeFolkIng('vinegar', '陈醋', 'fermented',
    FlavorProfile.create(10, 0, 0, 100, 0, 0, 0, 30, 10), PhysicalProperties.create(10, 1, 1, 10),
    ['silver_carp', 'bighead_carp', 'crucian'], ['summer', 'autumn'],
    SimpleTemperatureRange.create(15, 35), DosageRange.create(10, 50, 'ml'),
    '民间偏方', 'safe', '酸味浓，鲢鳙喜欢', 3));
  list.push(makeFolkIng('rice_wine', '米酒', 'beverage',
    FlavorProfile.create(50, 20, 40, 10, 0, 0, 30, 40, 0), PhysicalProperties.create(10, 1, 1, 10),
    ['crucian', 'carp', 'bream', 'grass_carp'], ['spring', 'summer', 'autumn'],
    SimpleTemperatureRange.create(10, 35), DosageRange.create(20, 80, 'ml'),
    '传统方法', 'safe', '酒酿香甜，效果好', 8));
  list.push(makeFolkIng('fermented_rice', '酒糟', 'fermented',
    FlavorProfile.create(60, 20, 50, 20, 0, 0, 40, 50, 10), PhysicalProperties.create(6, 4, 5, 6),
    ['crucian', 'carp', 'bream', 'grass_carp'], ['spring', 'summer', 'autumn'],
    SimpleTemperatureRange.create(10, 35), DosageRange.create(30, 100, 'g'),
    '传统方法', 'safe', '酒香浓郁，经典配方', 5));
  list.push(makeFolkIng('musk', '麝香', 'medicine',
    FlavorProfile.create(0, 30, 60, 0, 0, 0, 0, 100, 0), PhysicalProperties.create(10, 1, 1, 10),
    ['crucian', 'carp', 'bream', 'grass_carp'], ['spring', 'summer', 'autumn', 'winter'],
    SimpleTemperatureRange.create(5, 35), DosageRange.create(0.1, 0.5, 'g'),
    '古方秘药', 'caution', '香味极浓，用量极少，价格昂贵', 200));
  list.push(makeFolkIng('borneol', '冰片', 'medicine',
    FlavorProfile.create(0, 0, 30, 0, 0, 0, 0, 95, 0), PhysicalProperties.create(10, 1, 1, 10),
    ['crucian', 'carp', 'bream'], ['summer', 'autumn'],
    SimpleTemperatureRange.create(15, 35), DosageRange.create(0.5, 2, 'g'),
    '中药材', 'caution', '清凉香味，穿透力强', 50));
  return list;
}


// ==================== 数据库管理类 ====================
export class IngredientDatabase {
  private static instance: IngredientDatabase | null = null;
  private ingredients: Ingredient[] = [];
  private initialized: boolean = false;

  private constructor() {}

  static getInstance(): IngredientDatabase {
    if (IngredientDatabase.instance === null) {
      IngredientDatabase.instance = new IngredientDatabase();
    }
    return IngredientDatabase.instance;
  }

  initialize(): void {
    if (this.initialized) return;
    const base = getBaseIngredients();
    const protein = getProteinIngredients();
    const additive = getAdditiveIngredients();
    const state = getStateIngredients();
    const natural = getNaturalIngredients();
    const live = getLiveIngredients();
    const pellet = getPelletIngredients();
    const folk = getFolkIngredients();
    for (let i = 0; i < base.length; i++) this.ingredients.push(base[i]);
    for (let i = 0; i < protein.length; i++) this.ingredients.push(protein[i]);
    for (let i = 0; i < additive.length; i++) this.ingredients.push(additive[i]);
    for (let i = 0; i < state.length; i++) this.ingredients.push(state[i]);
    for (let i = 0; i < natural.length; i++) this.ingredients.push(natural[i]);
    for (let i = 0; i < live.length; i++) this.ingredients.push(live[i]);
    for (let i = 0; i < pellet.length; i++) this.ingredients.push(pellet[i]);
    for (let i = 0; i < folk.length; i++) this.ingredients.push(folk[i]);
    this.initialized = true;
  }

  getAllIngredients(): Ingredient[] {
    this.initialize();
    return this.ingredients;
  }

  getIngredientById(id: string): Ingredient | null {
    this.initialize();
    for (let i = 0; i < this.ingredients.length; i++) {
      if (this.ingredients[i].id === id) return this.ingredients[i];
    }
    return null;
  }

  getIngredientsByCategory(category: IngredientCategory): Ingredient[] {
    this.initialize();
    const result: Ingredient[] = [];
    for (let i = 0; i < this.ingredients.length; i++) {
      if (this.ingredients[i].category === category) result.push(this.ingredients[i]);
    }
    return result;
  }

  getIngredientsBySubCategory(subCategory: IngredientSubCategory): Ingredient[] {
    this.initialize();
    const result: Ingredient[] = [];
    for (let i = 0; i < this.ingredients.length; i++) {
      if (this.ingredients[i].subCategory === subCategory) result.push(this.ingredients[i]);
    }
    return result;
  }

  getIngredientsForFish(fishId: string): Ingredient[] {
    this.initialize();
    const result: Ingredient[] = [];
    for (let i = 0; i < this.ingredients.length; i++) {
      const ing = this.ingredients[i];
      for (let j = 0; j < ing.targetFish.length; j++) {
        if (ing.targetFish[j] === fishId) {
          result.push(ing);
          break;
        }
      }
    }
    return result;
  }

  getIngredientsBySeason(season: Season): Ingredient[] {
    this.initialize();
    const result: Ingredient[] = [];
    for (let i = 0; i < this.ingredients.length; i++) {
      const ing = this.ingredients[i];
      for (let j = 0; j < ing.suitableSeason.length; j++) {
        if (ing.suitableSeason[j] === season) {
          result.push(ing);
          break;
        }
      }
    }
    return result;
  }

  getIngredientsByTemperature(temp: number): Ingredient[] {
    this.initialize();
    const result: Ingredient[] = [];
    for (let i = 0; i < this.ingredients.length; i++) {
      const ing = this.ingredients[i];
      if (temp >= ing.temperatureRange.min && temp <= ing.temperatureRange.max) {
        result.push(ing);
      }
    }
    return result;
  }

  getFolkIngredients(): Ingredient[] {
    this.initialize();
    const result: Ingredient[] = [];
    for (let i = 0; i < this.ingredients.length; i++) {
      if (this.ingredients[i].isFolk) result.push(this.ingredients[i]);
    }
    return result;
  }

  getSafeIngredients(): Ingredient[] {
    this.initialize();
    const result: Ingredient[] = [];
    for (let i = 0; i < this.ingredients.length; i++) {
      if (this.ingredients[i].riskLevel === 'safe') result.push(this.ingredients[i]);
    }
    return result;
  }

  searchIngredients(keyword: string): Ingredient[] {
    this.initialize();
    const result: Ingredient[] = [];
    const lowerKeyword = keyword.toLowerCase();
    for (let i = 0; i < this.ingredients.length; i++) {
      const ing = this.ingredients[i];
      if (ing.name.toLowerCase().includes(lowerKeyword) ||
          ing.id.toLowerCase().includes(lowerKeyword) ||
          ing.notes.toLowerCase().includes(lowerKeyword)) {
        result.push(ing);
      }
    }
    return result;
  }

  getIngredientCount(): number {
    this.initialize();
    return this.ingredients.length;
  }

  getCategoryCount(category: IngredientCategory): number {
    return this.getIngredientsByCategory(category).length;
  }
}

// ==================== 便捷导出函数 ====================
export function getAllIngredients(): Ingredient[] {
  return IngredientDatabase.getInstance().getAllIngredients();
}

export function getIngredientById(id: string): Ingredient | null {
  return IngredientDatabase.getInstance().getIngredientById(id);
}

export function getIngredientsByCategory(category: IngredientCategory): Ingredient[] {
  return IngredientDatabase.getInstance().getIngredientsByCategory(category);
}

export function getIngredientsForFish(fishId: string): Ingredient[] {
  return IngredientDatabase.getInstance().getIngredientsForFish(fishId);
}

export function getIngredientsBySeason(season: Season): Ingredient[] {
  return IngredientDatabase.getInstance().getIngredientsBySeason(season);
}

export function searchIngredients(keyword: string): Ingredient[] {
  return IngredientDatabase.getInstance().searchIngredients(keyword);
}

export function getIngredientCount(): number {
  return IngredientDatabase.getInstance().getIngredientCount();
}

export function getIngredientNameMap(): Map<string, string> {
  const ingredients = IngredientDatabase.getInstance().getAllIngredients();
  const map = new Map<string, string>();
  for (let i = 0; i < ingredients.length; i++) {
    map.set(ingredients[i].id, ingredients[i].name);
  }
  return map;
}
