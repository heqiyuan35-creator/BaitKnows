/**
 * 饵知�?- 生成配方结果�?
 * 按设计图重做：Tab导航、配料图标、步骤编号、使用技�?
 */
import { router } from '@kit.ArkUI';
import { ThemeColors } from '../theme/ThemeColors';
import { GeneratedRecipe, RecipeIngredient, GenerateReason, GenerateRecipeInput } from '../common/types/RecipeTypes';
import { generatorHistoryService } from '../services/GeneratorHistoryService';
import { generateSmartRecipe, getNextRecipeVariant, getSmartRecipeEngine, recordRecipeSave } from '../services/engine/SmartRecipeEngine';
import { fetchWeather } from '../services/WeatherService';
import { promptAction } from '@kit.ArkUI';
import { userDataService, CustomRecipeIngredient, RecipeStateProfile, RecipeFlavorProfile } from '../services/UserDataService';

// 步骤信息�?
class StepInfo {
  title: string = '';
  desc: string = '';

  constructor(title: string = '', desc: string = '') {
    this.title = title;
    this.desc = desc;
  }
}

@Entry
@Component
struct GeneratedRecipePage {
  @State recipe: GeneratedRecipe = new GeneratedRecipe();
  @State isFavorite: boolean = false;
  @State isLoaded: boolean = false;
  @State currentTab: number = 0;
  @State isSaved: boolean = false;
  @State showNameDialog: boolean = false;
  @State customRecipeName: string = '';
  @State nameError: string = '';

  private tabTitles: string[] = ['概览', '配料', '步骤'];
  private originalInput: GenerateRecipeInput | null = null;

  aboutToAppear(): void {
    try {
      const params = router.getParams();
      if (params) {
        const p = params as Record<string, Object>;
        if (p.recipe) {
          // 从鱼饵生成器传入的完整配�?
          const data: Record<string, Object> = JSON.parse(p.recipe as string);
          this.recipe = this.parseRecipe(data);
          this.isLoaded = true;
        } else if (p.quickMode) {
          // 快速模式：从首页传入鱼种和水域，自动生�?
          this.quickGenerate(p.fish as string, p.water as string);
          return;
        }
      }
    } catch (err) {
      console.error('Parse recipe failed:', err);
    }
    if (!this.isLoaded) {
      this.isLoaded = true;
    }

    // 保存到生成历�?
    if (this.recipe.id) {
      this.saveToHistory();
    }
  }

  // 快速生成配�?
  private async quickGenerate(fishId: string, waterType: string): Promise<void> {
    try {
      // 获取当前天气温度
      let temperature = 20;
      try {
        const weather = await fetchWeather();
        if (weather.isValid) {
          temperature = Math.round(weather.temperature);
        }
      } catch (e) {
        console.error('Fetch weather failed:', e);
      }

      // 构建输入参数
      const input = new GenerateRecipeInput();
      input.targetFishId = fishId || 'crucian';
      input.waterType = (waterType as 'river' | 'pond' | 'reservoir' | 'wild_pond') || 'pond';
      input.temperature = temperature;
      input.season = getSmartRecipeEngine().getCurrentSeason();
      input.fishDensity = 'medium';
      input.fishActivity = 'normal';
      input.fishingMethod = 'rub';
      input.mode = 'balanced';

      // 使用智能配方引擎生成配方
      const recipe = generateSmartRecipe(input);
      this.recipe = recipe;
      this.isLoaded = true;

      // 保存到历�?
      this.saveToHistory();
    } catch (err) {
      console.error('Quick generate failed:', err);
      this.isLoaded = true;
    }
  }

  private async saveToHistory(): Promise<void> {
    await generatorHistoryService.load();
    await generatorHistoryService.addHistory(this.recipe);
  }

  private parseRecipe(data: Record<string, Object>): GeneratedRecipe {
    const r = new GeneratedRecipe();
    const d = data;
    r.id = d.id as string || '';
    r.name = d.name as string || '智能配方';
    r.totalWeight = d.totalWeight as number || 500;
    r.mode = d.mode as string || 'balanced';
    r.createTime = d.createTime as number || Date.now();

    const ings = d.ingredients as Array<Record<string, Object>>;
    if (ings) {
      for (let i = 0; i < ings.length; i++) {
        const ing = new RecipeIngredient();
        ing.id = ings[i].id as string || '';
        ing.name = ings[i].name as string || '';
        ing.category = ings[i].category as 'main' | 'auxiliary' | 'state' | 'additive';
        ing.percentage = ings[i].percentage as number || 0;
        ing.weight = ings[i].weight as number || 0;
        ing.purpose = ings[i].purpose as string || '';
        r.ingredients.push(ing);
      }
    }

    const fp = d.flavorProfile as Record<string, Object>;
    if (fp) {
      r.flavorProfile.primary = fp.primary as string || '';
      r.flavorProfile.secondary = fp.secondary as string || '';
      r.flavorProfile.intensity = fp.intensity as number || 5;
      r.flavorProfile.suitableTemp = fp.suitableTemp as string || '';
    }

    const sp = d.stateProfile as Record<string, Object>;
    if (sp) {
      r.stateProfile.atomization = sp.atomization as number || 3;
      r.stateProfile.viscosity = sp.viscosity as number || 3;
      r.stateProfile.hookHolding = sp.hookHolding as number || 3;
      r.stateProfile.weight = sp.weight as number || 3;
    }

    const us = d.usage as Record<string, Object>;
    if (us) {
      r.usage.waterRatio = us.waterRatio as string || '1:1';
      r.usage.restTime = us.restTime as string || '5-10分钟';
      r.usage.firstCast = us.firstCast as string || '';
      r.usage.nestSuggestion = us.nestSuggestion as string || '';
    }

    const reasons = d.reasons as Array<Record<string, Object>>;
    if (reasons) {
      for (let i = 0; i < reasons.length; i++) {
        const reason = new GenerateReason();
        reason.condition = reasons[i].condition as string || '';
        reason.decision = reasons[i].decision as string || '';
        reason.icon = reasons[i].icon as string || '';
        r.reasons.push(reason);
      }
    }

    const cond = d.conditions as Record<string, Object>;
    if (cond) {
      r.conditions.targetFishId = cond.targetFishId as string || '';
      r.conditions.waterType = cond.waterType as 'river' | 'pond' | 'reservoir' | 'wild_pond';
      r.conditions.temperature = cond.temperature as number || 20;
      r.conditions.season = cond.season as 'spring' | 'summer' | 'autumn' | 'winter';
    }

    return r;
  }

  build() {
    Stack() {
      Column() {
        this.HeaderBar()

        if (!this.isLoaded) {
          Column() {
            LoadingProgress().width(40).height(40)
            Text('加载�?..').fontSize(14).fontColor(ThemeColors.TEXT_SECONDARY).margin({ top: 12 })
          }.width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
        } else {
          Scroll() {
            Column({ space: 0 }) {
              // 配方头部信息
              this.RecipeHeader()

              // Tab导航
              this.TabNavigation()

              // Tab内容
              if (this.currentTab === 0) {
                this.OverviewContent()
              } else if (this.currentTab === 1) {
                this.IngredientsContent()
              } else {
                this.StepsContent()
              }

              // 底部操作按钮
              this.ActionButtons()
            }
            .width('100%')
            .padding({ bottom: 40 })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#FFFBF5')

      // 命名对话�?
      if (this.showNameDialog) {
        this.NameDialog()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder NameDialog() {
    Column() {
      // 遮罩�?
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#00000066')
        .onClick(() => {
          this.showNameDialog = false;
          this.nameError = '';
        })
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })

    Column({ space: 16 }) {
      Text('保存配方').fontSize(18).fontWeight(FontWeight.Medium).fontColor(ThemeColors.TEXT_PRIMARY)

      Column({ space: 8 }) {
        Text('配方名称').fontSize(14).fontColor(ThemeColors.TEXT_SECONDARY).alignSelf(ItemAlign.Start)
        TextInput({ text: this.customRecipeName, placeholder: '请输入配方名�? })
          .fontSize(15)
          .height(44)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .padding({ left: 12, right: 12 })
          .onChange((value: string) => {
            this.customRecipeName = value;
            this.nameError = '';
          })

        if (this.nameError.length > 0) {
          Text(this.nameError).fontSize(12).fontColor('#F44336').alignSelf(ItemAlign.Start)
        }
      }
      .width('100%')

      Row({ space: 12 }) {
        Button('取消')
          .fontSize(14)
          .fontColor(ThemeColors.TEXT_PRIMARY)
          .backgroundColor('#F5F5F5')
          .borderRadius(20)
          .layoutWeight(1)
          .height(40)
          .onClick(() => {
            this.showNameDialog = false;
            this.nameError = '';
          })

        Button('保存')
          .fontSize(14)
          .fontColor(Color.White)
          .backgroundColor(ThemeColors.PRIMARY)
          .borderRadius(20)
          .layoutWeight(1)
          .height(40)
          .onClick(() => {
            this.confirmSaveRecipe();
          })
      }
      .width('100%')
    }
    .width('85%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .position({ x: '7.5%', y: '35%' })
  }

  @Builder HeaderBar() {
    Row() {
      Row() {
        Text('�?).fontSize(22).fontColor(ThemeColors.TEXT_PRIMARY)
      }
      .width(40)
      .height(40)
      .justifyContent(FlexAlign.Center)
      .onClick(() => router.back())

      Blank()

      Text('配方详情').fontSize(18).fontWeight(FontWeight.Medium).fontColor(ThemeColors.TEXT_PRIMARY)

      Blank()

      Row() {
        Text(this.isFavorite ? '�? : '�?)
          .fontSize(22)
          .fontColor(this.isFavorite ? '#F44336' : ThemeColors.TEXT_PRIMARY)
      }
      .width(40)
      .height(40)
      .justifyContent(FlexAlign.Center)
      .onClick(() => { this.isFavorite = !this.isFavorite; })
    }
    .width('100%')
    .height(56)
    .padding({ left: 8, right: 8 })
    .margin({ top: 44 })
  }

  @Builder RecipeHeader() {
    Column({ space: 12 }) {
      // 配方名称
      Text(this.recipe.name)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeColors.TEXT_PRIMARY)

      // 配方描述
      Text(this.getRecipeDescription())
        .fontSize(14)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .lineHeight(20)

      // 标签行：时间、难度、评�?
      Row({ space: 12 }) {
        this.InfoTagWithImage($r('app.media.time'), `${this.recipe.usage.restTime}`)
        this.InfoTagWithImage($r('app.media.Difficulty'), this.getDifficultyText())
        this.InfoTagWithImage($r('app.media.Twinkle'), '4.8')
      }
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 16, bottom: 20 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder InfoTagWithImage(icon: Resource, text: string) {
    Row({ space: 4 }) {
      Image(icon).width(14).height(14)
      Text(text).fontSize(12).fontColor(ThemeColors.TEXT_SECONDARY)
    }
    .padding({ left: 10, right: 10, top: 6, bottom: 6 })
    .backgroundColor(Color.White)
    .borderRadius(16)
  }

  @Builder TabNavigation() {
    Row({ space: 0 }) {
      ForEach(this.tabTitles, (title: string, index: number) => {
        Row() {
          Text(title)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.currentTab === index ? ThemeColors.PRIMARY : '#999999')
        }
        .layoutWeight(1)
        .height(40)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(this.currentTab === index ? Color.White : Color.Transparent)
        .borderRadius(20)
        .onClick(() => { this.currentTab = index; })
      })
    }
    .width('100%')
    .height(52)
    .padding({ left: 20, right: 20 })
    .backgroundColor(Color.White)
  }

  // ========== 概览Tab ==========
  @Builder OverviewContent() {
    Column({ space: 16 }) {
      // 味型卡片
      this.FlavorCard()

      // 状态特性卡�?
      this.StateCard()

      // 推荐理由
      this.ReasonsCard()
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 16 })
  }

  @Builder FlavorCard() {
    Column({ space: 12 }) {
      Text('味型特点').fontSize(16).fontWeight(FontWeight.Medium).fontColor(ThemeColors.TEXT_PRIMARY)

      Row({ space: 20 }) {
        Column({ space: 4 }) {
          Text('主味�?).fontSize(12).fontColor(ThemeColors.TEXT_MUTED)
          Text(this.recipe.flavorProfile.primary + this.recipe.flavorProfile.secondary)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.PRIMARY_DARK)
        }

        Column({ space: 4 }) {
          Text('浓度').fontSize(12).fontColor(ThemeColors.TEXT_MUTED)
          Row({ space: 2 }) {
            ForEach([1, 2, 3, 4, 5], (i: number) => {
              Row()
                .width(8)
                .height(8)
                .borderRadius(4)
                .backgroundColor(i <= Math.round(this.recipe.flavorProfile.intensity / 2) ? ThemeColors.PRIMARY : '#E5E5E5')
            })
          }
        }

        Column({ space: 4 }) {
          Text('适用水温').fontSize(12).fontColor(ThemeColors.TEXT_MUTED)
          Text(this.recipe.flavorProfile.suitableTemp || '15-25°C')
            .fontSize(14)
            .fontColor(ThemeColors.TEXT_PRIMARY)
        }
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder StateCard() {
    Column({ space: 12 }) {
      Text('状态特�?).fontSize(16).fontWeight(FontWeight.Medium).fontColor(ThemeColors.TEXT_PRIMARY)

      Row() {
        this.StateItem('雾化', this.recipe.stateProfile.atomization)
        this.StateItem('粘度', this.recipe.stateProfile.viscosity)
        this.StateItem('持钩', this.recipe.stateProfile.hookHolding)
        this.StateItem('比重', this.recipe.stateProfile.weight)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder StateItem(label: string, value: number) {
    Column({ space: 6 }) {
      Text(label).fontSize(12).fontColor(ThemeColors.TEXT_MUTED)
      // 进度条样�?
      Stack({ alignContent: Alignment.Start }) {
        Row().width('100%').height(6).borderRadius(3).backgroundColor('#F0F0F0')
        Row().width(`${value * 20}%`).height(6).borderRadius(3).backgroundColor(ThemeColors.PRIMARY)
      }.width('100%')
      Text(`${value}/5`).fontSize(11).fontColor(ThemeColors.TEXT_MUTED)
    }
    .layoutWeight(1)
    .padding({ left: 4, right: 4 })
  }

  @Builder ReasonsCard() {
    Column({ space: 12 }) {
      Text('为什么推�?).fontSize(16).fontWeight(FontWeight.Medium).fontColor(ThemeColors.TEXT_PRIMARY)

      ForEach(this.recipe.reasons, (reason: GenerateReason, index: number) => {
        Row({ space: 12 }) {
          // 编号圆圈
          Row() {
            Text(`${index + 1}`).fontSize(12).fontColor(Color.White)
          }
          .width(24)
          .height(24)
          .borderRadius(12)
          .backgroundColor(ThemeColors.PRIMARY)
          .justifyContent(FlexAlign.Center)

          Column({ space: 2 }) {
            Text(reason.condition).fontSize(14).fontColor(ThemeColors.TEXT_PRIMARY)
            Text(reason.decision).fontSize(13).fontColor(ThemeColors.PRIMARY_DARK)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
        }
        .width('100%')
        .padding(12)
        .backgroundColor('#FFF9F0')
        .borderRadius(8)
      })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  // ========== 配料Tab ==========
  @Builder IngredientsContent() {
    Column({ space: 16 }) {
      // 总量提示
      Row({ space: 8 }) {
        Image($r('app.media.Recipes')).width(16).height(16)
        Text(`总量 ${this.recipe.totalWeight}g`).fontSize(14).fontColor(ThemeColors.TEXT_SECONDARY)
      }
      .width('100%')
      .padding({ left: 4 })

      // 配料列表
      Column({ space: 0 }) {
        ForEach(this.recipe.ingredients, (ing: RecipeIngredient, index: number) => {
          this.IngredientItem(ing, index)
        })
      }
      .width('100%')
      .backgroundColor(Color.White)
      .borderRadius(12)
      .clip(true)
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 16 })
  }

  @Builder IngredientItem(ing: RecipeIngredient, index: number) {
    Row({ space: 12 }) {
      // 配料图标（圆形）
      Row() {
        Text(this.getIngredientIcon(ing.category)).fontSize(20)
      }
      .width(48)
      .height(48)
      .borderRadius(24)
      .backgroundColor(this.getIngredientBgColor(ing.category))
      .justifyContent(FlexAlign.Center)

      // 配料信息
      Column({ space: 4 }) {
        Text(ing.name).fontSize(15).fontColor(ThemeColors.TEXT_PRIMARY)
        Text(ing.purpose || this.getCategoryName(ing.category))
          .fontSize(12)
          .fontColor(ThemeColors.TEXT_MUTED)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 用量
      Column({ space: 2 }) {
        Text(`${ing.weight}g`).fontSize(16).fontWeight(FontWeight.Medium).fontColor(ThemeColors.PRIMARY_DARK)
        Text(`${ing.percentage}%`).fontSize(12).fontColor(ThemeColors.TEXT_MUTED)
      }
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
    .padding(16)
    .border({
      width: { bottom: index < this.recipe.ingredients.length - 1 ? 1 : 0 },
      color: '#F5F5F5'
    })
  }

  // ========== 步骤Tab ==========
  @Builder StepsContent() {
    Column({ space: 16 }) {
      // 使用步骤
      this.UsageStepsCard()

      // 使用技�?
      this.TipsCard()

      // 备注
      this.NotesCard()
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 16 })
  }

  @Builder UsageStepsCard() {
    Column({ space: 16 }) {
      Text('使用步骤').fontSize(16).fontWeight(FontWeight.Medium).fontColor(ThemeColors.TEXT_PRIMARY)

      // 动态生成步�?
      ForEach(this.generateDynamicSteps(), (step: StepInfo, index: number) => {
        this.StepItem(index + 1, step.title, step.desc)
      })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  // 动态生成步�?- 根据原料和状态特性生成不同步�?
  private generateDynamicSteps(): StepInfo[] {
    const steps: StepInfo[] = [];
    const sp = this.recipe.stateProfile;
    const usage = this.recipe.usage;
    const fp = this.recipe.flavorProfile;
    const ings = this.recipe.ingredients;

    // 获取主要原料名称
    const mainIngs = ings.filter((ing: RecipeIngredient) => ing.category === 'main').map((ing: RecipeIngredient) => ing.name);
    const auxIngs = ings.filter((ing: RecipeIngredient) => ing.category === 'auxiliary').map((ing: RecipeIngredient) => ing.name);
    const stateIngs = ings.filter((ing: RecipeIngredient) => ing.category === 'state').map((ing: RecipeIngredient) => ing.name);
    const addIngs = ings.filter((ing: RecipeIngredient) => ing.category === 'additive').map((ing: RecipeIngredient) => ing.name);

    // 步骤1：准备材�?- 列出具体原料
    let prepDesc = `准备${mainIngs.join('�?)}等主料`;
    if (auxIngs.length > 0) {
      prepDesc += `�?{auxIngs.join('�?)}作为辅料`;
    }
    prepDesc += `，总量${this.recipe.totalWeight}g`;
    steps.push(new StepInfo('准备材料', prepDesc));

    // 步骤2：混合干�?- 根据具体原料调整
    let mixDesc = '';
    if (mainIngs.length > 1) {
      mixDesc = `先将${mainIngs[0]}�?{mainIngs.slice(1).join('�?)}混合均匀`;
    } else if (mainIngs.length === 1) {
      mixDesc = `�?{mainIngs[0]}倒入盆中`;
    } else {
      mixDesc = '将所有干料倒入盆中';
    }
    if (auxIngs.length > 0) {
      mixDesc += `，再加入${auxIngs.join('�?)}搅拌`;
    }
    steps.push(new StepInfo('混合干料', mixDesc));

    // 步骤3：加水开�?- 根据味型和状态调�?
    let waterDesc = `�?{usage.waterRatio}比例`;
    if (fp.primary.includes('�?)) {
      waterDesc += '用常温水开饵，';
    } else if (fp.primary.includes('�?)) {
      waterDesc += '用温水开饵效果更佳，';
    } else {
      waterDesc += '加水�?;
    }
    if (sp.atomization >= 4) {
      waterDesc += '五指张开快速搅拌，让饵料充分吸�?;
    } else if (sp.viscosity >= 4) {
      waterDesc += '顺时针慢慢搅拌，避免出丝过多';
    } else if (sp.weight >= 4) {
      waterDesc += '搅拌均匀后适当压实';
    } else {
      waterDesc += '快速搅拌至无干�?;
    }
    steps.push(new StepInfo('加水开�?, waterDesc));

    // 步骤4：添加状态饵 - 如果有的�?
    if (stateIngs.length > 0) {
      let stateDesc = `加入${stateIngs.join('�?)}`;
      if (stateIngs.some((n: string) => n.includes('拉丝'))) {
        stateDesc += '，轻轻翻拌均匀，不要过度打�?;
      } else if (stateIngs.some((n: string) => n.includes('雪花'))) {
        stateDesc += '，增加雾化效�?;
      } else if (stateIngs.some((n: string) => n.includes('�?))) {
        stateDesc += '，增加附钩�?;
      } else {
        stateDesc += '，调整饵料状�?;
      }
      steps.push(new StepInfo('添加状态饵', stateDesc));
    }

    // 步骤5：静置醒�?- 根据状态调�?
    let restDesc = `静置${usage.restTime}`;
    if (sp.viscosity >= 4) {
      restDesc += '，让拉丝粉充分出丝，期间可翻动一�?;
    } else if (sp.atomization >= 4) {
      restDesc += '，保持蓬松状态，不要压实';
    } else if (fp.intensity >= 7) {
      restDesc += '，让味型充分融合';
    } else {
      restDesc += '，让饵料充分吸水';
    }
    steps.push(new StepInfo('静置醒饵', restDesc));

    // 步骤6：添加添加剂 - 如果有的�?
    if (addIngs.length > 0) {
      let addDesc = `最后加�?{addIngs.join('�?)}`;
      if (addIngs.some((n: string) => n.includes('诱食') || n.includes('DMPT'))) {
        addDesc += '，少量多次，边加边搅�?;
      } else if (addIngs.some((n: string) => n.includes('香精') || n.includes('essence'))) {
        addDesc += '，滴入后快速搅匀';
      } else {
        addDesc += '，均匀撒入后轻轻翻�?;
      }
      steps.push(new StepInfo('添加小药', addDesc));
    }

    // 步骤7：打揉成�?- 根据状态特性调�?
    let shapeDesc = '';
    if (sp.hookHolding >= 4 && sp.viscosity >= 4) {
      shapeDesc = '打揉20-30下增加粘性，搓成软硬适中的饵�?;
    } else if (sp.atomization >= 4) {
      shapeDesc = '轻轻收拢成团即可，保持蓬松雾化效�?;
    } else if (sp.weight >= 4) {
      shapeDesc = '用力打揉紧实，增加比重确保快速到�?;
    } else if (sp.viscosity <= 2) {
      shapeDesc = '不需过度打揉，保持散落状�?;
    } else {
      shapeDesc = '根据鱼情适当打揉，调整软硬度';
    }
    steps.push(new StepInfo('打揉成型', shapeDesc));

    return steps;
  }

  @Builder StepItem(num: number, title: string, desc: string) {
    Row({ space: 12 }) {
      // 步骤编号
      Row() {
        Text(`${num}`).fontSize(14).fontWeight(FontWeight.Medium).fontColor(Color.White)
      }
      .width(28)
      .height(28)
      .borderRadius(14)
      .backgroundColor(ThemeColors.PRIMARY)
      .justifyContent(FlexAlign.Center)

      Column({ space: 4 }) {
        Text(title).fontSize(15).fontWeight(FontWeight.Medium).fontColor(ThemeColors.TEXT_PRIMARY)
        Text(desc).fontSize(13).fontColor(ThemeColors.TEXT_SECONDARY).lineHeight(18)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
  }

  @Builder TipsCard() {
    Column({ space: 12 }) {
      Row({ space: 6 }) {
        Image($r('app.media.Twinkles')).width(18).height(18)
        Text('使用技�?).fontSize(16).fontWeight(FontWeight.Medium).fontColor(ThemeColors.TEXT_PRIMARY)
      }

      Column({ space: 8 }) {
        ForEach(this.generateDynamicTips(), (tip: string) => {
          this.TipItem(tip)
        })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFF9F0')
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  // 动态生成使用技�?
  private generateDynamicTips(): string[] {
    const tips: string[] = [];
    const sp = this.recipe.stateProfile;
    const fp = this.recipe.flavorProfile;
    const usage = this.recipe.usage;
    const ings = this.recipe.ingredients;
    const temp = this.recipe.conditions.temperature;
    const water = this.recipe.conditions.waterType;

    // 技�?：首钓建�?- 根据状态和水域
    if (usage.firstCast) {
      tips.push(usage.firstCast);
    } else if (sp.atomization >= 4) {
      tips.push('前几竿用大饵快速抽窝，形成雾化带诱�?);
    } else if (sp.weight >= 4) {
      tips.push('首竿搓大饵找底，确定水深后再调整');
    } else {
      tips.push('前几竿可适当加大饵团，快速诱鱼进�?);
    }

    // 技�?：打窝建�?- 根据水域和原�?
    if (usage.nestSuggestion) {
      tips.push(usage.nestSuggestion);
    } else if (water === 'river') {
      tips.push('野河走水可用酒米打底，散炮带�?);
    } else if (water === 'pond') {
      tips.push('黑坑建议散炮带窝，边钓边�?);
    } else {
      tips.push('可配合散炮或酒米打窝，效果更�?);
    }

    // 技�?：根据味型调�?
    if (fp.primary.includes('�?) && fp.intensity >= 6) {
      tips.push('腥味较重，小杂鱼多时可适当减少用量');
    } else if (fp.primary.includes('�?) && temp > 25) {
      tips.push('高温天气香味挥发快，可适当补充添加�?);
    } else if (fp.primary.includes('�?)) {
      tips.push('酸味饵料适合钓鲢鳙，注意控制雾化节奏');
    }

    // 技�?：根据状态特�?
    if (sp.viscosity >= 4 && sp.hookHolding >= 4) {
      tips.push('饵料粘度高，注意控制饵团大小避免挡口');
    } else if (sp.atomization >= 4 && sp.viscosity <= 2) {
      tips.push('雾化快粘度低，适合快频率抽�?);
    }

    // 技�?：根据温�?
    if (temp < 10) {
      tips.push('低温天气鱼口轻，饵团宜小宜软');
    } else if (temp > 30) {
      tips.push('高温天气鱼躲深水，可尝试钓深或早晚出�?);
    }

    // 确保至少3条技�?
    if (tips.length < 3) {
      tips.push('根据鱼口调整饵料软硬度和大小');
    }

    return tips.slice(0, 4);  // 最多显�?�?
  }

  @Builder TipItem(text: string) {
    Row({ space: 8 }) {
      Text('�?).fontSize(14).fontColor(ThemeColors.PRIMARY_DARK)
      Text(text).fontSize(13).fontColor(ThemeColors.TEXT_SECONDARY).layoutWeight(1)
    }.width('100%')
  }

  @Builder NotesCard() {
    Column({ space: 12 }) {
      Row({ space: 6 }) {
        Image($r('app.media.Temperature')).width(18).height(18)
        Text('备注').fontSize(16).fontWeight(FontWeight.Medium).fontColor(ThemeColors.TEXT_PRIMARY)
      }

      Text(this.getNotesText())
        .fontSize(13)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .lineHeight(20)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder ActionButtons() {
    Row({ space: 12 }) {
      Button('换一�?)
        .fontSize(14)
        .fontColor(ThemeColors.TEXT_PRIMARY)
        .backgroundColor('#F5F5F5')
        .borderRadius(24)
        .layoutWeight(1)
        .height(48)
        .onClick(() => {
          this.regenerateRecipe();
        })

      Button(this.isSaved ? '已保�? : '保存配方')
        .fontSize(14)
        .fontColor(Color.White)
        .backgroundColor(this.isSaved ? '#AAAAAA' : ThemeColors.PRIMARY)
        .borderRadius(24)
        .layoutWeight(1)
        .height(48)
        .onClick(() => {
          if (!this.isSaved) {
            this.showSaveDialog();
          }
        })
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 24 })
  }

  // 换一换：使用智能变体管理器获取不同配�?
  private async regenerateRecipe(): Promise<void> {
    try {
      // 使用智能配方引擎的变体功�?
      const newRecipe = getNextRecipeVariant();

      if (newRecipe !== null) {
        this.recipe = newRecipe;
        this.isSaved = false;

        // 保存到历�?
        this.saveToHistory();

        promptAction.showToast({ message: '已为您换一个配�?, duration: 1500 });
      } else {
        // 如果变体管理器返回null，重新生�?
        let temperature = this.recipe.conditions.temperature || 20;
        try {
          const weather = await fetchWeather();
          if (weather.isValid) {
            temperature = Math.round(weather.temperature);
          }
        } catch (e) {
          console.error('Fetch weather failed:', e);
        }

        const input = new GenerateRecipeInput();
        input.targetFishId = this.recipe.conditions.targetFishId || 'crucian';
        input.waterType = this.recipe.conditions.waterType || 'pond';
        input.temperature = temperature;
        input.season = this.recipe.conditions.season || getSmartRecipeEngine().getCurrentSeason();
        input.fishDensity = this.recipe.conditions.fishDensity || 'medium';
        input.fishActivity = this.recipe.conditions.fishActivity || 'normal';
        input.fishingMethod = this.recipe.conditions.fishingMethod || 'rub';
        input.mode = this.recipe.conditions.mode || 'balanced';

        const recipe = generateSmartRecipe(input);
        this.recipe = recipe;
        this.isSaved = false;

        this.saveToHistory();
        promptAction.showToast({ message: '已为您换一个配�?, duration: 1500 });
      }
    } catch (err) {
      console.error('Regenerate recipe failed:', err);
      promptAction.showToast({ message: '生成失败，请重试', duration: 1500 });
    }
  }

  // 显示保存对话�?
  private async showSaveDialog(): Promise<void> {
    await userDataService.load();
    this.customRecipeName = this.recipe.name;
    this.nameError = '';
    this.showNameDialog = true;
  }

  // 确认保存配方
  private async confirmSaveRecipe(): Promise<void> {
    const name = this.customRecipeName.trim();

    // 验证名称
    if (name.length === 0) {
      this.nameError = '请输入配方名�?;
      return;
    }

    if (name.length > 20) {
      this.nameError = '名称不能超过20个字�?;
      return;
    }

    // 检查重�?
    if (userDataService.isRecipeNameExists(name)) {
      this.nameError = '该名称已存在，请换一�?;
      return;
    }

    // 保存配方
    try {
      // 转换配料格式 - 保存完整信息
      const ingredients: CustomRecipeIngredient[] = [];
      for (let i = 0; i < this.recipe.ingredients.length; i++) {
        const ing = this.recipe.ingredients[i];
        const customIng = new CustomRecipeIngredient();
        customIng.ingredientId = ing.id;
        customIng.name = ing.name;
        customIng.ratio = ing.percentage;
        customIng.weight = ing.weight;
        customIng.purpose = ing.purpose;
        customIng.category = ing.category;
        ingredients.push(customIng);
      }

      // 构建动态步�?
      const dynamicSteps = this.generateDynamicSteps();
      const steps: string[] = [];
      for (let i = 0; i < dynamicSteps.length; i++) {
        steps.push(`${dynamicSteps[i].title}�?{dynamicSteps[i].desc}`);
      }

      // 构建技�?
      const tips = `${this.recipe.usage.firstCast || '前几竿可适当加大饵团，快速诱�?}�?{this.recipe.usage.nestSuggestion || '可配合散炮打窝，效果更佳'}`;

      // 构建状态特�?
      const stateProfile = new RecipeStateProfile();
      stateProfile.atomization = this.recipe.stateProfile.atomization;
      stateProfile.viscosity = this.recipe.stateProfile.viscosity;
      stateProfile.hookHolding = this.recipe.stateProfile.hookHolding;
      stateProfile.weight = this.recipe.stateProfile.weight;

      // 构建味型特�?
      const flavorProfile = new RecipeFlavorProfile();
      flavorProfile.primary = this.recipe.flavorProfile.primary;
      flavorProfile.secondary = this.recipe.flavorProfile.secondary;
      flavorProfile.intensity = this.recipe.flavorProfile.intensity;
      flavorProfile.suitableTemp = this.recipe.flavorProfile.suitableTemp;

      // 保存配方 - 包含完整数据
      await userDataService.addRecipe(
        name,
        [this.recipe.conditions.targetFishId],
        this.recipe.conditions.waterType,
        this.recipe.conditions.season,
        ingredients,
        steps,
        tips,
        stateProfile,
        flavorProfile,
        this.recipe.totalWeight
      );

      // 记录到偏好学习器
      recordRecipeSave(this.recipe);

      this.isSaved = true;
      this.showNameDialog = false;
      promptAction.showToast({ message: '配方已保�?, duration: 1500 });
    } catch (err) {
      console.error('Save recipe failed:', err);
      this.nameError = '保存失败，请重试';
    }
  }

  // 保存配方到用户数�?(旧方法保留兼�?
  private async saveRecipeToUserData(): Promise<void> {
    this.showSaveDialog();
  }

  // ========== 辅助方法 ==========
  private getRecipeDescription(): string {
    const fish = this.getFishName();
    const water = this.getWaterName();
    const season = this.getSeasonName();
    return `专为${season}${water}�?{fish}设计�?{this.recipe.flavorProfile.primary}${this.recipe.flavorProfile.secondary}味型，适合${this.recipe.flavorProfile.suitableTemp || '15-25°C'}水温使用。`;
  }

  private getDifficultyText(): string {
    const count = this.recipe.ingredients.length;
    if (count <= 3) return '简�?;
    if (count <= 5) return '中等';
    return '复杂';
  }

  private getFishName(): string {
    const fishId = this.recipe.conditions.targetFishId;
    if (fishId === 'crucian') return '鲫鱼';
    if (fishId === 'carp') return '鲤鱼';
    if (fishId === 'grass') return '草鱼';
    if (fishId === 'black') return '青鱼';
    if (fishId === 'catfish') return '鲶鱼';
    return '目标�?;
  }

  private getWaterName(): string {
    const waterType = this.recipe.conditions.waterType;
    if (waterType === 'river') return '野河';
    if (waterType === 'pond') return '黑坑';
    if (waterType === 'reservoir') return '水库';
    if (waterType === 'wild_pond') return '野塘';
    return '';
  }

  private getSeasonName(): string {
    const season = this.recipe.conditions.season;
    if (season === 'spring') return '春季';
    if (season === 'summer') return '夏季';
    if (season === 'autumn') return '秋季';
    if (season === 'winter') return '冬季';
    return '';
  }

  private getCategoryName(cat: string): string {
    if (cat === 'main') return '主饵';
    if (cat === 'auxiliary') return '辅饵';
    if (cat === 'state') return '状态饵';
    if (cat === 'additive') return '添加�?;
    return '';
  }

  private getIngredientIcon(cat: string): string {
    if (cat === 'main') return '🌾';
    if (cat === 'auxiliary') return '🥜';
    if (cat === 'state') return '💧';
    if (cat === 'additive') return '�?;
    return '📦';
  }

  private getIngredientBgColor(cat: string): string {
    if (cat === 'main') return '#FFF3E0';
    if (cat === 'auxiliary') return '#E8F5E9';
    if (cat === 'state') return '#E3F2FD';
    if (cat === 'additive') return '#FCE4EC';
    return '#F5F5F5';
  }

  private getNotesText(): string {
    const temp = this.recipe.conditions.temperature;
    const water = this.recipe.conditions.waterType;
    const fp = this.recipe.flavorProfile;
    const sp = this.recipe.stateProfile;
    const ings = this.recipe.ingredients;

    let notes: string[] = [];

    // 温度相关备注
    if (temp < 10) {
      notes.push(`当前气温${temp}°C，水温较低，建议适当增加腥味比例，饵料状态偏软粘，开饵时可用温水。`);
    } else if (temp < 15) {
      notes.push(`当前气温${temp}°C，早晚温差大，建议准备两套饵料，早晚用腥，中午用香。`);
    } else if (temp > 30) {
      notes.push(`当前气温${temp}°C，水温较高，建议清淡为主，可适当加入果酸类添加剂，避免饵料变质。`);
    } else if (temp > 25) {
      notes.push(`当前气温${temp}°C，温度适宜但偏高，注意饵料保鲜，开好的饵料尽快使用。`);
    } else {
      notes.push(`当前气温${temp}°C，温度适宜，按配方正常使用即可。`);
    }

    // 水域相关备注
    if (water === 'river') {
      notes.push('野河环境复杂，注意观察水流方向，选择缓流区作钓�?);
    } else if (water === 'pond') {
      notes.push('黑坑竞争激烈，注意观察周围钓友用饵，适时调整�?);
    } else if (water === 'reservoir') {
      notes.push('水库水面大，建议提前打窝，耐心守钓�?);
    }

    // 味型相关备注
    if (fp.intensity >= 8) {
      notes.push('本配方味型较浓，如遇滑口鱼可适当减少添加剂用量�?);
    } else if (fp.intensity <= 3) {
      notes.push('本配方味型清淡，适合钓滑口鱼或大个体鱼�?);
    }

    // 状态相关备�?
    if (sp.atomization >= 4 && sp.viscosity <= 2) {
      notes.push('雾化较快，适合快频率作钓，注意补窝节奏�?);
    }

    // 原料相关备注
    const hasLiveBait = ings.some((ing: RecipeIngredient) =>
      ing.name.includes('红虫') || ing.name.includes('蚯蚓') || ing.name.includes('活饵'));
    if (hasLiveBait) {
      notes.push('含活饵成分，注意保持新鲜度�?);
    }

    // 通用建议
    notes.push('如遇鱼口不佳，可尝试调整水比或更换添加剂�?);

    return notes.slice(0, 3).join('\n\n');
  }
}
