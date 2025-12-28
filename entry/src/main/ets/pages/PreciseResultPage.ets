/**
 * 精确匹配 - 结果展示�?
 * 展示配方分析结果、图表、详�?
 */
import { router, promptAction } from '@kit.ArkUI';
import { ThemeColors } from '../theme/ThemeColors';
import {
  PreciseMatchInput,
  PreciseMatchResult,
  DimensionScores,
  ParameterWeight,
  AnalysisStep,
  IngredientRatio,
  FEEDBACK_OPTIONS,
  FeedbackOption,
  FeedbackType
} from '../common/types/PreciseMatchTypes';
import { GeneratedRecipe, RecipeIngredient } from '../common/types/RecipeTypes';
import { preciseMatchEngine } from '../services/engine/PreciseMatchEngine';
import { getFishById } from '../data/FishData';
import { userDataService } from '../services/UserDataService';
import { AnalysisAnimation } from '../components/AnalysisAnimation';
import { RecipeService, Recipe, Ingredient } from '../services/RecipeService';

@Entry
@Component
struct PreciseResultPage {
  @State result: PreciseMatchResult = new PreciseMatchResult();
  @State isLoading: boolean = true;
  @State showFeedbackDialog: boolean = false;
  @State selectedFeedbacks: FeedbackType[] = [];
  @State showAnalysisAnimation: boolean = true;
  @State currentStep: number = 0;
  @State fishName: string = '目标�?;
  @State contentOpacity: number = 0;
  @State showIngredientSelect: boolean = false;  // 显示原料选择
  @State excludedIngredients: string[] = [];     // 排除的原料名�?
  @State showOtherReason: boolean = false;       // 显示其他原因提示
  @State isSaved: boolean = false;               // 是否已保存到配方�?

  private input: PreciseMatchInput = new PreciseMatchInput();
  private animationTimer: number = -1;
  private recipeService: RecipeService = RecipeService.getInstance();

  aboutToAppear(): void {
    // 获取传入的参�?
    const params = router.getParams() as Record<string, string>;
    if (params && params.input) {
      try {
        const inputData = JSON.parse(params.input) as PreciseMatchInput;
        // 手动复制属�?
        this.input.targetFish = inputData.targetFish;
        this.input.waterType = inputData.waterType;
        this.input.season = inputData.season;
        this.input.temperature = inputData.temperature;
        this.input.waterDepth = inputData.waterDepth;
        this.input.waterQuality = inputData.waterQuality;
        this.input.lightCondition = inputData.lightCondition;
        this.input.windCondition = inputData.windCondition;
        this.input.baitState = inputData.baitState;
        this.input.flavorIntensity = inputData.flavorIntensity;
        this.input.targetFishSize = inputData.targetFishSize;
        // 获取鱼种名称
        const fishData = getFishById(this.input.targetFish);
        if (fishData) {
          this.fishName = fishData.name;
        }
      } catch (e) {
        console.error('Parse input failed:', e);
      }
    }

    // 开始分析动�?
    this.startAnalysisAnimation();
  }

  aboutToDisappear(): void {
    if (this.animationTimer !== -1) {
      clearInterval(this.animationTimer);
    }
  }

  // 开始分析动�?
  private startAnalysisAnimation(): void {
    this.showAnalysisAnimation = true;
    this.currentStep = 0;
    this.contentOpacity = 0;

    // 模拟分析过程
    this.animationTimer = setInterval(() => {
      this.currentStep++;
      if (this.currentStep >= 5) {
        clearInterval(this.animationTimer);
        this.animationTimer = -1;

        // 执行实际分析
        setTimeout(() => {
          this.result = preciseMatchEngine.analyze(this.input);
          this.showAnalysisAnimation = false;
          this.isLoading = false;

          // 保存到历史记�?
          this.saveToHistory();

          // 内容淡入动画
          animateTo({
            duration: 400,
            curve: Curve.EaseOut
          }, () => {
            this.contentOpacity = 1;
          });
        }, 300);
      }
    }, 400);
  }

  // 返回上一�?
  private onBack(): void {
    router.back();
  }

  // 换一�?
  private onRefresh(): void {
    this.showFeedbackDialog = true;
  }

  // 确认反馈并重新生�?
  private onConfirmFeedback(): void {
    this.showFeedbackDialog = false;
    this.showIngredientSelect = false;
    this.showOtherReason = false;
    this.isLoading = true;

    // 保存反馈记录
    this.saveFeedback();

    setTimeout(() => {
      // 传递排除的原料给引�?
      this.result = preciseMatchEngine.adjustByFeedback(
        this.result,
        this.selectedFeedbacks,
        this.excludedIngredients
      );
      this.selectedFeedbacks = [];
      this.excludedIngredients = [];
      this.isLoading = false;
    }, 500);
  }

  // 保存到历史记�?
  private async saveToHistory(): Promise<void> {
    try {
      const fishData = getFishById(this.input.targetFish);
      const fishName = fishData?.name || this.input.targetFish;
      await userDataService.addPreciseHistory(
        this.result.recipe.name,
        fishName,
        this.result.matchScore,
        JSON.stringify(this.input)
      );
    } catch (e) {
      console.error('Save to history failed:', e);
    }
  }

  // 保存反馈记录
  private async saveFeedback(): Promise<void> {
    try {
      await userDataService.addFeedback(
        this.result.recipe.id,
        this.selectedFeedbacks,
        ''
      );
    } catch (e) {
      console.error('Save feedback failed:', e);
    }
  }

  // 保存配方到配方库
  private saveToRecipeLibrary(): void {
    if (this.isSaved) {
      promptAction.showToast({ message: '配方已保存过�? });
      return;
    }

    try {
      // �?GeneratedRecipe 转换�?Recipe 格式
      const recipe: Recipe = {
        id: `precise_${Date.now()}`,
        name: this.result.recipe.name,
        targetFish: [this.fishName],
        waterTypes: [this.input.waterType || '通用'],
        seasons: [this.input.season || '四季'],
        difficulty: '中等',
        prepTime: '15分钟',
        ingredients: this.result.recipe.ingredients.map((ing: RecipeIngredient): Ingredient => ({
          name: ing.name,
          amount: String(ing.weight),
          unit: 'g'
        })),
        steps: [
          `将所有原料按配比混合`,
          `加入${this.result.recipe.usage.waterRatio}的水`,
          `搅拌均匀�?{this.result.recipe.usage.restTime}`,
          this.result.recipe.usage.firstCast
        ],
        tips: [
          `主味型：${this.result.recipe.flavorProfile.primary}`,
          `辅味型：${this.result.recipe.flavorProfile.secondary}`,
          this.result.recipe.usage.nestSuggestion
        ],
        rating: this.result.matchScore / 20,  // 转换�?分制
        usageCount: 0,
        isGenerated: true,
        createTime: Date.now()
      };

      // 添加到配方库
      this.recipeService.addRecipe(recipe);
      this.isSaved = true;
      promptAction.showToast({ message: '�?已保存到配方�? });
    } catch (e) {
      console.error('Save to recipe library failed:', e);
      promptAction.showToast({ message: '保存失败，请重试' });
    }
  }

  // 切换反馈选项
  private toggleFeedback(type: FeedbackType): void {
    const index = this.selectedFeedbacks.indexOf(type);
    if (index >= 0) {
      this.selectedFeedbacks.splice(index, 1);
    } else {
      this.selectedFeedbacks.push(type);
    }
    // 触发UI更新
    this.selectedFeedbacks = [...this.selectedFeedbacks];
  }

  build() {
    Stack() {
      Column() {
        // 顶部标题�?
        this.TitleBar()

        if (this.showAnalysisAnimation) {
          // 分析动画 - 使用独立组件
          AnalysisAnimation({
            currentStep: this.currentStep,
            fishName: this.fishName
          })
            .layoutWeight(1)
        } else if (this.isLoading) {
          // 加载�?
          Column() {
            LoadingProgress().width(48).height(48).color(ThemeColors.PRIMARY)
            Text('正在生成配方...').fontSize(14).fontColor('#666').margin({ top: 16 })
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          // 结果内容
          Scroll() {
            Column({ space: 20 }) {
              // 匹配度评分卡�?
              this.ScoreCard()

              // 分析图表�?
              this.ChartSection()

              // 配方详情
              this.RecipeDetailCard()

              // 使用建议
              this.UsageSuggestionCard()

              // 备选方�?
              this.AlternativesSection()
            }
            .width('100%')
            .padding({ left: 20, right: 20, bottom: 40 })
            .opacity(this.contentOpacity)
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#FFFBF5')

      // 反馈对话�?
      if (this.showFeedbackDialog) {
        this.FeedbackDialogView()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  TitleBar() {
    Row() {
      Row() {
        Text('�?).fontSize(24).fontColor('#1A1A1A')
      }
      .width(40)
      .height(40)
      .justifyContent(FlexAlign.Center)
      .onClick(() => this.onBack())

      Text('精确匹配结果')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A1A')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      // 换一换按�?
      Row() {
        Text('🔄')
          .fontSize(18)
      }
      .width(40)
      .height(40)
      .justifyContent(FlexAlign.Center)
      .onClick(() => this.onRefresh())
    }
    .width('100%')
    .height(56)
    .padding({ left: 12, right: 12 })
    .margin({ top: 44 })
  }

  @Builder
  ScoreCard() {
    Column({ space: 12 }) {
      Row({ space: 16 }) {
        // 大分�?
        Column() {
          Text(`${this.result.matchScore}`)
            .fontSize(48)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.PRIMARY_DARK)
          Text('/100')
            .fontSize(16)
            .fontColor('#999')
        }

        // 评分说明
        Column({ space: 8 }) {
          Text('匹配度评�?)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1A1A1A')
          Text(this.result.scoreDescription)
            .fontSize(14)
            .fontColor('#666')

          // 评分�?
          Row() {
            Row()
              .width(`${this.result.matchScore}%`)
              .height(8)
              .backgroundColor(ThemeColors.PRIMARY)
              .borderRadius(4)
          }
          .width('100%')
          .height(8)
          .backgroundColor('#F0F0F0')
          .borderRadius(4)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(16)
  }

  @Builder
  ChartSection() {
    // 五维评分卡片
    Column({ space: 12 }) {
      Text('五维能力分析')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A1A')

      Row({ space: 16 }) {
        // 左侧：综合评分环
        Stack() {
          Progress({ value: this.result.matchScore, total: 100, type: ProgressType.Ring })
            .width(90)
            .height(90)
            .color(ThemeColors.PRIMARY)
            .backgroundColor('#F0F0F0')
            .style({ strokeWidth: 10 })

          Column() {
            Text(`${this.result.matchScore}`)
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor(ThemeColors.PRIMARY_DARK)
            Text('综合')
              .fontSize(11)
              .fontColor('#999')
          }
        }
        .width(90)
        .height(90)

        // 右侧：五维数值条
        Column({ space: 8 }) {
          this.DimensionBar('诱鱼�?, this.result.dimensionScores.attraction, '#E6A23C')
          this.DimensionBar('适口�?, this.result.dimensionScores.palatability, '#67C23A')
          this.DimensionBar('状�?, this.result.dimensionScores.state, '#409EFF')
          this.DimensionBar('留鱼�?, this.result.dimensionScores.retention, '#F56C6C')
          this.DimensionBar('性价�?, this.result.dimensionScores.costEffective, '#909399')
        }
        .layoutWeight(1)
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(16)
  }

  @Builder
  DimensionBar(name: string, score: number, color: string) {
    Row() {
      Row()
        .width(8)
        .height(8)
        .borderRadius(4)
        .backgroundColor(color)

      Text(name)
        .fontSize(12)
        .fontColor('#666')
        .margin({ left: 6 })
        .width(42)

      Stack({ alignContent: Alignment.Start }) {
        Row()
          .width('100%')
          .height(10)
          .backgroundColor('#F5F5F5')
          .borderRadius(5)

        Row()
          .width(`${score}%`)
          .height(10)
          .backgroundColor(color)
          .borderRadius(5)
      }
      .layoutWeight(1)
      .margin({ left: 6, right: 6 })

      Text(`${score}`)
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .fontColor(color)
        .width(24)
        .textAlign(TextAlign.End)
    }
    .width('100%')
  }

  @Builder
  RecipeDetailCard() {
    Column({ space: 16 }) {
      // 配方名称和保存按�?
      Row() {
        Text(this.result.recipe.name)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
          .layoutWeight(1)
        
        // 保存到配方库按钮
        Row({ space: 4 }) {
          Text(this.isSaved ? '�? : '💾')
            .fontSize(14)
          Text(this.isSaved ? '已保�? : '保存')
            .fontSize(12)
            .fontColor(this.isSaved ? '#67C23A' : ThemeColors.PRIMARY)
        }
        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
        .backgroundColor(this.isSaved ? '#F0F9EB' : '#FFF5E6')
        .borderRadius(14)
        .onClick(() => this.saveToRecipeLibrary())
        
        Text(`${this.result.recipe.totalWeight}g`)
          .fontSize(14)
          .fontColor('#999')
          .margin({ left: 8 })
      }
      .width('100%')

      // 原料列表
      Column({ space: 8 }) {
        Text('原料配比')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#666')

        ForEach(this.result.recipe.ingredients, (ing: RecipeIngredient) => {
          Row() {
            Text(ing.name)
              .fontSize(14)
              .fontColor('#1A1A1A')
              .layoutWeight(1)
            Text(`${ing.weight}g`)
              .fontSize(14)
              .fontColor('#666')
              .width(50)
            Text(`${ing.percentage}%`)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(ThemeColors.PRIMARY_DARK)
              .width(40)
              .textAlign(TextAlign.End)
          }
          .width('100%')
          .padding({ top: 8, bottom: 8 })
          .borderWidth({ bottom: 1 })
          .borderColor('#F0F0F0')
        })
      }
      .width('100%')

      // 味型说明
      Row({ space: 16 }) {
        Column({ space: 4 }) {
          Text('主味�?).fontSize(12).fontColor('#999')
          Text(this.result.recipe.flavorProfile.primary)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1A1A1A')
        }

        Column({ space: 4 }) {
          Text('辅味�?).fontSize(12).fontColor('#999')
          Text(this.result.recipe.flavorProfile.secondary)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1A1A1A')
        }

        Column({ space: 4 }) {
          Text('浓度').fontSize(12).fontColor('#999')
          Text(`${this.result.recipe.flavorProfile.intensity}/10`)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(ThemeColors.PRIMARY_DARK)
        }
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(16)
  }

  @Builder
  UsageSuggestionCard() {
    Column({ space: 12 }) {
      Text('使用建议')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A1A')

      Row({ space: 24 }) {
        Column({ space: 4 }) {
          Text('水比').fontSize(12).fontColor('#999')
          Text(this.result.recipe.usage.waterRatio)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1A1A1A')
        }

        Column({ space: 4 }) {
          Text('醒饵时间').fontSize(12).fontColor('#999')
          Text(this.result.recipe.usage.restTime)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1A1A1A')
        }
      }
      .width('100%')

      Text(this.result.recipe.usage.firstCast)
        .fontSize(14)
        .fontColor('#666')
        .lineHeight(22)

      Text(this.result.recipe.usage.nestSuggestion)
        .fontSize(14)
        .fontColor('#666')
        .lineHeight(22)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  AlternativesSection() {
    Column({ space: 12 }) {
      Text('备选方�?)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A1A')

      Scroll() {
        Row({ space: 12 }) {
          ForEach(this.result.alternatives, (alt: GeneratedRecipe) => {
            Column({ space: 8 }) {
              Text(alt.name)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#1A1A1A')

              Text(`${alt.flavorProfile.primary} · ${alt.flavorProfile.secondary}`)
                .fontSize(12)
                .fontColor('#666')

              Text(`浓度 ${alt.flavorProfile.intensity}/10`)
                .fontSize(12)
                .fontColor(ThemeColors.PRIMARY_DARK)
            }
            .width(140)
            .padding(12)
            .backgroundColor('#FFF5E6')
            .borderRadius(12)
            .alignItems(HorizontalAlign.Start)
          })
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  FeedbackDialogView() {
    Column() {
      // 遮罩
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.5)')
        .onClick(() => {
          this.showFeedbackDialog = false;
          this.showIngredientSelect = false;
          this.showOtherReason = false;
        })
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })

    // 对话�?
    Scroll() {
      Column({ space: 16 }) {
        Text('不满意的地方')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')

        // 选项1：味型不喜欢
        this.FeedbackOptionItem('👃', '味型不喜�?, 'flavor_dislike')

        // 选项2：提香（想要更香�?
        this.FeedbackOptionItem('🌸', '想要提香', 'want_more_fragrant')

        // 选项3：原料难获取
        Column({ space: 8 }) {
          Row({ space: 12 }) {
            Text('🛒').fontSize(20)
            Text('原料难获�?)
              .fontSize(15)
              .fontColor('#1A1A1A')
              .layoutWeight(1)
            Text(this.showIngredientSelect ? '�? : '�?)
              .fontSize(12)
              .fontColor('#999')
          }
          .width('100%')
          .padding(12)
          .backgroundColor(this.selectedFeedbacks.includes('ingredient_hard') ? '#FFF5E6' : '#F5F5F5')
          .borderRadius(8)
          .onClick(() => {
            this.showIngredientSelect = !this.showIngredientSelect;
            this.showOtherReason = false;
            if (this.showIngredientSelect) {
              this.toggleFeedback('ingredient_hard');
            }
          })

          // 原料列表（展开时显示）
          if (this.showIngredientSelect) {
            Column({ space: 8 }) {
              Text('选择难买到的原料�?)
                .fontSize(13)
                .fontColor('#666')
                .margin({ bottom: 4 })

              ForEach(this.result.recipe.ingredients, (ing: RecipeIngredient) => {
                Row({ space: 8 }) {
                  Checkbox()
                    .select(this.excludedIngredients.includes(ing.name))
                    .selectedColor(ThemeColors.PRIMARY)
                    .onChange((checked: boolean) => {
                      if (checked) {
                        this.excludedIngredients.push(ing.name);
                      } else {
                        const idx = this.excludedIngredients.indexOf(ing.name);
                        if (idx >= 0) {
                          this.excludedIngredients.splice(idx, 1);
                        }
                      }
                      this.excludedIngredients = [...this.excludedIngredients];
                    })

                  Text(ing.name)
                    .fontSize(14)
                    .fontColor('#1A1A1A')
                    .layoutWeight(1)

                  Text(`${ing.weight}g`)
                    .fontSize(13)
                    .fontColor('#999')
                }
                .width('100%')
                .padding({ left: 8, right: 8, top: 6, bottom: 6 })
              })
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#FAFAFA')
            .borderRadius(8)
          }
        }
        .width('100%')

        // 选项4：其他原�?
        Column({ space: 8 }) {
          Row({ space: 12 }) {
            Text('💬').fontSize(20)
            Text('其他原因')
              .fontSize(15)
              .fontColor('#1A1A1A')
              .layoutWeight(1)
            Text(this.showOtherReason ? '�? : '�?)
              .fontSize(12)
              .fontColor('#999')
          }
          .width('100%')
          .padding(12)
          .backgroundColor(this.selectedFeedbacks.includes('other') ? '#FFF5E6' : '#F5F5F5')
          .borderRadius(8)
          .onClick(() => {
            this.showOtherReason = !this.showOtherReason;
            this.showIngredientSelect = false;
            if (this.showOtherReason) {
              this.toggleFeedback('other');
            }
          })

          // 邮箱提示（展开时显示）
          if (this.showOtherReason) {
            Column({ space: 8 }) {
              Text('如有其他问题，请联系�?)
                .fontSize(13)
                .fontColor('#666')

              Row({ space: 8 }) {
                Text('📧')
                  .fontSize(16)
                Text('2770113524@qq.com')
                  .fontSize(14)
                  .fontColor(ThemeColors.PRIMARY_DARK)
                  .fontWeight(FontWeight.Medium)
              }

              Text('确认后将直接为您更换配方')
                .fontSize(12)
                .fontColor('#999')
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#FAFAFA')
            .borderRadius(8)
            .alignItems(HorizontalAlign.Start)
          }
        }
        .width('100%')

        // 按钮
        Row({ space: 12 }) {
          Button('取消')
            .fontSize(15)
            .fontColor('#666')
            .backgroundColor('#F5F5F5')
            .layoutWeight(1)
            .height(44)
            .onClick(() => {
              this.showFeedbackDialog = false;
              this.showIngredientSelect = false;
              this.showOtherReason = false;
              this.selectedFeedbacks = [];
              this.excludedIngredients = [];
            })

          Button('重新生成')
            .fontSize(15)
            .fontColor(Color.White)
            .backgroundColor(ThemeColors.PRIMARY)
            .layoutWeight(1)
            .height(44)
            .enabled(this.selectedFeedbacks.length > 0 || this.excludedIngredients.length > 0)
            .onClick(() => this.onConfirmFeedback())
        }
        .width('100%')
      }
      .width('100%')
      .padding(20)
    }
    .width('90%')
    .constraintSize({ maxHeight: '70%' })
    .backgroundColor(Color.White)
    .borderRadius(16)
    .position({ x: '5%', y: '15%' })
  }

  @Builder
  FeedbackOptionItem(icon: string, label: string, type: FeedbackType) {
    Row({ space: 12 }) {
      Text(icon).fontSize(20)
      Text(label)
        .fontSize(15)
        .fontColor('#1A1A1A')
        .layoutWeight(1)

      if (this.selectedFeedbacks.includes(type)) {
        Text('�?)
          .fontSize(16)
          .fontColor(ThemeColors.PRIMARY_DARK)
      }
    }
    .width('100%')
    .padding(12)
    .backgroundColor(this.selectedFeedbacks.includes(type) ? '#FFF5E6' : '#F5F5F5')
    .borderRadius(8)
    .onClick(() => {
      this.toggleFeedback(type);
      this.showIngredientSelect = false;
      this.showOtherReason = false;
    })
  }
}
