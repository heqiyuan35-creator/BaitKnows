/**
 * 鱼种数据�?
 * 包含常见淡水鱼和海水鱼的详细数据
 */
import {
  Fish,
  FlavorProfile,
  SeasonActivity,
  TemperatureRange,
  SeasonFlavorAdjust,
  SeasonalFlavorAdjustment,
  FishCategory
} from '../common/types/FishTypes';

function createCrucian(): Fish {
  const f = new Fish();
  f.id = 'crucian'; f.name = '鲫鱼'; f.scientificName = 'Carassius auratus';
  f.category = 'freshwater'; f.description = '最常见的淡水鱼，分布广泛，四季可钓'; f.difficulty = 3;
  f.waterType.push('pond'); f.waterType.push('river'); f.waterType.push('reservoir');
  f.habits.waterLayer = 'bottom';
  f.habits.temperatureRange = TemperatureRange.create(5, 18, 30);
  f.habits.activeTime.push('dawn'); f.habits.activeTime.push('morning'); f.habits.activeTime.push('dusk');
  f.habits.seasonActivity = SeasonActivity.create(9, 7, 9, 5);
  f.habits.alertness = 7; f.habits.schooling = true; f.habits.feedingStyle = 'cautious';
  f.dietPreference.type = 'omnivore';
  f.dietPreference.flavorPreference = FlavorProfile.create(70, 60, 80, 20, 10, 50, 40, 30, 40);
  f.dietPreference.seasonalFlavorAdjust = SeasonalFlavorAdjustment.create(
    SeasonFlavorAdjust.create('fishy', 'fragrant'), SeasonFlavorAdjust.create('fragrant', 'fruity'),
    SeasonFlavorAdjust.create('sweet', 'fragrant'), SeasonFlavorAdjust.create('fishy', 'sweet'));
  f.dietPreference.naturalFood.push('水草'); f.dietPreference.naturalFood.push('藻类');
  f.dietPreference.naturalFood.push('小虫'); f.dietPreference.naturalFood.push('浮游生物');
  f.dietPreference.naturalFood.push('红虫'); f.dietPreference.naturalFood.push('蚯蚓');
  return f;
}

function createCarp(): Fish {
  const f = new Fish();
  f.id = 'carp'; f.name = '鲤鱼'; f.scientificName = 'Cyprinus carpio';
  f.category = 'freshwater'; f.description = '体型较大，警觉性高，喜欢甜香味饵料'; f.difficulty = 4;
  f.waterType.push('pond'); f.waterType.push('river'); f.waterType.push('reservoir');
  f.habits.waterLayer = 'bottom';
  f.habits.temperatureRange = TemperatureRange.create(8, 22, 32);
  f.habits.activeTime.push('morning'); f.habits.activeTime.push('afternoon'); f.habits.activeTime.push('dusk');
  f.habits.seasonActivity = SeasonActivity.create(8, 9, 9, 4);
  f.habits.alertness = 8; f.habits.schooling = false; f.habits.feedingStyle = 'cautious';
  f.dietPreference.type = 'omnivore';
  f.dietPreference.flavorPreference = FlavorProfile.create(85, 50, 70, 30, 20, 40, 60, 20, 50);
  f.dietPreference.seasonalFlavorAdjust = SeasonalFlavorAdjustment.create(
    SeasonFlavorAdjust.create('fishy', 'sweet'), SeasonFlavorAdjust.create('sweet', 'fruity'),
    SeasonFlavorAdjust.create('sweet', 'fragrant'), SeasonFlavorAdjust.create('fishy', 'wine'));
  f.dietPreference.naturalFood.push('螺蛳'); f.dietPreference.naturalFood.push('河蚌');
  f.dietPreference.naturalFood.push('水草'); f.dietPreference.naturalFood.push('玉米');
  f.dietPreference.naturalFood.push('红薯'); f.dietPreference.naturalFood.push('蚯蚓');
  return f;
}


function createGrass(): Fish {
  const f = new Fish();
  f.id = 'grass'; f.name = '草鱼'; f.scientificName = 'Ctenopharyngodon idella';
  f.category = 'freshwater'; f.description = '草食性鱼类，喜食嫩草和发酵饵�?; f.difficulty = 3;
  f.waterType.push('pond'); f.waterType.push('river'); f.waterType.push('reservoir');
  f.habits.waterLayer = 'middle';
  f.habits.temperatureRange = TemperatureRange.create(10, 25, 35);
  f.habits.activeTime.push('morning'); f.habits.activeTime.push('afternoon');
  f.habits.seasonActivity = SeasonActivity.create(7, 10, 8, 3);
  f.habits.alertness = 6; f.habits.schooling = true; f.habits.feedingStyle = 'aggressive';
  f.dietPreference.type = 'herbivore';
  f.dietPreference.flavorPreference = FlavorProfile.create(60, 20, 90, 50, 30, 30, 70, 40, 60);
  f.dietPreference.seasonalFlavorAdjust = SeasonalFlavorAdjustment.create(
    SeasonFlavorAdjust.create('fragrant', 'sour'), SeasonFlavorAdjust.create('sour', 'fragrant'),
    SeasonFlavorAdjust.create('sweet', 'fragrant'), SeasonFlavorAdjust.create('fishy', 'fragrant'));
  f.dietPreference.naturalFood.push('嫩草'); f.dietPreference.naturalFood.push('芦苇�?);
  f.dietPreference.naturalFood.push('玉米'); f.dietPreference.naturalFood.push('麦粒');
  f.dietPreference.naturalFood.push('桑葚'); f.dietPreference.naturalFood.push('构树�?);
  return f;
}

function createSilver(): Fish {
  const f = new Fish();
  f.id = 'silver'; f.name = '鲢鱼'; f.scientificName = 'Hypophthalmichthys molitrix';
  f.category = 'freshwater'; f.description = '滤食性鱼类，喜酸臭味，中上层活动'; f.difficulty = 2;
  f.waterType.push('river'); f.waterType.push('reservoir');
  f.habits.waterLayer = 'surface';
  f.habits.temperatureRange = TemperatureRange.create(15, 28, 35);
  f.habits.activeTime.push('morning'); f.habits.activeTime.push('noon'); f.habits.activeTime.push('afternoon');
  f.habits.seasonActivity = SeasonActivity.create(6, 10, 7, 2);
  f.habits.alertness = 4; f.habits.schooling = true; f.habits.feedingStyle = 'aggressive';
  f.dietPreference.type = 'herbivore';
  f.dietPreference.flavorPreference = FlavorProfile.create(30, 40, 50, 90, 85, 20, 30, 70, 40);
  f.dietPreference.seasonalFlavorAdjust = SeasonalFlavorAdjustment.create(
    SeasonFlavorAdjust.create('sour', 'garlic'), SeasonFlavorAdjust.create('stinky', 'sour'),
    SeasonFlavorAdjust.create('sour', 'stinky'), SeasonFlavorAdjust.create('fishy', 'sour'));
  f.dietPreference.naturalFood.push('浮游藻类'); f.dietPreference.naturalFood.push('有机碎屑');
  f.dietPreference.naturalFood.push('浮游生物');
  return f;
}

function createBighead(): Fish {
  const f = new Fish();
  f.id = 'bighead'; f.name = '鳙鱼'; f.scientificName = 'Hypophthalmichthys nobilis';
  f.category = 'freshwater'; f.description = '又称花鲢、胖头鱼，滤食性，喜臭�?; f.difficulty = 2;
  f.waterType.push('river'); f.waterType.push('reservoir');
  f.habits.waterLayer = 'middle';
  f.habits.temperatureRange = TemperatureRange.create(15, 26, 33);
  f.habits.activeTime.push('morning'); f.habits.activeTime.push('afternoon');
  f.habits.seasonActivity = SeasonActivity.create(6, 9, 7, 2);
  f.habits.alertness = 5; f.habits.schooling = true; f.habits.feedingStyle = 'aggressive';
  f.dietPreference.type = 'omnivore';
  f.dietPreference.flavorPreference = FlavorProfile.create(25, 50, 40, 80, 95, 15, 20, 60, 30);
  f.dietPreference.seasonalFlavorAdjust = SeasonalFlavorAdjustment.create(
    SeasonFlavorAdjust.create('stinky', 'sour'), SeasonFlavorAdjust.create('stinky', 'garlic'),
    SeasonFlavorAdjust.create('sour', 'stinky'), SeasonFlavorAdjust.create('fishy', 'stinky'));
  f.dietPreference.naturalFood.push('浮游动物'); f.dietPreference.naturalFood.push('有机碎屑');
  f.dietPreference.naturalFood.push('轮虫'); f.dietPreference.naturalFood.push('枝角�?);
  return f;
}


function createCatfish(): Fish {
  const f = new Fish();
  f.id = 'catfish'; f.name = '鲶鱼'; f.scientificName = 'Silurus asotus';
  f.category = 'freshwater'; f.description = '肉食性鱼类，夜间活动，喜浓腥臭味'; f.difficulty = 2;
  f.waterType.push('pond'); f.waterType.push('river');
  f.habits.waterLayer = 'bottom';
  f.habits.temperatureRange = TemperatureRange.create(10, 24, 32);
  f.habits.activeTime.push('dusk'); f.habits.activeTime.push('night'); f.habits.activeTime.push('dawn');
  f.habits.seasonActivity = SeasonActivity.create(7, 9, 8, 4);
  f.habits.alertness = 3; f.habits.schooling = false; f.habits.feedingStyle = 'aggressive';
  f.dietPreference.type = 'carnivore';
  f.dietPreference.flavorPreference = FlavorProfile.create(10, 95, 20, 15, 90, 5, 5, 30, 10);
  f.dietPreference.seasonalFlavorAdjust = SeasonalFlavorAdjustment.create(
    SeasonFlavorAdjust.create('fishy', 'stinky'), SeasonFlavorAdjust.create('stinky', 'fishy'),
    SeasonFlavorAdjust.create('fishy', 'stinky'), SeasonFlavorAdjust.create('fishy', 'stinky'));
  f.dietPreference.naturalFood.push('小鱼'); f.dietPreference.naturalFood.push('�?);
  f.dietPreference.naturalFood.push('蚯蚓'); f.dietPreference.naturalFood.push('泥鳅');
  f.dietPreference.naturalFood.push('蛙类'); f.dietPreference.naturalFood.push('动物内脏');
  return f;
}

function createBlack(): Fish {
  const f = new Fish();
  f.id = 'black'; f.name = '青鱼'; f.scientificName = 'Mylopharyngodon piceus';
  f.category = 'freshwater'; f.description = '四大家鱼之首，体型大，喜食螺�?; f.difficulty = 5;
  f.waterType.push('reservoir'); f.waterType.push('river');
  f.habits.waterLayer = 'bottom';
  f.habits.temperatureRange = TemperatureRange.create(12, 24, 30);
  f.habits.activeTime.push('morning'); f.habits.activeTime.push('afternoon');
  f.habits.seasonActivity = SeasonActivity.create(7, 9, 8, 3);
  f.habits.alertness = 9; f.habits.schooling = false; f.habits.feedingStyle = 'cautious';
  f.dietPreference.type = 'carnivore';
  f.dietPreference.flavorPreference = FlavorProfile.create(40, 70, 50, 20, 40, 20, 30, 25, 35);
  f.dietPreference.seasonalFlavorAdjust = SeasonalFlavorAdjustment.create(
    SeasonFlavorAdjust.create('fishy', 'fragrant'), SeasonFlavorAdjust.create('fragrant', 'fishy'),
    SeasonFlavorAdjust.create('sweet', 'fishy'), SeasonFlavorAdjust.create('fishy', 'sweet'));
  f.dietPreference.naturalFood.push('螺蛳'); f.dietPreference.naturalFood.push('河蚌');
  f.dietPreference.naturalFood.push('蚬子'); f.dietPreference.naturalFood.push('�?);
  f.dietPreference.naturalFood.push('�?);
  return f;
}

function createBream(): Fish {
  const f = new Fish();
  f.id = 'bream'; f.name = '鳊鱼'; f.scientificName = 'Parabramis pekinensis';
  f.category = 'freshwater'; f.description = '又称武昌鱼，中层鱼类，喜香甜�?; f.difficulty = 3;
  f.waterType.push('pond'); f.waterType.push('river'); f.waterType.push('reservoir');
  f.habits.waterLayer = 'middle';
  f.habits.temperatureRange = TemperatureRange.create(10, 22, 30);
  f.habits.activeTime.push('morning'); f.habits.activeTime.push('afternoon'); f.habits.activeTime.push('dusk');
  f.habits.seasonActivity = SeasonActivity.create(8, 8, 9, 4);
  f.habits.alertness = 6; f.habits.schooling = true; f.habits.feedingStyle = 'opportunistic';
  f.dietPreference.type = 'omnivore';
  f.dietPreference.flavorPreference = FlavorProfile.create(75, 45, 85, 25, 15, 55, 50, 20, 45);
  f.dietPreference.seasonalFlavorAdjust = SeasonalFlavorAdjustment.create(
    SeasonFlavorAdjust.create('fragrant', 'fishy'), SeasonFlavorAdjust.create('fragrant', 'sweet'),
    SeasonFlavorAdjust.create('sweet', 'fragrant'), SeasonFlavorAdjust.create('fishy', 'fragrant'));
  f.dietPreference.naturalFood.push('水草'); f.dietPreference.naturalFood.push('藻类');
  f.dietPreference.naturalFood.push('小虫'); f.dietPreference.naturalFood.push('浮游生物');
  return f;
}


function createTilapia(): Fish {
  const f = new Fish();
  f.id = 'tilapia'; f.name = '罗非�?; f.scientificName = 'Oreochromis niloticus';
  f.category = 'freshwater'; f.description = '热带鱼种，适应性强，容易钓�?; f.difficulty = 1;
  f.waterType.push('pond');
  f.habits.waterLayer = 'all';
  f.habits.temperatureRange = TemperatureRange.create(18, 28, 38);
  f.habits.activeTime.push('morning'); f.habits.activeTime.push('noon'); f.habits.activeTime.push('afternoon');
  f.habits.seasonActivity = SeasonActivity.create(6, 10, 7, 2);
  f.habits.alertness = 3; f.habits.schooling = true; f.habits.feedingStyle = 'aggressive';
  f.dietPreference.type = 'omnivore';
  f.dietPreference.flavorPreference = FlavorProfile.create(60, 70, 60, 30, 50, 40, 35, 45, 25);
  f.dietPreference.seasonalFlavorAdjust = SeasonalFlavorAdjustment.create(
    SeasonFlavorAdjust.create('fishy', 'fragrant'), SeasonFlavorAdjust.create('fragrant', 'fishy'),
    SeasonFlavorAdjust.create('fishy', 'sweet'), SeasonFlavorAdjust.create('fishy', 'fishy'));
  f.dietPreference.naturalFood.push('藻类'); f.dietPreference.naturalFood.push('水草');
  f.dietPreference.naturalFood.push('小虫'); f.dietPreference.naturalFood.push('有机碎屑');
  f.dietPreference.naturalFood.push('蚯蚓');
  return f;
}

function createYellowhead(): Fish {
  const f = new Fish();
  f.id = 'yellowhead'; f.name = '黄颡�?; f.scientificName = 'Pelteobagrus fulvidraco';
  f.category = 'freshwater'; f.description = '又称黄辣丁，肉食性，夜间活动'; f.difficulty = 2;
  f.waterType.push('pond'); f.waterType.push('river');
  f.habits.waterLayer = 'bottom';
  f.habits.temperatureRange = TemperatureRange.create(8, 22, 30);
  f.habits.activeTime.push('dusk'); f.habits.activeTime.push('night'); f.habits.activeTime.push('dawn');
  f.habits.seasonActivity = SeasonActivity.create(7, 9, 8, 4);
  f.habits.alertness = 4; f.habits.schooling = false; f.habits.feedingStyle = 'aggressive';
  f.dietPreference.type = 'carnivore';
  f.dietPreference.flavorPreference = FlavorProfile.create(15, 90, 25, 10, 70, 10, 5, 20, 15);
  f.dietPreference.seasonalFlavorAdjust = SeasonalFlavorAdjustment.create(
    SeasonFlavorAdjust.create('fishy', 'stinky'), SeasonFlavorAdjust.create('fishy', 'stinky'),
    SeasonFlavorAdjust.create('fishy', 'stinky'), SeasonFlavorAdjust.create('fishy', 'fishy'));
  f.dietPreference.naturalFood.push('蚯蚓'); f.dietPreference.naturalFood.push('红虫');
  f.dietPreference.naturalFood.push('小虾'); f.dietPreference.naturalFood.push('小鱼');
  f.dietPreference.naturalFood.push('螺肉');
  return f;
}

function getFishData(): Fish[] {
  const fishes: Fish[] = [];
  fishes.push(createCrucian());
  fishes.push(createCarp());
  fishes.push(createGrass());
  fishes.push(createSilver());
  fishes.push(createBighead());
  fishes.push(createCatfish());
  fishes.push(createBlack());
  fishes.push(createBream());
  fishes.push(createTilapia());
  fishes.push(createYellowhead());
  return fishes;
}

class FishDatabaseClass {
  private fishes: Fish[] = [];
  constructor() { this.fishes = getFishData(); }
  getAllFishes(): Fish[] { return this.fishes; }
  getFishById(id: string): Fish | undefined {
    for (let i = 0; i < this.fishes.length; i++) {
      if (this.fishes[i].id === id) return this.fishes[i];
    }
    return undefined;
  }
  getFishByWaterType(waterType: string): Fish[] {
    const result: Fish[] = [];
    for (let i = 0; i < this.fishes.length; i++) {
      const fish = this.fishes[i];
      for (let j = 0; j < fish.waterType.length; j++) {
        if (fish.waterType[j] === waterType) { result.push(fish); break; }
      }
    }
    return result;
  }
  getFishByCategory(category: FishCategory): Fish[] {
    const result: Fish[] = [];
    for (let i = 0; i < this.fishes.length; i++) {
      if (this.fishes[i].category === category) result.push(this.fishes[i]);
    }
    return result;
  }
  getFishNameMap(): Map<string, string> {
    const map = new Map<string, string>();
    for (let i = 0; i < this.fishes.length; i++) {
      map.set(this.fishes[i].id, this.fishes[i].name);
    }
    return map;
  }
}

export const fishDatabase = new FishDatabaseClass();
export function getFishById(id: string): Fish | undefined { return fishDatabase.getFishById(id); }
export function getFishByWaterType(waterType: string): Fish[] { return fishDatabase.getFishByWaterType(waterType); }
export function getFishByCategory(category: FishCategory): Fish[] { return fishDatabase.getFishByCategory(category); }
export function getFishNameMap(): Map<string, string> { return fishDatabase.getFishNameMap(); }
