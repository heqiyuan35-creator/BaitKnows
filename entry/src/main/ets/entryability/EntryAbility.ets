/**
 * 饵知�?- 应用入口
 */
import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { storageService } from '../services/StorageService';
import { LocationService } from '../services/LocationService';
import { MapsInitializer } from '@amap/amap_lbs_map3d';
import { ServiceSettings } from '@amap/amap_lbs_search';
import { AMapPrivacyShowStatus, AMapPrivacyInfoStatus, AMapPrivacyAgreeStatus } from '@amap/amap_lbs_common';
import { AMapConstants } from '../common/AMapConstants';

const DOMAIN = 0x0000;
const TAG = 'BaitKnows';

export default class EntryAbility extends UIAbility {
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    hilog.info(DOMAIN, TAG, 'Ability onCreate');

    // 初始化高德地图SDK
    this.initAMapSDK();

    // 初始化存储服�?
    try {
      await storageService.init(this.context);
      hilog.info(DOMAIN, TAG, 'StorageService initialized');
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'Failed to init StorageService: %{public}s', JSON.stringify(err));
    }

    // 初始化定位服务（提前获取位置�?
    try {
      await LocationService.init(this.context);
      hilog.info(DOMAIN, TAG, 'LocationService initialized');
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'Failed to init LocationService: %{public}s', JSON.stringify(err));
    }
  }

  /**
   * 初始化高德地图SDK
   */
  private initAMapSDK(): void {
    try {
      // 1. 设置隐私政策合规（必须在初始化之前调用）
      ServiceSettings.updatePrivacyShow(
        AMapPrivacyShowStatus.DidShow,
        AMapPrivacyInfoStatus.DidContain,
        this.context
      );
      ServiceSettings.updatePrivacyAgree(AMapPrivacyAgreeStatus.DidAgree, this.context);

      // 2. 设置API Key
      MapsInitializer.setApiKey(AMapConstants.AMAP_API_KEY);

      // 3. 启用3D地形图（需要在MapView创建之前调用�?
      MapsInitializer.setTerrainEnable(true);

      // 4. 开启调试模式（发布时建议关闭）
      MapsInitializer.setDebugMode(true);

      hilog.info(DOMAIN, TAG, 'AMap SDK initialized with 3D terrain enabled');
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'AMap SDK init failed: %{public}s', JSON.stringify(error));
    }
  }

  onDestroy(): void {
    hilog.info(DOMAIN, TAG, 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, TAG, 'Ability onWindowStageCreate');

    // 设置全屏
    windowStage.getMainWindow((err, win) => {
      if (err.code) {
        hilog.error(DOMAIN, TAG, 'Failed to get main window: %{public}s', JSON.stringify(err));
        return;
      }
      // 设置全屏显示
      win.setWindowLayoutFullScreen(true);
    });

    // 加载欢迎�?
    windowStage.loadContent('pages/WelcomePage', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, TAG, 'Failed to load content: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, TAG, 'Content loaded successfully');
    });
  }

  onWindowStageDestroy(): void {
    hilog.info(DOMAIN, TAG, 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(DOMAIN, TAG, 'Ability onForeground');
  }

  onBackground(): void {
    hilog.info(DOMAIN, TAG, 'Ability onBackground');
  }
}
