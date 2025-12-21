# Design Document: 加号菜单重设计

## Overview

重新设计底部Tab栏中间的加号(+)按钮功能，将原来直接进入智能配方生成页面改为弹出一个功能菜单，提供四个入口：精确匹配、个人创作、原料新增、鱼类新增。采用底部弹出卡片(Bottom Sheet)样式，配合动画效果提升用户体验。

## Architecture

```
┌─────────────────────────────────────────┐
│              WelcomePage                │
│  ┌───────────────────────────────────┐  │
│  │           MainContent             │  │
│  │  (HomePage/RecipeBrowser/etc.)    │  │
│  │                                   │  │
│  │                                   │  │
│  └───────────────────────────────────┘  │
│  ┌───────────────────────────────────┐  │
│  │    AddMenuSheet (Overlay)         │  │
│  │  ┌─────────┐  ┌─────────┐        │  │
│  │  │精确匹配 │  │个人创作 │        │  │
│  │  └─────────┘  └─────────┘        │  │
│  │  ┌─────────┐  ┌─────────┐        │  │
│  │  │原料新增 │  │鱼类新增 │        │  │
│  │  └─────────┘  └─────────┘        │  │
│  └───────────────────────────────────┘  │
│  ┌───────────────────────────────────┐  │
│  │         Bottom Tab Bar            │  │
│  │  首页  配方  [+]  记录  我的      │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

## Components and Interfaces

### 1. AddMenuSheet 组件

底部弹出菜单组件，负责显示四个功能入口。

```typescript
// 菜单项数据接口
interface AddMenuItem {
  id: string;           // 唯一标识
  icon: string;         // 图标（emoji或Resource）
  title: string;        // 标题
  description: string;  // 描述
  route: string;        // 跳转路由
}

// 组件属性
interface AddMenuSheetProps {
  visible: boolean;                    // 是否显示
  onClose: () => void;                 // 关闭回调
  onItemClick: (item: AddMenuItem) => void;  // 点击项回调
}
```

### 2. 菜单项配置

```typescript
const ADD_MENU_ITEMS: AddMenuItem[] = [
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
```

### 3. WelcomePage 修改

在 WelcomePage 中添加菜单状态管理和显示逻辑：

```typescript
@State showAddMenu: boolean = false;

// 点击加号按钮
onAddButtonClick(): void {
  this.showAddMenu = true;
}

// 关闭菜单
closeAddMenu(): void {
  this.showAddMenu = false;
}

// 处理菜单项点击
onMenuItemClick(item: AddMenuItem): void {
  this.showAddMenu = false;
  router.pushUrl({ url: item.route });
}
```

## Data Models

### 用户自定义原料数据模型

```typescript
interface CustomIngredient {
  id: string;              // 唯一ID（user_ing_xxx）
  name: string;            // 原料名称
  category: string;        // 分类
  description: string;     // 描述
  createdAt: number;       // 创建时间
  userId: string;          // 用户ID
}
```

### 用户自定义鱼种数据模型

```typescript
interface CustomFish {
  id: string;              // 唯一ID（user_fish_xxx）
  name: string;            // 鱼种名称
  nameEn: string;          // 英文名
  waterTypes: string[];    // 适合水域
  feedingType: string;     // 食性
  description: string;     // 描述
  createdAt: number;       // 创建时间
  userId: string;          // 用户ID
}
```

### 用户自定义配方数据模型

```typescript
interface CustomRecipe {
  id: string;              // 唯一ID（user_recipe_xxx）
  name: string;            // 配方名称
  targetFish: string[];    // 目标鱼种
  waterType: string;       // 适合水域
  season: string;          // 适合季节
  ingredients: RecipeIngredient[];  // 原料列表
  steps: string[];         // 制作步骤
  tips: string;            // 使用技巧
  createdAt: number;       // 创建时间
  userId: string;          // 用户ID
}
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

由于本功能主要是UI交互，大部分需求是UI样式和导航相关的example测试，没有适合property-based testing的通用属性。主要通过单元测试和UI测试验证：

**Example Tests:**
1. 点击加号按钮后菜单可见性状态变为true
2. 点击遮罩层后菜单可见性状态变为false
3. 菜单包含4个功能入口
4. 每个入口包含正确的标题和描述
5. 点击各入口后正确跳转到对应页面

## Error Handling

| 场景 | 处理方式 |
|------|----------|
| 路由跳转失败 | 捕获异常，显示Toast提示"页面跳转失败" |
| 页面不存在 | 跳转到404页面或显示错误提示 |
| 动画执行异常 | 降级为无动画直接显示/隐藏 |

## Testing Strategy

### 单元测试
- 测试菜单状态切换逻辑
- 测试菜单项配置数据完整性
- 测试路由跳转参数正确性

### UI测试
- 测试点击加号按钮显示菜单
- 测试点击遮罩关闭菜单
- 测试点击各功能入口跳转正确
- 测试菜单布局和样式符合设计

### 集成测试
- 测试从菜单跳转到各功能页面的完整流程
- 测试返回后菜单状态正确
