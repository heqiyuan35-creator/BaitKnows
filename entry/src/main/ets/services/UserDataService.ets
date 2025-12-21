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
  tips: string
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
  return recipe;
}

class UserDataServiceClass {
  private static instance: UserDataServiceClass;
  private customIngredients: CustomIngredient[] = [];
  private customFish: CustomFish[] = [];
  private customRecipes: CustomRecipe[] = [];
  private isLoaded: boolean = false;

  private constructor() {}

  static getInstance(): UserDataServiceClass {
    if (!UserDataServiceClass.instance) {
      UserDataServiceClass.instance = new UserDataServiceClass();
    }
    return UserDataServiceClass.instance;
  }

  // 加载所有用户数据
  async load(): Promise<void> {
    if (this.isLoaded) return;

    this.customIngredients = await storageService.load<CustomIngredient[]>(
      STORAGE_KEY_INGREDIENTS, []
    );
    this.customFish = await storageService.load<CustomFish[]>(
      STORAGE_KEY_FISH, []
    );
    this.customRecipes = await storageService.load<CustomRecipe[]>(
      STORAGE_KEY_RECIPES, []
    );

    this.isLoaded = true;
    console.info('[UserDataService] loaded');
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
    waterTypes: string[],
    feedingType: string,
    waterLayer: string,
    activityTime: string,
    preferredTemp: string,
    favoriteFood: string[],
    description: string
  ): Promise<CustomFish> {
    const fish = createFish(name, nameEn, waterTypes, feedingType, waterLayer, activityTime, preferredTemp, favoriteFood, description);
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
    tips: string
  ): Promise<CustomRecipe> {
    const recipe = createRecipe(name, targetFish, waterType, season, ingredients, steps, tips);
    this.customRecipes.push(recipe);
    await this.saveRecipes();
    return recipe;
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

  // ==================== 统计信息 ====================

  getStats(): UserDataStats {
    const stats = new UserDataStats();
    stats.ingredients = this.customIngredients.length;
    stats.fish = this.customFish.length;
    stats.recipes = this.customRecipes.length;
    return stats;
  }
}

export const userDataService = UserDataServiceClass.getInstance();
