/**
 * 饵知�?- 鱼种数据
 * 统一的鱼种信息管�?
 */

// 食性类�?
export type FeedingType = 'herbivore' | 'carnivore' | 'omnivore';  // 草食 | 肉食 | 杂食

// 活动水层
export type WaterLayer = 'surface' | 'middle' | 'bottom' | 'all';  // 上层 | 中层 | 底层 | 全水�?

// 活动时段
export type ActivityTime = 'day' | 'night' | 'dawn_dusk' | 'all';  // 白天 | 夜间 | 晨昏 | 全天

// 鱼种习�?
export interface FishHabit {
  feedingType: FeedingType;       // 食�?
  waterLayer: WaterLayer;         // 活动水层
  activityTime: ActivityTime;     // 活动时段
  preferredTemp: string;          // 适宜水温范围
  activeSeasons: string[];        // 活跃季节
  favoriteFood: string[];         // 喜食饵料
  description: string;            // 习性描�?
}

// 鱼种数据接口
export interface FishData {
  id: string;                     // 唯一标识
  name: string;                   // 中文�?
  nameEn: string;                 // 英文�?
  icon: Resource;                 // 图标
  iconActive: Resource;           // 选中图标
  waterTypes: string[];           // 适合的水域类�?
  habit: FishHabit;               // 习性信�?
}

// 食性名称映�?
export const FeedingTypeNames: Record<FeedingType, string> = {
  'herbivore': '草食�?,
  'carnivore': '肉食�?,
  'omnivore': '杂食�?
};

// 水层名称映射
export const WaterLayerNames: Record<WaterLayer, string> = {
  'surface': '上层',
  'middle': '中层',
  'bottom': '底层',
  'all': '全水�?
};

// 活动时段名称映射
export const ActivityTimeNames: Record<ActivityTime, string> = {
  'day': '白天',
  'night': '夜间',
  'dawn_dusk': '晨昏',
  'all': '全天'
};


// ==================== 所有鱼种数�?====================
export const ALL_FISH_DATA: FishData[] = [
  // ========== 池塘常见鱼种 ==========
  {
    id: 'crucian', name: '鲫鱼', nameEn: 'Crucian Carp',
    icon: $r('app.media.Crucian_carp'), iconActive: $r('app.media.Crucian_carp'),
    waterTypes: ['pond', 'river', 'lake'],
    habit: { feedingType: 'omnivore', waterLayer: 'bottom', activityTime: 'all',
      preferredTemp: '15-25°C', activeSeasons: ['春季', '秋季'],
      favoriteFood: ['蚯蚓', '红虫', '商品�?, '玉米'],
      description: '性情温和，喜群居，耐低氧，四季可钓，春秋最�? }
  },
  {
    id: 'carp', name: '鲤鱼', nameEn: 'Common Carp',
    icon: $r('app.media.Carp'), iconActive: $r('app.media.Carp'),
    waterTypes: ['pond', 'river', 'reservoir', 'lake'],
    habit: { feedingType: 'omnivore', waterLayer: 'bottom', activityTime: 'dawn_dusk',
      preferredTemp: '18-28°C', activeSeasons: ['春季', '夏季', '秋季'],
      favoriteFood: ['玉米', '红薯', '螺蛳', '蚯蚓'],
      description: '生性胆小警觉，喜在水底觅食，晨昏活动频�? }
  },
  {
    id: 'grass_carp', name: '草鱼', nameEn: 'Grass Carp',
    icon: $r('app.media.Grass_carp'), iconActive: $r('app.media.Grass_carp'),
    waterTypes: ['pond', 'river', 'reservoir', 'lake'],
    habit: { feedingType: 'herbivore', waterLayer: 'middle', activityTime: 'day',
      preferredTemp: '20-30°C', activeSeasons: ['夏季', '秋季'],
      favoriteFood: ['嫩草', '芦苇', '玉米', '麦粒'],
      description: '草食性为主，喜食水草嫩叶，夏季高温期最活跃' }
  },
  {
    id: 'bighead', name: '鳙鱼', nameEn: 'Bighead Carp',
    icon: $r('app.media.Bigheadcarp'), iconActive: $r('app.media.Bigheadcarp'),
    waterTypes: ['pond', 'reservoir'],
    habit: { feedingType: 'omnivore', waterLayer: 'surface', activityTime: 'day',
      preferredTemp: '22-30°C', activeSeasons: ['夏季'],
      favoriteFood: ['酸臭�?, '发酵�?, '浮游生物'],
      description: '滤食性鱼类，喜酸臭味饵料，夏季高温浮钓效果好' }
  },
  {
    id: 'silver_carp', name: '鲢鱼', nameEn: 'Silver Carp',
    icon: $r('app.media.Silvercarp'), iconActive: $r('app.media.Silvercarp'),
    waterTypes: ['pond', 'reservoir'],
    habit: { feedingType: 'omnivore', waterLayer: 'surface', activityTime: 'day',
      preferredTemp: '22-30°C', activeSeasons: ['夏季'],
      favoriteFood: ['酸饵', '雾化�?, '浮游生物'],
      description: '与鳙鱼习性相近，喜酸味饵料，常浮�? }
  },
  {
    id: 'tilapia', name: '罗非�?, nameEn: 'Tilapia',
    icon: $r('app.media.Tilapia'), iconActive: $r('app.media.Tilapia'),
    waterTypes: ['pond'],
    habit: { feedingType: 'omnivore', waterLayer: 'all', activityTime: 'day',
      preferredTemp: '25-35°C', activeSeasons: ['夏季', '秋季'],
      favoriteFood: ['蚯蚓', '虾粉', '商品�?, '冻料'],
      description: '南方池塘常见，耐高温，繁殖力强，夏季活�? }
  },
  {
    id: 'channel_catfish', name: '斑点叉尾�?, nameEn: 'Channel Catfish',
    icon: $r('app.media.Spotted_Forktail_Catfish'), iconActive: $r('app.media.Spotted_Forktail_Catfish'),
    waterTypes: ['pond'],
    habit: { feedingType: 'omnivore', waterLayer: 'bottom', activityTime: 'night',
      preferredTemp: '20-28°C', activeSeasons: ['夏季', '秋季'],
      favoriteFood: ['鸡肝', '颗粒�?, '蚯蚓', '虾肉'],
      description: '黑坑常见养殖鱼种，喜腥味饵料，夜间活�? }
  },

  // ========== 河流特色鱼种 ==========
  {
    id: 'catfish', name: '鲶鱼', nameEn: 'Catfish',
    icon: $r('app.media.Catfish'), iconActive: $r('app.media.Catfish'),
    waterTypes: ['river', 'pond'],
    habit: { feedingType: 'carnivore', waterLayer: 'bottom', activityTime: 'night',
      preferredTemp: '20-28°C', activeSeasons: ['夏季', '秋季'],
      favoriteFood: ['鸡肝', '蚯蚓', '小鱼', '泥鳅'],
      description: '夜行性肉食鱼，喜腥味重饵，夜钓效果最�? }
  },
  {
    id: 'yellow_catfish', name: '黄颡�?, nameEn: 'Yellow Catfish',
    icon: $r('app.media.Yellow_catfish'), iconActive: $r('app.media.Yellow_catfish'),
    waterTypes: ['river'],
    habit: { feedingType: 'carnivore', waterLayer: 'bottom', activityTime: 'night',
      preferredTemp: '18-28°C', activeSeasons: ['夏季', '秋季'],
      favoriteFood: ['蚯蚓', '鸡肝', '虾肉', '红虫'],
      description: '夜行性底栖鱼，喜腥饵，常藏于石缝中，肉质鲜美' }
  },
  {
    id: 'bream', name: '鳊鱼', nameEn: 'Bream',
    icon: $r('app.media.Bream'), iconActive: $r('app.media.Bream'),
    waterTypes: ['river', 'lake'],
    habit: { feedingType: 'herbivore', waterLayer: 'middle', activityTime: 'day',
      preferredTemp: '18-26°C', activeSeasons: ['春季', '夏季', '秋季'],
      favoriteFood: ['麸皮', '玉米�?, '青草', '麦粒'],
      description: '草食性为主，喜素饵，常在中上层活�? }
  },
  {
    id: 'culter', name: '翘嘴', nameEn: 'Culter',
    icon: $r('app.media.Bigmouth_bass'), iconActive: $r('app.media.Bigmouth_bass'),
    waterTypes: ['river', 'reservoir', 'lake'],
    habit: { feedingType: 'carnivore', waterLayer: 'surface', activityTime: 'dawn_dusk',
      preferredTemp: '18-28°C', activeSeasons: ['夏季', '秋季'],
      favoriteFood: ['小鱼', '�?, '亮片', '米诺'],
      description: '凶猛掠食性，喜追逐小鱼，路亚和活饵效果好' }
  },
  {
    id: 'topmouth_culter', name: '马口', nameEn: 'Topmouth Culter',
    icon: $r('app.media.Mouthbrooder'), iconActive: $r('app.media.Mouthbrooder'),
    waterTypes: ['river'],
    habit: { feedingType: 'carnivore', waterLayer: 'surface', activityTime: 'day',
      preferredTemp: '15-25°C', activeSeasons: ['春季', '夏季', '秋季'],
      favoriteFood: ['小虫', '飞蝇', '亮片', '软虫'],
      description: '溪流路亚热门鱼种，喜清澈流水，攻击性强' }
  },
  {
    id: 'barbel', name: '鲃鱼', nameEn: 'Barbel',
    icon: $r('app.media.Snakehead_fish'), iconActive: $r('app.media.Snakehead_fish'),
    waterTypes: ['river'],
    habit: { feedingType: 'omnivore', waterLayer: 'bottom', activityTime: 'day',
      preferredTemp: '18-26°C', activeSeasons: ['春季', '夏季', '秋季'],
      favoriteFood: ['蚯蚓', '虾肉', '螺蛳', '水生昆虫'],
      description: '喜急流环境，常在石缝觅食，力量�? }
  },
  {
    id: 'chub', name: '赤眼�?, nameEn: 'Chub',
    icon: $r('app.media.Red_eye_trout'), iconActive: $r('app.media.Red_eye_trout'),
    waterTypes: ['river'],
    habit: { feedingType: 'omnivore', waterLayer: 'middle', activityTime: 'day',
      preferredTemp: '16-26°C', activeSeasons: ['春季', '夏季', '秋季'],
      favoriteFood: ['蚯蚓', '面饵', '玉米', '麦粒'],
      description: '中小型河鱼，眼睛红色，肉质鲜�? }
  },
  {
    id: 'loach', name: '泥鳅', nameEn: 'Loach',
    icon: $r('app.media.Loach'), iconActive: $r('app.media.Loach'),
    waterTypes: ['river', 'pond'],
    habit: { feedingType: 'omnivore', waterLayer: 'bottom', activityTime: 'night',
      preferredTemp: '18-28°C', activeSeasons: ['夏季', '秋季'],
      favoriteFood: ['蚯蚓', '红虫', '腐殖�?],
      description: '底栖鱼类，喜泥底环境，常作为钓饵使用' }
  },
  {
    id: 'mandarin_fish_river', name: '河鳜', nameEn: 'River Mandarin Fish',
    icon: $r('app.media.Chinese_perch'), iconActive: $r('app.media.Chinese_perch'),
    waterTypes: ['river'],
    habit: { feedingType: 'carnivore', waterLayer: 'middle', activityTime: 'dawn_dusk',
      preferredTemp: '18-26°C', activeSeasons: ['春季', '秋季'],
      favoriteFood: ['小鱼', '�?, '泥鳅'],
      description: '河流中的鳜鱼，喜清澈流水，以活饵垂钓' }
  },

  // ========== 水库大型鱼种 ==========
  {
    id: 'black_carp', name: '青鱼', nameEn: 'Black Carp',
    icon: $r('app.media.Black_carp'), iconActive: $r('app.media.Black_carp'),
    waterTypes: ['reservoir', 'lake'],
    habit: { feedingType: 'carnivore', waterLayer: 'bottom', activityTime: 'day',
      preferredTemp: '18-26°C', activeSeasons: ['夏季', '秋季'],
      favoriteFood: ['螺蛳', '蚌肉', '河蚬', '蚯蚓'],
      description: '四大家鱼之一，喜食螺蛳贝类，体型大力量足' }
  },
  {
    id: 'mandarin_fish', name: '鳜鱼', nameEn: 'Mandarin Fish',
    icon: $r('app.media.Chinese_perch'), iconActive: $r('app.media.Chinese_perch'),
    waterTypes: ['reservoir', 'lake'],
    habit: { feedingType: 'carnivore', waterLayer: 'middle', activityTime: 'dawn_dusk',
      preferredTemp: '18-25°C', activeSeasons: ['春季', '秋季'],
      favoriteFood: ['小鱼', '�?, '泥鳅'],
      description: '名贵肉食性鱼类，喜清澈水质，以活饵垂钓效果最�? }
  },
  {
    id: 'wuchang_fish', name: '武昌�?, nameEn: 'Wuchang Fish',
    icon: $r('app.media.Wuchang_Fish'), iconActive: $r('app.media.Wuchang_Fish'),
    waterTypes: ['reservoir', 'lake'],
    habit: { feedingType: 'herbivore', waterLayer: 'middle', activityTime: 'day',
      preferredTemp: '18-28°C', activeSeasons: ['春季', '夏季', '秋季'],
      favoriteFood: ['麸皮', '玉米', '青草', '藻类'],
      description: '长江中下游特产，肉质细嫩，喜素饵' }
  },
  {
    id: 'giant_carp', name: '巨鲤', nameEn: 'Giant Carp',
    icon: $r('app.media.Giant_Carp'), iconActive: $r('app.media.Giant_Carp'),
    waterTypes: ['reservoir'],
    habit: { feedingType: 'omnivore', waterLayer: 'bottom', activityTime: 'dawn_dusk',
      preferredTemp: '18-26°C', activeSeasons: ['春季', '秋季'],
      favoriteFood: ['玉米', '红薯', '螺蛳', '酒糟'],
      description: '水库大物代表，体重可达数十斤，需重窝守钓' }
  },
  {
    id: 'yellow_cheek', name: '黄尾�?, nameEn: 'Yellow Cheek Carp',
    icon: $r('app.media.Yellowtail_Catfish'), iconActive: $r('app.media.Yellowtail_Catfish'),
    waterTypes: ['reservoir'],
    habit: { feedingType: 'omnivore', waterLayer: 'bottom', activityTime: 'day',
      preferredTemp: '16-26°C', activeSeasons: ['春季', '夏季', '秋季'],
      favoriteFood: ['藻类', '蚯蚓', '商品�?],
      description: '水库常见鱼种，喜刮食石头上的藻类' }
  },
  {
    id: 'catla', name: '鲮鱼', nameEn: 'Catla',
    icon: $r('app.media.Liza_fish'), iconActive: $r('app.media.Liza_fish'),
    waterTypes: ['reservoir'],
    habit: { feedingType: 'omnivore', waterLayer: 'bottom', activityTime: 'day',
      preferredTemp: '22-30°C', activeSeasons: ['夏季', '秋季'],
      favoriteFood: ['花生�?, '商品�?, '蚯蚓'],
      description: '南方水库常见，喜温暖水域，力量大' }
  },
  {
    id: 'bass', name: '大口黑鲈', nameEn: 'Largemouth Bass',
    icon: $r('app.media.Largemouth_Bass'), iconActive: $r('app.media.Largemouth_Bass'),
    waterTypes: ['reservoir', 'lake'],
    habit: { feedingType: 'carnivore', waterLayer: 'all', activityTime: 'dawn_dusk',
      preferredTemp: '18-28°C', activeSeasons: ['春季', '夏季', '秋季'],
      favoriteFood: ['小鱼', '�?, '软虫', '米诺'],
      description: '路亚钓法最热门对象鱼，攻击性强，手感好' }
  },

  // ========== 湖泊特色鱼种 ==========
  {
    id: 'snakehead', name: '黑鱼', nameEn: 'Snakehead',
    icon: $r('app.media.Snakeheadfish'), iconActive: $r('app.media.Snakeheadfish'),
    waterTypes: ['lake', 'pond'],
    habit: { feedingType: 'carnivore', waterLayer: 'all', activityTime: 'day',
      preferredTemp: '20-30°C', activeSeasons: ['夏季', '秋季'],
      favoriteFood: ['小鱼', '青蛙', '泥鳅', '雷蛙'],
      description: '凶猛肉食性，喜藏于水草中伏击猎物，路亚热门对象鱼' }
  },
  {
    id: 'pike', name: '狗鱼', nameEn: 'Pike',
    icon: $r('app.media.Northern_pike'), iconActive: $r('app.media.Northern_pike'),
    waterTypes: ['lake'],
    habit: { feedingType: 'carnivore', waterLayer: 'middle', activityTime: 'day',
      preferredTemp: '12-22°C', activeSeasons: ['春季', '秋季', '冬季'],
      favoriteFood: ['小鱼', '蛙类', '大型软虫'],
      description: '北方湖泊顶级掠食者，体型大，攻击性极�? }
  },
  {
    id: 'perch', name: '鲈鱼', nameEn: 'Perch',
    icon: $r('app.media.Perch'), iconActive: $r('app.media.Perch'),
    waterTypes: ['lake'],
    habit: { feedingType: 'carnivore', waterLayer: 'middle', activityTime: 'day',
      preferredTemp: '15-25°C', activeSeasons: ['春季', '秋季'],
      favoriteFood: ['小鱼', '�?, '蚯蚓'],
      description: '淡水鲈鱼，肉质鲜美，喜清澈水�? }
  },
  {
    id: 'whitebait', name: '银鱼', nameEn: 'Whitebait',
    icon: $r('app.media.Whitebait'), iconActive: $r('app.media.Whitebait'),
    waterTypes: ['lake'],
    habit: { feedingType: 'carnivore', waterLayer: 'surface', activityTime: 'day',
      preferredTemp: '15-22°C', activeSeasons: ['春季', '秋季'],
      favoriteFood: ['浮游生物', '小虫'],
      description: '太湖特产，体型小透明，常作为其他鱼的饵料' }
  },
  {
    id: 'redfin_culter', name: '红鳍�?, nameEn: 'Redfin Culter',
    icon: $r('app.media.Redfin_culter'), iconActive: $r('app.media.Redfin_culter'),
    waterTypes: ['lake', 'river'],
    habit: { feedingType: 'carnivore', waterLayer: 'surface', activityTime: 'day',
      preferredTemp: '18-28°C', activeSeasons: ['夏季', '秋季'],
      favoriteFood: ['小鱼', '�?, '昆虫'],
      description: '鳍呈红色，外形优美，攻击性强' }
  },
  {
    id: 'softshell_turtle', name: '甲鱼', nameEn: 'Softshell Turtle',
    icon: $r('app.media.Soft_shelledturtle'), iconActive: $r('app.media.Soft_shelledturtle'),
    waterTypes: ['lake', 'pond'],
    habit: { feedingType: 'carnivore', waterLayer: 'bottom', activityTime: 'night',
      preferredTemp: '22-30°C', activeSeasons: ['夏季', '秋季'],
      favoriteFood: ['鸡肝', '猪肝', '小鱼', '蚯蚓'],
      description: '夜行性，喜腥味重饵，需用专门钓�? }
  },
  {
    id: 'eel', name: '黄鳝', nameEn: 'Asian Swamp Eel',
    icon: $r('app.media.eel'), iconActive: $r('app.media.eel'),
    waterTypes: ['lake', 'pond', 'river'],
    habit: { feedingType: 'carnivore', waterLayer: 'bottom', activityTime: 'night',
      preferredTemp: '22-30°C', activeSeasons: ['夏季', '秋季'],
      favoriteFood: ['蚯蚓', '小鱼', '蛙类'],
      description: '穴居鱼类，夜间出洞觅食，需专门钓法' }
  },
  {
    id: 'crab', name: '河蟹', nameEn: 'River Crab',
    icon: $r('app.media.river_crab'), iconActive: $r('app.media.river_crab'),
    waterTypes: ['lake'],
    habit: { feedingType: 'omnivore', waterLayer: 'bottom', activityTime: 'night',
      preferredTemp: '18-25°C', activeSeasons: ['秋季'],
      favoriteFood: ['鸡肝', '鱼肉', '玉米'],
      description: '阳澄湖大闸蟹闻名，秋季肥美，夜间活动' }
  },
  {
    id: 'shrimp', name: '河虾', nameEn: 'River Shrimp',
    icon: $r('app.media.river_shrimp'), iconActive: $r('app.media.river_shrimp'),
    waterTypes: ['lake', 'river'],
    habit: { feedingType: 'omnivore', waterLayer: 'bottom', activityTime: 'night',
      preferredTemp: '18-28°C', activeSeasons: ['夏季', '秋季'],
      favoriteFood: ['腐殖�?, '藻类', '小虫'],
      description: '常见淡水虾，可作为钓饵或垂钓对象' }
  }
];


// ==================== 工具函数 ====================

// 根据ID获取鱼种数据
export function getFishById(id: string): FishData | undefined {
  return ALL_FISH_DATA.find((fish: FishData) => fish.id === id);
}

// 根据水域类型获取鱼种列表
export function getFishByWaterType(waterType: string): FishData[] {
  return ALL_FISH_DATA.filter((fish: FishData) => fish.waterTypes.includes(waterType));
}

// 根据食性获取鱼种列�?
export function getFishByFeedingType(feedingType: FeedingType): FishData[] {
  return ALL_FISH_DATA.filter((fish: FishData) => fish.habit.feedingType === feedingType);
}

// 根据活动水层获取鱼种列表
export function getFishByWaterLayer(layer: WaterLayer): FishData[] {
  return ALL_FISH_DATA.filter((fish: FishData) => fish.habit.waterLayer === layer);
}

// 根据活动时段获取鱼种列表
export function getFishByActivityTime(time: ActivityTime): FishData[] {
  return ALL_FISH_DATA.filter((fish: FishData) => fish.habit.activityTime === time);
}

// 获取所有鱼种ID列表（按水域分组�?
export function getFishIdsByWaterType(): Record<string, string[]> {
  return {
    'pond': ALL_FISH_DATA.filter((f: FishData) => f.waterTypes.includes('pond')).map((f: FishData) => f.id),
    'river': ALL_FISH_DATA.filter((f: FishData) => f.waterTypes.includes('river')).map((f: FishData) => f.id),
    'reservoir': ALL_FISH_DATA.filter((f: FishData) => f.waterTypes.includes('reservoir')).map((f: FishData) => f.id),
    'lake': ALL_FISH_DATA.filter((f: FishData) => f.waterTypes.includes('lake')).map((f: FishData) => f.id)
  };
}
