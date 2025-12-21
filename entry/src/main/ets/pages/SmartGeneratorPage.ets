/**
 * 鱼饵生成器 - 按设计图重做
 */
import { router } from '@kit.ArkUI';
import { ThemeColors } from '../theme/ThemeColors';
import { GenerateRecipeInput, RecipeSeason, RecipeWaterType, FishDensity, FishActivity, FishingMethod, GenerateMode } from '../common/types/RecipeTypes';
import { generateRecipe, getCurrentSeason } from '../services/RecipeGeneratorService';
import { fetchWeather } from '../services/WeatherService';

interface FishItem { id: string; name: string; normalImage: Resource; selectedImage: Resource; }
interface WaterItem { type: RecipeWaterType; name: string; normalImage: Resource; selectedImage: Resource; }
interface SeasonItem { type: RecipeSeason; name: string; normalImage: Resource; selectedImage: Resource; }

@Entry
@Component
struct SmartGeneratorPage {
  @State selectedFish: string = 'carp';
  @State selectedWater: RecipeWaterType = 'river';
  @State selectedSeason: RecipeSeason = 'spring';
  @State temperature: number = 24;
  @State showAdvanced: boolean = false;
  @State fishDensity: FishDensity = 'medium';
  @State fishActivity: FishActivity = 'normal';
  @State fishingMethod: FishingMethod = 'rub';
  @State mode: GenerateMode = 'balanced';
  @State isLoading: boolean = false;
  @State lastRecord: string = '香辣玉米';

  private fishList: FishItem[] = [
    { id: 'carp', name: '鲤鱼', normalImage: $r('app.media.Carp'), selectedImage: $r('app.media.Carp') },
    { id: 'crucian', name: '鲫鱼', normalImage: $r('app.media.Crucian_carp'), selectedImage: $r('app.media.Crucian_carp') },
    { id: 'grass', name: '草鱼', normalImage: $r('app.media.Grass_carp'), selectedImage: $r('app.media.Grass_carp') },
    { id: 'catfish', name: '鲶鱼', normalImage: $r('app.media.Catfish'), selectedImage: $r('app.media.Catfish') },
    { id: 'black', name: '青鱼', normalImage: $r('app.media.Black_carp'), selectedImage: $r('app.media.Black_carp') }
  ];

  private waterList: WaterItem[] = [
    { type: 'river', name: '河流', normalImage: $r('app.media.River'), selectedImage: $r('app.media.Rivers') },
    { type: 'wild_pond', name: '湖泊', normalImage: $r('app.media.Lake'), selectedImage: $r('app.media.Lakes') },
    { type: 'pond', name: '池塘', normalImage: $r('app.media.Pond'), selectedImage: $r('app.media.Ponds') },
    { type: 'reservoir', name: '水库', normalImage: $r('app.media.Reservoir'), selectedImage: $r('app.media.Reservoirs') }
  ];

  private seasonList: SeasonItem[] = [
    { type: 'spring', name: '春季', normalImage: $r('app.media.Spring'), selectedImage: $r('app.media.Springs') },
    { type: 'summer', name: '夏季', normalImage: $r('app.media.Summer'), selectedImage: $r('app.media.Summers') },
    { type: 'autumn', name: '秋季', normalImage: $r('app.media.Autumn'), selectedImage: $r('app.media.Autumns') },
    { type: 'winter', name: '冬季', normalImage: $r('app.media.Winter'), selectedImage: $r('app.media.Winters') }
  ];

  aboutToAppear(): void {
    this.selectedSeason = getCurrentSeason();
    this.loadWeather();
  }

  async loadWeather(): Promise<void> {
    try {
      const weather = await fetchWeather();
      if (weather.isValid) {
        this.temperature = Math.round(weather.temperature);
      }
    } catch (err) { console.error('Load weather failed:', err); }
  }


  onGenerate(): void {
    if (!this.selectedFish) return;
    this.isLoading = true;

    const input = new GenerateRecipeInput();
    input.targetFishId = this.selectedFish;
    input.waterType = this.selectedWater;
    input.temperature = this.temperature;
    input.season = this.selectedSeason;
    input.fishDensity = this.fishDensity;
    input.fishActivity = this.fishActivity;
    input.fishingMethod = this.fishingMethod;
    input.mode = this.mode;

    try {
      const recipe = generateRecipe(input);
      const recipeJson = JSON.stringify(recipe);
      this.isLoading = false;
      router.pushUrl({ url: 'pages/GeneratedRecipePage', params: { recipe: recipeJson } });
    } catch (err) {
      console.error('Generate failed:', err);
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('鱼饵生成器').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#1A1A1A')
        Blank()
        Text('⟳').fontSize(22).fontColor('#1A1A1A')
      }
      .width('100%').height(56).padding({ left: 20, right: 20 }).margin({ top: 44 })

      Scroll() {
        Column({ space: 24 }) {
          // 目标鱼种
          this.FishSection()

          // 水域环境
          this.WaterSection()

          // 季节与天气
          this.SeasonWeatherSection()

          // 高级选项
          this.AdvancedSection()

          // 上次记录
          this.LastRecordSection()
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

  @Builder FishSection() {
    Column({ space: 16 }) {
      Row() {
        Text('目标鱼种').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#1A1A1A')
        Blank()
        Text('查看全部').fontSize(14).fontColor(ThemeColors.PRIMARY)
      }.width('100%')

      Scroll() {
        Row({ space: 12 }) {
          ForEach(this.fishList, (fish: FishItem) => {
            Column({ space: 8 }) {
              Stack() {
                // 图片直接设置圆形
                Image(this.selectedFish === fish.id ? fish.selectedImage : fish.normalImage)
                  .width(66)
                  .height(66)
                  .borderRadius(33)
                  .objectFit(ImageFit.Cover)
                  .border({
                    width: this.selectedFish === fish.id ? 3 : 1,
                    color: this.selectedFish === fish.id ? ThemeColors.PRIMARY : '#E5E5E5'
                  })

                // 选中勾选标记
                if (this.selectedFish === fish.id) {
                  Row() {
                    Text('✓').fontSize(11).fontColor(Color.White)
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
            .onClick(() => { this.selectedFish = fish.id; })
          })
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
    }.width('100%').alignItems(HorizontalAlign.Start)
  }


  @Builder WaterSection() {
    Column({ space: 12 }) {
      Text('水域环境').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#1A1A1A')

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.waterList, (water: WaterItem) => {
          Row({ space: 6 }) {
            Image(this.selectedWater === water.type ? water.selectedImage : water.normalImage)
              .width(20).height(20)
            Text(water.name).fontSize(14)
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
          .onClick(() => { this.selectedWater = water.type; })
        })
      }
    }.width('100%').alignItems(HorizontalAlign.Start)
  }

  @Builder SeasonWeatherSection() {
    Column({ space: 16 }) {
      Text('季节与天气').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#1A1A1A')

      // 温度滑块卡片
      Column({ space: 12 }) {
        Row() {
          Row({ space: 6 }) {
            Text('🌡').fontSize(16)
            Text('气温').fontSize(15).fontColor('#1A1A1A')
          }
          Blank()
          Text(`${this.temperature}°C`).fontSize(18).fontWeight(FontWeight.Bold).fontColor(ThemeColors.PRIMARY)
        }.width('100%')

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
            // 根据温度自动调整季节
            if (this.temperature < 10) this.selectedSeason = 'winter';
            else if (this.temperature < 20) this.selectedSeason = 'spring';
            else if (this.temperature < 30) this.selectedSeason = 'summer';
            else this.selectedSeason = 'autumn';
          })

        Row() {
          Text('寒冷 (0°C)').fontSize(12).fontColor('#999')
          Blank()
          Text('炎热 (40°C)').fontSize(12).fontColor('#999')
        }.width('100%')
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .borderRadius(12)

      // 季节选择 2x2 网格
      Grid() {
        ForEach(this.seasonList, (season: SeasonItem) => {
          GridItem() {
            Column({ space: 8 }) {
              Image(this.selectedSeason === season.type ? season.selectedImage : season.normalImage)
                .width(36).height(36)
              Text(season.name).fontSize(14)
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
            .onClick(() => { this.selectedSeason = season.type; })
          }
        })
      }
      .columnsTemplate('1fr 1fr')
      .rowsGap(12)
      .columnsGap(12)
      .width('100%')
      .height(172)
    }.width('100%').alignItems(HorizontalAlign.Start)
  }


  @Builder AdvancedSection() {
    Column({ space: 12 }) {
      Row() {
        Text('⚙').fontSize(16).fontColor('#666')
        Text('高级选项').fontSize(16).fontColor('#1A1A1A').margin({ left: 8 })
        Blank()
        Text(this.showAdvanced ? '∧' : '∨').fontSize(16).fontColor('#999')
      }
      .width('100%')
      .height(50)
      .padding({ left: 16, right: 16 })
      .backgroundColor(Color.White)
      .borderRadius(12)
      .onClick(() => { this.showAdvanced = !this.showAdvanced; })

      if (this.showAdvanced) {
        Column({ space: 16 }) {
          // 鱼情
          Column({ space: 8 }) {
            Text('鱼情判断').fontSize(14).fontColor('#666')
            Row({ space: 8 }) {
              this.OptionChip('密度高', this.fishDensity === 'high', () => { this.fishDensity = 'high'; })
              this.OptionChip('密度中', this.fishDensity === 'medium', () => { this.fishDensity = 'medium'; })
              this.OptionChip('密度低', this.fishDensity === 'low', () => { this.fishDensity = 'low'; })
            }
            Row({ space: 8 }) {
              this.OptionChip('开口好', this.fishActivity === 'good', () => { this.fishActivity = 'good'; })
              this.OptionChip('开口一般', this.fishActivity === 'normal', () => { this.fishActivity = 'normal'; })
              this.OptionChip('开口差', this.fishActivity === 'poor', () => { this.fishActivity = 'poor'; })
            }
          }.width('100%').alignItems(HorizontalAlign.Start)

          // 钓法
          Column({ space: 8 }) {
            Text('作钓方式').fontSize(14).fontColor('#666')
            Row({ space: 8 }) {
              this.OptionChip('搓饵', this.fishingMethod === 'rub', () => { this.fishingMethod = 'rub'; })
              this.OptionChip('拉饵', this.fishingMethod === 'pull', () => { this.fishingMethod = 'pull'; })
              this.OptionChip('散炮', this.fishingMethod === 'scatter', () => { this.fishingMethod = 'scatter'; })
              this.OptionChip('包食', this.fishingMethod === 'wrap', () => { this.fishingMethod = 'wrap'; })
            }
          }.width('100%').alignItems(HorizontalAlign.Start)

          // 模式
          Column({ space: 8 }) {
            Text('生成模式').fontSize(14).fontColor('#666')
            Row({ space: 8 }) {
              this.OptionChip('保守', this.mode === 'conservative', () => { this.mode = 'conservative'; })
              this.OptionChip('均衡', this.mode === 'balanced', () => { this.mode = 'balanced'; })
              this.OptionChip('激进', this.mode === 'aggressive', () => { this.mode = 'aggressive'; })
            }
          }.width('100%').alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding(16)
        .backgroundColor(Color.White)
        .borderRadius(12)
      }
    }.width('100%').alignItems(HorizontalAlign.Start)
  }

  @Builder OptionChip(label: string, selected: boolean, onClick: () => void) {
    Text(label)
      .fontSize(13)
      .fontColor(selected ? ThemeColors.PRIMARY : '#666')
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .backgroundColor(selected ? '#FFF5E6' : '#F5F5F5')
      .borderRadius(16)
      .border({ width: selected ? 1 : 0, color: ThemeColors.PRIMARY })
      .onClick(onClick)
  }

  @Builder LastRecordSection() {
    Row() {
      Row({ space: 6 }) {
        Text('⏱').fontSize(14).fontColor('#999')
        Text(`上次记录: ${this.lastRecord}`).fontSize(13).fontColor('#666')
      }
      Blank()
      Text('载入').fontSize(14).fontColor(ThemeColors.PRIMARY)
    }
    .width('100%')
    .padding({ left: 4, right: 4 })
  }

  @Builder GenerateButton() {
    Column() {
      Button() {
        Row({ space: 8 }) {
          if (this.isLoading) {
            LoadingProgress().width(20).height(20).color(Color.White)
          } else {
            Text('✦').fontSize(16).fontColor(Color.White)
          }
          Text(this.isLoading ? '生成中...' : '生成配方')
            .fontSize(16).fontColor(Color.White).fontWeight(FontWeight.Medium)
        }
      }
      .width('100%')
      .height(52)
      .backgroundColor(ThemeColors.PRIMARY)
      .borderRadius(26)
      .enabled(!this.isLoading)
      .onClick(() => this.onGenerate())
    }
    .width('100%')
    .padding({ left: 20, right: 20, bottom: 34, top: 12 })
    .backgroundColor('#FFFBF5')
  }
}
