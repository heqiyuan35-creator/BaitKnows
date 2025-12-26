/**
 * 饵知道 - 配方创作页面
 * 用户自定义创建鱼饵配方
 */
import { router } from '@kit.ArkUI';
import { ThemeColors } from '../theme/ThemeColors';
import { ThemeConstants } from '../theme/ThemeConstants';
import { ALL_FISH_DATA, FishData } from '../data/FishData';
import { getAllIngredients, Ingredient } from '../data/IngredientDatabase';
import { userDataService, CustomRecipeIngredient, RecipeStateProfile, RecipeFlavorProfile, CustomIngredient, CustomFish } from '../services/UserDataService';

// 配方原料项
class RecipeIngredientItem {
  ingredientId: string = '';
  name: string = '';
  ratio: number = 1;
  weight: number = 0;
  category: string = '';
}

// 统一原料显示项（用于选择弹窗）
class IngredientDisplayItem {
  id: string = '';
  name: string = '';
  category: string = '';
  isCustom: boolean = false;
}

// 统一鱼种显示项（用于选择弹窗）
class FishDisplayItem {
  id: string = '';
  name: string = '';
  icon: Resource | string = $r('app.media.fishImage');
  waterTypes: string[] = [];
  isCustom: boolean = false;
}

// 选项类
class SelectOption {
  id: string = '';
  name: string = '';
}

// 创建选项辅助函数
function makeOption(id: string, name: string): SelectOption {
  const opt = new SelectOption();
  opt.id = id;
  opt.name = name;
  return opt;
}

@Entry
@Component
struct RecipeCreatePage {
  @State recipeName: string = '';
  @State selectedFishIds: string[] = [];
  @State selectedWaterType: string = 'pond';
  @State selectedSeason: string = 'spring';
  @State ingredients: RecipeIngredientItem[] = [];
  @State steps: string[] = [''];
  @State tips: string = '';
  @State showFishPicker: boolean = false;
  @State showIngredientPicker: boolean = false;

  // 新增字段
  @State difficulty: string = 'medium';
  @State prepTime: string = '15分钟';
  @State totalWeight: number = 500;

  // 状态特性
  @State atomization: number = 3;
  @State viscosity: number = 3;
  @State hookHolding: number = 3;
  @State baitWeight: number = 3;

  // 味型特性
  @State primaryFlavor: string = 'fishy';
  @State secondaryFlavor: string = '';
  @State flavorIntensity: number = 3;

  // 提示信息
  @State toastMessage: string = '';
  @State showToast: boolean = false;
  @State isSaving: boolean = false;

  private waterTypes: SelectOption[] = [
    makeOption('pond', '池塘'),
    makeOption('river', '河流'),
    makeOption('reservoir', '水库'),
    makeOption('lake', '湖泊')
  ];

  private seasons: SelectOption[] = [
    makeOption('spring', '春季'),
    makeOption('summer', '夏季'),
    makeOption('autumn', '秋季'),
    makeOption('winter', '冬季')
  ];

  private difficulties: SelectOption[] = [
    makeOption('easy', '简单'),
    makeOption('medium', '中等'),
    makeOption('hard', '困难')
  ];

  private flavors: SelectOption[] = [
    makeOption('fishy', '腥'),
    makeOption('fragrant', '香'),
    makeOption('sweet', '甜'),
    makeOption('sour', '酸'),
    makeOption('smelly', '臭'),
    makeOption('plain', '本味')
  ];

  async aboutToAppear(): Promise<void> {
    // 确保用户数据服务已加载
    await userDataService.load();
  }

  build() {
    Column() {
      // 顶部导航栏
      this.NavBar()

      // 表单内容
      Scroll() {
        Column({ space: 16 }) {
          // 配方名称
          this.FormSection('配方名称')

          // 目标鱼种
          this.FishSelectorSection()

          // 适合水域
          this.WaterTypeSection()

          // 适合季节
          this.SeasonSection()

          // 难度和准备时间
          this.DifficultySection()

          // 总重量
          this.TotalWeightSection()

          // 原料配比
          this.IngredientSection()

          // 状态特性
          this.StateProfileSection()

          // 味型特性
          this.FlavorProfileSection()

          // 制作步骤
          this.StepsSection()

          // 使用技巧
          this.TipsSection()

          // 保存按钮
          Button('保存配方')
            .width('100%')
            .height(48)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .backgroundColor(ThemeColors.PRIMARY)
            .fontColor(ThemeColors.TEXT_PRIMARY)
            .margin({ top: 16, bottom: 32 })
            .onClick(() => this.saveRecipe())
        }
        .padding(16)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      // 鱼种选择弹窗
      if (this.showFishPicker) {
        this.FishPickerDialog()
      }

      // 原料选择弹窗
      if (this.showIngredientPicker) {
        this.IngredientPickerDialog()
      }

      // Toast 提示
      if (this.showToast) {
        Column() {
          Text(this.toastMessage)
            .fontSize(14)
            .fontColor(Color.White)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor('rgba(0, 0, 0, 0.7)')
            .borderRadius(20)
        }
        .width('100%')
        .position({ x: 0, y: '40%' })
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeColors.BG_PRIMARY)
  }

  @Builder
  NavBar() {
    Row() {
      Text('←')
        .fontSize(24)
        .fontColor(ThemeColors.TEXT_PRIMARY)
        .onClick(() => router.back())
        .padding(8)

      Text('创建配方')
        .fontSize(ThemeConstants.FONT_SIZE_LG)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeColors.TEXT_PRIMARY)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Text('')
        .width(40)
    }
    .width('100%')
    .height(56)
    .padding({ left: 8, right: 16 })
    .margin({ top: 44 })
    .backgroundColor(ThemeColors.BG_SECONDARY)
  }

  @Builder
  FormSection(title: string) {
    Column({ space: 8 }) {
      Text(title)
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .fontWeight(FontWeight.Medium)

      TextInput({ placeholder: '请输入配方名称', text: this.recipeName })
        .width('100%')
        .height(44)
        .fontSize(ThemeConstants.FONT_SIZE_BASE)
        .backgroundColor(ThemeColors.BG_CARD)
        .borderRadius(ThemeConstants.RADIUS_SM)
        .padding({ left: 12, right: 12 })
        .onChange((value: string) => {
          this.recipeName = value;
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  FishSelectorSection() {
    Column({ space: 8 }) {
      Text('目标鱼种')
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .fontWeight(FontWeight.Medium)

      Row() {
        if (this.selectedFishIds.length === 0) {
          Text('点击选择目标鱼种')
            .fontSize(ThemeConstants.FONT_SIZE_BASE)
            .fontColor(ThemeColors.TEXT_HINT)
        } else {
          Text(this.getSelectedFishNames())
            .fontSize(ThemeConstants.FONT_SIZE_BASE)
            .fontColor(ThemeColors.TEXT_PRIMARY)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        Blank()
        Text('>')
          .fontSize(16)
          .fontColor(ThemeColors.TEXT_MUTED)
      }
      .width('100%')
      .height(44)
      .padding({ left: 12, right: 12 })
      .backgroundColor(ThemeColors.BG_CARD)
      .borderRadius(ThemeConstants.RADIUS_SM)
      .onClick(() => {
        this.showFishPicker = true;
      })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  WaterTypeSection() {
    Column({ space: 8 }) {
      Text('适合水域')
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .fontWeight(FontWeight.Medium)

      Row({ space: 8 }) {
        ForEach(this.waterTypes, (item: SelectOption) => {
          Text(item.name)
            .fontSize(ThemeConstants.FONT_SIZE_SM)
            .fontColor(this.getWaterTypeColor(item.id))
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .backgroundColor(this.getWaterTypeBgColor(item.id))
            .borderRadius(ThemeConstants.RADIUS_FULL)
            .border({
              width: 1,
              color: this.selectedWaterType === item.id && this.isWaterTypeAvailable(item.id) ?
                ThemeColors.PRIMARY : Color.Transparent
            })
            .opacity(this.isWaterTypeAvailable(item.id) ? 1.0 : 0.4)
            .onClick(() => {
              if (this.isWaterTypeAvailable(item.id)) {
                this.selectedWaterType = item.id;
              }
            })
        })
      }
      .width('100%')

      // 提示信息
      if (this.selectedFishIds.length > 0 && !this.isWaterTypeAvailable(this.selectedWaterType)) {
        Text('当前选择的水域不适合所选鱼种，请重新选择')
          .fontSize(12)
          .fontColor(ThemeColors.ERROR)
          .margin({ top: 4 })
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  // 获取水域文字颜色
  private getWaterTypeColor(waterTypeId: string): ResourceColor {
    if (!this.isWaterTypeAvailable(waterTypeId)) {
      return ThemeColors.TEXT_MUTED;
    }
    return this.selectedWaterType === waterTypeId ? ThemeColors.PRIMARY : ThemeColors.TEXT_SECONDARY;
  }

  // 获取水域背景颜色
  private getWaterTypeBgColor(waterTypeId: string): ResourceColor {
    if (!this.isWaterTypeAvailable(waterTypeId)) {
      return ThemeColors.BG_CARD;
    }
    return this.selectedWaterType === waterTypeId ? 'rgba(232, 168, 73, 0.15)' : ThemeColors.BG_CARD;
  }

  // 检查水域是否可用（根据选中的鱼种）
  private isWaterTypeAvailable(waterTypeId: string): boolean {
    if (this.selectedFishIds.length === 0) {
      return true; // 没选鱼种时所有水域都可用
    }

    // 获取所有选中鱼种的水域交集
    const availableWaterTypes = this.getAvailableWaterTypes();
    return availableWaterTypes.includes(waterTypeId);
  }

  // 获取选中鱼种的可用水域（支持系统鱼种和用户自定义鱼种）
  private getAvailableWaterTypes(): string[] {
    if (this.selectedFishIds.length === 0) {
      return ['pond', 'river', 'reservoir', 'lake'];
    }

    // 收集所有选中鱼种的水域
    const allWaterTypes: Set<string> = new Set();
    for (const fishId of this.selectedFishIds) {
      // 先从系统鱼种查找
      const fish = ALL_FISH_DATA.find((f: FishData) => f.id === fishId);
      if (fish) {
        for (const wt of fish.waterTypes) {
          allWaterTypes.add(wt);
        }
      } else {
        // 再从用户自定义鱼种查找
        const customFish = userDataService.getCustomFish().find((f: CustomFish) => f.id === fishId);
        if (customFish) {
          for (const wt of customFish.waterTypes) {
            allWaterTypes.add(wt);
          }
        }
      }
    }

    return Array.from(allWaterTypes);
  }

  // 获取所有鱼种列表（系统 + 用户自定义）
  private getAllFishItems(): FishDisplayItem[] {
    const items: FishDisplayItem[] = [];

    // 添加系统鱼种
    for (const fish of ALL_FISH_DATA) {
      const item = new FishDisplayItem();
      item.id = fish.id;
      item.name = fish.name;
      item.icon = fish.icon;
      item.waterTypes = fish.waterTypes;
      item.isCustom = false;
      items.push(item);
    }

    // 添加用户自定义鱼种
    const customFishList = userDataService.getCustomFish();
    for (const fish of customFishList) {
      const item = new FishDisplayItem();
      item.id = fish.id;
      item.name = fish.name;
      item.icon = fish.icon || $r('app.media.fishImage');
      item.waterTypes = fish.waterTypes;
      item.isCustom = true;
      items.push(item);
    }

    return items;
  }

  @Builder
  SeasonSection() {
    Column({ space: 8 }) {
      Text('适合季节')
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .fontWeight(FontWeight.Medium)

      Row({ space: 8 }) {
        ForEach(this.seasons, (item: SelectOption) => {
          Text(item.name)
            .fontSize(ThemeConstants.FONT_SIZE_SM)
            .fontColor(this.selectedSeason === item.id ? ThemeColors.PRIMARY : ThemeColors.TEXT_SECONDARY)
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .backgroundColor(this.selectedSeason === item.id ? 'rgba(232, 168, 73, 0.15)' : ThemeColors.BG_CARD)
            .borderRadius(ThemeConstants.RADIUS_FULL)
            .border({
              width: 1,
              color: this.selectedSeason === item.id ? ThemeColors.PRIMARY : Color.Transparent
            })
            .onClick(() => {
              this.selectedSeason = item.id;
            })
        })
      }
      .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  DifficultySection() {
    Column({ space: 8 }) {
      Text('制作难度')
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .fontWeight(FontWeight.Medium)

      Row({ space: 8 }) {
        ForEach(this.difficulties, (item: SelectOption) => {
          Text(item.name)
            .fontSize(ThemeConstants.FONT_SIZE_SM)
            .fontColor(this.difficulty === item.id ? ThemeColors.PRIMARY : ThemeColors.TEXT_SECONDARY)
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .backgroundColor(this.difficulty === item.id ? 'rgba(232, 168, 73, 0.15)' : ThemeColors.BG_CARD)
            .borderRadius(ThemeConstants.RADIUS_FULL)
            .border({
              width: 1,
              color: this.difficulty === item.id ? ThemeColors.PRIMARY : Color.Transparent
            })
            .onClick(() => {
              this.difficulty = item.id;
            })
        })
      }
      .width('100%')

      // 准备时间
      Row() {
        Text('准备时间')
          .fontSize(ThemeConstants.FONT_SIZE_SM)
          .fontColor(ThemeColors.TEXT_SECONDARY)

        Blank()

        TextInput({ placeholder: '如：15分钟', text: this.prepTime })
          .width(120)
          .height(36)
          .fontSize(ThemeConstants.FONT_SIZE_SM)
          .backgroundColor(ThemeColors.BG_CARD)
          .borderRadius(ThemeConstants.RADIUS_SM)
          .textAlign(TextAlign.Center)
          .onChange((value: string) => {
            this.prepTime = value;
          })
      }
      .width('100%')
      .margin({ top: 8 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  TotalWeightSection() {
    Column({ space: 8 }) {
      Text('配方总重量')
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .fontWeight(FontWeight.Medium)

      Row() {
        TextInput({ placeholder: '500', text: this.totalWeight.toString() })
          .width(100)
          .height(40)
          .fontSize(ThemeConstants.FONT_SIZE_BASE)
          .backgroundColor(ThemeColors.BG_CARD)
          .borderRadius(ThemeConstants.RADIUS_SM)
          .textAlign(TextAlign.Center)
          .type(InputType.Number)
          .onChange((value: string) => {
            const num = parseInt(value);
            if (!isNaN(num) && num > 0) {
              this.totalWeight = num;
            }
          })

        Text('克')
          .fontSize(ThemeConstants.FONT_SIZE_BASE)
          .fontColor(ThemeColors.TEXT_SECONDARY)
          .margin({ left: 8 })
      }
      .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  IngredientSection() {
    Column({ space: 8 }) {
      Text('原料配比')
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .fontWeight(FontWeight.Medium)

      Column({ space: 8 }) {
        ForEach(this.ingredients, (item: RecipeIngredientItem, index: number) => {
          Row() {
            Text(item.name)
              .fontSize(ThemeConstants.FONT_SIZE_BASE)
              .fontColor(ThemeColors.TEXT_PRIMARY)
              .layoutWeight(1)

            Text(`${item.ratio}份`)
              .fontSize(ThemeConstants.FONT_SIZE_SM)
              .fontColor(ThemeColors.TEXT_SECONDARY)
              .margin({ right: 12 })

            Text('×')
              .fontSize(16)
              .fontColor(ThemeColors.ERROR)
              .onClick(() => {
                this.ingredients.splice(index, 1);
                this.ingredients = this.ingredients.slice();
              })
          }
          .width('100%')
          .height(44)
          .padding({ left: 12, right: 12 })
          .backgroundColor(ThemeColors.BG_CARD)
          .borderRadius(ThemeConstants.RADIUS_SM)
        })

        // 添加原料按钮
        Row() {
          Text('+ 添加原料')
            .fontSize(ThemeConstants.FONT_SIZE_BASE)
            .fontColor(ThemeColors.PRIMARY)
        }
        .width('100%')
        .height(44)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(ThemeColors.BG_CARD)
        .borderRadius(ThemeConstants.RADIUS_SM)
        .border({ width: 1, color: ThemeColors.PRIMARY, style: BorderStyle.Dashed })
        .onClick(() => {
          this.showIngredientPicker = true;
        })
      }
      .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  StepsSection() {
    Column({ space: 8 }) {
      Text('制作步骤')
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .fontWeight(FontWeight.Medium)

      Column({ space: 8 }) {
        ForEach(this.steps, (step: string, index: number) => {
          Row() {
            Text(`${index + 1}.`)
              .fontSize(ThemeConstants.FONT_SIZE_BASE)
              .fontColor(ThemeColors.PRIMARY)
              .fontWeight(FontWeight.Bold)
              .margin({ right: 8 })

            TextInput({ placeholder: '输入步骤内容', text: step })
              .layoutWeight(1)
              .height(40)
              .fontSize(ThemeConstants.FONT_SIZE_BASE)
              .backgroundColor(Color.Transparent)
              .onChange((value: string) => {
                this.steps[index] = value;
              })

            if (this.steps.length > 1) {
              Text('×')
                .fontSize(16)
                .fontColor(ThemeColors.ERROR)
                .margin({ left: 8 })
                .onClick(() => {
                  this.steps.splice(index, 1);
                  this.steps = this.steps.slice();
                })
            }
          }
          .width('100%')
          .padding({ left: 12, right: 12 })
          .backgroundColor(ThemeColors.BG_CARD)
          .borderRadius(ThemeConstants.RADIUS_SM)
        })

        // 添加步骤按钮
        Row() {
          Text('+ 添加步骤')
            .fontSize(ThemeConstants.FONT_SIZE_BASE)
            .fontColor(ThemeColors.PRIMARY)
        }
        .width('100%')
        .height(44)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(ThemeColors.BG_CARD)
        .borderRadius(ThemeConstants.RADIUS_SM)
        .border({ width: 1, color: ThemeColors.PRIMARY, style: BorderStyle.Dashed })
        .onClick(() => {
          this.steps.push('');
          this.steps = this.steps.slice();
        })
      }
      .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  TipsSection() {
    Column({ space: 8 }) {
      Text('使用技巧')
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .fontWeight(FontWeight.Medium)

      TextArea({ placeholder: '输入使用技巧和注意事项', text: this.tips })
        .width('100%')
        .height(100)
        .fontSize(ThemeConstants.FONT_SIZE_BASE)
        .backgroundColor(ThemeColors.BG_CARD)
        .borderRadius(ThemeConstants.RADIUS_SM)
        .padding(12)
        .onChange((value: string) => {
          this.tips = value;
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  StateProfileSection() {
    Column({ space: 12 }) {
      Text('状态特性')
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .fontWeight(FontWeight.Medium)

      // 雾化性
      Column({ space: 4 }) {
        Row() {
          Text('雾化性')
            .fontSize(ThemeConstants.FONT_SIZE_SM)
            .fontColor(ThemeColors.TEXT_PRIMARY)
          Blank()
          Text(this.getStateLabel(this.atomization))
            .fontSize(ThemeConstants.FONT_SIZE_SM)
            .fontColor(ThemeColors.PRIMARY)
        }
        .width('100%')

        Slider({
          value: this.atomization,
          min: 1,
          max: 5,
          step: 1,
          style: SliderStyle.OutSet
        })
          .width('100%')
          .blockColor(ThemeColors.PRIMARY)
          .trackColor(ThemeColors.BG_TERTIARY)
          .selectedColor(ThemeColors.PRIMARY)
          .onChange((newValue: number) => {
            this.atomization = Math.round(newValue);
          })
      }
      .width('100%')

      // 粘度
      Column({ space: 4 }) {
        Row() {
          Text('粘度')
            .fontSize(ThemeConstants.FONT_SIZE_SM)
            .fontColor(ThemeColors.TEXT_PRIMARY)
          Blank()
          Text(this.getStateLabel(this.viscosity))
            .fontSize(ThemeConstants.FONT_SIZE_SM)
            .fontColor(ThemeColors.PRIMARY)
        }
        .width('100%')

        Slider({
          value: this.viscosity,
          min: 1,
          max: 5,
          step: 1,
          style: SliderStyle.OutSet
        })
          .width('100%')
          .blockColor(ThemeColors.PRIMARY)
          .trackColor(ThemeColors.BG_TERTIARY)
          .selectedColor(ThemeColors.PRIMARY)
          .onChange((newValue: number) => {
            this.viscosity = Math.round(newValue);
          })
      }
      .width('100%')

      // 附钩性
      Column({ space: 4 }) {
        Row() {
          Text('附钩性')
            .fontSize(ThemeConstants.FONT_SIZE_SM)
            .fontColor(ThemeColors.TEXT_PRIMARY)
          Blank()
          Text(this.getStateLabel(this.hookHolding))
            .fontSize(ThemeConstants.FONT_SIZE_SM)
            .fontColor(ThemeColors.PRIMARY)
        }
        .width('100%')

        Slider({
          value: this.hookHolding,
          min: 1,
          max: 5,
          step: 1,
          style: SliderStyle.OutSet
        })
          .width('100%')
          .blockColor(ThemeColors.PRIMARY)
          .trackColor(ThemeColors.BG_TERTIARY)
          .selectedColor(ThemeColors.PRIMARY)
          .onChange((newValue: number) => {
            this.hookHolding = Math.round(newValue);
          })
      }
      .width('100%')

      // 比重
      Column({ space: 4 }) {
        Row() {
          Text('比重')
            .fontSize(ThemeConstants.FONT_SIZE_SM)
            .fontColor(ThemeColors.TEXT_PRIMARY)
          Blank()
          Text(this.getStateLabel(this.baitWeight))
            .fontSize(ThemeConstants.FONT_SIZE_SM)
            .fontColor(ThemeColors.PRIMARY)
        }
        .width('100%')

        Slider({
          value: this.baitWeight,
          min: 1,
          max: 5,
          step: 1,
          style: SliderStyle.OutSet
        })
          .width('100%')
          .blockColor(ThemeColors.PRIMARY)
          .trackColor(ThemeColors.BG_TERTIARY)
          .selectedColor(ThemeColors.PRIMARY)
          .onChange((newValue: number) => {
            this.baitWeight = Math.round(newValue);
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(12)
    .backgroundColor(ThemeColors.BG_CARD)
    .borderRadius(ThemeConstants.RADIUS_SM)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  SliderRow(label: string, value: number, onChange: (value: number) => void) {
    Column({ space: 4 }) {
      Row() {
        Text(label)
          .fontSize(ThemeConstants.FONT_SIZE_SM)
          .fontColor(ThemeColors.TEXT_PRIMARY)

        Blank()

        Text(this.getStateLabel(value))
          .fontSize(ThemeConstants.FONT_SIZE_SM)
          .fontColor(ThemeColors.PRIMARY)
      }
      .width('100%')

      Slider({
        value: value,
        min: 1,
        max: 5,
        step: 1,
        style: SliderStyle.OutSet
      })
        .width('100%')
        .blockColor(ThemeColors.PRIMARY)
        .trackColor(ThemeColors.BG_TERTIARY)
        .selectedColor(ThemeColors.PRIMARY)
        .onChange((newValue: number) => {
          onChange(Math.round(newValue));
        })
    }
    .width('100%')
  }

  private getStateLabel(value: number): string {
    const labels: string[] = ['很低', '较低', '中等', '较高', '很高'];
    return labels[value - 1] || '中等';
  }

  @Builder
  FlavorProfileSection() {
    Column({ space: 12 }) {
      Text('味型特性')
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .fontWeight(FontWeight.Medium)

      // 主味型
      Column({ space: 8 }) {
        Text('主味型')
          .fontSize(ThemeConstants.FONT_SIZE_SM)
          .fontColor(ThemeColors.TEXT_PRIMARY)

        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.flavors, (item: SelectOption) => {
            Text(item.name)
              .fontSize(ThemeConstants.FONT_SIZE_SM)
              .fontColor(this.primaryFlavor === item.id ? ThemeColors.PRIMARY : ThemeColors.TEXT_SECONDARY)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .margin({ right: 8, bottom: 8 })
              .backgroundColor(this.primaryFlavor === item.id ? 'rgba(232, 168, 73, 0.15)' : ThemeColors.BG_TERTIARY)
              .borderRadius(ThemeConstants.RADIUS_FULL)
              .border({
                width: 1,
                color: this.primaryFlavor === item.id ? ThemeColors.PRIMARY : Color.Transparent
              })
              .onClick(() => {
                this.primaryFlavor = item.id;
              })
          })
        }
        .width('100%')
      }

      // 副味型
      Column({ space: 8 }) {
        Text('副味型（可选）')
          .fontSize(ThemeConstants.FONT_SIZE_SM)
          .fontColor(ThemeColors.TEXT_PRIMARY)

        Flex({ wrap: FlexWrap.Wrap }) {
          Text('无')
            .fontSize(ThemeConstants.FONT_SIZE_SM)
            .fontColor(this.secondaryFlavor === '' ? ThemeColors.PRIMARY : ThemeColors.TEXT_SECONDARY)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .margin({ right: 8, bottom: 8 })
            .backgroundColor(this.secondaryFlavor === '' ? 'rgba(232, 168, 73, 0.15)' : ThemeColors.BG_TERTIARY)
            .borderRadius(ThemeConstants.RADIUS_FULL)
            .border({
              width: 1,
              color: this.secondaryFlavor === '' ? ThemeColors.PRIMARY : Color.Transparent
            })
            .onClick(() => {
              this.secondaryFlavor = '';
            })

          ForEach(this.flavors, (item: SelectOption) => {
            Text(item.name)
              .fontSize(ThemeConstants.FONT_SIZE_SM)
              .fontColor(this.secondaryFlavor === item.id ? ThemeColors.PRIMARY : ThemeColors.TEXT_SECONDARY)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .margin({ right: 8, bottom: 8 })
              .backgroundColor(this.secondaryFlavor === item.id ? 'rgba(232, 168, 73, 0.15)' : ThemeColors.BG_TERTIARY)
              .borderRadius(ThemeConstants.RADIUS_FULL)
              .border({
                width: 1,
                color: this.secondaryFlavor === item.id ? ThemeColors.PRIMARY : Color.Transparent
              })
              .onClick(() => {
                this.secondaryFlavor = item.id;
              })
          })
        }
        .width('100%')
      }

      // 味型浓度
      Column({ space: 4 }) {
        Row() {
          Text('味型浓度')
            .fontSize(ThemeConstants.FONT_SIZE_SM)
            .fontColor(ThemeColors.TEXT_PRIMARY)
          Blank()
          Text(this.getStateLabel(this.flavorIntensity))
            .fontSize(ThemeConstants.FONT_SIZE_SM)
            .fontColor(ThemeColors.PRIMARY)
        }
        .width('100%')

        Slider({
          value: this.flavorIntensity,
          min: 1,
          max: 5,
          step: 1,
          style: SliderStyle.OutSet
        })
          .width('100%')
          .blockColor(ThemeColors.PRIMARY)
          .trackColor(ThemeColors.BG_TERTIARY)
          .selectedColor(ThemeColors.PRIMARY)
          .onChange((newValue: number) => {
            this.flavorIntensity = Math.round(newValue);
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(12)
    .backgroundColor(ThemeColors.BG_CARD)
    .borderRadius(ThemeConstants.RADIUS_SM)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  FishPickerDialog() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.5)')
        .onClick(() => {
          this.showFishPicker = false;
        })

      Column() {
        Row() {
          Text('选择目标鱼种')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.TEXT_PRIMARY)
          Blank()
          Text('完成')
            .fontSize(16)
            .fontColor(ThemeColors.PRIMARY)
            .onClick(() => {
              this.showFishPicker = false;
            })
        }
        .width('100%')
        .padding({ bottom: 12 })

        Scroll() {
          Column({ space: 8 }) {
            // 显示所有鱼种（系统 + 用户自定义）
            ForEach(this.getAllFishItems(), (fish: FishDisplayItem) => {
              Row() {
                Image(fish.icon)
                  .width(36)
                  .height(36)
                  .borderRadius(18)
                  .margin({ right: 12 })

                Column() {
                  Row({ space: 4 }) {
                    Text(fish.name)
                      .fontSize(16)
                      .fontColor(ThemeColors.TEXT_PRIMARY)

                    if (fish.isCustom) {
                      Text('自定义')
                        .fontSize(10)
                        .fontColor(ThemeColors.PRIMARY)
                        .padding({ left: 4, right: 4, top: 2, bottom: 2 })
                        .backgroundColor('rgba(232, 168, 73, 0.15)')
                        .borderRadius(4)
                    }
                  }
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                Checkbox()
                  .select(this.selectedFishIds.includes(fish.id))
                  .selectedColor(ThemeColors.PRIMARY)
                  .onChange((checked: boolean) => {
                    if (checked) {
                      this.selectedFishIds.push(fish.id);
                    } else {
                      const idx = this.selectedFishIds.indexOf(fish.id);
                      if (idx > -1) {
                        this.selectedFishIds.splice(idx, 1);
                      }
                    }
                    this.selectedFishIds = this.selectedFishIds.slice();

                    // 检查当前水域是否仍然可用，如果不可用则自动切换
                    if (!this.isWaterTypeAvailable(this.selectedWaterType)) {
                      const available = this.getAvailableWaterTypes();
                      if (available.length > 0) {
                        this.selectedWaterType = available[0];
                      }
                    }
                  })
              }
              .width('100%')
              .padding(12)
              .backgroundColor(ThemeColors.BG_TERTIARY)
              .borderRadius(8)
            })
          }
        }
        .height(400)
        .scrollBar(BarState.Auto)
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
  IngredientPickerDialog() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.5)')
        .onClick(() => {
          this.showIngredientPicker = false;
        })

      Column() {
        Row() {
          Text('选择原料')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.TEXT_PRIMARY)
          Blank()
          Text('✕')
            .fontSize(20)
            .fontColor(ThemeColors.TEXT_SECONDARY)
            .onClick(() => {
              this.showIngredientPicker = false;
            })
        }
        .width('100%')
        .padding({ bottom: 12 })

        Scroll() {
          Column({ space: 8 }) {
            // 用户自定义原料（如果有）
            ForEach(this.getCustomIngredientItems(), (item: IngredientDisplayItem) => {
              Row() {
                Column() {
                  Row({ space: 4 }) {
                    Text(item.name)
                      .fontSize(16)
                      .fontColor(ThemeColors.TEXT_PRIMARY)

                    Text('自定义')
                      .fontSize(10)
                      .fontColor(Color.White)
                      .padding({ left: 4, right: 4, top: 2, bottom: 2 })
                      .backgroundColor(ThemeColors.PRIMARY)
                      .borderRadius(4)
                  }

                  Text(this.getCategoryName(item.category))
                    .fontSize(12)
                    .fontColor(ThemeColors.TEXT_MUTED)
                    .margin({ top: 2 })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                Text('+')
                  .fontSize(20)
                  .fontColor(ThemeColors.PRIMARY)
                  .padding(8)
                  .onClick(() => {
                    this.addIngredientToRecipe(item);
                  })
              }
              .width('100%')
              .padding(12)
              .backgroundColor('rgba(232, 168, 73, 0.1)')
              .borderRadius(8)
            })

            // 系统原料
            ForEach(this.getSystemIngredientItems(), (item: IngredientDisplayItem) => {
              Row() {
                Column() {
                  Text(item.name)
                    .fontSize(16)
                    .fontColor(ThemeColors.TEXT_PRIMARY)

                  Text(this.getCategoryName(item.category))
                    .fontSize(12)
                    .fontColor(ThemeColors.TEXT_MUTED)
                    .margin({ top: 2 })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                Text('+')
                  .fontSize(20)
                  .fontColor(ThemeColors.PRIMARY)
                  .padding(8)
                  .onClick(() => {
                    this.addIngredientToRecipe(item);
                  })
              }
              .width('100%')
              .padding(12)
              .backgroundColor(ThemeColors.BG_TERTIARY)
              .borderRadius(8)
            })
          }
        }
        .height(450)
        .scrollBar(BarState.Auto)
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

  // 获取用户自定义原料列表
  private getCustomIngredientItems(): IngredientDisplayItem[] {
    const customList = userDataService.getCustomIngredients();
    const result: IngredientDisplayItem[] = [];
    for (let i = 0; i < customList.length; i++) {
      const c = customList[i];
      const item = new IngredientDisplayItem();
      item.id = c.id;
      item.name = c.name;
      item.category = c.category;
      item.isCustom = true;
      result.push(item);
    }
    return result;
  }

  // 获取系统原料列表
  private getSystemIngredientItems(): IngredientDisplayItem[] {
    const systemList = getAllIngredients();
    const result: IngredientDisplayItem[] = [];
    for (let i = 0; i < systemList.length; i++) {
      const s = systemList[i];
      const item = new IngredientDisplayItem();
      item.id = s.id;
      item.name = s.name;
      item.category = s.category;
      item.isCustom = false;
      result.push(item);
    }
    return result;
  }

  // 添加原料到配方
  private addIngredientToRecipe(item: IngredientDisplayItem): void {
    // 检查是否已添加
    const exists = this.ingredients.some((ing: RecipeIngredientItem) => ing.ingredientId === item.id);
    if (!exists) {
      const newItem = new RecipeIngredientItem();
      newItem.ingredientId = item.id;
      newItem.name = item.name;
      newItem.ratio = 1;
      newItem.category = item.category;
      this.ingredients.push(newItem);
      this.ingredients = this.ingredients.slice();
    }
    this.showIngredientPicker = false;
  }

  // 获取原料分类名称
  private getCategoryName(category: string): string {
    const categoryNames: Record<string, string> = {
      'base': '基础饵料',
      'protein': '蛋白质类',
      'additive': '添加剂',
      'state': '状态调节',
      'binder': '粘合剂',
      'natural': '天然原料',
      'pellet': '颗粒饵',
      'live': '活饵',
      'folk': '民间偏方'
    };
    return categoryNames[category] || '其他';
  }

  private getSelectedFishNames(): string {
    return this.selectedFishIds
      .map((id: string) => {
        // 先从系统鱼种查找
        const fish = ALL_FISH_DATA.find((f: FishData) => f.id === id);
        if (fish) {
          return fish.name;
        }
        // 再从用户自定义鱼种查找
        const customFish = userDataService.getCustomFish().find((f: CustomFish) => f.id === id);
        if (customFish) {
          return customFish.name;
        }
        return '';
      })
      .filter((name: string) => name !== '')
      .join('、');
  }

  private async saveRecipe(): Promise<void> {
    // 防止重复提交
    if (this.isSaving) {
      return;
    }

    // 验证配方名称
    const trimmedName = this.recipeName.trim();
    if (!trimmedName) {
      this.showToastMessage('请输入配方名称');
      return;
    }

    if (trimmedName.length < 2) {
      this.showToastMessage('配方名称至少2个字符');
      return;
    }

    if (trimmedName.length > 20) {
      this.showToastMessage('配方名称不能超过20个字符');
      return;
    }

    // 检查配方名称是否重复
    if (userDataService.isRecipeNameExists(trimmedName)) {
      this.showToastMessage('配方名称已存在，请换一个名称');
      return;
    }

    // 验证目标鱼种
    if (this.selectedFishIds.length === 0) {
      this.showToastMessage('请选择目标鱼种');
      return;
    }

    // 验证原料
    if (this.ingredients.length === 0) {
      this.showToastMessage('请至少添加一种原料');
      return;
    }

    // 验证水域是否可用
    if (!this.isWaterTypeAvailable(this.selectedWaterType)) {
      this.showToastMessage('请选择适合所选鱼种的水域');
      return;
    }

    // 验证制作步骤
    const validSteps = this.steps.filter((s: string) => s.trim().length > 0);
    if (validSteps.length === 0) {
      this.showToastMessage('请至少添加一个制作步骤');
      return;
    }

    // 开始保存
    this.isSaving = true;

    try {
      // 转换原料格式
      const recipeIngredients: CustomRecipeIngredient[] = [];
      for (let i = 0; i < this.ingredients.length; i++) {
        const item = this.ingredients[i];
        const ri = new CustomRecipeIngredient();
        ri.ingredientId = item.ingredientId;
        ri.name = item.name;
        ri.ratio = item.ratio;
        ri.weight = item.weight;
        ri.category = item.category;
        recipeIngredients.push(ri);
      }

      // 构建状态特性
      const stateProfile = new RecipeStateProfile();
      stateProfile.atomization = this.atomization;
      stateProfile.viscosity = this.viscosity;
      stateProfile.hookHolding = this.hookHolding;
      stateProfile.weight = this.baitWeight;

      // 构建味型特性
      const flavorProfile = new RecipeFlavorProfile();
      flavorProfile.primary = this.primaryFlavor;
      flavorProfile.secondary = this.secondaryFlavor;
      flavorProfile.intensity = this.flavorIntensity;

      // 保存到 UserDataService
      await userDataService.addRecipe(
        trimmedName,
        this.selectedFishIds.slice(),
        this.selectedWaterType,
        this.selectedSeason,
        recipeIngredients,
        validSteps,
        this.tips.trim(),
        stateProfile,
        flavorProfile,
        this.totalWeight,
        this.difficulty,
        this.prepTime
      );

      console.info('配方保存成功:', trimmedName);

      // 显示成功提示后跳转
      this.showToastMessage('配方保存成功');

      // 延迟跳转，让用户看到提示
      setTimeout(() => {
        router.replaceUrl({
          url: 'pages/RecipeBrowserPage'
        });
      }, 800);

    } catch (error) {
      console.error('保存配方失败:', error);
      this.showToastMessage('保存失败，请重试');
      this.isSaving = false;
    }
  }

  // 显示 Toast 提示
  private showToastMessage(message: string): void {
    this.toastMessage = message;
    this.showToast = true;

    // 2秒后自动隐藏
    setTimeout(() => {
      this.showToast = false;
    }, 2000);
  }
}
