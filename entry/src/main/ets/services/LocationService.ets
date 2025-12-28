/**
 * 全局定位服务 - 单例模式
 * �?App 启动时获取位置，供各页面使用
 */
import { geoLocationManager } from '@kit.LocationKit';
import { abilityAccessCtrl, bundleManager, common, Permissions } from '@kit.AbilityKit';

export interface LocationInfo {
  latitude: number;
  longitude: number;
  accuracy?: number;
  isValid: boolean;
  errorMsg?: string;
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
  private _context: common.UIAbilityContext | null = null;

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

  // 初始化定位（�?EntryAbility 中调用）
  async init(context: common.UIAbilityContext): Promise<void> {
    console.info(this.TAG, 'Initializing location service...');
    this._context = context;
    
    // 先检查定位服务是否开�?
    const isEnabled = await this.checkLocationEnabled();
    if (!isEnabled) {
      console.warn(this.TAG, 'Location service is disabled');
      this._currentLocation.errorMsg = '定位服务未开�?;
      // 使用默认位置，但标记为有效以便地图能显示
      this._currentLocation.isValid = true;
      return;
    }
    
    await this.checkAndRequestPermission(context);
  }

  // 检查定位服务是否开�?
  private async checkLocationEnabled(): Promise<boolean> {
    try {
      return geoLocationManager.isLocationEnabled();
    } catch (error) {
      console.error(this.TAG, `Check location enabled failed: ${error}`);
      return false;
    }
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

      console.info(this.TAG, `Permission status: ${grantStatus}`);

      if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        this._hasPermission = true;
        await this.fetchCurrentLocation();
      } else {
        await this.requestPermissions(context);
      }
    } catch (error) {
      console.error(this.TAG, `Permission check failed: ${error}`);
      // 权限检查失败，使用默认位置
      this._currentLocation.isValid = true;
      this._currentLocation.errorMsg = '权限检查失�?;
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
      
      console.info(this.TAG, `Permission request result: ${JSON.stringify(result.authResults)}`);
      
      const allGranted = result.authResults.every(status => status === 0);

      if (allGranted) {
        this._hasPermission = true;
        await this.fetchCurrentLocation();
      } else {
        this._hasPermission = false;
        console.warn(this.TAG, 'Location permission denied');
        // 权限被拒绝，使用默认位置
        this._currentLocation.isValid = true;
        this._currentLocation.errorMsg = '定位权限被拒�?;
      }
    } catch (error) {
      console.error(this.TAG, `Request permission failed: ${error}`);
      // 请求权限失败，使用默认位�?
      this._currentLocation.isValid = true;
      this._currentLocation.errorMsg = '请求权限失败';
    }
  }

  // 获取当前位置
  async fetchCurrentLocation(): Promise<LocationInfo> {
    if (this._isLocating) {
      return this._currentLocation;
    }

    this._isLocating = true;
    console.info(this.TAG, 'Fetching current location...');

    try {
      // 先检查定位服�?
      const isEnabled = geoLocationManager.isLocationEnabled();
      if (!isEnabled) {
        console.warn(this.TAG, 'Location service is disabled');
        this._currentLocation.isValid = true;  // 使用默认位置
        this._currentLocation.errorMsg = '定位服务未开�?;
        return this._currentLocation;
      }

      const request: geoLocationManager.CurrentLocationRequest = {
        priority: geoLocationManager.LocationRequestPriority.FIRST_FIX,
        scenario: geoLocationManager.LocationRequestScenario.UNSET,
        maxAccuracy: 100,
        timeoutMs: 10000  // 10秒超�?
      };

      console.info(this.TAG, 'Calling getCurrentLocation...');
      const location = await geoLocationManager.getCurrentLocation(request);
      
      this._currentLocation = {
        latitude: location.latitude,
        longitude: location.longitude,
        accuracy: location.accuracy,
        isValid: true
      };
      console.info(this.TAG, `Location updated: ${location.latitude}, ${location.longitude}`);
    } catch (error) {
      const err = error as Error;
      console.error(this.TAG, `Get location failed: ${err.message || error}`);
      
      // 定位失败，使用默认位置但标记为有�?
      this._currentLocation.isValid = true;
      this._currentLocation.errorMsg = `定位失败: ${err.message || '未知错误'}`;
    } finally {
      this._isLocating = false;
    }

    return this._currentLocation;
  }

  // 手动刷新位置（供页面调用�?
  async refreshLocation(): Promise<LocationInfo> {
    // 如果没有权限，尝试重新请�?
    if (!this._hasPermission && this._context) {
      await this.requestPermissions(this._context);
    }
    
    return this.fetchCurrentLocation();
  }
}

export const LocationService = LocationServiceClass.getInstance();
