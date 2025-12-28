/**
 * 智能配方生成相关类型定义
 */

// 水域类型
export type RecipeWaterType = 'river' | 'pond' | 'reservoir' | 'wild_pond';

// 季节
export type RecipeSeason = 'spring' | 'summer' | 'autumn' | 'winter';

// 作钓方式
export type FishingMethod = 'rub' | 'pull' | 'scatter' | 'wrap';

// 生成模式
export type GenerateMode = 'conservative' | 'balanced' | 'aggressive';

// 鱼密�?
export type FishDensity = 'high' | 'medium' | 'low';

// 开口情�?
export type FishActivity = 'good' | 'normal' | 'poor';

// 配方原料分类
export type RecipeIngredientCategory = 'main' | 'auxiliary' | 'state' | 'additive';

// 味型修正
export class FlavorModifier {
  fishy: number = 0;
  fragrant: number = 0;
  sweet: number = 0;
  sour: number = 0;
  stinky: number = 0;
  constructor() {}
  static create(fi: number, fr: number, sw: number, so: number, st: number): FlavorModifier {
    const m = new FlavorModifier();
    m.fishy = fi; m.fragrant = fr; m.sweet = sw; m.sour = so; m.stinky = st;
    return m;
  }
}

// 状态修�?
export class StateModifier {
  atomization: number = 0;
  viscosity: number = 0;
  intensity: number = 0;
  constructor() {}
  static create(atom: number, visc: number, inten: number): StateModifier {
    const m = new StateModifier();
    m.atomization = atom; m.viscosity = visc; m.intensity = inten;
    return m;
  }
}


// 季节修正映射
export class SeasonModifierMap {
  spring: FlavorModifier = new FlavorModifier();
  summer: FlavorModifier = new FlavorModifier();
  autumn: FlavorModifier = new FlavorModifier();
  winter: FlavorModifier = new FlavorModifier();
  constructor() {}
}

// 水域修正映射
export class WaterModifierMap {
  river: StateModifier = new StateModifier();
  pond: StateModifier = new StateModifier();
  reservoir: StateModifier = new StateModifier();
  wild_pond: StateModifier = new StateModifier();
  constructor() {}
}

// 推荐原料
export class IngredientRecommend {
  main: string[] = [];
  auxiliary: string[] = [];
  state: string[] = [];
  additive: string[] = [];
  constructor() {}
}

// 鱼种配方规则
export class FishRecipeRule {
  fishId: string = '';
  fishName: string = '';
  baseFlavor: FlavorModifier = new FlavorModifier();
  seasonModifier: SeasonModifierMap = new SeasonModifierMap();
  waterModifier: WaterModifierMap = new WaterModifierMap();
  recommendedIngredients: IngredientRecommend = new IngredientRecommend();
  constructor() {}
}

// 温度规则
export class TemperatureRule {
  minTemp: number = 0;
  maxTemp: number = 40;
  flavorModifier: FlavorModifier = new FlavorModifier();
  stateModifier: StateModifier = new StateModifier();
  description: string = '';
  constructor() {}
}

// 生成配方输入
export class GenerateRecipeInput {
  targetFishId: string = '';
  waterType: RecipeWaterType = 'river';
  temperature: number = 20;
  season: RecipeSeason = 'spring';
  fishDensity: FishDensity = 'medium';
  fishActivity: FishActivity = 'normal';
  fishingMethod: FishingMethod = 'rub';
  availableBaits: string[] = [];
  mode: GenerateMode = 'balanced';
  constructor() {}
}


// 配方原料
export class RecipeIngredient {
  id: string = '';
  name: string = '';
  category: RecipeIngredientCategory = 'main';
  percentage: number = 0;
  weight: number = 0;
  purpose: string = '';
  constructor() {}
}

// 味型说明
export class FlavorDescription {
  primary: string = '';
  secondary: string = '';
  intensity: number = 5;
  suitableTemp: string = '';
  constructor() {}
}

// 状态特�?
export class StateProfile {
  atomization: number = 3;
  viscosity: number = 3;
  hookHolding: number = 3;
  weight: number = 3;
  constructor() {}
}

// 使用建议
export class UsageSuggestion {
  waterRatio: string = '1:1';
  restTime: string = '5-10分钟';
  firstCast: string = '';
  nestSuggestion: string = '';
  constructor() {}
}

// 生成理由
export class GenerateReason {
  condition: string = '';
  decision: string = '';
  icon: string = '';
  constructor() {}
}

// 生成的配�?
export class GeneratedRecipe {
  id: string = '';
  name: string = '';
  ingredients: RecipeIngredient[] = [];
  totalWeight: number = 500;
  flavorProfile: FlavorDescription = new FlavorDescription();
  stateProfile: StateProfile = new StateProfile();
  usage: UsageSuggestion = new UsageSuggestion();
  reasons: GenerateReason[] = [];
  conditions: GenerateRecipeInput = new GenerateRecipeInput();
  createTime: number = 0;
  mode: string = 'balanced';
  constructor() {}
}

// 配方反馈
export class RecipeFeedback {
  recipeId: string = '';
  rating: string = 'normal';
  note: string = '';
  createTime: number = 0;
  constructor() {}
}


// 模式修正
export class ModeModifier {
  flavorScale: number = 1.0;
  atomizationBias: number = 0;
  constructor() {}
  static create(scale: number, bias: number): ModeModifier {
    const m = new ModeModifier();
    m.flavorScale = scale;
    m.atomizationBias = bias;
    return m;
  }
}

// 理由模板
export class ReasonTemplate {
  condition: string = '';
  decision: string = '';
  icon: string = '';
  constructor() {}
  static create(cond: string, dec: string, ic: string): ReasonTemplate {
    const t = new ReasonTemplate();
    t.condition = cond;
    t.decision = dec;
    t.icon = ic;
    return t;
  }
}
