/**
 * 高德地图配置常量
 * 请替换为你在高德开放平台申请的Key
 * 申请地址: https://lbs.amap.com/
 */
export class AMapConstants {
  /**
   * 高德地图API Key
   */
  static readonly AMAP_API_KEY: string = "6f356712f041528b048e8e12d23043bd";

  /**
   * 默认地图中心点（武汉�?
   */
  static readonly DEFAULT_CENTER_LAT: number = 30.5928;
  static readonly DEFAULT_CENTER_LNG: number = 114.3055;

  /**
   * 默认缩放级别
   */
  static readonly DEFAULT_ZOOM: number = 13;

  /**
   * 地图视图名称
   */
  static readonly MAP_VIEW_NAME: string = 'BaitKnowsMap';

  /**
   * POI搜索半径（米�?
   */
  static readonly SEARCH_RADIUS: number = 5000;
}
