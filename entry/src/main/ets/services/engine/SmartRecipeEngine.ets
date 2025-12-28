/**
 * 智能配方引擎
 * 整合环境分析、原料匹配、变体管理，提供统一的配方生成接�?
 */
import {
  GenerateRecipeInput, GeneratedRecipe, RecipeIngredient,
  FlavorDescription, StateProfile, UsageSuggestion, GenerateReason,
  RecipeSeason
} from '../../common/types/RecipeTypes';
import { getContextAnalyzer, AnalysisResult, FlavorWeights, StateWeights } from './ContextAnalyzer';
import { getIngredientPool, ScoredIngredient } from './IngredientPool';
import { getVariantManager, RecipeVariant } from './VariantManager';
import { getPreferenceLearner } from './PreferenceLearner';
import { getIngredientById, Ingredient } from '../../data/IngredientDatabase';
import {
  getTempReasonTemplate, getWaterReasonTemplate, getFishReasonTemplate,
  getDensityReasonTemplate, getActivityReasonTemplate, getModeReasonTemplate
} from '../../data/RecipeRules';

// 引擎配置
export class EngineConfig {
  totalWeight: number = 500;           // 默认总重�?
  mainRatio: number = 45;              // 主饵占比
  auxRatio: number = 25;               // 辅饵占比
  stateRatio: number = 18;             // 状态饵占比
  additiveRatio: number = 12;          // 添加剂占�?
  maxVariantAttempts: number = 10;     // 最大变体尝试次�?
  minDifferenceScore: number = 25;     // 最小差异度

  constructor() {}
}

// 智能配方引擎
export class SmartRecipeEngine {
  private static instance: SmartRecipeEngine | null = null;
  private config: EngineConfig = new EngineConfig();
  private currentAnalysis: AnalysisResult | null = null;
  private currentInput: GenerateRecipeInput | null = null;
  private variantAttemptIndex: number = 0;

  private constructor() {}

  static getInstance(): SmartRecipeEngine {
    if (SmartRecipeEngine.instance === null) {
      SmartRecipeEngine.instance = new SmartRecipeEngine();
    }
    return SmartRecipeEngine.instance;
  }

  /**
   * 生成配方 (主入�?
   */
  generate(input: GenerateRecipeInput): GeneratedRecipe {
    // 保存当前输入
    this.currentInput = input;
    this.variantAttemptIndex = 0;

    // 1. 环境分析
    const analyzer = getContextAnalyzer();
    this.currentAnalysis = analyzer.analyze(input);

    // 2. 生成配方
    const recipe = this.buildRecipe(input, this.currentAnalysis, null);

    // 3. 记录到变体管理器
    const variantManager = getVariantManager();
    const conditionHash = variantManager.hashConditions(input);
    variantManager.recordShownRecipe(conditionHash, recipe);

    // 4. 记录到偏好学习器
    const prefLearner = getPreferenceLearner();
    if (prefLearner.isLoaded()) {
      prefLearner.recordGenerate(recipe);
    }

    return recipe;
  }

  /**
   * 获取下一个变�?(换一�?
   */
  getNextVariant(): GeneratedRecipe | null {
    if (this.currentInput === null || this.currentAnalysis === null) {
      return null;
    }

    const variantManager = getVariantManager();
    const conditionHash = variantManager.hashConditions(this.currentInput);

    // 检查是否已经尝试太多次
    if (this.variantAttemptIndex >= this.config.maxVariantAttempts) {
      // 重置尝试计数，但保留历史记录
      this.variantAttemptIndex = 0;
    }

    // 尝试生成不重复的变体
    let attempts = 0;
    while (attempts < this.config.maxVariantAttempts) {
      this.variantAttemptIndex++;
      attempts++;

      // 生成变体参数
      const variantParams = variantManager.generateVariantParams(
        this.buildRecipe(this.currentInput, this.currentAnalysis, null),
        this.currentAnalysis,
        this.variantAttemptIndex
      );

      // 使用变体参数生成新配�?
      const newRecipe = this.buildRecipe(this.currentInput, this.currentAnalysis, variantParams);

      // 检查是否与历史配方重复
      if (!variantManager.isDuplicateRecipe(newRecipe)) {
        // 记录新配�?
        variantManager.recordShownRecipe(conditionHash, newRecipe);
        return newRecipe;
      }
    }

    // 如果所有尝试都失败，强制生成一个（即使可能有些相似�?
    const forcedVariant = variantManager.generateVariantParams(
      this.buildRecipe(this.currentInput, this.currentAnalysis, null),
      this.currentAnalysis,
      Date.now() % 100  // 使用时间戳增加随机�?
    );

    const forcedRecipe = this.buildRecipe(this.currentInput, this.currentAnalysis, forcedVariant);
    variantManager.recordShownRecipe(conditionHash, forcedRecipe);
    return forcedRecipe;
  }


  /**
   * 构建配方
   */
  private buildRecipe(
    input: GenerateRecipeInput,
    analysis: AnalysisResult,
    variant: RecipeVariant | null
  ): GeneratedRecipe {
    const recipe = new GeneratedRecipe();
    recipe.id = this.generateId();
    recipe.createTime = Date.now();
    recipe.mode = input.mode;
    recipe.conditions = input;
    recipe.totalWeight = this.config.totalWeight;

    // 应用变体调整到分析结�?
    let adjustedAnalysis = analysis;
    if (variant !== null) {
      adjustedAnalysis = this.applyVariantToAnalysis(analysis, variant);
    }

    // 1. 匹配原料
    const ingredients = this.matchIngredients(input, adjustedAnalysis, variant);
    recipe.ingredients = ingredients;

    // 2. 生成配方名称
    recipe.name = this.generateRecipeName(input, analysis, variant);

    // 3. 生成味型说明
    recipe.flavorProfile = this.generateFlavorProfile(adjustedAnalysis.flavorWeights, input);

    // 4. 生成状态特�?
    recipe.stateProfile = this.generateStateProfile(adjustedAnalysis.stateWeights);

    // 5. 生成使用建议
    recipe.usage = this.generateUsage(input, adjustedAnalysis.stateWeights);

    // 6. 生成推荐理由
    recipe.reasons = this.generateReasons(input, analysis, variant);

    return recipe;
  }

  /**
   * 应用变体调整到分析结�?
   */
  private applyVariantToAnalysis(analysis: AnalysisResult, variant: RecipeVariant): AnalysisResult {
    // 克隆分析结果
    const adjusted = new AnalysisResult();
    adjusted.flavorWeights = analysis.flavorWeights.clone();
    adjusted.stateWeights = analysis.stateWeights.clone();
    adjusted.fishRule = analysis.fishRule;
    adjusted.specialScenarios = analysis.specialScenarios.slice();
    adjusted.priorityFactors = analysis.priorityFactors.slice();
    adjusted.analysisNotes = analysis.analysisNotes.slice();

    // 应用味型偏移
    if (variant.flavorShift !== null) {
      const shift = variant.flavorShift;
      switch (shift.primaryShift) {
        case 'increase_fishy':
          adjusted.flavorWeights.fishy += shift.intensityChange;
          adjusted.flavorWeights.fragrant -= Math.round(shift.intensityChange * 0.3);
          break;
        case 'increase_fragrant':
          adjusted.flavorWeights.fragrant += shift.intensityChange;
          adjusted.flavorWeights.fishy -= Math.round(shift.intensityChange * 0.3);
          break;
        case 'increase_sweet':
          adjusted.flavorWeights.sweet += shift.intensityChange;
          break;
        case 'increase_sour':
          adjusted.flavorWeights.sour += shift.intensityChange;
          adjusted.flavorWeights.sweet -= Math.round(shift.intensityChange * 0.3);
          break;
        case 'decrease_intensity':
          const scale = 1 + shift.intensityChange / 100;
          adjusted.flavorWeights.fishy = Math.round(adjusted.flavorWeights.fishy * scale);
          adjusted.flavorWeights.fragrant = Math.round(adjusted.flavorWeights.fragrant * scale);
          adjusted.flavorWeights.sweet = Math.round(adjusted.flavorWeights.sweet * scale);
          break;
        case 'more_atomization':
          adjusted.stateWeights.atomization += 20;
          adjusted.stateWeights.viscosity -= 10;
          break;
        case 'more_viscosity':
          adjusted.stateWeights.viscosity += 20;
          adjusted.stateWeights.atomization -= 10;
          break;
        case 'lighter':
          adjusted.stateWeights.weight -= 15;
          adjusted.stateWeights.atomization += 10;
          break;
        case 'heavier':
          adjusted.stateWeights.weight += 15;
          adjusted.stateWeights.atomization -= 10;
          break;
      }

      // 归一�?
      adjusted.flavorWeights.fishy = Math.min(100, Math.max(0, adjusted.flavorWeights.fishy));
      adjusted.flavorWeights.fragrant = Math.min(100, Math.max(0, adjusted.flavorWeights.fragrant));
      adjusted.flavorWeights.sweet = Math.min(100, Math.max(0, adjusted.flavorWeights.sweet));
      adjusted.flavorWeights.sour = Math.min(100, Math.max(0, adjusted.flavorWeights.sour));
      adjusted.stateWeights.atomization = Math.min(100, Math.max(0, adjusted.stateWeights.atomization));
      adjusted.stateWeights.viscosity = Math.min(100, Math.max(0, adjusted.stateWeights.viscosity));
      adjusted.stateWeights.weight = Math.min(100, Math.max(0, adjusted.stateWeights.weight));
    }

    return adjusted;
  }

  /**
   * 匹配原料
   */
  private matchIngredients(
    input: GenerateRecipeInput,
    analysis: AnalysisResult,
    variant: RecipeVariant | null
  ): RecipeIngredient[] {
    const pool = getIngredientPool();
    const result: RecipeIngredient[] = [];
    const selectedIds: string[] = [];

    // 获取鱼种推荐原料
    const fishRule = analysis.fishRule;
    if (fishRule === null) {
      return this.getDefaultIngredients();
    }

    // 用户可用原料过滤
    const available = input.availableBaits || [];
    const filterAvailable = (ids: string[]): string[] => {
      if (available.length === 0) return ids;
      const filtered: string[] = [];
      for (let i = 0; i < ids.length; i++) {
        for (let j = 0; j < available.length; j++) {
          if (ids[i] === available[j]) {
            filtered.push(ids[i]);
            break;
          }
        }
      }
      return filtered.length > 0 ? filtered : ids;
    };

    // 1. 选主�?(1-2�?
    let mainCandidates = filterAvailable(fishRule.recommendedIngredients.main);
    // 应用变体替换
    if (variant !== null && variant.ingredientSwaps.length > 0) {
      mainCandidates = this.applySwapsToCandidate(mainCandidates, variant, 'main');
    }
    const mainSelected = pool.matchByFlavor(analysis.flavorWeights, mainCandidates, 2, selectedIds);
    for (let i = 0; i < mainSelected.length; i++) {
      selectedIds.push(mainSelected[i].ingredient.id);
      result.push(this.createRecipeIngredient(mainSelected[i], 'main', this.config.mainRatio / mainSelected.length));
    }

    // 2. 选辅�?(1�?
    let auxCandidates = filterAvailable(fishRule.recommendedIngredients.auxiliary);
    if (variant !== null && variant.ingredientSwaps.length > 0) {
      auxCandidates = this.applySwapsToCandidate(auxCandidates, variant, 'auxiliary');
    }
    const auxSelected = pool.matchByFlavor(analysis.flavorWeights, auxCandidates, 1, selectedIds);
    for (let i = 0; i < auxSelected.length; i++) {
      selectedIds.push(auxSelected[i].ingredient.id);
      result.push(this.createRecipeIngredient(auxSelected[i], 'auxiliary', this.config.auxRatio));
    }

    // 3. 选状态饵 (1�?
    let stateCandidates = filterAvailable(fishRule.recommendedIngredients.state);
    if (variant !== null && variant.ingredientSwaps.length > 0) {
      stateCandidates = this.applySwapsToCandidate(stateCandidates, variant, 'state');
    }
    const stateSelected = pool.matchByState(analysis.stateWeights, stateCandidates, input.fishingMethod, 1, selectedIds);
    for (let i = 0; i < stateSelected.length; i++) {
      selectedIds.push(stateSelected[i].ingredient.id);
      result.push(this.createRecipeIngredient(stateSelected[i], 'state', this.config.stateRatio));
    }

    // 4. 选添加剂 (1�?
    let addCandidates = filterAvailable(fishRule.recommendedIngredients.additive);
    if (variant !== null && variant.ingredientSwaps.length > 0) {
      addCandidates = this.applySwapsToCandidate(addCandidates, variant, 'additive');
    }
    const addSelected = pool.matchByFlavor(analysis.flavorWeights, addCandidates, 1, selectedIds);
    for (let i = 0; i < addSelected.length; i++) {
      selectedIds.push(addSelected[i].ingredient.id);
      result.push(this.createRecipeIngredient(addSelected[i], 'additive', this.config.additiveRatio));
    }

    // 5. 应用配比调整
    if (variant !== null && variant.ratioAdjustments.length > 0) {
      this.applyRatioAdjustments(result, variant);
    }

    // 6. 确保总比例为100%
    this.normalizeRatios(result);

    return result;
  }

  /**
   * 应用原料替换到候选列�?
   */
  private applySwapsToCandidate(candidates: string[], variant: RecipeVariant, category: string): string[] {
    const result: string[] = [];

    for (let i = 0; i < candidates.length; i++) {
      let swapped = false;
      for (let j = 0; j < variant.ingredientSwaps.length; j++) {
        const swap = variant.ingredientSwaps[j];
        if (swap.originalId === candidates[i]) {
          // 将替换原料放在前面（优先选择�?
          result.unshift(swap.replacementId);
          swapped = true;
          break;
        }
      }
      if (!swapped) {
        result.push(candidates[i]);
      }
    }

    return result;
  }

  /**
   * 应用配比调整
   */
  private applyRatioAdjustments(ingredients: RecipeIngredient[], variant: RecipeVariant): void {
    for (let i = 0; i < variant.ratioAdjustments.length; i++) {
      const adj = variant.ratioAdjustments[i];
      for (let j = 0; j < ingredients.length; j++) {
        if (ingredients[j].id === adj.ingredientId) {
          ingredients[j].percentage = adj.newRatio;
          break;
        }
      }
    }
  }

  /**
   * 归一化配�?
   */
  private normalizeRatios(ingredients: RecipeIngredient[]): void {
    let total = 0;
    for (let i = 0; i < ingredients.length; i++) {
      total += ingredients[i].percentage;
    }

    if (total === 0) return;

    const scale = 100 / total;
    for (let i = 0; i < ingredients.length; i++) {
      ingredients[i].percentage = Math.round(ingredients[i].percentage * scale);
      ingredients[i].weight = Math.round(this.config.totalWeight * ingredients[i].percentage / 100);
    }
  }

  /**
   * 创建配方原料
   */
  private createRecipeIngredient(scored: ScoredIngredient, category: string, percentage: number): RecipeIngredient {
    const ing = new RecipeIngredient();
    ing.id = scored.ingredient.id;
    ing.name = scored.ingredient.name;
    ing.category = category as 'main' | 'auxiliary' | 'state' | 'additive';
    ing.percentage = Math.round(percentage);
    ing.weight = Math.round(this.config.totalWeight * percentage / 100);
    ing.purpose = this.getIngredientPurpose(category, scored.matchReasons);
    return ing;
  }

  /**
   * 获取原料用途说�?
   */
  private getIngredientPurpose(category: string, reasons: string[]): string {
    let base = '';
    if (category === 'main') base = '主饵，提供基础味型';
    else if (category === 'auxiliary') base = '辅饵，增强诱鱼效�?;
    else if (category === 'state') base = '状态粉，调节雾化粘�?;
    else if (category === 'additive') base = '添加剂，提升味型浓度';

    if (reasons.length > 0) {
      base += '�? + reasons.join('�?);
    }
    return base;
  }

  /**
   * 获取默认原料
   */
  private getDefaultIngredients(): RecipeIngredient[] {
    const result: RecipeIngredient[] = [];

    const main = new RecipeIngredient();
    main.id = 'corn_flour'; main.name = '玉米�?; main.category = 'main';
    main.percentage = 45; main.weight = 225; main.purpose = '主饵，提供基础味型';
    result.push(main);

    const aux = new RecipeIngredient();
    aux.id = 'fish_meal'; aux.name = '鱼粉'; aux.category = 'auxiliary';
    aux.percentage = 25; aux.weight = 125; aux.purpose = '辅饵，增强诱鱼效�?;
    result.push(aux);

    const state = new RecipeIngredient();
    state.id = 'drawing_powder'; state.name = '拉丝�?; state.category = 'state';
    state.percentage = 18; state.weight = 90; state.purpose = '状态粉，调节雾化粘�?;
    result.push(state);

    const add = new RecipeIngredient();
    add.id = 'dmpt'; add.name = 'DMPT诱食�?; add.category = 'additive';
    add.percentage = 12; add.weight = 60; add.purpose = '添加剂，提升味型浓度';
    result.push(add);

    return result;
  }


  /**
   * 生成配方名称
   */
  private generateRecipeName(input: GenerateRecipeInput, analysis: AnalysisResult, variant: RecipeVariant | null): string {
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

    const fishName = analysis.fishRule ? analysis.fishRule.fishName : '目标�?;

    let suffix = '';
    if (input.mode === 'conservative') suffix = '�?;
    else if (input.mode === 'aggressive') suffix = '�?;
    else suffix = '�?;

    // 添加变体标识
    if (variant !== null) {
      const variantSuffix = this.getVariantSuffix(variant);
      return `${season}${water}${fishName}-${suffix}${variantSuffix}`;
    }

    return `${season}${water}${fishName}-${suffix}`;
  }

  /**
   * 获取变体后缀
   */
  private getVariantSuffix(variant: RecipeVariant): string {
    switch (variant.strategy) {
      case 'flavor_shift':
        if (variant.flavorShift?.primaryShift === 'increase_fishy') return '·�?;
        if (variant.flavorShift?.primaryShift === 'increase_fragrant') return '·�?;
        if (variant.flavorShift?.primaryShift === 'increase_sweet') return '·�?;
        if (variant.flavorShift?.primaryShift === 'increase_sour') return '·�?;
        if (variant.flavorShift?.primaryShift === 'decrease_intensity') return '·�?;
        return '·�?;
      case 'ingredient_swap':
        return '·�?;
      case 'additive_change':
        return '·�?;
      case 'ratio_adjust':
        return '·�?;
      case 'state_change':
        return '·�?;
      default:
        return '';
    }
  }

  /**
   * 生成味型说明
   */
  private generateFlavorProfile(weights: FlavorWeights, input: GenerateRecipeInput): FlavorDescription {
    const profile = new FlavorDescription();

    profile.primary = weights.getPrimaryFlavor();
    profile.secondary = weights.getSecondaryFlavor();

    // 计算浓度 (1-10)
    const avgIntensity = weights.getTotalIntensity() / 5;
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
   * 生成状态特�?
   */
  private generateStateProfile(weights: StateWeights): StateProfile {
    const profile = new StateProfile();

    // 转换�?-5星级，基于实际权重�?
    profile.atomization = Math.min(5, Math.max(1, this.toStarRating(weights.atomization)));
    profile.viscosity = Math.min(5, Math.max(1, this.toStarRating(weights.viscosity)));
    profile.hookHolding = Math.min(5, Math.max(1, Math.round((weights.viscosity + 20) / 24)));  // 粘度越高附钩性越�?
    profile.weight = Math.min(5, Math.max(1, this.toStarRating(weights.weight)));

    return profile;
  }

  /**
   * 生成使用建议
   */
  private generateUsage(input: GenerateRecipeInput, stateWeights: StateWeights): UsageSuggestion {
    const usage = new UsageSuggestion();

    // 水比 - 根据雾化和粘度综合判�?
    if (stateWeights.atomization > 70) {
      usage.waterRatio = '1:0.7';
    } else if (stateWeights.atomization > 60) {
      usage.waterRatio = '1:0.8';
    } else if (stateWeights.atomization > 40) {
      usage.waterRatio = '1:0.9';
    } else if (stateWeights.viscosity > 60) {
      usage.waterRatio = '1:1.1';
    } else {
      usage.waterRatio = '1:1';
    }

    // 静置时间 - 根据粘度和雾�?
    if (stateWeights.viscosity > 70) {
      usage.restTime = '15-20分钟';
    } else if (stateWeights.viscosity > 60) {
      usage.restTime = '10-15分钟';
    } else if (stateWeights.viscosity > 40) {
      usage.restTime = '5-10分钟';
    } else if (stateWeights.atomization > 60) {
      usage.restTime = '3-5分钟';
    } else {
      usage.restTime = '5-8分钟';
    }

    // 首钓建议 - 根据钓法和状态综合判�?
    if (input.fishingMethod === 'rub') {
      if (stateWeights.weight > 60) {
        usage.firstCast = '搓大饵快速找底，确定水深后改小饵';
      } else if (stateWeights.atomization > 60) {
        usage.firstCast = '搓饵抽窝，形成雾化带后改小饵';
      } else {
        usage.firstCast = '搓大饵找鱼层，有口后改小�?;
      }
    } else if (input.fishingMethod === 'pull') {
      if (stateWeights.atomization > 60) {
        usage.firstCast = '拉小饵快频率，边诱边�?;
      } else {
        usage.firstCast = '拉饵找口，注意控制饵团大�?;
      }
    } else if (input.fishingMethod === 'scatter') {
      if (stateWeights.weight > 60) {
        usage.firstCast = '散炮到底诱鱼，搓饵钓�?;
      } else {
        usage.firstCast = '先打散炮诱鱼，再搓饵�?;
      }
    } else if (input.fishingMethod === 'wrap') {
      usage.firstCast = '外层雾化诱鱼，内层留�?;
    } else {
      if (stateWeights.atomization > 50) {
        usage.firstCast = '前几竿加大饵团快速诱�?;
      } else {
        usage.firstCast = '搓大饵试鱼层，找到鱼层后调整';
      }
    }

    // 打窝建议 - 根据水域和状�?
    if (input.waterType === 'river') {
      if (stateWeights.viscosity > 60) {
        usage.nestSuggestion = '酒米+颗粒打底，粘饵带�?;
      } else {
        usage.nestSuggestion = '酒米+颗粒，少量多次补�?;
      }
    } else if (input.waterType === 'pond') {
      if (stateWeights.atomization > 60) {
        usage.nestSuggestion = '散炮带窝，高频率抽竿';
      } else {
        usage.nestSuggestion = '散炮带窝，边钓边�?;
      }
    } else if (input.waterType === 'reservoir') {
      if (stateWeights.weight > 60) {
        usage.nestSuggestion = '大窝守钓，玉�?颗粒+酒米';
      } else {
        usage.nestSuggestion = '提前打窝，耐心守钓';
      }
    } else {
      if (stateWeights.atomization > 50) {
        usage.nestSuggestion = '酒米打底，散炮诱�?;
      } else {
        usage.nestSuggestion = '酒米打底，适量补窝';
      }
    }

    return usage;
  }

  /**
   * 生成推荐理由
   */
  private generateReasons(input: GenerateRecipeInput, analysis: AnalysisResult, variant: RecipeVariant | null): GenerateReason[] {
    const reasons: GenerateReason[] = [];

    // 温度理由 - 根据具体温度生成更详细的理由
    const tempReason = new GenerateReason();
    if (input.temperature < 5) {
      tempReason.condition = `水温极低(${input.temperature}°C)`;
      tempReason.decision = '浓腥浓香，慢雾化留鱼';
      tempReason.icon = '❄️';
    } else if (input.temperature < 10) {
      tempReason.condition = `水温较低(${input.temperature}°C)`;
      tempReason.decision = '腥香为主，增加粘�?;
      tempReason.icon = '🌡�?;
    } else if (input.temperature < 15) {
      tempReason.condition = `水温偏低(${input.temperature}°C)`;
      tempReason.decision = '腥香兼顾，状态偏�?;
      tempReason.icon = '🌡�?;
    } else if (input.temperature < 25) {
      tempReason.condition = `水温适宜(${input.temperature}°C)`;
      tempReason.decision = '香甜为主，状态适中';
      tempReason.icon = '☀�?;
    } else if (input.temperature < 30) {
      tempReason.condition = `水温偏高(${input.temperature}°C)`;
      tempReason.decision = '清淡果香，快雾化';
      tempReason.icon = '🌤�?;
    } else {
      tempReason.condition = `水温较高(${input.temperature}°C)`;
      tempReason.decision = '本味清淡，加果酸';
      tempReason.icon = '🔥';
    }
    reasons.push(tempReason);

    // 水域理由 - 更详细的描述
    const waterReason = new GenerateReason();
    if (input.waterType === 'river') {
      waterReason.condition = '野河流水环境';
      waterReason.decision = '降低雾化，增加粘�?;
    } else if (input.waterType === 'pond') {
      waterReason.condition = '黑坑竞技环境';
      waterReason.decision = '快雾化诱鱼，味型突出';
    } else if (input.waterType === 'reservoir') {
      waterReason.condition = '水库大水�?;
      waterReason.decision = '重比重到底，持久留鱼';
    } else {
      waterReason.condition = '野塘自然环境';
      waterReason.decision = '本味为主，状态自�?;
    }
    waterReason.icon = '🌊';
    reasons.push(waterReason);

    // 鱼种理由
    const fishTemplate = getFishReasonTemplate(input.targetFishId);
    const fishReason = new GenerateReason();
    fishReason.condition = fishTemplate.condition;
    fishReason.decision = fishTemplate.decision;
    fishReason.icon = fishTemplate.icon;
    reasons.push(fishReason);

    // 变体理由 - 如果是换一换生成的
    if (variant !== null && variant.description) {
      const variantReason = new GenerateReason();
      variantReason.condition = '配方调整';
      // 根据变体策略生成更具体的理由
      switch (variant.strategy) {
        case 'flavor_shift':
          if (variant.flavorShift?.primaryShift === 'increase_fishy') {
            variantReason.decision = '增加腥味比例，提升诱鱼效�?;
          } else if (variant.flavorShift?.primaryShift === 'increase_fragrant') {
            variantReason.decision = '增加香味比例，适合滑口�?;
          } else if (variant.flavorShift?.primaryShift === 'increase_sweet') {
            variantReason.decision = '增加甜味，提升适口�?;
          } else if (variant.flavorShift?.primaryShift === 'decrease_intensity') {
            variantReason.decision = '整体减淡，适合警惕性高的鱼';
          } else if (variant.flavorShift?.primaryShift === 'more_atomization') {
            variantReason.decision = '增加雾化，加快诱鱼速度';
          } else if (variant.flavorShift?.primaryShift === 'more_viscosity') {
            variantReason.decision = '增加粘度，提升附钩�?;
          } else if (variant.flavorShift?.primaryShift === 'lighter') {
            variantReason.decision = '减轻比重，适合钓浮或离�?;
          } else if (variant.flavorShift?.primaryShift === 'heavier') {
            variantReason.decision = '增加比重，快速到底守大鱼';
          } else {
            variantReason.decision = variant.description;
          }
          break;
        case 'ingredient_swap':
          variantReason.decision = '更换原料组合，尝试不同效�?;
          break;
        case 'additive_change':
          variantReason.decision = '更换添加剂，调整味型方向';
          break;
        case 'ratio_adjust':
          variantReason.decision = '调整配比，优化饵料状�?;
          break;
        case 'state_change':
          variantReason.decision = '改变状态特性，适应不同鱼情';
          break;
        default:
          variantReason.decision = variant.description;
      }
      variantReason.icon = '🔄';
      reasons.push(variantReason);
    }

    // 鱼情理由
    const densityTemplate = getDensityReasonTemplate(input.fishDensity);
    if (densityTemplate !== null) {
      const r = new GenerateReason();
      r.condition = densityTemplate.condition;
      r.decision = densityTemplate.decision;
      r.icon = densityTemplate.icon;
      reasons.push(r);
    }

    // 开口理�?
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

    // 特殊场景理由
    for (let i = 0; i < analysis.specialScenarios.length; i++) {
      const scenario = analysis.specialScenarios[i];
      const scenarioReason = this.getScenarioReason(scenario);
      if (scenarioReason !== null) {
        reasons.push(scenarioReason);
      }
    }

    return reasons;
  }

  /**
   * 获取特殊场景理由
   */
  private getScenarioReason(scenario: string): GenerateReason | null {
    const r = new GenerateReason();

    switch (scenario) {
      case 'extreme_cold':
        r.condition = '极寒天气';
        r.decision = '高腥高蛋白配�?;
        r.icon = '❄️';
        return r;
      case 'extreme_hot':
        r.condition = '高温天气';
        r.decision = '清淡果酸配方';
        r.icon = '🔥';
        return r;
      case 'carnivore_fish':
        r.condition = '肉食性鱼�?;
        r.decision = '浓腥味型为主';
        r.icon = '🦈';
        return r;
      case 'black_pit_new':
        r.condition = '黑坑新放�?;
        r.decision = '可适当加小�?;
        r.icon = '🆕';
        return r;
      case 'black_pit_old':
        r.condition = '黑坑老鱼';
        r.decision = '本味为主，减少刺激';
        r.icon = '🐢';
        return r;
      case 'flowing_water':
        r.condition = '流水环境';
        r.decision = '增加粘度和比�?;
        r.icon = '🌊';
        return r;
      case 'deep_water':
        r.condition = '深水区域';
        r.decision = '重比重快到底';
        r.icon = '🏔�?;
        return r;
      default:
        return null;
    }
  }

  /**
   * 转换为星级评�?
   */
  private toStarRating(value: number): number {
    return Math.min(5, Math.max(1, Math.round(value / 20)));
  }

  /**
   * 生成唯一ID
   */
  private generateId(): string {
    return `recipe_${Date.now()}_${Math.random().toString(36).substring(2, 8)}`;
  }

  /**
   * 重置变体历史
   */
  resetVariantHistory(): void {
    getVariantManager().resetShownHistory();
    this.variantAttemptIndex = 0;
  }

  /**
   * 获取当前季节
   */
  getCurrentSeason(): RecipeSeason {
    const month = new Date().getMonth() + 1;
    if (month >= 3 && month <= 5) return 'spring';
    if (month >= 6 && month <= 8) return 'summer';
    if (month >= 9 && month <= 11) return 'autumn';
    return 'winter';
  }

  /**
   * 获取配置
   */
  getConfig(): EngineConfig {
    return this.config;
  }

  /**
   * 设置总重�?
   */
  setTotalWeight(weight: number): void {
    this.config.totalWeight = Math.max(100, Math.min(2000, weight));
  }
}

// 导出单例获取函数
export function getSmartRecipeEngine(): SmartRecipeEngine {
  return SmartRecipeEngine.getInstance();
}

// 导出便捷函数
export function generateSmartRecipe(input: GenerateRecipeInput): GeneratedRecipe {
  return getSmartRecipeEngine().generate(input);
}

export function getNextRecipeVariant(): GeneratedRecipe | null {
  return getSmartRecipeEngine().getNextVariant();
}

export function resetRecipeVariantHistory(): void {
  getSmartRecipeEngine().resetVariantHistory();
}

// 记录配方保存（供外部调用�?
export function recordRecipeSave(recipe: GeneratedRecipe): void {
  const prefLearner = getPreferenceLearner();
  if (prefLearner.isLoaded()) {
    prefLearner.recordSave(recipe);
  }
}

// 记录配方反馈（供外部调用�?
export function recordRecipeFeedback(recipeId: string, rating: 'good' | 'normal' | 'bad', note: string): void {
  const prefLearner = getPreferenceLearner();
  if (prefLearner.isLoaded()) {
    prefLearner.recordFeedback(recipeId, rating, note);
  }
}
