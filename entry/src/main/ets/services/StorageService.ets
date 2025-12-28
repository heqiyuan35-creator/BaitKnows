/**
 * 饵知�?- 存储服务
 */
import { preferences } from '@kit.ArkData';
import { Context } from '@kit.AbilityKit';

class StorageServiceClass {
  private pref: preferences.Preferences | null = null;
  private isInit: boolean = false;
  private static instance: StorageServiceClass;

  private constructor() {}

  static getInstance(): StorageServiceClass {
    if (!StorageServiceClass.instance) {
      StorageServiceClass.instance = new StorageServiceClass();
    }
    return StorageServiceClass.instance;
  }

  async init(context: Context): Promise<void> {
    if (this.isInit) return;
    try {
      this.pref = await preferences.getPreferences(context, 'bait_knows_data');
      this.isInit = true;
      console.info('[StorageService] initialized');
    } catch (error) {
      console.error(`[StorageService] init failed: ${(error as Error).message}`);
    }
  }

  async save<T>(key: string, data: T): Promise<void> {
    if (!this.pref) return;
    try {
      const json = JSON.stringify(data);
      await this.pref.put(key, json);
      await this.pref.flush();
    } catch (error) {
      console.error(`[StorageService] save failed: ${(error as Error).message}`);
    }
  }

  async load<T>(key: string, defaultVal: T): Promise<T> {
    if (!this.pref) return defaultVal;
    try {
      const json = await this.pref.get(key, '') as string;
      if (!json) return defaultVal;
      return JSON.parse(json) as T;
    } catch (error) {
      console.error(`[StorageService] load failed: ${(error as Error).message}`);
      return defaultVal;
    }
  }

  async remove(key: string): Promise<void> {
    if (!this.pref) return;
    try {
      await this.pref.delete(key);
      await this.pref.flush();
    } catch (error) {
      console.error(`[StorageService] remove failed: ${(error as Error).message}`);
    }
  }

  async has(key: string): Promise<boolean> {
    if (!this.pref) return false;
    try {
      return await this.pref.has(key);
    } catch (error) {
      return false;
    }
  }
}

export const storageService = StorageServiceClass.getInstance();
