/**
 * 偏好学习�?
 * 学习用户偏好，优化推荐结�?
 */
import { preferences } from '@kit.ArkData';
import { GeneratedRecipe, RecipeIngredient } from '../../common/types/RecipeTypes';

// 用户偏好数据
export class UserPreference {
  // 原料使用频率 (ingredientId -> count)
  ingredientUsage: Map<string, number> = new Map();

  // 味型偏好 (flavorType -> preferenceScore)
  flavorPreference: Map<string, number> = new Map();

  // 保存的配方ID列表
  savedRecipeIds: string[] = [];

  // 配方反馈历史
  feedbackHistory: RecipeFeedback[] = [];

  // 常用原料列表 (手动设置)
  favoriteIngredients: string[] = [];

  // 统计数据
  totalRecipesGenerated: number = 0;
  totalRecipesSaved: number = 0;

  constructor() {}
}

// 配方反馈
export class RecipeFeedback {
  recipeId: string = '';
  rating: 'good' | 'normal' | 'bad' = 'normal';
  note: string = '';
  createTime: number = 0;

  constructor() {}

  static create(recipeId: string, rating: 'good' | 'normal' | 'bad', note: string): RecipeFeedback {
    const f = new RecipeFeedback();
    f.recipeId = recipeId;
    f.rating = rating;
    f.note = note;
    f.createTime = Date.now();
    return f;
  }
}

// 反馈序列化类 (用于JSON存储)
export class FeedbackSerializable {
  recipeId: string = '';
  rating: string = 'normal';
  note: string = '';
  createTime: number = 0;

  constructor() {}

  static create(recipeId: string, rating: string, note: string, createTime: number): FeedbackSerializable {
    const f = new FeedbackSerializable();
    f.recipeId = recipeId;
    f.rating = rating;
    f.note = note;
    f.createTime = createTime;
    return f;
  }
}

// 原料使用条目 (用于排序)
export class IngredientUsageEntry {
  id: string = '';
  count: number = 0;

  constructor() {}

  static create(id: string, count: number): IngredientUsageEntry {
    const e = new IngredientUsageEntry();
    e.id = id;
    e.count = count;
    return e;
  }
}

// 味型分数条目 (用于排序)
export class FlavorScoreEntry {
  flavor: string = '';
  score: number = 0;

  constructor() {}

  static create(flavor: string, score: number): FlavorScoreEntry {
    const e = new FlavorScoreEntry();
    e.flavor = flavor;
    e.score = score;
    return e;
  }
}

// 偏好统计数据
export class PreferenceStatistics {
  generated: number = 0;
  saved: number = 0;
  feedbackCount: number = 0;

  constructor() {}

  static create(generated: number, saved: number, feedbackCount: number): PreferenceStatistics {
    const s = new PreferenceStatistics();
    s.generated = generated;
    s.saved = saved;
    s.feedbackCount = feedbackCount;
    return s;
  }
}

// 偏好学习�?
export class PreferenceLearner {
  private static instance: PreferenceLearner | null = null;
  private preference: UserPreference = new UserPreference();
  private loaded: boolean = false;
  private store: preferences.Preferences | null = null;
  private readonly STORE_NAME = 'user_preference_store';

  private constructor() {}

  static getInstance(): PreferenceLearner {
    if (PreferenceLearner.instance === null) {
      PreferenceLearner.instance = new PreferenceLearner();
    }
    return PreferenceLearner.instance;
  }

  /**
   * 加载偏好数据
   */
  async load(context: Context): Promise<void> {
    if (this.loaded) return;

    try {
      this.store = await preferences.getPreferences(context, this.STORE_NAME);

      // 加载原料使用频率
      const usageJson = await this.store.get('ingredientUsage', '{}') as string;
      const usageObj = JSON.parse(usageJson) as Record<string, number>;
      this.preference.ingredientUsage = new Map();
      const usageKeys = Object.keys(usageObj);
      for (let i = 0; i < usageKeys.length; i++) {
        this.preference.ingredientUsage.set(usageKeys[i], usageObj[usageKeys[i]]);
      }

      // 加载味型偏好
      const flavorJson = await this.store.get('flavorPreference', '{}') as string;
      const flavorObj = JSON.parse(flavorJson) as Record<string, number>;
      this.preference.flavorPreference = new Map();
      const flavorKeys = Object.keys(flavorObj);
      for (let i = 0; i < flavorKeys.length; i++) {
        this.preference.flavorPreference.set(flavorKeys[i], flavorObj[flavorKeys[i]]);
      }

      // 加载保存的配方ID
      const savedJson = await this.store.get('savedRecipeIds', '[]') as string;
      this.preference.savedRecipeIds = JSON.parse(savedJson) as string[];

      // 加载常用原料
      const favJson = await this.store.get('favoriteIngredients', '[]') as string;
      this.preference.favoriteIngredients = JSON.parse(favJson) as string[];

      // 加载统计数据
      this.preference.totalRecipesGenerated = await this.store.get('totalRecipesGenerated', 0) as number;
      this.preference.totalRecipesSaved = await this.store.get('totalRecipesSaved', 0) as number;

      // 加载反馈历史
      const feedbackJson = await this.store.get('feedbackHistory', '[]') as string;
      const feedbackArr = JSON.parse(feedbackJson) as Array<Record<string, Object>>;
      this.preference.feedbackHistory = [];
      for (let i = 0; i < feedbackArr.length; i++) {
        const fb = new RecipeFeedback();
        fb.recipeId = feedbackArr[i].recipeId as string || '';
        fb.rating = feedbackArr[i].rating as 'good' | 'normal' | 'bad' || 'normal';
        fb.note = feedbackArr[i].note as string || '';
        fb.createTime = feedbackArr[i].createTime as number || 0;
        this.preference.feedbackHistory.push(fb);
      }

      this.loaded = true;
    } catch (err) {
      console.error('Load preference failed:', err);
      this.loaded = true;
    }
  }

  /**
   * 保存偏好数据
   */
  private async save(): Promise<void> {
    if (this.store === null) return;

    try {
      // 保存原料使用频率
      const usageObj: Record<string, number> = {};
      this.preference.ingredientUsage.forEach((value, key) => {
        usageObj[key] = value;
      });
      await this.store.put('ingredientUsage', JSON.stringify(usageObj));

      // 保存味型偏好
      const flavorObj: Record<string, number> = {};
      this.preference.flavorPreference.forEach((value, key) => {
        flavorObj[key] = value;
      });
      await this.store.put('flavorPreference', JSON.stringify(flavorObj));

      // 保存其他数据
      await this.store.put('savedRecipeIds', JSON.stringify(this.preference.savedRecipeIds));
      await this.store.put('favoriteIngredients', JSON.stringify(this.preference.favoriteIngredients));
      await this.store.put('totalRecipesGenerated', this.preference.totalRecipesGenerated);
      await this.store.put('totalRecipesSaved', this.preference.totalRecipesSaved);

      // 保存反馈历史 (只保留最�?0�?
      const recentFeedback = this.preference.feedbackHistory.slice(-50);
      const feedbackArr: Array<FeedbackSerializable> = [];
      for (let i = 0; i < recentFeedback.length; i++) {
        const fb = recentFeedback[i];
        feedbackArr.push(FeedbackSerializable.create(fb.recipeId, fb.rating, fb.note, fb.createTime));
      }
      await this.store.put('feedbackHistory', JSON.stringify(feedbackArr));

      await this.store.flush();
    } catch (err) {
      console.error('Save preference failed:', err);
    }
  }


  /**
   * 记录配方生成
   */
  recordGenerate(recipe: GeneratedRecipe): void {
    this.preference.totalRecipesGenerated++;

    // 记录原料使用
    for (let i = 0; i < recipe.ingredients.length; i++) {
      const ing = recipe.ingredients[i];
      const count = this.preference.ingredientUsage.get(ing.id) || 0;
      this.preference.ingredientUsage.set(ing.id, count + 1);
    }

    // 记录味型偏好
    const primary = recipe.flavorProfile.primary;
    const secondary = recipe.flavorProfile.secondary;
    if (primary) {
      const pScore = this.preference.flavorPreference.get(primary) || 0;
      this.preference.flavorPreference.set(primary, pScore + 1);
    }
    if (secondary) {
      const sScore = this.preference.flavorPreference.get(secondary) || 0;
      this.preference.flavorPreference.set(secondary, sScore + 0.5);
    }

    this.save();
  }

  /**
   * 记录配方保存
   */
  recordSave(recipe: GeneratedRecipe): void {
    this.preference.totalRecipesSaved++;

    // 添加到保存列�?
    if (this.preference.savedRecipeIds.indexOf(recipe.id) < 0) {
      this.preference.savedRecipeIds.push(recipe.id);
      // 限制保存列表大小
      if (this.preference.savedRecipeIds.length > 100) {
        this.preference.savedRecipeIds.shift();
      }
    }

    // 保存的配方，原料使用权重更高
    for (let i = 0; i < recipe.ingredients.length; i++) {
      const ing = recipe.ingredients[i];
      const count = this.preference.ingredientUsage.get(ing.id) || 0;
      this.preference.ingredientUsage.set(ing.id, count + 2); // 保存的配方权�?2
    }

    // 味型偏好权重更高
    const primary = recipe.flavorProfile.primary;
    const secondary = recipe.flavorProfile.secondary;
    if (primary) {
      const pScore = this.preference.flavorPreference.get(primary) || 0;
      this.preference.flavorPreference.set(primary, pScore + 3);
    }
    if (secondary) {
      const sScore = this.preference.flavorPreference.get(secondary) || 0;
      this.preference.flavorPreference.set(secondary, sScore + 1.5);
    }

    this.save();
  }

  /**
   * 记录原料使用
   */
  recordIngredientUse(ingredientId: string): void {
    const count = this.preference.ingredientUsage.get(ingredientId) || 0;
    this.preference.ingredientUsage.set(ingredientId, count + 1);
    this.save();
  }

  /**
   * 记录配方反馈
   */
  recordFeedback(recipeId: string, rating: 'good' | 'normal' | 'bad', note: string): void {
    const feedback = RecipeFeedback.create(recipeId, rating, note);
    this.preference.feedbackHistory.push(feedback);

    // 根据反馈调整偏好
    // 好评增加权重，差评减少权�?
    // 这里简化处理，实际可以更复�?

    this.save();
  }

  /**
   * 获取原料偏好加成
   * 返回 0-20 的加成�?
   */
  getPreferenceBoost(ingredientId: string): number {
    const count = this.preference.ingredientUsage.get(ingredientId) || 0;

    // 常用原料额外加成
    let isFavorite = false;
    for (let i = 0; i < this.preference.favoriteIngredients.length; i++) {
      if (this.preference.favoriteIngredients[i] === ingredientId) {
        isFavorite = true;
        break;
      }
    }

    let boost = 0;

    // 使用频率加成 (最�?0�?
    if (count > 20) boost += 10;
    else if (count > 10) boost += 7;
    else if (count > 5) boost += 5;
    else if (count > 2) boost += 3;
    else if (count > 0) boost += 1;

    // 常用原料加成 (额外10�?
    if (isFavorite) boost += 10;

    return Math.min(20, boost);
  }

  /**
   * 获取味型偏好加成
   */
  getFlavorBoost(flavorType: string): number {
    const score = this.preference.flavorPreference.get(flavorType) || 0;

    if (score > 30) return 15;
    if (score > 20) return 10;
    if (score > 10) return 7;
    if (score > 5) return 5;
    if (score > 0) return 2;
    return 0;
  }

  /**
   * 获取常用原料列表
   */
  getFrequentIngredients(limit: number = 10): string[] {
    const entries: Array<IngredientUsageEntry> = [];
    this.preference.ingredientUsage.forEach((count, id) => {
      entries.push(IngredientUsageEntry.create(id, count));
    });

    // 按使用次数排�?
    entries.sort((a, b) => b.count - a.count);

    const result: string[] = [];
    const maxCount = Math.min(limit, entries.length);
    for (let i = 0; i < maxCount; i++) {
      result.push(entries[i].id);
    }
    return result;
  }

  /**
   * 获取偏好的味�?
   */
  getPreferredFlavors(): string[] {
    const entries: Array<FlavorScoreEntry> = [];
    this.preference.flavorPreference.forEach((score, flavor) => {
      entries.push(FlavorScoreEntry.create(flavor, score));
    });

    entries.sort((a, b) => b.score - a.score);

    const result: string[] = [];
    const maxCount = Math.min(3, entries.length);
    for (let i = 0; i < maxCount; i++) {
      result.push(entries[i].flavor);
    }
    return result;
  }

  /**
   * 设置常用原料
   */
  setFavoriteIngredients(ingredientIds: string[]): void {
    this.preference.favoriteIngredients = ingredientIds.slice(0, 20); // 最�?0�?
    this.save();
  }

  /**
   * 添加常用原料
   */
  addFavoriteIngredient(ingredientId: string): void {
    if (this.preference.favoriteIngredients.indexOf(ingredientId) < 0) {
      this.preference.favoriteIngredients.push(ingredientId);
      if (this.preference.favoriteIngredients.length > 20) {
        this.preference.favoriteIngredients.shift();
      }
      this.save();
    }
  }

  /**
   * 移除常用原料
   */
  removeFavoriteIngredient(ingredientId: string): void {
    const index = this.preference.favoriteIngredients.indexOf(ingredientId);
    if (index >= 0) {
      this.preference.favoriteIngredients.splice(index, 1);
      this.save();
    }
  }

  /**
   * 获取常用原料列表
   */
  getFavoriteIngredients(): string[] {
    return this.preference.favoriteIngredients.slice();
  }

  /**
   * 重置偏好数据
   */
  async resetPreferences(): Promise<void> {
    this.preference = new UserPreference();
    await this.save();
  }

  /**
   * 获取统计数据
   */
  getStatistics(): PreferenceStatistics {
    return PreferenceStatistics.create(
      this.preference.totalRecipesGenerated,
      this.preference.totalRecipesSaved,
      this.preference.feedbackHistory.length
    );
  }

  /**
   * 检查是否已加载
   */
  isLoaded(): boolean {
    return this.loaded;
  }

  /**
   * 获取偏好数据（用于调试）
   */
  getPreference(): UserPreference {
    return this.preference;
  }
}

// 导出单例获取函数
export function getPreferenceLearner(): PreferenceLearner {
  return PreferenceLearner.getInstance();
}
