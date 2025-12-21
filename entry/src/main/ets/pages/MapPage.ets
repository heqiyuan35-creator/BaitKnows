/**
 * 饵知道 - 地图页面
 * 显示周边真实钓点，点击推荐饵料
 */
import { MapComponent, mapCommon, map, site } from '@kit.MapKit';
import { AsyncCallback, BusinessError } from '@kit.BasicServicesKit';
import { router } from '@kit.ArkUI';
import { ThemeColors } from '../theme/ThemeColors';
import { LocationService, LocationInfo } from '../services/LocationService';
import { FishingSpotService } from '../services/FishingSpotService';
import { FishingSpot, BaitInfo, WaterTypeNames, WaterTypeIcons } from '../data/FishingSpotData';

@Entry
@Component
struct MapPage {
  private TAG = 'MapPage';
  private mapOptions?: mapCommon.MapOptions;
  private mapCallback?: AsyncCallback<map.MapComponentController>;
  private mapController?: map.MapComponentController;
  private locationMarker?: map.Marker;
  private spotMarkers: map.Marker[] = [];

  @State isMapReady: boolean = false;
  @State isSearching: boolean = false;
  @State currentLocation: string = '定位中...';
  @State locationInfo: LocationInfo = LocationService.currentLocation;
  @State fishingSpots: FishingSpot[] = [];
  @State showBaitDialog: boolean = false;
  @State selectedSpot: FishingSpot | null = null;
  @State recommendedBaits: BaitInfo[] = [];
  @State clickedLocationName: string = '';  // 点击位置的名称

  aboutToAppear(): void {
    this.locationInfo = LocationService.currentLocation;

    // 用当前位置初始化地图
    this.mapOptions = {
      position: {
        target: {
          latitude: this.locationInfo.latitude,
          longitude: this.locationInfo.longitude
        },
        zoom: 14
      },
      scaleControlsEnabled: true,
      zoomControlsEnabled: true,
      compassControlsEnabled: true
    };

    if (this.locationInfo.isValid) {
      this.currentLocation = '已定位';
    }

    this.mapCallback = async (err, mapController) => {
      if (!err) {
        this.mapController = mapController;
        this.isMapReady = true;

        const eventManager = this.mapController.getEventManager();

        // 地图加载完成
        eventManager.on('mapLoad', () => {
          this.addUserLocationMarker();
          this.searchNearbySpots();
        });

        // 地图点击事件 - 逆地理编码获取地名
        eventManager.on('mapClick', (position: mapCommon.LatLng) => {
          this.onMapClick(position);
        });
      } else {
        console.error(this.TAG, `Map init failed: ${err.code}, ${err.message}`);
      }
    };
  }

  // 地图点击事件处理
  async onMapClick(position: mapCommon.LatLng): Promise<void> {
    console.info(this.TAG, `Map clicked: ${position.latitude}, ${position.longitude}`);
    this.clickedLocationName = '查询中...';

    try {
      const params: site.ReverseGeocodeParams = {
        location: {
          latitude: position.latitude,
          longitude: position.longitude
        },
        language: 'zh',
        radius: 50
      };

      const result = await site.reverseGeocode(params);

      if (result && result.addressComponent) {
        const addr = result.addressComponent;

        // 拼接地址：区 + 街道/道路
        const parts: string[] = [];
        if (addr.adminLevel3) {
          parts.push(addr.adminLevel3);
        }
        if (addr.adminLevel4) {
          parts.push(addr.adminLevel4);
        }

        if (parts.length > 0) {
          this.clickedLocationName = parts.join('');
        } else {
          this.clickedLocationName = `${position.latitude.toFixed(4)}, ${position.longitude.toFixed(4)}`;
        }

        console.info(this.TAG, `Location name: ${this.clickedLocationName}`);
      } else {
        this.clickedLocationName = `${position.latitude.toFixed(4)}, ${position.longitude.toFixed(4)}`;
      }
    } catch (error) {
      const err = error as BusinessError;
      console.error(this.TAG, `Reverse geocode failed: ${err.code}, ${err.message}`);
      this.clickedLocationName = `${position.latitude.toFixed(4)}, ${position.longitude.toFixed(4)}`;
    }
  }

  // 搜索周边真实钓点
  async searchNearbySpots(): Promise<void> {
    if (!this.locationInfo.isValid) return;

    this.isSearching = true;
    this.currentLocation = '搜索钓点中...';

    try {
      this.fishingSpots = await FishingSpotService.searchNearbySpots(
        this.locationInfo.latitude,
        this.locationInfo.longitude,
        5000 // 5km 范围
      );

      // 保存到全局缓存，供首页使用
      FishingSpotService.updateCachedSpots(this.fishingSpots);

      this.currentLocation = `已定位 · 发现 ${this.fishingSpots.length} 个钓点`;

      // 添加钓点标记
      await this.addSpotMarkers();
    } catch (err) {
      console.error(this.TAG, `Search spots failed: ${err}`);
      this.currentLocation = '搜索钓点失败';
    } finally {
      this.isSearching = false;
    }
  }

  // 添加用户位置标记
  async addUserLocationMarker(): Promise<void> {
    if (!this.mapController || !this.locationInfo.isValid) return;

    try {
      // 用户位置标记
      const markerOptions: mapCommon.MarkerOptions = {
        position: {
          latitude: this.locationInfo.latitude,
          longitude: this.locationInfo.longitude
        },
        title: '📍 我的位置',
        snippet: '当前所在位置',
        clickable: true,
        alpha: 1,
        anchorU: 0.5,
        anchorV: 1
      };
      this.locationMarker = await this.mapController.addMarker(markerOptions);

      // 显示信息窗口
      this.locationMarker.setInfoWindowVisible(true);
    } catch (e) {
      console.error(this.TAG, `Add user marker error: ${e}`);
    }
  }

  // 添加钓点标记
  async addSpotMarkers(): Promise<void> {
    if (!this.mapController) return;

    // 清除旧标记
    for (const marker of this.spotMarkers) {
      marker.remove();
    }
    this.spotMarkers = [];

    // 添加新标记
    for (const spot of this.fishingSpots) {
      try {
        const icon = WaterTypeIcons[spot.waterType] || '📍';
        const markerOptions: mapCommon.MarkerOptions = {
          position: {
            latitude: spot.latitude,
            longitude: spot.longitude
          },
          title: `${icon} ${spot.name}`,
          snippet: `${WaterTypeNames[spot.waterType]} · ${FishingSpotService.formatDistance(spot.distance || 0)}`,
          clickable: true
        };

        const marker = await this.mapController.addMarker(markerOptions);
        this.spotMarkers.push(marker);
      } catch (e) {
        console.error(this.TAG, `Add spot marker error: ${e}`);
      }
    }

    // 监听标记点击
    if (this.mapController) {
      const eventManager = this.mapController.getEventManager();
      eventManager.on('markerClick', (clickedMarker: map.Marker) => {
        const clickedSpot = this.fishingSpots.find(s =>
          Math.abs(s.latitude - clickedMarker.getPosition().latitude) < 0.0001 &&
          Math.abs(s.longitude - clickedMarker.getPosition().longitude) < 0.0001
        );
        if (clickedSpot) {
          this.onSpotClick(clickedSpot);
        }
      });
    }
  }

  // 点击钓点
  onSpotClick(spot: FishingSpot): void {
    this.selectedSpot = spot;
    this.recommendedBaits = FishingSpotService.recommendBaits(spot.waterType);
    this.showBaitDialog = true;
  }

  // 刷新位置和钓点
  async refreshLocation(): Promise<void> {
    this.currentLocation = '正在定位...';

    try {
      const location = await LocationService.fetchCurrentLocation();
      this.locationInfo = location;

      if (location.isValid) {
        // 更新用户标记
        if (this.locationMarker) {
          this.locationMarker.remove();
        }
        await this.addUserLocationMarker();
        this.moveToCurrentLocation();
        // 重新搜索钓点
        await this.searchNearbySpots();
      } else {
        this.currentLocation = '定位失败';
      }
    } catch (err) {
      this.currentLocation = '定位失败';
    }
  }

  moveToCurrentLocation(): void {
    if (!this.mapController || !this.locationInfo.isValid) return;
    const position: mapCommon.LatLng = {
      latitude: this.locationInfo.latitude,
      longitude: this.locationInfo.longitude
    };
    const cameraUpdate = map.newLatLng(position, 14);
    this.mapController.animateCamera(cameraUpdate, 500);
  }

  goBack(): void {
    router.back();
  }

  onPageShow(): void {
    if (this.mapController) {
      this.mapController.show();
    }
  }

  onPageHide(): void {
    if (this.mapController) {
      this.mapController.hide();
    }
  }

  build() {
    Stack() {
      Column() {
        // 顶部导航栏
        Row() {
          Image($r('app.media.Left'))
            .width(24)
            .height(24)
            .onClick(() => this.goBack())

          Text('钓点地图')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.TEXT_PRIMARY)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)

          Text('📍')
            .fontSize(20)
            .onClick(() => this.refreshLocation())
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .backgroundColor(ThemeColors.BG_SECONDARY)

        // 钓点数量提示
        Row() {
          Text(this.currentLocation)
            .fontSize(12)
            .fontColor(ThemeColors.TEXT_SECONDARY)
          if (this.isSearching) {
            LoadingProgress()
              .width(16)
              .height(16)
              .margin({ left: 8 })
          }
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        .backgroundColor(ThemeColors.BG_PRIMARY)

        // 点击位置名称显示
        if (this.clickedLocationName) {
          Row() {
            Text('📍 点击位置: ')
              .fontSize(12)
              .fontColor(ThemeColors.TEXT_SECONDARY)
            Text(this.clickedLocationName)
              .fontSize(12)
              .fontColor(ThemeColors.PRIMARY)
              .fontWeight(FontWeight.Medium)
              .layoutWeight(1)
            Text('✕')
              .fontSize(14)
              .fontColor(ThemeColors.TEXT_SECONDARY)
              .onClick(() => { this.clickedLocationName = '' })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 6, bottom: 6 })
          .backgroundColor('#E3F2FD')
        }

        // 地图（全屏）
        Stack() {
          if (this.mapOptions) {
            MapComponent({
              mapOptions: this.mapOptions,
              mapCallback: this.mapCallback
            })
              .width('100%')
              .height('100%')
          }

          if (!this.isMapReady) {
            Column() {
              LoadingProgress().width(48).height(48).color(ThemeColors.PRIMARY)
              Text('地图加载中...').fontSize(14).fontColor(ThemeColors.TEXT_SECONDARY).margin({ top: 12 })
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Center)
            .backgroundColor(ThemeColors.BG_PRIMARY)
          }
        }
        .layoutWeight(1)
        .width('100%')
      }
      .width('100%')
      .height('100%')

      // 饵料推荐弹窗
      if (this.showBaitDialog && this.selectedSpot) {
        this.BaitRecommendDialog()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  BaitRecommendDialog() {
    Column() {
      // 遮罩
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.5)')
        .onClick(() => { this.showBaitDialog = false })
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })

    // 弹窗内容
    Column() {
      // 标题
      Row() {
        Text(`${WaterTypeIcons[this.selectedSpot!.waterType]} ${this.selectedSpot!.name}`)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.TEXT_PRIMARY)
        Blank()
        Text('✕')
          .fontSize(20)
          .fontColor(ThemeColors.TEXT_SECONDARY)
          .onClick(() => { this.showBaitDialog = false })
      }
      .width('100%')
      .margin({ bottom: 8 })

      Text(`${WaterTypeNames[this.selectedSpot!.waterType]} · ${this.selectedSpot!.description}`)
        .fontSize(13)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .margin({ bottom: 16 })

      Divider().color('#eee').margin({ bottom: 16 })

      Text('🎣 推荐饵料')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeColors.TEXT_PRIMARY)
        .margin({ bottom: 12 })

      ForEach(this.recommendedBaits, (bait: BaitInfo) => {
        Row() {
          Text(bait.icon)
            .fontSize(28)
            .margin({ right: 12 })

          Column() {
            Text(bait.name)
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor(ThemeColors.TEXT_PRIMARY)
            Text(bait.description)
              .fontSize(12)
              .fontColor(ThemeColors.TEXT_SECONDARY)
              .margin({ top: 2 })
            Text(`目标鱼: ${bait.targetFish.join('、')}`)
              .fontSize(11)
              .fontColor(ThemeColors.PRIMARY)
              .margin({ top: 4 })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Text(bait.season)
            .fontSize(11)
            .fontColor('#999')
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor('#f5f5f5')
            .borderRadius(4)
        }
        .width('100%')
        .padding(12)
        .backgroundColor(ThemeColors.BG_SECONDARY)
        .borderRadius(8)
        .margin({ bottom: 8 })
      })

      Button('换一批推荐')
        .width('100%')
        .height(44)
        .fontSize(14)
        .backgroundColor(ThemeColors.PRIMARY)
        .fontColor(Color.White)
        .margin({ top: 8 })
        .onClick(() => {
          this.recommendedBaits = FishingSpotService.recommendBaits(this.selectedSpot!.waterType);
        })
    }
    .width('90%')
    .padding(20)
    .backgroundColor(ThemeColors.BG_PRIMARY)
    .borderRadius(16)
    .position({ x: '5%', y: '20%' })
  }
}
