/**
 * 饵知道 - 首页
 * 天气信息、快速配方生成、附近渔点
 */
import { ThemeColors } from '../theme/ThemeColors';
import { ThemeConstants } from '../theme/ThemeConstants';
import { AppConstants } from '../common/constants/AppConstants';
import { router } from '@kit.ArkUI';
import { FishingSpotService } from '../services/FishingSpotService';
import { FishingSpot, BaitInfo, WaterTypeNames, WaterTypeImages } from '../data/FishingSpotData';
import { LocationService } from '../services/LocationService';
import { WeatherData, FishingIndex, fetchWeather, calculateFishingIndex } from '../services/WeatherService';
import { ALL_FISH_DATA, FishData, getFishByWaterType } from '../data/FishData';
import { site } from '@kit.MapKit';

// 水域选项接口
interface WaterOption {
  type: string;
  label: string;
  icon: Resource;
  iconActive: Resource;
}

@Component
export struct HomePage {
  @State selectedFish: string = 'crucian';
  @State selectedWater: string = AppConstants.WATER_RIVER;
  @State temperature: number = 0;
  @State weather: string = '--';
  @State city: string = '定位中...';
  @State windInfo: string = '-- --';
  @State pressure: number = 0;
  @State fishingIndex: FishingIndex = { level: '未知', color: '#999999', description: '加载中...' };
  @State isLoadingWeather: boolean = true;
  @State fishingSpots: FishingSpot[] = [];
  @State isLoadingSpots: boolean = false;
  @State showBaitDialog: boolean = false;
  @State selectedSpot: FishingSpot | null = null;
  @State recommendedBaits: BaitInfo[] = [];
  @State showFishPicker: boolean = false;
  @State currentFishList: FishData[] = [];  // 当前水域的鱼种列表（缓存）

  // 水域选项（四大类：池塘、河流、水库、湖泊）
  private waterOptions: WaterOption[] = [
    { type: AppConstants.WATER_POND, label: '池塘', icon: $r('app.media.Pond'), iconActive: $r('app.media.Ponds') },
    { type: AppConstants.WATER_RIVER, label: '河流', icon: $r('app.media.River'), iconActive: $r('app.media.Rivers') },
    { type: AppConstants.WATER_RESERVOIR, label: '水库', icon: $r('app.media.Reservoir'), iconActive: $r('app.media.Reservoirs') },
    { type: AppConstants.WATER_LAKE, label: '湖泊', icon: $r('app.media.Lake'), iconActive: $r('app.media.Lakes') }
  ];

  // 预缓存各水域鱼种（避免重复计算）
  private waterFishCache: Record<string, FishData[]> = {};

  // 更新当前水域的鱼种列表
  private updateCurrentFishList(): void {
    if (!this.waterFishCache[this.selectedWater]) {
      this.waterFishCache[this.selectedWater] = getFishByWaterType(this.selectedWater);
    }
    this.currentFishList = this.waterFishCache[this.selectedWater];
  }

  aboutToAppear(): void {
    // 初始化鱼种列表
    this.updateCurrentFishList();

    // 加载缓存的钓点数据
    this.fishingSpots = FishingSpotService.cachedSpots;

    // 根据附近渔点自动选择最多的水域类型
    this.autoSelectWaterType();

    // 如果没有缓存，主动搜索
    if (this.fishingSpots.length === 0) {
      this.loadNearbySpots();
    }

    // 加载天气数据
    this.loadWeather();
  }

  // 根据附近渔点自动选择最多的水域类型
  private autoSelectWaterType(): void {
    if (this.fishingSpots.length === 0) return;

    // 统计各水域类型数量
    const waterCount: Record<string, number> = {
      'pond': 0,
      'river': 0,
      'reservoir': 0,
      'lake': 0
    };

    this.fishingSpots.forEach((spot: FishingSpot) => {
      if (waterCount[spot.waterType] !== undefined) {
        waterCount[spot.waterType]++;
      }
    });

    // 找出数量最多的水域类型
    let maxType = AppConstants.WATER_RIVER;
    let maxCount = 0;
    const types = Object.keys(waterCount);
    for (let i = 0; i < types.length; i++) {
      const t = types[i];
      if (waterCount[t] > maxCount) {
        maxCount = waterCount[t];
        maxType = t;
      }
    }

    // 设置选中的水域类型
    if (maxCount > 0 && this.selectedWater !== maxType) {
      this.selectedWater = maxType;
      this.updateCurrentFishList();
      // 同时更新鱼种为该水域的第一个
      if (this.currentFishList.length > 0) {
        this.selectedFish = this.currentFishList[0].id;
      }
    }
  }

  // 加载天气数据
  async loadWeather(): Promise<void> {
    this.isLoadingWeather = true;
    try {
      const weatherData = await fetchWeather();
      if (weatherData.isValid) {
        this.temperature = Math.round(weatherData.temperature);
        this.weather = weatherData.weatherText;
        this.windInfo = `${weatherData.windDirection} ${weatherData.windSpeed}km/h`;
        this.pressure = Math.round(weatherData.pressure);
        this.fishingIndex = calculateFishingIndex(weatherData);

        // 获取城市名（逆地理编码）
        await this.fetchCityName();
      }
    } catch (err) {
      console.error('Load weather failed:', err);
    } finally {
      this.isLoadingWeather = false;
    }
  }

  // 获取城市名称
  async fetchCityName(): Promise<void> {
    const location = LocationService.currentLocation;
    if (!location.isValid) {
      this.city = '未知位置';
      return;
    }

    try {
      const params: site.ReverseGeocodeParams = {
        location: {
          latitude: location.latitude,
          longitude: location.longitude
        },
        language: 'zh',
        radius: 100
      };

      const result = await site.reverseGeocode(params);
      if (result && result.addressComponent) {
        const addr = result.addressComponent;
        // 显示"市+区"，如"武汉市 江岸区"
        if (addr.adminLevel2 && addr.adminLevel3) {
          this.city = `${addr.adminLevel2} ${addr.adminLevel3}`;
        } else if (addr.adminLevel2) {
          this.city = addr.adminLevel2;
        } else if (addr.adminLevel3) {
          this.city = addr.adminLevel3;
        } else {
          this.city = '当前位置';
        }
      }
    } catch (err) {
      console.error('Fetch city name failed:', err);
      this.city = '当前位置';
    }
  }

  // 加载附近钓点
  async loadNearbySpots(): Promise<void> {
    const location = LocationService.currentLocation;
    if (!location.isValid) return;

    this.isLoadingSpots = true;
    try {
      this.fishingSpots = await FishingSpotService.searchNearbySpots(
        location.latitude, location.longitude, 5000
      );
      FishingSpotService.updateCachedSpots(this.fishingSpots);
      // 加载完成后自动选择最多的水域类型
      this.autoSelectWaterType();
    } catch (err) {
      console.error('Load spots failed:', err);
    } finally {
      this.isLoadingSpots = false;
    }
  }

  // 跳转到路线详情
  navigateToRoute(spot: FishingSpot): void {
    router.pushUrl({
      url: 'pages/RouteDetailPage',
      params: { spotId: spot.id }
    });
  }

  // 点击钓点显示饵料推荐
  onSpotClick(spot: FishingSpot): void {
    this.selectedSpot = spot;
    this.recommendedBaits = FishingSpotService.recommendBaits(spot.waterType);
    this.showBaitDialog = true;
  }

  private getSelectedFishName(): string {
    const fish = ALL_FISH_DATA.find((f: FishData) => f.id === this.selectedFish);
    return fish ? `${fish.name} (${fish.nameEn})` : '';
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: ThemeConstants.SPACE_MD }) {
          // 顶部标题栏
          this.HeaderBar()

          // 天气卡片
          this.WeatherCard()

          // 智能配方区域
          this.GeneratorSection()

          // 附近渔点
          this.NearbySpots()
        }
        .width('100%')
        .padding({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD, bottom: 80 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(ThemeColors.BG_PRIMARY)
      .scrollBar(BarState.Off)

      // 饵料推荐弹窗
      if (this.showBaitDialog && this.selectedSpot) {
        this.BaitRecommendDialog()
      }

      // 鱼种选择弹窗
      if (this.showFishPicker) {
        this.FishPickerDialog()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  HeaderBar() {
    Row() {
      Row({ space: 8 }) {
        Image($r('app.media.hooks'))
          .width(28)
          .height(28)
        Text(AppConstants.APP_NAME)
          .fontSize(ThemeConstants.FONT_SIZE_XL)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.TEXT_PRIMARY)
      }
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .margin({ top: 44 })
  }

  @Builder
  WeatherCard() {
    Column({ space: ThemeConstants.SPACE_SM }) {
      // 钓鱼指数
      Row({ space: 6 }) {
        Circle()
          .width(8)
          .height(8)
          .fill(this.fishingIndex.color)
        Text(`钓鱼指数: ${this.fishingIndex.level}`)
          .fontSize(ThemeConstants.FONT_SIZE_SM)
          .fontColor(this.fishingIndex.color)
      }
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .backgroundColor(this.fishingIndex.level === '适宜' ? 'rgba(76, 175, 80, 0.15)' :
        this.fishingIndex.level === '一般' ? 'rgba(255, 152, 0, 0.15)' : 'rgba(244, 67, 54, 0.15)')
      .borderRadius(ThemeConstants.RADIUS_FULL)

      // 温度和天气
      Row() {
        Column({ space: 4 }) {
          if (this.isLoadingWeather) {
            Row() {
              LoadingProgress().width(24).height(24)
              Text('加载中...').fontSize(14).fontColor(ThemeColors.TEXT_SECONDARY).margin({ left: 8 })
            }
          } else {
            Text(`${this.temperature}°C`)
              .fontSize(ThemeConstants.FONT_SIZE_4XL)
              .fontWeight(FontWeight.Bold)
              .fontColor(ThemeColors.TEXT_PRIMARY)
            Text(`${this.weather} · ${this.city}`)
              .fontSize(ThemeConstants.FONT_SIZE_SM)
              .fontColor(ThemeColors.TEXT_SECONDARY)
          }
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        // 天气图标
        Row() {
          Text(this.getWeatherEmoji())
            .fontSize(32)
        }
        .width(56)
        .height(56)
        .backgroundColor(ThemeColors.BG_TERTIARY)
        .borderRadius(ThemeConstants.RADIUS_BASE)
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')

      // 风向和气压
      Row({ space: ThemeConstants.SPACE_MD }) {
        this.WeatherInfoItem('风向', this.windInfo)
        this.WeatherInfoItem('气压', `${this.pressure} hPa`)
      }
      .width('100%')
      .margin({ top: 8 })
    }
    .width('100%')
    .padding(ThemeConstants.SPACE_MD)
    .backgroundColor(ThemeColors.BG_CARD)
    .borderRadius(ThemeConstants.RADIUS_MD)
  }

  // 根据天气获取emoji
  private getWeatherEmoji(): string {
    if (this.weather.includes('晴')) return '☀️';
    if (this.weather.includes('云')) return '⛅';
    if (this.weather.includes('阴')) return '☁️';
    if (this.weather.includes('雨')) return '🌧️';
    if (this.weather.includes('雪')) return '❄️';
    if (this.weather.includes('雷')) return '⛈️';
    if (this.weather.includes('雾') || this.weather.includes('霾')) return '🌫️';
    return '🌤️';
  }

  @Builder
  WeatherInfoItem(label: string, value: string) {
    Row({ space: 8 }) {
      Text('→')
        .fontSize(14)
        .fontColor(ThemeColors.TEXT_MUTED)
      Column({ space: 2 }) {
        Text(label)
          .fontSize(ThemeConstants.FONT_SIZE_XS)
          .fontColor(ThemeColors.TEXT_MUTED)
        Text(value)
          .fontSize(ThemeConstants.FONT_SIZE_SM)
          .fontColor(ThemeColors.TEXT_PRIMARY)
      }
      .alignItems(HorizontalAlign.Start)
    }
    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
    .backgroundColor(ThemeColors.BG_TERTIARY)
    .borderRadius(ThemeConstants.RADIUS_SM)
  }

  @Builder
  GeneratorSection() {
    Column({ space: ThemeConstants.SPACE_MD }) {
      // 标题
      Row() {
        Text('快速配方')
          .fontSize(ThemeConstants.FONT_SIZE_LG)
          .fontWeight(FontWeight.Medium)
          .fontColor(ThemeColors.TEXT_PRIMARY)
        Blank()
        Text('查看历史')
          .fontSize(ThemeConstants.FONT_SIZE_SM)
          .fontColor(ThemeColors.PRIMARY)
          .onClick(() => {
            router.pushUrl({ url: 'pages/GeneratorHistoryPage' });
          })
      }
      .width('100%')

      Text('根据天气和附近渔点，一键生成配方。')
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)

      // 目标鱼种选择
      Column({ space: 8 }) {
        Text('目标鱼种')
          .fontSize(ThemeConstants.FONT_SIZE_SM)
          .fontColor(ThemeColors.TEXT_SECONDARY)

        Row() {
          Text(this.getSelectedFishName())
            .fontSize(ThemeConstants.FONT_SIZE_BASE)
            .fontColor(ThemeColors.TEXT_PRIMARY)
          Blank()
          Text('▼')
            .fontSize(12)
            .fontColor(ThemeColors.TEXT_MUTED)
        }
        .width('100%')
        .height(ThemeConstants.HEIGHT_MD)
        .padding({ left: 12, right: 12 })
        .backgroundColor(ThemeColors.BG_TERTIARY)
        .borderRadius(ThemeConstants.RADIUS_SM)
        .onClick(() => {
          this.showFishPicker = true;
        })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      // 水域类型选择
      Column({ space: 8 }) {
        Text('水域类型')
          .fontSize(ThemeConstants.FONT_SIZE_SM)
          .fontColor(ThemeColors.TEXT_SECONDARY)

        // 水域按钮 2x2 布局
        Column({ space: 8 }) {
          Row({ space: 8 }) {
            ForEach(this.waterOptions.slice(0, 2), (option: WaterOption) => {
              this.WaterTypeButton(option)
            })
          }
          .width('100%')

          Row({ space: 8 }) {
            ForEach(this.waterOptions.slice(2, 4), (option: WaterOption) => {
              this.WaterTypeButton(option)
            })
          }
          .width('100%')
        }
        .width('100%')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      // 生成按钮
      Button() {
        Row({ space: 8 }) {
          Text('✨')
            .fontSize(16)
          Text('一键生成配方')
            .fontSize(ThemeConstants.FONT_SIZE_MD)
            .fontColor(ThemeColors.TEXT_PRIMARY)
            .fontWeight(FontWeight.Medium)
        }
      }
      .width('100%')
      .height(ThemeConstants.HEIGHT_LG)
      .backgroundColor(ThemeColors.PRIMARY)
      .borderRadius(ThemeConstants.RADIUS_SM)
      .margin({ top: 8 })
      .onClick(() => {
        // 直接跳转到配方详情页，传递鱼种和水域参数
        router.pushUrl({
          url: 'pages/GeneratedRecipePage',
          params: {
            fish: this.selectedFish,
            water: this.selectedWater,
            quickMode: true  // 快速模式标记
          }
        });
      })
    }
    .width('100%')
    .padding(ThemeConstants.SPACE_MD)
    .backgroundColor(ThemeColors.BG_CARD)
    .borderRadius(ThemeConstants.RADIUS_MD)
  }

  @Builder
  WaterTypeButton(option: WaterOption) {
    Row({ space: 6 }) {
      Image(this.selectedWater === option.type ? option.iconActive : option.icon)
        .width(16)
        .height(16)
        .fillColor(this.selectedWater === option.type ? ThemeColors.PRIMARY : ThemeColors.TEXT_MUTED)
      Text(option.label)
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(this.selectedWater === option.type ? ThemeColors.PRIMARY : ThemeColors.TEXT_SECONDARY)
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .padding({ top: 10, bottom: 10 })
    .backgroundColor(this.selectedWater === option.type ? 'rgba(232, 168, 73, 0.15)' : ThemeColors.BG_TERTIARY)
    .borderRadius(ThemeConstants.RADIUS_SM)
    .border({
      width: 1,
      color: this.selectedWater === option.type ? ThemeColors.PRIMARY : Color.Transparent
    })
    .onClick(() => {
      if (this.selectedWater === option.type) return;  // 避免重复点击
      this.selectedWater = option.type;
      this.updateCurrentFishList();
      // 切换水域时，重置鱼种为该水域的第一个鱼种
      if (this.currentFishList.length > 0 && !this.currentFishList.some((f: FishData) => f.id === this.selectedFish)) {
        this.selectedFish = this.currentFishList[0].id;
      }
    })
  }

  @Builder
  NearbySpots() {
    Column({ space: ThemeConstants.SPACE_MD }) {
      // 标题
      Row() {
        Text('附近渔点')
          .fontSize(ThemeConstants.FONT_SIZE_LG)
          .fontWeight(FontWeight.Medium)
          .fontColor(ThemeColors.TEXT_PRIMARY)
        Blank()
        Text('地图模式')
          .fontSize(ThemeConstants.FONT_SIZE_SM)
          .fontColor(ThemeColors.PRIMARY)
          .onClick(() => {
            router.pushUrl({ url: 'pages/MapPage' });
          })
      }
      .width('100%')

      // 加载中
      if (this.isLoadingSpots) {
        Row() {
          LoadingProgress().width(20).height(20)
          Text('搜索附近钓点...').fontSize(14).fontColor(ThemeColors.TEXT_SECONDARY).margin({ left: 8 })
        }
        .width('100%')
        .padding(16)
        .justifyContent(FlexAlign.Center)
      } else if (this.fishingSpots.length === 0) {
        // 无数据
        Text('暂无附近钓点，点击地图模式搜索')
          .fontSize(14)
          .fontColor(ThemeColors.TEXT_SECONDARY)
          .padding(16)
      } else {
        // 钓点列表
        ForEach(this.fishingSpots.slice(0, 5), (spot: FishingSpot) => {
          this.SpotCardReal(spot)
        })
      }
    }
    .width('100%')
  }

  @Builder
  SpotCardReal(spot: FishingSpot) {
    Row() {
      // 使用带颜色的河流图标
      Image($r('app.media.River'))
        .width(36)
        .height(36)
        .margin({ right: 12 })

      Column({ space: 4 }) {
        Text(spot.name)
          .fontSize(ThemeConstants.FONT_SIZE_BASE)
          .fontWeight(FontWeight.Medium)
          .fontColor(ThemeColors.TEXT_PRIMARY)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Row({ space: 4 }) {
          Text('📍')
            .fontSize(12)
          Text(`${FishingSpotService.formatDistance(spot.distance || 0)} · ${WaterTypeNames[spot.waterType]}`)
            .fontSize(ThemeConstants.FONT_SIZE_SM)
            .fontColor(ThemeColors.TEXT_SECONDARY)
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 饵料推荐按钮
      Row() {
        Text('🎣')
          .fontSize(14)
      }
      .width(32)
      .height(32)
      .backgroundColor(ThemeColors.BG_TERTIARY)
      .borderRadius(16)
      .justifyContent(FlexAlign.Center)
      .margin({ right: 8 })
      .onClick(() => this.onSpotClick(spot))

      // 导航按钮
      Row() {
        Text('→')
          .fontSize(16)
          .fontColor(ThemeColors.TEXT_PRIMARY)
      }
      .width(36)
      .height(36)
      .backgroundColor(ThemeColors.PRIMARY)
      .borderRadius(18)
      .justifyContent(FlexAlign.Center)
      .onClick(() => this.navigateToRoute(spot))
    }
    .width('100%')
    .padding(ThemeConstants.SPACE_MD)
    .backgroundColor(ThemeColors.BG_CARD)
    .borderRadius(ThemeConstants.RADIUS_MD)
    .margin({ bottom: 8 })
  }

  @Builder
  SpotCard(name: string, distance: string, desc: string) {
    Row() {
      Column({ space: 4 }) {
        Text(name)
          .fontSize(ThemeConstants.FONT_SIZE_BASE)
          .fontWeight(FontWeight.Medium)
          .fontColor(ThemeColors.TEXT_PRIMARY)
        Row({ space: 4 }) {
          Text('📍')
            .fontSize(12)
          Text(`${distance} · ${desc}`)
            .fontSize(ThemeConstants.FONT_SIZE_SM)
            .fontColor(ThemeColors.TEXT_SECONDARY)
        }
      }
      .alignItems(HorizontalAlign.Start)

      Blank()

      Row() {
        Text('→')
          .fontSize(16)
          .fontColor(ThemeColors.TEXT_PRIMARY)
      }
      .width(32)
      .height(32)
      .backgroundColor(ThemeColors.PRIMARY)
      .borderRadius(16)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .padding(ThemeConstants.SPACE_MD)
    .backgroundColor(ThemeColors.BG_CARD)
    .borderRadius(ThemeConstants.RADIUS_MD)
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
        Image(WaterTypeImages[this.selectedSpot!.waterType]?.active || $r('app.media.River'))
          .width(24)
          .height(24)
          .margin({ right: 8 })
        Text(this.selectedSpot!.name)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.TEXT_PRIMARY)
          .layoutWeight(1)
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

      // 底部按钮
      Row({ space: 12 }) {
        Button('换一批')
          .layoutWeight(1)
          .height(44)
          .fontSize(14)
          .backgroundColor(ThemeColors.BG_TERTIARY)
          .fontColor(ThemeColors.TEXT_PRIMARY)
          .onClick(() => {
            this.recommendedBaits = FishingSpotService.recommendBaits(this.selectedSpot!.waterType);
          })

        Button('去这里')
          .layoutWeight(1)
          .height(44)
          .fontSize(14)
          .backgroundColor(ThemeColors.PRIMARY)
          .fontColor(Color.White)
          .onClick(() => {
            this.showBaitDialog = false;
            this.navigateToRoute(this.selectedSpot!);
          })
      }
      .width('100%')
      .margin({ top: 8 })
    }
    .width('90%')
    .padding(20)
    .backgroundColor(ThemeColors.BG_PRIMARY)
    .borderRadius(16)
    .position({ x: '5%', y: '15%' })
  }

  @Builder
  FishPickerDialog() {
    // 遮罩层
    Column()
      .width('100%')
      .height('100%')
      .backgroundColor('rgba(0,0,0,0.5)')
      .position({ x: 0, y: 0 })
      .onClick(() => { this.showFishPicker = false })

    // 弹窗内容
    Column() {
      // 标题
      Row() {
        Text('选择目标鱼种')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.TEXT_PRIMARY)
        Blank()
        Text('✕')
          .fontSize(20)
          .fontColor(ThemeColors.TEXT_SECONDARY)
          .onClick(() => { this.showFishPicker = false })
      }
      .width('100%')
      .padding({ bottom: 12 })

      // 鱼种列表（可滚动）
      Scroll() {
        Column({ space: 8 }) {
          ForEach(this.currentFishList, (fish: FishData) => {
            Row() {
              // 鱼图片
              Image(fish.icon)
                .width(40)
                .height(40)
                .borderRadius(20)
                .margin({ right: 12 })

              Column({ space: 2 }) {
                Text(fish.name)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(ThemeColors.TEXT_PRIMARY)
                Text(fish.nameEn)
                  .fontSize(12)
                  .fontColor(ThemeColors.TEXT_SECONDARY)
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              // 选中标记
              if (this.selectedFish === fish.id) {
                Text('✓')
                  .fontSize(18)
                  .fontColor(ThemeColors.PRIMARY)
                  .fontWeight(FontWeight.Bold)
              }
            }
            .width('100%')
            .padding(12)
            .backgroundColor(this.selectedFish === fish.id ? 'rgba(232, 168, 73, 0.1)' : ThemeColors.BG_TERTIARY)
            .borderRadius(12)
            .border({
              width: this.selectedFish === fish.id ? 1 : 0,
              color: ThemeColors.PRIMARY
            })
            .onClick(() => {
              this.selectedFish = fish.id;
              this.showFishPicker = false;
            })
          })
        }
        .width('100%')
      }
      .width('100%')
      .constraintSize({ maxHeight: 400 })
      .scrollBar(BarState.Auto)
    }
    .width('85%')
    .padding(20)
    .backgroundColor(ThemeColors.BG_PRIMARY)
    .borderRadius(16)
    .position({ x: '7.5%', y: '15%' })
  }
}
