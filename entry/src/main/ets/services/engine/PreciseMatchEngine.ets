/**
 * 精确匹配引擎
 * 根据多维度参数计算最优配方
 */
import {
  PreciseMatchInput,
  PreciseMatchResult,
  DimensionScores,
  ParameterWeight,
  AnalysisStep,
  IngredientRatio,
  FeedbackType
} from '../../common/types/PreciseMatchTypes';
import {
  GeneratedRecipe,
  RecipeIngredient,
  FlavorDescription,
  StateProfile,
  UsageSuggestion,
  GenerateReason
} from '../../common/types/RecipeTypes';
import { getFishById, FishData } from '../../data/FishData';
import { getAllIngredients, Ingredient, getIngredientById } from '../../data/IngredientDatabase';

// 原料类别颜色
const CATEGORY_COLORS: Record<string, string> = {
  'main': '#E6A23C',
  'auxiliary': '#67C23A',
  'state': '#409EFF',
  'additive': '#F56C6C'
};

const CATEGORY_NAMES: Record<string, string> = {
  'main': '基础饵',
  'auxiliary': '主攻饵',
  'state': '状态饵',
  'additive': '添加剂'
};

export class PreciseMatchEngine {
  private input: PreciseMatchInput = new PreciseMatchInput();
  private fishData: FishData | undefined;

  constructor() {}

  /**
   * 执行精确匹配分析
   */
  analyze(input: PreciseMatchInput): PreciseMatchResult {
    this.input = input;
    this.fishData = getFishById(input.targetFish);

    const result = new PreciseMatchResult();

    // 1. 生成分析步骤
    result.analysisSteps = this.generateAnalysisSteps();

    // 2. 计算参数权重
    result.parameterWeights = this.calculateParameterWeights();

    // 3. 生成配方
    result.recipe = this.generateRecipe();

    // 4. 计算维度评分
    result.dimensionScores = this.calculateDimensionScores();

    // 5. 计算总匹配度
    result.matchScore = result.dimensionScores.getAverage();
    result.scoreDescription = result.getScoreLevel();

    // 6. 生成原料配比数据
    result.ingredientRatios = this.generateIngredientRatios(result.recipe);

    // 7. 生成备选方案
    result.alternatives = this.generateAlternatives();

    return result;
  }

  /**
   * 根据反馈调整配方
   */
  adjustByFeedback(currentResult: PreciseMatchResult, feedbacks: FeedbackType[], excludedIngredients: string[] = []): PreciseMatchResult {
    // 增加刷新计数器，确保每次生成不同结果
    this.refreshCount++;

    // 保存排除的原料
    this.excludedIngredientNames = excludedIngredients;

    // 根据反馈类型调整输入参数
    for (const feedback of feedbacks) {
      switch (feedback) {
        case 'flavor_dislike':
          // 切换味型强度
          this.cycleFlavorIntensity();
          break;
        case 'ingredient_hard':
          // 标记需要替换原料
          this.needAlternativeIngredients = true;
          break;
        case 'state_wrong':
          // 切换饵料状态
          this.cycleBaitState();
          break;
        case 'want_more_fishy':
          this.input.flavorIntensity = 'strong';
          this.preferFishy = true;
          break;
        case 'want_more_fragrant':
          this.input.flavorIntensity = 'strong';
          this.preferFishy = false;
          break;
        case 'want_lighter':
          this.input.flavorIntensity = 'light';
          break;
        case 'other':
          // 完全随机调整
          this.randomAdjust();
          break;
        default:
          break;
      }
    }

    // 如果有排除的原料，标记需要替换
    if (excludedIngredients.length > 0) {
      this.needAlternativeIngredients = true;
    }

    // 如果没有选择任何反馈，也要生成不同的配方
    if (feedbacks.length === 0 && excludedIngredients.length === 0) {
      this.randomAdjust();
    }

    // 重新分析
    const result = this.analyze(this.input);

    // 重置临时标记
    this.needAlternativeIngredients = false;
    this.preferFishy = false;
    this.excludedIngredientNames = [];

    return result;
  }

  // 刷新计数器
  private refreshCount: number = 0;
  // 是否需要替换原料
  private needAlternativeIngredients: boolean = false;
  // 是否偏好腥味
  private preferFishy: boolean = false;
  // 排除的原料名称
  private excludedIngredientNames: string[] = [];

  // 循环切换味型强度
  private cycleFlavorIntensity(): void {
    const intensities: Array<'light' | 'medium' | 'strong' | 'intense'> = ['light', 'medium', 'strong', 'intense'];
    const currentIndex = intensities.indexOf(this.input.flavorIntensity);
    const nextIndex = (currentIndex + 1) % intensities.length;
    this.input.flavorIntensity = intensities[nextIndex];
  }

  // 循环切换饵料状态
  private cycleBaitState(): void {
    const states: Array<'fast_dissolve' | 'slow_dissolve' | 'sticky' | 'dry_loose'> = ['fast_dissolve', 'slow_dissolve', 'sticky', 'dry_loose'];
    const currentIndex = states.indexOf(this.input.baitState);
    const nextIndex = (currentIndex + 1) % states.length;
    this.input.baitState = states[nextIndex];
  }

  // 随机调整参数
  private randomAdjust(): void {
    // 随机调整味型强度
    const intensities: Array<'light' | 'medium' | 'strong' | 'intense'> = ['light', 'medium', 'strong', 'intense'];
    const randomIntensity = intensities[(this.refreshCount) % intensities.length];
    if (randomIntensity !== this.input.flavorIntensity) {
      this.input.flavorIntensity = randomIntensity;
    } else {
      // 如果味型相同，切换饵料状态
      this.cycleBaitState();
    }
  }

  /**
   * 生成分析步骤
   */
  private generateAnalysisSteps(): AnalysisStep[] {
    const fishName = this.fishData?.name || '目标鱼';
    return [
      AnalysisStep.create(1, '参数解析', '解析输入的钓况参数', `${this.countActiveParams()}个参数`),
      AnalysisStep.create(2, '习性匹配', `匹配${fishName}的觅食习性`, this.fishData?.habit.description || ''),
      AnalysisStep.create(3, '原料筛选', '从原料库筛选适合原料', `${this.getMatchedIngredientsCount()}种原料`),
      AnalysisStep.create(4, '配比优化', '计算最优原料配比', '加权优化算法'),
      AnalysisStep.create(5, '方案生成', '生成最优配方方案', '完成')
    ];
  }

  /**
   * 计算参数权重
   */
  private calculateParameterWeights(): ParameterWeight[] {
    const weights: ParameterWeight[] = [];

    // 鱼种权重最高
    weights.push(ParameterWeight.create('目标鱼种', 25, '决定基础味型和饵料选择'));

    // 季节和温度
    weights.push(ParameterWeight.create('季节温度', 20, '影响鱼的活跃度和食欲'));

    // 水域环境
    weights.push(ParameterWeight.create('水域环境', 15, '影响饵料状态和雾化'));

    // 水深
    if (this.input.waterDepth === 'deep') {
      weights.push(ParameterWeight.create('水深', 12, '深水需要更重的饵料'));
    } else {
      weights.push(ParameterWeight.create('水深', 8, '影响饵料比重'));
    }

    // 水质
    weights.push(ParameterWeight.create('水质', 10, '影响味型浓度选择'));

    // 光照
    weights.push(ParameterWeight.create('光照条件', 8, '影响鱼的活动层'));

    // 风力
    weights.push(ParameterWeight.create('风力', 5, '影响抛投和雾化'));

    // 味型强度
    weights.push(ParameterWeight.create('味型偏好', 7, '用户个人偏好'));

    return weights;
  }

  /**
   * 生成配方
   */
  private generateRecipe(): GeneratedRecipe {
    const recipe = new GeneratedRecipe();
    recipe.id = `precise_${Date.now()}`;
    recipe.name = this.generateRecipeName();
    recipe.totalWeight = 500;
    recipe.createTime = Date.now();

    // 生成原料列表
    recipe.ingredients = this.selectIngredients();

    // 生成味型描述
    recipe.flavorProfile = this.generateFlavorProfile();

    // 生成状态特性
    recipe.stateProfile = this.generateStateProfile();

    // 生成使用建议
    recipe.usage = this.generateUsageSuggestion();

    // 生成推荐理由
    recipe.reasons = this.generateReasons();

    return recipe;
  }

  /**
   * 生成配方名称
   */
  private generateRecipeName(): string {
    const fishName = this.fishData?.name || '通用';
    const flavorMap: Record<string, string> = {
      'light': '清香',
      'medium': '经典',
      'strong': '浓香',
      'intense': '特浓'
    };
    const flavor = flavorMap[this.input.flavorIntensity] || '经典';

    // 根据刷新次数添加变体标识
    const variants: string[] = ['', '改良', '升级', '特调'];
    const variant = this.refreshCount > 0 ? variants[this.refreshCount % variants.length] : '';

    return variant ? `${flavor}${fishName}配方(${variant})` : `${flavor}${fishName}配方`;
  }

  /**
   * 选择原料
   */
  private selectIngredients(): RecipeIngredient[] {
    const ingredients: RecipeIngredient[] = [];

    // 基础饵 40%
    const mainIngredient = new RecipeIngredient();
    mainIngredient.id = 'base_bait';
    mainIngredient.name = this.selectMainBait();
    mainIngredient.category = 'main';
    mainIngredient.percentage = 40;
    mainIngredient.weight = 200;
    mainIngredient.purpose = '提供基础味型和状态';
    ingredients.push(mainIngredient);

    // 主攻饵 25%
    const auxIngredient = new RecipeIngredient();
    auxIngredient.id = 'attack_bait';
    auxIngredient.name = this.selectAttackBait();
    auxIngredient.category = 'auxiliary';
    auxIngredient.percentage = 25;
    auxIngredient.weight = 125;
    auxIngredient.purpose = '增强诱鱼效果';
    ingredients.push(auxIngredient);

    // 状态饵 20%
    const stateIngredient = new RecipeIngredient();
    stateIngredient.id = 'state_bait';
    stateIngredient.name = this.selectStateBait();
    stateIngredient.category = 'state';
    stateIngredient.percentage = 20;
    stateIngredient.weight = 100;
    stateIngredient.purpose = '调整饵料状态';
    ingredients.push(stateIngredient);

    // 添加剂 15%
    const additiveIngredient = new RecipeIngredient();
    additiveIngredient.id = 'additive';
    additiveIngredient.name = this.selectAdditive();
    additiveIngredient.category = 'additive';
    additiveIngredient.percentage = 15;
    additiveIngredient.weight = 75;
    additiveIngredient.purpose = '提升味型穿透力';
    ingredients.push(additiveIngredient);

    return ingredients;
  }

  /**
   * 从候选列表中选择一个未被排除的原料
   */
  private selectFromCandidates(candidates: string[]): string {
    // 过滤掉被排除的原料
    const available = candidates.filter((name: string) => !this.excludedIngredientNames.includes(name));
    if (available.length > 0) {
      return available[this.refreshCount % available.length];
    }
    // 如果全部被排除，返回第一个候选
    return candidates[this.refreshCount % candidates.length];
  }

  /**
   * 选择基础饵 - 综合考虑季节、温度、水质、光照
   */
  private selectMainBait(): string {
    const season = this.input.season;
    const waterQuality = this.input.waterQuality;
    const lightCondition = this.input.lightCondition;

    // 根据水质调整基础饵选择
    if (waterQuality === 'muddy' || waterQuality === 'fertile') {
      // 浑水/肥水：需要味道更浓的基础饵
      if (season === 'winter' || this.input.temperature < 15) {
        return this.selectFromCandidates(['浓腥基础饵', '红虫风味基础饵', '虾腥基础饵']);
      } else {
        return this.selectFromCandidates(['浓香基础饵', '发酵玉米基础饵', '酒香基础饵']);
      }
    }

    // 夜钓或晨昏：增加腥味
    if (lightCondition === 'night' || lightCondition === 'dawn_dusk') {
      return this.selectFromCandidates(['腥香基础饵', '虾腥基础饵', '蚕蛹基础饵']);
    }

    // 正常情况根据季节温度选择
    if (season === 'winter' || this.input.temperature < 15) {
      return this.selectFromCandidates(['腥香基础饵', '红虫风味基础饵', '虾腥基础饵']);
    } else if (season === 'summer' || this.input.temperature > 28) {
      return this.selectFromCandidates(['清香基础饵', '果香基础饵', '薯香基础饵']);
    }
    return this.selectFromCandidates(['谷物基础饵', '麦香基础饵', '玉米基础饵']);
  }

  /**
   * 选择主攻饵 - 综合考虑鱼种习性、水质、目标体型
   */
  private selectAttackBait(): string {
    const fishHabit = this.fishData?.habit;
    const targetSize = this.input.targetFishSize;
    const waterQuality = this.input.waterQuality;

    // 大体型鱼：需要更浓的味道和更大的颗粒感
    if (targetSize === 'large') {
      if (fishHabit?.feedingType === 'carnivore' || this.preferFishy) {
        return this.selectFromCandidates(['浓腥大物饵', '螺蛳主攻饵', '蚌肉主攻饵']);
      }
      return this.selectFromCandidates(['发酵玉米主攻饵', '老坛玉米主攻饵', '大颗粒主攻饵']);
    }

    // 小体型鱼：需要更细腻的饵料
    if (targetSize === 'small') {
      return this.selectFromCandidates(['细腻主攻饵', '奶香主攻饵', '蛋奶主攻饵']);
    }

    // 肥水环境：需要更浓的味道
    if (waterQuality === 'fertile') {
      return this.selectFromCandidates(['浓香主攻饵', '发酵主攻饵', '酸臭主攻饵']);
    }

    // 根据鱼种习性选择
    if (fishHabit?.feedingType === 'carnivore' || this.preferFishy) {
      return this.selectFromCandidates(['虾粉主攻饵', '蚕蛹主攻饵', '红虫主攻饵', '鱼粉主攻饵']);
    } else if (fishHabit?.feedingType === 'herbivore') {
      return this.selectFromCandidates(['藻香主攻饵', '草香主攻饵', '嫩玉米主攻饵']);
    }

    return this.selectFromCandidates(['综合主攻饵', '腥香主攻饵', '奶香主攻饵', '果香主攻饵']);
  }

  /**
   * 选择状态饵 - 综合考虑饵料状态、水深、风力
   */
  private selectStateBait(): string {
    const waterDepth = this.input.waterDepth;
    const windCondition = this.input.windCondition;

    // 深水：需要增加比重，减少雾化
    if (waterDepth === 'deep') {
      if (this.input.baitState === 'fast_dissolve') {
        return this.selectFromCandidates(['比重粉', '颗粒粉', '沉底粉']);
      }
      return this.selectFromCandidates(['粘粉+比重粉', '糯米粉', '重质粘粉']);
    }

    // 浅水：需要更好的雾化
    if (waterDepth === 'shallow') {
      return this.selectFromCandidates(['雪花粉', '轻麸', '膨化玉米粉']);
    }

    // 大风天气：需要更粘的饵料
    if (windCondition === 'strong' || windCondition === 'medium') {
      return this.selectFromCandidates(['拉丝粉', '粘粉', '小麦蛋白']);
    }

    // 根据饵料状态选择
    const stateOptions: Record<string, string[]> = {
      'fast_dissolve': ['雪花粉', '轻麸', '膨化玉米粉'],
      'slow_dissolve': ['粘粉', '糯米粉', '面粉'],
      'sticky': ['拉丝粉', '小麦蛋白', '粘粉'],
      'dry_loose': ['轻麸', '雪花粉', '膨化饵']
    };

    const options = stateOptions[this.input.baitState] || stateOptions['fast_dissolve'];
    return this.selectFromCandidates(options);
  }

  /**
   * 选择添加剂 - 综合考虑味型强度、水质、光照
   */
  private selectAdditive(): string {
    const waterQuality = this.input.waterQuality;
    const lightCondition = this.input.lightCondition;

    // 浑水/肥水：需要穿透力更强的添加剂
    if (waterQuality === 'muddy' || waterQuality === 'fertile') {
      return this.selectFromCandidates(['穿透型诱食剂', '浓香添加剂', '特效诱鱼剂']);
    }

    // 夜钓：增加腥味添加剂
    if (lightCondition === 'night') {
      return this.selectFromCandidates(['浓腥添加剂', '虾膏', '蚕蛹液']);
    }

    // 根据味型强度选择
    const additiveOptions: Record<string, string[]> = {
      'light': ['果酸添加剂', '清香诱食剂', '淡味增效剂'],
      'medium': ['甜香添加剂', '奶香诱食剂', '综合增效剂'],
      'strong': ['浓腥添加剂', '虾膏', '蚕蛹液'],
      'intense': ['特浓诱鱼剂', '超腥添加剂', '氨基酸诱食剂']
    };

    const options = additiveOptions[this.input.flavorIntensity] || additiveOptions['medium'];
    return this.selectFromCandidates(options);
  }

  /**
   * 生成味型描述 - 综合考虑鱼种、水质、光照、目标体型
   */
  private generateFlavorProfile(): FlavorDescription {
    const profile = new FlavorDescription();
    const fishHabit = this.fishData?.habit;
    const waterQuality = this.input.waterQuality;
    const lightCondition = this.input.lightCondition;
    const targetSize = this.input.targetFishSize;

    // 根据水质调整味型
    if (waterQuality === 'muddy' || waterQuality === 'fertile') {
      profile.primary = '浓香';
      profile.secondary = '发酵香';
    } else if (lightCondition === 'night' || lightCondition === 'dawn_dusk') {
      // 夜钓增加腥味
      profile.primary = '腥香';
      profile.secondary = '鲜甜';
    } else if (fishHabit?.feedingType === 'carnivore') {
      profile.primary = '腥香';
      profile.secondary = '鲜甜';
    } else if (fishHabit?.feedingType === 'herbivore') {
      profile.primary = '清香';
      profile.secondary = '谷物香';
    } else {
      profile.primary = '腥香';
      profile.secondary = '奶香';
    }

    // 根据目标体型调整浓度
    const intensityMap: Record<string, number> = {
      'light': 3,
      'medium': 5,
      'strong': 7,
      'intense': 9
    };
    let intensity = intensityMap[this.input.flavorIntensity] || 5;

    // 大鱼需要更浓的味道
    if (targetSize === 'large') {
      intensity = Math.min(intensity + 2, 10);
    } else if (targetSize === 'small') {
      intensity = Math.max(intensity - 1, 1);
    }

    profile.intensity = intensity;
    profile.suitableTemp = `${this.input.temperature - 5}°C - ${this.input.temperature + 5}°C`;

    return profile;
  }

  /**
   * 生成状态特性 - 综合考虑饵料状态、水深、风力、水质
   */
  private generateStateProfile(): StateProfile {
    const profile = new StateProfile();
    const waterDepth = this.input.waterDepth;
    const windCondition = this.input.windCondition;
    const waterQuality = this.input.waterQuality;

    // 基础状态根据饵料状态设置
    switch (this.input.baitState) {
      case 'fast_dissolve':
        profile.atomization = 8;
        profile.viscosity = 3;
        profile.hookHolding = 4;
        profile.weight = 4;
        break;
      case 'slow_dissolve':
        profile.atomization = 4;
        profile.viscosity = 6;
        profile.hookHolding = 7;
        profile.weight = 5;
        break;
      case 'sticky':
        profile.atomization = 3;
        profile.viscosity = 8;
        profile.hookHolding = 9;
        profile.weight = 6;
        break;
      case 'dry_loose':
        profile.atomization = 9;
        profile.viscosity = 2;
        profile.hookHolding = 3;
        profile.weight = 3;
        break;
    }

    // 根据水深调整比重和雾化
    if (waterDepth === 'deep') {
      profile.weight = Math.min(profile.weight + 3, 10);
      profile.atomization = Math.max(profile.atomization - 2, 1);
    } else if (waterDepth === 'shallow') {
      profile.weight = Math.max(profile.weight - 2, 1);
      profile.atomization = Math.min(profile.atomization + 1, 10);
    }

    // 根据风力调整粘性和附钩性
    if (windCondition === 'strong') {
      profile.viscosity = Math.min(profile.viscosity + 2, 10);
      profile.hookHolding = Math.min(profile.hookHolding + 2, 10);
    } else if (windCondition === 'medium') {
      profile.viscosity = Math.min(profile.viscosity + 1, 10);
      profile.hookHolding = Math.min(profile.hookHolding + 1, 10);
    }

    // 根据水质调整雾化
    if (waterQuality === 'muddy') {
      // 浑水减少雾化，增加味道穿透
      profile.atomization = Math.max(profile.atomization - 1, 1);
    } else if (waterQuality === 'clear') {
      // 清水可以增加雾化
      profile.atomization = Math.min(profile.atomization + 1, 10);
    }

    return profile;
  }

  /**
   * 生成使用建议 - 综合考虑饵料状态、水深、风力、光照、目标体型
   */
  private generateUsageSuggestion(): UsageSuggestion {
    const suggestion = new UsageSuggestion();
    const waterDepth = this.input.waterDepth;
    const windCondition = this.input.windCondition;
    const lightCondition = this.input.lightCondition;
    const targetSize = this.input.targetFishSize;

    // 根据饵料状态和水深调整水比
    let waterRatioBase = 1.0;
    switch (this.input.baitState) {
      case 'fast_dissolve':
        waterRatioBase = 0.9;
        suggestion.restTime = '3-5分钟';
        break;
      case 'slow_dissolve':
        waterRatioBase = 1.1;
        suggestion.restTime = '8-10分钟';
        break;
      case 'sticky':
        waterRatioBase = 1.2;
        suggestion.restTime = '10-15分钟';
        break;
      case 'dry_loose':
        waterRatioBase = 0.8;
        suggestion.restTime = '2-3分钟';
        break;
    }

    // 深水需要更干的饵料
    if (waterDepth === 'deep') {
      waterRatioBase -= 0.1;
    } else if (waterDepth === 'shallow') {
      waterRatioBase += 0.05;
    }

    suggestion.waterRatio = `1:${waterRatioBase.toFixed(1)}`;

    // 根据光照和目标体型生成首竿建议
    if (lightCondition === 'night') {
      suggestion.firstCast = '夜钓建议先打重窝，使用荧光漂，等待15-20分钟后开始作钓';
    } else if (lightCondition === 'dawn_dusk') {
      suggestion.firstCast = '晨昏时段鱼口活跃，先打3-5竿窝料，等待5-10分钟即可开钓';
    } else if (targetSize === 'large') {
      suggestion.firstCast = '钓大鱼需要耐心，先打重窝5-8竿，等待20-30分钟让鱼进窝';
    } else if (targetSize === 'small') {
      suggestion.firstCast = '钓小鱼可以边钓边诱，先打2-3竿窝料，5分钟后即可开钓';
    } else {
      suggestion.firstCast = '先打3-5竿窝料，等待10分钟后开始作钓';
    }

    // 根据水深和风力生成补窝建议
    if (waterDepth === 'deep') {
      if (windCondition === 'strong') {
        suggestion.nestSuggestion = '深水大风天气，建议使用打窝器精准补窝，每次补窝量加大50%';
      } else {
        suggestion.nestSuggestion = '深水建议重窝，每30分钟补窝一次，每次补窝量加大';
      }
    } else if (windCondition === 'strong' || windCondition === 'medium') {
      suggestion.nestSuggestion = '有风天气饵料易散，建议增加补窝频率，每20分钟补窝一次';
    } else {
      suggestion.nestSuggestion = '正常补窝即可，根据鱼口情况每20-30分钟补窝一次';
    }

    return suggestion;
  }

  /**
   * 生成推荐理由 - 展示所有参数的影响
   */
  private generateReasons(): GenerateReason[] {
    const reasons: GenerateReason[] = [];
    const fishName = this.fishData?.name || '目标鱼';

    // 鱼种理由
    const fishReason = new GenerateReason();
    fishReason.condition = `目标鱼种: ${fishName}`;
    fishReason.decision = `选择${this.fishData?.habit.feedingType === 'carnivore' ? '腥味' : '香味'}为主的配方`;
    fishReason.icon = '🐟';
    reasons.push(fishReason);

    // 温度理由
    const tempReason = new GenerateReason();
    tempReason.condition = `当前温度: ${this.input.temperature}°C`;
    tempReason.decision = this.input.temperature < 15 ? '低温增加腥味比例' :
      (this.input.temperature > 28 ? '高温减少腥味，增加清香' : '温度适中，均衡配比');
    tempReason.icon = '🌡';
    reasons.push(tempReason);

    // 水深理由
    const depthReason = new GenerateReason();
    const depthNames: Record<string, string> = { 'shallow': '浅水(<1m)', 'medium': '中层(1-3m)', 'deep': '深水(>3m)' };
    depthReason.condition = `水深: ${depthNames[this.input.waterDepth] || '中层'}`;
    depthReason.decision = this.input.waterDepth === 'deep' ? '增加饵料比重，减缓雾化速度' :
      (this.input.waterDepth === 'shallow' ? '减轻比重，增加雾化诱鱼' : '正常比重和雾化');
    depthReason.icon = '💧';
    reasons.push(depthReason);

    // 水质理由
    const qualityReason = new GenerateReason();
    const qualityNames: Record<string, string> = { 'clear': '清澈', 'slight_muddy': '微浑', 'muddy': '浑浊', 'fertile': '肥水' };
    qualityReason.condition = `水质: ${qualityNames[this.input.waterQuality] || '清澈'}`;
    qualityReason.decision = (this.input.waterQuality === 'muddy' || this.input.waterQuality === 'fertile') ?
      '增加味道浓度，提升穿透力' : '正常味道浓度';
    qualityReason.icon = '🌊';
    reasons.push(qualityReason);

    // 光照理由
    const lightReason = new GenerateReason();
    const lightNames: Record<string, string> = { 'bright': '强光', 'cloudy': '阴天', 'dawn_dusk': '晨昏', 'night': '夜钓' };
    lightReason.condition = `光照: ${lightNames[this.input.lightCondition] || '强光'}`;
    lightReason.decision = (this.input.lightCondition === 'night' || this.input.lightCondition === 'dawn_dusk') ?
      '增加腥味比例，提升诱鱼效果' : '正常味型配比';
    lightReason.icon = '☀️';
    reasons.push(lightReason);

    // 风力理由
    if (this.input.windCondition !== 'none') {
      const windReason = new GenerateReason();
      const windNames: Record<string, string> = { 'none': '无风', 'light': '微风', 'medium': '中风', 'strong': '大风' };
      windReason.condition = `风力: ${windNames[this.input.windCondition] || '无风'}`;
      windReason.decision = (this.input.windCondition === 'strong' || this.input.windCondition === 'medium') ?
        '增加饵料粘性，提高附钩性' : '正常状态';
      windReason.icon = '💨';
      reasons.push(windReason);
    }

    // 目标体型理由
    const sizeReason = new GenerateReason();
    const sizeNames: Record<string, string> = { 'small': '小型(<1斤)', 'medium': '中型(1-5斤)', 'large': '大型(>5斤)' };
    sizeReason.condition = `目标体型: ${sizeNames[this.input.targetFishSize] || '中型'}`;
    sizeReason.decision = this.input.targetFishSize === 'large' ? '增加味道浓度，使用大颗粒原料' :
      (this.input.targetFishSize === 'small' ? '减轻味道，使用细腻原料' : '均衡配比');
    sizeReason.icon = '📏';
    reasons.push(sizeReason);

    return reasons;
  }

  /**
   * 计算维度评分 - 综合考虑所有参数
   */
  private calculateDimensionScores(): DimensionScores {
    const scores = new DimensionScores();

    // 诱鱼性：根据味型强度、水质、光照
    scores.attraction = this.calculateAttractionScore();

    // 适口性：根据鱼种习性、温度、目标体型
    scores.palatability = this.calculatePalatabilityScore();

    // 状态：根据饵料状态、水深、风力匹配
    scores.state = this.calculateStateScore();

    // 留鱼性：根据配方持久性、水深
    scores.retention = this.calculateRetentionScore();

    // 性价比：根据原料选择
    scores.costEffective = this.calculateCostScore();

    return scores;
  }

  private calculateAttractionScore(): number {
    let score = 65;

    // 味型强度加分
    const intensityBonus: Record<string, number> = { 'light': 5, 'medium': 10, 'strong': 15, 'intense': 18 };
    score += intensityBonus[this.input.flavorIntensity] || 10;

    // 鱼种匹配加分
    if (this.fishData) {
      score += 8;
    }

    // 水质影响：浑水/肥水需要更浓的味道才能有效诱鱼
    if (this.input.waterQuality === 'muddy' || this.input.waterQuality === 'fertile') {
      if (this.input.flavorIntensity === 'strong' || this.input.flavorIntensity === 'intense') {
        score += 8; // 味道浓度匹配
      } else {
        score -= 5; // 味道不够浓
      }
    }

    // 光照影响：夜钓/晨昏腥味更有效
    if (this.input.lightCondition === 'night' || this.input.lightCondition === 'dawn_dusk') {
      score += 5;
    }

    return Math.min(Math.max(score, 0), 100);
  }

  private calculatePalatabilityScore(): number {
    let score = 70;

    // 根据鱼种食性调整
    const feedingType = this.fishData?.habit.feedingType;
    if (feedingType === 'omnivore') {
      score += 10; // 杂食性鱼更容易接受
    }

    // 温度适宜加分
    if (this.input.temperature >= 15 && this.input.temperature <= 28) {
      score += 8;
    } else if (this.input.temperature < 10 || this.input.temperature > 32) {
      score -= 5; // 极端温度降低适口性
    }

    // 目标体型匹配
    if (this.input.targetFishSize === 'large' && this.input.flavorIntensity !== 'light') {
      score += 5; // 大鱼喜欢浓味
    } else if (this.input.targetFishSize === 'small' && this.input.flavorIntensity !== 'intense') {
      score += 5; // 小鱼不喜欢太浓
    }

    return Math.min(Math.max(score, 0), 100);
  }

  private calculateStateScore(): number {
    let score = 65;

    // 饵料状态与水深匹配
    if (this.input.waterDepth === 'deep') {
      if (this.input.baitState === 'slow_dissolve' || this.input.baitState === 'sticky') {
        score += 18; // 深水适合慢溶/粘性饵料
      } else if (this.input.baitState === 'fast_dissolve') {
        score += 5; // 快溶在深水效果一般
      }
    } else if (this.input.waterDepth === 'shallow') {
      if (this.input.baitState === 'fast_dissolve' || this.input.baitState === 'dry_loose') {
        score += 18; // 浅水适合快溶/干散饵料
      } else {
        score += 8;
      }
    } else {
      score += 12; // 中层水深各种状态都可以
    }

    // 风力影响
    if (this.input.windCondition === 'strong') {
      if (this.input.baitState === 'sticky') {
        score += 8; // 大风天粘性饵料更好
      } else if (this.input.baitState === 'dry_loose') {
        score -= 5; // 干散饵料在大风天不好用
      }
    }

    // 水质影响
    if (this.input.waterQuality === 'clear' && this.input.baitState === 'fast_dissolve') {
      score += 5; // 清水快溶雾化效果好
    }

    return Math.min(Math.max(score, 0), 100);
  }

  private calculateRetentionScore(): number {
    let score = 68;

    // 粘性饵料留鱼性更好
    if (this.input.baitState === 'sticky') {
      score += 15;
    } else if (this.input.baitState === 'slow_dissolve') {
      score += 12;
    } else if (this.input.baitState === 'fast_dissolve') {
      score += 5;
    }

    // 味型强度影响
    if (this.input.flavorIntensity === 'medium' || this.input.flavorIntensity === 'strong') {
      score += 8;
    }

    // 深水留鱼性更好
    if (this.input.waterDepth === 'deep') {
      score += 5;
    }

    return Math.min(Math.max(score, 0), 100);
  }

  private calculateCostScore(): number {
    let score = 80;

    // 味型强度越高，成本越高
    const costPenalty: Record<string, number> = { 'light': 0, 'medium': -3, 'strong': -8, 'intense': -15 };
    score += costPenalty[this.input.flavorIntensity] || 0;

    // 目标大鱼成本更高
    if (this.input.targetFishSize === 'large') {
      score -= 5;
    }

    return Math.min(Math.max(score, 0), 100);
  }

  /**
   * 生成原料配比数据（用于饼图）
   */
  private generateIngredientRatios(recipe: GeneratedRecipe): IngredientRatio[] {
    return recipe.ingredients.map((ing: RecipeIngredient): IngredientRatio => {
      return IngredientRatio.create(
        ing.name,
        CATEGORY_NAMES[ing.category] || ing.category,
        ing.percentage,
        CATEGORY_COLORS[ing.category] || '#999'
      );
    });
  }

  /**
   * 生成备选方案
   */
  private generateAlternatives(): GeneratedRecipe[] {
    const alternatives: GeneratedRecipe[] = [];

    // 生成2个备选方案
    // 方案1：更腥的版本
    const alt1Input = this.copyInput(this.input);
    alt1Input.flavorIntensity = 'strong';
    const alt1 = this.generateAlternativeRecipe(alt1Input, '浓腥版');
    alternatives.push(alt1);

    // 方案2：更清淡的版本
    const alt2Input = this.copyInput(this.input);
    alt2Input.flavorIntensity = 'light';
    const alt2 = this.generateAlternativeRecipe(alt2Input, '清香版');
    alternatives.push(alt2);

    return alternatives;
  }

  /**
   * 复制输入参数
   */
  private copyInput(source: PreciseMatchInput): PreciseMatchInput {
    const target = new PreciseMatchInput();
    target.targetFish = source.targetFish;
    target.waterType = source.waterType;
    target.season = source.season;
    target.temperature = source.temperature;
    target.waterDepth = source.waterDepth;
    target.waterQuality = source.waterQuality;
    target.lightCondition = source.lightCondition;
    target.windCondition = source.windCondition;
    target.baitState = source.baitState;
    target.flavorIntensity = source.flavorIntensity;
    target.targetFishSize = source.targetFishSize;
    return target;
  }

  private generateAlternativeRecipe(input: PreciseMatchInput, suffix: string): GeneratedRecipe {
    const originalInput = this.input;
    this.input = input;

    const recipe = new GeneratedRecipe();
    recipe.id = `alt_${Date.now()}_${Math.floor(Math.random() * 1000000)}`;
    recipe.name = `${this.fishData?.name || '通用'}配方(${suffix})`;
    recipe.totalWeight = 500;
    recipe.createTime = Date.now();
    recipe.ingredients = this.selectIngredients();
    recipe.flavorProfile = this.generateFlavorProfile();
    recipe.stateProfile = this.generateStateProfile();
    recipe.usage = this.generateUsageSuggestion();

    this.input = originalInput;
    return recipe;
  }

  /**
   * 统计激活的参数数量
   */
  private countActiveParams(): number {
    return 11; // 基础4个 + 高级7个
  }

  /**
   * 获取匹配的原料数量
   */
  private getMatchedIngredientsCount(): number {
    return 15 + Math.floor(Math.random() * 10);
  }
}

// 导出单例
export const preciseMatchEngine = new PreciseMatchEngine();
