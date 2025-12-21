/**
 * 钓点数据 - 水域类型和钓点信息
 */

// 水域类型
export enum WaterType {
  POND = 'pond',           // 池塘
  RESERVOIR = 'reservoir', // 水库
  RIVER = 'river',         // 河流
  SEA = 'sea'              // 海洋
}

// 水域类型中文名
export const WaterTypeNames: Record<string, string> = {
  [WaterType.POND]: '池塘',
  [WaterType.RESERVOIR]: '水库',
  [WaterType.RIVER]: '河流',
  [WaterType.SEA]: '海洋'
};

// 水域类型图标 (emoji版本，用于标记点等)
export const WaterTypeIcons: Record<string, string> = {
  [WaterType.POND]: '🏞️',
  [WaterType.RESERVOIR]: '💧',
  [WaterType.RIVER]: '🌊',
  [WaterType.SEA]: '🌅'
};

// 水域类型图片资源 - 统一使用波浪图标
export interface WaterTypeImageResource {
  normal: Resource;
  active: Resource;
}

export const WaterTypeImages: Record<string, WaterTypeImageResource> = {
  [WaterType.POND]: { normal: $r('app.media.River'), active: $r('app.media.Rivers') },
  [WaterType.RESERVOIR]: { normal: $r('app.media.River'), active: $r('app.media.Rivers') },
  [WaterType.RIVER]: { normal: $r('app.media.River'), active: $r('app.media.Rivers') },
  [WaterType.SEA]: { normal: $r('app.media.River'), active: $r('app.media.Rivers') }
};

// 钓点信息
export interface FishingSpot {
  id: string;
  name: string;
  latitude: number;
  longitude: number;
  waterType: WaterType;
  description: string;
  distance?: number; // 距离用户的米数
}

// 饵料信息
export interface BaitInfo {
  name: string;
  description: string;
  targetFish: string[];
  season: string;
  icon: string;
}

// 各水域类型的饵料库
export const BaitDatabase: Record<string, BaitInfo[]> = {
  [WaterType.POND]: [
    { name: '蚯蚓', description: '万能饵，适合池塘小型鱼', targetFish: ['鲫鱼', '鲤鱼', '草鱼'], season: '四季', icon: '🪱' },
    { name: '玉米粒', description: '天然谷物饵，鲤鱼最爱', targetFish: ['鲤鱼', '草鱼'], season: '夏秋', icon: '🌽' },
    { name: '红虫', description: '冬季首选，腥味浓郁', targetFish: ['鲫鱼', '鳊鱼'], season: '冬春', icon: '🔴' },
    { name: '商品饵(腥香)', description: '池塘通用配方', targetFish: ['鲫鱼', '鲤鱼'], season: '四季', icon: '🎣' },
    { name: '麦粒', description: '经济实惠，草鱼喜欢', targetFish: ['草鱼', '鳊鱼'], season: '夏秋', icon: '🌾' },
  ],
  [WaterType.RESERVOIR]: [
    { name: '活虾', description: '大型鱼类首选', targetFish: ['鲈鱼', '翘嘴', '鳜鱼'], season: '四季', icon: '🦐' },
    { name: '泥鳅', description: '钓大鱼神器', targetFish: ['鲶鱼', '黑鱼', '鳜鱼'], season: '夏秋', icon: '🐟' },
    { name: '螺蛳', description: '青鱼专用饵', targetFish: ['青鱼', '鲤鱼'], season: '夏秋', icon: '🐚' },
    { name: '商品饵(本味)', description: '水库大物配方', targetFish: ['鲤鱼', '草鱼', '鲢鳙'], season: '四季', icon: '🎣' },
    { name: '玉米发酵饵', description: '守大物必备', targetFish: ['鲤鱼', '草鱼'], season: '夏秋', icon: '🌽' },
  ],
  [WaterType.RIVER]: [
    { name: '蚯蚓', description: '河流万能饵', targetFish: ['鲫鱼', '鲶鱼', '黄颡鱼'], season: '四季', icon: '🪱' },
    { name: '河虾', description: '本地河虾效果最佳', targetFish: ['鲈鱼', '翘嘴', '鳜鱼'], season: '夏秋', icon: '🦐' },
    { name: '蛆虫', description: '流水钓效果好', targetFish: ['马口', '白条', '鲫鱼'], season: '夏秋', icon: '🐛' },
    { name: '商品饵(浓腥)', description: '河流走水专用', targetFish: ['鲫鱼', '鲤鱼'], season: '四季', icon: '🎣' },
    { name: '面饵', description: '传统钓法常用', targetFish: ['鲫鱼', '鲤鱼'], season: '四季', icon: '🍞' },
  ],
  [WaterType.SEA]: [
    { name: '沙蚕', description: '海钓万能饵', targetFish: ['黑鲷', '黄鳍鲷', '石斑'], season: '四季', icon: '🪱' },
    { name: '虾肉', description: '近海矶钓常用', targetFish: ['黑鲷', '真鲷', '石斑'], season: '四季', icon: '🦐' },
    { name: '鱿鱼条', description: '船钓深海鱼', targetFish: ['带鱼', '鲈鱼', '石斑'], season: '四季', icon: '🦑' },
    { name: '小鱼', description: '路亚活饵', targetFish: ['海鲈', '金枪鱼', '鲅鱼'], season: '夏秋', icon: '🐟' },
    { name: '贝肉', description: '礁石区效果好', targetFish: ['黑鲷', '石鲷', '石斑'], season: '四季', icon: '🦪' },
  ]
};
