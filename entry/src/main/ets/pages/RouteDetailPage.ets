/**
 * 路线详情页 - 显示到钓点的路线规划
 */
import { MapComponent, mapCommon, map, navi } from '@kit.MapKit';
import { AsyncCallback, BusinessError } from '@kit.BasicServicesKit';
import { router } from '@kit.ArkUI';
import { ThemeColors } from '../theme/ThemeColors';
import { LocationService } from '../services/LocationService';
import { FishingSpotService } from '../services/FishingSpotService';
import { FishingSpot, WaterTypeNames, WaterTypeIcons } from '../data/FishingSpotData';

interface RouteParams {
  spotId: string;
}

interface RouteInfo {
  distance: number;
  duration: number;
  type: string;
}

@Entry
@Component
struct RouteDetailPage {
  private TAG = 'RouteDetailPage';
  private mapOptions?: mapCommon.MapOptions;
  private mapCallback?: AsyncCallback<map.MapComponentController>;
  private mapController?: map.MapComponentController;
  private currentPolyline?: map.MapPolyline;  // 保存当前路线引用

  @State spot: FishingSpot | null = null;
  @State isMapReady: boolean = false;
  @State isLoading: boolean = true;
  @State selectedRouteType: string = 'driving';
  @State routeInfo: RouteInfo | null = null;
  @State routeDistance: number = 0;
  @State routeDuration: number = 0;

  aboutToAppear(): void {
    const params = router.getParams() as RouteParams;
    if (params && params.spotId) {
      this.spot = FishingSpotService.cachedSpots.find(s => s.id === params.spotId) || null;
    }

    if (!this.spot) return;

    const userLocation = LocationService.currentLocation;
    const centerLat = (userLocation.latitude + this.spot.latitude) / 2;
    const centerLng = (userLocation.longitude + this.spot.longitude) / 2;

    this.mapOptions = {
      position: {
        target: { latitude: centerLat, longitude: centerLng },
        zoom: 13
      },
      scaleControlsEnabled: true,
      zoomControlsEnabled: true
    };

    this.mapCallback = async (err, mapController) => {
      if (!err) {
        this.mapController = mapController;
        this.isMapReady = true;

        const eventManager = this.mapController.getEventManager();
        eventManager.on('mapLoad', () => {
          this.addMarkers();
          this.calculateRoute();
        });
      }
    };
  }

  async addMarkers(): Promise<void> {
    if (!this.mapController || !this.spot) return;

    const userLocation = LocationService.currentLocation;

    await this.mapController.addMarker({
      position: { latitude: userLocation.latitude, longitude: userLocation.longitude },
      title: '📍 我的位置',
      snippet: '出发点',
      clickable: true
    });

    await this.mapController.addMarker({
      position: { latitude: this.spot.latitude, longitude: this.spot.longitude },
      title: `🎣 ${this.spot.name}`,
      snippet: '目的地',
      clickable: true
    });
  }

  async calculateRoute(): Promise<void> {
    if (!this.spot) return;

    this.isLoading = true;
    const userLocation = LocationService.currentLocation;

    // 清除旧路线
    if (this.currentPolyline) {
      this.currentPolyline.remove();
      this.currentPolyline = undefined;
    }

    try {
      let result: navi.RouteResult;

      if (this.selectedRouteType === 'driving') {
        const params: navi.DrivingRouteParams = {
          origins: [{ latitude: userLocation.latitude, longitude: userLocation.longitude }],
          destination: { latitude: this.spot.latitude, longitude: this.spot.longitude },
          language: 'zh_CN'
        };
        result = await navi.getDrivingRoutes(params);
      } else if (this.selectedRouteType === 'walking') {
        const params: navi.RouteParams = {
          origins: [{ latitude: userLocation.latitude, longitude: userLocation.longitude }],
          destination: { latitude: this.spot.latitude, longitude: this.spot.longitude },
          language: 'zh_CN'
        };
        result = await navi.getWalkingRoutes(params);
      } else {
        const params: navi.RouteParams = {
          origins: [{ latitude: userLocation.latitude, longitude: userLocation.longitude }],
          destination: { latitude: this.spot.latitude, longitude: this.spot.longitude },
          language: 'zh_CN'
        };
        result = await navi.getCyclingRoutes(params);
      }

      // 打印完整结果查看结构
      console.info(this.TAG, `Route result: ${JSON.stringify(result)}`);

      // 解析路线结果
      if (result && result.routes && result.routes.length > 0) {
        const route = result.routes[0];
        console.info(this.TAG, `First route: ${JSON.stringify(route)}`);

        // 从路线中提取路线点
        await this.parseRouteAndDraw(result);
      } else {
        console.warn(this.TAG, 'No routes found');
        await this.useEstimatedRoute();
      }
    } catch (error) {
      const err = error as BusinessError;
      console.error(this.TAG, `Route calculation failed: ${err.code}, ${err.message}`);
      await this.useEstimatedRoute();
    } finally {
      this.isLoading = false;
    }
  }

  // 解析路线结果并绘制
  async parseRouteAndDraw(result: navi.RouteResult): Promise<void> {
    const routePoints: mapCommon.LatLng[] = [];

    try {
      const resultStr = JSON.stringify(result);

      // 从 polyline 数组中提取点
      // 结构: routes[].steps[].roads[].polyline[{latitude, longitude}]
      const polylinePattern = /"polyline"\s*:\s*\[([\s\S]*?)\]/g;
      let polylineMatch: RegExpExecArray | null;

      while ((polylineMatch = polylinePattern.exec(resultStr)) !== null) {
        const polylineContent = polylineMatch[1];

        // 从每个 polyline 中提取经纬度
        const pointPattern = /\{\s*"longitude"\s*:\s*([\d.]+)\s*,\s*"latitude"\s*:\s*([\d.]+)\s*\}/g;
        let pointMatch: RegExpExecArray | null;

        while ((pointMatch = pointPattern.exec(polylineContent)) !== null) {
          const lng = parseFloat(pointMatch[1]);
          const lat = parseFloat(pointMatch[2]);

          if (lat > 0 && lng > 0) {
            // 避免连续重复点
            const lastPoint = routePoints.length > 0 ? routePoints[routePoints.length - 1] : null;
            if (!lastPoint ||
              Math.abs(lastPoint.latitude - lat) > 0.000001 ||
              Math.abs(lastPoint.longitude - lng) > 0.000001) {
              routePoints.push({ latitude: lat, longitude: lng });
            }
          }
        }
      }

      console.info(this.TAG, `Extracted ${routePoints.length} route points`);

      // 提取总距离和时间（从 roads 中累加）
      let totalDistance = 0;
      let totalDuration = 0;

      const distancePattern = /"distance"\s*:\s*([\d.]+)/g;
      const durationPattern = /"duration"\s*:\s*(\d+)/g;

      let distMatch: RegExpExecArray | null;
      while ((distMatch = distancePattern.exec(resultStr)) !== null) {
        totalDistance += parseFloat(distMatch[1]);
      }

      let durMatch: RegExpExecArray | null;
      while ((durMatch = durationPattern.exec(resultStr)) !== null) {
        totalDuration += parseInt(durMatch[1]);
      }

      // 距离可能重复计算了，取合理值
      this.routeDistance = totalDistance > 0 ? Math.round(totalDistance / 2) : (this.spot?.distance || 0);
      this.routeDuration = totalDuration > 0 ? Math.round(totalDuration / 2) : this.estimateDuration(this.routeDistance);

      // 如果距离太大，使用直线距离
      if (this.routeDistance > (this.spot?.distance || 0) * 3) {
        this.routeDistance = this.spot?.distance || 0;
        this.routeDuration = this.estimateDuration(this.routeDistance);
      }

      this.routeInfo = {
        distance: this.routeDistance,
        duration: this.routeDuration,
        type: this.selectedRouteType
      };

      // 绘制路线
      if (routePoints.length >= 2) {
        console.info(this.TAG, `Drawing route with ${routePoints.length} points`);
        await this.drawPolyline(routePoints);
      } else {
        console.warn(this.TAG, 'Not enough points, drawing simple line');
        await this.drawSimpleLine();
      }
    } catch (e) {
      console.error(this.TAG, `Parse route error: ${e}`);
      await this.useEstimatedRoute();
    }
  }

  // 使用估算路线（直线）
  async useEstimatedRoute(): Promise<void> {
    this.routeDistance = this.spot?.distance || 0;
    this.routeDuration = this.estimateDuration(this.routeDistance);

    this.routeInfo = {
      distance: this.routeDistance,
      duration: this.routeDuration,
      type: this.selectedRouteType
    };

    await this.drawSimpleLine();
  }

  // 绘制折线路线
  async drawPolyline(points: mapCommon.LatLng[]): Promise<void> {
    if (!this.mapController || points.length < 2) return;

    try {
      // 清除旧路线
      if (this.currentPolyline) {
        this.currentPolyline.remove();
      }

      const polylineOptions: mapCommon.MapPolylineOptions = {
        points: points,
        clickable: false,
        geodesic: false,
        width: 8,
        color: 0xFF4285F4
      };

      this.currentPolyline = await this.mapController.addPolyline(polylineOptions);

      // 调整视野显示整条路线
      this.fitBounds(points);
    } catch (e) {
      console.error(this.TAG, `Draw polyline error: ${e}`);
    }
  }

  // 绘制简单直线
  async drawSimpleLine(): Promise<void> {
    if (!this.mapController || !this.spot) return;

    const userLocation = LocationService.currentLocation;
    const points: mapCommon.LatLng[] = [
      { latitude: userLocation.latitude, longitude: userLocation.longitude },
      { latitude: this.spot.latitude, longitude: this.spot.longitude }
    ];

    await this.drawPolyline(points);
  }

  // 调整地图视野
  fitBounds(points: mapCommon.LatLng[]): void {
    if (!this.mapController || points.length === 0) return;

    let minLat = points[0].latitude;
    let maxLat = points[0].latitude;
    let minLng = points[0].longitude;
    let maxLng = points[0].longitude;

    for (const p of points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    const centerLat = (minLat + maxLat) / 2;
    const centerLng = (minLng + maxLng) / 2;

    // 根据范围计算合适的缩放级别
    const latDiff = maxLat - minLat;
    const lngDiff = maxLng - minLng;
    const maxDiff = Math.max(latDiff, lngDiff);
    let zoom = 14;
    if (maxDiff > 0.1) zoom = 11;
    else if (maxDiff > 0.05) zoom = 12;
    else if (maxDiff > 0.02) zoom = 13;

    const cameraUpdate = map.newLatLng({ latitude: centerLat, longitude: centerLng }, zoom);
    this.mapController.animateCamera(cameraUpdate, 500);
  }

  // 根据出行方式估算时间（秒）
  estimateDuration(distanceMeters: number): number {
    let speedMps: number;
    if (this.selectedRouteType === 'driving') {
      speedMps = 40 * 1000 / 3600;
    } else if (this.selectedRouteType === 'cycling') {
      speedMps = 15 * 1000 / 3600;
    } else {
      speedMps = 5 * 1000 / 3600;
    }
    return Math.round(distanceMeters / speedMps);
  }

  formatDistance(meters: number): string {
    if (meters < 1000) return `${meters}米`;
    return `${(meters / 1000).toFixed(1)}公里`;
  }

  formatDuration(seconds: number): string {
    if (seconds < 60) return `${seconds}秒`;
    const minutes = Math.floor(seconds / 60);
    if (minutes < 60) return `${minutes}分钟`;
    const hours = Math.floor(minutes / 60);
    const remainMinutes = minutes % 60;
    return `${hours}小时${remainMinutes}分钟`;
  }

  goBack(): void {
    router.back();
  }

  onPageShow(): void {
    if (this.mapController) this.mapController.show();
  }

  onPageHide(): void {
    if (this.mapController) this.mapController.hide();
  }

  build() {
    Column() {
      // 顶部导航栏（添加状态栏高度）
      Row() {
        Image($r('app.media.Left'))
          .width(24)
          .height(24)
          .onClick(() => this.goBack())

        Text('路线规划')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.TEXT_PRIMARY)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Blank().width(24)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16, top: 0 })
      .margin({ top: 44 })  // 状态栏高度
      .backgroundColor(ThemeColors.BG_SECONDARY)

      if (this.spot) {
        Row() {
          Text(WaterTypeIcons[this.spot.waterType])
            .fontSize(24)
            .margin({ right: 12 })

          Column() {
            Text(this.spot.name)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(ThemeColors.TEXT_PRIMARY)
            Text(`${WaterTypeNames[this.spot.waterType]} · ${FishingSpotService.formatDistance(this.spot.distance || 0)}`)
              .fontSize(12)
              .fontColor(ThemeColors.TEXT_SECONDARY)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
        }
        .width('100%')
        .padding(16)
        .backgroundColor(ThemeColors.BG_PRIMARY)
      }

      Row({ space: 12 }) {
        this.RouteTypeButton('🚗', '驾车', 'driving')
        this.RouteTypeButton('🚶', '步行', 'walking')
        this.RouteTypeButton('🚴', '骑行', 'cycling')
      }
      .width('100%')
      .padding(12)
      .backgroundColor(ThemeColors.BG_PRIMARY)
      .justifyContent(FlexAlign.Center)

      if (this.routeInfo) {
        Row() {
          Column() {
            Text(this.formatDistance(this.routeInfo.distance))
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(ThemeColors.PRIMARY)
            Text('总距离')
              .fontSize(12)
              .fontColor(ThemeColors.TEXT_SECONDARY)
          }
          .layoutWeight(1)

          Column() {
            Text(this.formatDuration(this.routeInfo.duration))
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(ThemeColors.PRIMARY)
            Text('预计时间')
              .fontSize(12)
              .fontColor(ThemeColors.TEXT_SECONDARY)
          }
          .layoutWeight(1)
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#E8F5E9')
      }

      Stack() {
        if (this.mapOptions) {
          MapComponent({
            mapOptions: this.mapOptions,
            mapCallback: this.mapCallback
          })
            .width('100%')
            .height('100%')
        }

        if (this.isLoading) {
          Column() {
            LoadingProgress().width(48).height(48).color(ThemeColors.PRIMARY)
            Text('计算路线中...').fontSize(14).fontColor(ThemeColors.TEXT_SECONDARY).margin({ top: 12 })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .backgroundColor('rgba(255,255,255,0.8)')
        }
      }
      .layoutWeight(1)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeColors.BG_PRIMARY)
  }

  @Builder
  RouteTypeButton(icon: string, label: string, type: string) {
    Column() {
      Text(icon).fontSize(24)
      Text(label)
        .fontSize(12)
        .fontColor(this.selectedRouteType === type ? ThemeColors.PRIMARY : ThemeColors.TEXT_SECONDARY)
        .margin({ top: 4 })
    }
    .padding(12)
    .backgroundColor(this.selectedRouteType === type ? 'rgba(232, 168, 73, 0.15)' : ThemeColors.BG_SECONDARY)
    .borderRadius(8)
    .border({
      width: this.selectedRouteType === type ? 1 : 0,
      color: ThemeColors.PRIMARY
    })
    .onClick(() => {
      if (this.selectedRouteType !== type) {
        this.selectedRouteType = type;
        this.calculateRoute();
      }
    })
  }
}
