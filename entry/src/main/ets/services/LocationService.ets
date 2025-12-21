/**
 * 全局定位服务 - 单例模式
 * 在 App 启动时获取位置，供各页面使用
 */
import { geoLocationManager } from '@kit.LocationKit';
import { abilityAccessCtrl, bundleManager, common, Permissions } from '@kit.AbilityKit';

export interface LocationInfo {
  latitude: number;
  longitude: number;
  accuracy?: number;
  isValid: boolean;
}

class LocationServiceClass {
  private TAG = 'LocationService';
  private static instance: LocationServiceClass;
  private _currentLocation: LocationInfo = {
    latitude: 30.5844,  // 默认武汉
    longitude: 114.2986,
    isValid: false
  };
  private _hasPermission: boolean = false;
  private _isLocating: boolean = false;

  private constructor() {}

  static getInstance(): LocationServiceClass {
    if (!LocationServiceClass.instance) {
      LocationServiceClass.instance = new LocationServiceClass();
    }
    return LocationServiceClass.instance;
  }

  get currentLocation(): LocationInfo {
    return this._currentLocation;
  }

  get hasPermission(): boolean {
    return this._hasPermission;
  }

  get isLocating(): boolean {
    return this._isLocating;
  }

  // 初始化定位（在 EntryAbility 中调用）
  async init(context: common.UIAbilityContext): Promise<void> {
    console.info(this.TAG, 'Initializing location service...');
    await this.checkAndRequestPermission(context);
  }

  // 检查并请求权限
  private async checkAndRequestPermission(context: common.UIAbilityContext): Promise<void> {
    try {
      const permission: Permissions = 'ohos.permission.LOCATION';
      const atManager = abilityAccessCtrl.createAtManager();
      const bundleInfo = await bundleManager.getBundleInfoForSelf(
        bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION
      );
      const tokenId = bundleInfo.appInfo.accessTokenId;
      const grantStatus = await atManager.checkAccessToken(tokenId, permission);

      if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        this._hasPermission = true;
        await this.fetchCurrentLocation();
      } else {
        await this.requestPermissions(context);
      }
    } catch (error) {
      console.error(this.TAG, `Permission check failed: ${error}`);
    }
  }

  // 请求权限
  private async requestPermissions(context: common.UIAbilityContext): Promise<void> {
    const permissions: Permissions[] = [
      'ohos.permission.APPROXIMATELY_LOCATION',
      'ohos.permission.LOCATION'
    ];

    try {
      const atManager = abilityAccessCtrl.createAtManager();
      const result = await atManager.requestPermissionsFromUser(context, permissions);
      const allGranted = result.authResults.every(status => status === 0);

      if (allGranted) {
        this._hasPermission = true;
        await this.fetchCurrentLocation();
      } else {
        this._hasPermission = false;
        console.warn(this.TAG, 'Location permission denied');
      }
    } catch (error) {
      console.error(this.TAG, `Request permission failed: ${error}`);
    }
  }

  // 获取当前位置
  async fetchCurrentLocation(): Promise<LocationInfo> {
    if (this._isLocating) {
      return this._currentLocation;
    }

    this._isLocating = true;

    try {
      const request: geoLocationManager.CurrentLocationRequest = {
        priority: geoLocationManager.LocationRequestPriority.FIRST_FIX,
        scenario: geoLocationManager.LocationRequestScenario.UNSET,
        maxAccuracy: 100
      };

      const location = await geoLocationManager.getCurrentLocation(request);
      this._currentLocation = {
        latitude: location.latitude,
        longitude: location.longitude,
        accuracy: location.accuracy,
        isValid: true
      };
      console.info(this.TAG, `Location updated: ${location.latitude}, ${location.longitude}`);
    } catch (error) {
      console.error(this.TAG, `Get location failed: ${error}`);
      this._currentLocation.isValid = false;
    } finally {
      this._isLocating = false;
    }

    return this._currentLocation;
  }
}

export const LocationService = LocationServiceClass.getInstance();
