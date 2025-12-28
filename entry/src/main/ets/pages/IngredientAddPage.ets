/**
 * 饵知�?- 原料新增页面
 * 用户自定义添加饵料原�?
 */
import { router } from '@kit.ArkUI';
import { ThemeColors } from '../theme/ThemeColors';
import { ThemeConstants } from '../theme/ThemeConstants';
import { userDataService, CustomFish } from '../services/UserDataService';
import { ALL_FISH_DATA, FishData } from '../data/FishData';

// 原料分类�?
class IngredientCategoryItem {
  id: string = '';
  name: string = '';
  icon: string = '';
}

// 子分类类
class SubCategoryItem {
  id: string = '';
  name: string = '';
}

// 季节选项
class SeasonItem {
  id: string = '';
  name: string = '';
}

// 创建分类辅助函数
function makeCategory(id: string, name: string, icon: string): IngredientCategoryItem {
  const cat = new IngredientCategoryItem();
  cat.id = id;
  cat.name = name;
  cat.icon = icon;
  return cat;
}

function makeSubCategory(id: string, name: string): SubCategoryItem {
  const sub = new SubCategoryItem();
  sub.id = id;
  sub.name = name;
  return sub;
}

function makeSeason(id: string, name: string): SeasonItem {
  const s = new SeasonItem();
  s.id = id;
  s.name = name;
  return s;
}

// 扩展数据�?
class PhysicalData {
  atomization: number = 5;
  viscosity: number = 5;
  weight: number = 5;
}

class DosageData {
  min: number = 10;
  max: number = 50;
  unit: string = 'g';
}

class ExtendedIngredientData {
  subCategory: string = '';
  seasons: string[] = [];
  physical: PhysicalData = new PhysicalData();
  dosage: DosageData = new DosageData();
}

@Entry
@Component
struct IngredientAddPage {
  // 基本信息
  @State ingredientName: string = '';
  @State selectedCategory: string = 'base';
  @State selectedSubCategory: string = 'grain';
  @State description: string = '';

  // 适用信息
  @State selectedFishIds: string[] = [];
  @State selectedSeasons: string[] = ['spring', 'summer', 'autumn', 'winter'];

  // 物理特�?
  @State atomization: number = 5;
  @State viscosity: number = 5;
  @State weight: number = 5;

  // 用量范围
  @State dosageMin: number = 10;
  @State dosageMax: number = 50;
  @State dosageUnit: string = 'g';

  // 弹窗状�?
  @State showFishPicker: boolean = false;
  @State showToast: boolean = false;
  @State toastMessage: string = '';
  @State isSaving: boolean = false;

  private categories: IngredientCategoryItem[] = [
    makeCategory('base', '基础�?, '🌾'),
    makeCategory('protein', '蛋白�?, '🦐'),
    makeCategory('additive', '添加�?, '💧'),
    makeCategory('state', '状态饵', '🧊'),
    makeCategory('binder', '粘合�?, '🍯'),
    makeCategory('natural', '天然�?, '🌿'),
    makeCategory('pellet', '颗粒�?, '�?),
    makeCategory('live', '活饵', '🪱'),
    makeCategory('folk', '民间偏方', '🧪')
  ];

  private subCategories: Record<string, SubCategoryItem[]> = {
    'base': [makeSubCategory('grain', '谷物'), makeSubCategory('tuber', '薯类'), makeSubCategory('bean', '豆类')],
    'protein': [makeSubCategory('aquatic', '水产'), makeSubCategory('insect', '昆虫'), makeSubCategory('animal', '动物')],
    'additive': [makeSubCategory('essence', '香精'), makeSubCategory('attractant', '诱食�?), makeSubCategory('acid', '酸类'), makeSubCategory('condiment', '调味�?), makeSubCategory('oil', '油类')],
    'state': [makeSubCategory('atomizer', '雾化�?), makeSubCategory('weight', '增重�?)],
    'binder': [makeSubCategory('grain', '谷物淀�?), makeSubCategory('tuber', '薯类淀�?)],
    'natural': [makeSubCategory('plant', '植物'), makeSubCategory('seed', '种子')],
    'pellet': [makeSubCategory('other', '颗粒')],
    'live': [makeSubCategory('worm', '蠕虫'), makeSubCategory('baitfish', '饵鱼')],
    'folk': [makeSubCategory('medicine', '药材'), makeSubCategory('beverage', '饮品'), makeSubCategory('fermented', '发酵�?), makeSubCategory('other', '其他')]
  };

  private seasons: SeasonItem[] = [
    makeSeason('spring', '春季'),
    makeSeason('summer', '夏季'),
    makeSeason('autumn', '秋季'),
    makeSeason('winter', '冬季')
  ];

  async aboutToAppear(): Promise<void> {
    await userDataService.load();
  }

  build() {
    Column() {
      this.NavBar()

      Scroll() {
        Column({ space: 16 }) {
          // 原料名称
          this.NameSection()

          // 原料分类
          this.CategorySection()

          // 子分�?
          this.SubCategorySection()

          // 适用鱼种
          this.TargetFishSection()

          // 适用季节
          this.SeasonSection()

          // 物理特�?
          this.PhysicalSection()

          // 用量范围
          this.DosageSection()

          // 原料描述/备注
          this.DescriptionSection()

          // 保存按钮
          Button('保存原料')
            .width('100%')
            .height(48)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .backgroundColor(this.isSaving ? ThemeColors.TEXT_MUTED : ThemeColors.PRIMARY)
            .fontColor(ThemeColors.TEXT_PRIMARY)
            .margin({ top: 16, bottom: 32 })
            .enabled(!this.isSaving)
            .onClick(() => this.saveIngredient())
        }
        .padding(16)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      // 鱼种选择弹窗
      if (this.showFishPicker) {
        this.FishPickerDialog()
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
      Text('�?)
        .fontSize(24)
        .fontColor(ThemeColors.TEXT_PRIMARY)
        .onClick(() => router.back())
        .padding(8)

      Text('添加原料')
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
  NameSection() {
    Column({ space: 8 }) {
      Text('原料名称 *')
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .fontWeight(FontWeight.Medium)

      TextInput({ placeholder: '请输入原料名�?, text: this.ingredientName })
        .width('100%')
        .height(48)
        .fontSize(ThemeConstants.FONT_SIZE_BASE)
        .backgroundColor(ThemeColors.BG_CARD)
        .borderRadius(ThemeConstants.RADIUS_SM)
        .padding({ left: 12, right: 12 })
        .onChange((value: string) => {
          this.ingredientName = value;
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  CategorySection() {
    Column({ space: 8 }) {
      Text('原料分类 *')
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .fontWeight(FontWeight.Medium)

      Column({ space: 8 }) {
        Row({ space: 8 }) {
          ForEach(this.categories.slice(0, 3), (cat: IngredientCategoryItem) => {
            this.CategoryItem(cat)
          })
        }
        .width('100%')

        Row({ space: 8 }) {
          ForEach(this.categories.slice(3, 6), (cat: IngredientCategoryItem) => {
            this.CategoryItem(cat)
          })
        }
        .width('100%')

        Row({ space: 8 }) {
          ForEach(this.categories.slice(6, 9), (cat: IngredientCategoryItem) => {
            this.CategoryItem(cat)
          })
        }
        .width('100%')
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  CategoryItem(cat: IngredientCategoryItem) {
    Column({ space: 4 }) {
      Text(cat.icon)
        .fontSize(24)

      Text(cat.name)
        .fontSize(ThemeConstants.FONT_SIZE_XS)
        .fontColor(this.selectedCategory === cat.id ? ThemeColors.PRIMARY : ThemeColors.TEXT_SECONDARY)
    }
    .layoutWeight(1)
    .padding({ top: 12, bottom: 12 })
    .backgroundColor(this.selectedCategory === cat.id ? 'rgba(232, 168, 73, 0.15)' : ThemeColors.BG_CARD)
    .borderRadius(ThemeConstants.RADIUS_SM)
    .border({
      width: 1,
      color: this.selectedCategory === cat.id ? ThemeColors.PRIMARY : Color.Transparent
    })
    .onClick(() => {
      this.selectedCategory = cat.id;
      // 重置子分�?
      const subs = this.subCategories[cat.id];
      if (subs && subs.length > 0) {
        this.selectedSubCategory = subs[0].id;
      }
    })
  }

  // 获取当前分类的子分类
  private getCurrentSubCategories(): SubCategoryItem[] {
    return this.subCategories[this.selectedCategory] || [];
  }

  @Builder
  SubCategorySection() {
    Column({ space: 8 }) {
      Text('子分�?)
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .fontWeight(FontWeight.Medium)

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.getCurrentSubCategories(), (sub: SubCategoryItem) => {
          Text(sub.name)
            .fontSize(ThemeConstants.FONT_SIZE_SM)
            .fontColor(this.selectedSubCategory === sub.id ? ThemeColors.PRIMARY : ThemeColors.TEXT_SECONDARY)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .margin({ right: 8, bottom: 8 })
            .backgroundColor(this.selectedSubCategory === sub.id ? 'rgba(232, 168, 73, 0.15)' : ThemeColors.BG_CARD)
            .borderRadius(ThemeConstants.RADIUS_FULL)
            .border({
              width: 1,
              color: this.selectedSubCategory === sub.id ? ThemeColors.PRIMARY : Color.Transparent
            })
            .onClick(() => {
              this.selectedSubCategory = sub.id;
            })
        })
      }
      .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  TargetFishSection() {
    Column({ space: 8 }) {
      Text('适用鱼种 *')
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .fontWeight(FontWeight.Medium)

      Row() {
        if (this.selectedFishIds.length === 0) {
          Text('点击选择适用鱼种')
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
      .height(48)
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
  SeasonSection() {
    Column({ space: 8 }) {
      Text('适用季节')
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .fontWeight(FontWeight.Medium)

      Row({ space: 8 }) {
        ForEach(this.seasons, (season: SeasonItem) => {
          Text(season.name)
            .fontSize(ThemeConstants.FONT_SIZE_SM)
            .fontColor(this.selectedSeasons.includes(season.id) ? ThemeColors.PRIMARY : ThemeColors.TEXT_SECONDARY)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .backgroundColor(this.selectedSeasons.includes(season.id) ? 'rgba(232, 168, 73, 0.15)' : ThemeColors.BG_CARD)
            .borderRadius(ThemeConstants.RADIUS_FULL)
            .border({
              width: 1,
              color: this.selectedSeasons.includes(season.id) ? ThemeColors.PRIMARY : Color.Transparent
            })
            .onClick(() => {
              if (this.selectedSeasons.includes(season.id)) {
                // 至少保留一个季�?
                if (this.selectedSeasons.length > 1) {
                  const idx = this.selectedSeasons.indexOf(season.id);
                  this.selectedSeasons.splice(idx, 1);
                  this.selectedSeasons = this.selectedSeasons.slice();
                }
              } else {
                this.selectedSeasons.push(season.id);
                this.selectedSeasons = this.selectedSeasons.slice();
              }
            })
        })
      }
      .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  PhysicalSection() {
    Column({ space: 12 }) {
      Text('物理特�?)
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .fontWeight(FontWeight.Medium)

      // 雾化�?
      Column({ space: 4 }) {
        Row() {
          Text('雾化�?)
            .fontSize(ThemeConstants.FONT_SIZE_SM)
            .fontColor(ThemeColors.TEXT_PRIMARY)
          Blank()
          Text(this.getPhysicalLabel(this.atomization))
            .fontSize(ThemeConstants.FONT_SIZE_SM)
            .fontColor(ThemeColors.PRIMARY_DARK)
        }
        .width('100%')

        Slider({ value: this.atomization, min: 1, max: 10, step: 1, style: SliderStyle.OutSet })
          .width('100%')
          .blockColor(ThemeColors.PRIMARY)
          .trackColor(ThemeColors.BG_TERTIARY)
          .selectedColor(ThemeColors.PRIMARY)
          .onChange((value: number) => { this.atomization = Math.round(value); })
      }
      .width('100%')

      // 粘度
      Column({ space: 4 }) {
        Row() {
          Text('粘度')
            .fontSize(ThemeConstants.FONT_SIZE_SM)
            .fontColor(ThemeColors.TEXT_PRIMARY)
          Blank()
          Text(this.getPhysicalLabel(this.viscosity))
            .fontSize(ThemeConstants.FONT_SIZE_SM)
            .fontColor(ThemeColors.PRIMARY_DARK)
        }
        .width('100%')

        Slider({ value: this.viscosity, min: 1, max: 10, step: 1, style: SliderStyle.OutSet })
          .width('100%')
          .blockColor(ThemeColors.PRIMARY)
          .trackColor(ThemeColors.BG_TERTIARY)
          .selectedColor(ThemeColors.PRIMARY)
          .onChange((value: number) => { this.viscosity = Math.round(value); })
      }
      .width('100%')

      // 比重
      Column({ space: 4 }) {
        Row() {
          Text('比重')
            .fontSize(ThemeConstants.FONT_SIZE_SM)
            .fontColor(ThemeColors.TEXT_PRIMARY)
          Blank()
          Text(this.getPhysicalLabel(this.weight))
            .fontSize(ThemeConstants.FONT_SIZE_SM)
            .fontColor(ThemeColors.PRIMARY_DARK)
        }
        .width('100%')

        Slider({ value: this.weight, min: 1, max: 10, step: 1, style: SliderStyle.OutSet })
          .width('100%')
          .blockColor(ThemeColors.PRIMARY)
          .trackColor(ThemeColors.BG_TERTIARY)
          .selectedColor(ThemeColors.PRIMARY)
          .onChange((value: number) => { this.weight = Math.round(value); })
      }
      .width('100%')
    }
    .width('100%')
    .padding(12)
    .backgroundColor(ThemeColors.BG_CARD)
    .borderRadius(ThemeConstants.RADIUS_SM)
    .alignItems(HorizontalAlign.Start)
  }

  private getPhysicalLabel(value: number): string {
    if (value <= 2) return '很低';
    if (value <= 4) return '较低';
    if (value <= 6) return '中等';
    if (value <= 8) return '较高';
    return '很高';
  }

  @Builder
  DosageSection() {
    Column({ space: 8 }) {
      Text('建议用量')
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .fontWeight(FontWeight.Medium)

      Row({ space: 8 }) {
        TextInput({ placeholder: '最�?, text: this.dosageMin.toString() })
          .width(80)
          .height(40)
          .fontSize(ThemeConstants.FONT_SIZE_SM)
          .backgroundColor(ThemeColors.BG_CARD)
          .borderRadius(ThemeConstants.RADIUS_SM)
          .textAlign(TextAlign.Center)
          .type(InputType.Number)
          .onChange((value: string) => {
            const num = parseInt(value);
            if (!isNaN(num) && num >= 0) this.dosageMin = num;
          })

        Text('~')
          .fontSize(ThemeConstants.FONT_SIZE_BASE)
          .fontColor(ThemeColors.TEXT_SECONDARY)

        TextInput({ placeholder: '最�?, text: this.dosageMax.toString() })
          .width(80)
          .height(40)
          .fontSize(ThemeConstants.FONT_SIZE_SM)
          .backgroundColor(ThemeColors.BG_CARD)
          .borderRadius(ThemeConstants.RADIUS_SM)
          .textAlign(TextAlign.Center)
          .type(InputType.Number)
          .onChange((value: string) => {
            const num = parseInt(value);
            if (!isNaN(num) && num >= 0) this.dosageMax = num;
          })

        Text('�?)
          .fontSize(ThemeConstants.FONT_SIZE_BASE)
          .fontColor(ThemeColors.TEXT_SECONDARY)
      }
      .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  DescriptionSection() {
    Column({ space: 8 }) {
      Text('备注说明')
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .fontWeight(FontWeight.Medium)

      TextArea({ placeholder: '描述原料的特点、使用技巧等', text: this.description })
        .width('100%')
        .height(80)
        .fontSize(ThemeConstants.FONT_SIZE_BASE)
        .backgroundColor(ThemeColors.BG_CARD)
        .borderRadius(ThemeConstants.RADIUS_SM)
        .padding(12)
        .onChange((value: string) => {
          this.description = value;
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  FishPickerDialog() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.5)')
        .onClick(() => { this.showFishPicker = false; })

      Column() {
        Row() {
          Text('选择适用鱼种')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.TEXT_PRIMARY)
          Blank()
          Text('完成')
            .fontSize(16)
            .fontColor(ThemeColors.PRIMARY_DARK)
            .onClick(() => { this.showFishPicker = false; })
        }
        .width('100%')
        .padding({ bottom: 12 })

        Scroll() {
          Column({ space: 8 }) {
            // 系统鱼种
            ForEach(ALL_FISH_DATA, (fish: FishData) => {
              Row() {
                Image(fish.icon)
                  .width(32)
                  .height(32)
                  .borderRadius(16)
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
                      if (idx > -1) this.selectedFishIds.splice(idx, 1);
                    }
                    this.selectedFishIds = this.selectedFishIds.slice();
                  })
              }
              .width('100%')
              .padding(10)
              .backgroundColor(ThemeColors.BG_TERTIARY)
              .borderRadius(8)
            })

            // 用户自定义鱼�?
            ForEach(userDataService.getCustomFish(), (fish: CustomFish) => {
              Row() {
                Image(fish.icon || $r('app.media.fishImage'))
                  .width(32)
                  .height(32)
                  .borderRadius(16)
                  .margin({ right: 12 })

                Row({ space: 4 }) {
                  Text(fish.name)
                    .fontSize(16)
                    .fontColor(ThemeColors.TEXT_PRIMARY)

                  Text('自定�?)
                    .fontSize(10)
                    .fontColor(ThemeColors.PRIMARY_DARK)
                    .padding({ left: 4, right: 4, top: 2, bottom: 2 })
                    .backgroundColor('rgba(232, 168, 73, 0.15)')
                    .borderRadius(4)
                }
                .layoutWeight(1)

                Checkbox()
                  .select(this.selectedFishIds.includes(fish.id))
                  .selectedColor(ThemeColors.PRIMARY)
                  .onChange((checked: boolean) => {
                    if (checked) {
                      this.selectedFishIds.push(fish.id);
                    } else {
                      const idx = this.selectedFishIds.indexOf(fish.id);
                      if (idx > -1) this.selectedFishIds.splice(idx, 1);
                    }
                    this.selectedFishIds = this.selectedFishIds.slice();
                  })
              }
              .width('100%')
              .padding(10)
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
        // 先从系统鱼种查找
        const fish = ALL_FISH_DATA.find((f: FishData) => f.id === id);
        if (fish) {
          return fish.name;
        }
        // 再从用户自定义鱼种查�?
        const customFish = userDataService.getCustomFish().find((f: CustomFish) => f.id === id);
        if (customFish) {
          return customFish.name;
        }
        return '';
      })
      .filter((name: string) => name !== '')
      .join('�?);
  }

  private showToastMessage(message: string): void {
    this.toastMessage = message;
    this.showToast = true;
    setTimeout(() => { this.showToast = false; }, 2000);
  }


  private async saveIngredient(): Promise<void> {
    if (this.isSaving) return;

    // 验证名称
    const trimmedName = this.ingredientName.trim();
    if (!trimmedName) {
      this.showToastMessage('请输入原料名�?);
      return;
    }

    if (trimmedName.length < 2) {
      this.showToastMessage('原料名称至少2个字�?);
      return;
    }

    if (trimmedName.length > 20) {
      this.showToastMessage('原料名称不能超过20个字�?);
      return;
    }

    // 验证鱼种
    if (this.selectedFishIds.length === 0) {
      this.showToastMessage('请选择适用鱼种');
      return;
    }

    // 验证用量
    if (this.dosageMin > this.dosageMax) {
      this.showToastMessage('最小用量不能大于最大用�?);
      return;
    }

    this.isSaving = true;

    try {
      // 构建扩展数据
      const physical = new PhysicalData();
      physical.atomization = this.atomization;
      physical.viscosity = this.viscosity;
      physical.weight = this.weight;

      const dosage = new DosageData();
      dosage.min = this.dosageMin;
      dosage.max = this.dosageMax;
      dosage.unit = this.dosageUnit;

      const extData = new ExtendedIngredientData();
      extData.subCategory = this.selectedSubCategory;
      extData.seasons = this.selectedSeasons.slice();
      extData.physical = physical;
      extData.dosage = dosage;

      const extendedData: string = JSON.stringify(extData);

      // 保存�?UserDataService
      await userDataService.addIngredient(
        trimmedName,
        this.selectedCategory,
        this.description.trim(),
        this.selectedFishIds.slice(),
        extendedData  // 将扩展数据存�?usage 字段
      );

      this.showToastMessage('原料保存成功');

      setTimeout(() => {
        router.back();
      }, 800);

    } catch (error) {
      console.error('保存原料失败:', error);
      this.showToastMessage('保存失败，请重试');
      this.isSaving = false;
    }
  }
}
