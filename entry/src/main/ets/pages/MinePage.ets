/**
 * 饵知�?- 我的页面
 * 用户信息、等级系统、功能入�?
 */
import { ThemeColors } from '../theme/ThemeColors';
import { ThemeConstants } from '../theme/ThemeConstants';
import { Router, RouteParams } from '../router/Router';
import { AppConstants } from '../common/constants/AppConstants';
import { router, promptAction } from '@kit.ArkUI';
import { UserProfile, LEVEL_CONFIGS } from '../common/types/UserTypes';
import { userService } from '../services/UserService';
import { userDataService } from '../services/UserDataService';
import { fishingRecordService } from '../services/FishingRecordService';

// 菜单项接�?
interface MenuItem {
  icon: Resource;
  title: string;
  subtitle: string;
  route: string;
}

@Component
export struct MinePage {
  @Prop @Watch('onRefreshTriggerChange') refreshTrigger: number = 0;
  @State profile: UserProfile = new UserProfile();
  @State levelProgress: number = 0;
  @State nextLevelExp: number = 100;
  @State isLoading: boolean = true;
  @State cacheSize: string = '12.5 MB';

  private menuItems: MenuItem[] = [
    { icon: $r('app.media.Recipe'), title: '我的收藏', subtitle: '收藏的配�?, route: AppConstants.ROUTE_FAVORITE },
    { icon: $r('app.media.time'), title: '生成历史', subtitle: '配方生成记录', route: AppConstants.ROUTE_GENERATOR_HISTORY }
  ];

  aboutToAppear(): void {
    this.loadUserData();
  }

  // 页面显示时刷新数据（从其他页面返回时�?
  onPageShow(): void {
    this.loadUserData();
  }

  // 监听刷新触发器变�?
  onRefreshTriggerChange(): void {
    this.loadUserData();
  }

  private async loadUserData(): Promise<void> {
    this.isLoading = true;
    await userService.load();
    await userDataService.load();
    
    // 同步收藏数量
    const favoriteCount = userDataService.getFavoriteRecipes().length;
    if (userService.profile.favoriteCount !== favoriteCount) {
      await userService.updateFavoriteCount(favoriteCount);
    }
    
    this.profile = userService.profile;
    this.levelProgress = userService.getLevelProgress();

    // 计算下一等级所需经验
    const currentConfig = userService.getLevelConfig(this.profile.experience);
    this.nextLevelExp = currentConfig.maxExp;

    this.isLoading = false;
  }

  private getLevelIcon(): string {
    const config = LEVEL_CONFIGS.find(c => c.level === this.profile.level);
    return config?.icon || '🎣';
  }

  build() {
    Column() {
      // 顶部用户信息�?
      this.UserHeader()

      Scroll() {
        Column({ space: ThemeConstants.SPACE_MD }) {
          // 等级卡片
          this.LevelCard()

          // 统计卡片
          this.StatsRow()

          // 功能菜单
          this.MenuSection()

          // 数据管理
          this.DataSection()

          // 关于应用
          this.AboutSection()
        }
        .padding({ bottom: 100 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeColors.BG_PRIMARY)
  }

  @Builder
  UserHeader() {
    Column({ space: ThemeConstants.SPACE_SM }) {
      // 头像
      Row() {
        Text(this.getLevelIcon())
          .fontSize(40)
      }
      .width(80)
      .height(80)
      .backgroundColor(ThemeColors.BG_CARD)
      .borderRadius(40)
      .justifyContent(FlexAlign.Center)
      .border({ width: 3, color: ThemeColors.PRIMARY })

      // 昵称
      Text(this.profile.nickname)
        .fontSize(ThemeConstants.FONT_SIZE_XL)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeColors.TEXT_PRIMARY)

      // 等级称号
      Row({ space: 6 }) {
        Text(this.profile.levelTitle)
          .fontSize(ThemeConstants.FONT_SIZE_SM)
          .fontColor(ThemeColors.PRIMARY_DARK)
          .padding({ left: 8, right: 8, top: 2, bottom: 2 })
          .backgroundColor('rgba(232, 168, 73, 0.2)')
          .borderRadius(4)
      }
    }
    .width('100%')
    .padding({ top: 60, bottom: ThemeConstants.SPACE_MD })
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  LevelCard() {
    Column({ space: 12 }) {
      Row() {
        Column({ space: 2 }) {
          Text('等级进度')
            .fontSize(ThemeConstants.FONT_SIZE_MD)
            .fontWeight(FontWeight.Medium)
            .fontColor(ThemeColors.TEXT_PRIMARY)
          Text(`距离下一等级还需 ${Math.max(0, this.nextLevelExp - this.profile.experience)} 经验`)
            .fontSize(ThemeConstants.FONT_SIZE_XS)
            .fontColor(ThemeColors.TEXT_MUTED)
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        Text(`${this.profile.experience}`)
          .fontSize(ThemeConstants.FONT_SIZE_2XL)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.PRIMARY_DARK)
      }
      .width('100%')

      // 进度�?
      Stack({ alignContent: Alignment.Start }) {
        Row()
          .width('100%')
          .height(10)
          .backgroundColor(ThemeColors.BG_TERTIARY)
          .borderRadius(5)

        Row()
          .width(`${this.levelProgress}%`)
          .height(10)
          .linearGradient({
            direction: GradientDirection.Right,
            colors: [[ThemeColors.PRIMARY, 0], [ThemeColors.GRADIENT_PRIMARY_END, 1]]
          })
          .borderRadius(5)
      }
      .width('100%')

      // 等级图标说明
      Row({ space: 4 }) {
        ForEach(['🎣', '🐟', '🐠', '🦈', '👑'], (icon: string, index: number) => {
          Column({ space: 2 }) {
            Text(icon)
              .fontSize(index < this.profile.level ? 18 : 14)
              .opacity(index < this.profile.level ? 1 : 0.4)
          }
          .layoutWeight(1)
        })
      }
      .width('100%')
      .margin({ top: 4 })
    }
    .width('100%')
    .padding(ThemeConstants.SPACE_MD)
    .margin({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD })
    .backgroundColor(ThemeColors.BG_CARD)
    .borderRadius(ThemeConstants.RADIUS_MD)
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.05)', offsetY: 2 })
  }

  @Builder
  StatsRow() {
    Row({ space: ThemeConstants.SPACE_SM }) {
      this.StatItem('总渔�?, `${this.profile.totalCatch.toFixed(1)}`, 'kg')
      this.StatItem('出钓次数', `${this.profile.totalTrips}`, '�?)
      this.StatItem('我的收藏', `${this.profile.favoriteCount}`, '�?)
    }
    .width('100%')
    .padding({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD })
  }

  @Builder
  StatItem(label: string, value: string, unit: string) {
    Column({ space: 4 }) {
      Row() {
        Text(value)
          .fontSize(ThemeConstants.FONT_SIZE_2XL)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.PRIMARY_DARK)
        Text(unit)
          .fontSize(ThemeConstants.FONT_SIZE_SM)
          .fontColor(ThemeColors.TEXT_SECONDARY)
          .margin({ left: 2, top: 8 })
      }
      Text(label)
        .fontSize(ThemeConstants.FONT_SIZE_XS)
        .fontColor(ThemeColors.TEXT_SECONDARY)
    }
    .layoutWeight(1)
    .padding({ top: 16, bottom: 16 })
    .backgroundColor(ThemeColors.BG_CARD)
    .borderRadius(ThemeConstants.RADIUS_SM)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  MenuSection() {
    Column({ space: 1 }) {
      ForEach(this.menuItems, (item: MenuItem, index: number) => {
        this.MenuItemRow(item, index === 0, index === this.menuItems.length - 1)
      })
    }
    .margin({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD })
    .borderRadius(ThemeConstants.RADIUS_MD)
    .clip(true)
  }

  @Builder
  MenuItemRow(item: MenuItem, isFirst: boolean, isLast: boolean) {
    Row() {
      Image(item.icon)
        .width(24)
        .height(24)
        .fillColor(ThemeColors.PRIMARY)

      Column({ space: 2 }) {
        Text(item.title)
          .fontSize(ThemeConstants.FONT_SIZE_MD)
          .fontColor(ThemeColors.TEXT_PRIMARY)
        Text(item.subtitle)
          .fontSize(ThemeConstants.FONT_SIZE_XS)
          .fontColor(ThemeColors.TEXT_SECONDARY)
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: ThemeConstants.SPACE_MD })

      Blank()

      Text('>')
        .fontSize(ThemeConstants.FONT_SIZE_MD)
        .fontColor(ThemeColors.TEXT_MUTED)
    }
    .width('100%')
    .height(64)
    .padding({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD })
    .backgroundColor(ThemeColors.BG_CARD)
    .onClick(() => {
      Router.push(item.route);
    })
  }

  @Builder
  AboutSection() {
    Column({ space: 1 }) {
      // 版本
      Row() {
        Text('版本')
          .fontSize(ThemeConstants.FONT_SIZE_MD)
          .fontColor(ThemeColors.TEXT_PRIMARY)
        Blank()
        Text(AppConstants.APP_VERSION)
          .fontSize(ThemeConstants.FONT_SIZE_MD)
          .fontColor(ThemeColors.TEXT_SECONDARY)
      }
      .width('100%')
      .height(52)
      .padding({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD })
      .backgroundColor(ThemeColors.BG_CARD)

      // 隐私政策
      Row() {
        Text('隐私政策')
          .fontSize(ThemeConstants.FONT_SIZE_MD)
          .fontColor(ThemeColors.TEXT_PRIMARY)
        Blank()
        Text('>')
          .fontSize(ThemeConstants.FONT_SIZE_MD)
          .fontColor(ThemeColors.TEXT_MUTED)
      }
      .width('100%')
      .height(52)
      .padding({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD })
      .backgroundColor(ThemeColors.BG_CARD)
      .onClick(() => {
        const params = new RouteParams();
        params.title = '隐私政策';
        params.type = 'privacy';
        Router.push('pages/AgreementPage', params);
      })

      // 用户协议
      Row() {
        Text('用户协议')
          .fontSize(ThemeConstants.FONT_SIZE_MD)
          .fontColor(ThemeColors.TEXT_PRIMARY)
        Blank()
        Text('>')
          .fontSize(ThemeConstants.FONT_SIZE_MD)
          .fontColor(ThemeColors.TEXT_MUTED)
      }
      .width('100%')
      .height(52)
      .padding({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD })
      .backgroundColor(ThemeColors.BG_CARD)
      .onClick(() => {
        const params = new RouteParams();
        params.title = '用户协议';
        params.type = 'agreement';
        Router.push('pages/AgreementPage', params);
      })
    }
    .margin({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD })
    .borderRadius(ThemeConstants.RADIUS_MD)
    .clip(true)

    // 应用信息
    Column({ space: ThemeConstants.SPACE_SM }) {
      Text(AppConstants.APP_NAME)
        .fontSize(ThemeConstants.FONT_SIZE_MD)
        .fontWeight(FontWeight.Medium)
        .fontColor(ThemeColors.TEXT_PRIMARY)

      Text(AppConstants.APP_SLOGAN)
        .fontSize(ThemeConstants.FONT_SIZE_XS)
        .fontColor(ThemeColors.TEXT_MUTED)
    }
    .width('100%')
    .padding({ top: ThemeConstants.SPACE_LG })
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  DataSection() {
    Column({ space: 1 }) {
      // 清除缓存
      Row() {
        Column({ space: 2 }) {
          Text('清除缓存')
            .fontSize(ThemeConstants.FONT_SIZE_MD)
            .fontColor(ThemeColors.TEXT_PRIMARY)
          Text(`当前缓存: ${this.cacheSize}`)
            .fontSize(ThemeConstants.FONT_SIZE_XS)
            .fontColor(ThemeColors.TEXT_SECONDARY)
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        Text('清除')
          .fontSize(ThemeConstants.FONT_SIZE_SM)
          .fontColor(ThemeColors.PRIMARY_DARK)
      }
      .width('100%')
      .height(64)
      .padding({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD })
      .backgroundColor(ThemeColors.BG_CARD)
      .onClick(() => {
        this.cacheSize = '0 MB';
        promptAction.showToast({ message: '缓存已清�? });
      })

      // 重置数据
      Row() {
        Column({ space: 2 }) {
          Text('重置数据')
            .fontSize(ThemeConstants.FONT_SIZE_MD)
            .fontColor(ThemeColors.ERROR)
          Text('清除所有本地数�?)
            .fontSize(ThemeConstants.FONT_SIZE_XS)
            .fontColor(ThemeColors.TEXT_SECONDARY)
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        Text('>')
          .fontSize(ThemeConstants.FONT_SIZE_MD)
          .fontColor(ThemeColors.TEXT_MUTED)
      }
      .width('100%')
      .height(64)
      .padding({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD })
      .backgroundColor(ThemeColors.BG_CARD)
      .onClick(() => {
        promptAction.showDialog({
          title: '确认重置',
          message: '此操作将清除所有本地数据，包括配方、记录、收藏等，是否继续？',
          buttons: [
            { text: '取消', color: ThemeColors.TEXT_MUTED },
            { text: '确认重置', color: ThemeColors.ERROR }
          ]
        }).then(async (result) => {
          if (result.index === 1) {
            // 清除所有数�?
            await userDataService.clearAllData();
            await fishingRecordService.clearAllRecords();
            await userService.resetProfile();
            
            // 重新加载用户数据
            await this.loadUserData();
            
            promptAction.showToast({ message: '数据已重�? });
          }
        });
      })
    }
    .margin({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD })
    .borderRadius(ThemeConstants.RADIUS_MD)
    .clip(true)
  }
}
