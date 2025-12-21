/**
 * 饵知道 - 用户自定义数据服务
 * 管理用户自定义的原料、鱼种、配方数据
 */
import { storageService } from './StorageService';

// 用户自定义原料
export interface CustomIngredient {
  id: string;
  name: string;
  category: string;
  description: string;
  targetFish: string[];
  usage: string;
  createdAt: number;
}

// 用户自定义鱼种
export interface CustomFish {
  id: string;
  name: string;
  nameEn: string;
  waterTypes: string[];
  feedingType: string;
  waterLayer: string;
  activityTime: string;
  preferredTemp: string;
  favoriteFood: string[];
  description: string;
  createdAt: number;
}

// 用户自定义配方原料项
export interface CustomRecipeIngredient {
  ingredientId: string;
  name: string;
  ratio: number;
}

// 用户自定义配方
export interface CustomRecipe {
  id: string;
  name: string;
  targetFish: string[];
  waterType: string;
  season: string;
  ingredients: CustomRecipeIngredient[];
  steps: string[];
  tips: string;
  createdAt: number;
}

// 存储键
const STORAGE_KEYS = {
  CUSTOM_INGREDIENTS: 'user_custom_ingredients',
  CUSTOM_FISH: 'user_custom_fish',
  CUSTOM_RECIPES: 'user_custom_recipes'
};

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
      STORAGE_KEYS.CUSTOM_INGREDIENTS, []
    );
    this.customFish = await storageService.load<CustomFish[]>(
      STORAGE_KEYS.CUSTOM_FISH, []
    );
    this.customRecipes = await storageService.load<CustomRecipe[]>(
      STORAGE_KEYS.CUSTOM_RECIPES, []
    );

    this.isLoaded = true;
    console.info('[UserDataService] loaded:', {
      ingredients: this.customIngredients.length,
      fish: this.customFish.length,
      recipes: this.customRecipes.length
    });
  }

  // ==================== 原料管理 ====================

  // 获取所有自定义原料
  getCustomIngredients(): CustomIngredient[] {
    return [...this.customIngredients];
  }

  // 添加自定义原料
  async addIngredient(data: Omit<CustomIngredient, 'id' | 'createdAt'>): Promise<CustomIngredient> {
    const ingredient: CustomIngredient = {
      ...data,
      id: `user_ing_${Date.now()}`,
      createdAt: Date.now()
    };

    this.customIngredients.push(ingredient);
    await this.saveIngredients();
    return ingredient;
  }

  // 删除自定义原料
  async deleteIngredient(id: string): Promise<boolean> {
    const index = this.customIngredients.findIndex((i: CustomIngredient) => i.id === id);
    if (index === -1) return false;

    this.customIngredients.splice(index, 1);
    await this.saveIngredients();
    return true;
  }

  // 更新自定义原料
  async updateIngredient(id: string, data: Partial<CustomIngredient>): Promise<boolean> {
    const index = this.customIngredients.findIndex((i: CustomIngredient) => i.id === id);
    if (index === -1) return false;

    this.customIngredients[index] = { ...this.customIngredients[index], ...data };
    await this.saveIngredients();
    return true;
  }

  private async saveIngredients(): Promise<void> {
    await storageService.save(STORAGE_KEYS.CUSTOM_INGREDIENTS, this.customIngredients);
  }

  // ==================== 鱼种管理 ====================

  // 获取所有自定义鱼种
  getCustomFish(): CustomFish[] {
    return [...this.customFish];
  }

  // 添加自定义鱼种
  async addFish(data: Omit<CustomFish, 'id' | 'createdAt'>): Promise<CustomFish> {
    const fish: CustomFish = {
      ...data,
      id: `user_fish_${Date.now()}`,
      createdAt: Date.now()
    };

    this.customFish.push(fish);
    await this.saveFish();
    return fish;
  }

  // 删除自定义鱼种
  async deleteFish(id: string): Promise<boolean> {
    const index = this.customFish.findIndex((f: CustomFish) => f.id === id);
    if (index === -1) return false;

    this.customFish.splice(index, 1);
    await this.saveFish();
    return true;
  }

  // 更新自定义鱼种
  async updateFish(id: string, data: Partial<CustomFish>): Promise<boolean> {
    const index = this.customFish.findIndex((f: CustomFish) => f.id === id);
    if (index === -1) return false;

    this.customFish[index] = { ...this.customFish[index], ...data };
    await this.saveFish();
    return true;
  }

  private async saveFish(): Promise<void> {
    await storageService.save(STORAGE_KEYS.CUSTOM_FISH, this.customFish);
  }

  // ==================== 配方管理 ====================

  // 获取所有自定义配方
  getCustomRecipes(): CustomRecipe[] {
    return [...this.customRecipes];
  }

  // 添加自定义配方
  async addRecipe(data: Omit<CustomRecipe, 'id' | 'createdAt'>): Promise<CustomRecipe> {
    const recipe: CustomRecipe = {
      ...data,
      id: `user_recipe_${Date.now()}`,
      createdAt: Date.now()
    };

    this.customRecipes.push(recipe);
    await this.saveRecipes();
    return recipe;
  }

  // 删除自定义配方
  async deleteRecipe(id: string): Promise<boolean> {
    const index = this.customRecipes.findIndex((r: CustomRecipe) => r.id === id);
    if (index === -1) return false;

    this.customRecipes.splice(index, 1);
    await this.saveRecipes();
    return true;
  }

  // 更新自定义配方
  async updateRecipe(id: string, data: Partial<CustomRecipe>): Promise<boolean> {
    const index = this.customRecipes.findIndex((r: CustomRecipe) => r.id === id);
    if (index === -1) return false;

    this.customRecipes[index] = { ...this.customRecipes[index], ...data };
    await this.saveRecipes();
    return true;
  }

  private async saveRecipes(): Promise<void> {
    await storageService.save(STORAGE_KEYS.CUSTOM_RECIPES, this.customRecipes);
  }

  // ==================== 统计信息 ====================

  getStats(): { ingredients: number; fish: number; recipes: number } {
    return {
      ingredients: this.customIngredients.length,
      fish: this.customFish.length,
      recipes: this.customRecipes.length
    };
  }
}

export const userDataService = UserDataServiceClass.getInstance();
