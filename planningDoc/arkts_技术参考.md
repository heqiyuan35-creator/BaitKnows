# BaitKnows ArkTS 技术参考

> 基于 HydroQuiz 项目经验整理，避免踩坑

---

## 一、ArkTS 常见错误与解决方案

### 1. arkts-limited-throw - throw 类型限制

```typescript
// ❌ 错误
throw 'Database not initialized';
throw error;  // error 是 unknown

// ✅ 正确
throw new Error('Database not initialized');
throw new Error(`Failed: ${(error as Error).message}`);
```

### 2. arkts-no-utility-types - 不支持工具类型

```typescript
// ❌ 错误 - 不支持 Omit、Pick、Partial
async save(record: Omit<Record, 'id'>): Promise<string>

// ✅ 正确 - 定义独立接口
export interface RecordInput {
  name: string;
  value: number;
}
async save(record: RecordInput): Promise<string>
```

### 3. arkts-no-obj-literals-as-types - 对象字面量不能作为类型

```typescript
// ❌ 错误
async save(data: { name: string; value: number }): Promise<void>

// ✅ 正确
export interface DataInput { name: string; value: number; }
async save(data: DataInput): Promise<void>
```

### 4. arkts-no-untyped-obj-literals - 对象必须有类型

```typescript
// ❌ 错误
await service.save({ name: 'test', value: 100 });

// ✅ 正确
const input: DataInput = { name: 'test', value: 100 };
await service.save(input);
```

### 5. arkts-no-structural-typing - 不支持结构化类型

```typescript
// ❌ 错误 - 不同文件定义相同结构的接口不能互用
// PageA.ets
interface Stats { total: number; }
// Service.ets
export interface Statistics { total: number; }
// 赋值会报错！

// ✅ 正确 - 导入使用同一个类型
import { Statistics } from '../services/Service';
@State stats: Statistics = { total: 0 };
```

### 6. @Builder 中不能声明变量

```typescript
// ❌ 错误
@Builder
ItemBuilder(index: number) {
  const isActive = index === this.currentIndex;  // 错误！
  Text(isActive ? '✓' : '')
}

// ✅ 正确 - 抽取到方法
private isActive(index: number): boolean {
  return index === this.currentIndex;
}

@Builder
ItemBuilder(index: number) {
  Text(this.isActive(index) ? '✓' : '')
}
```

### 7. 资源目录结构错误

```
// ❌ 错误 - profile 目录只能放 JSON5
resources/base/profile/
├── main_pages.json  ✅
└── htmlFolder/      ❌ 不能放文件夹

// ✅ 正确
resources/base/profile/
├── main_pages.json
└── backup_config.json

planningDoc/  // 其他文件放这里
└── reference/
```

---

## 二、最佳实践

### 1. 接口定义规范

```typescript
// 输入参数接口
export interface RecipeInput {
  name: string;
  targetFish: string[];
  ingredients: IngredientInput[];
}

// 返回结果接口
export interface RecipeResult {
  id: string;
  recipe: BaitRecipe;
  score: number;
}
```

### 2. 错误处理规范

```typescript
try {
  // 业务逻辑
} catch (error) {
  console.error('[Service] Failed:', (error as Error).message);
  throw new Error('Operation failed');
}
```

### 3. 对象创建规范

```typescript
// ✅ 推荐
const result: RecipeResult = {
  id: 'r_001',
  recipe: recipe,
  score: 85
};
return result;

// ❌ 不推荐
return { id: 'r_001', recipe: recipe, score: 85 };
```

### 4. ID 命名规范

```typescript
// 格式：{类型}_{编号}
{ id: 'recipe_001', ... }      // 配方
{ id: 'fish_001', ... }        // 鱼种
{ id: 'ingredient_001', ... }  // 配料
{ id: 'record_001', ... }      // 渔获记录
```

---

## 三、动画效果

### 1. 入场动画（列表项依次出现）

```typescript
@Component
struct AnimatedItem {
  @Prop index: number = 0;

  build() {
    Column() { /* 内容 */ }
    .transition(
      TransitionEffect.OPACITY
        .combine(TransitionEffect.scale({ x: 0.5, y: 0.5 }))
        .animation({ 
          duration: 300, 
          curve: Curve.Friction, 
          delay: 30 * this.index  // 依次延迟
        })
    )
  }
}
```

### 2. 弹性回弹动画

```typescript
import { curves } from '@kit.ArkUI';

this.getUIContext()?.animateTo({
  curve: curves.springMotion()
}, () => {
  this.translateX = 0;
  this.translateY = 0;
});
```

### 3. 缩放淡出动画

```typescript
this.getUIContext()?.animateTo({
  duration: 300,
  curve: Curve.EaseIn
}, () => {
  item.scaleVal = 0;
  item.opacityVal = 0;
});
```

### 动画曲线速查

| 曲线 | 效果 | 适用场景 |
|------|------|----------|
| `Curve.Friction` | 摩擦减速 | 入场动画 |
| `Curve.EaseIn` | 缓入 | 退出/消失 |
| `Curve.EaseOut` | 缓出 | 进入/出现 |
| `curves.springMotion()` | 弹性 | 回弹效果 |

---

## 四、手势交互

### 长按 + 拖拽组合

```typescript
.gesture(
  GestureGroup(GestureMode.Sequence,
    // 先长按
    LongPressGesture({ duration: 500 })
      .onAction(() => {
        this.isDragging = true;
      }),
    // 再拖拽
    PanGesture({ direction: PanDirection.All })
      .onActionUpdate((event) => {
        item.translateX = event.offsetX;
        item.translateY = event.offsetY;
      })
      .onActionEnd(() => {
        this.isDragging = false;
      })
  )
)
```

---

## 五、数据存储 (Preferences)

### 基础封装

```typescript
import { preferences } from '@kit.ArkData';

class StorageService {
  private pref: preferences.Preferences | null = null;

  async init(context: Context): Promise<void> {
    this.pref = await preferences.getPreferences(context, 'bait_knows');
  }

  async save<T>(key: string, data: T): Promise<void> {
    await this.pref?.put(key, JSON.stringify(data));
    await this.pref?.flush();
  }

  async load<T>(key: string, defaultVal: T): Promise<T> {
    const json = await this.pref?.get(key, '') as string;
    return json ? JSON.parse(json) as T : defaultVal;
  }
}
```

---

## 六、BaitKnows 项目特定注意事项

### 1. 欢迎页随机背景

```typescript
// 背景图列表
const backgrounds: Resource[] = [
  $r('app.media.Welcomebackground1'),
  $r('app.media.Welcomebackground2'),
  $r('app.media.Welcomebackground3'),
  $r('app.media.Welcomebackground4')
];

// 随机选择（避免连续重复）
async getRandomBg(): Promise<Resource> {
  let lastIdx = await storage.load('bg_index', -1);
  let newIdx: number;
  do {
    newIdx = Math.floor(Math.random() * 4);
  } while (newIdx === lastIdx);
  await storage.save('bg_index', newIdx);
  return backgrounds[newIdx];
}
```

### 2. 配方数据结构

```typescript
// 配方输入（用于保存）
export interface RecipeInput {
  name: string;
  targetFish: string[];
  waterType: string[];
  season: string[];
  ingredients: IngredientInput[];
  steps: StepInput[];
}

// 配方完整数据
export class BaitRecipe {
  id: string = '';
  name: string = '';
  targetFish: string[] = [];
  waterType: string[] = [];
  season: string[] = [];
  difficulty: string = 'medium';
  catchRate: number = 0;
  ingredients: BaitIngredient[] = [];
  steps: RecipeStep[] = [];
  tips: string[] = [];
  isFavorite: boolean = false;
  createdAt: number = 0;
}
```

### 3. 渔获记录数据结构

```typescript
export interface FishingRecordInput {
  date: number;
  location: string;
  weather: string;
  fishName: string;
  weight: number;
  count: number;
  recipeId: string;
  notes: string;
}

export class FishingRecord {
  id: string = '';
  date: number = 0;
  location: string = '';
  weather: string = '';
  fishName: string = '';
  fishNameEn: string = '';
  weight: number = 0;
  count: number = 1;
  recipeId: string = '';
  recipeName: string = '';
  notes: string = '';
}
```

---

## 七、快速参考

### 常用 Kit 导入

```typescript
// 路由
import { router } from '@kit.ArkUI';

// 动画曲线
import { curves } from '@kit.ArkUI';

// 数据存储
import { preferences } from '@kit.ArkData';

// 上下文
import { common } from '@kit.AbilityKit';

// 弹窗
import { promptAction } from '@kit.ArkUI';
```

### 路由跳转

```typescript
// 跳转
router.pushUrl({ url: 'pages/RecipeDetailPage', params: { id: 'r_001' } });

// 返回
router.back();

// 获取参数
const params = router.getParams() as Record<string, string>;
const id = params['id'];
```

### 弹窗提示

```typescript
promptAction.showToast({ message: '保存成功', duration: 2000 });
```

---

> 文档版本: 1.0  
> 更新日期: 2025-12-20
