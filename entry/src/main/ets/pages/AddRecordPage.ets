/**
 * 饵知�?- 添加渔获记录�?
 * 记录钓鱼成果
 */
import { ThemeColors } from '../theme/ThemeColors';
import { ThemeConstants } from '../theme/ThemeConstants';
import { Router, RouteParams } from '../router/Router';
import { FishingRecord } from '../common/types/UserTypes';
import { fishingRecordService } from '../services/FishingRecordService';
import { userDataService, CustomRecipe } from '../services/UserDataService';
import { storageService } from '../services/StorageService';
import { promptAction } from '@kit.ArkUI';
import { picker } from '@kit.CoreFileKit';
import { fileIo } from '@kit.CoreFileKit';
import { speechRecognizer } from '@kit.CoreSpeechKit';
import { abilityAccessCtrl, Permissions, common } from '@kit.AbilityKit';

// 预设配方简要信息（用于配方选择�?
class PresetRecipeInfo {
  id: string = '';
  name: string = '';
  targetFish: string[] = [];

  constructor(id: string, name: string, fish: string[]) {
    this.id = id;
    this.name = name;
    this.targetFish = fish;
  }
}

// 预设配方数据库（简化版，用于配方选择�?
const PRESET_RECIPES: Map<string, PresetRecipeInfo> = new Map([
  // 池塘
  ['r_001', new PresetRecipeInfo('r_001', '池塘鲫鱼散炮', ['鲫鱼'])],
  ['r_002', new PresetRecipeInfo('r_002', '黑坑鲤鱼颗粒', ['鲤鱼'])],
  ['r_003', new PresetRecipeInfo('r_003', '池塘草鱼青草�?, ['草鱼'])],
  ['r_004', new PresetRecipeInfo('r_004', '池塘鳙鱼酸臭�?, ['鳙鱼'])],
  ['r_005', new PresetRecipeInfo('r_005', '池塘鲢鱼酸饵', ['鲢鱼'])],
  ['r_006', new PresetRecipeInfo('r_006', '南方罗非专用�?, ['罗非�?])],
  ['r_007', new PresetRecipeInfo('r_007', '黑坑叉尾专用�?, ['斑点叉尾�?])],
  ['r_008', new PresetRecipeInfo('r_008', '池塘鲶鱼腥饵', ['鲶鱼'])],
  // 河流
  ['r_101', new PresetRecipeInfo('r_101', '野河鲫鱼蚯蚓伴侣', ['鲫鱼'])],
  ['r_102', new PresetRecipeInfo('r_102', '江河鲤鱼玉米�?, ['鲤鱼'])],
  ['r_103', new PresetRecipeInfo('r_103', '河流草鱼嫩草�?, ['草鱼'])],
  ['r_105', new PresetRecipeInfo('r_105', '河流黄颡鱼饵', ['黄颡�?])],
  ['r_106', new PresetRecipeInfo('r_106', '河流鳊鱼素饵', ['鳊鱼'])],
  ['r_107', new PresetRecipeInfo('r_107', '河流翘嘴路亚�?, ['翘嘴'])],
  // 水库
  ['r_201', new PresetRecipeInfo('r_201', '水库大鲤守钓�?, ['鲤鱼'])],
  ['r_202', new PresetRecipeInfo('r_202', '水库草鱼浮钓�?, ['草鱼'])],
  ['r_205', new PresetRecipeInfo('r_205', '水库青鱼螺蛳�?, ['青鱼'])],
  ['r_206', new PresetRecipeInfo('r_206', '水库鳜鱼活饵', ['鳜鱼'])],
  ['r_207', new PresetRecipeInfo('r_207', '水库武昌鱼素�?, ['武昌�?])],
  ['r_210', new PresetRecipeInfo('r_210', '南方鲮鱼专用�?, ['鲮鱼'])],
  // 湖泊
  ['r_301', new PresetRecipeInfo('r_301', '湖泊鲫鱼传统�?, ['鲫鱼'])],
  ['r_302', new PresetRecipeInfo('r_302', '湖泊鲤鱼爆炸�?, ['鲤鱼'])],
  ['r_304', new PresetRecipeInfo('r_304', '湖泊鳜鱼活饵', ['鳜鱼'])],
  ['r_305', new PresetRecipeInfo('r_305', '湖泊青鱼螺蛳�?, ['青鱼'])],
  ['r_306', new PresetRecipeInfo('r_306', '湖泊黑鱼雷蛙', ['黑鱼'])],
  ['r_315', new PresetRecipeInfo('r_315', '湖泊鳊鱼素饵', ['鳊鱼'])]
]);

// 存储�?
const STORAGE_LAST_LOCATION = 'last_fishing_location';
const STORAGE_LAST_WEATHER = 'last_fishing_weather';

// 鱼种选项
interface FishOption {
  name: string;
  icon: Resource;
}

// 配方选项
interface RecipeOption {
  id: string;
  name: string;
  targetFish: string;
  isUserRecipe: boolean;
  isFavorite: boolean;
}

@Entry
@Component
struct AddRecordPage {
  @State selectedDate: string = '';
  @State location: string = '';
  @State selectedFishList: string[] = [];  // 改为数组支持多�?
  @State weight: string = '';
  @State count: string = '1';
  @State selectedRecipeId: string = '';
  @State selectedRecipe: string = '';
  @State weather: string = '晴朗';
  @State notes: string = '';
  @State isSaving: boolean = false;
  @State hasSaved: boolean = false;  // 是否已保存过，防止重复保�?
  @State showRecipeSelector: boolean = false;
  @State recipeOptions: RecipeOption[] = [];
  @State avgWeight: string = '';  // 平均单尾重量提示
  @State photos: string[] = [];   // 渔获图片
  @State isRecording: boolean = false;  // 是否正在录音
  @State recordingText: string = '';    // 实时识别文字
  @State isAsrInitializing: boolean = false;  // ASR引擎初始化中
  private asrEngine: speechRecognizer.SpeechRecognitionEngine | null = null;
  private asrSessionId: string = '';    // 语音识别会话ID

  private fishOptions: FishOption[] = [
    { name: '鲤鱼', icon: $r('app.media.Carp') },
    { name: '草鱼', icon: $r('app.media.Grass_carp') },
    { name: '鲫鱼', icon: $r('app.media.Crucian_carp') },
    { name: '青鱼', icon: $r('app.media.Black_carp') },
    { name: '鲶鱼', icon: $r('app.media.Catfish') },
    { name: '鲢鱼', icon: $r('app.media.Silvercarp') },
    { name: '鳙鱼', icon: $r('app.media.Bigheadcarp') },
    { name: '黑鱼', icon: $r('app.media.Snakehead_fish') },
    { name: '其他', icon: $r('app.media.Fish') }
  ];

  private weatherOptions: string[] = ['晴朗', '多云', '阴天', '小雨', '大风'];

  // 切换鱼种选择
  private toggleFishSelection(fishName: string): void {
    const index = this.selectedFishList.indexOf(fishName);
    if (index >= 0) {
      this.selectedFishList = this.selectedFishList.filter((f: string) => f !== fishName);
    } else {
      this.selectedFishList = [...this.selectedFishList, fishName];
    }
  }

  // 检查鱼种是否已选中
  private isFishSelected(fishName: string): boolean {
    return this.selectedFishList.includes(fishName);
  }

  aboutToAppear(): void {
    // 默认今天日期
    const today = new Date();
    const year = today.getFullYear();
    const month = (today.getMonth() + 1).toString().padStart(2, '0');
    const day = today.getDate().toString().padStart(2, '0');
    this.selectedDate = `${year}-${month}-${day}`;

    // 加载上次使用的钓点和天气
    this.loadLastSettings();

    // 加载配方选项
    this.loadRecipeOptions();
  }

  private async loadLastSettings(): Promise<void> {
    const lastLocation = await storageService.load<string>(STORAGE_LAST_LOCATION, '');
    const lastWeather = await storageService.load<string>(STORAGE_LAST_WEATHER, '晴朗');

    if (lastLocation) {
      this.location = lastLocation;
    }
    if (lastWeather) {
      this.weather = lastWeather;
    }
  }

  private async saveLastSettings(): Promise<void> {
    if (this.location.trim()) {
      await storageService.save(STORAGE_LAST_LOCATION, this.location.trim());
    }
    await storageService.save(STORAGE_LAST_WEATHER, this.weather);
  }

  // 计算平均单尾重量
  private calculateAvgWeight(): void {
    const w = parseFloat(this.weight) || 0;
    const c = parseInt(this.count) || 0;
    if (w > 0 && c > 0) {
      const avg = Math.round((w / c) * 100) / 100;
      this.avgWeight = `平均单尾: ${avg} kg`;
    } else {
      this.avgWeight = '';
    }
  }

  private async loadRecipeOptions(): Promise<void> {
    await userDataService.load();

    // 获取收藏的配方ID
    const favoriteIds = userDataService.getFavoriteRecipes();

    // 获取用户自定义配�?
    const userRecipes = userDataService.getCustomRecipes();

    const options: RecipeOption[] = [];

    // 添加所有预设配�?
    PRESET_RECIPES.forEach((preset: PresetRecipeInfo, id: string) => {
      const isFavorite = favoriteIds.includes(id);
      const opt: RecipeOption = {
        id: preset.id,
        name: preset.name,
        targetFish: preset.targetFish.join('�?),
        isUserRecipe: false,
        isFavorite: isFavorite
      };
      options.push(opt);
    });

    // 添加用户自定义配�?
    for (const ur of userRecipes) {
      const opt: RecipeOption = {
        id: ur.id,
        name: ur.name,
        targetFish: ur.targetFish.join('�?),
        isUserRecipe: true,
        isFavorite: true
      };
      options.push(opt);
    }

    this.recipeOptions = options;
  }

  build() {
    Column() {
      this.HeaderBar()

      Scroll() {
        Column({ space: ThemeConstants.SPACE_MD }) {
          // 日期选择
          this.FormItem('📅 日期', this.selectedDate)

          // 钓点位置
          this.InputItem('📍 钓点位置', '请输入钓点名�?, this.location, (value: string) => {
            this.location = value;
          })

          // 天气选择
          this.WeatherSelector()

          // 鱼种选择
          this.FishSelector()

          // 重量输入
          this.InputItem('⚖️ 总重�?(kg)', '请输入重�?, this.weight, (value: string) => {
            this.weight = value;
            this.calculateAvgWeight();
          })

          // 数量输入
          Column({ space: 8 }) {
            this.InputItem('🔢 数量 (�?', '请输入数�?, this.count, (value: string) => {
              this.count = value;
              this.calculateAvgWeight();
            })

            // 平均单尾重量提示
            if (this.avgWeight) {
              Text(this.avgWeight)
                .fontSize(ThemeConstants.FONT_SIZE_XS)
                .fontColor(ThemeColors.PRIMARY_DARK)
                .width('100%')
                .textAlign(TextAlign.End)
            }
          }

          // 使用配方
          this.RecipeSelector()

          // 渔获图片
          this.PhotoSelector()

          // 备注
          this.NotesInput()

          // 保存按钮
          this.SaveButton()
        }
        .padding({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD, bottom: 40 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      // 配方选择弹窗
      if (this.showRecipeSelector) {
        this.RecipeSelectorDialog()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeColors.BG_PRIMARY)
  }

  @Builder
  HeaderBar() {
    Column() {
      // 状态栏占位
      Row()
        .width('100%')
        .height(36)

      Row() {
        Image($r('app.media.Left'))
          .width(24)
          .height(24)
          .fillColor(ThemeColors.TEXT_PRIMARY)
          .onClick(() => Router.back())

        Blank()

        Text('添加记录')
          .fontSize(ThemeConstants.FONT_SIZE_LG)
          .fontWeight(FontWeight.Medium)
          .fontColor(ThemeColors.TEXT_PRIMARY)

        Blank()

        Row().width(24)
      }
      .width('100%')
      .height(48)
      .padding({ left: 16, right: 16 })
    }
    .width('100%')
  }


  @Builder
  FormItem(label: string, value: string) {
    Column({ space: 8 }) {
      Text(label)
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .width('100%')

      Row() {
        Text(value)
          .fontSize(ThemeConstants.FONT_SIZE_BASE)
          .fontColor(ThemeColors.TEXT_PRIMARY)
        Blank()
        Text('>')
          .fontSize(ThemeConstants.FONT_SIZE_MD)
          .fontColor(ThemeColors.TEXT_MUTED)
      }
      .width('100%')
      .height(48)
      .padding({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD })
      .backgroundColor(ThemeColors.BG_CARD)
      .borderRadius(ThemeConstants.RADIUS_SM)
    }
  }

  @Builder
  InputItem(label: string, placeholder: string, value: string, onChange: (value: string) => void) {
    Column({ space: 8 }) {
      Text(label)
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .width('100%')

      TextInput({ placeholder: placeholder, text: value })
        .fontSize(ThemeConstants.FONT_SIZE_BASE)
        .fontColor(ThemeColors.TEXT_PRIMARY)
        .placeholderColor(ThemeColors.TEXT_HINT)
        .backgroundColor(ThemeColors.BG_CARD)
        .borderRadius(ThemeConstants.RADIUS_SM)
        .height(50)
        .padding({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD })
        .shadow({ radius: 4, color: 'rgba(0,0,0,0.04)', offsetY: 1 })
        .onChange(onChange)
    }
  }

  @Builder
  WeatherSelector() {
    Column({ space: 8 }) {
      Text('🌤�?天气')
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .width('100%')

      Scroll() {
        Row({ space: 8 }) {
          ForEach(this.weatherOptions, (option: string) => {
            Column({ space: 4 }) {
              Text(this.getWeatherIcon(option))
                .fontSize(20)
              Text(option)
                .fontSize(ThemeConstants.FONT_SIZE_XS)
                .fontColor(this.weather === option ? ThemeColors.TEXT_PRIMARY : ThemeColors.TEXT_SECONDARY)
            }
            .width(60)
            .padding({ top: 10, bottom: 10 })
            .backgroundColor(this.weather === option ? ThemeColors.PRIMARY : ThemeColors.BG_CARD)
            .borderRadius(ThemeConstants.RADIUS_SM)
            .shadow(this.weather === option ? { radius: 4, color: 'rgba(232,168,73,0.3)', offsetY: 2 } : undefined)
            .onClick(() => {
              this.weather = option;
            })
          })
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
    }
  }

  private getWeatherIcon(weather: string): string {
    const icons: Record<string, string> = {
      '晴朗': '☀�?,
      '多云': '�?,
      '阴天': '☁️',
      '小雨': '🌧�?,
      '大风': '💨'
    };
    return icons[weather] || '🌤�?;
  }

  @Builder
  FishSelector() {
    Column({ space: 8 }) {
      Row() {
        Text('🐟 鱼种')
          .fontSize(ThemeConstants.FONT_SIZE_SM)
          .fontColor(ThemeColors.TEXT_SECONDARY)
        
        if (this.selectedFishList.length > 0) {
          Text(`（已�?{this.selectedFishList.length}种）`)
            .fontSize(ThemeConstants.FONT_SIZE_XS)
            .fontColor(ThemeColors.PRIMARY_DARK)
            .margin({ left: 4 })
        }
      }
      .width('100%')

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.fishOptions, (option: FishOption) => {
          Stack() {
            Column({ space: 4 }) {
              Image(option.icon)
                .width(28)
                .height(28)
                .objectFit(ImageFit.Contain)
              Text(option.name)
                .fontSize(ThemeConstants.FONT_SIZE_XS)
                .fontColor(this.isFishSelected(option.name) ? ThemeColors.TEXT_PRIMARY : ThemeColors.TEXT_SECONDARY)
            }
            .width(64)
            .padding({ top: 8, bottom: 8 })
            .backgroundColor(this.isFishSelected(option.name) ? ThemeColors.PRIMARY : ThemeColors.BG_CARD)
            .borderRadius(ThemeConstants.RADIUS_SM)
            .shadow(this.isFishSelected(option.name) ? { radius: 4, color: 'rgba(232,168,73,0.3)', offsetY: 2 } : undefined)

            // 选中标记
            if (this.isFishSelected(option.name)) {
              Text('�?)
                .fontSize(10)
                .fontColor(Color.White)
                .backgroundColor(ThemeColors.SUCCESS)
                .borderRadius(8)
                .width(16)
                .height(16)
                .textAlign(TextAlign.Center)
                .position({ x: 48, y: 0 })
            }
          }
          .margin({ right: 8, bottom: 8 })
          .onClick(() => {
            this.toggleFishSelection(option.name);
          })
        })
      }
      .width('100%')
    }
  }

  @Builder
  PhotoSelector() {
    Column({ space: 8 }) {
      Text('📷 渔获图片 (可�?')
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .width('100%')

      Scroll() {
        Row({ space: 8 }) {
          // 已选图�?
          ForEach(this.photos, (photo: string, index: number) => {
            Stack() {
              Image(photo)
                .width(80)
                .height(80)
                .objectFit(ImageFit.Cover)
                .borderRadius(ThemeConstants.RADIUS_SM)

              // 删除按钮
              Text('×')
                .fontSize(14)
                .fontColor(Color.White)
                .backgroundColor('rgba(0,0,0,0.5)')
                .borderRadius(10)
                .width(20)
                .height(20)
                .textAlign(TextAlign.Center)
                .position({ x: 56, y: 4 })
                .onClick(() => {
                  this.photos = this.photos.filter((_: string, i: number) => i !== index);
                })
            }
            .width(80)
            .height(80)
          }, (photo: string, index: number) => `photo_${index}_${photo}`)

          // 添加按钮（最�?张）
          if (this.photos.length < 3) {
            Column() {
              Text('📷')
                .fontSize(24)
              Text('添加图片')
                .fontSize(ThemeConstants.FONT_SIZE_XS)
                .fontColor(ThemeColors.TEXT_SECONDARY)
                .margin({ top: 4 })
            }
            .width(80)
            .height(80)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(ThemeColors.BG_CARD)
            .borderRadius(ThemeConstants.RADIUS_SM)
            .border({ width: 1, color: ThemeColors.TEXT_MUTED, style: BorderStyle.Dashed })
            .onClick(() => {
              this.selectPhoto();
            })
          }
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
    }
  }

  // 选择图片
  private async selectPhoto(): Promise<void> {
    try {
      const photoPicker = new picker.PhotoViewPicker();
      const result = await photoPicker.select({
        MIMEType: picker.PhotoViewMIMETypes.IMAGE_TYPE,
        maxSelectNumber: 3 - this.photos.length
      });

      if (result.photoUris && result.photoUris.length > 0) {
        this.photos = [...this.photos, ...result.photoUris];
      }
    } catch (error) {
      console.error('选择图片失败:', error);
      promptAction.showToast({ message: '选择图片失败' });
    }
  }

  @Builder
  NotesInput() {
    Column({ space: 8 }) {
      Row() {
        Text('📝 备注')
          .fontSize(ThemeConstants.FONT_SIZE_SM)
          .fontColor(ThemeColors.TEXT_SECONDARY)

        Blank()

        // 语音输入按钮
        Row({ space: 4 }) {
          if (this.isAsrInitializing) {
            LoadingProgress()
              .width(14)
              .height(14)
              .color(ThemeColors.PRIMARY)
          } else {
            Text(this.isRecording ? '🔴' : '🎤')
              .fontSize(16)
          }
          Text(this.isAsrInitializing ? '初始�?..' : (this.isRecording ? '录音�?..' : '语音输入'))
            .fontSize(ThemeConstants.FONT_SIZE_XS)
            .fontColor(this.isRecording ? ThemeColors.ERROR : ThemeColors.PRIMARY)
        }
        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        .backgroundColor(this.isRecording ? 'rgba(255,77,79,0.1)' : ThemeColors.PRIMARY_LIGHT)
        .borderRadius(ThemeConstants.RADIUS_FULL)
        .enabled(!this.isAsrInitializing)
        .opacity(this.isAsrInitializing ? 0.6 : 1)
        .onClick(() => {
          if (this.isRecording) {
            this.stopVoiceInput();
          } else {
            this.startVoiceInput();
          }
        })
      }
      .width('100%')

      // 实时识别文字显示
      if (this.isRecording && this.recordingText) {
        Text(this.recordingText)
          .fontSize(ThemeConstants.FONT_SIZE_SM)
          .fontColor(ThemeColors.PRIMARY_DARK)
          .width('100%')
          .padding(8)
          .backgroundColor(ThemeColors.PRIMARY_LIGHT)
          .borderRadius(ThemeConstants.RADIUS_SM)
      }

      TextArea({ placeholder: '记录一些心得体�?..', text: this.notes })
        .fontSize(ThemeConstants.FONT_SIZE_BASE)
        .fontColor(ThemeColors.TEXT_PRIMARY)
        .placeholderColor(ThemeColors.TEXT_HINT)
        .backgroundColor(ThemeColors.BG_CARD)
        .borderRadius(ThemeConstants.RADIUS_SM)
        .height(100)
        .padding(ThemeConstants.SPACE_MD)
        .onChange((value: string) => {
          this.notes = value;
        })
    }
  }

  // 检查麦克风权限
  private async checkMicPermission(): Promise<boolean> {
    const atManager = abilityAccessCtrl.createAtManager();
    const context = getContext(this) as common.UIAbilityContext;
    const tokenId = context.applicationInfo.accessTokenId;
    const grantStatus = atManager.checkAccessTokenSync(tokenId, 'ohos.permission.MICROPHONE');
    return grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
  }

  // 请求麦克风权�?
  private async requestMicPermission(): Promise<boolean> {
    const permissions: Permissions[] = ['ohos.permission.MICROPHONE'];
    const atManager = abilityAccessCtrl.createAtManager();
    const context = getContext(this) as common.UIAbilityContext;
    const result = await atManager.requestPermissionsFromUser(context, permissions);
    return result.authResults[0] === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
  }

  // 初始化语音识别引擎（异步，避免阻塞主线程�?
  private async initAsrEngine(): Promise<boolean> {
    if (this.asrEngine) return true;

    return new Promise((resolve) => {
      // 使用 setTimeout 将引擎创建推迟到下一个事件循环，避免阻塞UI
      setTimeout(() => {
        const extraParam: Record<string, Object> = {
          'locate': 'CN',
          'recognizerMode': 'short'
        };

        // 优先使用离线模式（更稳定，不依赖网络�?
        const initParams: speechRecognizer.CreateEngineParams = {
          language: 'zh-CN',
          online: 1,  // 1=离线模式
          extraParams: extraParam
        };

        speechRecognizer.createEngine(initParams, (err, engine) => {
          if (!err && engine) {
            this.asrEngine = engine;
            this.setupAsrListener();
            resolve(true);
          } else {
            console.error('离线语音识别引擎创建失败:', JSON.stringify(err));
            // 离线失败，尝试在线模�?
            const onlineParams: speechRecognizer.CreateEngineParams = {
              language: 'zh-CN',
              online: 0,  // 0=在线模式
              extraParams: extraParam
            };
            speechRecognizer.createEngine(onlineParams, (err2, engine2) => {
              if (!err2 && engine2) {
                this.asrEngine = engine2;
                this.setupAsrListener();
                resolve(true);
              } else {
                console.error('在线语音识别引擎也失�?', JSON.stringify(err2));
                resolve(false);
              }
            });
          }
        });
      }, 0);
    });
  }

  // 设置语音识别监听
  private setupAsrListener(): void {
    if (!this.asrEngine) return;

    const listener: speechRecognizer.RecognitionListener = {
      onStart: (sessionId: string, eventMessage: string) => {
        console.info('语音识别开�?);
      },
      onEvent: (sessionId: string, eventCode: number, eventMessage: string) => {
        console.info('语音识别事件:', eventCode);
      },
      onResult: (sessionId: string, result: speechRecognizer.SpeechRecognitionResult) => {
        const text = result.result || '';
        this.recordingText = text;
        if (result.isFinal) {
          // 最终结果追加到备注
          this.notes = this.notes ? this.notes + text : text;
          this.recordingText = '';
        }
      },
      onComplete: (sessionId: string, eventMessage: string) => {
        this.isRecording = false;
        this.recordingText = '';
        console.info('语音识别完成');
      },
      onError: (sessionId: string, errorCode: number, errorMessage: string) => {
        this.isRecording = false;
        this.recordingText = '';
        console.error('语音识别错误:', errorCode, errorMessage);
        promptAction.showToast({ message: '语音识别失败，请重试' });
      }
    };
    this.asrEngine.setListener(listener);
  }

  // 开始语音输�?
  private async startVoiceInput(): Promise<void> {
    // 防止重复点击
    if (this.isAsrInitializing || this.isRecording) return;

    // 检查权�?
    const hasPermission = await this.checkMicPermission();
    if (!hasPermission) {
      const granted = await this.requestMicPermission();
      if (!granted) {
        promptAction.showToast({ message: '需要麦克风权限才能使用语音输入' });
        return;
      }
    }

    // 显示初始化状�?
    this.isAsrInitializing = true;

    // 初始化引�?
    const initialized = await this.initAsrEngine();
    this.isAsrInitializing = false;

    if (!initialized) {
      promptAction.showToast({ message: '语音识别初始化失败，请检查设备是否支�? });
      return;
    }

    // 开始识�?
    this.asrSessionId = `asr_${Date.now()}`;
    const audioParam: speechRecognizer.AudioInfo = {
      audioType: 'pcm',
      sampleRate: 16000,
      soundChannel: 1,
      sampleBit: 16
    };

    const extraParam: Record<string, Object> = {
      'recognitionMode': 0,
      'vadBegin': 2000,
      'vadEnd': 3000,
      'maxAudioDuration': 60000
    };

    const recognizerParams: speechRecognizer.StartParams = {
      sessionId: this.asrSessionId,
      audioInfo: audioParam,
      extraParams: extraParam
    };

    this.asrEngine!.startListening(recognizerParams);
    this.isRecording = true;
    this.recordingText = '';
  }

  // 停止语音输入
  private stopVoiceInput(): void {
    if (this.asrEngine && this.isRecording) {
      this.asrEngine.finish(this.asrSessionId);
      this.isRecording = false;
    }
  }

  @Builder
  RecipeSelector() {
    Column({ space: 8 }) {
      Text('🧪 使用配方 (可�?')
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .width('100%')

      Row() {
        Text(this.selectedRecipe || '点击选择配方')
          .fontSize(ThemeConstants.FONT_SIZE_BASE)
          .fontColor(this.selectedRecipe ? ThemeColors.TEXT_PRIMARY : ThemeColors.TEXT_HINT)
          .layoutWeight(1)

        if (this.selectedRecipe) {
          Text('×')
            .fontSize(ThemeConstants.FONT_SIZE_MD)
            .fontColor(ThemeColors.TEXT_MUTED)
            .padding({ left: 8, right: 8 })
            .onClick(() => {
              this.selectedRecipeId = '';
              this.selectedRecipe = '';
            })
        }

        Text('>')
          .fontSize(ThemeConstants.FONT_SIZE_MD)
          .fontColor(ThemeColors.TEXT_MUTED)
      }
      .width('100%')
      .height(50)
      .padding({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD })
      .backgroundColor(ThemeColors.BG_CARD)
      .borderRadius(ThemeConstants.RADIUS_SM)
      .shadow({ radius: 4, color: 'rgba(0,0,0,0.04)', offsetY: 1 })
      .onClick(() => {
        this.showRecipeSelector = true;
      })
    }
  }

  @Builder
  RecipeSelectorDialog() {
    Stack() {
      // 遮罩
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.5)')
        .onClick(() => {
          this.showRecipeSelector = false;
        })

      // 弹窗内容
      Column() {
        // 标题�?
        Row() {
          Text('选择配方')
            .fontSize(ThemeConstants.FONT_SIZE_LG)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.TEXT_PRIMARY)

          Blank()

          Text('×')
            .fontSize(24)
            .fontColor(ThemeColors.TEXT_SECONDARY)
            .onClick(() => {
              this.showRecipeSelector = false;
            })
        }
        .width('100%')
        .padding({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD, top: ThemeConstants.SPACE_MD })

        // 手动输入
        Row({ space: 8 }) {
          TextInput({ placeholder: '或手动输入配方名�?, text: this.selectedRecipe })
            .fontSize(ThemeConstants.FONT_SIZE_BASE)
            .fontColor(ThemeColors.TEXT_PRIMARY)
            .placeholderColor(ThemeColors.TEXT_HINT)
            .backgroundColor(ThemeColors.BG_TERTIARY)
            .borderRadius(ThemeConstants.RADIUS_SM)
            .height(44)
            .layoutWeight(1)
            .padding({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD })
            .onChange((value: string) => {
              this.selectedRecipe = value;
              this.selectedRecipeId = '';
            })

          Button('确定')
            .fontSize(ThemeConstants.FONT_SIZE_SM)
            .fontColor(Color.White)
            .backgroundColor(ThemeColors.PRIMARY)
            .borderRadius(ThemeConstants.RADIUS_SM)
            .height(44)
            .onClick(() => {
              this.showRecipeSelector = false;
            })
        }
        .width('100%')
        .padding({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD, top: ThemeConstants.SPACE_MD })

        // 配方列表
        if (this.recipeOptions.length > 0) {
          Text('可选配�?)
            .fontSize(ThemeConstants.FONT_SIZE_SM)
            .fontColor(ThemeColors.TEXT_SECONDARY)
            .width('100%')
            .padding({ left: ThemeConstants.SPACE_MD, top: ThemeConstants.SPACE_MD })

          Scroll() {
            Column({ space: 8 }) {
              ForEach(this.recipeOptions, (option: RecipeOption) => {
                Row() {
                  Column({ space: 4 }) {
                    Row({ space: 6 }) {
                      Text(option.name)
                        .fontSize(ThemeConstants.FONT_SIZE_BASE)
                        .fontColor(ThemeColors.TEXT_PRIMARY)
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .layoutWeight(1)
                      if (option.isFavorite) {
                        Text('❤️')
                          .fontSize(12)
                      }
                      if (option.isUserRecipe) {
                        Text('自创')
                          .fontSize(ThemeConstants.FONT_SIZE_XS)
                          .fontColor(ThemeColors.PRIMARY_DARK)
                          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                          .backgroundColor(ThemeColors.PRIMARY_LIGHT)
                          .borderRadius(4)
                      }
                    }
                    .width('100%')
                    Text(`🐟 ${option.targetFish}`)
                      .fontSize(ThemeConstants.FONT_SIZE_XS)
                      .fontColor(ThemeColors.TEXT_SECONDARY)
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)

                  if (this.selectedRecipeId === option.id) {
                    Text('�?)
                      .fontSize(18)
                      .fontColor(ThemeColors.PRIMARY_DARK)
                  }
                }
                .width('100%')
                .padding(ThemeConstants.SPACE_MD)
                .backgroundColor(this.selectedRecipeId === option.id ? ThemeColors.PRIMARY_LIGHT : ThemeColors.BG_CARD)
                .borderRadius(ThemeConstants.RADIUS_SM)
                .onClick(() => {
                  this.selectedRecipeId = option.id;
                  this.selectedRecipe = option.name;
                  this.showRecipeSelector = false;
                })
              })
            }
            .padding({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD, bottom: ThemeConstants.SPACE_MD })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        } else {
          Column() {
            Text('📭')
              .fontSize(40)
            Text('暂无可选配�?)
              .fontSize(ThemeConstants.FONT_SIZE_SM)
              .fontColor(ThemeColors.TEXT_SECONDARY)
              .margin({ top: 8 })
            Text('可以手动输入配方名称')
              .fontSize(ThemeConstants.FONT_SIZE_XS)
              .fontColor(ThemeColors.TEXT_MUTED)
              .margin({ top: 4 })
          }
          .width('100%')
          .padding({ top: 40, bottom: 40 })
        }
      }
      .width('90%')
      .height('60%')
      .backgroundColor(ThemeColors.BG_SECONDARY)
      .borderRadius(ThemeConstants.RADIUS_LG)
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
  }

  @Builder
  SaveButton() {
    Button() {
      if (this.isSaving) {
        Row({ space: 8 }) {
          LoadingProgress()
            .width(20)
            .height(20)
            .color(ThemeColors.TEXT_PRIMARY)
          Text('保存�?..')
            .fontSize(ThemeConstants.FONT_SIZE_MD)
            .fontColor(ThemeColors.TEXT_PRIMARY)
        }
      } else {
        Row({ space: 8 }) {
          Text('�?)
            .fontSize(18)
            .fontColor(ThemeColors.TEXT_PRIMARY)
          Text('保存记录')
            .fontSize(ThemeConstants.FONT_SIZE_MD)
            .fontColor(ThemeColors.TEXT_PRIMARY)
            .fontWeight(FontWeight.Medium)
        }
      }
    }
    .backgroundColor(ThemeColors.PRIMARY)
    .borderRadius(ThemeConstants.RADIUS_MD)
    .width('100%')
    .height(52)
    .margin({ top: ThemeConstants.SPACE_LG })
    .enabled(!this.isSaving && !this.hasSaved)
    .opacity(this.hasSaved ? 0.5 : 1)
    .shadow({ radius: 8, color: 'rgba(232,168,73,0.4)', offsetY: 4 })
    .onClick(() => {
      this.saveRecord();
    })
  }

  // 显示炫耀弹窗
  private showVictoryDialog(record: FishingRecord): void {
    promptAction.showDialog({
      title: '🎉 记录保存成功',
      message: '要生成一张精美的渔获分享图炫耀一下吗�?,
      buttons: [
        { text: '跳过', color: ThemeColors.TEXT_MUTED },
        { text: '炫耀一�?🏆', color: ThemeColors.PRIMARY }
      ]
    }).then((result) => {
      if (result.index === 1) {
        const params: Record<string, FishingRecord> = { 'record': record };
        Router.push('pages/VictorySharePage', params as RouteParams);
      } else {
        Router.back();
      }
    }).catch(() => {
      Router.back();
    });
  }

  private saveRecord(): void {
    // 防止重复提交
    if (this.isSaving || this.hasSaved) {
      return;
    }
    
    // 验证必填字段
    if (!this.location.trim()) {
      promptAction.showToast({ message: '请输入钓点位�? });
      return;
    }
    if (this.selectedFishList.length === 0) {
      promptAction.showToast({ message: '请选择鱼种' });
      return;
    }
    if (!this.weight || parseFloat(this.weight) <= 0) {
      promptAction.showToast({ message: '请输入有效重�? });
      return;
    }

    this.isSaving = true;

    // 创建记录
    const record = new FishingRecord();
    record.location = this.location.trim();
    record.fishName = this.selectedFishList.join('�?);  // 多鱼种用顿号连接
    record.fishIcon = '🐟';
    record.weight = parseFloat(this.weight) || 0;
    record.count = parseInt(this.count) || 1;
    record.maxSingle = record.count > 0 ? Math.round((record.weight / record.count) * 100) / 100 : record.weight;
    record.recipeName = this.selectedRecipe.trim();
    record.recipeId = this.selectedRecipeId;
    record.weather = this.weather;
    record.notes = this.notes.trim();
    record.photos = this.photos;  // 保存图片
    record.date = new Date(this.selectedDate).getTime();
    record.dateStr = this.selectedDate;

    // 保存记录
    fishingRecordService.addRecord(record).then(() => {
      // 保存上次使用的钓点和天气
      this.saveLastSettings();

      this.isSaving = false;
      this.hasSaved = true;  // 标记已保存，防止重复保存
      
      // 显示炫耀弹窗
      this.showVictoryDialog(record);
    }).catch(() => {
      this.isSaving = false;
      promptAction.showToast({ message: '保存失败，请重试' });
    });
  }
}
