/**
 * 饵知道 - 用户自定义数据服务
 * 管理用户自定义的原料、鱼种、配方数据
 */
import { storageService } from './StorageService';

// 用户自定义原料
export class CustomIngredient {
  id: string = '';
  name: string = '';
  category: string = '';
  description: string = '';
  targetFish: string[] = [];
  usage: string = '';
  createdAt: number = 0;
}

// 用户自定义鱼种
export class CustomFish {
  id: string = '';
  name: string = '';
  nameEn: string = '';
  icon: string = '';  // 鱼种图片路径
  waterTypes: string[] = [];
  feedingType: string = '';
  waterLayer: string = '';
  activityTime: string = '';
  preferredTemp: string = '';
  favoriteFood: string[] = [];
  description: string = '';
  createdAt: number = 0;
}

// 用户自定义配方原料项
export class CustomRecipeIngredient {
  ingredientId: string = '';
  name: string = '';
  ratio: number = 1;
  weight: number = 0;
  purpose: string = '';
  category: string = '';
}

// 配方状态特性
export class RecipeStateProfile {
  atomization: number = 3;
  viscosity: number = 3;
  hookHolding: number = 3;
  weight: number = 3;
}

// 配方味型特性
export class RecipeFlavorProfile {
  primary: string = '';
  secondary: string = '';
  intensity: number = 3;
  suitableTemp: string = '15-25°C';
}

// 用户自定义配方
export class CustomRecipe {
  id: string = '';
  name: string = '';
  targetFish: string[] = [];
  waterType: string = '';
  season: string = '';
  ingredients: CustomRecipeIngredient[] = [];
  steps: string[] = [];
  tips: string = '';
  createdAt: number = 0;
  // 难度：easy, medium, hard
  difficulty: string = 'medium';
  // 准备时间
  prepTime: string = '15分钟';
  // 扩展字段：状态特性
  stateProfile: RecipeStateProfile = new RecipeStateProfile();
  // 扩展字段：味型特性
  flavorProfile: RecipeFlavorProfile = new RecipeFlavorProfile();
  // 扩展字段：总重量
  totalWeight: number = 500;
}

// 统计信息接口
export class UserDataStats {
  ingredients: number = 0;
  fish: number = 0;
  recipes: number = 0;
}

// 存储键
const STORAGE_KEY_INGREDIENTS = 'user_custom_ingredients';
const STORAGE_KEY_FISH = 'user_custom_fish';
const STORAGE_KEY_RECIPES = 'user_custom_recipes';
const STORAGE_KEY_FAVORITES = 'user_favorite_recipes';
const STORAGE_KEY_PRECISE_PREFERENCES = 'user_precise_preferences';
const STORAGE_KEY_PRECISE_HISTORY = 'user_precise_history';
const STORAGE_KEY_FEEDBACK_HISTORY = 'user_feedback_history';

// 精确匹配用户偏好
export class PreciseMatchPreferences {
  waterDepth: string = 'medium';
  waterQuality: string = 'clear';
  lightCondition: string = 'bright';
  windCondition: string = 'none';
  baitState: string = 'fast_dissolve';
  flavorIntensity: string = 'medium';
  targetFishSize: string = 'medium';
  lastUpdated: number = 0;
}

// 精确匹配历史记录
export class PreciseMatchHistoryItem {
  id: string = '';
  recipeName: string = '';
  targetFish: string = '';
  matchScore: number = 0;
  createdAt: number = 0;
  inputParams: string = '';  // JSON字符串存储输入参数
}

// 用户反馈记录
export class FeedbackHistoryItem {
  id: string = '';
  recipeId: string = '';
  feedbackTypes: string[] = [];
  otherReason: string = '';
  createdAt: number = 0;
}

// 创建原料的辅助函数
function createIngredient(
  name: string,
  category: string,
  description: string,
  targetFish: string[],
  usage: string
): CustomIngredient {
  const ing = new CustomIngredient();
  ing.id = `user_ing_${Date.now()}`;
  ing.name = name;
  ing.category = category;
  ing.description = description;
  ing.targetFish = targetFish;
  ing.usage = usage;
  ing.createdAt = Date.now();
  return ing;
}

// 创建鱼种的辅助函数
function createFish(
  name: string,
  nameEn: string,
  icon: string,
  waterTypes: string[],
  feedingType: string,
  waterLayer: string,
  activityTime: string,
  preferredTemp: string,
  favoriteFood: string[],
  description: string
): CustomFish {
  const fish = new CustomFish();
  fish.id = `user_fish_${Date.now()}`;
  fish.name = name;
  fish.nameEn = nameEn;
  fish.icon = icon;
  fish.waterTypes = waterTypes;
  fish.feedingType = feedingType;
  fish.waterLayer = waterLayer;
  fish.activityTime = activityTime;
  fish.preferredTemp = preferredTemp;
  fish.favoriteFood = favoriteFood;
  fish.description = description;
  fish.createdAt = Date.now();
  return fish;
}

// 创建配方的辅助函数
function createRecipe(
  name: string,
  targetFish: string[],
  waterType: string,
  season: string,
  ingredients: CustomRecipeIngredient[],
  steps: string[],
  tips: string,
  stateProfile: RecipeStateProfile | null,
  flavorProfile: RecipeFlavorProfile | null,
  totalWeight: number,
  difficulty: string,
  prepTime: string
): CustomRecipe {
  const recipe = new CustomRecipe();
  recipe.id = `user_recipe_${Date.now()}`;
  recipe.name = name;
  recipe.targetFish = targetFish;
  recipe.waterType = waterType;
  recipe.season = season;
  recipe.ingredients = ingredients;
  recipe.steps = steps;
  recipe.tips = tips;
  recipe.createdAt = Date.now();
  recipe.totalWeight = totalWeight;
  recipe.difficulty = difficulty;
  recipe.prepTime = prepTime;

  if (stateProfile !== null) {
    recipe.stateProfile = stateProfile;
  }
  if (flavorProfile !== null) {
    recipe.flavorProfile = flavorProfile;
  }

  return recipe;
}

class UserDataServiceClass {
  private static instance: UserDataServiceClass;
  private customIngredients: CustomIngredient[] = [];
  private customFish: CustomFish[] = [];
  private customRecipes: CustomRecipe[] = [];
  private favoriteRecipes: string[] = [];  // 收藏的配方ID列表
  private precisePreferences: PreciseMatchPreferences = new PreciseMatchPreferences();
  private preciseHistory: PreciseMatchHistoryItem[] = [];
  private feedbackHistory: FeedbackHistoryItem[] = [];
  private isLoaded: boolean = false;

  private constructor() {}

  static getInstance(): UserDataServiceClass {
    if (!UserDataServiceClass.instance) {
      UserDataServiceClass.instance = new UserDataServiceClass();
    }
    return UserDataServiceClass.instance;
  }

  // 加载所有用户数据
  async load(forceReload: boolean = false): Promise<void> {
    if (this.isLoaded && !forceReload) return;

    this.customIngredients = await storageService.load<CustomIngredient[]>(
      STORAGE_KEY_INGREDIENTS, []
    );
    this.customFish = await storageService.load<CustomFish[]>(
      STORAGE_KEY_FISH, []
    );
    this.customRecipes = await storageService.load<CustomRecipe[]>(
      STORAGE_KEY_RECIPES, []
    );

    this.favoriteRecipes = await storageService.load<string[]>(
      STORAGE_KEY_FAVORITES, []
    );

    // 加载精确匹配相关数据
    this.precisePreferences = await storageService.load<PreciseMatchPreferences>(
      STORAGE_KEY_PRECISE_PREFERENCES, new PreciseMatchPreferences()
    );
    this.preciseHistory = await storageService.load<PreciseMatchHistoryItem[]>(
      STORAGE_KEY_PRECISE_HISTORY, []
    );
    this.feedbackHistory = await storageService.load<FeedbackHistoryItem[]>(
      STORAGE_KEY_FEEDBACK_HISTORY, []
    );

    this.isLoaded = true;
    console.info('[UserDataService] loaded, recipes count:', this.customRecipes.length);
  }

  // ==================== 原料管理 ====================

  getCustomIngredients(): CustomIngredient[] {
    return this.customIngredients.slice();
  }

  async addIngredient(
    name: string,
    category: string,
    description: string,
    targetFish: string[],
    usage: string
  ): Promise<CustomIngredient> {
    const ingredient = createIngredient(name, category, description, targetFish, usage);
    this.customIngredients.push(ingredient);
    await this.saveIngredients();
    return ingredient;
  }

  async deleteIngredient(id: string): Promise<boolean> {
    const index = this.customIngredients.findIndex((i: CustomIngredient) => i.id === id);
    if (index === -1) return false;
    this.customIngredients.splice(index, 1);
    await this.saveIngredients();
    return true;
  }

  private async saveIngredients(): Promise<void> {
    await storageService.save(STORAGE_KEY_INGREDIENTS, this.customIngredients);
  }

  // ==================== 鱼种管理 ====================

  getCustomFish(): CustomFish[] {
    return this.customFish.slice();
  }

  async addFish(
    name: string,
    nameEn: string,
    icon: string,
    waterTypes: string[],
    feedingType: string,
    waterLayer: string,
    activityTime: string,
    preferredTemp: string,
    favoriteFood: string[],
    description: string
  ): Promise<CustomFish> {
    const fish = createFish(name, nameEn, icon, waterTypes, feedingType, waterLayer, activityTime, preferredTemp, favoriteFood, description);
    this.customFish.push(fish);
    await this.saveFish();
    return fish;
  }

  async deleteFish(id: string): Promise<boolean> {
    const index = this.customFish.findIndex((f: CustomFish) => f.id === id);
    if (index === -1) return false;
    this.customFish.splice(index, 1);
    await this.saveFish();
    return true;
  }

  private async saveFish(): Promise<void> {
    await storageService.save(STORAGE_KEY_FISH, this.customFish);
  }

  // ==================== 配方管理 ====================

  getCustomRecipes(): CustomRecipe[] {
    return this.customRecipes.slice();
  }

  async addRecipe(
    name: string,
    targetFish: string[],
    waterType: string,
    season: string,
    ingredients: CustomRecipeIngredient[],
    steps: string[],
    tips: string,
    stateProfile: RecipeStateProfile | null = null,
    flavorProfile: RecipeFlavorProfile | null = null,
    totalWeight: number = 500,
    difficulty: string = 'medium',
    prepTime: string = '15分钟'
  ): Promise<CustomRecipe> {
    const recipe = createRecipe(name, targetFish, waterType, season, ingredients, steps, tips, stateProfile, flavorProfile, totalWeight, difficulty, prepTime);
    this.customRecipes.push(recipe);
    await this.saveRecipes();
    return recipe;
  }

  // 检查配方名称是否已存在
  isRecipeNameExists(name: string): boolean {
    for (let i = 0; i < this.customRecipes.length; i++) {
      if (this.customRecipes[i].name === name) {
        return true;
      }
    }
    return false;
  }

  async deleteRecipe(id: string): Promise<boolean> {
    const index = this.customRecipes.findIndex((r: CustomRecipe) => r.id === id);
    if (index === -1) return false;
    this.customRecipes.splice(index, 1);
    await this.saveRecipes();
    return true;
  }

  private async saveRecipes(): Promise<void> {
    await storageService.save(STORAGE_KEY_RECIPES, this.customRecipes);
  }

  // ==================== 收藏管理 ====================

  // 获取所有收藏的配方ID
  getFavoriteRecipes(): string[] {
    return this.favoriteRecipes.slice();
  }

  // 检查配方是否已收藏
  isFavorite(recipeId: string): boolean {
    return this.favoriteRecipes.includes(recipeId);
  }

  // 添加收藏
  async addFavorite(recipeId: string): Promise<boolean> {
    if (this.favoriteRecipes.includes(recipeId)) {
      return false;  // 已经收藏过了
    }
    this.favoriteRecipes.push(recipeId);
    await this.saveFavorites();
    console.info('[UserDataService] Added favorite:', recipeId);
    return true;
  }

  // 取消收藏
  async removeFavorite(recipeId: string): Promise<boolean> {
    const index = this.favoriteRecipes.indexOf(recipeId);
    if (index === -1) {
      return false;  // 没有收藏过
    }
    this.favoriteRecipes.splice(index, 1);
    await this.saveFavorites();
    console.info('[UserDataService] Removed favorite:', recipeId);
    return true;
  }

  // 切换收藏状态
  async toggleFavorite(recipeId: string): Promise<boolean> {
    if (this.isFavorite(recipeId)) {
      await this.removeFavorite(recipeId);
      return false;  // 返回新的收藏状态
    } else {
      await this.addFavorite(recipeId);
      return true;  // 返回新的收藏状态
    }
  }

  private async saveFavorites(): Promise<void> {
    await storageService.save(STORAGE_KEY_FAVORITES, this.favoriteRecipes);
  }

  // ==================== 统计信息 ====================

  getStats(): UserDataStats {
    const stats = new UserDataStats();
    stats.ingredients = this.customIngredients.length;
    stats.fish = this.customFish.length;
    stats.recipes = this.customRecipes.length;
    return stats;
  }

  // ==================== 精确匹配偏好管理 ====================

  // 获取精确匹配偏好
  getPrecisePreferences(): PreciseMatchPreferences {
    return this.precisePreferences;
  }

  // 保存精确匹配偏好
  async savePrecisePreferences(prefs: PreciseMatchPreferences): Promise<void> {
    prefs.lastUpdated = Date.now();
    this.precisePreferences = prefs;
    await storageService.save(STORAGE_KEY_PRECISE_PREFERENCES, this.precisePreferences);
    console.info('[UserDataService] Saved precise preferences');
  }

  // 更新单个偏好项
  async updatePrecisePreference(key: string, value: string): Promise<void> {
    // 根据key更新对应的偏好项
    switch (key) {
      case 'waterDepth':
        this.precisePreferences.waterDepth = value;
        break;
      case 'waterQuality':
        this.precisePreferences.waterQuality = value;
        break;
      case 'lightCondition':
        this.precisePreferences.lightCondition = value;
        break;
      case 'windCondition':
        this.precisePreferences.windCondition = value;
        break;
      case 'baitState':
        this.precisePreferences.baitState = value;
        break;
      case 'flavorIntensity':
        this.precisePreferences.flavorIntensity = value;
        break;
      case 'targetFishSize':
        this.precisePreferences.targetFishSize = value;
        break;
    }
    this.precisePreferences.lastUpdated = Date.now();
    await storageService.save(STORAGE_KEY_PRECISE_PREFERENCES, this.precisePreferences);
  }

  // ==================== 精确匹配历史管理 ====================

  // 获取精确匹配历史
  getPreciseHistory(): PreciseMatchHistoryItem[] {
    return this.preciseHistory.slice().sort((a: PreciseMatchHistoryItem, b: PreciseMatchHistoryItem) =>
      b.createdAt - a.createdAt
    );
  }

  // 添加精确匹配历史记录
  async addPreciseHistory(
    recipeName: string,
    targetFish: string,
    matchScore: number,
    inputParams: string
  ): Promise<PreciseMatchHistoryItem> {
    const item = new PreciseMatchHistoryItem();
    item.id = `precise_${Date.now()}`;
    item.recipeName = recipeName;
    item.targetFish = targetFish;
    item.matchScore = matchScore;
    item.inputParams = inputParams;
    item.createdAt = Date.now();

    this.preciseHistory.unshift(item);

    // 只保留最近50条记录
    if (this.preciseHistory.length > 50) {
      this.preciseHistory = this.preciseHistory.slice(0, 50);
    }

    await storageService.save(STORAGE_KEY_PRECISE_HISTORY, this.preciseHistory);
    console.info('[UserDataService] Added precise history:', recipeName);
    return item;
  }

  // 清空精确匹配历史
  async clearPreciseHistory(): Promise<void> {
    this.preciseHistory = [];
    await storageService.save(STORAGE_KEY_PRECISE_HISTORY, this.preciseHistory);
  }

  // ==================== 反馈历史管理 ====================

  // 获取反馈历史
  getFeedbackHistory(): FeedbackHistoryItem[] {
    return this.feedbackHistory.slice();
  }

  // 添加反馈记录
  async addFeedback(
    recipeId: string,
    feedbackTypes: string[],
    otherReason: string = ''
  ): Promise<FeedbackHistoryItem> {
    const item = new FeedbackHistoryItem();
    item.id = `feedback_${Date.now()}`;
    item.recipeId = recipeId;
    item.feedbackTypes = feedbackTypes;
    item.otherReason = otherReason;
    item.createdAt = Date.now();

    this.feedbackHistory.unshift(item);

    // 只保留最近100条反馈
    if (this.feedbackHistory.length > 100) {
      this.feedbackHistory = this.feedbackHistory.slice(0, 100);
    }

    await storageService.save(STORAGE_KEY_FEEDBACK_HISTORY, this.feedbackHistory);
    console.info('[UserDataService] Added feedback for recipe:', recipeId);
    return item;
  }

  // 获取某个配方的反馈统计
  getFeedbackStats(recipeId: string): Record<string, number> {
    const stats: Record<string, number> = {};
    for (const item of this.feedbackHistory) {
      if (item.recipeId === recipeId) {
        for (const type of item.feedbackTypes) {
          stats[type] = (stats[type] || 0) + 1;
        }
      }
    }
    return stats;
  }

  // ==================== 重置所有数据 ====================

  // 清除所有用户数据
  async clearAllData(): Promise<void> {
    // 清空内存数据
    this.customIngredients = [];
    this.customFish = [];
    this.customRecipes = [];
    this.favoriteRecipes = [];
    this.precisePreferences = new PreciseMatchPreferences();
    this.preciseHistory = [];
    this.feedbackHistory = [];
    this.isLoaded = false;  // 重置加载标志

    // 清空存储
    await storageService.remove(STORAGE_KEY_INGREDIENTS);
    await storageService.remove(STORAGE_KEY_FISH);
    await storageService.remove(STORAGE_KEY_RECIPES);
    await storageService.remove(STORAGE_KEY_FAVORITES);
    await storageService.remove(STORAGE_KEY_PRECISE_PREFERENCES);
    await storageService.remove(STORAGE_KEY_PRECISE_HISTORY);
    await storageService.remove(STORAGE_KEY_FEEDBACK_HISTORY);

    console.info('[UserDataService] All user data cleared');
  }
}

export const userDataService = UserDataServiceClass.getInstance();
