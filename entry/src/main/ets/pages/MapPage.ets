/**
 * 饵知�?- 地图页面（高德地图版�?
 * 显示周边真实钓点，点击推荐饵�?
 */
import {
  AMap,
  MapView,
  MapViewComponent,
  MapViewManager,
  MapViewCreateCallback,
  CameraUpdateFactory,
  CameraUpdate,
  LatLng,
  LatLngBounds,
  Marker,
  MarkerOptions,
  Polyline,
  PolylineOptions,
  BitmapDescriptorFactory,
  BitmapDescriptor,
  MapType
} from '@amap/amap_lbs_map3d';
import {
  PoiSearch,
  PoiQuery,
  PoiResult,
  PoiItem,
  OnPoiSearchListener,
  LatLonPoint,
  AMapException,
  PoiSearchBound,
  GeocodeSearch,
  ReGeocodeQuery,
  ReGeocodeAddress,
  RouteSearch,
  DriveRouteQuery,
  DriveRouteResult,
  WalkRouteQuery,
  WalkRouteResult,
  RideRouteQuery,
  RideRouteResult,
  BusRouteResult,
  FromAndTo,
  OnRouteSearchListener,
  DrivePath,
  DriveStep,
  WalkPath,
  WalkStep,
  RidePath,
  RideStep
} from '@amap/amap_lbs_search';
import { ArrayList } from '@kit.ArkTS';
import { abilityAccessCtrl, common, PermissionRequestResult, Permissions } from '@kit.AbilityKit';
import { geoLocationManager } from '@kit.LocationKit';
import { router } from '@kit.ArkUI';
import { ThemeColors } from '../theme/ThemeColors';
import { FishingSpot, WaterType, WaterTypeNames, WaterTypeImages } from '../data/FishingSpotData';
import { RecipeService, Recipe } from '../services/RecipeService';
import { FishingSpotService } from '../services/FishingSpotService';

const MAP_VIEW_NAME: string = 'BaitKnowsMap';

// 钓点搜索关键�?- 水域相关
const FISHING_KEYWORDS: string[] = ['�?, '�?, '水库', '�?, '�?, '钓鱼', '垂钓', '公园'];

// 用户自定义钓点接�?
interface UserCustomSpot {
  id: string;
  name: string;
  latitude: number;
  longitude: number;
  note: string;
  createTime: number;
  waterType: WaterType;
}

// 路线类型
type RouteType = 'drive' | 'walk' | 'ride';

@Entry
@Component
struct MapPage {
  private TAG = 'MapPage';
  private mapView: MapView | undefined = undefined;
  private aMap: AMap | undefined = undefined;
  private poiSearch: PoiSearch | undefined = undefined;
  private geocodeSearch: GeocodeSearch | undefined = undefined;
  private routeSearch: RouteSearch | undefined = undefined;
  private locationMarker: Marker | undefined = undefined;
  private spotMarkers: Marker[] = [];
  private customSpotMarkers: Marker[] = [];
  private hooksIcon: BitmapDescriptor | undefined = undefined;
  private routePolyline: Polyline | undefined = undefined;
  private startMarker: Marker | undefined = undefined;
  private endMarker: Marker | undefined = undefined;

  @State isMapReady: boolean = false;
  @State isSearching: boolean = false;
  @State currentLocation: string = '定位�?..';
  @State currentLatLng: LatLng | undefined = undefined;
  @State fishingSpots: FishingSpot[] = [];
  @State showBaitDialog: boolean = false;
  @State selectedSpot: FishingSpot | null = null;
  @State recommendedRecipes: Recipe[] = [];
  @State clickedLocationName: string = '';
  @State showMapTypePanel: boolean = false;
  @State currentMapType: number = 0; // 0:普�?1:卫星 2:夜间

  // 导航相关状�?
  @State showRoutePanel: boolean = false;
  @State selectedRouteType: RouteType = 'drive';
  @State isRouteSearching: boolean = false;
  @State routeDistance: number = 0;
  @State routeDuration: number = 0;
  @State routeInfo: string = '';

  // 用户自定义打点相关状�?
  @State isAddingCustomSpot: boolean = false;
  @State showAddSpotDialog: boolean = false;
  @State pendingSpotLatLng: LatLng | undefined = undefined;
  @State pendingSpotAddress: string = '';
  @State customSpotName: string = '';
  @State customSpotNote: string = '';
  @State customSpotWaterType: WaterType = WaterType.POND;
  @State userCustomSpots: UserCustomSpot[] = [];
  @State showCustomSpotDetail: boolean = false;
  @State selectedCustomSpot: UserCustomSpot | null = null;
  @State showMySpotsList: boolean = false;

  // 默认位置（武汉）
  private defaultLat: number = 30.5928;
  private defaultLng: number = 114.3055;

  private mapViewCreateCallback: MapViewCreateCallback =
    (mapview: MapView | undefined, mapViewName: string | undefined): void => {
      if (!mapview || mapViewName !== MAP_VIEW_NAME) return;

      console.info(this.TAG, 'MapView created');
      this.mapView = mapview;
      this.mapView.onCreate();

      this.mapView.getMapAsync((map: AMap): void => {
        console.info(this.TAG, 'AMap ready');
        this.aMap = map;
        this.isMapReady = true;

        // 初始化地图位�?
        const defaultLocation: LatLng = new LatLng(this.defaultLat, this.defaultLng);
        const update: CameraUpdate = CameraUpdateFactory.newLatLngZoom(defaultLocation, 12);
        map.moveCamera(update);

        // 启用地图控件
        map.getUiSettings()?.setZoomControlsEnabled(true);
        map.getUiSettings()?.setScaleControlsEnabled(true);

        // 请求定位权限
        this.requestLocationPermission();

        // 地图点击事件 - 逆地理编码或添加自定义钓�?
        map.setOnMapClickListener((point: LatLng): void => {
          if (this.isAddingCustomSpot) {
            this.onMapClickForCustomSpot(point);
          } else {
            this.onMapClick(point);
          }
        });

        // 标记点击事件
        map.setOnMarkerClickListener((marker: Marker): boolean => {
          this.onMarkerClick(marker);
          return true;
        });

        // 加载自定义标记图�?
        this.loadCustomMarkerIcon();
      });
    };

  // POI搜索监听�?
  private currentKeywordIndex: number = 0;
  private tempSpots: FishingSpot[] = [];

  // 路线搜索监听�?
  private routeSearchListener: OnRouteSearchListener = {
    onDriveRouteSearched: (result: DriveRouteResult | undefined, errorCode: number): void => {
      console.info(this.TAG, '========== 驾车路线回调 ==========');
      console.info(this.TAG, `errorCode=${errorCode}, result=${!!result}`);
      this.isRouteSearching = false;
      if (errorCode === AMapException.CODE_AMAP_SUCCESS && result) {
        const paths = result.getPaths();
        console.info(this.TAG, `找到 ${paths?.length || 0} 条路线`);
        if (paths && paths.length > 0) {
          const path: DrivePath = paths[0];
          this.routeDistance = path.getDistance();
          this.routeDuration = path.getDuration();
          console.info(this.TAG, `距离=${this.routeDistance}�? 时间=${this.routeDuration}秒`);
          this.routeInfo = `驾车 ${this.formatRouteDistance(this.routeDistance)} · ${this.formatRouteDuration(this.routeDuration)}`;
          this.drawDriveRoute(path);
        } else {
          this.routeInfo = '未找到驾车路�?;
        }
      } else {
        console.error(this.TAG, `驾车路线查询失败: ${errorCode}`);
        this.routeInfo = this.getRouteErrorMessage(errorCode);
      }
    },

    onWalkRouteSearched: (result: WalkRouteResult | undefined, errorCode: number): void => {
      console.info(this.TAG, '========== 步行路线回调 ==========');
      console.info(this.TAG, `errorCode=${errorCode}, result=${!!result}`);
      this.isRouteSearching = false;
      if (errorCode === AMapException.CODE_AMAP_SUCCESS && result) {
        const paths = result.getPaths();
        console.info(this.TAG, `找到 ${paths?.length || 0} 条路线`);
        if (paths && paths.length > 0) {
          const path: WalkPath = paths[0];
          this.routeDistance = path.getDistance();
          this.routeDuration = path.getDuration();
          console.info(this.TAG, `距离=${this.routeDistance}�? 时间=${this.routeDuration}秒`);
          this.routeInfo = `步行 ${this.formatRouteDistance(this.routeDistance)} · ${this.formatRouteDuration(this.routeDuration)}`;
          this.drawWalkRoute(path);
        } else {
          this.routeInfo = '未找到步行路�?;
        }
      } else {
        console.error(this.TAG, `步行路线查询失败: ${errorCode}`);
        this.routeInfo = this.getRouteErrorMessage(errorCode);
      }
    },

    onRideRouteSearched: (result: RideRouteResult | undefined, errorCode: number): void => {
      console.info(this.TAG, '========== 骑行路线回调 ==========');
      console.info(this.TAG, `errorCode=${errorCode}, result=${!!result}`);
      this.isRouteSearching = false;
      if (errorCode === AMapException.CODE_AMAP_SUCCESS && result) {
        const paths = result.getPaths();
        console.info(this.TAG, `找到 ${paths?.length || 0} 条路线`);
        if (paths && paths.length > 0) {
          const path: RidePath = paths[0];
          this.routeDistance = path.getDistance();
          this.routeDuration = path.getDuration();
          console.info(this.TAG, `距离=${this.routeDistance}�? 时间=${this.routeDuration}秒`);
          this.routeInfo = `骑行 ${this.formatRouteDistance(this.routeDistance)} · ${this.formatRouteDuration(this.routeDuration)}`;
          this.drawRideRoute(path);
        } else {
          this.routeInfo = '未找到骑行路�?;
        }
      } else {
        console.error(this.TAG, `骑行路线查询失败: ${errorCode}`);
        this.routeInfo = this.getRouteErrorMessage(errorCode);
      }
    },

    onBusRouteSearched: (result: BusRouteResult | undefined, errorCode: number): void => {
      this.isRouteSearching = false;
    }
  };

  // 获取路线错误信息
  private getRouteErrorMessage(errorCode: number): string {
    const errorMessages: Record<number, string> = {
      1001: '请求参数非法',
      1002: 'Key不正确或过期',
      1003: '没有权限使用相应的服�?,
      1008: '起点或终点不在中国大陆范围内',
      1009: '起点附近没有找到道路',
      1010: '终点附近没有找到道路',
      1011: '起点和终点距离太�?,
      1012: '起点和终点距离太�?,
      1200: '服务响应错误',
      1804: '路线计算失败'
    };
    return errorMessages[errorCode] || `路线查询失败(${errorCode})`;
  }

  private poiSearchListener: OnPoiSearchListener = {
    onPoiSearched: (result: PoiResult | undefined, errorCode: number): void => {
      console.info(this.TAG, `POI搜索回调: errorCode=${errorCode}, keyword=${FISHING_KEYWORDS[this.currentKeywordIndex]}`);

      if (errorCode === AMapException.CODE_AMAP_SUCCESS && result) {
        const pois = result.getPois();
        console.info(this.TAG, `找到 ${pois?.length || 0} 个POI`);

        if (pois && pois.length > 0) {
          pois.forEach((poi: PoiItem): void => {
            const point = poi.getLatLonPoint();
            if (point) {
              const name = poi.getTitle() || '';
              // 检查是否已存在
              const exists = this.tempSpots.some(s =>
                Math.abs(s.latitude - point.getLatitude()) < 0.0001 &&
                Math.abs(s.longitude - point.getLongitude()) < 0.0001
              );
              if (!exists) {
                const waterType = this.detectWaterType(name);
                const distance = this.currentLatLng ?
                  this.calculateDistance(this.currentLatLng.latitude, this.currentLatLng.longitude,
                    point.getLatitude(), point.getLongitude()) : 0;

                this.tempSpots.push({
                  id: poi.getPoiId() || `spot_${this.tempSpots.length}`,
                  name: name,
                  latitude: point.getLatitude(),
                  longitude: point.getLongitude(),
                  waterType: waterType,
                  description: poi.getSnippet() || this.getSpotDescription(waterType),
                  distance: Math.round(distance)
                });
                console.info(this.TAG, `添加钓点: ${name} (${point.getLatitude()}, ${point.getLongitude()})`);
              }
            }
          });
        }
      } else {
        console.error(this.TAG, `POI搜索失败: ${errorCode}`);
      }

      // 继续搜索下一个关键词
      this.currentKeywordIndex++;
      if (this.currentKeywordIndex < FISHING_KEYWORDS.length) {
        this.searchNextKeyword();
      } else {
        // 搜索完成
        console.info(this.TAG, `所有关键词搜索完成，共找到 ${this.tempSpots.length} 个钓点`);
        this.finishSearch();
      }
    },
    onPoiItemSearched: (): void => {}
  };

  // 导航参数
  private navigateToSpotOnLoad: boolean = false;
  private pendingNavigateSpot: FishingSpot | null = null;

  aboutToAppear(): void {
    console.info(this.TAG, 'MapPage aboutToAppear');
    MapViewManager.getInstance().registerMapViewCreatedCallback(this.mapViewCreateCallback);

    const context: Context = getContext(this);
    this.poiSearch = new PoiSearch(context, undefined);
    this.poiSearch.setOnPoiSearchListener(this.poiSearchListener);
    this.geocodeSearch = new GeocodeSearch(context);
    
    // 初始化路线搜�?
    this.routeSearch = new RouteSearch(context);
    this.routeSearch.setRouteSearchListener(this.routeSearchListener);

    // 检查是否有导航参数
    this.checkNavigationParams();
  }

  // 检查导航参�?
  private checkNavigationParams(): void {
    const params = router.getParams() as Record<string, Object> | undefined;
    if (params && params['navigateToSpot'] === true) {
      console.info(this.TAG, '收到导航参数');
      this.navigateToSpotOnLoad = true;
      this.pendingNavigateSpot = {
        id: params['spotId'] as string || '',
        name: params['spotName'] as string || '钓点',
        latitude: params['spotLat'] as number || 0,
        longitude: params['spotLng'] as number || 0,
        waterType: params['spotWaterType'] as WaterType || WaterType.POND,
        distance: params['spotDistance'] as number || 0,
        description: ''
      };
      console.info(this.TAG, `待导航钓�? ${this.pendingNavigateSpot.name}`);
    }
  }

  aboutToDisappear(): void {
    console.info(this.TAG, 'MapPage aboutToDisappear');
    this.clearSpotMarkers();
    MapViewManager.getInstance().unregisterMapViewCreatedCallback(this.mapViewCreateCallback);
    if (this.mapView) {
      this.mapView.onDestroy();
      this.mapView = undefined;
      this.aMap = undefined;
    }
  }

  onPageShow(): void {
    if (this.mapView) {
      this.mapView.onResume();
    }
  }

  onPageHide(): void {
    if (this.mapView) {
      this.mapView.onPause();
    }
  }

  // 请求定位权限
  private async requestLocationPermission(): Promise<void> {
    try {
      const permissions: Permissions[] = [
        'ohos.permission.APPROXIMATELY_LOCATION',
        'ohos.permission.LOCATION'
      ];

      const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
      const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
      const result: PermissionRequestResult = await atManager.requestPermissionsFromUser(context, permissions);

      const allGranted: boolean = result.authResults.every((status: number): boolean => status === 0);
      if (allGranted) {
        this.startLocation();
      } else {
        this.currentLocation = '未授权定位，使用默认位置';
        this.currentLatLng = new LatLng(this.defaultLat, this.defaultLng);
        this.addLocationMarker();
        this.searchNearbySpots();
      }
    } catch (error) {
      console.error(this.TAG, `Permission request failed: ${error}`);
      this.currentLatLng = new LatLng(this.defaultLat, this.defaultLng);
      this.addLocationMarker();
      this.searchNearbySpots();
    }
  }

  // 开始定�?
  private startLocation(): void {
    this.currentLocation = '正在定位...';

    const request: geoLocationManager.CurrentLocationRequest = {
      priority: geoLocationManager.LocationRequestPriority.FIRST_FIX,
      scenario: geoLocationManager.LocationRequestScenario.UNSET
    };

    geoLocationManager.getCurrentLocation(request)
      .then(async (location: geoLocationManager.Location): Promise<void> => {
        console.info(this.TAG, `Location: ${location.latitude}, ${location.longitude}`);
        this.currentLatLng = new LatLng(location.latitude, location.longitude);
        this.currentLocation = '已定�?;

        // 移动地图到当前位�?
        if (this.aMap) {
          const update: CameraUpdate = CameraUpdateFactory.newLatLngZoom(this.currentLatLng, 13);
          this.aMap.animateCamera(update);
        }

        // 添加位置标记
        await this.addLocationMarker();

        // 获取地址
        this.getAddressFromLocation(location.latitude, location.longitude);

        // 搜索附近钓点
        this.searchNearbySpots();
      })
      .catch((error: Error): void => {
        console.error(this.TAG, `Location failed: ${error}`);
        this.currentLocation = '定位失败，使用默认位�?;
        this.currentLatLng = new LatLng(this.defaultLat, this.defaultLng);
        this.addLocationMarker();
        this.searchNearbySpots();
      });
  }

  // 添加当前位置标记 - 使用醒目的红色大标记
  private async addLocationMarker(): Promise<void> {
    if (!this.aMap || !this.currentLatLng) return;

    if (this.locationMarker) {
      this.locationMarker.remove();
    }

    const options: MarkerOptions = new MarkerOptions();
    options.setPosition(this.currentLatLng);
    options.setTitle('🎯 我的位置');
    options.setSnippet('点击定位到此�?);

    // 使用红色标记，更醒目
    options.setIcon(BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_RED));
    options.setAnchor(0.5, 1.0);
    options.setZIndex(999); // 最高层级，确保在最上面

    this.locationMarker = this.aMap.addMarker(options);

    // 默认显示信息窗口，让用户一眼看�?
    if (this.locationMarker) {
      this.locationMarker.showInfoWindow();
    }
  }

  // 搜索附近钓点
  private searchNearbySpots(): void {
    if (!this.poiSearch || !this.currentLatLng) {
      console.error(this.TAG, '无法搜索：poiSearch或位置未初始�?);
      return;
    }

    // 如果是导航模式，跳过 POI 搜索，直接开始导�?
    if (this.navigateToSpotOnLoad && this.pendingNavigateSpot) {
      console.info(this.TAG, `导航模式：跳过POI搜索，直接导航到 ${this.pendingNavigateSpot.name}`);
      this.navigateToSpotOnLoad = false;
      this.currentLocation = `导航�? ${this.pendingNavigateSpot.name}`;
      
      setTimeout(() => {
        if (this.pendingNavigateSpot) {
          this.startNavigation(this.pendingNavigateSpot);
          this.pendingNavigateSpot = null;
        }
      }, 300);
      return;
    }

    this.isSearching = true;
    this.currentLocation = '搜索钓点�?..';
    this.currentKeywordIndex = 0;
    this.tempSpots = [];

    this.searchNextKeyword();
  }

  // 搜索下一个关键词 - 基于用户位置的周边搜�?
  private searchNextKeyword(): void {
    if (!this.poiSearch || !this.currentLatLng) return;

    const keyword = FISHING_KEYWORDS[this.currentKeywordIndex];
    console.info(this.TAG, `搜索关键�? ${keyword}, 位置: (${this.currentLatLng.latitude}, ${this.currentLatLng.longitude})`);

    // 创建查询
    const query: PoiQuery = new PoiQuery(keyword, '', '');
    query.setPageSize(20);
    query.setPageNum(0);

    // 基于用户当前位置创建周边搜索范围�?0公里�?
    const centerPoint: LatLonPoint = new LatLonPoint(
      this.currentLatLng.latitude,
      this.currentLatLng.longitude
    );
    const searchBound: PoiSearchBound = PoiSearchBound.createCircleSearchBound(centerPoint, 10000);

    this.poiSearch.setQuery(query);
    this.poiSearch.setBound(searchBound);
    this.poiSearch.searchPOIAsyn();
  }

  // 完成搜索
  private finishSearch(): void {
    // 按距离排�?
    this.tempSpots.sort((a, b) => (a.distance || 0) - (b.distance || 0));
    this.fishingSpots = this.tempSpots.slice(0, 20);

    console.info(this.TAG, `搜索完成，找�?${this.fishingSpots.length} 个钓点`);

    this.isSearching = false;

    // 如果是导航模式，不添加其他钓点，只处理目标钓�?
    if (this.navigateToSpotOnLoad && this.pendingNavigateSpot) {
      console.info(this.TAG, `导航模式：直接导航到 ${this.pendingNavigateSpot.name}`);
      this.navigateToSpotOnLoad = false;
      this.currentLocation = `导航�? ${this.pendingNavigateSpot.name}`;
      
      // 更新缓存
      FishingSpotService.updateCachedSpots(this.fishingSpots);
      
      // 延迟执行导航
      setTimeout(() => {
        if (this.pendingNavigateSpot) {
          this.startNavigation(this.pendingNavigateSpot);
          this.pendingNavigateSpot = null;
        }
      }, 300);
      return;
    }

    // 如果没有搜索到钓点，添加附近的模拟钓点（基于当前位置�?
    if (this.fishingSpots.length === 0 && this.currentLatLng) {
      this.addNearbyMockSpots();
    }

    // 更新缓存，让首页也能获取到钓点数�?
    FishingSpotService.updateCachedSpots(this.fishingSpots);

    if (this.fishingSpots.length > 0) {
      this.currentLocation = `发现 ${this.fishingSpots.length} 个钓点`;
    } else {
      this.currentLocation = '附近暂无钓点';
    }

    // 添加钓点标记
    this.addSpotMarkers();
  }

  // 添加附近真实钓点（武汉地区热门钓点）
  private addNearbyMockSpots(): void {
    if (!this.currentLatLng) return;

    const userLat = this.currentLatLng.latitude;
    const userLng = this.currentLatLng.longitude;

    // 武汉真实钓点数据
    const realSpots: FishingSpot[] = [
      // 东湖区域
      {
        id: 'spot_1',
        name: '东湖落雁景区',
        latitude: 30.5547,
        longitude: 114.4283,
        waterType: WaterType.RESERVOIR,
        description: '东湖最大的湖汊，水质好，鱼种丰�?,
        distance: 0
      },
      {
        id: 'spot_2',
        name: '东湖磨山景区',
        latitude: 30.5489,
        longitude: 114.4089,
        waterType: WaterType.RESERVOIR,
        description: '风景优美，适合休闲垂钓',
        distance: 0
      },
      {
        id: 'spot_3',
        name: '东湖听涛景区',
        latitude: 30.5612,
        longitude: 114.3856,
        waterType: WaterType.RESERVOIR,
        description: '交通便利，岸边钓位�?,
        distance: 0
      },
      // 沙湖区域
      {
        id: 'spot_4',
        name: '沙湖公园',
        latitude: 30.5734,
        longitude: 114.3412,
        waterType: WaterType.POND,
        description: '市区内钓场，适合休闲',
        distance: 0
      },
      // 汤逊湖区域
      {
        id: 'spot_5',
        name: '汤逊湖',
        latitude: 30.4523,
        longitude: 114.3678,
        waterType: WaterType.RESERVOIR,
        description: '武汉最大城中湖，大物频�?,
        distance: 0
      },
      // 长江区域
      {
        id: 'spot_6',
        name: '汉口江滩',
        latitude: 30.5912,
        longitude: 114.2934,
        waterType: WaterType.RIVER,
        description: '长江钓场，鱼口活�?,
        distance: 0
      },
      {
        id: 'spot_7',
        name: '武昌江滩',
        latitude: 30.5523,
        longitude: 114.3123,
        waterType: WaterType.RIVER,
        description: '江边钓位，注意安�?,
        distance: 0
      },
      // 其他湖泊
      {
        id: 'spot_8',
        name: '墨水�?,
        latitude: 30.5234,
        longitude: 114.2156,
        waterType: WaterType.POND,
        description: '汉阳区钓场，鲫鱼�?,
        distance: 0
      },
      {
        id: 'spot_9',
        name: '南湖',
        latitude: 30.5089,
        longitude: 114.3534,
        waterType: WaterType.POND,
        description: '洪山区湖泊，环境优美',
        distance: 0
      },
      {
        id: 'spot_10',
        name: '后官�?,
        latitude: 30.4912,
        longitude: 114.1234,
        waterType: WaterType.RESERVOIR,
        description: '蔡甸区大型水库，鱼种�?,
        distance: 0
      },
      {
        id: 'spot_11',
        name: '严西�?,
        latitude: 30.5234,
        longitude: 114.4789,
        waterType: WaterType.RESERVOIR,
        description: '光谷附近，水质清�?,
        distance: 0
      },
      {
        id: 'spot_12',
        name: '梁子�?,
        latitude: 30.2567,
        longitude: 114.5234,
        waterType: WaterType.RESERVOIR,
        description: '武汉最大淡水湖，野钓圣�?,
        distance: 0
      }
    ];

    // 计算每个钓点到用户的距离
    realSpots.forEach(spot => {
      spot.distance = Math.round(this.calculateDistance(userLat, userLng, spot.latitude, spot.longitude));
    });

    // 按距离排序，取最近的10�?
    realSpots.sort((a, b) => (a.distance || 0) - (b.distance || 0));
    this.fishingSpots = realSpots.slice(0, 10);

    console.info(this.TAG, `添加�?${this.fishingSpots.length} 个真实钓点`);
  }

  // 添加钓点标记 - 按照高德地图文档方式添加
  private addSpotMarkers(): void {
    if (!this.aMap) {
      console.error(this.TAG, '地图未初始化，无法添加标�?);
      return;
    }

    this.clearSpotMarkers();
    console.info(this.TAG, `开始添�?${this.fishingSpots.length} 个钓点标记`);

    for (let i = 0; i < this.fishingSpots.length; i++) {
      const spot = this.fishingSpots[i];

      // 按照高德文档方式创建 Marker
      let options: MarkerOptions = new MarkerOptions();
      options.setPosition(new LatLng(spot.latitude, spot.longitude));
      options.setTitle(spot.name);
      options.setSnippet(`${WaterTypeNames[spot.waterType]} · ${this.formatDistance(spot.distance || 0)}`);

      // �?个用橙色（推荐），其他用绿色
      const hue = i < 3 ? BitmapDescriptorFactory.HUE_ORANGE : BitmapDescriptorFactory.HUE_GREEN;
      options.setIcon(BitmapDescriptorFactory.defaultMarker(hue));
      options.setAnchor(0.5, 1.0);

      let marker = this.aMap.addMarker(options);
      if (marker) {
        this.spotMarkers.push(marker);
        console.info(this.TAG, `添加钓点标记: ${spot.name} at (${spot.latitude}, ${spot.longitude})`);
      }
    }

    console.info(this.TAG, `成功添加 ${this.spotMarkers.length} 个标记`);
  }

  // 清除钓点标记
  private clearSpotMarkers(): void {
    for (const marker of this.spotMarkers) {
      marker.remove();
    }
    this.spotMarkers = [];
  }

  // 标记点击事件
  private onMarkerClick(marker: Marker): void {
    const position = marker.getPosition();

    // 先检查是否是自定义钓�?
    const customSpot = this.userCustomSpots.find(s =>
      Math.abs(s.latitude - position.latitude) < 0.0001 &&
      Math.abs(s.longitude - position.longitude) < 0.0001
    );

    if (customSpot) {
      this.onCustomSpotClick(customSpot);
      return;
    }

    // 查找对应的POI钓点
    const spot = this.fishingSpots.find(s =>
      Math.abs(s.latitude - position.latitude) < 0.0001 &&
      Math.abs(s.longitude - position.longitude) < 0.0001
    );

    if (spot) {
      this.onSpotClick(spot);
    }
  }

  // 点击钓点
  private onSpotClick(spot: FishingSpot): void {
    this.selectedSpot = spot;
    this.recommendedRecipes = this.recommendRecipes(spot.waterType);
    this.showBaitDialog = true;
  }

  // 地图点击事件 - 逆地理编�?
  private async onMapClick(point: LatLng): Promise<void> {
    if (!this.geocodeSearch) return;

    this.clickedLocationName = '查询�?..';

    try {
      const latLonPoint: LatLonPoint = new LatLonPoint(point.latitude, point.longitude);
      const query: ReGeocodeQuery = new ReGeocodeQuery(latLonPoint, 200, GeocodeSearch.AMAP);
      const address: ReGeocodeAddress | undefined = await this.geocodeSearch.getFromLocation(query);

      if (address) {
        const formatAddress = address.getFormatAddress();
        if (formatAddress) {
          // 简化地址显示
          const district = address.getDistrict() || '';
          const township = address.getTownship() || '';
          this.clickedLocationName = `${district}${township}` || formatAddress;
        } else {
          this.clickedLocationName = `${point.latitude.toFixed(4)}, ${point.longitude.toFixed(4)}`;
        }
      } else {
        this.clickedLocationName = `${point.latitude.toFixed(4)}, ${point.longitude.toFixed(4)}`;
      }
    } catch (error) {
      console.error(this.TAG, `Reverse geocode failed: ${error}`);
      this.clickedLocationName = `${point.latitude.toFixed(4)}, ${point.longitude.toFixed(4)}`;
    }
  }

  // 获取当前位置地址
  private async getAddressFromLocation(lat: number, lng: number): Promise<void> {
    if (!this.geocodeSearch) return;

    try {
      const point: LatLonPoint = new LatLonPoint(lat, lng);
      const query: ReGeocodeQuery = new ReGeocodeQuery(point, 200, GeocodeSearch.AMAP);
      const address: ReGeocodeAddress | undefined = await this.geocodeSearch.getFromLocation(query);

      if (address) {
        const city = address.getCity() || '';
        const district = address.getDistrict() || '';
        if (city) {
          this.currentLocation = `${city} ${district}`.trim();
        }
      }
    } catch (error) {
      console.error(this.TAG, `Get address failed: ${error}`);
    }
  }

  // 刷新位置
  private refreshLocation(): void {
    this.startLocation();
  }

  // 移动到当前位�?
  private moveToCurrentLocation(): void {
    if (!this.aMap || !this.currentLatLng) return;
    const update: CameraUpdate = CameraUpdateFactory.newLatLngZoom(this.currentLatLng, 14);
    this.aMap.animateCamera(update);
  }

  // 返回
  private goBack(): void {
    router.back();
  }

  // 切换地图类型
  private switchMapType(type: number): void {
    if (!this.aMap) return;
    this.currentMapType = type;
    switch (type) {
      case 0: // 普通地�?
        this.aMap.setMapType(MapType.MAP_TYPE_NORMAL);
        break;
      case 1: // 卫星地图
        this.aMap.setMapType(MapType.MAP_TYPE_SATELLITE);
        break;
      case 2: // 夜间模式
        this.aMap.setMapType(MapType.MAP_TYPE_NIGHT);
        break;
    }
    this.showMapTypePanel = false;
  }

  // 获取地图类型名称
  private getMapTypeName(): string {
    const names = ['普�?, '卫星', '夜间'];
    return names[this.currentMapType] || '普�?;
  }

  // 判断是否为水域相�?
  private isWaterRelated(name: string): boolean {
    const excludeKeywords = ['厕所', '卫生�?, '火锅', '餐厅', '饭店', '超市', '商场', '医院', '学校',
      '停车�?, '加油�?, '银行', '药店', '美容', '美发', '酒店', '宾馆', '公司', '�?];
    for (const exclude of excludeKeywords) {
      if (name.includes(exclude)) return false;
    }

    const waterKeywords = ['垂钓', '钓场', '钓鱼', '渔场', '鱼塘', '鱼池', '钓园',
      '江滩', '河滩', '湖滩', '水库', '湿地公园', '湿地', '�?, '�?, '�?, '�?, '�?, '�?, '�?, '渡口'];
    for (const keyword of waterKeywords) {
      if (name.includes(keyword)) return true;
    }
    return false;
  }

  // 检测水域类�?
  private detectWaterType(name: string): WaterType {
    if (name.includes('�?) || name.includes('�?)) {
      return WaterType.LAKE;
    }
    if (name.includes('�?) || name.includes('�?) || name.includes('�?) ||
        name.includes('�?) || name.includes('码头') || name.includes('渡口')) {
      return WaterType.RIVER;
    }
    if (name.includes('水库')) {
      return WaterType.RESERVOIR;
    }
    return WaterType.POND;
  }

  // 获取钓点描述
  private getSpotDescription(type: WaterType): string {
    const descriptions: Record<string, string> = {
      [WaterType.POND]: '适合休闲垂钓',
      [WaterType.RESERVOIR]: '水域开阔，适合守钓',
      [WaterType.RIVER]: '流水钓场，鱼口活�?,
      [WaterType.LAKE]: '湖泊钓场，鱼种丰�?
    };
    return descriptions[type] || '钓点环境良好';
  }

  // 计算距离
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

  // 格式化距�?
  private formatDistance(meters: number): string {
    if (meters < 1000) return `${meters}米`;
    return `${(meters / 1000).toFixed(1)}公里`;
  }

  // 格式化路线距�?
  private formatRouteDistance(meters: number): string {
    if (meters < 1000) return `${meters}米`;
    return `${(meters / 1000).toFixed(1)}公里`;
  }

  // 格式化路线时�?
  private formatRouteDuration(seconds: number): string {
    if (seconds < 60) return `${seconds}秒`;
    const minutes: number = Math.floor(seconds / 60);
    if (minutes < 60) return `${minutes}分钟`;
    const hours: number = Math.floor(minutes / 60);
    return `${hours}小时${minutes % 60}分钟`;
  }

  // ==================== 路线规划功能 ====================

  // 开始导航到钓点
  private startNavigation(spot: FishingSpot): void {
    if (!this.currentLatLng) {
      this.routeInfo = '请先获取当前位置';
      return;
    }
    
    this.selectedSpot = spot;
    this.showBaitDialog = false;
    this.showRoutePanel = true;
    this.searchRoute();
  }

  // 搜索路线
  private searchRoute(): void {
    if (!this.routeSearch || !this.currentLatLng || !this.selectedSpot) {
      console.error(this.TAG, '无法搜索路线：参数不完整');
      console.error(this.TAG, `routeSearch=${!!this.routeSearch}, currentLatLng=${!!this.currentLatLng}, selectedSpot=${!!this.selectedSpot}`);
      this.routeInfo = '参数不完整，无法规划路线';
      return;
    }

    this.isRouteSearching = true;
    this.routeInfo = '正在规划路线...';
    this.clearRouteLine();

    const startLat = this.currentLatLng.latitude;
    const startLng = this.currentLatLng.longitude;
    const endLat = this.selectedSpot.latitude;
    const endLng = this.selectedSpot.longitude;

    // 详细日志
    console.info(this.TAG, '========== 路线规划调试 ==========');
    console.info(this.TAG, `起点: lat=${startLat}, lng=${startLng}`);
    console.info(this.TAG, `终点: lat=${endLat}, lng=${endLng}`);
    console.info(this.TAG, `钓点名称: ${this.selectedSpot.name}`);
    console.info(this.TAG, `出行方式: ${this.selectedRouteType}`);

    // 在界面上显示坐标信息用于调试
    this.routeInfo = `起点:(${startLat.toFixed(4)},${startLng.toFixed(4)}) 终点:(${endLat.toFixed(4)},${endLng.toFixed(4)})`;

    // 验证坐标有效�?
    if (startLat === 0 || startLng === 0) {
      this.routeInfo = '当前位置无效(0,0)，请重新定位';
      this.isRouteSearching = false;
      console.error(this.TAG, '起点坐标�?');
      return;
    }

    if (endLat === 0 || endLng === 0) {
      this.routeInfo = '钓点位置无效(0,0)';
      this.isRouteSearching = false;
      console.error(this.TAG, '终点坐标�?');
      return;
    }

    // 检查坐标是否在中国范围�?(大致范围: 纬度3-54, 经度73-136)
    const isStartInChina = startLat >= 3 && startLat <= 54 && startLng >= 73 && startLng <= 136;
    const isEndInChina = endLat >= 3 && endLat <= 54 && endLng >= 73 && endLng <= 136;
    
    console.info(this.TAG, `起点在中国范�? ${isStartInChina}, 终点在中国范�? ${isEndInChina}`);

    if (!isStartInChina) {
      this.routeInfo = `起点不在中国范围:(${startLat.toFixed(4)},${startLng.toFixed(4)})`;
      this.isRouteSearching = false;
      return;
    }

    if (!isEndInChina) {
      this.routeInfo = `终点不在中国范围:(${endLat.toFixed(4)},${endLng.toFixed(4)})`;
      this.isRouteSearching = false;
      return;
    }

    const startPoint: LatLonPoint = new LatLonPoint(startLat, startLng);
    const endPoint: LatLonPoint = new LatLonPoint(endLat, endLng);
    
    console.info(this.TAG, `LatLonPoint 起点: ${startPoint.getLatitude()}, ${startPoint.getLongitude()}`);
    console.info(this.TAG, `LatLonPoint 终点: ${endPoint.getLatitude()}, ${endPoint.getLongitude()}`);
    
    const fromAndTo: FromAndTo = new FromAndTo(startPoint, endPoint);

    // 添加起终点标�?
    this.addRouteMarkers(startPoint, endPoint);

    console.info(this.TAG, `开始搜�?{this.selectedRouteType}路线...`);
    this.routeInfo = `搜索${this.selectedRouteType === 'drive' ? '驾车' : this.selectedRouteType === 'walk' ? '步行' : '骑行'}路线�?..`;

    if (this.selectedRouteType === 'drive') {
      const query: DriveRouteQuery = new DriveRouteQuery(fromAndTo, RouteSearch.DrivingDefault, undefined, undefined, '');
      console.info(this.TAG, '发起驾车路线查询');
      this.routeSearch.calculateDriveRouteAsyn(query);
    } else if (this.selectedRouteType === 'walk') {
      const query: WalkRouteQuery = new WalkRouteQuery(fromAndTo);
      console.info(this.TAG, '发起步行路线查询');
      this.routeSearch.calculateWalkRouteAsyn(query);
    } else {
      const query: RideRouteQuery = new RideRouteQuery(fromAndTo);
      console.info(this.TAG, '发起骑行路线查询');
      this.routeSearch.calculateRideRouteAsyn(query);
    }
  }

  // 添加起终点标�?
  private addRouteMarkers(start: LatLonPoint, end: LatLonPoint): void {
    if (!this.aMap) return;

    // 清除旧标�?
    if (this.startMarker) {
      this.startMarker.remove();
      this.startMarker = undefined;
    }
    if (this.endMarker) {
      this.endMarker.remove();
      this.endMarker = undefined;
    }

    // 起点标记 - 绿色
    const startOptions: MarkerOptions = new MarkerOptions();
    startOptions.setPosition(new LatLng(start.getLatitude(), start.getLongitude()));
    startOptions.setTitle('起点');
    startOptions.setSnippet('我的位置');
    startOptions.setIcon(BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_GREEN));
    startOptions.setAnchor(0.5, 1.0);
    startOptions.setZIndex(200);
    this.startMarker = this.aMap.addMarker(startOptions);

    // 终点标记 - 红色
    const endOptions: MarkerOptions = new MarkerOptions();
    endOptions.setPosition(new LatLng(end.getLatitude(), end.getLongitude()));
    endOptions.setTitle('终点');
    endOptions.setSnippet(this.selectedSpot?.name || '钓点');
    endOptions.setIcon(BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_RED));
    endOptions.setAnchor(0.5, 1.0);
    endOptions.setZIndex(200);
    this.endMarker = this.aMap.addMarker(endOptions);
  }

  // 绘制驾车路线
  private drawDriveRoute(path: DrivePath): void {
    if (!this.aMap) return;

    const steps = path.getSteps();
    if (!steps) return;

    const pointList: ArrayList<LatLng> = new ArrayList<LatLng>();

    steps.forEach((step: DriveStep): void => {
      const polyline = step.getPolyline();
      if (polyline) {
        polyline.forEach((point: LatLonPoint): void => {
          pointList.add(new LatLng(point.getLatitude(), point.getLongitude()));
        });
      }
    });

    if (pointList.length > 0) {
      this.drawRoutePolyline(pointList, 0xFF4CAF50); // 绿色
    }
  }

  // 绘制步行路线
  private drawWalkRoute(path: WalkPath): void {
    if (!this.aMap) return;

    const steps = path.getSteps();
    if (!steps) return;

    const pointList: ArrayList<LatLng> = new ArrayList<LatLng>();

    steps.forEach((step: WalkStep): void => {
      const polyline = step.getPolyline();
      if (polyline) {
        polyline.forEach((point: LatLonPoint): void => {
          pointList.add(new LatLng(point.getLatitude(), point.getLongitude()));
        });
      }
    });

    if (pointList.length > 0) {
      this.drawRoutePolyline(pointList, 0xFF2196F3); // 蓝色
    }
  }

  // 绘制骑行路线
  private drawRideRoute(path: RidePath): void {
    if (!this.aMap) return;

    const steps = path.getSteps();
    if (!steps) return;

    const pointList: ArrayList<LatLng> = new ArrayList<LatLng>();

    steps.forEach((step: RideStep): void => {
      const polyline = step.getPolyline();
      if (polyline) {
        polyline.forEach((point: LatLonPoint): void => {
          pointList.add(new LatLng(point.getLatitude(), point.getLongitude()));
        });
      }
    });

    if (pointList.length > 0) {
      this.drawRoutePolyline(pointList, 0xFFFF9800); // 橙色
    }
  }

  // 绘制路线折线
  private drawRoutePolyline(points: ArrayList<LatLng>, color: number): void {
    if (!this.aMap) return;

    this.clearRouteLine();

    const options: PolylineOptions = new PolylineOptions();
    options.setPoints(points);
    options.setWidth(14);
    options.setColor(color);
    this.routePolyline = this.aMap.addPolyline(options);

    // 调整视野显示整条路线
    this.fitRouteBounds(points);
  }

  // 清除路线
  private clearRouteLine(): void {
    if (this.routePolyline) {
      this.routePolyline.remove();
      this.routePolyline = undefined;
    }
  }

  // 关闭导航面板
  private closeRoutePanel(): void {
    this.showRoutePanel = false;
    this.clearRouteLine();
    
    // 清除起终点标�?
    if (this.startMarker) {
      this.startMarker.remove();
      this.startMarker = undefined;
    }
    if (this.endMarker) {
      this.endMarker.remove();
      this.endMarker = undefined;
    }
    
    this.routeInfo = '';
    this.routeDistance = 0;
    this.routeDuration = 0;
  }

  // 调整地图视野以显示整条路�?
  private fitRouteBounds(points: ArrayList<LatLng>): void {
    if (!this.aMap || points.length === 0) return;

    let minLat: number = 90;
    let maxLat: number = -90;
    let minLng: number = 180;
    let maxLng: number = -180;

    points.forEach((point: LatLng): void => {
      minLat = Math.min(minLat, point.latitude);
      maxLat = Math.max(maxLat, point.latitude);
      minLng = Math.min(minLng, point.longitude);
      maxLng = Math.max(maxLng, point.longitude);
    });

    const bounds: LatLngBounds = new LatLngBounds(
      new LatLng(minLat, minLng),
      new LatLng(maxLat, maxLng)
    );

    const update: CameraUpdate = CameraUpdateFactory.newLatLngBounds(bounds, 100);
    this.aMap.animateCamera(update);
  }

  // 推荐配方 - 使用真实配方�?
  private recommendRecipes(waterType: WaterType): Recipe[] {
    // 水域类型映射: pond→池�? reservoir→水�? river→河�? lake→湖�?
    const waterTypeMap: Record<string, string> = {
      [WaterType.POND]: '池塘',
      [WaterType.RESERVOIR]: '水库',
      [WaterType.RIVER]: '河流',
      [WaterType.LAKE]: '湖泊'
    };
    
    const chineseWaterType = waterTypeMap[waterType] || '池塘';
    const recipeService = RecipeService.getInstance();
    const allRecipes = recipeService.getRecipesByWaterType(chineseWaterType);
    
    if (allRecipes.length === 0) {
      // 如果没有匹配的配方，返回所有配方中随机几个
      const all = recipeService.getAllRecipes();
      const shuffled = [...all].sort(() => Math.random() - 0.5);
      return shuffled.slice(0, 3);
    }
    
    // 随机选择2-4个配�?
    const shuffled = [...allRecipes].sort(() => Math.random() - 0.5);
    const count = Math.min(Math.floor(Math.random() * 3) + 2, shuffled.length);
    return shuffled.slice(0, count);
  }

  // ==================== 用户自定义打点功�?====================

  // 加载自定义标记图�?
  private async loadCustomMarkerIcon(): Promise<void> {
    try {
      const context = getContext(this);
      // �?rawfile 目录加载 hooks.png
      this.hooksIcon = await BitmapDescriptorFactory.fromRawfilePath(context, 'hooks.png');
      console.info(this.TAG, '自定义标记图标加载成�?);
    } catch (error) {
      console.error(this.TAG, `加载自定义图标失�? ${error}`);
    }
  }

  // 开�?关闭打点模式
  private toggleAddSpotMode(): void {
    this.isAddingCustomSpot = !this.isAddingCustomSpot;
    if (this.isAddingCustomSpot) {
      this.currentLocation = '👆 点击地图选择钓点位置';
    } else {
      this.currentLocation = this.fishingSpots.length > 0 
        ? `发现 ${this.fishingSpots.length} 个钓点` 
        : '附近暂无钓点';
    }
  }

  // 地图点击添加自定义钓�?
  private async onMapClickForCustomSpot(point: LatLng): Promise<void> {
    // 检查附�?000米内是否已有钓点
    const nearbySpot = this.findNearbySpot(point, 1000);
    if (nearbySpot) {
      this.currentLocation = `附近已有钓点: ${nearbySpot.name}`;
      this.isAddingCustomSpot = false;
      // 高亮显示附近的钓�?
      if (this.aMap) {
        const update: CameraUpdate = CameraUpdateFactory.newLatLngZoom(
          new LatLng(nearbySpot.latitude, nearbySpot.longitude), 15
        );
        this.aMap.animateCamera(update);
      }
      return;
    }

    // 检查附�?000米内是否已有自定义钓�?
    const nearbyCustomSpot = this.findNearbyCustomSpot(point, 1000);
    if (nearbyCustomSpot) {
      this.currentLocation = `附近已有钓点: ${nearbyCustomSpot.name}`;
      this.isAddingCustomSpot = false;
      if (this.aMap) {
        const update: CameraUpdate = CameraUpdateFactory.newLatLngZoom(
          new LatLng(nearbyCustomSpot.latitude, nearbyCustomSpot.longitude), 15
        );
        this.aMap.animateCamera(update);
      }
      return;
    }

    this.pendingSpotLatLng = point;
    this.pendingSpotAddress = '获取地址�?..';
    
    // 获取点击位置的地址
    if (this.geocodeSearch) {
      try {
        const latLonPoint: LatLonPoint = new LatLonPoint(point.latitude, point.longitude);
        const query: ReGeocodeQuery = new ReGeocodeQuery(latLonPoint, 200, GeocodeSearch.AMAP);
        const address: ReGeocodeAddress | undefined = await this.geocodeSearch.getFromLocation(query);
        
        if (address) {
          const district = address.getDistrict() || '';
          const township = address.getTownship() || '';
          const street = address.getStreetNumber()?.getStreet() || '';
          this.pendingSpotAddress = `${district}${township}${street}`.trim() || 
            `${point.latitude.toFixed(4)}, ${point.longitude.toFixed(4)}`;
        } else {
          this.pendingSpotAddress = `${point.latitude.toFixed(4)}, ${point.longitude.toFixed(4)}`;
        }
      } catch (error) {
        this.pendingSpotAddress = `${point.latitude.toFixed(4)}, ${point.longitude.toFixed(4)}`;
      }
    }
    
    // 重置表单
    this.customSpotName = '';
    this.customSpotNote = '';
    this.customSpotWaterType = WaterType.POND;
    
    // 显示添加钓点弹窗
    this.showAddSpotDialog = true;
    this.isAddingCustomSpot = false;
    this.currentLocation = this.fishingSpots.length > 0 
      ? `发现 ${this.fishingSpots.length} 个钓点` 
      : '附近暂无钓点';
  }

  // 查找附近的POI钓点
  private findNearbySpot(point: LatLng, radiusMeters: number): FishingSpot | null {
    for (const spot of this.fishingSpots) {
      const distance = this.calculateDistance(point.latitude, point.longitude, spot.latitude, spot.longitude);
      if (distance <= radiusMeters) {
        return spot;
      }
    }
    return null;
  }

  // 查找附近的自定义钓点
  private findNearbyCustomSpot(point: LatLng, radiusMeters: number): UserCustomSpot | null {
    for (const spot of this.userCustomSpots) {
      const distance = this.calculateDistance(point.latitude, point.longitude, spot.latitude, spot.longitude);
      if (distance <= radiusMeters) {
        return spot;
      }
    }
    return null;
  }

  // 保存自定义钓�?
  private saveCustomSpot(): void {
    if (!this.pendingSpotLatLng) return;
    
    const newSpot: UserCustomSpot = {
      id: `custom_${Date.now()}`,
      name: this.customSpotName || `我的钓点${this.userCustomSpots.length + 1}`,
      latitude: this.pendingSpotLatLng.latitude,
      longitude: this.pendingSpotLatLng.longitude,
      note: this.customSpotNote,
      createTime: Date.now(),
      waterType: this.customSpotWaterType
    };
    
    this.userCustomSpots.push(newSpot);
    this.addCustomSpotMarker(newSpot);
    
    // 关闭弹窗
    this.showAddSpotDialog = false;
    this.pendingSpotLatLng = undefined;
    
    console.info(this.TAG, `保存自定义钓�? ${newSpot.name}`);
  }

  // 添加自定义钓点标�?
  private addCustomSpotMarker(spot: UserCustomSpot): void {
    if (!this.aMap) return;
    
    const options: MarkerOptions = new MarkerOptions();
    options.setPosition(new LatLng(spot.latitude, spot.longitude));
    options.setTitle(`🎣 ${spot.name}`);
    options.setSnippet(spot.note || WaterTypeNames[spot.waterType]);
    
    // 使用 hooks.png 图标
    if (this.hooksIcon) {
      options.setIcon(this.hooksIcon);
    } else {
      // 备用：使用紫色标�?
      options.setIcon(BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_VIOLET));
    }
    options.setAnchor(0.5, 1.0);
    options.setZIndex(100);
    
    const marker = this.aMap.addMarker(options);
    if (marker) {
      this.customSpotMarkers.push(marker);
    }
  }

  // 刷新所有自定义钓点标记
  private refreshCustomSpotMarkers(): void {
    // 清除现有标记
    for (const marker of this.customSpotMarkers) {
      marker.remove();
    }
    this.customSpotMarkers = [];
    
    // 重新添加
    for (const spot of this.userCustomSpots) {
      this.addCustomSpotMarker(spot);
    }
  }

  // 删除自定义钓�?
  private deleteCustomSpot(spotId: string): void {
    const index = this.userCustomSpots.findIndex(s => s.id === spotId);
    if (index > -1) {
      this.userCustomSpots.splice(index, 1);
      this.refreshCustomSpotMarkers();
      this.showCustomSpotDetail = false;
      this.selectedCustomSpot = null;
    }
  }

  // 点击自定义钓�?
  private onCustomSpotClick(spot: UserCustomSpot): void {
    this.selectedCustomSpot = spot;
    this.showCustomSpotDetail = true;
    
    // 移动地图到该位置
    if (this.aMap) {
      const update: CameraUpdate = CameraUpdateFactory.newLatLngZoom(
        new LatLng(spot.latitude, spot.longitude), 15
      );
      this.aMap.animateCamera(update);
    }
  }

  // 格式化时�?
  private formatTime(timestamp: number): string {
    const date = new Date(timestamp);
    return `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate().toString().padStart(2, '0')} ${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
  }

  build() {
    Stack() {
      Column() {
        // 顶部导航�?
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

          // 我的钓点列表按钮
          Text('📋')
            .fontSize(20)
            .margin({ right: 12 })
            .onClick(() => { this.showMySpotsList = true })

          Text('📍')
            .fontSize(20)
            .onClick(() => this.moveToCurrentLocation())
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .margin({ top: 44 })
        .backgroundColor(ThemeColors.BG_SECONDARY)

        // 状态提�?
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
          Blank()
          Text('🔄')
            .fontSize(16)
            .onClick(() => this.refreshLocation())
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
              .fontColor(ThemeColors.PRIMARY_DARK)
              .fontWeight(FontWeight.Medium)
              .layoutWeight(1)
            Text('�?)
              .fontSize(14)
              .fontColor(ThemeColors.TEXT_SECONDARY)
              .onClick(() => { this.clickedLocationName = '' })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 6, bottom: 6 })
          .backgroundColor('#E3F2FD')
        }

        // 高德地图
        Stack() {
          MapViewComponent({ mapViewName: MAP_VIEW_NAME })
            .width('100%')
            .height('100%')

          if (!this.isMapReady) {
            Column() {
              LoadingProgress().width(48).height(48).color(ThemeColors.PRIMARY)
              Text('地图加载�?..').fontSize(14).fontColor(ThemeColors.TEXT_SECONDARY).margin({ top: 12 })
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Center)
            .backgroundColor(ThemeColors.BG_PRIMARY)
          }

          // 地图类型切换按钮
          if (this.isMapReady) {
            Column() {
              Text('🗺�?)
                .fontSize(20)
                .padding(10)
                .backgroundColor('rgba(255,255,255,0.95)')
                .borderRadius(8)
                .shadow({ radius: 4, color: 'rgba(0,0,0,0.15)' })
                .onClick(() => { this.showMapTypePanel = !this.showMapTypePanel })
            }
            .position({ x: 16, y: 16 })

            // 添加钓点按钮
            Column() {
              Row() {
                Image($r('app.media.hooks'))
                  .width(24)
                  .height(24)
                Text(this.isAddingCustomSpot ? '取消' : '打点')
                  .fontSize(13)
                  .fontColor(this.isAddingCustomSpot ? '#F44336' : ThemeColors.PRIMARY)
                  .margin({ left: 4 })
              }
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .backgroundColor(this.isAddingCustomSpot ? '#FFEBEE' : 'rgba(255,255,255,0.95)')
              .borderRadius(20)
              .shadow({ radius: 4, color: 'rgba(0,0,0,0.15)' })
              .onClick(() => this.toggleAddSpotMode())
            }
            .position({ x: 16, y: 70 })
          }

          // 地图类型选择面板
          if (this.showMapTypePanel) {
            Column({ space: 8 }) {
              this.MapTypeButton('🗺�?, '普�?, 0)
              this.MapTypeButton('🛰�?, '卫星', 1)
              this.MapTypeButton('🌙', '夜间', 2)
            }
            .padding(12)
            .backgroundColor('rgba(255,255,255,0.98)')
            .borderRadius(12)
            .shadow({ radius: 8, color: 'rgba(0,0,0,0.2)' })
            .position({ x: 16, y: 120 })
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

      // 添加自定义钓点弹�?
      if (this.showAddSpotDialog) {
        this.AddCustomSpotDialog()
      }

      // 自定义钓点详情弹�?
      if (this.showCustomSpotDetail && this.selectedCustomSpot) {
        this.CustomSpotDetailDialog()
      }

      // 我的钓点列表弹窗
      if (this.showMySpotsList) {
        this.MySpotListDialog()
      }

      // 路线规划面板
      if (this.showRoutePanel) {
        this.RoutePlanPanel()
      }
    }
    .width('100%')
    .height('100%')
  }

  // 路线规划面板
  @Builder
  RoutePlanPanel() {
    Column() {
      // 顶部信息�?
      Row() {
        Column() {
          Text(this.selectedSpot?.name || '钓点')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.TEXT_PRIMARY)
          if (this.routeInfo) {
            Text(this.routeInfo)
              .fontSize(13)
              .fontColor(ThemeColors.PRIMARY_DARK)
              .margin({ top: 4 })
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text('�?)
          .fontSize(22)
          .fontColor(ThemeColors.TEXT_SECONDARY)
          .padding(8)
          .onClick(() => this.closeRoutePanel())
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor(ThemeColors.BG_PRIMARY)

      // 出行方式选择
      Row({ space: 12 }) {
        this.RouteTypeButton('🚗', '驾车', 'drive')
        this.RouteTypeButton('🚶', '步行', 'walk')
        this.RouteTypeButton('🚴', '骑行', 'ride')
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 12 })
      .backgroundColor(ThemeColors.BG_PRIMARY)
      .justifyContent(FlexAlign.Center)

      // 路线信息
      if (this.routeDistance > 0) {
        Row() {
          Column() {
            Text(this.formatRouteDistance(this.routeDistance))
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(ThemeColors.PRIMARY_DARK)
            Text('总距�?)
              .fontSize(12)
              .fontColor(ThemeColors.TEXT_SECONDARY)
          }
          .layoutWeight(1)

          Column() {
            Text(this.formatRouteDuration(this.routeDuration))
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(ThemeColors.PRIMARY_DARK)
            Text('预计时间')
              .fontSize(12)
              .fontColor(ThemeColors.TEXT_SECONDARY)
          }
          .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 24 })
        .backgroundColor('#E8F5E9')
      }

      // 加载中提�?
      if (this.isRouteSearching) {
        Row() {
          LoadingProgress()
            .width(20)
            .height(20)
            .color(ThemeColors.PRIMARY)
          Text('正在规划路线...')
            .fontSize(13)
            .fontColor(ThemeColors.TEXT_SECONDARY)
            .margin({ left: 8 })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 24 })
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .backgroundColor(ThemeColors.BG_PRIMARY)
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.15)', offsetY: -2 })
    .position({ x: 0, y: '100%' })
    .translate({ y: -260 })
  }

  @Builder
  RouteTypeButton(icon: string, label: string, type: RouteType) {
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
        this.searchRoute();
      }
    })
  }

  @Builder
  MapTypeButton(icon: string, label: string, type: number) {
    Row() {
      Text(icon)
        .fontSize(18)
        .margin({ right: 8 })
      Text(label)
        .fontSize(14)
        .fontColor(this.currentMapType === type ? ThemeColors.PRIMARY : ThemeColors.TEXT_PRIMARY)
        .fontWeight(this.currentMapType === type ? FontWeight.Bold : FontWeight.Normal)
      if (this.currentMapType === type) {
        Text('�?)
          .fontSize(14)
          .fontColor(ThemeColors.PRIMARY_DARK)
          .margin({ left: 8 })
      }
    }
    .width(100)
    .height(40)
    .padding({ left: 12, right: 12 })
    .backgroundColor(this.currentMapType === type ? '#E3F2FD' : '#f5f5f5')
    .borderRadius(8)
    .onClick(() => this.switchMapType(type))
  }

  @Builder
  BaitRecommendDialog() {
    Stack() {
      // 遮罩
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.5)')
        .onClick(() => { this.showBaitDialog = false })

      // 弹窗内容
      Column() {
        // 标题
        Row() {
          Image(WaterTypeImages[this.selectedSpot!.waterType].active)
            .width(24)
            .height(24)
            .margin({ right: 8 })
          Text(this.selectedSpot!.name)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.TEXT_PRIMARY)
            .layoutWeight(1)
          Text('�?)
            .fontSize(20)
            .fontColor(ThemeColors.TEXT_SECONDARY)
            .onClick(() => { this.showBaitDialog = false })
        }
        .width('100%')
        .margin({ bottom: 8 })

        Text(`${WaterTypeNames[this.selectedSpot!.waterType]} · ${this.selectedSpot!.description}`)
          .fontSize(13)
          .fontColor(ThemeColors.TEXT_SECONDARY)
          .margin({ bottom: 8 })

        if (this.selectedSpot!.distance) {
          Text(`距您 ${this.formatDistance(this.selectedSpot!.distance)}`)
            .fontSize(12)
            .fontColor(ThemeColors.PRIMARY_DARK)
            .margin({ bottom: 16 })
        }

        Divider().color('#eee').margin({ bottom: 16 })

        Text('🎣 推荐配方')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.TEXT_PRIMARY)
          .margin({ bottom: 12 })

        // 配方列表 - 可滚�?
        Scroll() {
          Column({ space: 12 }) {
            ForEach(this.recommendedRecipes, (recipe: Recipe) => {
              Column() {
                // 配方名称和评�?
                Row() {
                  Text(recipe.name)
                    .fontSize(15)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(ThemeColors.TEXT_PRIMARY)
                    .layoutWeight(1)
                  Row() {
                    Text('�?)
                      .fontSize(12)
                    Text(recipe.rating.toFixed(1))
                      .fontSize(12)
                      .fontColor('#FF9800')
                      .fontWeight(FontWeight.Medium)
                  }
                }
                .width('100%')
                .margin({ bottom: 6 })

                // 目标鱼种和难�?
                Row() {
                  Text(`🐟 ${recipe.targetFish.join('�?)}`)
                    .fontSize(11)
                    .fontColor(ThemeColors.PRIMARY_DARK)
                  Blank()
                  Text(`难度: ${recipe.difficulty}`)
                    .fontSize(11)
                    .fontColor('#999')
                  Text(` · ${recipe.prepTime}`)
                    .fontSize(11)
                    .fontColor('#999')
                }
                .width('100%')
                .margin({ bottom: 8 })

                // 材料
                Text('📦 材料:')
                  .fontSize(12)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(ThemeColors.TEXT_PRIMARY)
                  .margin({ bottom: 4 })
                Text(recipe.ingredients.map(i => `${i.name}${i.amount}${i.unit}`).join('�?))
                  .fontSize(11)
                  .fontColor(ThemeColors.TEXT_SECONDARY)
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .margin({ bottom: 8 })

                // 步骤摘要
                Text('📝 步骤:')
                  .fontSize(12)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(ThemeColors.TEXT_PRIMARY)
                  .margin({ bottom: 4 })
                Text(recipe.steps.slice(0, 2).join(' �?') + (recipe.steps.length > 2 ? '...' : ''))
                  .fontSize(11)
                  .fontColor(ThemeColors.TEXT_SECONDARY)
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .margin({ bottom: 8 })

                // 小贴�?
                if (recipe.tips.length > 0) {
                  Text('💡 ' + recipe.tips[0])
                    .fontSize(11)
                    .fontColor('#FF9800')
                    .fontStyle(FontStyle.Italic)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }

                // 季节标签
                Row({ space: 4 }) {
                  ForEach(recipe.seasons, (season: string) => {
                    Text(season)
                      .fontSize(10)
                      .fontColor('#666')
                      .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                      .backgroundColor('#f0f0f0')
                      .borderRadius(4)
                  })
                }
                .width('100%')
                .margin({ top: 8 })
              }
              .width('100%')
              .padding(12)
              .backgroundColor(ThemeColors.BG_SECONDARY)
              .borderRadius(10)
            })
          }
        }
        .height(320)
        .scrollBar(BarState.Auto)

        Button('换一批推�?)
          .width('100%')
          .height(44)
          .fontSize(14)
          .backgroundColor(ThemeColors.PRIMARY)
          .fontColor(Color.White)
          .margin({ top: 12 })
          .onClick(() => {
            this.recommendedRecipes = this.recommendRecipes(this.selectedSpot!.waterType);
          })

        // 导航按钮
        Button('🧭 导航前往')
          .width('100%')
          .height(44)
          .fontSize(14)
          .backgroundColor('#4CAF50')
          .fontColor(Color.White)
          .margin({ top: 8 })
          .onClick(() => {
            this.startNavigation(this.selectedSpot!);
          })
      }
      .width('90%')
      .padding(20)
      .backgroundColor(ThemeColors.BG_PRIMARY)
      .borderRadius(16)
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
  }

  // 添加自定义钓点弹�?
  @Builder
  AddCustomSpotDialog() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.5)')
        .onClick(() => { this.showAddSpotDialog = false })

      Column() {
        // 标题
        Row() {
          Image($r('app.media.hooks'))
            .width(24)
            .height(24)
          Text('添加我的钓点')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.TEXT_PRIMARY)
            .margin({ left: 8 })
            .layoutWeight(1)
          Text('�?)
            .fontSize(20)
            .fontColor(ThemeColors.TEXT_SECONDARY)
            .onClick(() => { this.showAddSpotDialog = false })
        }
        .width('100%')
        .margin({ bottom: 16 })

        // 位置信息
        Row() {
          Text('📍')
            .fontSize(16)
          Text(this.pendingSpotAddress)
            .fontSize(13)
            .fontColor(ThemeColors.TEXT_SECONDARY)
            .margin({ left: 8 })
            .layoutWeight(1)
        }
        .width('100%')
        .padding(12)
        .backgroundColor('#f5f5f5')
        .borderRadius(8)
        .margin({ bottom: 16 })

        // 钓点名称
        Text('钓点名称')
          .fontSize(14)
          .fontColor(ThemeColors.TEXT_PRIMARY)
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 8 })
        TextInput({ placeholder: '给这个钓点起个名�?, text: this.customSpotName })
          .width('100%')
          .height(44)
          .fontSize(14)
          .backgroundColor('#f5f5f5')
          .borderRadius(8)
          .padding({ left: 12, right: 12 })
          .onChange((value: string) => { this.customSpotName = value })
          .margin({ bottom: 16 })

        // 水域类型选择
        Text('水域类型')
          .fontSize(14)
          .fontColor(ThemeColors.TEXT_PRIMARY)
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 8 })
        Row({ space: 8 }) {
          this.WaterTypeChip(WaterType.POND, '池塘', $r('app.media.Pond'), $r('app.media.Ponds'))
          this.WaterTypeChip(WaterType.RESERVOIR, '水库', $r('app.media.Reservoir'), $r('app.media.Reservoirs'))
          this.WaterTypeChip(WaterType.RIVER, '河流', $r('app.media.River'), $r('app.media.Rivers'))
          this.WaterTypeChip(WaterType.LAKE, '湖泊', $r('app.media.Lake'), $r('app.media.Lakes'))
        }
        .width('100%')
        .margin({ bottom: 16 })

        // 备注
        Text('备注信息')
          .fontSize(14)
          .fontColor(ThemeColors.TEXT_PRIMARY)
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 8 })
        TextArea({ placeholder: '记录鱼情、钓位、收费等信息...', text: this.customSpotNote })
          .width('100%')
          .height(80)
          .fontSize(14)
          .backgroundColor('#f5f5f5')
          .borderRadius(8)
          .padding(12)
          .onChange((value: string) => { this.customSpotNote = value })
          .margin({ bottom: 20 })

        // 保存按钮
        Button('保存钓点')
          .width('100%')
          .height(48)
          .fontSize(16)
          .backgroundColor(ThemeColors.PRIMARY)
          .fontColor(Color.White)
          .onClick(() => this.saveCustomSpot())
      }
      .width('90%')
      .padding(20)
      .backgroundColor(ThemeColors.BG_PRIMARY)
      .borderRadius(16)
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
  }

  @Builder
  WaterTypeChip(type: WaterType, label: string, normalIcon: Resource, activeIcon: Resource) {
    Row() {
      Image(this.customSpotWaterType === type ? activeIcon : normalIcon)
        .width(18)
        .height(18)
        .margin({ right: 4 })
      Text(label)
        .fontSize(12)
        .fontColor(this.customSpotWaterType === type ? Color.White : ThemeColors.TEXT_PRIMARY)
    }
    .padding({ left: 8, right: 10, top: 6, bottom: 6 })
    .backgroundColor(this.customSpotWaterType === type ? ThemeColors.PRIMARY : '#f0f0f0')
    .borderRadius(16)
    .onClick(() => { this.customSpotWaterType = type })
  }

  // 自定义钓点详情弹�?
  @Builder
  CustomSpotDetailDialog() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.5)')
        .onClick(() => { this.showCustomSpotDetail = false })

      Column() {
        // 标题
        Row() {
          Image($r('app.media.hooks'))
            .width(28)
            .height(28)
          Text(this.selectedCustomSpot!.name)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.TEXT_PRIMARY)
            .margin({ left: 8 })
            .layoutWeight(1)
          Text('�?)
            .fontSize(20)
            .fontColor(ThemeColors.TEXT_SECONDARY)
            .onClick(() => { this.showCustomSpotDetail = false })
        }
        .width('100%')
        .margin({ bottom: 16 })

        // 水域类型
        Row() {
          Image(WaterTypeImages[this.selectedCustomSpot!.waterType].active)
            .width(20)
            .height(20)
          Text(WaterTypeNames[this.selectedCustomSpot!.waterType])
            .fontSize(14)
            .fontColor(ThemeColors.PRIMARY_DARK)
            .margin({ left: 6 })
        }
        .margin({ bottom: 12 })

        // 坐标
        Row() {
          Text('📍 坐标: ')
            .fontSize(13)
            .fontColor(ThemeColors.TEXT_SECONDARY)
          Text(`${this.selectedCustomSpot!.latitude.toFixed(6)}, ${this.selectedCustomSpot!.longitude.toFixed(6)}`)
            .fontSize(13)
            .fontColor(ThemeColors.TEXT_PRIMARY)
        }
        .width('100%')
        .margin({ bottom: 8 })

        // 创建时间
        Row() {
          Text('🕐 添加时间: ')
            .fontSize(13)
            .fontColor(ThemeColors.TEXT_SECONDARY)
          Text(this.formatTime(this.selectedCustomSpot!.createTime))
            .fontSize(13)
            .fontColor(ThemeColors.TEXT_PRIMARY)
        }
        .width('100%')
        .margin({ bottom: 16 })

        // 备注
        if (this.selectedCustomSpot!.note) {
          Text('📝 备注')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(ThemeColors.TEXT_PRIMARY)
            .margin({ bottom: 8 })
          Text(this.selectedCustomSpot!.note)
            .fontSize(14)
            .fontColor(ThemeColors.TEXT_SECONDARY)
            .width('100%')
            .padding(12)
            .backgroundColor('#f5f5f5')
            .borderRadius(8)
            .margin({ bottom: 16 })
        }

        Divider().color('#eee').margin({ bottom: 16 })

        // 操作按钮
        Row({ space: 12 }) {
          Button('查看配方推荐')
            .layoutWeight(1)
            .height(44)
            .fontSize(14)
            .backgroundColor(ThemeColors.PRIMARY)
            .fontColor(Color.White)
            .onClick(() => {
              // 转换�?FishingSpot 格式并显示配�?
              const spot: FishingSpot = {
                id: this.selectedCustomSpot!.id,
                name: this.selectedCustomSpot!.name,
                latitude: this.selectedCustomSpot!.latitude,
                longitude: this.selectedCustomSpot!.longitude,
                waterType: this.selectedCustomSpot!.waterType,
                description: this.selectedCustomSpot!.note || WaterTypeNames[this.selectedCustomSpot!.waterType]
              };
              this.selectedSpot = spot;
              this.recommendedRecipes = this.recommendRecipes(spot.waterType);
              this.showCustomSpotDetail = false;
              this.showBaitDialog = true;
            })

          Button('删除')
            .width(80)
            .height(44)
            .fontSize(14)
            .backgroundColor('#FFEBEE')
            .fontColor('#F44336')
            .onClick(() => {
              this.deleteCustomSpot(this.selectedCustomSpot!.id);
            })
        }
        .width('100%')
      }
      .width('90%')
      .padding(20)
      .backgroundColor(ThemeColors.BG_PRIMARY)
      .borderRadius(16)
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
  }

  // 我的钓点列表弹窗
  @Builder
  MySpotListDialog() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.5)')
        .onClick(() => { this.showMySpotsList = false })

      Column() {
        // 标题
        Row() {
          Image($r('app.media.hooks'))
            .width(24)
            .height(24)
          Text('我的钓点')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.TEXT_PRIMARY)
            .margin({ left: 8 })
            .layoutWeight(1)
          Text(`�?${this.userCustomSpots.length} 个`)
            .fontSize(13)
            .fontColor(ThemeColors.TEXT_SECONDARY)
            .margin({ right: 12 })
          Text('�?)
            .fontSize(20)
            .fontColor(ThemeColors.TEXT_SECONDARY)
            .onClick(() => { this.showMySpotsList = false })
        }
        .width('100%')
        .margin({ bottom: 16 })

        if (this.userCustomSpots.length === 0) {
          // 空状�?
          Column() {
            Text('🎣')
              .fontSize(48)
              .margin({ bottom: 12 })
            Text('还没有添加钓�?)
              .fontSize(15)
              .fontColor(ThemeColors.TEXT_SECONDARY)
            Text('点击地图上的"打点"按钮添加')
              .fontSize(13)
              .fontColor('#999')
              .margin({ top: 8 })
          }
          .width('100%')
          .height(200)
          .justifyContent(FlexAlign.Center)
        } else {
          // 钓点列表
          Scroll() {
            Column({ space: 10 }) {
              ForEach(this.userCustomSpots, (spot: UserCustomSpot) => {
                Row() {
                  Image($r('app.media.hooks'))
                    .width(36)
                    .height(36)
                    .margin({ right: 12 })

                  Column() {
                    Text(spot.name)
                      .fontSize(15)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(ThemeColors.TEXT_PRIMARY)
                    Row() {
                      Image(WaterTypeImages[spot.waterType].normal)
                        .width(14)
                        .height(14)
                      Text(WaterTypeNames[spot.waterType])
                        .fontSize(12)
                        .fontColor(ThemeColors.TEXT_SECONDARY)
                        .margin({ left: 4 })
                      if (spot.note) {
                        Text(' · ')
                          .fontSize(12)
                          .fontColor('#ccc')
                        Text(spot.note)
                          .fontSize(12)
                          .fontColor(ThemeColors.TEXT_SECONDARY)
                          .maxLines(1)
                          .textOverflow({ overflow: TextOverflow.Ellipsis })
                          .layoutWeight(1)
                      }
                    }
                    .margin({ top: 4 })
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)

                  Text('�?)
                    .fontSize(20)
                    .fontColor('#ccc')
                }
                .width('100%')
                .padding(12)
                .backgroundColor(ThemeColors.BG_SECONDARY)
                .borderRadius(10)
                .onClick(() => {
                  this.showMySpotsList = false;
                  this.onCustomSpotClick(spot);
                })
              })
            }
          }
          .height(300)
          .scrollBar(BarState.Auto)
        }

        // 添加钓点按钮
        Button('+ 添加新钓�?)
          .width('100%')
          .height(48)
          .fontSize(15)
          .backgroundColor(ThemeColors.PRIMARY)
          .fontColor(Color.White)
          .margin({ top: 16 })
          .onClick(() => {
            this.showMySpotsList = false;
            this.toggleAddSpotMode();
          })
      }
      .width('90%')
      .padding(20)
      .backgroundColor(ThemeColors.BG_PRIMARY)
      .borderRadius(16)
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
  }
}
