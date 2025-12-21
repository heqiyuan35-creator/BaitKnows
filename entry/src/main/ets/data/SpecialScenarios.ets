/**
 * 特殊场景规则
 * 定义各种特殊钓鱼场景的配方调整规则
 */
import { FlavorModifier, StateModifier } from '../common/types/RecipeTypes';

// 特殊场景类型
export type ScenarioType =
  'extreme_cold' |      // 极寒 (<5°C)
  'very_cold' |         // 很冷 (5-10°C)
  'cold' |              // 冷 (10-15°C)
  'warm' |              // 温暖 (15-25°C)
  'hot' |               // 热 (25-30°C)
  'extreme_hot' |       // 极热 (>30°C)
  'carnivore' |         // 肉食性鱼类
  'herbivore' |         // 草食性鱼类
  'omnivore' |          // 杂食性鱼类
  'filter_feeder' |     // 滤食性鱼类 (鲢鳙)
  'black_pit_new' |     // 黑坑新放鱼
  'black_pit_old' |     // 黑坑老鱼/滑口鱼
  'black_pit_competition' | // 黑坑竞技
  'wild_river_flow' |   // 野河流水
  'wild_river_still' |  // 野河静水
  'reservoir_shallow' | // 水库浅水
  'reservoir_deep' |    // 水库深水
  'night_fishing' |     // 夜钓
  'dawn_fishing' |      // 早钓 (天亮前后)
  'noon_fishing' |      // 午钓 (中午高温)
  'rainy' |             // 雨天
  'after_rain' |        // 雨后
  'windy' |             // 大风天
  'pressure_low' |      // 低气压
  'pressure_high' |     // 高气压
  'muddy_water' |       // 浑水
  'clear_water' |       // 清水
  'algae_bloom';        // 水华/藻类爆发

// 场景规则
export class ScenarioRule {
  scenarioType: ScenarioType = 'warm';
  name: string = '';
  description: string = '';
  flavorModifier: FlavorModifier = new FlavorModifier();
  stateModifier: StateModifier = new StateModifier();
  recommendedIngredients: string[] = [];
  avoidIngredients: string[] = [];
  tips: string[] = [];
  priority: number = 0;  // 优先级，数值越高越优先应用

  constructor() {}
}

// 创建场景规则的辅助函数
function createRule(
  type: ScenarioType,
  name: string,
  desc: string,
  flavorMod: FlavorModifier,
  stateMod: StateModifier,
  recommended: string[],
  avoid: string[],
  tips: string[],
  priority: number
): ScenarioRule {
  const rule = new ScenarioRule();
  rule.scenarioType = type;
  rule.name = name;
  rule.description = desc;
  rule.flavorModifier = flavorMod;
  rule.stateModifier = stateMod;
  rule.recommendedIngredients = recommended;
  rule.avoidIngredients = avoid;
  rule.tips = tips;
  rule.priority = priority;
  return rule;
}

// ==================== 温度相关场景 ====================
function getTemperatureScenarios(): ScenarioRule[] {
  const rules: ScenarioRule[] = [];

  // 极寒场景 (<5°C)
  rules.push(createRule(
    'extreme_cold',
    '极寒天气',
    '水温极低，鱼活性极差，需要高腥高蛋白刺激',
    FlavorModifier.create(50, 20, 15, -20, 10),
    StateModifier.create(-30, 25, 20),
    ['bloodworm_powder', 'earthworm_powder', 'fish_meal', 'shrimp_powder', 'liver_powder'],
    ['citric_acid', 'lactic_acid', 'light_bran'],
    ['使用活红虫效果最佳', '饵料状态要软粘', '小饵慢频率', '选择向阳背风钓位'],
    100
  ));

  // 很冷场景 (5-10°C)
  rules.push(createRule(
    'very_cold',
    '低温天气',
    '水温较低，鱼开口慢，需要浓腥浓香',
    FlavorModifier.create(35, 15, 10, -10, 5),
    StateModifier.create(-20, 15, 15),
    ['bloodworm_powder', 'fish_meal', 'shrimp_powder', 'silkworm_pupa_powder'],
    ['citric_acid', 'snowflake_powder'],
    ['腥香为主', '适当增加小药用量', '耐心等口'],
    90
  ));

  // 冷场景 (10-15°C)
  rules.push(createRule(
    'cold',
    '凉爽天气',
    '水温偏低，适当增腥',
    FlavorModifier.create(20, 10, 5, 0, 0),
    StateModifier.create(-10, 10, 10),
    ['fish_meal', 'shrimp_powder', 'earthworm_powder'],
    [],
    ['腥香搭配', '状态适中'],
    80
  ));

  // 温暖场景 (15-25°C)
  rules.push(createRule(
    'warm',
    '适宜天气',
    '水温适宜，鱼活性好，味型均衡',
    FlavorModifier.create(0, 0, 0, 0, 0),
    StateModifier.create(0, 0, 0),
    [],
    [],
    ['根据鱼种调整味型', '状态根据钓法调整'],
    50
  ));

  // 热场景 (25-30°C)
  rules.push(createRule(
    'hot',
    '高温天气',
    '水温较高，鱼食欲下降，需要清淡配方',
    FlavorModifier.create(-25, 10, -15, 25, 0),
    StateModifier.create(15, -15, -10),
    ['citric_acid', 'lactic_acid', 'strawberry_essence', 'banana_essence'],
    ['fish_meal', 'blood_meal', 'liver_powder'],
    ['清淡果酸为主', '早晚出钓效果好', '选择阴凉钓位'],
    85
  ));

  // 极热场景 (>30°C)
  rules.push(createRule(
    'extreme_hot',
    '酷暑天气',
    '水温极高，鱼躲避高温，需要极清淡配方',
    FlavorModifier.create(-40, 5, -25, 35, 0),
    StateModifier.create(25, -25, -20),
    ['citric_acid', 'lactic_acid', 'acetic_acid', 'yogurt', 'cola'],
    ['fish_meal', 'blood_meal', 'shrimp_powder', 'earthworm_powder'],
    ['果酸为主', '凌晨或傍晚出钓', '深水或阴凉处', '可尝试钓浮'],
    95
  ));

  return rules;
}


// ==================== 鱼类食性场景 ====================
function getFishTypeScenarios(): ScenarioRule[] {
  const rules: ScenarioRule[] = [];

  // 肉食性鱼类
  rules.push(createRule(
    'carnivore',
    '肉食性鱼类',
    '鲶鱼、黑鱼、鳜鱼等肉食性鱼类，需要浓腥配方',
    FlavorModifier.create(40, -10, -20, 0, 30),
    StateModifier.create(-15, 15, 15),
    ['fish_meal', 'blood_meal', 'liver_powder', 'earthworm_powder', 'shrimp_powder', 'squid_powder'],
    ['corn_flour', 'sweet_potato_flour', 'vanilla_essence', 'strawberry_essence'],
    ['活饵效果最佳', '腥臭味型为主', '饵料要有韧性', '夜钓效果好'],
    70
  ));

  // 草食性鱼类
  rules.push(createRule(
    'herbivore',
    '草食性鱼类',
    '草鱼等草食性鱼类，需要香甜酸配方',
    FlavorModifier.create(-20, 25, 20, 20, 0),
    StateModifier.create(10, -10, -5),
    ['corn_flour', 'wheat_bran', 'sweet_potato_flour', 'tender_grass', 'mulberry', 'citric_acid'],
    ['fish_meal', 'blood_meal', 'liver_powder'],
    ['嫩草、桑葚等天然饵效果好', '发酵饵诱鱼效果佳', '夏季果酸味型'],
    70
  ));

  // 杂食性鱼类
  rules.push(createRule(
    'omnivore',
    '杂食性鱼类',
    '鲫鱼、鲤鱼等杂食性鱼类，味型均衡',
    FlavorModifier.create(0, 0, 0, 0, 0),
    StateModifier.create(0, 0, 0),
    [],
    [],
    ['根据季节调整味型', '腥香甜搭配'],
    50
  ));

  // 滤食性鱼类
  rules.push(createRule(
    'filter_feeder',
    '滤食性鱼类',
    '鲢鱼、鳙鱼等滤食性鱼类，需要酸臭雾化配方',
    FlavorModifier.create(-10, 0, -20, 50, 60),
    StateModifier.create(40, -30, -25),
    ['wheat_bran', 'rice_bran', 'citric_acid', 'lactic_acid', 'acetic_acid', 'stinky_tofu_juice', 'garlic_essence'],
    ['drawing_powder', 'sticky_powder', 'heavy_powder'],
    ['酸臭味型为主', '极快雾化', '钓浮或钓半水', '大饵团抽窝'],
    75
  ));

  return rules;
}

// ==================== 黑坑场景 ====================
function getBlackPitScenarios(): ScenarioRule[] {
  const rules: ScenarioRule[] = [];

  // 黑坑新放鱼
  rules.push(createRule(
    'black_pit_new',
    '黑坑新放鱼',
    '刚放的生口鱼，抢鱼为主',
    FlavorModifier.create(15, 20, 10, 0, 0),
    StateModifier.create(25, -15, -10),
    ['dmpt', 'betaine', 'amino_acid', 'fishy_essence', 'honey_essence'],
    [],
    ['快雾化抢鱼', '可适当加小药', '频率要快', '抢占好钓位'],
    85
  ));

  // 黑坑老鱼/滑口鱼
  rules.push(createRule(
    'black_pit_old',
    '黑坑老鱼',
    '被钓过多次的滑口鱼，需要本味配方',
    FlavorModifier.create(-20, -15, -10, 0, 0),
    StateModifier.create(-20, 15, 10),
    ['corn_flour', 'wheat_bran', 'soybean_flour', 'pellet_powder'],
    ['dmpt', 'fishy_essence', 'vanilla_essence'],
    ['本味为主', '减少小药', '慢雾化', '细线小钩', '耐心守钓'],
    85
  ));

  // 黑坑竞技
  rules.push(createRule(
    'black_pit_competition',
    '黑坑竞技',
    '竞技比赛，需要快速诱鱼',
    FlavorModifier.create(20, 25, 15, 0, 0),
    StateModifier.create(30, -20, -15),
    ['dmpt', 'betaine', 'amino_acid', 'snowflake_powder', 'light_bran'],
    ['sticky_powder', 'heavy_powder'],
    ['极快雾化', '高频率抽窝', '小药适量', '注意比赛规则'],
    90
  ));

  return rules;
}

// ==================== 野钓场景 ====================
function getWildFishingScenarios(): ScenarioRule[] {
  const rules: ScenarioRule[] = [];

  // 野河流水
  rules.push(createRule(
    'wild_river_flow',
    '野河流水',
    '有水流的野河，需要增加粘度和比重',
    FlavorModifier.create(5, 5, 0, 0, 0),
    StateModifier.create(-25, 30, 25),
    ['sticky_powder', 'heavy_powder', 'glutinous_rice_flour', 'drawing_powder'],
    ['snowflake_powder', 'light_bran', 'puffed_corn'],
    ['增加粘度防冲散', '重比重快到底', '选择回水湾', '走漂钓法'],
    80
  ));

  // 野河静水
  rules.push(createRule(
    'wild_river_still',
    '野河静水',
    '静水区域的野河，状态适中',
    FlavorModifier.create(0, 0, 0, 0, 0),
    StateModifier.create(0, 5, 5),
    [],
    [],
    ['状态适中', '酒米打窝效果好', '选择水草边'],
    60
  ));

  // 水库浅水
  rules.push(createRule(
    'reservoir_shallow',
    '水库浅水',
    '水库浅水区，适合钓小型鱼',
    FlavorModifier.create(5, 10, 5, 0, 0),
    StateModifier.create(10, -5, -5),
    ['snowflake_powder', 'light_bran'],
    ['heavy_powder'],
    ['雾化适中', '小饵为主', '注意惊鱼'],
    65
  ));

  // 水库深水
  rules.push(createRule(
    'reservoir_deep',
    '水库深水',
    '水库深水区，适合守钓大鱼',
    FlavorModifier.create(10, 15, 10, 0, 5),
    StateModifier.create(-20, 20, 25),
    ['heavy_powder', 'sticky_powder', 'corn_kernel', 'wheat_kernel'],
    ['snowflake_powder', 'light_bran'],
    ['重比重快到底', '大饵守钓', '打重窝', '耐心等待'],
    75
  ));

  return rules;
}

// ==================== 时段场景 ====================
function getTimePeriodScenarios(): ScenarioRule[] {
  const rules: ScenarioRule[] = [];

  // 夜钓
  rules.push(createRule(
    'night_fishing',
    '夜钓',
    '夜间钓鱼，鱼靠嗅觉觅食',
    FlavorModifier.create(15, 20, 10, 0, 10),
    StateModifier.create(-10, 10, 5),
    ['fishy_essence', 'garlic_essence', 'dmpt', 'earthworm', 'bloodworm'],
    [],
    ['味型要浓', '活饵效果好', '注意安全', '带好照明'],
    70
  ));

  // 早钓
  rules.push(createRule(
    'dawn_fishing',
    '早钓',
    '天亮前后，鱼活性开始增加',
    FlavorModifier.create(10, 10, 5, 0, 0),
    StateModifier.create(5, 0, 0),
    [],
    [],
    ['黄金时段', '鱼开口积极', '抓紧时间'],
    65
  ));

  // 午钓
  rules.push(createRule(
    'noon_fishing',
    '午钓',
    '中午高温时段，鱼活性下降',
    FlavorModifier.create(-15, 5, -10, 15, 0),
    StateModifier.create(10, -10, -5),
    ['citric_acid', 'lactic_acid'],
    ['fish_meal', 'blood_meal'],
    ['清淡为主', '选择阴凉处', '可尝试钓浮', '耐心等待'],
    70
  ));

  return rules;
}

// ==================== 天气场景 ====================
function getWeatherScenarios(): ScenarioRule[] {
  const rules: ScenarioRule[] = [];

  // 雨天
  rules.push(createRule(
    'rainy',
    '雨天',
    '下雨天气，水中溶氧增加',
    FlavorModifier.create(5, 5, 0, 5, 0),
    StateModifier.create(5, 0, 0),
    [],
    [],
    ['小雨天鱼开口好', '注意防滑', '选择避雨钓位'],
    60
  ));

  // 雨后
  rules.push(createRule(
    'after_rain',
    '雨后',
    '雨后水位上涨，鱼靠边觅食',
    FlavorModifier.create(10, 10, 5, 0, 0),
    StateModifier.create(5, 5, 0),
    ['earthworm', 'earthworm_powder'],
    [],
    ['雨后黄金时段', '钓近钓边', '蚯蚓效果极佳'],
    75
  ));

  // 大风天
  rules.push(createRule(
    'windy',
    '大风天',
    '风大浪大，需要增加比重',
    FlavorModifier.create(5, 5, 0, 0, 0),
    StateModifier.create(-15, 15, 20),
    ['heavy_powder', 'sticky_powder'],
    ['snowflake_powder', 'light_bran'],
    ['增加比重', '选择背风处', '注意安全'],
    70
  ));

  // 低气压
  rules.push(createRule(
    'pressure_low',
    '低气压',
    '气压低，水中溶氧不足，鱼开口差',
    FlavorModifier.create(-10, -5, -5, 10, 0),
    StateModifier.create(10, -10, -10),
    ['citric_acid', 'lactic_acid'],
    ['fish_meal', 'blood_meal'],
    ['鱼开口差', '清淡为主', '可尝试钓浮', '耐心等待'],
    80
  ));

  // 高气压
  rules.push(createRule(
    'pressure_high',
    '高气压',
    '气压高，水中溶氧充足，鱼活性好',
    FlavorModifier.create(5, 5, 5, 0, 0),
    StateModifier.create(5, 0, 0),
    [],
    [],
    ['鱼开口好', '正常配方即可'],
    55
  ));

  return rules;
}

// ==================== 水质场景 ====================
function getWaterQualityScenarios(): ScenarioRule[] {
  const rules: ScenarioRule[] = [];

  // 浑水
  rules.push(createRule(
    'muddy_water',
    '浑水',
    '水质浑浊，鱼靠嗅觉觅食',
    FlavorModifier.create(20, 15, 10, 0, 10),
    StateModifier.create(-10, 10, 10),
    ['fishy_essence', 'garlic_essence', 'dmpt', 'fish_meal', 'shrimp_powder'],
    [],
    ['味型要浓', '颜色鲜艳的饵料', '增加诱食剂'],
    75
  ));

  // 清水
  rules.push(createRule(
    'clear_water',
    '清水',
    '水质清澈，鱼警惕性高',
    FlavorModifier.create(-10, -5, -5, 0, 0),
    StateModifier.create(-5, 5, 5),
    [],
    ['dmpt', 'fishy_essence'],
    ['味型要淡', '细线小钩', '注意隐蔽', '自然饵效果好'],
    70
  ));

  // 水华/藻类爆发
  rules.push(createRule(
    'algae_bloom',
    '水华',
    '藻类爆发，水中溶氧不稳定',
    FlavorModifier.create(-15, 0, -10, 15, 0),
    StateModifier.create(15, -15, -10),
    ['citric_acid', 'lactic_acid'],
    ['fish_meal', 'blood_meal'],
    ['鱼可能缺氧', '清淡果酸', '选择进水口', '早晚出钓'],
    80
  ));

  return rules;
}


// ==================== 场景规则数据库 ====================
class ScenarioRulesDatabase {
  private static instance: ScenarioRulesDatabase | null = null;
  private rules: ScenarioRule[] = [];
  private ruleMap: Map<ScenarioType, ScenarioRule> = new Map();
  private initialized: boolean = false;

  private constructor() {}

  static getInstance(): ScenarioRulesDatabase {
    if (ScenarioRulesDatabase.instance === null) {
      ScenarioRulesDatabase.instance = new ScenarioRulesDatabase();
    }
    return ScenarioRulesDatabase.instance;
  }

  initialize(): void {
    if (this.initialized) return;

    // 加载所有场景规则
    const tempRules = getTemperatureScenarios();
    const fishRules = getFishTypeScenarios();
    const pitRules = getBlackPitScenarios();
    const wildRules = getWildFishingScenarios();
    const timeRules = getTimePeriodScenarios();
    const weatherRules = getWeatherScenarios();
    const waterRules = getWaterQualityScenarios();

    for (let i = 0; i < tempRules.length; i++) {
      this.rules.push(tempRules[i]);
      this.ruleMap.set(tempRules[i].scenarioType, tempRules[i]);
    }
    for (let i = 0; i < fishRules.length; i++) {
      this.rules.push(fishRules[i]);
      this.ruleMap.set(fishRules[i].scenarioType, fishRules[i]);
    }
    for (let i = 0; i < pitRules.length; i++) {
      this.rules.push(pitRules[i]);
      this.ruleMap.set(pitRules[i].scenarioType, pitRules[i]);
    }
    for (let i = 0; i < wildRules.length; i++) {
      this.rules.push(wildRules[i]);
      this.ruleMap.set(wildRules[i].scenarioType, wildRules[i]);
    }
    for (let i = 0; i < timeRules.length; i++) {
      this.rules.push(timeRules[i]);
      this.ruleMap.set(timeRules[i].scenarioType, timeRules[i]);
    }
    for (let i = 0; i < weatherRules.length; i++) {
      this.rules.push(weatherRules[i]);
      this.ruleMap.set(weatherRules[i].scenarioType, weatherRules[i]);
    }
    for (let i = 0; i < waterRules.length; i++) {
      this.rules.push(waterRules[i]);
      this.ruleMap.set(waterRules[i].scenarioType, waterRules[i]);
    }

    this.initialized = true;
  }

  getRule(scenarioType: ScenarioType): ScenarioRule | null {
    this.initialize();
    return this.ruleMap.get(scenarioType) || null;
  }

  getAllRules(): ScenarioRule[] {
    this.initialize();
    return this.rules;
  }

  getRulesByPriority(minPriority: number = 0): ScenarioRule[] {
    this.initialize();
    const result: ScenarioRule[] = [];
    for (let i = 0; i < this.rules.length; i++) {
      if (this.rules[i].priority >= minPriority) {
        result.push(this.rules[i]);
      }
    }
    // 按优先级排序
    result.sort((a, b) => b.priority - a.priority);
    return result;
  }

  getTemperatureScenario(temp: number): ScenarioType {
    if (temp < 5) return 'extreme_cold';
    if (temp < 10) return 'very_cold';
    if (temp < 15) return 'cold';
    if (temp < 25) return 'warm';
    if (temp < 30) return 'hot';
    return 'extreme_hot';
  }

  getRuleCount(): number {
    this.initialize();
    return this.rules.length;
  }
}

// 导出单例
export const scenarioRulesDatabase = ScenarioRulesDatabase.getInstance();

// 导出便捷函数
export function getScenarioRule(scenarioType: ScenarioType): ScenarioRule | null {
  return scenarioRulesDatabase.getRule(scenarioType);
}

export function getAllScenarioRules(): ScenarioRule[] {
  return scenarioRulesDatabase.getAllRules();
}

export function getTemperatureScenario(temp: number): ScenarioType {
  return scenarioRulesDatabase.getTemperatureScenario(temp);
}

export function getScenarioRulesByPriority(minPriority: number = 0): ScenarioRule[] {
  return scenarioRulesDatabase.getRulesByPriority(minPriority);
}
