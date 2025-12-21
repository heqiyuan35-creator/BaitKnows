/**
 * 原材料相关类型定义
 */
import { FlavorProfile } from './FishTypes';

// 原料分类
export type IngredientCategory = 'base' | 'protein' | 'additive' | 'state' | 'binder' | 'natural';

// 季节
export type Season = 'spring' | 'summer' | 'autumn' | 'winter';

// 物理属性
export class PhysicalProperties {
  atomization: number = 5;
  viscosity: number = 5;
  weight: number = 5;
  dispersal: number = 5;

  constructor() {}

  static create(a: number, v: number, w: number, d: number): PhysicalProperties {
    const p = new PhysicalProperties();
    p.atomization = a;
    p.viscosity = v;
    p.weight = w;
    p.dispersal = d;
    return p;
  }
}

// 用量范围
export class DosageRange {
  min: number = 0;
  max: number = 100;

  constructor() {}

  static create(minVal: number, maxVal: number): DosageRange {
    const d = new DosageRange();
    d.min = minVal;
    d.max = maxVal;
    return d;
  }
}

// 简单温度范围
export class SimpleTemperatureRange {
  min: number = 0;
  max: number = 40;

  constructor() {}

  static create(minVal: number, maxVal: number): SimpleTemperatureRange {
    const t = new SimpleTemperatureRange();
    t.min = minVal;
    t.max = maxVal;
    return t;
  }
}

// 原材料
export class Ingredient {
  id: string = '';
  name: string = '';
  category: IngredientCategory = 'base';
  flavorProfile: FlavorProfile = new FlavorProfile();
  physical: PhysicalProperties = new PhysicalProperties();
  targetFish: string[] = [];
  suitableSeason: Season[] = [];
  temperatureRange: SimpleTemperatureRange = new SimpleTemperatureRange();
  dosageRange: DosageRange = new DosageRange();
  notes: string = '';
  price: number = 0;

  constructor() {}
}
