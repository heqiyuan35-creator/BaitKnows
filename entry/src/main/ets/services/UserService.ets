/**
 * 饵知�?- 用户服务
 * 管理用户信息、等级计�?
 */
import { UserProfile, UserLevel, LevelConfig, LEVEL_CONFIGS, FishingRecord } from '../common/types/UserTypes';
import { storageService } from './StorageService';
import { AppConstants } from '../common/constants/AppConstants';

class UserServiceClass {
  private _profile: UserProfile = new UserProfile();
  private _isLoaded: boolean = false;

  get profile(): UserProfile {
    return this._profile;
  }

  get isLoaded(): boolean {
    return this._isLoaded;
  }

  /**
   * 初始化加载用户数�?
   */
  async load(): Promise<UserProfile> {
    if (this._isLoaded) {
      return this._profile;
    }

    const saved = await storageService.load<UserProfile>(
      AppConstants.STORAGE_USER_PROFILE,
      new UserProfile()
    );

    if (saved && saved.id) {
      this._profile = saved;
    } else {
      this._profile = new UserProfile();
      await this.save();
    }

    this._isLoaded = true;
    return this._profile;
  }

  /**
   * 保存用户数据
   */
  async save(): Promise<void> {
    this._profile.updateTime = Date.now();
    await storageService.save(AppConstants.STORAGE_USER_PROFILE, this._profile);
  }

  /**
   * 更新昵称
   */
  async updateNickname(nickname: string): Promise<void> {
    this._profile.nickname = nickname;
    await this.save();
  }

  /**
   * 计算经验�?
   * 经验 = 渔获重量×10 + 出钓次数×20 + 钓获尾数×5 + 活跃天数×5
   */
  calculateExperience(): number {
    const exp = Math.round(
      this._profile.totalCatch * 10 +
      this._profile.totalTrips * 20 +
      this._profile.totalFish * 5 +
      this._profile.activeDays * 5
    );
    return exp;
  }

  /**
   * 根据经验值获取等级配�?
   */
  getLevelConfig(exp: number): LevelConfig {
    for (let i = LEVEL_CONFIGS.length - 1; i >= 0; i--) {
      if (exp >= LEVEL_CONFIGS[i].minExp) {
        return LEVEL_CONFIGS[i];
      }
    }
    return LEVEL_CONFIGS[0];
  }

  /**
   * 获取当前等级进度 (0-100)
   */
  getLevelProgress(): number {
    const exp = this._profile.experience;
    const config = this.getLevelConfig(exp);

    if (config.level === UserLevel.MASTER) {
      return 100;
    }

    const currentLevelExp = exp - config.minExp;
    const levelRange = config.maxExp - config.minExp;

    return Math.min(100, Math.round((currentLevelExp / levelRange) * 100));
  }

  /**
   * 更新等级信息
   */
  async updateLevel(): Promise<void> {
    this._profile.experience = this.calculateExperience();
    const config = this.getLevelConfig(this._profile.experience);
    this._profile.level = config.level;
    this._profile.levelTitle = config.title;
    await this.save();
  }

  /**
   * 添加渔获记录后更新统�?
   */
  async onRecordAdded(record: FishingRecord): Promise<void> {
    this._profile.totalCatch += record.weight;
    this._profile.totalFish += record.count;
    this._profile.totalTrips += 1;

    if (record.maxSingle > this._profile.bestRecord) {
      this._profile.bestRecord = record.maxSingle;
    }

    // 更新活跃天数（简化：每次记录+1，实际应该按日期去重�?
    this._profile.activeDays += 1;

    if (record.recipeId) {
      this._profile.recipeUseCount += 1;
    }

    await this.updateLevel();
  }

  /**
   * 删除渔获记录后更新统�?
   */
  async onRecordDeleted(record: FishingRecord): Promise<void> {
    this._profile.totalCatch = Math.max(0, this._profile.totalCatch - record.weight);
    this._profile.totalFish = Math.max(0, this._profile.totalFish - record.count);
    this._profile.totalTrips = Math.max(0, this._profile.totalTrips - 1);

    if (record.recipeId) {
      this._profile.recipeUseCount = Math.max(0, this._profile.recipeUseCount - 1);
    }

    await this.updateLevel();
  }

  /**
   * 更新收藏数量
   */
  async updateFavoriteCount(count: number): Promise<void> {
    this._profile.favoriteCount = count;
    await this.save();
  }

  /**
   * 从记录列表重新计算统计数�?
   */
  async recalculateFromRecords(records: FishingRecord[]): Promise<void> {
    this._profile.totalCatch = 0;
    this._profile.totalFish = 0;
    this._profile.totalTrips = records.length;
    this._profile.bestRecord = 0;
    this._profile.recipeUseCount = 0;

    const activeDates = new Set<string>();

    for (const record of records) {
      this._profile.totalCatch += record.weight;
      this._profile.totalFish += record.count;

      if (record.maxSingle > this._profile.bestRecord) {
        this._profile.bestRecord = record.maxSingle;
      }

      if (record.recipeId) {
        this._profile.recipeUseCount += 1;
      }

      // 按日期统计活跃天�?
      const dateKey = new Date(record.date).toDateString();
      activeDates.add(dateKey);
    }

    this._profile.activeDays = activeDates.size;
    await this.updateLevel();
  }

  /**
   * 重置用户数据
   */
  async resetProfile(): Promise<void> {
    this._profile = new UserProfile();
    this._isLoaded = false;  // 重置加载标志，允许重新加�?
    await this.save();
    console.info('[UserService] User profile reset');
  }
}

export const userService = new UserServiceClass();
