/**
 * 智能配方引擎
 * 整合环境分析、原料匹配、变体管理，提供统一的配方生成接口
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
  totalWeight: number = 500;           // 默认总重量
  mainRatio: number = 45;              // 主饵占比
  auxRatio: number = 25;               // 辅饵占比
  stateRatio: number = 18;             // 状态饵占比
  additiveRatio: number = 12;          // 添加剂占比
  maxVariantAttempts: number = 10;     // 最大变体尝试次数
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
   * 生成配方 (主入口)
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
   * 获取下一个变体 (换一换)
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

      // 使用变体参数生成新配方
      const newRecipe = this.buildRecipe(this.currentInput, this.currentAnalysis, variantParams);

      // 检查是否与历史配方重复
      if (!variantManager.isDuplicateRecipe(newRecipe)) {
        // 记录新配方
        variantManager.recordShownRecipe(conditionHash, newRecipe);
        return newRecipe;
      }
    }

    // 如果所有尝试都失败，强制生成一个（即使可能有些相似）
    const forcedVariant = variantManager.generateVariantParams(
      this.buildRecipe(this.currentInput, this.currentAnalysis, null),
      this.currentAnalysis,
      Date.now() % 100  // 使用时间戳增加随机性
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

    // 应用变体调整到分析结果
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

    // 4. 生成状态特性
    recipe.stateProfile = this.generateStateProfile(adjustedAnalysis.stateWeights);

    // 5. 生成使用建议
    recipe.usage = this.generateUsage(input, adjustedAnalysis.stateWeights);

    // 6. 生成推荐理由
    recipe.reasons = this.generateReasons(input, analysis, variant);

    return recipe;
  }

  /**
   * 应用变体调整到分析结果
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

      // 归一化
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

    // 1. 选主饵 (1-2种)
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

    // 2. 选辅饵 (1种)
    let auxCandidates = filterAvailable(fishRule.recommendedIngredients.auxiliary);
    if (variant !== null && variant.ingredientSwaps.length > 0) {
      auxCandidates = this.applySwapsToCandidate(auxCandidates, variant, 'auxiliary');
    }
    const auxSelected = pool.matchByFlavor(analysis.flavorWeights, auxCandidates, 1, selectedIds);
    for (let i = 0; i < auxSelected.length; i++) {
      selectedIds.push(auxSelected[i].ingredient.id);
      result.push(this.createRecipeIngredient(auxSelected[i], 'auxiliary', this.config.auxRatio));
    }

    // 3. 选状态饵 (1种)
    let stateCandidates = filterAvailable(fishRule.recommendedIngredients.state);
    if (variant !== null && variant.ingredientSwaps.length > 0) {
      stateCandidates = this.applySwapsToCandidate(stateCandidates, variant, 'state');
    }
    const stateSelected = pool.matchByState(analysis.stateWeights, stateCandidates, input.fishingMethod, 1, selectedIds);
    for (let i = 0; i < stateSelected.length; i++) {
      selectedIds.push(stateSelected[i].ingredient.id);
      result.push(this.createRecipeIngredient(stateSelected[i], 'state', this.config.stateRatio));
    }

    // 4. 选添加剂 (1种)
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
   * 应用原料替换到候选列表
   */
  private applySwapsToCandidate(candidates: string[], variant: RecipeVariant, category: string): string[] {
    const result: string[] = [];

    for (let i = 0; i < candidates.length; i++) {
      let swapped = false;
      for (let j = 0; j < variant.ingredientSwaps.length; j++) {
        const swap = variant.ingredientSwaps[j];
        if (swap.originalId === candidates[i]) {
          // 将替换原料放在前面（优先选择）
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
   * 归一化配比
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
   * 获取原料用途说明
   */
  private getIngredientPurpose(category: string, reasons: string[]): string {
    let base = '';
    if (category === 'main') base = '主饵，提供基础味型';
    else if (category === 'auxiliary') base = '辅饵，增强诱鱼效果';
    else if (category === 'state') base = '状态粉，调节雾化粘度';
    else if (category === 'additive') base = '添加剂，提升味型浓度';

    if (reasons.length > 0) {
      base += '，' + reasons.join('、');
    }
    return base;
  }

  /**
   * 获取默认原料
   */
  private getDefaultIngredients(): RecipeIngredient[] {
    const result: RecipeIngredient[] = [];

    const main = new RecipeIngredient();
    main.id = 'corn_flour'; main.name = '玉米粉'; main.category = 'main';
    main.percentage = 45; main.weight = 225; main.purpose = '主饵，提供基础味型';
    result.push(main);

    const aux = new RecipeIngredient();
    aux.id = 'fish_meal'; aux.name = '鱼粉'; aux.category = 'auxiliary';
    aux.percentage = 25; aux.weight = 125; aux.purpose = '辅饵，增强诱鱼效果';
    result.push(aux);

    const state = new RecipeIngredient();
    state.id = 'drawing_powder'; state.name = '拉丝粉'; state.category = 'state';
    state.percentage = 18; state.weight = 90; state.purpose = '状态粉，调节雾化粘度';
    result.push(state);

    const add = new RecipeIngredient();
    add.id = 'dmpt'; add.name = 'DMPT诱食剂'; add.category = 'additive';
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

    const fishName = analysis.fishRule ? analysis.fishRule.fishName : '目标鱼';

    let suffix = '';
    if (input.mode === 'conservative') suffix = '稳';
    else if (input.mode === 'aggressive') suffix = '猛';
    else suffix = '衡';

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
        if (variant.flavorShift?.primaryShift === 'increase_fishy') return '·腥';
        if (variant.flavorShift?.primaryShift === 'increase_fragrant') return '·香';
        if (variant.flavorShift?.primaryShift === 'increase_sweet') return '·甜';
        if (variant.flavorShift?.primaryShift === 'increase_sour') return '·酸';
        if (variant.flavorShift?.primaryShift === 'decrease_intensity') return '·淡';
        return '·变';
      case 'ingredient_swap':
        return '·换';
      case 'additive_change':
        return '·药';
      case 'ratio_adjust':
        return '·调';
      case 'state_change':
        return '·态';
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
   * 生成状态特性
   */
  private generateStateProfile(weights: StateWeights): StateProfile {
    const profile = new StateProfile();

    // 转换为1-5星级，增加随机变化
    const randomOffset = (): number => {
      // 随机 -1, 0, 或 +1
      return Math.floor(Math.random() * 3) - 1;
    };

    profile.atomization = Math.min(5, Math.max(1, this.toStarRating(weights.atomization) + randomOffset()));
    profile.viscosity = Math.min(5, Math.max(1, this.toStarRating(weights.viscosity) + randomOffset()));
    profile.hookHolding = Math.min(5, Math.max(1, Math.round(weights.viscosity / 20) + randomOffset()));
    profile.weight = Math.min(5, Math.max(1, this.toStarRating(weights.weight) + randomOffset()));

    return profile;
  }

  /**
   * 生成使用建议
   */
  private generateUsage(input: GenerateRecipeInput, stateWeights: StateWeights): UsageSuggestion {
    const usage = new UsageSuggestion();

    // 水比
    if (stateWeights.atomization > 60) {
      usage.waterRatio = '1:0.8';
    } else if (stateWeights.atomization > 40) {
      usage.waterRatio = '1:0.9';
    } else {
      usage.waterRatio = '1:1';
    }

    // 静置时间
    if (stateWeights.viscosity > 60) {
      usage.restTime = '10-15分钟';
    } else if (stateWeights.viscosity > 40) {
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
   * 生成推荐理由
   */
  private generateReasons(input: GenerateRecipeInput, analysis: AnalysisResult, variant: RecipeVariant | null): GenerateReason[] {
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

    // 变体理由
    if (variant !== null && variant.description) {
      const variantReason = new GenerateReason();
      variantReason.condition = '配方变体';
      variantReason.decision = variant.description;
      variantReason.icon = '🔄';
      reasons.push(variantReason);
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
        r.decision = '高腥高蛋白配方';
        r.icon = '❄️';
        return r;
      case 'extreme_hot':
        r.condition = '高温天气';
        r.decision = '清淡果酸配方';
        r.icon = '🔥';
        return r;
      case 'carnivore_fish':
        r.condition = '肉食性鱼类';
        r.decision = '浓腥味型为主';
        r.icon = '🦈';
        return r;
      case 'black_pit_new':
        r.condition = '黑坑新放鱼';
        r.decision = '可适当加小药';
        r.icon = '🆕';
        return r;
      case 'black_pit_old':
        r.condition = '黑坑老鱼';
        r.decision = '本味为主，减少刺激';
        r.icon = '🐢';
        return r;
      case 'flowing_water':
        r.condition = '流水环境';
        r.decision = '增加粘度和比重';
        r.icon = '🌊';
        return r;
      case 'deep_water':
        r.condition = '深水区域';
        r.decision = '重比重快到底';
        r.icon = '🏔️';
        return r;
      default:
        return null;
    }
  }

  /**
   * 转换为星级评分
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
   * 设置总重量
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

// 记录配方保存（供外部调用）
export function recordRecipeSave(recipe: GeneratedRecipe): void {
  const prefLearner = getPreferenceLearner();
  if (prefLearner.isLoaded()) {
    prefLearner.recordSave(recipe);
  }
}

// 记录配方反馈（供外部调用）
export function recordRecipeFeedback(recipeId: string, rating: 'good' | 'normal' | 'bad', note: string): void {
  const prefLearner = getPreferenceLearner();
  if (prefLearner.isLoaded()) {
    prefLearner.recordFeedback(recipeId, rating, note);
  }
}
