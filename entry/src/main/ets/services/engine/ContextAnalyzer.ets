/**
 * 环境分析器
 * 负责分析输入的环境条件，生成味型权重和状态权重
 */
import {
  GenerateRecipeInput, FlavorModifier, StateModifier,
  FishRecipeRule, RecipeSeason, RecipeWaterType
} from '../../common/types/RecipeTypes';
import { getFishRule, getTemperatureRule, getDensityModifier, getActivityModifier, getModeModifier, getMethodModifier } from '../../data/RecipeRules';

// 味型权重
export class FlavorWeights {
  fishy: number = 0;      // 腥
  fragrant: number = 0;   // 香
  sweet: number = 0;      // 甜
  sour: number = 0;       // 酸
  stinky: number = 0;     // 臭

  constructor() {}

  static create(fi: number, fr: number, sw: number, so: number, st: number): FlavorWeights {
    const w = new FlavorWeights();
    w.fishy = fi; w.fragrant = fr; w.sweet = sw; w.sour = so; w.stinky = st;
    return w;
  }

  clone(): FlavorWeights {
    return FlavorWeights.create(this.fishy, this.fragrant, this.sweet, this.sour, this.stinky);
  }

  // 获取主味型
  getPrimaryFlavor(): string {
    let max = this.fishy;
    let primary = '腥';
    if (this.fragrant > max) { max = this.fragrant; primary = '香'; }
    if (this.sweet > max) { max = this.sweet; primary = '甜'; }
    if (this.sour > max) { max = this.sour; primary = '酸'; }
    if (this.stinky > max) { max = this.stinky; primary = '臭'; }
    return primary;
  }

  // 获取次味型
  getSecondaryFlavor(): string {
    const primary = this.getPrimaryFlavor();
    let max = -1;
    let secondary = '';
    if (primary !== '腥' && this.fishy > max) { max = this.fishy; secondary = '腥'; }
    if (primary !== '香' && this.fragrant > max) { max = this.fragrant; secondary = '香'; }
    if (primary !== '甜' && this.sweet > max) { max = this.sweet; secondary = '甜'; }
    if (primary !== '酸' && this.sour > max) { max = this.sour; secondary = '酸'; }
    if (primary !== '臭' && this.stinky > max) { max = this.stinky; secondary = '臭'; }
    return secondary;
  }

  // 计算总强度
  getTotalIntensity(): number {
    return this.fishy + this.fragrant + this.sweet + this.sour + this.stinky;
  }
}

// 状态权重
export class StateWeights {
  atomization: number = 50;  // 雾化 (0-100, 高=快雾化)
  viscosity: number = 50;    // 粘度 (0-100, 高=粘)
  weight: number = 50;       // 比重 (0-100, 高=重)

  constructor() {}

  static create(atom: number, visc: number, wt: number): StateWeights {
    const w = new StateWeights();
    w.atomization = atom; w.viscosity = visc; w.weight = wt;
    return w;
  }

  clone(): StateWeights {
    return StateWeights.create(this.atomization, this.viscosity, this.weight);
  }
}

// 特殊场景类型
export type SpecialScenario =
  'extreme_cold' |      // 极寒 (<5°C)
  'extreme_hot' |       // 极热 (>30°C)
  'carnivore_fish' |    // 肉食性鱼类
  'black_pit_new' |     // 黑坑新放鱼
  'black_pit_old' |     // 黑坑老鱼
  'flowing_water' |     // 流水环境
  'deep_water' |        // 深水区
  'night_fishing' |     // 夜钓
  'competition';        // 竞技钓

// 分析结果
export class AnalysisResult {
  flavorWeights: FlavorWeights = new FlavorWeights();
  stateWeights: StateWeights = new StateWeights();
  priorityFactors: string[] = [];       // 优先考虑的因素
  specialScenarios: SpecialScenario[] = [];  // 特殊场景标记
  fishRule: FishRecipeRule | null = null;
  analysisNotes: string[] = [];         // 分析备注

  constructor() {}
}

// 环境分析器
export class ContextAnalyzer {
  private static instance: ContextAnalyzer | null = null;

  private constructor() {}

  static getInstance(): ContextAnalyzer {
    if (ContextAnalyzer.instance === null) {
      ContextAnalyzer.instance = new ContextAnalyzer();
    }
    return ContextAnalyzer.instance;
  }

  /**
   * 综合分析所有环境因素
   */
  analyze(input: GenerateRecipeInput): AnalysisResult {
    const result = new AnalysisResult();

    // 1. 获取鱼种基础规则
    const fishRule = getFishRule(input.targetFishId);
    if (fishRule === null) {
      result.analysisNotes.push('未找到目标鱼种规则，使用默认配置');
      result.flavorWeights = FlavorWeights.create(50, 50, 40, 20, 10);
      result.stateWeights = StateWeights.create(50, 50, 50);
      return result;
    }
    result.fishRule = fishRule;

    // 2. 初始化基础味型权重
    result.flavorWeights = FlavorWeights.create(
      fishRule.baseFlavor.fishy,
      fishRule.baseFlavor.fragrant,
      fishRule.baseFlavor.sweet,
      fishRule.baseFlavor.sour,
      fishRule.baseFlavor.stinky
    );

    // 3. 初始化基础状态权重
    result.stateWeights = StateWeights.create(50, 50, 50);

    // 4. 检测特殊场景
    result.specialScenarios = this.detectSpecialScenarios(input, fishRule);

    // 5. 应用季节修正
    this.applySeasonModifier(result, fishRule, input.season);

    // 6. 应用温度修正 (权重最高)
    this.applyTemperatureModifier(result, input.temperature);

    // 7. 应用水域修正
    this.applyWaterTypeModifier(result, fishRule, input.waterType);

    // 8. 应用鱼情修正
    this.applyFishConditionModifier(result, input);

    // 9. 应用作钓方式修正
    this.applyMethodModifier(result, input.fishingMethod);

    // 10. 应用模式修正
    this.applyModeModifier(result, input.mode);

    // 11. 应用特殊场景修正
    this.applySpecialScenarioModifiers(result);

    // 12. 归一化权重
    this.normalizeWeights(result);

    // 13. 确定优先因素
    result.priorityFactors = this.determinePriorityFactors(input, result);

    return result;
  }


  /**
   * 检测特殊场景
   */
  private detectSpecialScenarios(input: GenerateRecipeInput, fishRule: FishRecipeRule): SpecialScenario[] {
    const scenarios: SpecialScenario[] = [];

    // 极端温度
    if (input.temperature < 5) {
      scenarios.push('extreme_cold');
    } else if (input.temperature > 30) {
      scenarios.push('extreme_hot');
    }

    // 肉食性鱼类
    const carnivoreFish = ['catfish', 'snakehead', 'mandarin_fish', 'yellow_catfish', 'pike', 'bass', 'eel'];
    for (let i = 0; i < carnivoreFish.length; i++) {
      if (input.targetFishId === carnivoreFish[i]) {
        scenarios.push('carnivore_fish');
        break;
      }
    }

    // 黑坑场景
    if (input.waterType === 'pond') {
      if (input.fishDensity === 'high' && input.fishActivity === 'good') {
        scenarios.push('black_pit_new');
      } else if (input.fishActivity === 'poor') {
        scenarios.push('black_pit_old');
      }
    }

    // 流水环境
    if (input.waterType === 'river') {
      scenarios.push('flowing_water');
    }

    // 深水区 (水库)
    if (input.waterType === 'reservoir') {
      scenarios.push('deep_water');
    }

    return scenarios;
  }

  /**
   * 应用季节修正
   */
  private applySeasonModifier(result: AnalysisResult, fishRule: FishRecipeRule, season: RecipeSeason): void {
    let mod: FlavorModifier;
    if (season === 'spring') {
      mod = fishRule.seasonModifier.spring;
      result.analysisNotes.push('春季：鱼刚开口，适当增腥');
    } else if (season === 'summer') {
      mod = fishRule.seasonModifier.summer;
      result.analysisNotes.push('夏季：水温高，清淡为主');
    } else if (season === 'autumn') {
      mod = fishRule.seasonModifier.autumn;
      result.analysisNotes.push('秋季：鱼储备过冬，香甜为主');
    } else {
      mod = fishRule.seasonModifier.winter;
      result.analysisNotes.push('冬季：水温低，浓腥浓香');
    }

    result.flavorWeights.fishy += mod.fishy;
    result.flavorWeights.fragrant += mod.fragrant;
    result.flavorWeights.sweet += mod.sweet;
    result.flavorWeights.sour += mod.sour;
    result.flavorWeights.stinky += mod.stinky;
  }

  /**
   * 应用温度修正 (权重系数1.2)
   */
  private applyTemperatureModifier(result: AnalysisResult, temperature: number): void {
    const tempRule = getTemperatureRule(temperature);
    const scale = 1.2; // 温度影响权重更高

    result.flavorWeights.fishy += Math.round(tempRule.flavorModifier.fishy * scale);
    result.flavorWeights.fragrant += Math.round(tempRule.flavorModifier.fragrant * scale);
    result.flavorWeights.sweet += Math.round(tempRule.flavorModifier.sweet * scale);
    result.flavorWeights.sour += Math.round(tempRule.flavorModifier.sour * scale);
    result.flavorWeights.stinky += Math.round(tempRule.flavorModifier.stinky * scale);

    result.stateWeights.atomization += tempRule.stateModifier.atomization;
    result.stateWeights.viscosity += tempRule.stateModifier.viscosity;
    result.stateWeights.weight += tempRule.stateModifier.intensity;

    result.analysisNotes.push(tempRule.description);
  }

  /**
   * 应用水域修正
   */
  private applyWaterTypeModifier(result: AnalysisResult, fishRule: FishRecipeRule, waterType: RecipeWaterType): void {
    let mod: StateModifier;
    if (waterType === 'river') {
      mod = fishRule.waterModifier.river;
      result.analysisNotes.push('野河：降低雾化，增加粘度');
    } else if (waterType === 'pond') {
      mod = fishRule.waterModifier.pond;
      result.analysisNotes.push('黑坑：加快雾化，味型加重');
    } else if (waterType === 'reservoir') {
      mod = fishRule.waterModifier.reservoir;
      result.analysisNotes.push('水库：大颗粒，留鱼持久');
    } else {
      mod = fishRule.waterModifier.wild_pond;
      result.analysisNotes.push('野塘：味型适中，状态自然');
    }

    result.stateWeights.atomization += mod.atomization;
    result.stateWeights.viscosity += mod.viscosity;
    result.stateWeights.weight += mod.intensity;
  }

  /**
   * 应用鱼情修正
   */
  private applyFishConditionModifier(result: AnalysisResult, input: GenerateRecipeInput): void {
    // 密度修正
    const densityMod = getDensityModifier(input.fishDensity);
    result.stateWeights.atomization += densityMod.atomization;
    result.stateWeights.viscosity += densityMod.viscosity;
    result.stateWeights.weight += densityMod.intensity;

    if (input.fishDensity === 'high') {
      result.analysisNotes.push('鱼密度高：快雾化抢鱼');
    } else if (input.fishDensity === 'low') {
      result.analysisNotes.push('鱼密度低：慢雾化留鱼');
    }

    // 开口情况修正
    const activityMod = getActivityModifier(input.fishActivity);
    result.stateWeights.atomization += activityMod.atomization;
    result.stateWeights.viscosity += activityMod.viscosity;

    if (input.fishActivity === 'good') {
      // 开口好，味型可以淡一点
      this.scaleFlavorWeights(result.flavorWeights, 0.9);
      result.analysisNotes.push('开口好：味型可适当减淡');
    } else if (input.fishActivity === 'poor') {
      // 开口差，味型要浓
      this.scaleFlavorWeights(result.flavorWeights, 1.2);
      result.analysisNotes.push('开口差：味型加重');
    }
  }

  /**
   * 应用作钓方式修正
   */
  private applyMethodModifier(result: AnalysisResult, method: string): void {
    const mod = getMethodModifier(method);
    result.stateWeights.atomization += mod.atomization;
    result.stateWeights.viscosity += mod.viscosity;

    if (method === 'pull') {
      result.analysisNotes.push('拉饵：需要拉丝粉');
    } else if (method === 'scatter') {
      result.analysisNotes.push('散炮：极快雾化');
    } else if (method === 'wrap') {
      result.analysisNotes.push('包食：外雾化内粘');
    }
  }

  /**
   * 应用模式修正
   */
  private applyModeModifier(result: AnalysisResult, mode: string): void {
    const modeMod = getModeModifier(mode);

    // 味型缩放
    this.scaleFlavorWeights(result.flavorWeights, modeMod.flavorScale);

    // 雾化偏移
    result.stateWeights.atomization += modeMod.atomizationBias;

    if (mode === 'conservative') {
      result.analysisNotes.push('保守模式：经典配方，稳定出鱼');
    } else if (mode === 'aggressive') {
      result.analysisNotes.push('激进模式：味型浓烈，可能爆护');
    }
  }

  /**
   * 应用特殊场景修正
   */
  private applySpecialScenarioModifiers(result: AnalysisResult): void {
    for (let i = 0; i < result.specialScenarios.length; i++) {
      const scenario = result.specialScenarios[i];

      if (scenario === 'extreme_cold') {
        // 极寒：高腥高蛋白
        result.flavorWeights.fishy += 30;
        result.flavorWeights.fragrant += 15;
        result.stateWeights.atomization -= 20;
        result.stateWeights.viscosity += 15;
        result.analysisNotes.push('极寒场景：高腥高蛋白，慢雾化');
      } else if (scenario === 'extreme_hot') {
        // 极热：清淡果酸
        result.flavorWeights.fishy -= 30;
        result.flavorWeights.sour += 25;
        result.flavorWeights.sweet -= 15;
        result.stateWeights.atomization += 20;
        result.analysisNotes.push('极热场景：清淡果酸，快雾化');
      } else if (scenario === 'carnivore_fish') {
        // 肉食性鱼类：浓腥
        result.flavorWeights.fishy += 20;
        result.flavorWeights.stinky += 15;
        result.analysisNotes.push('肉食性鱼类：浓腥味');
      } else if (scenario === 'black_pit_new') {
        // 黑坑新放鱼：加小药
        result.flavorWeights.fragrant += 15;
        result.stateWeights.atomization += 15;
        result.analysisNotes.push('黑坑新鱼：可加小药，快雾化');
      } else if (scenario === 'black_pit_old') {
        // 黑坑老鱼：本味
        this.scaleFlavorWeights(result.flavorWeights, 0.7);
        result.stateWeights.atomization -= 15;
        result.analysisNotes.push('黑坑老鱼：本味为主，慢雾化');
      } else if (scenario === 'flowing_water') {
        // 流水：增粘增重
        result.stateWeights.viscosity += 20;
        result.stateWeights.weight += 15;
        result.stateWeights.atomization -= 15;
        result.analysisNotes.push('流水环境：增粘增重');
      } else if (scenario === 'deep_water') {
        // 深水：重比重
        result.stateWeights.weight += 20;
        result.stateWeights.atomization -= 10;
        result.analysisNotes.push('深水区：重比重，快到底');
      }
    }
  }

  /**
   * 缩放味型权重
   */
  private scaleFlavorWeights(weights: FlavorWeights, scale: number): void {
    weights.fishy = Math.round(weights.fishy * scale);
    weights.fragrant = Math.round(weights.fragrant * scale);
    weights.sweet = Math.round(weights.sweet * scale);
    weights.sour = Math.round(weights.sour * scale);
    weights.stinky = Math.round(weights.stinky * scale);
  }

  /**
   * 归一化权重到 0-100 范围
   */
  private normalizeWeights(result: AnalysisResult): void {
    // 味型权重
    result.flavorWeights.fishy = Math.min(100, Math.max(0, result.flavorWeights.fishy));
    result.flavorWeights.fragrant = Math.min(100, Math.max(0, result.flavorWeights.fragrant));
    result.flavorWeights.sweet = Math.min(100, Math.max(0, result.flavorWeights.sweet));
    result.flavorWeights.sour = Math.min(100, Math.max(0, result.flavorWeights.sour));
    result.flavorWeights.stinky = Math.min(100, Math.max(0, result.flavorWeights.stinky));

    // 状态权重
    result.stateWeights.atomization = Math.min(100, Math.max(0, result.stateWeights.atomization));
    result.stateWeights.viscosity = Math.min(100, Math.max(0, result.stateWeights.viscosity));
    result.stateWeights.weight = Math.min(100, Math.max(0, result.stateWeights.weight));
  }

  /**
   * 确定优先因素
   */
  private determinePriorityFactors(input: GenerateRecipeInput, result: AnalysisResult): string[] {
    const factors: string[] = [];

    // 温度是最重要的因素
    if (input.temperature < 10 || input.temperature > 28) {
      factors.push('temperature');
    }

    // 特殊场景
    if (result.specialScenarios.length > 0) {
      factors.push('special_scenario');
    }

    // 鱼种特性
    factors.push('fish_species');

    // 水域类型
    if (input.waterType === 'pond' || input.waterType === 'river') {
      factors.push('water_type');
    }

    // 鱼情
    if (input.fishActivity === 'poor' || input.fishDensity === 'low') {
      factors.push('fish_condition');
    }

    return factors;
  }

  /**
   * 计算两个分析结果的差异度
   */
  calculateDifference(result1: AnalysisResult, result2: AnalysisResult): number {
    // 味型差异
    let flavorDiff = 0;
    flavorDiff += Math.abs(result1.flavorWeights.fishy - result2.flavorWeights.fishy);
    flavorDiff += Math.abs(result1.flavorWeights.fragrant - result2.flavorWeights.fragrant);
    flavorDiff += Math.abs(result1.flavorWeights.sweet - result2.flavorWeights.sweet);
    flavorDiff += Math.abs(result1.flavorWeights.sour - result2.flavorWeights.sour);
    flavorDiff += Math.abs(result1.flavorWeights.stinky - result2.flavorWeights.stinky);
    flavorDiff = flavorDiff / 5; // 平均

    // 状态差异
    let stateDiff = 0;
    stateDiff += Math.abs(result1.stateWeights.atomization - result2.stateWeights.atomization);
    stateDiff += Math.abs(result1.stateWeights.viscosity - result2.stateWeights.viscosity);
    stateDiff += Math.abs(result1.stateWeights.weight - result2.stateWeights.weight);
    stateDiff = stateDiff / 3; // 平均

    // 综合差异度 (0-100)
    return Math.min(100, (flavorDiff * 0.6 + stateDiff * 0.4));
  }
}

// 导出单例获取函数
export function getContextAnalyzer(): ContextAnalyzer {
  return ContextAnalyzer.getInstance();
}
