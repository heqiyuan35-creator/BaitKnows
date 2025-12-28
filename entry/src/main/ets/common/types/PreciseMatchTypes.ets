/**
 * 精确匹配功能 - 类型定义
 */
import { RecipeWaterType, RecipeSeason, GeneratedRecipe, RecipeIngredient } from './RecipeTypes';

// ==================== 高级参数类型 ====================

// 水深
export type WaterDepth = 'shallow' | 'medium' | 'deep';
export const WaterDepthNames: Record<WaterDepth, string> = {
  'shallow': '浅水(<1m)',
  'medium': '中层(1-3m)',
  'deep': '深水(>3m)'
};

// 水质
export type WaterQuality = 'clear' | 'slight_muddy' | 'muddy' | 'fertile';
export const WaterQualityNames: Record<WaterQuality, string> = {
  'clear': '清澈',
  'slight_muddy': '微浑',
  'muddy': '浑浊',
  'fertile': '肥水'
};

// 光照条件
export type LightCondition = 'bright' | 'cloudy' | 'dawn_dusk' | 'night';
export const LightConditionNames: Record<LightCondition, string> = {
  'bright': '强光',
  'cloudy': '阴天',
  'dawn_dusk': '晨昏',
  'night': '夜钓'
};

// 风力条件
export type WindCondition = 'none' | 'light' | 'medium' | 'strong';
export const WindConditionNames: Record<WindCondition, string> = {
  'none': '无风',
  'light': '微风',
  'medium': '中风',
  'strong': '大风'
};

// 饵料状态偏�?
export type BaitState = 'fast_dissolve' | 'slow_dissolve' | 'sticky' | 'dry_loose';
export const BaitStateNames: Record<BaitState, string> = {
  'fast_dissolve': '雾化�?,
  'slow_dissolve': '雾化�?,
  'sticky': '粘软',
  'dry_loose': '干散'
};

// 味型强度
export type FlavorIntensity = 'light' | 'medium' | 'strong' | 'intense';
export const FlavorIntensityNames: Record<FlavorIntensity, string> = {
  'light': '清淡',
  'medium': '适中',
  'strong': '浓郁',
  'intense': '刺激'
};

// 目标鱼体�?
export type FishSize = 'small' | 'medium' | 'large';
export const FishSizeNames: Record<FishSize, string> = {
  'small': '小型(<1�?',
  'medium': '中型(1-5�?',
  'large': '大型(>5�?'
};

// ==================== 精确匹配输入 ====================

export class PreciseMatchInput {
  // 基础参数
  targetFish: string = '';
  waterType: RecipeWaterType = 'river';
  season: RecipeSeason = 'spring';
  temperature: number = 20;

  // 高级参数
  waterDepth: WaterDepth = 'medium';
  waterQuality: WaterQuality = 'clear';
  lightCondition: LightCondition = 'bright';
  windCondition: WindCondition = 'none';
  baitState: BaitState = 'fast_dissolve';
  flavorIntensity: FlavorIntensity = 'medium';
  targetFishSize: FishSize = 'medium';

  constructor() {}
}

// ==================== 维度评分 ====================

export class DimensionScores {
  attraction: number = 0;      // 诱鱼�?0-100
  palatability: number = 0;    // 适口�?0-100
  state: number = 0;           // 状�?0-100
  retention: number = 0;       // 留鱼�?0-100
  costEffective: number = 0;   // 性价�?0-100

  constructor() {}

  // 计算平均�?
  getAverage(): number {
    return Math.round((this.attraction + this.palatability + this.state +
      this.retention + this.costEffective) / 5);
  }
}

// ==================== 参数权重 ====================

export class ParameterWeight {
  name: string = '';           // 参数名称
  weight: number = 0;          // 权重�?0-100
  impact: string = '';         // 影响说明

  constructor() {}

  static create(name: string, weight: number, impact: string): ParameterWeight {
    const p = new ParameterWeight();
    p.name = name;
    p.weight = weight;
    p.impact = impact;
    return p;
  }
}

// ==================== 分析步骤 ====================

export class AnalysisStep {
  step: number = 0;
  title: string = '';
  description: string = '';
  keyData: string = '';
  progress: number = 0;        // 0-100

  constructor() {}

  static create(step: number, title: string, desc: string, data: string): AnalysisStep {
    const s = new AnalysisStep();
    s.step = step;
    s.title = title;
    s.description = desc;
    s.keyData = data;
    s.progress = step * 20;
    return s;
  }
}

// ==================== 原料配比 ====================

export class IngredientRatio {
  name: string = '';
  category: string = '';       // 基础�?主攻�?状态饵/添加�?
  percentage: number = 0;
  color: string = '#E6A23C';

  constructor() {}

  static create(name: string, category: string, percentage: number, color: string): IngredientRatio {
    const r = new IngredientRatio();
    r.name = name;
    r.category = category;
    r.percentage = percentage;
    r.color = color;
    return r;
  }
}

// ==================== 精确匹配结果 ====================

export class PreciseMatchResult {
  recipe: GeneratedRecipe = new GeneratedRecipe();
  matchScore: number = 0;                          // 0-100 匹配�?
  dimensionScores: DimensionScores = new DimensionScores();
  parameterWeights: ParameterWeight[] = [];
  analysisSteps: AnalysisStep[] = [];
  ingredientRatios: IngredientRatio[] = [];
  alternatives: GeneratedRecipe[] = [];            // 备选方�?
  scoreDescription: string = '';                   // 评分说明

  constructor() {}

  // 获取评分等级描述
  getScoreLevel(): string {
    if (this.matchScore >= 90) return '非常适合当前钓况';
    if (this.matchScore >= 80) return '很适合当前钓况';
    if (this.matchScore >= 70) return '适合当前钓况';
    if (this.matchScore >= 60) return '基本适合';
    return '建议调整参数';
  }
}

// ==================== 反馈选项 ====================

export type FeedbackType = 'flavor_dislike' | 'ingredient_hard' | 'state_wrong' |
  'want_more_fishy' | 'want_more_fragrant' | 'want_lighter' | 'other';

export class FeedbackOption {
  id: FeedbackType = 'other';
  label: string = '';
  icon: string = '';
  adjustmentType: string = '';  // flavor/ingredient/state/intensity

  constructor() {}

  static create(id: FeedbackType, label: string, icon: string, type: string): FeedbackOption {
    const f = new FeedbackOption();
    f.id = id;
    f.label = label;
    f.icon = icon;
    f.adjustmentType = type;
    return f;
  }
}

// 预定义反馈选项
export const FEEDBACK_OPTIONS: FeedbackOption[] = [
  FeedbackOption.create('flavor_dislike', '味型不喜�?, '👃', 'flavor'),
  FeedbackOption.create('ingredient_hard', '原料难获�?, '🛒', 'ingredient'),
  FeedbackOption.create('state_wrong', '状态不合�?, '💧', 'state'),
  FeedbackOption.create('want_more_fishy', '想要更腥', '🐟', 'intensity'),
  FeedbackOption.create('want_more_fragrant', '想要更香', '🌸', 'intensity'),
  FeedbackOption.create('want_lighter', '想要更淡', '💨', 'intensity'),
  FeedbackOption.create('other', '其他原因', '💬', 'other')
];

// ==================== 用户反馈记录 ====================

export class UserFeedback {
  recipeId: string = '';
  feedbackTypes: FeedbackType[] = [];
  otherReason: string = '';
  timestamp: number = 0;

  constructor() {}
}
