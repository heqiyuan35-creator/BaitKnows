/**
 * 钓点数据 - 水域类型和钓点信�?
 */

// 水域类型
export enum WaterType {
  POND = 'pond',           // 池塘
  RESERVOIR = 'reservoir', // 水库
  RIVER = 'river',         // 河流
  LAKE = 'lake'            // 湖泊
}

// 水域类型中文�?
export const WaterTypeNames: Record<string, string> = {
  [WaterType.POND]: '池塘',
  [WaterType.RESERVOIR]: '水库',
  [WaterType.RIVER]: '河流',
  [WaterType.LAKE]: '湖泊'
};

// 水域类型图片资源
export interface WaterTypeImageResource {
  normal: Resource;
  active: Resource;
}

export const WaterTypeImages: Record<string, WaterTypeImageResource> = {
  [WaterType.POND]: { normal: $r('app.media.Pond'), active: $r('app.media.Ponds') },
  [WaterType.RESERVOIR]: { normal: $r('app.media.Reservoir'), active: $r('app.media.Reservoirs') },
  [WaterType.RIVER]: { normal: $r('app.media.River'), active: $r('app.media.Rivers') },
  [WaterType.LAKE]: { normal: $r('app.media.Lake'), active: $r('app.media.Lakes') }
};

// 钓点信息
export interface FishingSpot {
  id: string;
  name: string;
  latitude: number;
  longitude: number;
  waterType: WaterType;
  description: string;
  distance?: number; // 距离用户的米�?
}

// 饵料信息
export interface BaitInfo {
  name: string;
  description: string;
  targetFish: string[];
  season: string;
  icon: string;
}

// 各水域类型的饵料�?
export const BaitDatabase: Record<string, BaitInfo[]> = {
  [WaterType.POND]: [
    { name: '蚯蚓', description: '万能饵，适合池塘小型�?, targetFish: ['鲫鱼', '鲤鱼', '草鱼'], season: '四季', icon: '🪱' },
    { name: '玉米�?, description: '天然谷物饵，鲤鱼最�?, targetFish: ['鲤鱼', '草鱼'], season: '夏秋', icon: '🌽' },
    { name: '红虫', description: '冬季首选，腥味浓郁', targetFish: ['鲫鱼', '鳊鱼'], season: '冬春', icon: '🔴' },
    { name: '商品�?腥香)', description: '池塘通用配方', targetFish: ['鲫鱼', '鲤鱼'], season: '四季', icon: '🎣' },
    { name: '麦粒', description: '经济实惠，草鱼喜�?, targetFish: ['草鱼', '鳊鱼'], season: '夏秋', icon: '🌾' },
  ],
  [WaterType.RESERVOIR]: [
    { name: '活虾', description: '大型鱼类首�?, targetFish: ['鲈鱼', '翘嘴', '鳜鱼'], season: '四季', icon: '🦐' },
    { name: '泥鳅', description: '钓大鱼神�?, targetFish: ['鲶鱼', '黑鱼', '鳜鱼'], season: '夏秋', icon: '🐟' },
    { name: '螺蛳', description: '青鱼专用�?, targetFish: ['青鱼', '鲤鱼'], season: '夏秋', icon: '🐚' },
    { name: '商品�?本味)', description: '水库大物配方', targetFish: ['鲤鱼', '草鱼', '鲢鳙'], season: '四季', icon: '🎣' },
    { name: '玉米发酵�?, description: '守大物必�?, targetFish: ['鲤鱼', '草鱼'], season: '夏秋', icon: '🌽' },
  ],
  [WaterType.RIVER]: [
    { name: '蚯蚓', description: '河流万能�?, targetFish: ['鲫鱼', '鲶鱼', '黄颡�?], season: '四季', icon: '🪱' },
    { name: '河虾', description: '本地河虾效果最�?, targetFish: ['鲈鱼', '翘嘴', '鳜鱼'], season: '夏秋', icon: '🦐' },
    { name: '蛆虫', description: '流水钓效果好', targetFish: ['马口', '白条', '鲫鱼'], season: '夏秋', icon: '🐛' },
    { name: '商品�?浓腥)', description: '河流走水专用', targetFish: ['鲫鱼', '鲤鱼'], season: '四季', icon: '🎣' },
    { name: '面饵', description: '传统钓法常用', targetFish: ['鲫鱼', '鲤鱼'], season: '四季', icon: '🍞' },
  ],
  [WaterType.LAKE]: [
    { name: '活虾', description: '湖泊大鱼首�?, targetFish: ['鲈鱼', '翘嘴', '鳜鱼'], season: '四季', icon: '🦐' },
    { name: '泥鳅', description: '钓大鱼神�?, targetFish: ['鲶鱼', '黑鱼', '鳜鱼'], season: '夏秋', icon: '🐟' },
    { name: '玉米�?, description: '天然谷物�?, targetFish: ['鲤鱼', '草鱼'], season: '夏秋', icon: '🌽' },
    { name: '商品�?本味)', description: '湖泊通用配方', targetFish: ['鲤鱼', '草鱼', '鲢鳙'], season: '四季', icon: '🎣' },
    { name: '蚯蚓', description: '万能饵料', targetFish: ['鲫鱼', '鲤鱼'], season: '四季', icon: '🪱' },
  ]
};
