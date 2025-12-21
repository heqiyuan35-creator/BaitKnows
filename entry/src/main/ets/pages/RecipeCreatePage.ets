/**
 * 饵知道 - 配方创作页面
 * 用户自定义创建鱼饵配方
 */
import { router } from '@kit.ArkUI';
import { ThemeColors } from '../theme/ThemeColors';
import { ThemeConstants } from '../theme/ThemeConstants';
import { ALL_FISH_DATA, FishData } from '../data/FishData';
import { ALL_INGREDIENTS, Ingredient } from '../data/IngredientDatabase';
import { userDataService, CustomRecipeIngredient } from '../services/UserDataService';

// 配方原料项
interface RecipeIngredientItem {
  ingredientId: string;
  name: string;
  ratio: number;  // 比例 1-10
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

  private waterTypes: Array<{ id: string; name: string }> = [
    { id: 'pond', name: '池塘' },
    { id: 'river', name: '河流' },
    { id: 'reservoir', name: '水库' },
    { id: 'lake', name: '湖泊' }
  ];

  private seasons: Array<{ id: string; name: string }> = [
    { id: 'spring', name: '春季' },
    { id: 'summer', name: '夏季' },
    { id: 'autumn', name: '秋季' },
    { id: 'winter', name: '冬季' }
  ];

  build() {
    Column() {
      // 顶部导航栏
      this.NavBar()

      // 表单内容
      Scroll() {
        Column({ space: 16 }) {
          // 配方名称
          this.FormSection('配方名称', () => {
            this.InputField()
          })

          // 目标鱼种
          this.FormSection('目标鱼种', () => {
            this.FishSelector()
          })

          // 适合水域
          this.FormSection('适合水域', () => {
            this.WaterTypeSelector()
          })

          // 适合季节
          this.FormSection('适合季节', () => {
            this.SeasonSelector()
          })

          // 原料配比
          this.FormSection('原料配比', () => {
            this.IngredientList()
          })

          // 制作步骤
          this.FormSection('制作步骤', () => {
            this.StepsList()
          })

          // 使用技巧
          this.FormSection('使用技巧', () => {
            this.TipsInput()
          })

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
    .backgroundColor(ThemeColors.BG_SECONDARY)
  }

  @Builder
  FormSection(title: string, content: () => void) {
    Column({ space: 8 }) {
      Text(title)
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .fontWeight(FontWeight.Medium)

      content()
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  InputField() {
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

  @Builder
  FishSelector() {
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

  @Builder
  WaterTypeSelector() {
    Row({ space: 8 }) {
      ForEach(this.waterTypes, (item: { id: string; name: string }) => {
        Text(item.name)
          .fontSize(ThemeConstants.FONT_SIZE_SM)
          .fontColor(this.selectedWaterType === item.id ? ThemeColors.PRIMARY : ThemeColors.TEXT_SECONDARY)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .backgroundColor(this.selectedWaterType === item.id ? 'rgba(232, 168, 73, 0.15)' : ThemeColors.BG_CARD)
          .borderRadius(ThemeConstants.RADIUS_FULL)
          .border({
            width: 1,
            color: this.selectedWaterType === item.id ? ThemeColors.PRIMARY : Color.Transparent
          })
          .onClick(() => {
            this.selectedWaterType = item.id;
          })
      })
    }
    .width('100%')
  }

  @Builder
  SeasonSelector() {
    Row({ space: 8 }) {
      ForEach(this.seasons, (item: { id: string; name: string }) => {
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

  @Builder
  IngredientList() {
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
              this.ingredients = [...this.ingredients];
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

  @Builder
  StepsList() {
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
                this.steps = [...this.steps];
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
        this.steps = [...this.steps];
      })
    }
    .width('100%')
  }

  @Builder
  TipsInput() {
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
            ForEach(ALL_FISH_DATA, (fish: FishData) => {
              Row() {
                Image(fish.icon)
                  .width(36)
                  .height(36)
                  .borderRadius(18)
                  .margin({ right: 12 })

                Text(fish.name)
                  .fontSize(16)
                  .fontColor(ThemeColors.TEXT_PRIMARY)
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
                    this.selectedFishIds = [...this.selectedFishIds];
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
            ForEach(ALL_INGREDIENTS.slice(0, 30), (ing: Ingredient) => {
              Row() {
                Text(ing.name)
                  .fontSize(16)
                  .fontColor(ThemeColors.TEXT_PRIMARY)
                  .layoutWeight(1)

                Text('+')
                  .fontSize(20)
                  .fontColor(ThemeColors.PRIMARY)
                  .onClick(() => {
                    const newItem: RecipeIngredientItem = {
                      ingredientId: ing.id,
                      name: ing.name,
                      ratio: 1
                    };
                    this.ingredients.push(newItem);
                    this.ingredients = [...this.ingredients];
                    this.showIngredientPicker = false;
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

  private getSelectedFishNames(): string {
    return this.selectedFishIds
      .map((id: string) => {
        const fish = ALL_FISH_DATA.find((f: FishData) => f.id === id);
        return fish ? fish.name : '';
      })
      .filter((name: string) => name !== '')
      .join('、');
  }

  private async saveRecipe(): Promise<void> {
    if (!this.recipeName.trim()) {
      console.info('请输入配方名称');
      return;
    }
    if (this.selectedFishIds.length === 0) {
      console.info('请选择目标鱼种');
      return;
    }
    if (this.ingredients.length === 0) {
      console.info('请添加原料');
      return;
    }

    // 转换原料格式
    const recipeIngredients: CustomRecipeIngredient[] = this.ingredients.map((item: RecipeIngredientItem) => ({
      ingredientId: item.ingredientId,
      name: item.name,
      ratio: item.ratio
    }));

    // 过滤空步骤
    const validSteps = this.steps.filter((s: string) => s.trim().length > 0);

    // 保存到 UserDataService
    await userDataService.addRecipe({
      name: this.recipeName.trim(),
      targetFish: [...this.selectedFishIds],
      waterType: this.selectedWaterType,
      season: this.selectedSeason,
      ingredients: recipeIngredients,
      steps: validSteps,
      tips: this.tips.trim()
    });

    console.info('配方保存成功:', this.recipeName);
    router.back();
  }
}
