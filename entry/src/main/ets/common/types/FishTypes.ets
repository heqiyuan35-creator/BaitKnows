/**
 * 鱼种相关类型定义
 */

// 鱼类分类
export type FishCategory = 'freshwater' | 'saltwater';

// 水域类型
export type WaterType = 'pond' | 'river' | 'reservoir' | 'sea';

// 水层
export type WaterLayer = 'surface' | 'middle' | 'bottom' | 'all';

// 活跃时段
export type ActiveTime = 'dawn' | 'morning' | 'noon' | 'afternoon' | 'dusk' | 'night';

// 觅食风格
export type FeedingStyle = 'aggressive' | 'cautious' | 'opportunistic';

// 食性类型
export type DietType = 'herbivore' | 'carnivore' | 'omnivore';

// 味型
export class FlavorProfile {
  sweet: number = 0;
  fishy: number = 0;
  fragrant: number = 0;
  sour: number = 0;
  stinky: number = 0;
  milky: number = 0;
  fruity: number = 0;
  garlic: number = 0;
  wine: number = 0;

  constructor() {}

  static create(s: number, fi: number, fr: number, so: number, st: number, m: number, fu: number, g: number, w: number): FlavorProfile {
    const p = new FlavorProfile();
    p.sweet = s;
    p.fishy = fi;
    p.fragrant = fr;
    p.sour = so;
    p.stinky = st;
    p.milky = m;
    p.fruity = fu;
    p.garlic = g;
    p.wine = w;
    return p;
  }
}

// 季节活跃度
export class SeasonActivity {
  spring: number = 5;
  summer: number = 5;
  autumn: number = 5;
  winter: number = 5;

  constructor() {}

  static create(sp: number, su: number, au: number, wi: number): SeasonActivity {
    const s = new SeasonActivity();
    s.spring = sp;
    s.summer = su;
    s.autumn = au;
    s.winter = wi;
    return s;
  }
}

// 温度范围
export class TemperatureRange {
  min: number = 0;
  optimal: number = 20;
  max: number = 35;

  constructor() {}

  static create(min: number, opt: number, max: number): TemperatureRange {
    const t = new TemperatureRange();
    t.min = min;
    t.optimal = opt;
    t.max = max;
    return t;
  }
}

// 季节味型调整
export class SeasonFlavorAdjust {
  primary: string = '';
  secondary: string = '';

  constructor() {}

  static create(p: string, s: string): SeasonFlavorAdjust {
    const a = new SeasonFlavorAdjust();
    a.primary = p;
    a.secondary = s;
    return a;
  }
}

// 季节味型调整集合
export class SeasonalFlavorAdjustment {
  spring: SeasonFlavorAdjust = new SeasonFlavorAdjust();
  summer: SeasonFlavorAdjust = new SeasonFlavorAdjust();
  autumn: SeasonFlavorAdjust = new SeasonFlavorAdjust();
  winter: SeasonFlavorAdjust = new SeasonFlavorAdjust();

  constructor() {}

  static create(sp: SeasonFlavorAdjust, su: SeasonFlavorAdjust, au: SeasonFlavorAdjust, wi: SeasonFlavorAdjust): SeasonalFlavorAdjustment {
    const s = new SeasonalFlavorAdjustment();
    s.spring = sp;
    s.summer = su;
    s.autumn = au;
    s.winter = wi;
    return s;
  }
}

// 鱼类习性
export class FishHabits {
  waterLayer: WaterLayer = 'bottom';
  temperatureRange: TemperatureRange = new TemperatureRange();
  activeTime: ActiveTime[] = [];
  seasonActivity: SeasonActivity = new SeasonActivity();
  alertness: number = 5;
  schooling: boolean = false;
  feedingStyle: FeedingStyle = 'cautious';

  constructor() {}
}

// 食性偏好
export class DietPreference {
  type: DietType = 'omnivore';
  flavorPreference: FlavorProfile = new FlavorProfile();
  seasonalFlavorAdjust: SeasonalFlavorAdjustment = new SeasonalFlavorAdjustment();
  naturalFood: string[] = [];

  constructor() {}
}

// 鱼种完整定义
export class Fish {
  id: string = '';
  name: string = '';
  scientificName: string = '';
  category: FishCategory = 'freshwater';
  waterType: WaterType[] = [];
  habits: FishHabits = new FishHabits();
  dietPreference: DietPreference = new DietPreference();
  description: string = '';
  difficulty: number = 3;

  constructor() {}
}
