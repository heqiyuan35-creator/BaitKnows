/**
 * 饵知�?- 渔获记录服务
 * 管理渔获记录的增删改�?
 */
import { FishingRecord } from '../common/types/UserTypes';
import { storageService } from './StorageService';
import { userService } from './UserService';
import { AppConstants } from '../common/constants/AppConstants';

class FishingRecordServiceClass {
  private _records: FishingRecord[] = [];
  private _isLoaded: boolean = false;

  get records(): FishingRecord[] {
    return this._records;
  }

  get isLoaded(): boolean {
    return this._isLoaded;
  }

  /**
   * 加载所有记�?
   */
  async load(): Promise<FishingRecord[]> {
    if (this._isLoaded) {
      return this._records;
    }

    const saved = await storageService.load<FishingRecord[]>(
      AppConstants.STORAGE_RECORDS,
      []
    );

    this._records = saved || [];
    // 按日期倒序排列
    this._records.sort((a, b) => b.date - a.date);
    this._isLoaded = true;

    return this._records;
  }

  /**
   * 保存所有记�?
   */
  private async save(): Promise<void> {
    await storageService.save(AppConstants.STORAGE_RECORDS, this._records);
  }

  /**
   * 添加记录
   */
  async addRecord(record: FishingRecord): Promise<FishingRecord> {
    // 确保有ID
    if (!record.id) {
      record.id = `record_${Date.now()}_${Math.random().toString(36).substring(2, 6)}`;
    }
    record.createTime = Date.now();
    record.updateTime = Date.now();

    // 计算最大单尾（如果未设置，默认为总重�?数量�?
    if (record.maxSingle <= 0 && record.count > 0) {
      record.maxSingle = Math.round((record.weight / record.count) * 100) / 100;
    }

    this._records.unshift(record);
    await this.save();

    // 更新用户统计
    await userService.onRecordAdded(record);

    return record;
  }

  /**
   * 更新记录
   */
  async updateRecord(record: FishingRecord): Promise<boolean> {
    const index = this._records.findIndex(r => r.id === record.id);
    if (index < 0) {
      return false;
    }

    const oldRecord = this._records[index];
    record.updateTime = Date.now();
    this._records[index] = record;

    // 重新排序
    this._records.sort((a, b) => b.date - a.date);
    await this.save();

    // 重新计算用户统计
    await userService.recalculateFromRecords(this._records);

    return true;
  }

  /**
   * 删除记录
   */
  async deleteRecord(recordId: string): Promise<boolean> {
    const index = this._records.findIndex(r => r.id === recordId);
    if (index < 0) {
      return false;
    }

    const deletedRecord = this._records[index];
    this._records.splice(index, 1);
    await this.save();

    // 更新用户统计
    await userService.onRecordDeleted(deletedRecord);

    return true;
  }

  /**
   * 根据ID获取记录
   */
  getRecordById(recordId: string): FishingRecord | null {
    const record = this._records.find(r => r.id === recordId);
    return record || null;
  }

  /**
   * 获取统计数据
   */
  getStatistics(): RecordStatistics {
    const stats = new RecordStatistics();

    if (this._records.length === 0) {
      return stats;
    }

    let totalWeight = 0;
    let totalCount = 0;
    let maxSingle = 0;
    let monthTrips = 0;

    const now = new Date();
    const currentMonth = now.getMonth();
    const currentYear = now.getFullYear();

    for (const record of this._records) {
      totalWeight += record.weight;
      totalCount += record.count;

      if (record.maxSingle > maxSingle) {
        maxSingle = record.maxSingle;
      }

      // 统计本月出钓次数
      const recordDate = new Date(record.date);
      if (recordDate.getMonth() === currentMonth && recordDate.getFullYear() === currentYear) {
        monthTrips++;
      }
    }

    stats.totalWeight = Math.round(totalWeight * 10) / 10;
    stats.totalCount = totalCount;
    stats.maxSingle = Math.round(maxSingle * 10) / 10;
    stats.monthTrips = monthTrips;
    stats.totalTrips = this._records.length;

    return stats;
  }

  /**
   * 获取最近N条记�?
   */
  getRecentRecords(limit: number = 10): FishingRecord[] {
    return this._records.slice(0, limit);
  }

  /**
   * 按鱼种筛�?
   */
  filterByFish(fishName: string): FishingRecord[] {
    if (!fishName) {
      return this._records;
    }
    return this._records.filter(r => r.fishName === fishName);
  }

  /**
   * 按日期范围筛�?
   */
  filterByDateRange(startDate: number, endDate: number): FishingRecord[] {
    return this._records.filter(r => r.date >= startDate && r.date <= endDate);
  }

  /**
   * 按钓点搜�?
   */
  searchByLocation(keyword: string): FishingRecord[] {
    if (!keyword || !keyword.trim()) {
      return this._records;
    }
    const lowerKeyword = keyword.toLowerCase().trim();
    return this._records.filter(r =>
      r.location && r.location.toLowerCase().includes(lowerKeyword)
    );
  }

  /**
   * 获取所有钓点列表（去重�?
   */
  getAllLocations(): string[] {
    const locations = new Set<string>();
    for (const record of this._records) {
      if (record.location && record.location.trim()) {
        locations.add(record.location.trim());
      }
    }
    return Array.from(locations).sort();
  }

  /**
   * 获取所有鱼种列表（去重�?
   */
  getAllFishNames(): string[] {
    const fishNames = new Set<string>();
    for (const record of this._records) {
      if (record.fishName && record.fishName.trim()) {
        fishNames.add(record.fishName.trim());
      }
    }
    return Array.from(fishNames).sort();
  }

  /**
   * 组合筛选（鱼种 + 日期范围 + 钓点�?
   */
  filterRecords(fishName?: string, startDate?: number, endDate?: number, location?: string): FishingRecord[] {
    let result = this._records;

    if (fishName && fishName.trim()) {
      result = result.filter(r => r.fishName === fishName);
    }

    if (startDate && startDate > 0) {
      result = result.filter(r => r.date >= startDate);
    }

    if (endDate && endDate > 0) {
      result = result.filter(r => r.date <= endDate);
    }

    if (location && location.trim()) {
      const lowerLocation = location.toLowerCase().trim();
      result = result.filter(r =>
        r.location && r.location.toLowerCase().includes(lowerLocation)
      );
    }

    return result;
  }

  /**
   * 强制重新加载数据
   */
  async reload(): Promise<FishingRecord[]> {
    this._isLoaded = false;
    return this.load();
  }

  /**
   * 清除所有记�?
   */
  async clearAllRecords(): Promise<void> {
    this._records = [];
    this._isLoaded = false;  // 重置加载标志
    await this.save();
    console.info('[FishingRecordService] All records cleared');
  }
}

// 统计数据�?
export class RecordStatistics {
  totalWeight: number = 0;
  totalCount: number = 0;
  maxSingle: number = 0;
  monthTrips: number = 0;
  totalTrips: number = 0;

  constructor() {}
}

export const fishingRecordService = new FishingRecordServiceClass();
