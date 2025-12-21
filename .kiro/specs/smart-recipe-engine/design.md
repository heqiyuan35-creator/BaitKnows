# Smart Recipe Engine - 设计文档

## 架构概述

智能配方推荐引擎采用分层架构设计，将环境分析、原料匹配、配方生成、变体管理等功能模块化，便于扩展和维护。

```
┌─────────────────────────────────────────────────────────┐
│                    用户界面层                            │
│  GeneratedRecipePage / RecipeGeneratorPage              │
└─────────────────────────────────────────────────────────┘
                           │
┌─────────────────────────────────────────────────────────┐
│                  配方引擎服务层                          │
│              SmartRecipeEngineService                   │
│  ┌─────────────┬─────────────┬─────────────────────┐   │
│  │ContextAnalyzer│VariantManager│PreferenceLearner │   │
│  └─────────────┴─────────────┴─────────────────────┘   │
└─────────────────────────────────────────────────────────┘
                           │
┌─────────────────────────────────────────────────────────┐
│                    数据层                               │
│  ┌──────────────┬──────────────┬──────────────────┐    │
│  │IngredientPool│FishRuleBase  │UserPreferenceStore│   │
│  └──────────────┴──────────────┴──────────────────┘    │
└─────────────────────────────────────────────────────────┘
```

## 核心组件设计

### 1. ContextAnalyzer (环境分析器)

负责分析输入的环境条件，生成味型权重和状态权重。

```typescript
// 文件: entry/src/main/ets/services/engine/ContextAnalyzer.ets

class AnalysisResult {
  flavorWeights: FlavorWeights      // 味型权重 (腥/香/甜/酸/臭)
  stateWeights: StateWeights        // 状态权重 (雾化/粘度/比重)
  priorityFactors: string[]         // 优先考虑的因素
  specialConditions: string[]       // 特殊条件标记
}

class ContextAnalyzer {
  // 综合分析所有环境因素
  analyze(input: GenerateRecipeInput): AnalysisResult
  
  // 分析温度影响
  private analyzeTemperature(temp: number): FlavorModifier
  
  // 分析季节影响
  private analyzeSeason(season: RecipeSeason, fishId: string): FlavorModifier
  
  // 分析水域影响
  private analyzeWaterType(waterType: RecipeWaterType): StateModifier
  
  // 分析鱼情影响
  private analyzeFishCondition(density: FishDensity, activity: FishActivity): ConditionModifier
  
  // 检测特殊场景
  private detectSpecialScenarios(input: GenerateRecipeInput): string[]
}
```

### 2. IngredientPool (原料池)

管理所有可用原料，支持多维度筛选和匹配。

```typescript
// 文件: entry/src/main/ets/services/engine/IngredientPool.ets

class IngredientPool {
  private ingredients: Map<string, Ingredient>
  private categoryIndex: Map<IngredientCategory, string[]>
  private flavorIndex: Map<string, string[]>  // 按主味型索引
  private fishIndex: Map<string, string[]>    // 按适用鱼种索引
  
  // 按味型权重匹配原料
  matchByFlavor(weights: FlavorWeights, category: IngredientCategory, count: number): ScoredIngredient[]
  
  // 按状态权重匹配原料
  matchByState(weights: StateWeights, method: FishingMethod, count: number): ScoredIngredient[]
  
  // 按鱼种筛选
  filterByFish(fishId: string): Ingredient[]
  
  // 按季节筛选
  filterBySeason(season: RecipeSeason): Ingredient[]
  
  // 获取替代原料
  getAlternatives(ingredientId: string): Ingredient[]
}

class ScoredIngredient {
  ingredient: Ingredient
  score: number           // 匹配分数
  matchReasons: string[]  // 匹配原因
}
```

### 3. VariantManager (变体管理器)

管理配方变体，确保"换一换"功能能提供真正不同的配方。

```typescript
// 文件: entry/src/main/ets/services/engine/VariantManager.ets

class RecipeVariant {
  id: string
  strategy: VariantStrategy    // 变体策略
  ingredients: RecipeIngredient[]
  flavorProfile: FlavorDescription
  differenceScore: number      // 与基准配方的差异度
}

enum VariantStrategy {
  FLAVOR_SHIFT = 'flavor_shift',      // 味型偏移 (如腥香→香腥)
  INGREDIENT_SWAP = 'ingredient_swap', // 原料替换
  RATIO_ADJUST = 'ratio_adjust',       // 配比调整
  STATE_CHANGE = 'state_change',       // 状态改变
  ADDITIVE_CHANGE = 'additive_change'  // 添加剂更换
}

class VariantManager {
  private shownVariants: Set<string>   // 已展示的变体ID
  private variantCache: Map<string, RecipeVariant[]>  // 条件哈希 -> 变体列表
  
  // 生成配方变体
  generateVariants(baseRecipe: GeneratedRecipe, count: number): RecipeVariant[]
  
  // 获取下一个未展示的变体
  getNextVariant(conditionHash: string): RecipeVariant | null
  
  // 计算两个配方的差异度
  calculateDifference(recipe1: GeneratedRecipe, recipe2: GeneratedRecipe): number
  
  // 重置已展示记录
  resetShownHistory(): void
  
  // 生成条件哈希
  private hashConditions(input: GenerateRecipeInput): string
}
```

### 4. ReasonGenerator (理由生成器)

生成配方推荐理由，帮助用户理解配方设计思路。

```typescript
// 文件: entry/src/main/ets/services/engine/ReasonGenerator.ets

class ReasonGenerator {
  // 生成完整的推荐理由
  generateReasons(input: GenerateRecipeInput, recipe: GeneratedRecipe): GenerateReason[]
  
  // 生成温度相关理由
  private generateTempReason(temp: number): GenerateReason
  
  // 生成水域相关理由
  private generateWaterReason(waterType: RecipeWaterType): GenerateReason
  
  // 生成鱼种相关理由
  private generateFishReason(fishId: string): GenerateReason
  
  // 生成原料选择理由
  private generateIngredientReason(ingredient: RecipeIngredient, context: AnalysisResult): GenerateReason
  
  // 生成特殊场景理由
  private generateSpecialReason(scenario: string): GenerateReason
}
```

### 5. PreferenceLearner (偏好学习器)

学习用户偏好，优化推荐结果。

```typescript
// 文件: entry/src/main/ets/services/engine/PreferenceLearner.ets

class UserPreference {
  userId: string
  favoriteIngredients: Map<string, number>  // 原料ID -> 使用次数
  favoriteFlavors: Map<string, number>      // 味型 -> 偏好度
  savedRecipes: string[]                     // 保存的配方ID
  feedbackHistory: RecipeFeedback[]          // 反馈历史
}

class PreferenceLearner {
  private preferences: UserPreference
  
  // 记录配方保存
  recordSave(recipe: GeneratedRecipe): void
  
  // 记录原料使用
  recordIngredientUse(ingredientId: string): void
  
  // 记录配方反馈
  recordFeedback(recipeId: string, rating: string, note: string): void
  
  // 获取推荐权重调整
  getPreferenceBoost(ingredientId: string): number
  
  // 获取常用原料列表
  getFrequentIngredients(limit: number): string[]
  
  // 重置偏好数据
  resetPreferences(): void
}
```

## 数据模型设计

### 扩展的原料属性

```typescript
// 文件: entry/src/main/ets/common/types/IngredientTypes.ets

class EnhancedIngredient extends Ingredient {
  // 原有属性...
  
  // 新增属性
  alternatives: string[]           // 替代原料ID列表
  synergies: string[]              // 协同原料ID列表 (搭配效果好)
  conflicts: string[]              // 冲突原料ID列表 (不宜搭配)
  seasonalBonus: SeasonBonus[]     // 季节加成
  temperatureOptimal: number       // 最佳使用温度
  effectDescription: string        // 效果描述
}

class SeasonBonus {
  season: RecipeSeason
  bonus: number  // 加成值 (-20 到 +20)
}
```

### 配方变体数据

```typescript
// 文件: entry/src/main/ets/common/types/VariantTypes.ets

class VariantConfig {
  strategy: VariantStrategy
  minDifference: number      // 最小差异度要求
  maxAttempts: number        // 最大尝试次数
}

class VariantResult {
  variants: RecipeVariant[]
  totalGenerated: number
  uniqueCount: number
}
```

## 算法设计

### 1. 味型权重计算算法

```
输入: GenerateRecipeInput
输出: FlavorWeights

1. 获取鱼种基础味型 baseFlavor = getFishBaseFlavor(fishId)
2. 应用季节修正 seasonMod = getSeasonModifier(fishId, season)
3. 应用温度修正 tempMod = getTemperatureModifier(temperature)
4. 应用鱼情修正 activityMod = getActivityModifier(fishActivity)
5. 应用模式修正 modeMod = getModeModifier(mode)

6. 计算最终权重:
   finalWeights = baseFlavor
   finalWeights += seasonMod * 1.0
   finalWeights += tempMod * 1.2  // 温度影响权重更高
   finalWeights *= activityMod.scale
   finalWeights *= modeMod.scale

7. 归一化到 0-100 范围
8. 返回 finalWeights
```

### 2. 配方变体生成算法

```
输入: baseRecipe, count
输出: RecipeVariant[]

1. 初始化变体列表 variants = []
2. 定义策略优先级 strategies = [FLAVOR_SHIFT, INGREDIENT_SWAP, ADDITIVE_CHANGE, RATIO_ADJUST]

3. FOR each strategy in strategies:
   a. 尝试使用该策略生成变体
   b. 计算与基准配方的差异度
   c. IF 差异度 >= minDifference:
      - 添加到变体列表
   d. IF variants.length >= count:
      - BREAK

4. 如果变体不足，使用组合策略:
   a. 组合多个策略生成更多变体
   b. 确保每个变体都有足够差异

5. 返回 variants
```

### 3. 差异度计算算法

```
输入: recipe1, recipe2
输出: differenceScore (0-100)

1. 计算原料差异:
   ingredientDiff = 0
   FOR each ingredient in recipe1:
     IF ingredient not in recipe2:
       ingredientDiff += 20
     ELSE IF ratio difference > 10%:
       ingredientDiff += 10

2. 计算味型差异:
   flavorDiff = |recipe1.flavor - recipe2.flavor| / 5

3. 计算状态差异:
   stateDiff = |recipe1.state - recipe2.state| / 4

4. 综合差异度:
   totalDiff = ingredientDiff * 0.5 + flavorDiff * 0.3 + stateDiff * 0.2

5. 返回 min(100, totalDiff)
```

## 特殊场景处理

### 极端温度场景

| 温度范围 | 处理策略 |
|---------|---------|
| < 5°C | 高腥高蛋白，增加红虫粉/蚯蚓粉，减少雾化 |
| 5-10°C | 腥香为主，适当增加甜味，中等雾化 |
| 10-20°C | 均衡配方，根据鱼种调整 |
| 20-28°C | 香甜为主，可加果酸，快雾化 |
| > 28°C | 清淡果酸，减少腥味，快雾化 |

### 特殊水域场景

| 水域类型 | 处理策略 |
|---------|---------|
| 黑坑新放鱼 | 增加小药，快雾化，高诱鱼 |
| 黑坑老鱼 | 减少小药，本味为主，慢雾化 |
| 野河走水 | 增加粘度，重比重，减少雾化 |
| 水库深水 | 重比重，慢雾化，味型浓郁 |

## 文件结构

```
entry/src/main/ets/
├── services/
│   ├── engine/
│   │   ├── SmartRecipeEngine.ets      # 主引擎入口
│   │   ├── ContextAnalyzer.ets        # 环境分析器
│   │   ├── IngredientPool.ets         # 原料池
│   │   ├── VariantManager.ets         # 变体管理器
│   │   ├── ReasonGenerator.ets        # 理由生成器
│   │   └── PreferenceLearner.ets      # 偏好学习器
│   └── RecipeGeneratorService.ets     # 现有服务(重构)
├── data/
│   ├── IngredientDatabase.ets         # 原料数据库(扩展)
│   ├── RecipeRules.ets                # 配方规则(扩展)
│   └── SpecialScenarios.ets           # 特殊场景规则(新增)
└── common/types/
    ├── RecipeTypes.ets                # 配方类型(扩展)
    ├── IngredientTypes.ets            # 原料类型(新增)
    └── VariantTypes.ets               # 变体类型(新增)
```

## 接口设计

### SmartRecipeEngine 主接口

```typescript
class SmartRecipeEngine {
  // 生成配方
  generate(input: GenerateRecipeInput): GeneratedRecipe
  
  // 获取下一个变体 (换一换)
  getNextVariant(): GeneratedRecipe | null
  
  // 保存配方并记录偏好
  saveRecipe(recipe: GeneratedRecipe): void
  
  // 提交反馈
  submitFeedback(recipeId: string, rating: string, note: string): void
  
  // 获取用户常用原料
  getFrequentIngredients(): string[]
  
  // 重置变体历史
  resetVariantHistory(): void
}
```

## 性能考虑

1. **原料索引**: 使用多维索引加速原料查询
2. **变体缓存**: 缓存已生成的变体，避免重复计算
3. **懒加载**: 原料数据按需加载
4. **内存管理**: 限制变体缓存大小，定期清理

## 扩展性设计

1. **插件式规则**: 新的鱼种规则可以独立添加
2. **策略模式**: 变体生成策略可扩展
3. **配置化**: 关键参数可配置调整
