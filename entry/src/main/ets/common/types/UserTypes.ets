/**
 * 饵知�?- 用户相关类型定义
 */

// 用户等级枚举
export enum UserLevel {
  NOVICE = 1,      // 新手钓友
  BEGINNER = 2,    // 入门钓手
  SKILLED = 3,     // 熟练钓手
  EXPERT = 4,      // 钓鱼高手
  MASTER = 5       // 垂钓大师
}

// 等级配置
export class LevelConfig {
  level: UserLevel = UserLevel.NOVICE;
  title: string = '';
  minExp: number = 0;
  maxExp: number = 0;
  icon: string = '';

  constructor() {}

  static create(level: UserLevel, title: string, minExp: number, maxExp: number, icon: string): LevelConfig {
    const config = new LevelConfig();
    config.level = level;
    config.title = title;
    config.minExp = minExp;
    config.maxExp = maxExp;
    config.icon = icon;
    return config;
  }
}

// 等级配置�?
export const LEVEL_CONFIGS: LevelConfig[] = [
  LevelConfig.create(UserLevel.NOVICE, '新手钓友', 0, 100, '🎣'),
  LevelConfig.create(UserLevel.BEGINNER, '入门钓手', 100, 500, '🐟'),
  LevelConfig.create(UserLevel.SKILLED, '熟练钓手', 500, 1500, '🐠'),
  LevelConfig.create(UserLevel.EXPERT, '钓鱼高手', 1500, 5000, '🦈'),
  LevelConfig.create(UserLevel.MASTER, '垂钓大师', 5000, 999999, '👑')
];

// 用户信息
export class UserProfile {
  id: string = '';
  nickname: string = '钓鱼�?;
  avatar: string = '';
  level: UserLevel = UserLevel.NOVICE;
  levelTitle: string = '新手钓友';
  experience: number = 0;
  totalCatch: number = 0;        // 总渔获重�?(kg)
  totalTrips: number = 0;        // 总出钓次�?
  totalFish: number = 0;         // 总钓获尾�?
  bestRecord: number = 0;        // 最佳单尾记�?(kg)
  activeDays: number = 0;        // 活跃天数
  favoriteCount: number = 0;     // 收藏数量
  recipeUseCount: number = 0;    // 配方使用次数
  createTime: number = 0;
  updateTime: number = 0;

  constructor() {
    this.id = `user_${Date.now()}`;
    this.createTime = Date.now();
    this.updateTime = Date.now();
  }
}

// 渔获记录
export class FishingRecord {
  id: string = '';
  date: number = 0;              // 时间�?
  dateStr: string = '';          // 显示用日期字符串
  location: string = '';
  weather: string = '晴朗';
  fishName: string = '';
  fishIcon: string = '🐟';
  weight: number = 0;            // 总重�?kg
  count: number = 0;             // 尾数
  maxSingle: number = 0;         // 最大单�?kg
  recipeId: string = '';
  recipeName: string = '';
  notes: string = '';
  photos: string[] = [];
  createTime: number = 0;
  updateTime: number = 0;

  constructor() {
    this.id = `record_${Date.now()}_${Math.random().toString(36).substring(2, 6)}`;
    this.date = Date.now();
    this.createTime = Date.now();
    this.updateTime = Date.now();
  }
}

// 生成历史记录
export class GeneratorHistory {
  id: string = '';
  recipeId: string = '';
  recipeName: string = '';
  targetFish: string = '';
  waterType: string = '';
  season: string = '';
  createTime: number = 0;

  constructor() {
    this.id = `history_${Date.now()}`;
    this.createTime = Date.now();
  }
}
