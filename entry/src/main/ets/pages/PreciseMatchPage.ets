/**
 * 精确匹配 - 参数输入�?
 * 提供专业级参数配置，与快速配方形成差异化
 */
import { router } from '@kit.ArkUI';
import { ThemeColors } from '../theme/ThemeColors';
import { RecipeSeason, RecipeWaterType } from '../common/types/RecipeTypes';
import {
  PreciseMatchInput,
  WaterDepth, WaterDepthNames,
  WaterQuality, WaterQualityNames,
  LightCondition, LightConditionNames,
  WindCondition, WindConditionNames,
  BaitState, BaitStateNames,
  FlavorIntensity, FlavorIntensityNames,
  FishSize, FishSizeNames
} from '../common/types/PreciseMatchTypes';
import { ALL_FISH_DATA, FishData } from '../data/FishData';
import { fetchWeather } from '../services/WeatherService';
import { getCurrentSeason } from '../services/RecipeGeneratorService';
import { userDataService, CustomFish } from '../services/UserDataService';

interface FishItem {
  id: string;
  name: string;
  icon: Resource | string;
  isCustom?: boolean;
}

interface WaterItem {
  type: RecipeWaterType;
  name: string;
  icon: Resource;
  iconActive: Resource;
}

interface SeasonItem {
  type: RecipeSeason;
  name: string;
  icon: Resource;
  iconActive: Resource;
}

interface OptionItem {
  key: string;
  label: string;
}

@Entry
@Component
struct PreciseMatchPage {
  // 基础参数
  @State selectedFish: string = '';
  @State selectedWater: RecipeWaterType = 'river';
  @State selectedSeason: RecipeSeason = 'spring';
  @State temperature: number = 24;

  // 高级选项展开状�?
  @State showAdvanced: boolean = true;

  // 高级参数
  @State waterDepth: WaterDepth = 'medium';
  @State waterQuality: WaterQuality = 'clear';
  @State lightCondition: LightCondition = 'bright';
  @State windCondition: WindCondition = 'none';
  @State baitState: BaitState = 'fast_dissolve';
  @State flavorIntensity: FlavorIntensity = 'medium';
  @State targetFishSize: FishSize = 'medium';

  // 鱼种列表
  @State fishList: FishItem[] = [];
  @State isLoading: boolean = false;

  // 水域列表
  private waterList: WaterItem[] = [
    { type: 'river', name: '河流', icon: $r('app.media.River'), iconActive: $r('app.media.Rivers') },
    { type: 'wild_pond', name: '湖泊', icon: $r('app.media.Lake'), iconActive: $r('app.media.Lakes') },
    { type: 'pond', name: '池塘', icon: $r('app.media.Pond'), iconActive: $r('app.media.Ponds') },
    { type: 'reservoir', name: '水库', icon: $r('app.media.Reservoir'), iconActive: $r('app.media.Reservoirs') }
  ];

  // 季节列表
  private seasonList: SeasonItem[] = [
    { type: 'spring', name: '春季', icon: $r('app.media.Spring'), iconActive: $r('app.media.Springs') },
    { type: 'summer', name: '夏季', icon: $r('app.media.Summer'), iconActive: $r('app.media.Summers') },
    { type: 'autumn', name: '秋季', icon: $r('app.media.Autumn'), iconActive: $r('app.media.Autumns') },
    { type: 'winter', name: '冬季', icon: $r('app.media.Winter'), iconActive: $r('app.media.Winters') }
  ];

  // 高级选项数据
  private waterDepthOptions: OptionItem[] = [];
  private waterQualityOptions: OptionItem[] = [];
  private lightConditionOptions: OptionItem[] = [];
  private windConditionOptions: OptionItem[] = [];
  private baitStateOptions: OptionItem[] = [];
  private flavorIntensityOptions: OptionItem[] = [];
  private targetFishSizeOptions: OptionItem[] = [];

  aboutToAppear(): void {
    this.initAdvancedOptions();
    this.selectedSeason = getCurrentSeason();
    this.updateFishList();
    this.loadWeather();
    this.loadUserPreferences();
  }

  // 初始化高级选项数据
  private initAdvancedOptions(): void {
    this.waterDepthOptions = [
      { key: 'shallow', label: WaterDepthNames['shallow'] },
      { key: 'medium', label: WaterDepthNames['medium'] },
      { key: 'deep', label: WaterDepthNames['deep'] }
    ];
    this.waterQualityOptions = [
      { key: 'clear', label: WaterQualityNames['clear'] },
      { key: 'slight_muddy', label: WaterQualityNames['slight_muddy'] },
      { key: 'muddy', label: WaterQualityNames['muddy'] },
      { key: 'fertile', label: WaterQualityNames['fertile'] }
    ];
    this.lightConditionOptions = [
      { key: 'bright', label: LightConditionNames['bright'] },
      { key: 'cloudy', label: LightConditionNames['cloudy'] },
      { key: 'dawn_dusk', label: LightConditionNames['dawn_dusk'] },
      { key: 'night', label: LightConditionNames['night'] }
    ];
    this.windConditionOptions = [
      { key: 'none', label: WindConditionNames['none'] },
      { key: 'light', label: WindConditionNames['light'] },
      { key: 'medium', label: WindConditionNames['medium'] },
      { key: 'strong', label: WindConditionNames['strong'] }
    ];
    this.baitStateOptions = [
      { key: 'fast_dissolve', label: BaitStateNames['fast_dissolve'] },
      { key: 'slow_dissolve', label: BaitStateNames['slow_dissolve'] },
      { key: 'sticky', label: BaitStateNames['sticky'] },
      { key: 'dry_loose', label: BaitStateNames['dry_loose'] }
    ];
    this.flavorIntensityOptions = [
      { key: 'light', label: FlavorIntensityNames['light'] },
      { key: 'medium', label: FlavorIntensityNames['medium'] },
      { key: 'strong', label: FlavorIntensityNames['strong'] },
      { key: 'intense', label: FlavorIntensityNames['intense'] }
    ];
    this.targetFishSizeOptions = [
      { key: 'small', label: FishSizeNames['small'] },
      { key: 'medium', label: FishSizeNames['medium'] },
      { key: 'large', label: FishSizeNames['large'] }
    ];
  }

  // 加载用户偏好设置
  private async loadUserPreferences(): Promise<void> {
    try {
      await userDataService.load();
      const prefs = userDataService.getPrecisePreferences();
      if (prefs.lastUpdated > 0) {
        this.waterDepth = prefs.waterDepth as WaterDepth;
        this.waterQuality = prefs.waterQuality as WaterQuality;
        this.lightCondition = prefs.lightCondition as LightCondition;
        this.windCondition = prefs.windCondition as WindCondition;
        this.baitState = prefs.baitState as BaitState;
        this.flavorIntensity = prefs.flavorIntensity as FlavorIntensity;
        this.targetFishSize = prefs.targetFishSize as FishSize;
      }
    } catch (e) {
      console.error('Load preferences failed:', e);
    }
  }

  // 保存用户偏好设置
  private async saveUserPreferences(): Promise<void> {
    try {
      const prefs = userDataService.getPrecisePreferences();
      prefs.waterDepth = this.waterDepth;
      prefs.waterQuality = this.waterQuality;
      prefs.lightCondition = this.lightCondition;
      prefs.windCondition = this.windCondition;
      prefs.baitState = this.baitState;
      prefs.flavorIntensity = this.flavorIntensity;
      prefs.targetFishSize = this.targetFishSize;
      await userDataService.savePrecisePreferences(prefs);
    } catch (e) {
      console.error('Save preferences failed:', e);
    }
  }

  // 根据水域类型更新鱼种列表（包含系统鱼种和用户自定义鱼种）
  private updateFishList(): void {
    let waterTypeKey = this.selectedWater as string;
    if (this.selectedWater === 'wild_pond') {
      waterTypeKey = 'lake';
    }

    // 系统鱼种
    const filteredFish = ALL_FISH_DATA.filter((fish: FishData) => fish.waterTypes.includes(waterTypeKey));
    this.fishList = filteredFish.map((fish: FishData): FishItem => ({
      id: fish.id,
      name: fish.name,
      icon: fish.icon,
      isCustom: false
    }));

    // 用户自定义鱼�?
    const customFishList = userDataService.getCustomFish().filter((fish: CustomFish) =>
      fish.waterTypes.includes(waterTypeKey)
    );
    customFishList.forEach((fish: CustomFish) => {
      this.fishList.push({
        id: fish.id,
        name: fish.name,
        icon: fish.icon || $r('app.media.fishImage'),
        isCustom: true
      });
    });

    // 如果当前选中的鱼不在新列表中，选择第一�?
    const currentFishExists = this.fishList.some((f: FishItem) => f.id === this.selectedFish);
    if (!currentFishExists && this.fishList.length > 0) {
      this.selectedFish = this.fishList[0].id;
    }
  }

  // 加载天气
  async loadWeather(): Promise<void> {
    try {
      const weather = await fetchWeather();
      if (weather.isValid) {
        this.temperature = Math.round(weather.temperature);
      }
    } catch (err) {
      console.error('Load weather failed:', err);
    }
  }

  // 开始精确分�?
  private onStartAnalysis(): void {
    if (!this.selectedFish) return;
    this.isLoading = true;

    // 保存用户偏好设置
    this.saveUserPreferences();

    // 构建输入参数
    const input = new PreciseMatchInput();
    input.targetFish = this.selectedFish;
    input.waterType = this.selectedWater;
    input.season = this.selectedSeason;
    input.temperature = this.temperature;
    input.waterDepth = this.waterDepth;
    input.waterQuality = this.waterQuality;
    input.lightCondition = this.lightCondition;
    input.windCondition = this.windCondition;
    input.baitState = this.baitState;
    input.flavorIntensity = this.flavorIntensity;
    input.targetFishSize = this.targetFishSize;

    // 跳转到结果页
    const inputJson = JSON.stringify(input);
    this.isLoading = false;
    router.pushUrl({
      url: 'pages/PreciseResultPage',
      params: { input: inputJson }
    });
  }

  // 返回上一�?
  private onBack(): void {
    router.back();
  }

  build() {
    Column() {
      // 顶部标题�?
      this.TitleBar()

      Scroll() {
        Column({ space: 24 }) {
          // 目标鱼种
          this.FishSection()

          // 水域环境
          this.WaterSection()

          // 季节与天�?
          this.SeasonWeatherSection()

          // 高级选项
          this.AdvancedSection()
        }
        .width('100%')
        .padding({ left: 20, right: 20, bottom: 120 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      // 底部生成按钮
      this.GenerateButton()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFBF5')
  }

  @Builder
  TitleBar() {
    Row() {
      Row() {
        Text('�?)
          .fontSize(24)
          .fontColor('#1A1A1A')
      }
      .width(40)
      .height(40)
      .justifyContent(FlexAlign.Center)
      .onClick(() => this.onBack())

      Text('精确匹配')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A1A')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      // 占位，保持标题居�?
      Row().width(40).height(40)
    }
    .width('100%')
    .height(56)
    .padding({ left: 12, right: 12 })
    .margin({ top: 44 })
  }

  @Builder
  FishSection() {
    Column({ space: 16 }) {
      Row() {
        Text('目标鱼种')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
        Blank()
        Text(`已�?{this.fishList.length}种`)
          .fontSize(14)
          .fontColor('#999')
      }
      .width('100%')

      Scroll() {
        Row({ space: 12 }) {
          ForEach(this.fishList, (fish: FishItem) => {
            Column({ space: 8 }) {
              Stack() {
                Image(fish.icon)
                  .width(66)
                  .height(66)
                  .borderRadius(33)
                  .objectFit(ImageFit.Cover)
                  .border({
                    width: this.selectedFish === fish.id ? 3 : 1,
                    color: this.selectedFish === fish.id ? ThemeColors.PRIMARY : '#E5E5E5'
                  })

                if (this.selectedFish === fish.id) {
                  Row() {
                    Text('�?).fontSize(11).fontColor(Color.White)
                  }
                  .width(18)
                  .height(18)
                  .borderRadius(9)
                  .backgroundColor(ThemeColors.PRIMARY)
                  .justifyContent(FlexAlign.Center)
                  .position({ x: 48, y: 48 })
                }
              }
              .width(66)
              .height(66)

              Text(fish.name)
                .fontSize(13)
                .fontColor(this.selectedFish === fish.id ? ThemeColors.PRIMARY : '#666')
            }
            .onClick(() => {
              this.selectedFish = fish.id;
            })
          })
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  WaterSection() {
    Column({ space: 12 }) {
      Text('水域环境')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A1A')

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.waterList, (water: WaterItem) => {
          Row({ space: 6 }) {
            Image(this.selectedWater === water.type ? water.iconActive : water.icon)
              .width(20)
              .height(20)
            Text(water.name)
              .fontSize(14)
              .fontColor(this.selectedWater === water.type ? ThemeColors.PRIMARY : '#666')
          }
          .height(40)
          .padding({ left: 16, right: 16 })
          .backgroundColor(this.selectedWater === water.type ? '#FFF5E6' : Color.White)
          .borderRadius(20)
          .border({
            width: 1,
            color: this.selectedWater === water.type ? ThemeColors.PRIMARY : '#E5E5E5'
          })
          .margin({ right: 10, bottom: 10 })
          .onClick(() => {
            this.selectedWater = water.type;
            this.updateFishList();
          })
        })
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  SeasonWeatherSection() {
    Column({ space: 16 }) {
      Text('季节与天�?)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A1A')

      // 温度滑块
      Column({ space: 12 }) {
        Row() {
          Row({ space: 6 }) {
            Text('🌡').fontSize(16)
            Text('气温').fontSize(15).fontColor('#1A1A1A')
          }

          Blank()
          Text(`${this.temperature}°C`)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.PRIMARY_DARK)
        }
        .width('100%')

        Slider({
          value: this.temperature,
          min: 0,
          max: 40,
          step: 1,
          style: SliderStyle.OutSet
        })
          .selectedColor(ThemeColors.PRIMARY)
          .trackColor('#F0F0F0')
          .blockColor(ThemeColors.PRIMARY)
          .onChange((value: number) => {
            this.temperature = Math.round(value);
          })

        Row() {
          Text('寒冷 (0°C)').fontSize(12).fontColor('#999')
          Blank()
          Text('炎热 (40°C)').fontSize(12).fontColor('#999')
        }
        .width('100%')
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .borderRadius(12)

      // 季节选择
      Grid() {
        ForEach(this.seasonList, (season: SeasonItem) => {
          GridItem() {
            Column({ space: 8 }) {
              Image(this.selectedSeason === season.type ? season.iconActive : season.icon)
                .width(36)
                .height(36)
              Text(season.name)
                .fontSize(14)
                .fontColor(this.selectedSeason === season.type ? ThemeColors.PRIMARY : '#666')
            }
            .width('100%')
            .height(80)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(this.selectedSeason === season.type ? '#FFF5E6' : Color.White)
            .borderRadius(12)
            .border({
              width: this.selectedSeason === season.type ? 2 : 1,
              color: this.selectedSeason === season.type ? ThemeColors.PRIMARY : '#F0F0F0'
            })
            .onClick(() => {
              this.selectedSeason = season.type;
            })
          }
        })
      }
      .columnsTemplate('1fr 1fr')
      .rowsGap(12)
      .columnsGap(12)
      .width('100%')
      .height(172)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  AdvancedSection() {
    Column({ space: 12 }) {
      // 折叠标题
      Row() {
        Text('�?).fontSize(16).fontColor(ThemeColors.PRIMARY_DARK)
        Text('高级选项')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1A1A')
          .margin({ left: 8 })
        Text('（专业参数）')
          .fontSize(12)
          .fontColor('#999')
          .margin({ left: 4 })
        Blank()
        Text(this.showAdvanced ? '�? : '�?)
          .fontSize(16)
          .fontColor('#999')
      }
      .width('100%')
      .height(50)
      .padding({ left: 16, right: 16 })
      .backgroundColor(Color.White)
      .borderRadius(12)
      .onClick(() => {
        this.showAdvanced = !this.showAdvanced;
      })

      if (this.showAdvanced) {
        Column({ space: 20 }) {
          // 水深
          this.WaterDepthRow()

          // 水质
          this.WaterQualityRow()

          // 光照
          this.LightConditionRow()

          // 风力
          this.WindConditionRow()

          // 饵料状�?
          this.BaitStateRow()

          // 味型强度
          this.FlavorIntensityRow()

          // 目标体型
          this.TargetFishSizeRow()
        }
        .width('100%')
        .padding(16)
        .backgroundColor(Color.White)
        .borderRadius(12)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  WaterDepthRow() {
    Column({ space: 10 }) {
      Text('水深').fontSize(14).fontColor('#666')
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.waterDepthOptions, (opt: OptionItem) => {
          Text(opt.label)
            .fontSize(13)
            .fontColor(this.waterDepth === opt.key ? ThemeColors.PRIMARY : '#666')
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .backgroundColor(this.waterDepth === opt.key ? '#FFF5E6' : '#F5F5F5')
            .borderRadius(16)
            .border({ width: this.waterDepth === opt.key ? 1 : 0, color: ThemeColors.PRIMARY })
            .margin({ right: 8, bottom: 8 })
            .onClick(() => { this.waterDepth = opt.key as WaterDepth; })
        })
      }
    }.width('100%').alignItems(HorizontalAlign.Start)
  }

  @Builder
  WaterQualityRow() {
    Column({ space: 10 }) {
      Text('水质').fontSize(14).fontColor('#666')
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.waterQualityOptions, (opt: OptionItem) => {
          Text(opt.label)
            .fontSize(13)
            .fontColor(this.waterQuality === opt.key ? ThemeColors.PRIMARY : '#666')
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .backgroundColor(this.waterQuality === opt.key ? '#FFF5E6' : '#F5F5F5')
            .borderRadius(16)
            .border({ width: this.waterQuality === opt.key ? 1 : 0, color: ThemeColors.PRIMARY })
            .margin({ right: 8, bottom: 8 })
            .onClick(() => { this.waterQuality = opt.key as WaterQuality; })
        })
      }
    }.width('100%').alignItems(HorizontalAlign.Start)
  }

  @Builder
  LightConditionRow() {
    Column({ space: 10 }) {
      Text('光照').fontSize(14).fontColor('#666')
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.lightConditionOptions, (opt: OptionItem) => {
          Text(opt.label)
            .fontSize(13)
            .fontColor(this.lightCondition === opt.key ? ThemeColors.PRIMARY : '#666')
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .backgroundColor(this.lightCondition === opt.key ? '#FFF5E6' : '#F5F5F5')
            .borderRadius(16)
            .border({ width: this.lightCondition === opt.key ? 1 : 0, color: ThemeColors.PRIMARY })
            .margin({ right: 8, bottom: 8 })
            .onClick(() => { this.lightCondition = opt.key as LightCondition; })
        })
      }
    }.width('100%').alignItems(HorizontalAlign.Start)
  }

  @Builder
  WindConditionRow() {
    Column({ space: 10 }) {
      Text('风力').fontSize(14).fontColor('#666')
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.windConditionOptions, (opt: OptionItem) => {
          Text(opt.label)
            .fontSize(13)
            .fontColor(this.windCondition === opt.key ? ThemeColors.PRIMARY : '#666')
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .backgroundColor(this.windCondition === opt.key ? '#FFF5E6' : '#F5F5F5')
            .borderRadius(16)
            .border({ width: this.windCondition === opt.key ? 1 : 0, color: ThemeColors.PRIMARY })
            .margin({ right: 8, bottom: 8 })
            .onClick(() => { this.windCondition = opt.key as WindCondition; })
        })
      }
    }.width('100%').alignItems(HorizontalAlign.Start)
  }

  @Builder
  BaitStateRow() {
    Column({ space: 10 }) {
      Text('饵料状�?).fontSize(14).fontColor('#666')
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.baitStateOptions, (opt: OptionItem) => {
          Text(opt.label)
            .fontSize(13)
            .fontColor(this.baitState === opt.key ? ThemeColors.PRIMARY : '#666')
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .backgroundColor(this.baitState === opt.key ? '#FFF5E6' : '#F5F5F5')
            .borderRadius(16)
            .border({ width: this.baitState === opt.key ? 1 : 0, color: ThemeColors.PRIMARY })
            .margin({ right: 8, bottom: 8 })
            .onClick(() => { this.baitState = opt.key as BaitState; })
        })
      }
    }.width('100%').alignItems(HorizontalAlign.Start)
  }

  @Builder
  FlavorIntensityRow() {
    Column({ space: 10 }) {
      Text('味型强度').fontSize(14).fontColor('#666')
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.flavorIntensityOptions, (opt: OptionItem) => {
          Text(opt.label)
            .fontSize(13)
            .fontColor(this.flavorIntensity === opt.key ? ThemeColors.PRIMARY : '#666')
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .backgroundColor(this.flavorIntensity === opt.key ? '#FFF5E6' : '#F5F5F5')
            .borderRadius(16)
            .border({ width: this.flavorIntensity === opt.key ? 1 : 0, color: ThemeColors.PRIMARY })
            .margin({ right: 8, bottom: 8 })
            .onClick(() => { this.flavorIntensity = opt.key as FlavorIntensity; })
        })
      }
    }.width('100%').alignItems(HorizontalAlign.Start)
  }

  @Builder
  TargetFishSizeRow() {
    Column({ space: 10 }) {
      Text('目标体型').fontSize(14).fontColor('#666')
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.targetFishSizeOptions, (opt: OptionItem) => {
          Text(opt.label)
            .fontSize(13)
            .fontColor(this.targetFishSize === opt.key ? ThemeColors.PRIMARY : '#666')
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .backgroundColor(this.targetFishSize === opt.key ? '#FFF5E6' : '#F5F5F5')
            .borderRadius(16)
            .border({ width: this.targetFishSize === opt.key ? 1 : 0, color: ThemeColors.PRIMARY })
            .margin({ right: 8, bottom: 8 })
            .onClick(() => { this.targetFishSize = opt.key as FishSize; })
        })
      }
    }.width('100%').alignItems(HorizontalAlign.Start)
  }

  @Builder
  GenerateButton() {
    Column() {
      Button() {
        Row({ space: 8 }) {
          if (this.isLoading) {
            LoadingProgress().width(20).height(20).color(Color.White)
          } else {
            Text('�?).fontSize(16).fontColor(Color.White)
          }
          Text(this.isLoading ? '分析�?..' : '开始精确分�?)
            .fontSize(16)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Medium)
        }
      }
      .width('100%')
      .height(52)
      .backgroundColor(ThemeColors.PRIMARY)
      .borderRadius(26)
      .enabled(!this.isLoading && this.selectedFish !== '')
      .onClick(() => this.onStartAnalysis())
    }
    .width('100%')
    .padding({ left: 20, right: 20, bottom: 34, top: 12 })
    .backgroundColor('#FFFBF5')
  }
}
