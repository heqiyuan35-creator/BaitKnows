/**
 * 饵知道 - 原料新增页面
 * 用户自定义添加饵料原料
 */
import { router } from '@kit.ArkUI';
import { ThemeColors } from '../theme/ThemeColors';
import { ThemeConstants } from '../theme/ThemeConstants';
import { userDataService } from '../services/UserDataService';

// 原料分类
interface IngredientCategory {
  id: string;
  name: string;
  icon: string;
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
    { id: 'base', name: '基础饵', icon: '🌾' },
    { id: 'protein', name: '蛋白饵', icon: '🦐' },
    { id: 'additive', name: '添加剂', icon: '💧' },
    { id: 'state', name: '状态饵', icon: '🧊' },
    { id: 'binder', name: '粘合剂', icon: '🍯' },
    { id: 'natural', name: '天然饵', icon: '🌿' },
    { id: 'pellet', name: '颗粒饵', icon: '⚪' },
    { id: 'live', name: '活饵', icon: '🪱' },
    { id: 'folk', name: '民间偏方', icon: '🧪' }
  ];

  build() {
    Column() {
      // 顶部导航栏
      this.NavBar()

      // 表单内容
      Scroll() {
        Column({ space: 20 }) {
          // 原料名称
          this.FormSection('原料名称 *', () => {
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
          })

          // 原料分类
          this.FormSection('原料分类 *', () => {
            this.CategorySelector()
          })

          // 原料描述
          this.FormSection('原料描述', () => {
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
          })

          // 适用鱼种
          this.FormSection('适用鱼种', () => {
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
          })

          // 使用方法
          this.FormSection('使用方法', () => {
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
          })

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
    const fishList = this.targetFish
      .split(/[、,，]/)
      .map((s: string) => s.trim())
      .filter((s: string) => s.length > 0);

    // 保存到 UserDataService
    await userDataService.addIngredient({
      name: this.ingredientName.trim(),
      category: this.selectedCategory,
      description: this.description.trim(),
      targetFish: fishList,
      usage: this.usage.trim()
    });

    console.info('原料保存成功:', this.ingredientName);
    router.back();
  }
}
