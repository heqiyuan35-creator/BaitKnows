/**
 * 智能配方生成服务
 * 核心规则引擎，实现确定性的配方生成算法
 */
import {
  GenerateRecipeInput, GeneratedRecipe, RecipeIngredient,
  FlavorDescription, StateProfile, UsageSuggestion, GenerateReason,
  FlavorModifier, StateModifier, FishRecipeRule, TemperatureRule,
  RecipeSeason, RecipeWaterType, FishingMethod
} from '../common/types/RecipeTypes';
import {
  getFishRule, getTemperatureRule, getDensityModifier,
  getActivityModifier, getMethodModifier, getModeModifier,
  getTempReasonTemplate, getWaterReasonTemplate, getDensityReasonTemplate,
  getActivityReasonTemplate, getModeReasonTemplate, getFishReasonTemplate
} from '../data/RecipeRules';
import { getIngredientById, getIngredientNameMap, Ingredient } from '../data/IngredientDatabase';

// 味型权重
class FlavorWeights {
  fishy: number = 0;
  fragrant: number = 0;
  sweet: number = 0;
  sour: number = 0;
  stinky: number = 0;
  constructor() {}
}

// 状态权重
class StateWeights {
  atomization: number = 0;
  viscosity: number = 0;
  intensity: number = 0;
  constructor() {}
}

// 匹配的原料
class MatchedIngredient {
  id: string = '';
  name: string = '';
  category: string = '';
  score: number = 0;
  constructor() {}
}

class RecipeGeneratorServiceClass {
  private ingredientNames: Map<string, string> = new Map();

  constructor() {
    this.ingredientNames = getIngredientNameMap();
  }

  /**
   * 主生成方法
   */
  generateRecipe(input: GenerateRecipeInput): GeneratedRecipe {
    const recipe = new GeneratedRecipe();
    recipe.id = this.generateId();
    recipe.createTime = Date.now();
    recipe.mode = input.mode;
    recipe.conditions = input;
    recipe.totalWeight = 500;

    // 1. 获取鱼种基础规则
    const fishRule: FishRecipeRule | null = getFishRule(input.targetFishId);
    if (fishRule === null) {
      recipe.name = '默认配方';
      return recipe;
    }

    // 2. 计算最终味型权重
    const flavorWeights = this.calculateFlavorWeights(fishRule, input);

    // 3. 计算最终状态权重
    const stateWeights = this.calculateStateWeights(fishRule, input);

    // 4. 匹配原料
    const matchedIngredients = this.matchIngredients(fishRule, flavorWeights, stateWeights, input);

    // 5. 计算配比
    recipe.ingredients = this.calculateRatio(matchedIngredients, recipe.totalWeight);

    // 6. 生成配方名称
    recipe.name = this.generateRecipeName(input, fishRule);

    // 7. 生成味型说明
    recipe.flavorProfile = this.generateFlavorProfile(flavorWeights, input);

    // 8. 生成状态特性
    recipe.stateProfile = this.generateStateProfile(stateWeights, input);

    // 9. 生成使用建议
    recipe.usage = this.generateUsage(input, stateWeights);

    // 10. 生成理由
    recipe.reasons = this.generateReasons(input, flavorWeights, stateWeights);

    return recipe;
  }


  /**
   * 计算味型权重
   */
  private calculateFlavorWeights(fishRule: FishRecipeRule, input: GenerateRecipeInput): FlavorWeights {
    // 基础值
    const weights = new FlavorWeights();
    weights.fishy = fishRule.baseFlavor.fishy;
    weights.fragrant = fishRule.baseFlavor.fragrant;
    weights.sweet = fishRule.baseFlavor.sweet;
    weights.sour = fishRule.baseFlavor.sour;
    weights.stinky = fishRule.baseFlavor.stinky;

    // 季节修正
    const seasonMod = this.getSeasonModifier(fishRule, input.season);
    this.applyFlavorModifier(weights, seasonMod);

    // 温度修正
    const tempRule = getTemperatureRule(input.temperature);
    this.applyFlavorModifier(weights, tempRule.flavorModifier);

    // 鱼情修正 - 开口差时味型加重
    if (input.fishActivity === 'poor') {
      this.scaleFlavorWeights(weights, 1.2);
    } else if (input.fishActivity === 'good') {
      this.scaleFlavorWeights(weights, 0.9);
    }

    // 模式修正
    const modeMod = getModeModifier(input.mode);
    this.scaleFlavorWeights(weights, modeMod.flavorScale);

    // 限制范围 0-100
    this.clampFlavorWeights(weights);

    return weights;
  }

  /**
   * 计算状态权重
   */
  private calculateStateWeights(fishRule: FishRecipeRule, input: GenerateRecipeInput): StateWeights {
    // 基础值
    const weights = new StateWeights();
    weights.atomization = 50;
    weights.viscosity = 50;
    weights.intensity = 50;

    // 水域修正
    const waterMod = this.getWaterModifier(fishRule, input.waterType);
    this.applyStateModifier(weights, waterMod);

    // 温度修正
    const tempRule = getTemperatureRule(input.temperature);
    this.applyStateModifier(weights, tempRule.stateModifier);

    // 鱼密度修正
    const densityMod = getDensityModifier(input.fishDensity);
    this.applyStateModifier(weights, densityMod);

    // 开口情况修正
    const activityMod = getActivityModifier(input.fishActivity);
    this.applyStateModifier(weights, activityMod);

    // 作钓方式修正
    const methodMod = getMethodModifier(input.fishingMethod);
    this.applyStateModifier(weights, methodMod);

    // 模式修正
    const modeMod = getModeModifier(input.mode);
    weights.atomization += modeMod.atomizationBias;

    // 限制范围 0-100
    this.clampStateWeights(weights);

    return weights;
  }

  /**
   * 匹配原料
   */
  private matchIngredients(
    fishRule: FishRecipeRule,
    flavorWeights: FlavorWeights,
    stateWeights: StateWeights,
    input: GenerateRecipeInput
  ): MatchedIngredient[] {
    const matched: MatchedIngredient[] = [];
    const available = input.availableBaits || [];

    // 过滤出用户有的原料
    const filterAvailable = (ids: string[]): string[] => {
      if (available.length === 0) return ids;
      const filtered: string[] = [];
      for (let i = 0; i < ids.length; i++) {
        if (available.indexOf(ids[i]) >= 0) {
          filtered.push(ids[i]);
        }
      }
      return filtered.length > 0 ? filtered : ids;
    };

    // 1. 选主饵（1-2种）
    const mainIds = filterAvailable(fishRule.recommendedIngredients.main);
    const mainSelected = this.selectByFlavor(mainIds, flavorWeights, 2);
    for (let i = 0; i < mainSelected.length; i++) {
      const item = new MatchedIngredient();
      item.id = mainSelected[i].id;
      item.name = mainSelected[i].name;
      item.category = 'main';
      item.score = mainSelected[i].score;
      matched.push(item);
    }

    // 2. 选辅饵（1种）
    const auxIds = filterAvailable(fishRule.recommendedIngredients.auxiliary);
    const auxSelected = this.selectByFlavor(auxIds, flavorWeights, 1);
    for (let i = 0; i < auxSelected.length; i++) {
      const item = new MatchedIngredient();
      item.id = auxSelected[i].id;
      item.name = auxSelected[i].name;
      item.category = 'auxiliary';
      item.score = auxSelected[i].score;
      matched.push(item);
    }

    // 3. 选状态粉（1种）
    const stateIds = filterAvailable(fishRule.recommendedIngredients.state);
    const stateSelected = this.selectByState(stateIds, stateWeights, input.fishingMethod, 1);
    for (let i = 0; i < stateSelected.length; i++) {
      const item = new MatchedIngredient();
      item.id = stateSelected[i].id;
      item.name = stateSelected[i].name;
      item.category = 'state';
      item.score = stateSelected[i].score;
      matched.push(item);
    }

    // 4. 选添加剂（1种）
    const addIds = filterAvailable(fishRule.recommendedIngredients.additive);
    const addSelected = this.selectByFlavor(addIds, flavorWeights, 1);
    for (let i = 0; i < addSelected.length; i++) {
      const item = new MatchedIngredient();
      item.id = addSelected[i].id;
      item.name = addSelected[i].name;
      item.category = 'additive';
      item.score = addSelected[i].score;
      matched.push(item);
    }

    return matched;
  }


  /**
   * 计算配比
   */
  private calculateRatio(matched: MatchedIngredient[], totalWeight: number): RecipeIngredient[] {
    const result: RecipeIngredient[] = [];

    // 统计各类别数量
    let mainCount = 0, auxCount = 0, stateCount = 0, addCount = 0;
    for (let i = 0; i < matched.length; i++) {
      if (matched[i].category === 'main') mainCount++;
      else if (matched[i].category === 'auxiliary') auxCount++;
      else if (matched[i].category === 'state') stateCount++;
      else if (matched[i].category === 'additive') addCount++;
    }

    // 配比规则：主饵40-50%，辅饵20-30%，状态15-20%，添加剂5-10%
    const mainTotal = 45;   // 主饵总占比
    const auxTotal = 25;    // 辅饵总占比
    const stateTotal = 18;  // 状态总占比
    const addTotal = 12;    // 添加剂总占比

    for (let i = 0; i < matched.length; i++) {
      const ing = matched[i];
      const item = new RecipeIngredient();
      item.id = ing.id;
      item.name = ing.name;
      item.category = ing.category as 'main' | 'auxiliary' | 'state' | 'additive';

      // 计算百分比
      if (ing.category === 'main') {
        item.percentage = Math.round(mainTotal / mainCount);
      } else if (ing.category === 'auxiliary') {
        item.percentage = Math.round(auxTotal / auxCount);
      } else if (ing.category === 'state') {
        item.percentage = Math.round(stateTotal / stateCount);
      } else {
        item.percentage = Math.round(addTotal / addCount);
      }

      // 计算克数
      item.weight = Math.round(totalWeight * item.percentage / 100);

      // 用途说明
      item.purpose = this.getIngredientPurpose(ing.category);

      result.push(item);
    }

    return result;
  }

  /**
   * 生成配方名称
   */
  private generateRecipeName(input: GenerateRecipeInput, fishRule: FishRecipeRule): string {
    let season = '';
    if (input.season === 'spring') season = '春季';
    else if (input.season === 'summer') season = '夏季';
    else if (input.season === 'autumn') season = '秋季';
    else if (input.season === 'winter') season = '冬季';

    let water = '';
    if (input.waterType === 'river') water = '野河';
    else if (input.waterType === 'pond') water = '黑坑';
    else if (input.waterType === 'reservoir') water = '水库';
    else if (input.waterType === 'wild_pond') water = '野塘';

    let mode = '均衡';
    if (input.mode === 'conservative') mode = '保守';
    else if (input.mode === 'aggressive') mode = '激进';

    return `${season}${water}${fishRule.fishName}-${mode}配方`;
  }

  /**
   * 生成味型说明
   */
  private generateFlavorProfile(weights: FlavorWeights, input: GenerateRecipeInput): FlavorDescription {
    const profile = new FlavorDescription();

    // 确定主味型 - 手动比较找出最大的两个
    let primary = '腥';
    let primaryValue = weights.fishy;
    let secondary = '香';
    let secondaryValue = weights.fragrant;

    // 检查香
    if (weights.fragrant > primaryValue) {
      secondary = primary; secondaryValue = primaryValue;
      primary = '香'; primaryValue = weights.fragrant;
    } else if (weights.fragrant > secondaryValue) {
      secondary = '香'; secondaryValue = weights.fragrant;
    }
    // 检查甜
    if (weights.sweet > primaryValue) {
      secondary = primary; secondaryValue = primaryValue;
      primary = '甜'; primaryValue = weights.sweet;
    } else if (weights.sweet > secondaryValue) {
      secondary = '甜'; secondaryValue = weights.sweet;
    }
    // 检查酸
    if (weights.sour > primaryValue) {
      secondary = primary; secondaryValue = primaryValue;
      primary = '酸'; primaryValue = weights.sour;
    } else if (weights.sour > secondaryValue) {
      secondary = '酸'; secondaryValue = weights.sour;
    }
    // 检查臭
    if (weights.stinky > primaryValue) {
      secondary = primary; secondaryValue = primaryValue;
      primary = '臭'; primaryValue = weights.stinky;
    } else if (weights.stinky > secondaryValue) {
      secondary = '臭'; secondaryValue = weights.stinky;
    }

    profile.primary = primary;
    profile.secondary = secondary;

    // 计算浓度 (1-10)
    const avgIntensity = (primaryValue + secondaryValue) / 2;
    profile.intensity = Math.min(10, Math.max(1, Math.round(avgIntensity / 10)));

    // 适用水温
    if (input.temperature < 10) {
      profile.suitableTemp = '5-15°C';
    } else if (input.temperature < 20) {
      profile.suitableTemp = '10-20°C';
    } else if (input.temperature < 28) {
      profile.suitableTemp = '18-28°C';
    } else {
      profile.suitableTemp = '25-35°C';
    }

    return profile;
  }

  /**
   * 生成状态特性
   */
  private generateStateProfile(weights: StateWeights, input: GenerateRecipeInput): StateProfile {
    const profile = new StateProfile();

    // 转换为1-5星级
    profile.atomization = this.toStarRating(weights.atomization);
    profile.viscosity = this.toStarRating(weights.viscosity);

    // 持钩性与粘度正相关
    profile.hookHolding = Math.min(5, Math.max(1, Math.round(weights.viscosity / 20)));

    // 比重：雾化快则轻，粘度高则重
    const weightScore = 50 - weights.atomization * 0.3 + weights.viscosity * 0.3;
    profile.weight = this.toStarRating(weightScore);

    return profile;
  }


  /**
   * 生成使用建议
   */
  generateUsage(input: GenerateRecipeInput, stateWeights: StateWeights): UsageSuggestion {
    const usage = new UsageSuggestion();

    // 水比：雾化快用水少，粘度高用水多
    const atomLevel = stateWeights.atomization;
    if (atomLevel > 60) {
      usage.waterRatio = '1:0.8';
    } else if (atomLevel > 40) {
      usage.waterRatio = '1:0.9';
    } else {
      usage.waterRatio = '1:1';
    }

    // 静置时间：粘度高需要更长时间
    const viscLevel = stateWeights.viscosity;
    if (viscLevel > 60) {
      usage.restTime = '10-15分钟';
    } else if (viscLevel > 40) {
      usage.restTime = '5-10分钟';
    } else {
      usage.restTime = '3-5分钟';
    }

    // 首钓建议
    if (input.fishingMethod === 'rub') {
      usage.firstCast = '搓大饵找鱼层，有口后改小饵';
    } else if (input.fishingMethod === 'pull') {
      usage.firstCast = '拉小饵快频率，诱钓结合';
    } else if (input.fishingMethod === 'scatter') {
      usage.firstCast = '先打散炮诱鱼，再搓饵钓';
    } else if (input.fishingMethod === 'wrap') {
      usage.firstCast = '外层雾化诱鱼，内层留鱼';
    } else {
      usage.firstCast = '搓大饵试鱼层';
    }

    // 打窝建议
    if (input.waterType === 'river') {
      usage.nestSuggestion = '酒米+颗粒，少量多次';
    } else if (input.waterType === 'pond') {
      usage.nestSuggestion = '散炮带窝，边钓边诱';
    } else if (input.waterType === 'reservoir') {
      usage.nestSuggestion = '大窝守钓，玉米+颗粒';
    } else {
      usage.nestSuggestion = '酒米打底，适量补窝';
    }

    return usage;
  }

  /**
   * 生成理由
   */
  generateReasons(input: GenerateRecipeInput, flavorWeights: FlavorWeights, stateWeights: StateWeights): GenerateReason[] {
    const reasons: GenerateReason[] = [];

    // 温度理由
    const tempTemplate = getTempReasonTemplate(input.temperature);
    const tempReason = new GenerateReason();
    tempReason.condition = tempTemplate.condition;
    tempReason.decision = tempTemplate.decision;
    tempReason.icon = tempTemplate.icon;
    reasons.push(tempReason);

    // 水域理由
    const waterTemplate = getWaterReasonTemplate(input.waterType);
    const waterReason = new GenerateReason();
    waterReason.condition = waterTemplate.condition;
    waterReason.decision = waterTemplate.decision;
    waterReason.icon = waterTemplate.icon;
    reasons.push(waterReason);

    // 鱼种理由
    const fishTemplate = getFishReasonTemplate(input.targetFishId);
    const fishReason = new GenerateReason();
    fishReason.condition = fishTemplate.condition;
    fishReason.decision = fishTemplate.decision;
    fishReason.icon = fishTemplate.icon;
    reasons.push(fishReason);

    // 鱼情理由
    const densityTemplate = getDensityReasonTemplate(input.fishDensity);
    if (densityTemplate !== null) {
      const r = new GenerateReason();
      r.condition = densityTemplate.condition;
      r.decision = densityTemplate.decision;
      r.icon = densityTemplate.icon;
      reasons.push(r);
    }

    // 开口理由
    const activityTemplate = getActivityReasonTemplate(input.fishActivity);
    if (activityTemplate !== null) {
      const r = new GenerateReason();
      r.condition = activityTemplate.condition;
      r.decision = activityTemplate.decision;
      r.icon = activityTemplate.icon;
      reasons.push(r);
    }

    // 模式理由
    const modeTemplate = getModeReasonTemplate(input.mode);
    if (modeTemplate !== null) {
      const r = new GenerateReason();
      r.condition = modeTemplate.condition;
      r.decision = modeTemplate.decision;
      r.icon = modeTemplate.icon;
      reasons.push(r);
    }

    return reasons;
  }


  // ============================================================
  // 辅助方法
  // ============================================================

  private getSeasonModifier(fishRule: FishRecipeRule, season: RecipeSeason): FlavorModifier {
    if (season === 'spring') return fishRule.seasonModifier.spring;
    if (season === 'summer') return fishRule.seasonModifier.summer;
    if (season === 'autumn') return fishRule.seasonModifier.autumn;
    return fishRule.seasonModifier.winter;
  }

  private getWaterModifier(fishRule: FishRecipeRule, waterType: RecipeWaterType): StateModifier {
    if (waterType === 'river') return fishRule.waterModifier.river;
    if (waterType === 'pond') return fishRule.waterModifier.pond;
    if (waterType === 'reservoir') return fishRule.waterModifier.reservoir;
    return fishRule.waterModifier.wild_pond;
  }

  private applyFlavorModifier(weights: FlavorWeights, mod: FlavorModifier): void {
    weights.fishy += mod.fishy;
    weights.fragrant += mod.fragrant;
    weights.sweet += mod.sweet;
    weights.sour += mod.sour;
    weights.stinky += mod.stinky;
  }

  private applyStateModifier(weights: StateWeights, mod: StateModifier): void {
    weights.atomization += mod.atomization;
    weights.viscosity += mod.viscosity;
    weights.intensity += mod.intensity;
  }

  private scaleFlavorWeights(weights: FlavorWeights, scale: number): void {
    weights.fishy = Math.round(weights.fishy * scale);
    weights.fragrant = Math.round(weights.fragrant * scale);
    weights.sweet = Math.round(weights.sweet * scale);
    weights.sour = Math.round(weights.sour * scale);
    weights.stinky = Math.round(weights.stinky * scale);
  }

  private clampFlavorWeights(weights: FlavorWeights): void {
    weights.fishy = Math.min(100, Math.max(0, weights.fishy));
    weights.fragrant = Math.min(100, Math.max(0, weights.fragrant));
    weights.sweet = Math.min(100, Math.max(0, weights.sweet));
    weights.sour = Math.min(100, Math.max(0, weights.sour));
    weights.stinky = Math.min(100, Math.max(0, weights.stinky));
  }

  private clampStateWeights(weights: StateWeights): void {
    weights.atomization = Math.min(100, Math.max(0, weights.atomization));
    weights.viscosity = Math.min(100, Math.max(0, weights.viscosity));
    weights.intensity = Math.min(100, Math.max(0, weights.intensity));
  }

  private selectByFlavor(ids: string[], weights: FlavorWeights, count: number): MatchedIngredient[] {
    const scored: MatchedIngredient[] = [];

    for (let i = 0; i < ids.length; i++) {
      const id: string = ids[i];
      const ing: Ingredient | null = getIngredientById(id);
      if (ing === null) continue;

      // 计算味型匹配分数
      const fp = ing.flavorProfile;
      let score: number = 0;
      score += Math.min(fp.fishy, weights.fishy);
      score += Math.min(fp.fragrant, weights.fragrant);
      score += Math.min(fp.sweet, weights.sweet);

      const item = new MatchedIngredient();
      item.id = id;
      item.name = ing.name;
      item.category = '';
      item.score = score;
      scored.push(item);
    }

    // 按分数排序
    scored.sort((a: MatchedIngredient, b: MatchedIngredient): number => b.score - a.score);

    // 返回前N个
    const result: MatchedIngredient[] = [];
    const maxCount: number = Math.min(count, scored.length);
    for (let i = 0; i < maxCount; i++) {
      result.push(scored[i]);
    }
    return result;
  }

  private selectByState(ids: string[], weights: StateWeights, method: FishingMethod, count: number): MatchedIngredient[] {
    const scored: MatchedIngredient[] = [];

    for (let i = 0; i < ids.length; i++) {
      const id: string = ids[i];
      const ing: Ingredient | null = getIngredientById(id);
      if (ing === null) continue;

      // 计算状态匹配分数
      const phys = ing.physical;
      let score: number = 0;

      // 雾化匹配
      if (weights.atomization > 60) {
        score += phys.atomization * 10;  // 需要快雾化
      } else if (weights.atomization < 40) {
        score += (10 - phys.atomization) * 10;  // 需要慢雾化
      }

      // 拉饵需要拉丝粉
      if (method === 'pull' && id === 'drawing_powder') {
        score += 50;
      }

      // 散炮需要雪花粉
      if (method === 'scatter' && id === 'snowflake_powder') {
        score += 50;
      }

      const item = new MatchedIngredient();
      item.id = id;
      item.name = ing.name;
      item.category = '';
      item.score = score;
      scored.push(item);
    }

    scored.sort((a: MatchedIngredient, b: MatchedIngredient): number => b.score - a.score);

    const result: MatchedIngredient[] = [];
    const maxCount: number = Math.min(count, scored.length);
    for (let i = 0; i < maxCount; i++) {
      result.push(scored[i]);
    }
    return result;
  }


  private getIngredientPurpose(category: string): string {
    if (category === 'main') return '主饵，提供基础味型和状态';
    if (category === 'auxiliary') return '辅饵，增强诱鱼效果';
    if (category === 'state') return '状态粉，调节雾化和粘度';
    if (category === 'additive') return '添加剂，提升味型浓度';
    return '';
  }

  private toStarRating(value: number): number {
    // 0-100 转换为 1-5
    return Math.min(5, Math.max(1, Math.round(value / 20)));
  }

  private generateId(): string {
    return `recipe_${Date.now()}_${Math.random().toString(36).substring(2, 8)}`;
  }

  /**
   * 根据当前日期获取季节
   */
  getCurrentSeason(): RecipeSeason {
    const month = new Date().getMonth() + 1;
    if (month >= 3 && month <= 5) return 'spring';
    if (month >= 6 && month <= 8) return 'summer';
    if (month >= 9 && month <= 11) return 'autumn';
    return 'winter';
  }
}

// 导出单例
export const recipeGeneratorService = new RecipeGeneratorServiceClass();

// 导出便捷函数
export function generateRecipe(input: GenerateRecipeInput): GeneratedRecipe {
  return recipeGeneratorService.generateRecipe(input);
}

export function getCurrentSeason(): RecipeSeason {
  return recipeGeneratorService.getCurrentSeason();
}
