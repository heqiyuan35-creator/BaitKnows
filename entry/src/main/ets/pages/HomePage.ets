/**
 * 饵知�?- 首页
 * 天气信息、快速配方生成、附近渔�?
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
import { userDataService, CustomFish } from '../services/UserDataService';
import { site } from '@kit.MapKit';

// 水域选项接口
interface WaterOption {
  type: string;
  label: string;
  icon: Resource;
  iconActive: Resource;
}

// 推荐配方简化结�?
class RecommendRecipe {
  id: string = '';
  name: string = '';
  targetFish: string = '';
  ingredients: string[] = [];
  tags: string[] = [];
  catchRate: number = 0;

  constructor() {}
}

@Component
export struct HomePage {
  @State selectedFish: string = 'crucian';
  @State selectedWater: string = AppConstants.WATER_RIVER;
  @State temperature: number = 0;
  @State weather: string = '--';
  @State city: string = '定位�?..';
  @State windInfo: string = '-- --';
  @State pressure: number = 0;
  @State fishingIndex: FishingIndex = { level: '未知', color: '#999999', description: '加载�?..' };
  @State isLoadingWeather: boolean = true;
  @State fishingSpots: FishingSpot[] = [];
  @State isLoadingSpots: boolean = false;
  @State showBaitDialog: boolean = false;
  @State selectedSpot: FishingSpot | null = null;
  @State recommendedBaits: BaitInfo[] = [];
  @State recommendedRecipes: RecommendRecipe[] = [];
  @State showFishPicker: boolean = false;
  @State currentFishList: FishData[] = [];  // 当前水域的鱼种列表（缓存�?

  // 水域选项（四大类：池塘、河流、水库、湖泊）
  private waterOptions: WaterOption[] = [
    { type: AppConstants.WATER_POND, label: '池塘', icon: $r('app.media.Pond'), iconActive: $r('app.media.Ponds') },
    { type: AppConstants.WATER_RIVER, label: '河流', icon: $r('app.media.River'), iconActive: $r('app.media.Rivers') },
    { type: AppConstants.WATER_RESERVOIR, label: '水库', icon: $r('app.media.Reservoir'), iconActive: $r('app.media.Reservoirs') },
    { type: AppConstants.WATER_LAKE, label: '湖泊', icon: $r('app.media.Lake'), iconActive: $r('app.media.Lakes') }
  ];

  // 配方库数据（按水域分类）
  private recipeDatabase: Map<string, RecommendRecipe[]> = new Map();

  // 预缓存各水域鱼种（避免重复计算）
  private waterFishCache: Record<string, FishData[]> = {};

  // 更新当前水域的鱼种列�?
  private updateCurrentFishList(): void {
    if (!this.waterFishCache[this.selectedWater]) {
      this.waterFishCache[this.selectedWater] = getFishByWaterType(this.selectedWater);
    }
    this.currentFishList = this.waterFishCache[this.selectedWater];
  }

  aboutToAppear(): void {
    // 初始化配方数据库
    this.initRecipeDatabase();

    // 初始化鱼种列�?
    this.updateCurrentFishList();

    // 加载缓存的钓点数�?
    this.fishingSpots = FishingSpotService.cachedSpots;

    // 根据附近渔点自动选择最多的水域类型
    this.autoSelectWaterType();

    // 如果没有缓存，主动搜索（等待定位完成后再搜索�?
    if (this.fishingSpots.length === 0) {
      this.loadNearbySpots();
    }

    // 加载天气数据
    this.loadWeather();
  }

  // 初始化配方数据库
  private initRecipeDatabase(): void {
    // 池塘配方
    const pondRecipes: RecommendRecipe[] = [];
    pondRecipes.push(this.createRecipe('r_001', '池塘鲫鱼散炮', '鲫鱼', ['麸皮', '雪花�?, '拉丝�?], ['春季', '浅水'], 88));
    pondRecipes.push(this.createRecipe('r_002', '黑坑鲤鱼颗粒', '鲤鱼', ['原塘颗粒', '小药', '状态粉'], ['四季', '黑坑'], 92));
    pondRecipes.push(this.createRecipe('r_003', '池塘草鱼青草�?, '草鱼', ['嫩草', '玉米', '麦麸'], ['夏季', '浮钓'], 85));
    pondRecipes.push(this.createRecipe('r_004', '池塘鳙鱼酸臭�?, '鳙鱼', ['臭豆腐汁', '蒜粉', '雪花�?], ['夏季', '浮钓'], 86));
    pondRecipes.push(this.createRecipe('r_006', '南方罗非专用�?, '罗非�?, ['罗非颗粒', '虾粉', '蚯蚓�?], ['夏季', '底钓'], 82));
    pondRecipes.push(this.createRecipe('r_008', '池塘鲶鱼腥饵', '鲶鱼', ['鸡肝', '蚯蚓', '血�?], ['夜钓', '底钓'], 88));
    this.recipeDatabase.set('pond', pondRecipes);

    // 河流配方
    const riverRecipes: RecommendRecipe[] = [];
    riverRecipes.push(this.createRecipe('r_101', '野河鲫鱼蚯蚓伴侣', '鲫鱼', ['蚯蚓�?, '红虫', '酒米'], ['四季', '走水'], 90));
    riverRecipes.push(this.createRecipe('r_102', '江河鲤鱼玉米�?, '鲤鱼', ['发酵玉米', '蜂蜜', '麦粒'], ['夏秋', '深水'], 95));
    riverRecipes.push(this.createRecipe('r_103', '河流草鱼嫩草�?, '草鱼', ['嫩草', '芦苇�?, '玉米�?], ['夏季', '浮钓'], 85));
    riverRecipes.push(this.createRecipe('r_105', '河流黄颡鱼饵', '黄颡�?, ['蚯蚓', '鸡肝', '红虫'], ['夜钓', '石缝'], 85));
    riverRecipes.push(this.createRecipe('r_106', '河流鳊鱼素饵', '鳊鱼', ['麸皮', '玉米�?, '蜂蜜'], ['春夏', '中层'], 82));
    riverRecipes.push(this.createRecipe('r_107', '河流翘嘴路亚�?, '翘嘴', ['亮片', '活虾', '小鱼'], ['夏秋', '路亚'], 82));
    this.recipeDatabase.set('river', riverRecipes);

    // 水库配方
    const reservoirRecipes: RecommendRecipe[] = [];
    reservoirRecipes.push(this.createRecipe('r_201', '水库大鲤守钓�?, '鲤鱼', ['发酵玉米', '红薯', '药酒'], ['秋季', '守大�?], 98));
    reservoirRecipes.push(this.createRecipe('r_202', '水库草鱼浮钓�?, '草鱼', ['嫩玉�?, '青草', '麦麸'], ['夏季', '浮钓'], 90));
    reservoirRecipes.push(this.createRecipe('r_205', '水库青鱼螺蛳�?, '青鱼', ['田螺', '螺蛳�?, '蚌肉�?], ['四季', '底钓'], 92));
    reservoirRecipes.push(this.createRecipe('r_206', '水库鳜鱼活饵', '鳜鱼', ['活泥�?, '活虾', '小鱼'], ['春秋', '活饵'], 95));
    reservoirRecipes.push(this.createRecipe('r_207', '水库武昌鱼素�?, '武昌�?, ['麸皮', '玉米�?, '蜂蜜'], ['春夏', '中层'], 82));
    reservoirRecipes.push(this.createRecipe('r_210', '南方鲮鱼专用�?, '鲮鱼', ['花生�?, '麸皮', '玉米�?], ['夏秋', '底钓'], 85));
    this.recipeDatabase.set('reservoir', reservoirRecipes);

    // 湖泊配方
    const lakeRecipes: RecommendRecipe[] = [];
    lakeRecipes.push(this.createRecipe('r_301', '湖泊鲫鱼传统�?, '鲫鱼', ['酒米', '蚯蚓', '红虫'], ['四季', '传统�?], 90));
    lakeRecipes.push(this.createRecipe('r_302', '湖泊鲤鱼爆炸�?, '鲤鱼', ['糠饼', '玉米', '麦粒'], ['夏秋', '海竿'], 92));
    lakeRecipes.push(this.createRecipe('r_304', '湖泊鳜鱼活饵', '鳜鱼', ['活泥�?, '活虾', '小鱼'], ['夏秋', '活饵'], 95));
    lakeRecipes.push(this.createRecipe('r_305', '湖泊青鱼螺蛳�?, '青鱼', ['田螺', '螺蛳�?, '蚌肉'], ['夏秋', '底钓'], 90));
    lakeRecipes.push(this.createRecipe('r_306', '湖泊黑鱼雷蛙', '黑鱼', ['雷蛙', '软虫', '泥鳅'], ['夏季', '路亚'], 85));
    lakeRecipes.push(this.createRecipe('r_315', '湖泊鳊鱼素饵', '鳊鱼', ['麸皮', '玉米�?, '拉丝�?], ['春夏', '浮钓'], 82));
    this.recipeDatabase.set('lake', lakeRecipes);
  }

  // 创建配方对象
  private createRecipe(id: string, name: string, fish: string, ings: string[], tags: string[], rate: number): RecommendRecipe {
    const r = new RecommendRecipe();
    r.id = id;
    r.name = name;
    r.targetFish = fish;
    r.ingredients = ings;
    r.tags = tags;
    r.catchRate = rate;
    return r;
  }

  // 获取水域推荐配方
  private getRecipesForWater(waterType: string): RecommendRecipe[] {
    const recipes = this.recipeDatabase.get(waterType);
    if (recipes && recipes.length > 0) {
      // 随机打乱并返回前3�?
      const shuffled = recipes.slice();
      for (let i = shuffled.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        const temp = shuffled[i];
        shuffled[i] = shuffled[j];
        shuffled[j] = temp;
      }
      return shuffled.slice(0, 3);
    }
    return [];
  }

  // 页面显示时刷新数据（从地图页返回时同步缓存）
  onPageShow(): void {
    const cachedSpots = FishingSpotService.cachedSpots;
    if (cachedSpots.length > 0 && cachedSpots.length !== this.fishingSpots.length) {
      this.fishingSpots = cachedSpots;
      this.autoSelectWaterType();
    }
  }

  // 根据附近渔点自动选择最多的水域类型
  private autoSelectWaterType(): void {
    if (this.fishingSpots.length === 0) return;

    // 统计各水域类型数�?
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

    // 设置选中的水域类�?
    if (maxCount > 0 && this.selectedWater !== maxType) {
      this.selectedWater = maxType;
      this.updateCurrentFishList();
      // 同时更新鱼种为该水域的第一�?
      if (this.currentFishList.length > 0) {
        this.selectedFish = this.currentFishList[0].id;
      }
    }
  }

  // 加载天气数据
  async loadWeather(): Promise<void> {
    console.info('HomePage', 'loadWeather started');
    this.isLoadingWeather = true;
    try {
      console.info('HomePage', 'Calling fetchWeather...');
      const weatherData = await fetchWeather();
      console.info('HomePage', `Weather loaded: isValid=${weatherData.isValid}, temp=${weatherData.temperature}, wind=${weatherData.windDirection} ${weatherData.windSpeed}, pressure=${weatherData.pressure}`);
      if (weatherData.isValid) {
        this.temperature = Math.round(weatherData.temperature);
        this.weather = weatherData.weatherText;
        this.windInfo = `${weatherData.windDirection} ${weatherData.windSpeed}km/h`;
        this.pressure = Math.round(weatherData.pressure);
        this.fishingIndex = calculateFishingIndex(weatherData);
        console.info('HomePage', `State updated: windInfo=${this.windInfo}, pressure=${this.pressure}`);

        // 获取城市名（逆地理编码）
        await this.fetchCityName();
      }
    } catch (err) {
      console.error('HomePage', `Load weather failed: ${err}`);
    } finally {
      this.isLoadingWeather = false;
      console.info('HomePage', 'loadWeather finished');
    }
  }

  // 获取城市名称
  async fetchCityName(): Promise<void> {
    const location = LocationService.currentLocation;
    if (!location.isValid) {
      this.city = '未知位置';
      return;
    }

    // 检查是否是默认武汉坐标
    const isDefaultLocation = Math.abs(location.latitude - 30.5844) < 0.001 && 
                              Math.abs(location.longitude - 114.2986) < 0.001;

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
        // 显示"�?�?，如"武汉�?江岸�?
        if (addr.adminLevel2 && addr.adminLevel3) {
          this.city = `${addr.adminLevel2} ${addr.adminLevel3}`;
        } else if (addr.adminLevel2) {
          this.city = addr.adminLevel2;
        } else if (addr.adminLevel3) {
          this.city = addr.adminLevel3;
        } else {
          // 逆地理编码没有返回地址，根据坐标判�?
          this.city = isDefaultLocation ? '武汉�? : '定位�?..';
        }
      } else {
        // 没有结果，使用默�?
        this.city = isDefaultLocation ? '武汉�? : '定位�?..';
      }
    } catch (err) {
      console.error('Fetch city name failed:', err);
      // 逆地理编码失败，根据坐标显示
      this.city = isDefaultLocation ? '武汉�? : this.getCityByCoordinates(location.latitude, location.longitude);
    }
  }

  // 根据坐标粗略判断城市（备用方案）
  private getCityByCoordinates(lat: number, lng: number): string {
    // 武汉市范围：纬度29.97-31.37，经�?13.70-115.08
    if (lat >= 29.97 && lat <= 31.37 && lng >= 113.70 && lng <= 115.08) {
      return '武汉�?;
    }
    // 其他城市可以继续添加...
    return `${lat.toFixed(2)}°N, ${lng.toFixed(2)}°E`;
  }

  // 加载附近钓点
  async loadNearbySpots(): Promise<void> {
    // 如果定位还没完成，等待定�?
    let location = LocationService.currentLocation;
    if (!location.isValid) {
      this.isLoadingSpots = true;
      // 等待定位完成（最多等�?秒）
      for (let i = 0; i < 10; i++) {
        await new Promise<void>((resolve) => setTimeout(resolve, 500));
        location = LocationService.currentLocation;
        if (location.isValid) break;
      }
    }

    if (!location.isValid) {
      this.isLoadingSpots = false;
      return;
    }

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

  // 跳转到地图页导航（使用高德地图）
  navigateToRoute(spot: FishingSpot): void {
    router.pushUrl({
      url: 'pages/MapPage',
      params: { 
        navigateToSpot: true,
        spotId: spot.id,
        spotName: spot.name,
        spotLat: spot.latitude,
        spotLng: spot.longitude,
        spotWaterType: spot.waterType,
        spotDistance: spot.distance
      }
    });
  }

  // 点击钓点显示配方推荐
  onSpotClick(spot: FishingSpot): void {
    this.selectedSpot = spot;
    this.recommendedRecipes = this.getRecipesForWater(spot.waterType);
    this.showBaitDialog = true;
  }

  private getSelectedFishName(): string {
    // 先从系统鱼种查找
    const fish = ALL_FISH_DATA.find((f: FishData) => f.id === this.selectedFish);
    if (fish) {
      return `${fish.name} (${fish.nameEn})`;
    }
    // 再从用户自定义鱼种查�?
    const customFish = userDataService.getCustomFish().find((f: CustomFish) => f.id === this.selectedFish);
    if (customFish) {
      return customFish.nameEn ? `${customFish.name} (${customFish.nameEn})` : customFish.name;
    }
    return '';
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: ThemeConstants.SPACE_MD }) {
          // 顶部标题�?
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
        this.fishingIndex.level === '一�? ? 'rgba(255, 152, 0, 0.15)' : 'rgba(244, 67, 54, 0.15)')
      .borderRadius(ThemeConstants.RADIUS_FULL)

      // 温度和天�?
      Row() {
        Column({ space: 4 }) {
          if (this.isLoadingWeather) {
            Row() {
              LoadingProgress().width(24).height(24)
              Text('加载�?..').fontSize(14).fontColor(ThemeColors.TEXT_SECONDARY).margin({ left: 8 })
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

      // 风向和气�?
      Row({ space: ThemeConstants.SPACE_MD }) {
        // 风向
        Row({ space: 8 }) {
          Text('💨')
            .fontSize(14)
          Column({ space: 2 }) {
            Text('风向')
              .fontSize(ThemeConstants.FONT_SIZE_XS)
              .fontColor(ThemeColors.TEXT_MUTED)
            Text(this.windInfo)
              .fontSize(ThemeConstants.FONT_SIZE_SM)
              .fontColor(ThemeColors.TEXT_PRIMARY)
          }
          .alignItems(HorizontalAlign.Start)
        }
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .backgroundColor(ThemeColors.BG_TERTIARY)
        .borderRadius(ThemeConstants.RADIUS_SM)

        // 气压
        Row({ space: 8 }) {
          Text('📊')
            .fontSize(14)
          Column({ space: 2 }) {
            Text('气压')
              .fontSize(ThemeConstants.FONT_SIZE_XS)
              .fontColor(ThemeColors.TEXT_MUTED)
            Text(`${this.pressure} hPa`)
              .fontSize(ThemeConstants.FONT_SIZE_SM)
              .fontColor(ThemeColors.TEXT_PRIMARY)
          }
          .alignItems(HorizontalAlign.Start)
        }
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .backgroundColor(ThemeColors.BG_TERTIARY)
        .borderRadius(ThemeConstants.RADIUS_SM)
      }
      .width('100%')
      .margin({ top: 8 })
    }
    .width('100%')
    .padding(ThemeConstants.SPACE_MD)
    .linearGradient({
      direction: GradientDirection.RightBottom,
      colors: this.getWeatherGradient()
    })
    .borderRadius(ThemeConstants.RADIUS_MD)
  }

  // 根据天气获取渐变背景色（柔和版）
  private getWeatherGradient(): [string, number][] {
    if (this.weather.includes('�?)) {
      return [['#E3F2FD', 0], ['#BBDEFB', 1]];  // 浅蓝
    }
    if (this.weather.includes('�?) || this.weather.includes('多云')) {
      return [['#ECEFF1', 0], ['#CFD8DC', 1]];  // 浅灰�?
    }
    if (this.weather.includes('�?)) {
      return [['#E0E0E0', 0], ['#BDBDBD', 1]];  // 浅灰
    }
    if (this.weather.includes('�?)) {
      return [['#E8EAF6', 0], ['#C5CAE9', 1]];  // 浅紫�?
    }
    if (this.weather.includes('�?)) {
      return [['#E3F2FD', 0], ['#E1F5FE', 1]];  // 浅蓝�?
    }
    if (this.weather.includes('�?)) {
      return [['#EDE7F6', 0], ['#D1C4E9', 1]];  // 浅紫
    }
    if (this.weather.includes('�?) || this.weather.includes('�?)) {
      return [['#EFEBE9', 0], ['#D7CCC8', 1]];  // 浅棕
    }
    // 默认 - 浅粉色（原来的卡片色�?
    return [['#FFF8F0', 0], ['#FFF3E8', 1]];
  }

  // 根据天气获取emoji
  private getWeatherEmoji(): string {
    if (this.weather.includes('�?)) return '☀�?;
    if (this.weather.includes('�?)) return '�?;
    if (this.weather.includes('�?)) return '☁️';
    if (this.weather.includes('�?)) return '🌧�?;
    if (this.weather.includes('�?)) return '❄️';
    if (this.weather.includes('�?)) return '⛈️';
    if (this.weather.includes('�?) || this.weather.includes('�?)) return '🌫�?;
    return '🌤�?;
  }

  @Builder
  WeatherInfoItem(label: string, value: string) {
    Row({ space: 8 }) {
      Text('�?)
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
        Text('快速配�?)
          .fontSize(ThemeConstants.FONT_SIZE_LG)
          .fontWeight(FontWeight.Medium)
          .fontColor(ThemeColors.TEXT_PRIMARY)
        Blank()
        Text('查看历史')
          .fontSize(ThemeConstants.FONT_SIZE_SM)
          .fontColor(ThemeColors.PRIMARY_DARK)
          .onClick(() => {
            router.pushUrl({ url: 'pages/GeneratorHistoryPage' });
          })
      }
      .width('100%')

      Text('根据天气和附近渔点，一键生成配方�?)
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
          Text('�?)
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
          Text('�?)
            .fontSize(16)
          Text('一键生成配�?)
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
            quickMode: true  // 快速模式标�?
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
      // 切换水域时，重置鱼种为该水域的第一个鱼�?
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
          .fontColor(ThemeColors.PRIMARY_DARK)
          .onClick(() => {
            router.pushUrl({ url: 'pages/MapPage' });
          })
      }
      .width('100%')

      // 加载�?
      if (this.isLoadingSpots) {
        Row() {
          LoadingProgress().width(20).height(20)
          Text('搜索附近钓点...').fontSize(14).fontColor(ThemeColors.TEXT_SECONDARY).margin({ left: 8 })
        }
        .width('100%')
        .padding(16)
        .justifyContent(FlexAlign.Center)
      } else if (this.fishingSpots.length === 0) {
        // 无数�?
        Text('暂无附近钓点，点击地图模式搜�?)
          .fontSize(14)
          .fontColor(ThemeColors.TEXT_SECONDARY)
          .padding(16)
      } else {
        // 钓点列表（显示最�?0个）
        ForEach(this.fishingSpots.slice(0, 10), (spot: FishingSpot) => {
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
        Text('�?)
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
        Text('�?)
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
        .margin({ bottom: 16 })

      Divider().color('#eee').margin({ bottom: 16 })

      Text('🎣 推荐配方')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeColors.TEXT_PRIMARY)
        .margin({ bottom: 12 })

      ForEach(this.recommendedRecipes, (recipe: RecommendRecipe) => {
        Row() {
          Column() {
            Row({ space: 6 }) {
              Text(recipe.name)
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .fontColor(ThemeColors.TEXT_PRIMARY)
              if (recipe.catchRate >= 90) {
                Text(`🔥 ${recipe.catchRate}%`)
                  .fontSize(11)
                  .fontColor('#FF6B00')
              }
            }

            Row({ space: 4 }) {
              ForEach(recipe.tags, (tag: string) => {
                Text(tag)
                  .fontSize(10)
                  .fontColor('#666')
                  .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                  .backgroundColor('#f5f5f5')
                  .borderRadius(4)
              })
            }
            .margin({ top: 4 })

            Row({ space: 4 }) {
              ForEach(recipe.ingredients, (ing: string) => {
                Text(`�?${ing}`)
                  .fontSize(11)
                  .fontColor(ThemeColors.TEXT_SECONDARY)
              })
            }
            .margin({ top: 4 })

            Text(`目标�? ${recipe.targetFish}`)
              .fontSize(11)
              .fontColor(ThemeColors.PRIMARY_DARK)
              .margin({ top: 4 })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          // 查看详情按钮
          Text('�?)
            .fontSize(16)
            .fontColor(ThemeColors.PRIMARY_DARK)
            .onClick(() => {
              this.showBaitDialog = false;
              router.pushUrl({
                url: 'pages/RecipeDetailPage',
                params: { recipeId: recipe.id }
              });
            })
        }
        .width('100%')
        .padding(12)
        .backgroundColor(ThemeColors.BG_SECONDARY)
        .borderRadius(8)
        .margin({ bottom: 8 })
      })

      // 底部按钮
      Row({ space: 12 }) {
        Button('换一�?)
          .layoutWeight(1)
          .height(44)
          .fontSize(14)
          .backgroundColor(ThemeColors.BG_TERTIARY)
          .fontColor(ThemeColors.TEXT_PRIMARY)
          .onClick(() => {
            this.recommendedRecipes = this.getRecipesForWater(this.selectedSpot!.waterType);
          })

        Button('去这�?)
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
    // 遮罩�?
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
        Text('�?)
          .fontSize(20)
          .fontColor(ThemeColors.TEXT_SECONDARY)
          .onClick(() => { this.showFishPicker = false })
      }
      .width('100%')
      .padding({ bottom: 12 })

      // 鱼种列表（可滚动�?
      Scroll() {
        Column({ space: 8 }) {
          // 系统鱼种
          ForEach(this.currentFishList, (fish: FishData) => {
            Row() {
              // 鱼图�?
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
                Text('�?)
                  .fontSize(18)
                  .fontColor(ThemeColors.PRIMARY_DARK)
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

          // 用户自定义鱼种（筛选当前水域）
          ForEach(this.getCustomFishForCurrentWater(), (fish: CustomFish) => {
            Row() {
              // 鱼图�?
              Image(fish.icon || $r('app.media.fishImage'))
                .width(40)
                .height(40)
                .borderRadius(20)
                .margin({ right: 12 })

              Column({ space: 2 }) {
                Row({ space: 4 }) {
                  Text(fish.name)
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(ThemeColors.TEXT_PRIMARY)

                  Text('自定�?)
                    .fontSize(10)
                    .fontColor(ThemeColors.PRIMARY_DARK)
                    .padding({ left: 4, right: 4, top: 2, bottom: 2 })
                    .backgroundColor('rgba(232, 168, 73, 0.15)')
                    .borderRadius(4)
                }
                Text(fish.nameEn || '')
                  .fontSize(12)
                  .fontColor(ThemeColors.TEXT_SECONDARY)
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              // 选中标记
              if (this.selectedFish === fish.id) {
                Text('�?)
                  .fontSize(18)
                  .fontColor(ThemeColors.PRIMARY_DARK)
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

  // 获取当前水域的用户自定义鱼种
  private getCustomFishForCurrentWater(): CustomFish[] {
    return userDataService.getCustomFish().filter((fish: CustomFish) =>
      fish.waterTypes.includes(this.selectedWater)
    );
  }
}
