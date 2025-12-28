/**
 * 饵知�?- 配方生成历史服务
 */
import { GeneratedRecipe } from '../common/types/RecipeTypes';
import { storageService } from './StorageService';
import { AppConstants } from '../common/constants/AppConstants';

class GeneratorHistoryServiceClass {
  private _history: GeneratedRecipe[] = [];
  private _isLoaded: boolean = false;
  private readonly MAX_HISTORY = 50;

  get history(): GeneratedRecipe[] {
    return this._history;
  }

  get isLoaded(): boolean {
    return this._isLoaded;
  }

  /**
   * 加载历史记录
   */
  async load(): Promise<GeneratedRecipe[]> {
    if (this._isLoaded) {
      return this._history;
    }

    const saved = await storageService.load<GeneratedRecipe[]>(
      AppConstants.STORAGE_GENERATOR_HISTORY,
      []
    );

    this._history = saved || [];
    // 按时间倒序
    this._history.sort((a, b) => b.createTime - a.createTime);
    this._isLoaded = true;

    return this._history;
  }

  /**
   * 保存历史记录
   */
  private async save(): Promise<void> {
    await storageService.save(AppConstants.STORAGE_GENERATOR_HISTORY, this._history);
  }

  /**
   * 添加生成记录
   */
  async addHistory(recipe: GeneratedRecipe): Promise<void> {
    // 检查是否已存在
    const exists = this._history.some(h => h.id === recipe.id);
    if (exists) {
      return;
    }

    this._history.unshift(recipe);

    // 限制最大数�?
    if (this._history.length > this.MAX_HISTORY) {
      this._history = this._history.slice(0, this.MAX_HISTORY);
    }

    await this.save();
  }

  /**
   * 删除历史记录
   */
  async deleteHistory(recipeId: string): Promise<boolean> {
    const index = this._history.findIndex(h => h.id === recipeId);
    if (index < 0) {
      return false;
    }

    this._history.splice(index, 1);
    await this.save();
    return true;
  }

  /**
   * 清空所有历�?
   */
  async clearAll(): Promise<void> {
    this._history = [];
    await this.save();
  }

  /**
   * 根据ID获取历史记录
   */
  getHistoryById(recipeId: string): GeneratedRecipe | null {
    return this._history.find(h => h.id === recipeId) || null;
  }

  /**
   * 获取最近N条记�?
   */
  getRecentHistory(limit: number = 10): GeneratedRecipe[] {
    return this._history.slice(0, limit);
  }
}

export const generatorHistoryService = new GeneratorHistoryServiceClass();
