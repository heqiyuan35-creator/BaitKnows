/**
 * 原料�?
 * 管理所有可用原料，支持多维度筛选和匹配
 */
import { Ingredient, IngredientCategory, Season, getAllIngredients, getIngredientById } from '../../data/IngredientDatabase';
import { FlavorWeights, StateWeights } from './ContextAnalyzer';
import { FishingMethod } from '../../common/types/RecipeTypes';
import { getPreferenceLearner } from './PreferenceLearner';

// 带分数的原料
export class ScoredIngredient {
  ingredient: Ingredient;
  score: number = 0;
  matchReasons: string[] = [];

  constructor(ing: Ingredient) {
    this.ingredient = ing;
  }
}

// 原料�?
export class IngredientPool {
  private static instance: IngredientPool | null = null;
  private ingredients: Ingredient[] = [];
  private categoryIndex: Map<string, string[]> = new Map();  // category -> id[]
  private fishIndex: Map<string, string[]> = new Map();      // fishId -> id[]
  private seasonIndex: Map<string, string[]> = new Map();    // season -> id[]
  private initialized: boolean = false;
  private usePreference: boolean = true;  // 是否使用偏好加成

  private constructor() {}

  static getInstance(): IngredientPool {
    if (IngredientPool.instance === null) {
      IngredientPool.instance = new IngredientPool();
    }
    return IngredientPool.instance;
  }

  /**
   * 初始化索�?
   */
  initialize(): void {
    if (this.initialized) return;

    this.ingredients = getAllIngredients();

    // 构建类别索引
    for (let i = 0; i < this.ingredients.length; i++) {
      const ing = this.ingredients[i];

      // 类别索引
      const catIds = this.categoryIndex.get(ing.category) || [];
      catIds.push(ing.id);
      this.categoryIndex.set(ing.category, catIds);

      // 鱼种索引
      for (let j = 0; j < ing.targetFish.length; j++) {
        const fishId = ing.targetFish[j];
        const fishIds = this.fishIndex.get(fishId) || [];
        fishIds.push(ing.id);
        this.fishIndex.set(fishId, fishIds);
      }

      // 季节索引
      for (let j = 0; j < ing.suitableSeason.length; j++) {
        const season = ing.suitableSeason[j];
        const seasonIds = this.seasonIndex.get(season) || [];
        seasonIds.push(ing.id);
        this.seasonIndex.set(season, seasonIds);
      }
    }

    this.initialized = true;
  }

  /**
   * 按味型权重匹配原�?
   */
  matchByFlavor(
    weights: FlavorWeights,
    candidateIds: string[],
    count: number,
    excludeIds: string[] = []
  ): ScoredIngredient[] {
    this.initialize();
    const scored: ScoredIngredient[] = [];

    for (let i = 0; i < candidateIds.length; i++) {
      const id = candidateIds[i];

      // 排除已选原�?
      let excluded = false;
      for (let j = 0; j < excludeIds.length; j++) {
        if (excludeIds[j] === id) {
          excluded = true;
          break;
        }
      }
      if (excluded) continue;

      const ing = getIngredientById(id);
      if (ing === null) continue;

      const scoredIng = new ScoredIngredient(ing);
      const fp = ing.flavorProfile;

      // 计算味型匹配分数
      // 使用加权匹配：原料味型与目标权重的匹配度
      let score = 0;
      const reasons: string[] = [];

      // 腥味匹配
      if (weights.fishy > 50 && fp.fishy > 50) {
        score += Math.min(fp.fishy, weights.fishy) * 0.3;
        if (fp.fishy > 70) reasons.push('腥味浓郁');
      } else if (weights.fishy < 30 && fp.fishy < 30) {
        score += 20; // 都不需要腥味也是匹�?
      }

      // 香味匹配
      if (weights.fragrant > 50 && fp.fragrant > 50) {
        score += Math.min(fp.fragrant, weights.fragrant) * 0.25;
        if (fp.fragrant > 70) reasons.push('香味突出');
      }

      // 甜味匹配
      if (weights.sweet > 50 && fp.sweet > 50) {
        score += Math.min(fp.sweet, weights.sweet) * 0.2;
        if (fp.sweet > 70) reasons.push('甜味明显');
      }

      // 酸味匹配
      if (weights.sour > 40 && fp.sour > 40) {
        score += Math.min(fp.sour, weights.sour) * 0.15;
        if (fp.sour > 60) reasons.push('酸味适中');
      }

      // 臭味匹配
      if (weights.stinky > 40 && fp.stinky > 40) {
        score += Math.min(fp.stinky, weights.stinky) * 0.1;
        if (fp.stinky > 60) reasons.push('臭味独特');
      }

      // 加入随机因子增加变化 (0-15�?
      score += Math.random() * 15;

      // 应用用户偏好加成 (0-20�?
      if (this.usePreference) {
        const prefLearner = getPreferenceLearner();
        if (prefLearner.isLoaded()) {
          const prefBoost = prefLearner.getPreferenceBoost(id);
          if (prefBoost > 0) {
            score += prefBoost;
            if (prefBoost >= 10) reasons.push('常用原料');
          }
        }
      }

      scoredIng.score = score;
      scoredIng.matchReasons = reasons;
      scored.push(scoredIng);
    }

    // 按分数排�?
    scored.sort((a: ScoredIngredient, b: ScoredIngredient): number => b.score - a.score);

    // 返回前N�?
    const result: ScoredIngredient[] = [];
    const maxCount = Math.min(count, scored.length);
    for (let i = 0; i < maxCount; i++) {
      result.push(scored[i]);
    }
    return result;
  }


  /**
   * 按状态权重匹配原�?
   */
  matchByState(
    weights: StateWeights,
    candidateIds: string[],
    method: FishingMethod,
    count: number,
    excludeIds: string[] = []
  ): ScoredIngredient[] {
    this.initialize();
    const scored: ScoredIngredient[] = [];

    for (let i = 0; i < candidateIds.length; i++) {
      const id = candidateIds[i];

      // 排除已选原�?
      let excluded = false;
      for (let j = 0; j < excludeIds.length; j++) {
        if (excludeIds[j] === id) {
          excluded = true;
          break;
        }
      }
      if (excluded) continue;

      const ing = getIngredientById(id);
      if (ing === null) continue;

      const scoredIng = new ScoredIngredient(ing);
      const phys = ing.physical;
      let score = 0;
      const reasons: string[] = [];

      // 雾化匹配
      if (weights.atomization > 60) {
        // 需要快雾化
        score += phys.atomization * 8;
        if (phys.atomization > 7) reasons.push('雾化�?);
      } else if (weights.atomization < 40) {
        // 需要慢雾化
        score += (10 - phys.atomization) * 8;
        if (phys.atomization < 4) reasons.push('雾化�?);
      } else {
        score += 30; // 中等雾化
      }

      // 粘度匹配
      if (weights.viscosity > 60) {
        score += phys.viscosity * 6;
        if (phys.viscosity > 7) reasons.push('粘性强');
      } else if (weights.viscosity < 40) {
        score += (10 - phys.viscosity) * 6;
      }

      // 比重匹配
      if (weights.weight > 60) {
        score += phys.weight * 5;
        if (phys.weight > 7) reasons.push('比重�?);
      } else if (weights.weight < 40) {
        score += (10 - phys.weight) * 5;
        if (phys.weight < 4) reasons.push('比重�?);
      }

      // 作钓方式特殊加分
      if (method === 'pull' && id === 'drawing_powder') {
        score += 50;
        reasons.push('拉饵必备');
      }
      if (method === 'scatter' && id === 'snowflake_powder') {
        score += 50;
        reasons.push('散炮必备');
      }
      if (method === 'scatter' && id === 'light_bran') {
        score += 40;
        reasons.push('散炮推荐');
      }

      // 随机因子
      score += Math.random() * 10;

      scoredIng.score = score;
      scoredIng.matchReasons = reasons;
      scored.push(scoredIng);
    }

    scored.sort((a: ScoredIngredient, b: ScoredIngredient): number => b.score - a.score);

    const result: ScoredIngredient[] = [];
    const maxCount = Math.min(count, scored.length);
    for (let i = 0; i < maxCount; i++) {
      result.push(scored[i]);
    }
    return result;
  }

  /**
   * 按鱼种筛选原料ID
   */
  filterByFish(fishId: string): string[] {
    this.initialize();
    return this.fishIndex.get(fishId) || [];
  }

  /**
   * 按季节筛选原料ID
   */
  filterBySeason(season: Season): string[] {
    this.initialize();
    return this.seasonIndex.get(season) || [];
  }

  /**
   * 按类别获取原料ID
   */
  getByCategory(category: IngredientCategory): string[] {
    this.initialize();
    return this.categoryIndex.get(category) || [];
  }

  /**
   * 获取替代原料
   * 找到与指定原料味型相似的其他原料
   */
  getAlternatives(ingredientId: string, count: number = 3): Ingredient[] {
    this.initialize();
    const original = getIngredientById(ingredientId);
    if (original === null) return [];

    const alternatives: ScoredIngredient[] = [];
    const sameCategory = this.categoryIndex.get(original.category) || [];

    for (let i = 0; i < sameCategory.length; i++) {
      const id = sameCategory[i];
      if (id === ingredientId) continue;

      const ing = getIngredientById(id);
      if (ing === null) continue;

      // 计算味型相似�?
      const scoredIng = new ScoredIngredient(ing);
      let similarity = 100;

      // 味型差异越小，相似度越高
      similarity -= Math.abs(original.flavorProfile.fishy - ing.flavorProfile.fishy) * 0.3;
      similarity -= Math.abs(original.flavorProfile.fragrant - ing.flavorProfile.fragrant) * 0.3;
      similarity -= Math.abs(original.flavorProfile.sweet - ing.flavorProfile.sweet) * 0.2;
      similarity -= Math.abs(original.flavorProfile.sour - ing.flavorProfile.sour) * 0.1;
      similarity -= Math.abs(original.flavorProfile.stinky - ing.flavorProfile.stinky) * 0.1;

      scoredIng.score = Math.max(0, similarity);
      alternatives.push(scoredIng);
    }

    alternatives.sort((a: ScoredIngredient, b: ScoredIngredient): number => b.score - a.score);

    const result: Ingredient[] = [];
    const maxCount = Math.min(count, alternatives.length);
    for (let i = 0; i < maxCount; i++) {
      result.push(alternatives[i].ingredient);
    }
    return result;
  }

  /**
   * 获取互补原料
   * 找到能补充指定原料缺失味型的原料
   */
  getComplementary(ingredientId: string, targetWeights: FlavorWeights, count: number = 2): Ingredient[] {
    this.initialize();
    const original = getIngredientById(ingredientId);
    if (original === null) return [];

    // 计算缺失的味�?
    const missing = new FlavorWeights();
    missing.fishy = Math.max(0, targetWeights.fishy - original.flavorProfile.fishy);
    missing.fragrant = Math.max(0, targetWeights.fragrant - original.flavorProfile.fragrant);
    missing.sweet = Math.max(0, targetWeights.sweet - original.flavorProfile.sweet);
    missing.sour = Math.max(0, targetWeights.sour - original.flavorProfile.sour);
    missing.stinky = Math.max(0, targetWeights.stinky - original.flavorProfile.stinky);

    // 在所有原料中找能补充缺失味型�?
    const complementary: ScoredIngredient[] = [];

    for (let i = 0; i < this.ingredients.length; i++) {
      const ing = this.ingredients[i];
      if (ing.id === ingredientId) continue;
      if (ing.category === 'live' || ing.category === 'folk') continue; // 排除活饵和邪�?

      const scoredIng = new ScoredIngredient(ing);
      let score = 0;

      // 能补充缺失味型的得分�?
      if (missing.fishy > 30 && ing.flavorProfile.fishy > 50) {
        score += ing.flavorProfile.fishy * 0.3;
      }
      if (missing.fragrant > 30 && ing.flavorProfile.fragrant > 50) {
        score += ing.flavorProfile.fragrant * 0.25;
      }
      if (missing.sweet > 30 && ing.flavorProfile.sweet > 50) {
        score += ing.flavorProfile.sweet * 0.2;
      }
      if (missing.sour > 30 && ing.flavorProfile.sour > 40) {
        score += ing.flavorProfile.sour * 0.15;
      }
      if (missing.stinky > 30 && ing.flavorProfile.stinky > 40) {
        score += ing.flavorProfile.stinky * 0.1;
      }

      scoredIng.score = score;
      complementary.push(scoredIng);
    }

    complementary.sort((a: ScoredIngredient, b: ScoredIngredient): number => b.score - a.score);

    const result: Ingredient[] = [];
    const maxCount = Math.min(count, complementary.length);
    for (let i = 0; i < maxCount; i++) {
      if (complementary[i].score > 10) { // 只返回有意义的补�?
        result.push(complementary[i].ingredient);
      }
    }
    return result;
  }

  /**
   * 获取原料总数
   */
  getIngredientCount(): number {
    this.initialize();
    return this.ingredients.length;
  }

  /**
   * 获取所有原�?
   */
  getAllIngredients(): Ingredient[] {
    this.initialize();
    return this.ingredients;
  }

  /**
   * 设置是否使用偏好加成
   */
  setUsePreference(use: boolean): void {
    this.usePreference = use;
  }

  /**
   * 获取是否使用偏好加成
   */
  getUsePreference(): boolean {
    return this.usePreference;
  }
}

// 导出单例获取函数
export function getIngredientPool(): IngredientPool {
  return IngredientPool.getInstance();
}
