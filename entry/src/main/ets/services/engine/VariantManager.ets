/**
 * 变体管理�?
 * 管理配方变体，确�?换一�?功能能提供真正不同的配方
 */
import { GeneratedRecipe, RecipeIngredient, GenerateRecipeInput } from '../../common/types/RecipeTypes';
import { FlavorWeights, StateWeights, AnalysisResult } from './ContextAnalyzer';

// 变体策略
export type VariantStrategy =
  'flavor_shift' |      // 味型偏移 (如腥香→香腥)
  'ingredient_swap' |   // 原料替换
  'additive_change' |   // 添加剂更�?
  'ratio_adjust' |      // 配比调整
  'state_change';       // 状态改�?

// 配方变体
export class RecipeVariant {
  id: string = '';
  strategy: VariantStrategy = 'ingredient_swap';
  baseRecipeId: string = '';
  differenceScore: number = 0;  // 与基准配方的差异�?(0-100)
  description: string = '';     // 变体描述

  // 变体参数调整
  flavorShift: FlavorShiftParams | null = null;
  ingredientSwaps: IngredientSwap[] = [];
  ratioAdjustments: RatioAdjustment[] = [];

  constructor() {
    this.id = `variant_${Date.now()}_${Math.random().toString(36).substring(2, 6)}`;
  }
}

// 味型偏移参数
export class FlavorShiftParams {
  primaryShift: string = '';    // 主味型变化方�?
  intensityChange: number = 0;  // 浓度变化 (-20 �?+20)

  constructor() {}

  static create(shift: string, intensity: number): FlavorShiftParams {
    const p = new FlavorShiftParams();
    p.primaryShift = shift;
    p.intensityChange = intensity;
    return p;
  }
}

// 原料替换
export class IngredientSwap {
  originalId: string = '';
  replacementId: string = '';
  reason: string = '';

  constructor() {}

  static create(orig: string, repl: string, reason: string): IngredientSwap {
    const s = new IngredientSwap();
    s.originalId = orig;
    s.replacementId = repl;
    s.reason = reason;
    return s;
  }
}

// 配比调整
export class RatioAdjustment {
  ingredientId: string = '';
  originalRatio: number = 0;
  newRatio: number = 0;

  constructor() {}

  static create(id: string, orig: number, newR: number): RatioAdjustment {
    const a = new RatioAdjustment();
    a.ingredientId = id;
    a.originalRatio = orig;
    a.newRatio = newR;
    return a;
  }
}

// 变体生成配置
export class VariantConfig {
  minDifference: number = 25;   // 最小差异度要求
  maxAttempts: number = 10;     // 最大尝试次�?
  strategies: VariantStrategy[] = ['ingredient_swap', 'flavor_shift', 'additive_change', 'ratio_adjust'];

  constructor() {}
}

// 配比调整模式
export class RatioPattern {
  main: number = 0;
  aux: number = 0;
  state: number = 0;
  additive: number = 0;

  constructor() {}

  static create(main: number, aux: number, state: number = 0, additive: number = 0): RatioPattern {
    const p = new RatioPattern();
    p.main = main;
    p.aux = aux;
    p.state = state;
    p.additive = additive;
    return p;
  }
}

// 变体管理�?
export class VariantManager {
  private static instance: VariantManager | null = null;

  // 已展示的变体记录 (conditionHash -> Set<variantId>)
  private shownVariants: Map<string, Set<string>> = new Map();

  // 变体缓存 (conditionHash -> RecipeVariant[])
  private variantCache: Map<string, RecipeVariant[]> = new Map();

  // 当前会话的配方历�?(用于计算差异)
  private sessionRecipes: GeneratedRecipe[] = [];

  // 配置
  private config: VariantConfig = new VariantConfig();

  private constructor() {}

  static getInstance(): VariantManager {
    if (VariantManager.instance === null) {
      VariantManager.instance = new VariantManager();
    }
    return VariantManager.instance;
  }

  /**
   * 生成变体参数
   * 返回用于生成不同配方的参数调�?
   */
  generateVariantParams(
    baseRecipe: GeneratedRecipe,
    analysisResult: AnalysisResult,
    attemptIndex: number
  ): RecipeVariant {
    const variant = new RecipeVariant();
    variant.baseRecipeId = baseRecipe.id;

    // 根据尝试次数选择不同策略
    const strategyIndex = attemptIndex % this.config.strategies.length;
    variant.strategy = this.config.strategies[strategyIndex];

    switch (variant.strategy) {
      case 'flavor_shift':
        this.applyFlavorShiftStrategy(variant, analysisResult, attemptIndex);
        break;
      case 'ingredient_swap':
        this.applyIngredientSwapStrategy(variant, baseRecipe, attemptIndex);
        break;
      case 'additive_change':
        this.applyAdditiveChangeStrategy(variant, baseRecipe, attemptIndex);
        break;
      case 'ratio_adjust':
        this.applyRatioAdjustStrategy(variant, baseRecipe, attemptIndex);
        break;
      case 'state_change':
        this.applyStateChangeStrategy(variant, analysisResult, attemptIndex);
        break;
    }

    return variant;
  }


  /**
   * 味型偏移策略
   */
  private applyFlavorShiftStrategy(variant: RecipeVariant, analysis: AnalysisResult, index: number): void {
    const shifts = ['increase_fishy', 'increase_fragrant', 'increase_sweet', 'decrease_intensity', 'increase_sour'];
    const shiftType = shifts[index % shifts.length];

    let intensityChange = 0;
    let description = '';

    switch (shiftType) {
      case 'increase_fishy':
        intensityChange = 15 + (index % 3) * 5;
        description = '增加腥味比例';
        break;
      case 'increase_fragrant':
        intensityChange = 15 + (index % 3) * 5;
        description = '增加香味比例';
        break;
      case 'increase_sweet':
        intensityChange = 10 + (index % 3) * 5;
        description = '增加甜味比例';
        break;
      case 'decrease_intensity':
        intensityChange = -15 - (index % 3) * 5;
        description = '整体味型减淡';
        break;
      case 'increase_sour':
        intensityChange = 10 + (index % 2) * 5;
        description = '增加酸味比例';
        break;
    }

    variant.flavorShift = FlavorShiftParams.create(shiftType, intensityChange);
    variant.description = description;
    variant.differenceScore = 20 + Math.abs(intensityChange);
  }

  /**
   * 原料替换策略
   */
  private applyIngredientSwapStrategy(variant: RecipeVariant, baseRecipe: GeneratedRecipe, index: number): void {
    // 根据index决定替换哪类原料
    const categories = ['main', 'auxiliary', 'additive', 'state'];
    const targetCategory = categories[index % categories.length];

    // 找到该类别的原料
    for (let i = 0; i < baseRecipe.ingredients.length; i++) {
      const ing = baseRecipe.ingredients[i];
      if (ing.category === targetCategory) {
        // 生成替换建议
        const swap = new IngredientSwap();
        swap.originalId = ing.id;
        swap.replacementId = this.getAlternativeIngredientId(ing.id, ing.category, index);
        swap.reason = `更换${this.getCategoryName(targetCategory)}`;
        variant.ingredientSwaps.push(swap);
        break;
      }
    }

    variant.description = `更换${this.getCategoryName(targetCategory)}`;
    variant.differenceScore = 30 + (index % 3) * 10;
  }

  /**
   * 添加剂更换策�?
   */
  private applyAdditiveChangeStrategy(variant: RecipeVariant, baseRecipe: GeneratedRecipe, index: number): void {
    // 专门针对添加剂的替换
    for (let i = 0; i < baseRecipe.ingredients.length; i++) {
      const ing = baseRecipe.ingredients[i];
      if (ing.category === 'additive') {
        const swap = new IngredientSwap();
        swap.originalId = ing.id;
        swap.replacementId = this.getAlternativeAdditiveId(ing.id, index);
        swap.reason = '更换添加剂类�?;
        variant.ingredientSwaps.push(swap);
      }
    }

    variant.description = '更换添加剂配�?;
    variant.differenceScore = 25 + (index % 4) * 8;
  }

  /**
   * 配比调整策略
   */
  private applyRatioAdjustStrategy(variant: RecipeVariant, baseRecipe: GeneratedRecipe, index: number): void {
    // 调整主饵和辅饵的比例
    const adjustmentPatterns: RatioPattern[] = [
      RatioPattern.create(5, -5, 0, 0),      // 增加主饵
      RatioPattern.create(-5, 5, 0, 0),      // 增加辅饵
      RatioPattern.create(0, -5, 5, 0),      // 增加状态饵
      RatioPattern.create(-3, -2, 0, 5)      // 增加添加�?
    ];

    const pattern = adjustmentPatterns[index % adjustmentPatterns.length];

    for (let i = 0; i < baseRecipe.ingredients.length; i++) {
      const ing = baseRecipe.ingredients[i];
      let adjustment = 0;

      if (ing.category === 'main') {
        adjustment = pattern.main;
      } else if (ing.category === 'auxiliary') {
        adjustment = pattern.aux;
      } else if (ing.category === 'state') {
        adjustment = pattern.state;
      } else if (ing.category === 'additive') {
        adjustment = pattern.additive;
      }

      if (adjustment !== 0) {
        const ratioAdj = RatioAdjustment.create(
          ing.id,
          ing.percentage,
          Math.max(5, Math.min(60, ing.percentage + adjustment))
        );
        variant.ratioAdjustments.push(ratioAdj);
      }
    }

    variant.description = '调整配比比例';
    variant.differenceScore = 15 + (index % 3) * 5;
  }

  /**
   * 状态改变策�?
   */
  private applyStateChangeStrategy(variant: RecipeVariant, analysis: AnalysisResult, index: number): void {
    // 改变状态饵选择
    const stateChanges = ['more_atomization', 'more_viscosity', 'lighter', 'heavier'];
    const changeType = stateChanges[index % stateChanges.length];

    let description = '';
    switch (changeType) {
      case 'more_atomization':
        description = '增加雾化效果';
        break;
      case 'more_viscosity':
        description = '增加粘度';
        break;
      case 'lighter':
        description = '减轻比重';
        break;
      case 'heavier':
        description = '增加比重';
        break;
    }

    variant.flavorShift = FlavorShiftParams.create(changeType, 0);
    variant.description = description;
    variant.differenceScore = 20 + (index % 3) * 8;
  }

  /**
   * 获取替代原料ID
   */
  private getAlternativeIngredientId(originalId: string, category: string, index: number): string {
    // 主饵替代列表
    const mainAlternatives: Map<string, string[]> = new Map();
    mainAlternatives.set('corn_flour', ['wheat_bran', 'sweet_potato_flour', 'soybean_flour', 'rice_bran']);
    mainAlternatives.set('wheat_bran', ['corn_flour', 'rice_bran', 'bread_crumb', 'soybean_cake']);
    mainAlternatives.set('soybean_flour', ['peanut_flour', 'corn_flour', 'sesame_flour']);
    mainAlternatives.set('sweet_potato_flour', ['potato_flour', 'corn_flour', 'soybean_flour']);

    // 辅饵替代列表
    const auxAlternatives: Map<string, string[]> = new Map();
    auxAlternatives.set('fish_meal', ['shrimp_powder', 'silkworm_pupa_powder', 'squid_powder']);
    auxAlternatives.set('shrimp_powder', ['fish_meal', 'crab_powder', 'clam_powder']);
    auxAlternatives.set('silkworm_pupa_powder', ['fish_meal', 'earthworm_powder', 'bloodworm_powder']);

    // 状态饵替代列表
    const stateAlternatives: Map<string, string[]> = new Map();
    stateAlternatives.set('drawing_powder', ['snowflake_powder', 'light_bran', 'sticky_powder']);
    stateAlternatives.set('snowflake_powder', ['light_bran', 'puffed_corn', 'drawing_powder']);
    stateAlternatives.set('sticky_powder', ['glutinous_rice_flour', 'tapioca_starch', 'drawing_powder']);

    let alternatives: string[] = [];
    if (category === 'main') {
      alternatives = mainAlternatives.get(originalId) || ['corn_flour', 'wheat_bran', 'soybean_flour'];
    } else if (category === 'auxiliary') {
      alternatives = auxAlternatives.get(originalId) || ['fish_meal', 'shrimp_powder', 'silkworm_pupa_powder'];
    } else if (category === 'state') {
      alternatives = stateAlternatives.get(originalId) || ['drawing_powder', 'snowflake_powder', 'sticky_powder'];
    }

    return alternatives[index % alternatives.length];
  }

  /**
   * 获取替代添加剂ID
   */
  private getAlternativeAdditiveId(originalId: string, index: number): string {
    const additiveGroups: string[][] = [
      ['dmpt', 'betaine', 'amino_acid'],           // 诱食剂组
      ['vanilla_essence', 'strawberry_essence', 'banana_essence', 'honey_essence'],  // 甜香�?
      ['garlic_essence', 'anise_essence', 'fishy_essence'],  // 特殊香型�?
      ['white_sugar', 'brown_sugar', 'honey'],     // 甜味�?
      ['sesame_oil', 'peanut_oil', 'fish_oil']     // 油类�?
    ];

    // 找到原料所在的�?
    let groupIndex = -1;
    let posInGroup = -1;
    for (let i = 0; i < additiveGroups.length; i++) {
      for (let j = 0; j < additiveGroups[i].length; j++) {
        if (additiveGroups[i][j] === originalId) {
          groupIndex = i;
          posInGroup = j;
          break;
        }
      }
      if (groupIndex >= 0) break;
    }

    if (groupIndex >= 0) {
      // 在同组内选择不同�?
      const group = additiveGroups[groupIndex];
      const newPos = (posInGroup + 1 + index) % group.length;
      return group[newPos];
    }

    // 默认返回常用添加�?
    const defaults = ['dmpt', 'honey_essence', 'garlic_essence', 'white_sugar'];
    return defaults[index % defaults.length];
  }

  /**
   * 获取类别名称
   */
  private getCategoryName(category: string): string {
    if (category === 'main') return '主饵';
    if (category === 'auxiliary') return '辅饵';
    if (category === 'state') return '状态饵';
    if (category === 'additive') return '添加�?;
    return '原料';
  }

  /**
   * 记录已展示的配方
   */
  recordShownRecipe(conditionHash: string, recipe: GeneratedRecipe): void {
    // 记录到已展示集合
    let shown = this.shownVariants.get(conditionHash);
    if (!shown) {
      shown = new Set<string>();
      this.shownVariants.set(conditionHash, shown);
    }
    shown.add(recipe.id);

    // 记录到会话历�?
    this.sessionRecipes.push(recipe);

    // 限制历史大小
    if (this.sessionRecipes.length > 20) {
      this.sessionRecipes.shift();
    }
  }

  /**
   * 获取已展示的配方数量
   */
  getShownCount(conditionHash: string): number {
    const shown = this.shownVariants.get(conditionHash);
    return shown ? shown.size : 0;
  }

  /**
   * 检查配方是否与历史配方重复
   */
  isDuplicateRecipe(recipe: GeneratedRecipe): boolean {
    for (let i = 0; i < this.sessionRecipes.length; i++) {
      if (this.calculateRecipeDifference(recipe, this.sessionRecipes[i]) < this.config.minDifference) {
        return true;
      }
    }
    return false;
  }

  /**
   * 计算两个配方的差异度
   */
  calculateRecipeDifference(recipe1: GeneratedRecipe, recipe2: GeneratedRecipe): number {
    let ingredientDiff = 0;
    let flavorDiff = 0;
    let stateDiff = 0;

    // 1. 原料差异 (权重50%)
    const ids1 = new Set<string>();
    const ids2 = new Set<string>();
    for (let i = 0; i < recipe1.ingredients.length; i++) {
      ids1.add(recipe1.ingredients[i].id);
    }
    for (let i = 0; i < recipe2.ingredients.length; i++) {
      ids2.add(recipe2.ingredients[i].id);
    }

    // 计算不同的原料数�?
    let diffCount = 0;
    ids1.forEach((id) => {
      if (!ids2.has(id)) diffCount++;
    });
    ids2.forEach((id) => {
      if (!ids1.has(id)) diffCount++;
    });

    ingredientDiff = diffCount * 15; // 每个不同原料15�?

    // 2. 味型差异 (权重30%)
    const fp1 = recipe1.flavorProfile;
    const fp2 = recipe2.flavorProfile;
    if (fp1.primary !== fp2.primary) flavorDiff += 20;
    if (fp1.secondary !== fp2.secondary) flavorDiff += 10;
    flavorDiff += Math.abs(fp1.intensity - fp2.intensity) * 3;

    // 3. 状态差�?(权重20%)
    const sp1 = recipe1.stateProfile;
    const sp2 = recipe2.stateProfile;
    stateDiff += Math.abs(sp1.atomization - sp2.atomization) * 4;
    stateDiff += Math.abs(sp1.viscosity - sp2.viscosity) * 3;
    stateDiff += Math.abs(sp1.weight - sp2.weight) * 3;

    // 综合差异�?
    const totalDiff = ingredientDiff * 0.5 + flavorDiff * 0.3 + stateDiff * 0.2;
    return Math.min(100, totalDiff);
  }

  /**
   * 生成条件哈希
   */
  hashConditions(input: GenerateRecipeInput): string {
    return `${input.targetFishId}_${input.waterType}_${input.season}_${input.mode}`;
  }

  /**
   * 重置已展示历�?
   */
  resetShownHistory(): void {
    this.shownVariants.clear();
    this.sessionRecipes = [];
  }

  /**
   * 重置特定条件的历�?
   */
  resetConditionHistory(conditionHash: string): void {
    this.shownVariants.delete(conditionHash);
  }

  /**
   * 获取配置
   */
  getConfig(): VariantConfig {
    return this.config;
  }

  /**
   * 设置最小差异度
   */
  setMinDifference(value: number): void {
    this.config.minDifference = Math.max(10, Math.min(50, value));
  }
}

// 导出单例获取函数
export function getVariantManager(): VariantManager {
  return VariantManager.getInstance();
}
