/**
 * 饵知道 - 原料新增页面
 * 用户自定义添加饵料原料
 */
import { router } from '@kit.ArkUI';
import { ThemeColors } from '../theme/ThemeColors';
import { ThemeConstants } from '../theme/ThemeConstants';
import { userDataService } from '../services/UserDataService';

// 原料分类类
class IngredientCategory {
  id: string = '';
  name: string = '';
  icon: string = '';
}

// 创建分类辅助函数
function makeCategory(id: string, name: string, icon: string): IngredientCategory {
  const cat = new IngredientCategory();
  cat.id = id;
  cat.name = name;
  cat.icon = icon;
  return cat;
}

@Entry
@Component
struct IngredientAddPage {
  @State ingredientName: string = '';
  @State selectedCategory: string = 'base';
  @State description: string = '';
  @State targetFish: string = '';
  @State usage: string = '';

  private categories: IngredientCategory[] = [
    makeCategory('base', '基础饵', '🌾'),
    makeCategory('protein', '蛋白饵', '🦐'),
    makeCategory('additive', '添加剂', '💧'),
    makeCategory('state', '状态饵', '🧊'),
    makeCategory('binder', '粘合剂', '🍯'),
    makeCategory('natural', '天然饵', '🌿'),
    makeCategory('pellet', '颗粒饵', '⚪'),
    makeCategory('live', '活饵', '🪱'),
    makeCategory('folk', '民间偏方', '🧪')
  ];

  build() {
    Column() {
      // 顶部导航栏
      this.NavBar()

      // 表单内容
      Scroll() {
        Column({ space: 20 }) {
          // 原料名称
          this.NameSection()

          // 原料分类
          this.CategorySection()

          // 原料描述
          this.DescriptionSection()

          // 适用鱼种
          this.TargetFishSection()

          // 使用方法
          this.UsageSection()

          // 保存按钮
          Button('保存原料')
            .width('100%')
            .height(48)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .backgroundColor(ThemeColors.PRIMARY)
            .fontColor(ThemeColors.TEXT_PRIMARY)
            .margin({ top: 16, bottom: 32 })
            .onClick(() => this.saveIngredient())
        }
        .padding(16)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
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
    .backgroundColor(ThemeColors.BG_SECONDARY)
  }

  @Builder
  NameSection() {
    Column({ space: 8 }) {
      Text('原料名称 *')
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .fontWeight(FontWeight.Medium)

      TextInput({ placeholder: '请输入原料名称', text: this.ingredientName })
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

      this.CategorySelector()
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  DescriptionSection() {
    Column({ space: 8 }) {
      Text('原料描述')
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .fontWeight(FontWeight.Medium)

      TextArea({ placeholder: '描述原料的特点、来源等', text: this.description })
        .width('100%')
        .height(100)
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
  TargetFishSection() {
    Column({ space: 8 }) {
      Text('适用鱼种')
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .fontWeight(FontWeight.Medium)

      TextInput({ placeholder: '如：鲫鱼、鲤鱼（多个用顿号分隔）', text: this.targetFish })
        .width('100%')
        .height(48)
        .fontSize(ThemeConstants.FONT_SIZE_BASE)
        .backgroundColor(ThemeColors.BG_CARD)
        .borderRadius(ThemeConstants.RADIUS_SM)
        .padding({ left: 12, right: 12 })
        .onChange((value: string) => {
          this.targetFish = value;
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  UsageSection() {
    Column({ space: 8 }) {
      Text('使用方法')
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .fontWeight(FontWeight.Medium)

      TextArea({ placeholder: '描述如何使用这种原料', text: this.usage })
        .width('100%')
        .height(80)
        .fontSize(ThemeConstants.FONT_SIZE_BASE)
        .backgroundColor(ThemeColors.BG_CARD)
        .borderRadius(ThemeConstants.RADIUS_SM)
        .padding(12)
        .onChange((value: string) => {
          this.usage = value;
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  CategorySelector() {
    Column({ space: 8 }) {
      // 第一行 3个
      Row({ space: 8 }) {
        ForEach(this.categories.slice(0, 3), (cat: IngredientCategory) => {
          this.CategoryItem(cat)
        })
      }
      .width('100%')

      // 第二行 3个
      Row({ space: 8 }) {
        ForEach(this.categories.slice(3, 6), (cat: IngredientCategory) => {
          this.CategoryItem(cat)
        })
      }
      .width('100%')

      // 第三行 3个
      Row({ space: 8 }) {
        ForEach(this.categories.slice(6, 9), (cat: IngredientCategory) => {
          this.CategoryItem(cat)
        })
      }
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  CategoryItem(cat: IngredientCategory) {
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
    })
  }

  private async saveIngredient(): Promise<void> {
    if (!this.ingredientName.trim()) {
      console.info('请输入原料名称');
      return;
    }

    // 解析目标鱼种
    const fishList: string[] = [];
    const parts = this.targetFish.split(/[、,，]/);
    for (let i = 0; i < parts.length; i++) {
      const s = parts[i].trim();
      if (s.length > 0) {
        fishList.push(s);
      }
    }

    // 保存到 UserDataService
    await userDataService.addIngredient(
      this.ingredientName.trim(),
      this.selectedCategory,
      this.description.trim(),
      fishList,
      this.usage.trim()
    );

    console.info('原料保存成功:', this.ingredientName);
    router.back();
  }
}
