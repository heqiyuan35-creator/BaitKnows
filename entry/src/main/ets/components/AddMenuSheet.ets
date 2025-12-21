/**
 * 饵知道 - 加号菜单底部弹出组件
 * 提供四个功能入口：精确匹配、个人创作、原料新增、鱼类新增
 */
import { ThemeColors } from '../theme/ThemeColors';
import { ThemeConstants } from '../theme/ThemeConstants';

// 菜单项数据接口
export interface AddMenuItem {
  id: string;
  icon: string;
  title: string;
  description: string;
  route: string;
}

// 菜单项配置
export const ADD_MENU_ITEMS: AddMenuItem[] = [
  {
    id: 'precise_match',
    icon: '🎯',
    title: '精确匹配',
    description: '根据条件精准推荐',
    route: 'pages/SmartGeneratorPage'
  },
  {
    id: 'personal_creation',
    icon: '✏️',
    title: '个人创作',
    description: '创建自定义配方',
    route: 'pages/RecipeCreatePage'
  },
  {
    id: 'ingredient_add',
    icon: '🧪',
    title: '原料新增',
    description: '添加自定义原料',
    route: 'pages/IngredientAddPage'
  },
  {
    id: 'fish_add',
    icon: '🐟',
    title: '鱼类新增',
    description: '添加自定义鱼种',
    route: 'pages/FishAddPage'
  }
];

@Component
export struct AddMenuSheet {
  @Prop visible: boolean = false;
  onClose?: () => void;
  onItemClick?: (item: AddMenuItem) => void;

  @State private sheetOffset: number = 300;  // 初始偏移量（隐藏状态）

  aboutToAppear(): void {
    if (this.visible) {
      this.animateIn();
    }
  }

  // 监听visible变化
  onVisibleChange(): void {
    if (this.visible) {
      this.animateIn();
    } else {
      this.animateOut();
    }
  }

  // 滑入动画
  private animateIn(): void {
    animateTo({
      duration: 250,
      curve: Curve.EaseOut
    }, () => {
      this.sheetOffset = 0;
    });
  }

  // 滑出动画
  private animateOut(): void {
    animateTo({
      duration: 200,
      curve: Curve.EaseIn
    }, () => {
      this.sheetOffset = 300;
    });
  }

  // 处理遮罩点击
  private handleOverlayClick(): void {
    if (this.onClose) {
      this.onClose();
    }
  }

  // 处理菜单项点击
  private handleItemClick(item: AddMenuItem): void {
    if (this.onItemClick) {
      this.onItemClick(item);
    }
  }

  build() {
    if (this.visible) {
      Stack() {
        // 遮罩层
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor(ThemeColors.OVERLAY)
          .onClick(() => this.handleOverlayClick())
          .transition({ type: TransitionType.All, opacity: 0 })

        // 底部弹出卡片
        Column() {
          // 顶部拖拽指示条
          Row() {
            Column()
              .width(40)
              .height(4)
              .backgroundColor(ThemeColors.TEXT_HINT)
              .borderRadius(2)
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .padding({ top: 12, bottom: 8 })

          // 标题
          Text('快速操作')
            .fontSize(ThemeConstants.FONT_SIZE_LG)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.TEXT_PRIMARY)
            .margin({ bottom: 16 })

          // 2x2 网格布局
          Column({ space: 12 }) {
            // 第一行
            Row({ space: 12 }) {
              this.MenuItemCard(ADD_MENU_ITEMS[0])
              this.MenuItemCard(ADD_MENU_ITEMS[1])
            }
            .width('100%')

            // 第二行
            Row({ space: 12 }) {
              this.MenuItemCard(ADD_MENU_ITEMS[2])
              this.MenuItemCard(ADD_MENU_ITEMS[3])
            }
            .width('100%')
          }
          .width('100%')
          .padding({ left: 16, right: 16, bottom: 32 })
        }
        .width('100%')
        .backgroundColor(ThemeColors.BG_CARD)
        .borderRadius({ topLeft: 20, topRight: 20 })
        .position({ x: 0, y: '100%' })
        .translate({ y: -300 + this.sheetOffset })
        .gesture(
          PanGesture({ direction: PanDirection.Down })
            .onActionEnd(() => {
              if (this.onClose) {
                this.onClose();
              }
            })
        )
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
    }
  }

  @Builder
  MenuItemCard(item: AddMenuItem) {
    Column({ space: 8 }) {
      // 图标
      Text(item.icon)
        .fontSize(32)

      // 标题
      Text(item.title)
        .fontSize(ThemeConstants.FONT_SIZE_BASE)
        .fontWeight(FontWeight.Medium)
        .fontColor(ThemeColors.TEXT_PRIMARY)

      // 描述
      Text(item.description)
        .fontSize(ThemeConstants.FONT_SIZE_XS)
        .fontColor(ThemeColors.TEXT_SECONDARY)
    }
    .layoutWeight(1)
    .padding(16)
    .backgroundColor(ThemeColors.BG_TERTIARY)
    .borderRadius(ThemeConstants.RADIUS_MD)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => this.handleItemClick(item))
  }
}
