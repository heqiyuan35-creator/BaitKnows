/**
 * 钓点服务 - 支持华为地图和高德地图搜�?
 */
import { site } from '@kit.MapKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { FishingSpot, WaterType, BaitInfo, BaitDatabase, WaterTypeNames } from '../data/FishingSpotData';

class FishingSpotServiceClass {
  private TAG = 'FishingSpotService';
  private _cachedSpots: FishingSpot[] = [];

  get cachedSpots(): FishingSpot[] {
    return this._cachedSpots;
  }

  updateCachedSpots(spots: FishingSpot[]): void {
    this._cachedSpots = spots;
    console.info(this.TAG, `缓存更新: ${spots.length} 个钓点`);
  }

  // 获取附近钓点（优先使用缓存，如果缓存为空则使用预设数据）
  async searchNearbySpots(userLat: number, userLng: number, radiusMeters: number = 5000): Promise<FishingSpot[]> {
    // 如果已有缓存数据（从地图页获取的），直接返回
    if (this._cachedSpots.length > 0) {
      console.info(this.TAG, `使用缓存数据: ${this._cachedSpots.length} 个钓点`);
      return this._cachedSpots;
    }

    // 尝试使用华为地图 API 搜索
    const spots = await this.searchWithHuaweiMap(userLat, userLng, radiusMeters);
    
    // 如果华为地图搜索失败或无结果，使用预设的真实钓点数据
    if (spots.length === 0) {
      console.info(this.TAG, '华为地图搜索无结果，使用预设钓点数据');
      return this.getPresetSpots(userLat, userLng);
    }

    return spots;
  }

  // 使用华为地图 Site API 搜索
  private async searchWithHuaweiMap(userLat: number, userLng: number, radiusMeters: number): Promise<FishingSpot[]> {
    const spots: FishingSpot[] = [];
    const searchKeywords: string[] = ['江滩', '河滩', '水库', '鱼塘', '钓场', '垂钓', '湿地公园', '湖泊', '码头'];

    for (const keyword of searchKeywords) {
      try {
        const params: site.NearbySearchParams = {
          query: keyword,
          location: { latitude: userLat, longitude: userLng },
          radius: radiusMeters,
          language: 'zh'
        };

        const result = await site.nearbySearch(params);

        if (result && result.sites) {
          for (const siteInfo of result.sites) {
            if (!siteInfo.location || !siteInfo.name) continue;
            if (!this.isWaterRelated(siteInfo.name)) continue;

            const exists = spots.some(s =>
              Math.abs(s.latitude - siteInfo.location!.latitude) < 0.0001 &&
              Math.abs(s.longitude - siteInfo.location!.longitude) < 0.0001
            );

            if (!exists) {
              const waterType = this.detectWaterType(siteInfo.name, siteInfo.poi?.poiTypes || []);
              const distance = this.calculateDistance(userLat, userLng, siteInfo.location.latitude, siteInfo.location.longitude);

              const spot = new FishingSpot();
              spot.id = siteInfo.siteId || `spot_${spots.length}`;
              spot.name = siteInfo.name;
              spot.latitude = siteInfo.location.latitude;
              spot.longitude = siteInfo.location.longitude;
              spot.waterType = waterType;
              spot.description = siteInfo.formatAddress || this.getSpotDescription(waterType);
              spot.distance = Math.round(distance);
              spots.push(spot);
            }
          }
        }
      } catch (error) {
        const err = error as BusinessError;
        console.error(this.TAG, `Search ${keyword} failed: ${err.code}, ${err.message}`);
      }
    }

    spots.sort((a, b) => (a.distance || 0) - (b.distance || 0));
    return spots.slice(0, 20);
  }

  // 创建钓点辅助函数
  private createSpot(id: string, name: string, lat: number, lng: number, waterType: string, desc: string): FishingSpot {
    const spot = new FishingSpot();
    spot.id = id;
    spot.name = name;
    spot.latitude = lat;
    spot.longitude = lng;
    spot.waterType = waterType;
    spot.description = desc;
    return spot;
  }

  // 获取预设的真实钓点数据（武汉地区）
  private getPresetSpots(userLat: number, userLng: number): FishingSpot[] {
    const realSpots: FishingSpot[] = [
      this.createSpot('preset_1', '东湖落雁景区', 30.5547, 114.4283, WaterType.RESERVOIR, '东湖最大的湖汊，水质好，鱼种丰富'),
      this.createSpot('preset_2', '东湖磨山景区', 30.5489, 114.4089, WaterType.RESERVOIR, '风景优美，适合休闲垂钓'),
      this.createSpot('preset_3', '东湖听涛景区', 30.5612, 114.3856, WaterType.RESERVOIR, '交通便利，岸边钓位多'),
      this.createSpot('preset_4', '沙湖公园', 30.5734, 114.3412, WaterType.POND, '市区内钓场，适合休闲'),
      this.createSpot('preset_5', '汤逊湖', 30.4523, 114.3678, WaterType.RESERVOIR, '武汉最大城中湖，大物频出'),
      this.createSpot('preset_6', '汉口江滩', 30.5912, 114.2934, WaterType.RIVER, '长江钓场，鱼口活跃'),
      this.createSpot('preset_7', '武昌江滩', 30.5523, 114.3123, WaterType.RIVER, '江边钓位，注意安全'),
      this.createSpot('preset_8', '墨水湖', 30.5234, 114.2156, WaterType.POND, '汉阳区钓场，鲫鱼多'),
      this.createSpot('preset_9', '南湖', 30.5089, 114.3534, WaterType.POND, '洪山区湖泊，环境优美'),
      this.createSpot('preset_10', '后官湖', 30.4912, 114.1234, WaterType.RESERVOIR, '蔡甸区大型水库，鱼种多'),
      this.createSpot('preset_11', '严西湖', 30.5234, 114.4789, WaterType.RESERVOIR, '光谷附近，水质清澈'),
      this.createSpot('preset_12', '梁子湖', 30.2567, 114.5234, WaterType.RESERVOIR, '武汉最大淡水湖，野钓圣地')
    ];

    // 计算每个钓点到用户的距离
    realSpots.forEach(spot => {
      spot.distance = Math.round(this.calculateDistance(userLat, userLng, spot.latitude, spot.longitude));
    });

    // 按距离排序，取最近的10�?
    realSpots.sort((a, b) => (a.distance || 0) - (b.distance || 0));
    return realSpots.slice(0, 10);
  }

  private isWaterRelated(name: string): boolean {
    // 第一步：严格排除非钓点（优先级最高）
    const strictExcludeKeywords = [
      // 公共设施
      '厕所', '卫生�?, '洗手�?, '公厕', '公共厕所',
      // 美容美发
      '护肤', '美肤', '美容', '美发', '理发', 'SPA', 'spa', '造型', '时尚',
      // 餐饮（包括各种店铺形式）
      '火锅', '烧烤', '餐厅', '饭店', '酒楼', '食堂', '小吃', '面馆', '串串', '烤肉',
      '咖啡', '奶茶', '甜品', '蛋糕', '快餐', '外卖', '美食', '酒吧', '酒店', '宾馆',
      '热炼', '饭橘', '分店', '连锁', '加盟',
      // 商业服务
      '超市', '商场', '购物', '专卖', '批发', '零售', '银行', '药店',
      // 教育医疗
      '医院', '诊所', '学校', '幼儿�?, '学院', '大学', '培训',
      // 停车交�?
      '停车�?, '停车', '加油�?, '充电�?,
      // 运动娱乐（非钓鱼�?
      '跳伞', '蹦极', 'KTV', '网吧', '游戏', '电影', '健身', '游泳�?,
      '划船', '皮划�?, '赛艇', '训练基地', '俱乐�?,
      // 企业行政
      '公司', '集团', '大厦', '广场', '写字�?, '办公', '营销', '中心',
      // 住宅
      '小区', '花园', '家园', '�?, '�?, '公寓', '民宿'
    ];

    for (const exclude of strictExcludeKeywords) {
      if (name.includes(exclude)) return false;
    }

    // 第二步：排除�?�?字的（基本都是商铺）
    if (name.includes('�?)) return false;

    // 第三步：必须包含真正的钓�?水域关键�?
    const realFishingKeywords = [
      // 钓鱼专用（最可靠�?
      '垂钓', '钓场', '钓鱼', '渔场', '鱼塘', '鱼池', '钓园', '渔具',
      // 自然水域
      '江滩', '河滩', '湖滩', '水库',
      '湿地公园', '湿地',
      // �?�?但不是其他用途的
      '鱼塘', '荷塘', '莲塘'
    ];

    // 优先匹配钓鱼专用关键�?
    for (const keyword of realFishingKeywords) {
      if (name.includes(keyword)) return true;
    }

    // 第四步：对于通用水域词（湖、河、江等），需要更严格判断
    // 必须�?XX�?�?XX�?这种地名形式
    const waterBodyPatterns = [
      /�?/,      // �?�?结尾：东湖、南�?
      /�?/,      // �?�?结尾
      /�?/,      // �?�?结尾
      /�?/,      // �?�?结尾
      /�?/,      // �?�?结尾：垂柳塘
      /�?/,      // �?�?结尾
      /�?/,      // �?�?结尾（内陆河港）
      /渡口$/     // �?渡口"结尾
    ];

    for (const pattern of waterBodyPatterns) {
      if (pattern.test(name)) return true;
    }

    return false;
  }

  private detectWaterType(name: string, poiTypes: string[]): WaterType {
    const nameAndTypes = name + poiTypes.join(',');

    // 湖泊
    if (nameAndTypes.includes('�?) || nameAndTypes.includes('�?)) {
      return WaterType.LAKE;
    }

    // 河流：江、河、溪、港（内陆港口属于河流）、码�?
    if (nameAndTypes.includes('�?) || nameAndTypes.includes('�?) ||
        nameAndTypes.includes('�?) || nameAndTypes.includes('�?) ||
        nameAndTypes.includes('码头') || nameAndTypes.includes('渡口')) {
      return WaterType.RIVER;
    }

    // 水库
    if (nameAndTypes.includes('水库')) {
      return WaterType.RESERVOIR;
    }

    // 默认池塘
    return WaterType.POND;
  }

  private calculateDistance(lat1: number, lng1: number, lat2: number, lng2: number): number {
    const R = 6371000;
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLng = (lng2 - lng1) * Math.PI / 180;
    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
      Math.sin(dLng / 2) * Math.sin(dLng / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
  }

  private getSpotDescription(type: WaterType): string {
    const descriptions: Record<string, string> = {
      [WaterType.POND]: '适合休闲垂钓',
      [WaterType.RESERVOIR]: '水域开阔，适合守钓',
      [WaterType.RIVER]: '流水钓场，鱼口活�?,
      [WaterType.LAKE]: '湖泊钓场，鱼种丰�?
    };
    return descriptions[type] || '钓点环境良好';
  }

  recommendBaits(waterType: WaterType): BaitInfo[] {
    const allBaits = BaitDatabase[waterType] || [];
    if (allBaits.length === 0) return [];
    const shuffled = [...allBaits].sort(() => Math.random() - 0.5);
    const count = Math.min(Math.floor(Math.random() * 2) + 2, shuffled.length);
    return shuffled.slice(0, count);
  }

  getWaterTypeName(type: WaterType): string {
    return WaterTypeNames[type] || '未知';
  }

  formatDistance(meters: number): string {
    if (meters < 1000) return `${meters}米`;
    return `${(meters / 1000).toFixed(1)}公里`;
  }
}

export const FishingSpotService = new FishingSpotServiceClass();
