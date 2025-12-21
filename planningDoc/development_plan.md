# 饵知道 (BaitKnows) 开发计划

## 项目概述

**饵知道** 是一款面向钓鱼爱好者的单机应用，核心功能是智能生成鱼饵配方、记录渔获日记、浏览配方库。应用采用深色主题，橙色为主色调，营造专业钓鱼氛围。

---

## 一、页面结构

### 1.1 页面清单

| 页面 | 文件名 | 功能 |
|------|--------|------|
| 欢迎页 | WelcomePage.ets | 启动页，随机展示4张背景图，Logo+版本号 |
| 首页 | HomePage.ets | 天气卡片、智能配方生成、附近渔点 |
| 配方库 | RecipeBrowserPage.ets | 水域Tab、鱼种筛选、配方列表 |
| 配方详情 | RecipeDetailPage.ets | 配方信息、配料、步骤、收藏 |
| 渔获记录 | FishingRecordPage.ets | 统计数据、记录列表 |
| 添加记录 | AddRecordPage.ets | 新增渔获表单 |
| 我的 | MinePage.ets | 用户信息、等级、功能入口 |
| 生成配方 | GeneratedRecipePage.ets | AI生成结果展示 |
| 收藏 | FavoritePage.ets | 收藏的配方 |
| 设置 | SettingsPage.ets | 通用设置 |

### 1.2 导航结构

```
MainTabPage (底部5个Tab)
├── 首页 (HomePage)
├── 配方 (RecipeBrowserPage)  
├── + (悬浮按钮 → 生成配方/添加记录)
├── 日记 (FishingRecordPage)
└── 我的 (MinePage)
```

---

## 二、数据架构

### 2.1 存储方案

使用 **Preferences** 存储 JSON 数据（单机应用）

```typescript
StorageKeys = {
  USER_PROFILE: 'user_profile',
  FAVORITE_RECIPES: 'favorite_recipes',
  FISHING_RECORDS: 'fishing_records',
  GENERATOR_HISTORY: 'generator_history',
  WELCOME_BG_INDEX: 'welcome_bg_index',
}
```

### 2.2 核心数据模型

**用户信息**
```typescript
UserProfile {
  nickname: string      // 昵称
  level: number         // 等级
  levelTitle: string    // 等级称号
  totalCatch: number    // 总渔获
  bestRecord: number    // 最佳记录(kg)
  activeDays: number    // 活跃天数
}
```

**渔获记录**
```typescript
FishingRecord {
  id: string
  date: number
  location: string
  weather: string
  fishName: string
  weight: number
  count: number
  recipeId: string
  recipeName: string
  notes: string
}
```

**配方数据**
```typescript
BaitRecipe {
  id: string
  name: string
  targetFish: string[]
  waterType: string[]
  season: string[]
  difficulty: string
  catchRate: number
  ingredients: Ingredient[]
  steps: Step[]
  tips: string[]
}
```

---

## 三、素材资源

### 3.1 欢迎页背景 (随机轮换)
- Welcomebackground1.jpg
- Welcomebackground2.jpg
- Welcomebackground3.jpg
- Welcomebackground4.jpg

### 3.2 Tab图标
| Tab | 未选中 | 选中 |
|-----|--------|------|
| 首页 | home.png | homes.png |
| 配方 | Recipe.png | Recipes.png |
| 日记 | time.png | times.png |
| 我的 | mine.png | mines.png |

### 3.3 水域图标
| 水域 | 未选中 | 选中 |
|------|--------|------|
| 池塘 | Pond.png | Ponds.png |
| 河流 | River.png | Rivers.png |
| 水库 | Reservoir.png | Reservoirs.png |
| 湖泊 | Lake.png | Lakes.png |

### 3.4 季节图标
| 季节 | 未选中 | 选中 |
|------|--------|------|
| 春 | Spring.png | Springs.png |
| 夏 | Summer.png | Summers.png |
| 秋 | Autumn.png | Autumns.png |
| 冬 | Winter.png | Winters.png |

### 3.5 其他图标
- hook.png / hooks.png - 鱼钩
- Fish.png / Fishs.png - 鱼
- Twinkle.png / Twinkles.png - 推荐
- heartfill.png - 收藏
- Difficulty.png - 难度
- Temperature.png - 温度
- Left.png - 返回
- Option.png - 更多

---

## 四、开发阶段

### 第一阶段：基础框架 (2天)
- [x] 主题系统 (ThemeColors, ThemeConstants)
- [x] 欢迎页 (随机背景、Logo、加载动画)
- [x] MainTabPage 底部导航
- [x] 路由系统
- [x] 存储服务

### 第二阶段：首页 (2天)
- [x] 天气信息卡片
- [x] 智能配方生成入口
- [x] 目标鱼种选择
- [x] 水域类型选择
- [x] 一键生成按钮
- [ ] 附近渔点展示 (待接入地图API)

### 第三阶段：配方库 (2天)
- [x] 水域Tab切换
- [x] 鱼种筛选栏
- [x] 配方卡片列表
- [x] 配方详情页
- [x] 收藏功能

### 第四阶段：渔获记录 (2天)
- [x] 统计数据卡片
- [x] 记录列表
- [x] 添加记录表单
- [x] 记录详情/编辑

### 第五阶段：我的页面 (1天)
- [x] 用户信息卡片
- [x] 等级系统
- [x] 功能入口
- [x] 设置页面

### 第六阶段：智能生成 (2天)
- [x] 配方生成算法 (RecipeService)
- [x] 生成结果页面 (GeneratedRecipePage)
- [x] 智能生成页面 (GeneratorPage)
- [x] 生成历史

### 第七阶段：优化 (3天)
- [x] 动画效果 (欢迎页Logo动画)
- [x] 数据持久化测试
- [x] UI细节打磨

---

## 五、文件结构

```
entry/src/main/ets/
├── common/
│   ├── constants/AppConstants.ets
│   ├── types/
│   │   ├── BaitTypes.ets
│   │   ├── FishTypes.ets
│   │   ├── IngredientTypes.ets
│   │   ├── RecipeTypes.ets
│   │   └── UserTypes.ets
│   └── utils/Logger.ets
├── components/
│   ├── ConfirmDialog.ets
│   ├── EmptyState.ets
│   ├── LoadingView.ets
│   ├── RecipeCard.ets
│   ├── RecordCard.ets
│   ├── StatCard.ets
│   └── WeatherCard.ets
├── data/
│   ├── FishDatabase.ets
│   ├── FishingSpotData.ets
│   ├── IngredientDatabase.ets
│   ├── EnvironmentDatabase.ets
│   └── RecipeRules.ets
├── pages/
│   ├── WelcomePage.ets
│   ├── MainTabPage.ets
│   ├── HomePage.ets
│   ├── RecipeBrowserPage.ets
│   ├── RecipeDetailPage.ets
│   ├── FishingRecordPage.ets
│   ├── AddRecordPage.ets
│   ├── RecordDetailPage.ets
│   ├── MinePage.ets
│   ├── GeneratedRecipePage.ets
│   ├── GeneratorPage.ets
│   ├── GeneratorHistoryPage.ets
│   ├── FavoritePage.ets
│   ├── SettingsPage.ets
│   └── MapPage.ets
├── router/Router.ets
├── services/
│   ├── StorageService.ets
│   ├── RecipeService.ets
│   ├── RecipeGeneratorService.ets
│   ├── FishingRecordService.ets
│   ├── FishingSpotService.ets
│   ├── GeneratorHistoryService.ets
│   ├── LocationService.ets
│   ├── UserService.ets
│   └── WeatherService.ets
└── theme/
    ├── ThemeColors.ets
    └── ThemeConstants.ets
```

---

## 六、主题色彩

```typescript
// 主色调
PRIMARY: '#E8A849'        // 橙黄色
PRIMARY_DARK: '#C4872E'   // 深橙色

// 背景色
BG_PRIMARY: '#1A1A1A'     // 主背景
BG_SECONDARY: '#2A2A2A'   // 卡片背景
BG_TERTIARY: '#3A3A3A'    // 输入框背景

// 文字色
TEXT_PRIMARY: '#FFFFFF'   // 主文字
TEXT_SECONDARY: '#B0B0B0' // 次要文字
TEXT_MUTED: '#707070'     // 弱化文字
```

---

## 七、下一步

1. ~~创建主题系统~~ ✅
2. ~~实现欢迎页（随机背景）~~ ✅
3. ~~搭建 MainTabPage~~ ✅
4. ~~接入天气API~~ ✅
5. ~~完善数据持久化~~ ✅
6. ~~添加动画效果~~ ✅
7. ~~UI细节打磨~~ ✅

🎉 项目开发完成！
