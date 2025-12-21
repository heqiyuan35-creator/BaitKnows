/**
 * 饵知道 - 应用入口
 */
import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { storageService } from '../services/StorageService';
import { LocationService } from '../services/LocationService';

const DOMAIN = 0x0000;
const TAG = 'BaitKnows';

export default class EntryAbility extends UIAbility {
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    hilog.info(DOMAIN, TAG, 'Ability onCreate');

    // 初始化存储服务
    try {
      await storageService.init(this.context);
      hilog.info(DOMAIN, TAG, 'StorageService initialized');
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'Failed to init StorageService: %{public}s', JSON.stringify(err));
    }

    // 初始化定位服务（提前获取位置）
    try {
      await LocationService.init(this.context);
      hilog.info(DOMAIN, TAG, 'LocationService initialized');
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'Failed to init LocationService: %{public}s', JSON.stringify(err));
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

    // 加载欢迎页
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
