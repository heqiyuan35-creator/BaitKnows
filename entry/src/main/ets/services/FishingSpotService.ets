/**
 * 钓点服务 - 使用华为地图 Site API 搜索真实水域
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
  }

  async searchNearbySpots(userLat: number, userLng: number, radiusMeters: number = 5000): Promise<FishingSpot[]> {
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

              const spot: FishingSpot = {
                id: siteInfo.siteId || `spot_${spots.length}`,
                name: siteInfo.name,
                latitude: siteInfo.location.latitude,
                longitude: siteInfo.location.longitude,
                waterType: waterType,
                description: siteInfo.formatAddress || this.getSpotDescription(waterType),
                distance: Math.round(distance)
              };
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

  private isWaterRelated(name: string): boolean {
    const excludeKeywords = [
      '酒店', '宾馆', '餐厅', '饭店', '超市', '商场', '医院', '学校', '银行', '药店',
      '珠宝', '艺术', 'KTV', '酒吧', '网吧', '营销', '中心', '协会', '公司', '集团',
      '大厦', '广场', '写字楼', '办公', '店', '厅', '馆', '院', '所', '站', '局',
      '路', '街', '道', '巷', '弄', '区', '市', '省', '镇', '村', '社区',
      '小区', '花园', '家园', '苑', '府', '城', '湾'
    ];

    for (const exclude of excludeKeywords) {
      if (name.includes(exclude)) return false;
    }

    const waterPlaceKeywords = [
      '江滩', '河滩', '湖滩', '海滩', '水库', '蓄水池',
      '湖泊', '湖', '潭', '鱼塘', '鱼池', '垂钓', '钓场', '钓鱼', '渔场',
      '湿地', '湿地公园', '江边', '河边', '湖边', '码头', '渡口'
    ];

    for (const keyword of waterPlaceKeywords) {
      if (name.includes(keyword)) return true;
    }
    return false;
  }

  private detectWaterType(name: string, poiTypes: string[]): WaterType {
    const nameAndTypes = name + poiTypes.join(',');

    // 海洋：必须同时包含"海"字，且不能是内陆港口
    // 内陆城市的"港"是河港，不是海港
    if (nameAndTypes.includes('海滩') || nameAndTypes.includes('海湾') ||
        (nameAndTypes.includes('海') && !nameAndTypes.includes('港'))) {
      return WaterType.SEA;
    }

    // 河流：江、河、溪、港（内陆港口属于河流）、码头
    if (nameAndTypes.includes('江') || nameAndTypes.includes('河') ||
        nameAndTypes.includes('溪') || nameAndTypes.includes('港') ||
        nameAndTypes.includes('码头') || nameAndTypes.includes('渡口')) {
      return WaterType.RIVER;
    }

    // 水库/湖泊
    if (nameAndTypes.includes('水库') || nameAndTypes.includes('湖') || nameAndTypes.includes('潭')) {
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
      [WaterType.RIVER]: '流水钓场，鱼口活跃',
      [WaterType.SEA]: '海钓圣地，注意潮汐'
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
