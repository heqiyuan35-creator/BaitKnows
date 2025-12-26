/**
 * 饵知道 - 渔获记录详情/编辑页
 */
import { ThemeColors } from '../theme/ThemeColors';
import { ThemeConstants } from '../theme/ThemeConstants';
import { Router, RouteParams } from '../router/Router';
import { FishingRecord } from '../common/types/UserTypes';
import { fishingRecordService } from '../services/FishingRecordService';
import { promptAction } from '@kit.ArkUI';

// 鱼种选项
interface FishOption {
  name: string;
  icon: Resource;
}

@Entry
@Component
struct RecordDetailPage {
  @State record: FishingRecord = new FishingRecord();
  @State isEdit: boolean = false;
  @State isLoading: boolean = true;
  @State showDeleteDialog: boolean = false;

  // 编辑状态的临时数据
  @State editLocation: string = '';
  @State editFishName: string = '';
  @State editWeight: string = '';
  @State editCount: string = '';
  @State editMaxSingle: string = '';
  @State editRecipeName: string = '';
  @State editWeather: string = '';
  @State editNotes: string = '';

  private fishOptions: FishOption[] = [
    { name: '鲤鱼', icon: $r('app.media.Carp') },
    { name: '草鱼', icon: $r('app.media.Grass_carp') },
    { name: '鲫鱼', icon: $r('app.media.Crucian_carp') },
    { name: '青鱼', icon: $r('app.media.Black_carp') },
    { name: '鲶鱼', icon: $r('app.media.Catfish') },
    { name: '鲢鱼', icon: $r('app.media.Silvercarp') },
    { name: '鳙鱼', icon: $r('app.media.Bigheadcarp') },
    { name: '黑鱼', icon: $r('app.media.Snakehead_fish') },
    { name: '鲈鱼', icon: $r('app.media.Perch') },
    { name: '其他', icon: $r('app.media.Fish') }
  ];

  private weatherOptions: string[] = ['晴朗', '多云', '阴天', '小雨', '大风'];

  aboutToAppear(): void {
    const params = Router.getParams();
    if (params.recordId) {
      this.loadRecord(params.recordId);
    }
    if (params.isEdit) {
      this.isEdit = true;
    }
  }

  private loadRecord(recordId: string): void {
    const record = fishingRecordService.getRecordById(recordId);
    if (record) {
      this.record = record;
      this.initEditData();
    }
    this.isLoading = false;
  }

  private initEditData(): void {
    this.editLocation = this.record.location;
    this.editFishName = this.record.fishName;
    this.editWeight = this.record.weight.toString();
    this.editCount = this.record.count.toString();
    this.editMaxSingle = this.record.maxSingle.toString();
    this.editRecipeName = this.record.recipeName;
    this.editWeather = this.record.weather;
    this.editNotes = this.record.notes;
  }

  private formatDate(timestamp: number): string {
    const date = new Date(timestamp);
    const month = date.getMonth() + 1;
    const day = date.getDate();
    const weekDays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    const weekDay = weekDays[date.getDay()];
    return `${month}月${day}日 ${weekDay}`;
  }

  private getWeatherIcon(weather: string): string {
    const icons: Record<string, string> = {
      '晴朗': '☀️',
      '多云': '⛅',
      '阴天': '☁️',
      '小雨': '🌧️',
      '大风': '💨'
    };
    return icons[weather] || '🌤️';
  }

  // 截断鱼种名称，最多显示2种鱼
  private formatFishName(name: string): string {
    if (!name) return '未知鱼种';
    const fishList = name.split('、');
    if (fishList.length <= 2) return name;
    return fishList.slice(0, 2).join('、') + '等';
  }

  private async saveChanges(): Promise<void> {
    this.record.location = this.editLocation;
    this.record.fishName = this.editFishName;
    this.record.weight = parseFloat(this.editWeight) || 0;
    this.record.count = parseInt(this.editCount) || 0;
    this.record.maxSingle = parseFloat(this.editMaxSingle) || 0;
    this.record.recipeName = this.editRecipeName;
    this.record.weather = this.editWeather;
    this.record.notes = this.editNotes;

    const success = await fishingRecordService.updateRecord(this.record);
    if (success) {
      promptAction.showToast({ message: '保存成功' });
      this.isEdit = false;
    } else {
      promptAction.showToast({ message: '保存失败' });
    }
  }

  private async deleteRecord(): Promise<void> {
    try {
      const recordId = this.record.id;
      if (!recordId) {
        promptAction.showToast({ message: '记录ID无效' });
        return;
      }
      const success = await fishingRecordService.deleteRecord(recordId);
      if (success) {
        promptAction.showToast({ message: '删除成功' });
        Router.back();
      } else {
        promptAction.showToast({ message: '删除失败，请重试' });
      }
    } catch (error) {
      console.error('[RecordDetailPage] Delete error:', error);
      promptAction.showToast({ message: '删除出错，请重试' });
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      this.HeaderBar()

      if (this.isLoading) {
        this.LoadingView()
      } else if (this.isEdit) {
        this.EditView()
      } else {
        this.DetailView()
      }

      // 删除确认弹窗
      if (this.showDeleteDialog) {
        this.DeleteDialog()
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
          .onClick(() => {
            if (this.isEdit) {
              this.isEdit = false;
              this.initEditData();
            } else {
              Router.back();
            }
          })

        Blank()

        Text(this.isEdit ? '编辑记录' : '记录详情')
          .fontSize(ThemeConstants.FONT_SIZE_LG)
          .fontWeight(FontWeight.Medium)
          .fontColor(ThemeColors.TEXT_PRIMARY)

        Blank()

        if (!this.isEdit) {
          Row({ space: 16 }) {
            Text('编辑')
              .fontSize(ThemeConstants.FONT_SIZE_SM)
              .fontColor(ThemeColors.PRIMARY)
              .onClick(() => { this.isEdit = true; })

            Text('删除')
              .fontSize(ThemeConstants.FONT_SIZE_SM)
              .fontColor('#FF4444')
              .onClick(() => { this.showDeleteDialog = true; })
          }
        } else {
          Text('保存')
            .fontSize(ThemeConstants.FONT_SIZE_SM)
            .fontColor(ThemeColors.PRIMARY)
            .onClick(() => { this.saveChanges(); })
        }
      }
      .width('100%')
      .height(48)
      .padding({ left: 16, right: 16 })
    }
    .width('100%')
  }

  @Builder
  LoadingView() {
    Column() {
      LoadingProgress()
        .width(48)
        .height(48)
        .color(ThemeColors.PRIMARY)
      Text('加载中...')
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .margin({ top: 12 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  DetailView() {
    Scroll() {
      Column({ space: ThemeConstants.SPACE_MD }) {
        // 主信息卡片
        Column({ space: 12 }) {
          // 日期和天气
          Row() {
            Row({ space: 6 }) {
              Text('📅')
                .fontSize(14)
              Text(this.formatDate(this.record.date))
                .fontSize(ThemeConstants.FONT_SIZE_SM)
                .fontColor(ThemeColors.TEXT_SECONDARY)
            }
            Blank()
            Row({ space: 4 }) {
              Text(this.getWeatherIcon(this.record.weather))
                .fontSize(16)
              Text(this.record.weather)
                .fontSize(ThemeConstants.FONT_SIZE_SM)
                .fontColor(ThemeColors.TEXT_SECONDARY)
            }
            .padding({ left: 10, right: 10, top: 4, bottom: 4 })
            .backgroundColor(ThemeColors.BG_TERTIARY)
            .borderRadius(ThemeConstants.RADIUS_FULL)
          }
          .width('100%')

          // 鱼种和重量
          Row() {
            Column({ space: 4 }) {
              Row({ space: 8 }) {
                Text('🐟')
                  .fontSize(24)
                  .flexShrink(0)
                Text(this.formatFishName(this.record.fishName))
                  .fontSize(ThemeConstants.FONT_SIZE_XL)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(ThemeColors.TEXT_PRIMARY)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .constraintSize({ maxWidth: '60%' })

              Text(`共 ${this.record.count} 尾`)
                .fontSize(ThemeConstants.FONT_SIZE_SM)
                .fontColor(ThemeColors.TEXT_SECONDARY)
            }
            .alignItems(HorizontalAlign.Start)
            .flexShrink(1)

            Blank()

            Column({ space: 4 }) {
              Row() {
                Text(`${this.record.weight}`)
                  .fontSize(36)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(ThemeColors.PRIMARY)
                Text('kg')
                  .fontSize(ThemeConstants.FONT_SIZE_MD)
                  .fontColor(ThemeColors.TEXT_SECONDARY)
                  .margin({ left: 4, top: 12 })
              }
            }
            .alignItems(HorizontalAlign.End)
            .flexShrink(0)
          }
          .width('100%')
        }
        .width('100%')
        .padding(ThemeConstants.SPACE_MD)
        .backgroundColor(ThemeColors.BG_CARD)
        .borderRadius(ThemeConstants.RADIUS_MD)
        .margin({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD })
        .shadow({ radius: 8, color: 'rgba(0,0,0,0.05)', offsetY: 2 })

        // 详细信息
        Column({ space: 1 }) {
          this.InfoRow('📍 钓点', this.record.location || '未填写')
          this.InfoRow('🏆 最大单尾', `${this.record.maxSingle} kg`)
          this.RecipeInfoRow()
        }
        .margin({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD })
        .borderRadius(ThemeConstants.RADIUS_MD)
        .clip(true)
        .shadow({ radius: 8, color: 'rgba(0,0,0,0.05)', offsetY: 2 })

        // 渔获图片
        if (this.record.photos && this.record.photos.length > 0) {
          Column({ space: 8 }) {
            Row({ space: 6 }) {
              Text('📷')
                .fontSize(16)
              Text('渔获图片')
                .fontSize(ThemeConstants.FONT_SIZE_MD)
                .fontWeight(FontWeight.Medium)
                .fontColor(ThemeColors.TEXT_PRIMARY)
            }
            .width('100%')

            Row({ space: 8 }) {
              ForEach(this.record.photos, (photo: string, index: number) => {
                Image(photo)
                  .width(100)
                  .height(100)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(ThemeConstants.RADIUS_SM)
              }, (photo: string, index: number) => `photo_${index}`)
            }
            .width('100%')
          }
          .width('100%')
          .padding(ThemeConstants.SPACE_MD)
          .backgroundColor(ThemeColors.BG_CARD)
          .borderRadius(ThemeConstants.RADIUS_MD)
          .margin({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD })
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.05)', offsetY: 2 })
        }

        // 备注
        if (this.record.notes) {
          Column({ space: 8 }) {
            Row({ space: 6 }) {
              Text('📝')
                .fontSize(16)
              Text('备注')
                .fontSize(ThemeConstants.FONT_SIZE_MD)
                .fontWeight(FontWeight.Medium)
                .fontColor(ThemeColors.TEXT_PRIMARY)
            }
            .width('100%')

            Text(this.record.notes)
              .fontSize(ThemeConstants.FONT_SIZE_BASE)
              .fontColor(ThemeColors.TEXT_SECONDARY)
              .lineHeight(22)
              .width('100%')
          }
          .width('100%')
          .padding(ThemeConstants.SPACE_MD)
          .backgroundColor(ThemeColors.BG_CARD)
          .borderRadius(ThemeConstants.RADIUS_MD)
          .margin({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD })
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.05)', offsetY: 2 })
        }
      }
      .padding({ top: ThemeConstants.SPACE_MD, bottom: 40 })
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder
  InfoRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(ThemeConstants.FONT_SIZE_BASE)
        .fontColor(ThemeColors.TEXT_SECONDARY)
      Blank()
      Text(value)
        .fontSize(ThemeConstants.FONT_SIZE_BASE)
        .fontColor(ThemeColors.TEXT_PRIMARY)
    }
    .width('100%')
    .height(52)
    .padding({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD })
    .backgroundColor(ThemeColors.BG_CARD)
  }

  @Builder
  RecipeInfoRow() {
    Row() {
      Text('🧪 使用配方')
        .fontSize(ThemeConstants.FONT_SIZE_BASE)
        .fontColor(ThemeColors.TEXT_SECONDARY)
      Blank()
      if (this.record.recipeName && this.record.recipeId) {
        Row({ space: 4 }) {
          Text(this.record.recipeName)
            .fontSize(ThemeConstants.FONT_SIZE_BASE)
            .fontColor(ThemeColors.PRIMARY)
          Text('>')
            .fontSize(ThemeConstants.FONT_SIZE_SM)
            .fontColor(ThemeColors.PRIMARY)
        }
        .onClick(() => {
          Router.goToRecipeDetail(this.record.recipeId);
        })
      } else {
        Text(this.record.recipeName || '未填写')
          .fontSize(ThemeConstants.FONT_SIZE_BASE)
          .fontColor(ThemeColors.TEXT_PRIMARY)
      }
    }
    .width('100%')
    .height(52)
    .padding({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD })
    .backgroundColor(ThemeColors.BG_CARD)
  }

  @Builder
  EditView() {
    Scroll() {
      Column({ space: ThemeConstants.SPACE_MD }) {
        // 钓点位置
        this.EditInput('📍 钓点位置', '请输入钓点名称', this.editLocation, (v: string) => { this.editLocation = v; })

        // 天气选择
        this.WeatherSelector()

        // 鱼种选择
        this.FishSelector()

        // 重量
        this.EditInput('⚖️ 总重量 (kg)', '请输入重量', this.editWeight, (v: string) => { this.editWeight = v; })

        // 数量
        this.EditInput('🔢 数量 (尾)', '请输入数量', this.editCount, (v: string) => { this.editCount = v; })

        // 最大单尾
        this.EditInput('🏆 最大单尾 (kg)', '请输入最大单尾重量', this.editMaxSingle, (v: string) => { this.editMaxSingle = v; })

        // 使用配方
        this.EditInput('🧪 使用配方', '请输入配方名称', this.editRecipeName, (v: string) => { this.editRecipeName = v; })

        // 备注
        this.NotesInput()
      }
      .padding({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD, top: ThemeConstants.SPACE_MD, bottom: 40 })
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder
  EditInput(label: string, placeholder: string, value: string, onChange: (v: string) => void) {
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
        .height(48)
        .padding({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD })
        .onChange(onChange)
    }
  }

  @Builder
  WeatherSelector() {
    Column({ space: 8 }) {
      Text('🌤️ 天气')
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .width('100%')

      Row({ space: 8 }) {
        ForEach(this.weatherOptions, (option: string) => {
          Text(option)
            .fontSize(ThemeConstants.FONT_SIZE_SM)
            .fontColor(this.editWeather === option ? ThemeColors.TEXT_PRIMARY : ThemeColors.TEXT_SECONDARY)
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .backgroundColor(this.editWeather === option ? ThemeColors.PRIMARY : ThemeColors.BG_CARD)
            .borderRadius(ThemeConstants.RADIUS_SM)
            .onClick(() => { this.editWeather = option; })
        })
      }
      .width('100%')
    }
  }

  @Builder
  FishSelector() {
    Column({ space: 8 }) {
      Text('🐟 鱼种')
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .width('100%')

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.fishOptions, (option: FishOption) => {
          Column({ space: 4 }) {
            Image(option.icon)
              .width(28)
              .height(28)
              .objectFit(ImageFit.Contain)
            Text(option.name)
              .fontSize(ThemeConstants.FONT_SIZE_XS)
              .fontColor(this.editFishName === option.name ? ThemeColors.TEXT_PRIMARY : ThemeColors.TEXT_SECONDARY)
          }
          .width(64)
          .padding({ top: 8, bottom: 8 })
          .backgroundColor(this.editFishName === option.name ? ThemeColors.PRIMARY : ThemeColors.BG_CARD)
          .borderRadius(ThemeConstants.RADIUS_SM)
          .margin({ right: 8, bottom: 8 })
          .onClick(() => { this.editFishName = option.name; })
        })
      }
      .width('100%')
    }
  }

  @Builder
  NotesInput() {
    Column({ space: 8 }) {
      Text('📝 备注')
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .width('100%')

      TextArea({ placeholder: '记录一些心得体会...', text: this.editNotes })
        .fontSize(ThemeConstants.FONT_SIZE_BASE)
        .fontColor(ThemeColors.TEXT_PRIMARY)
        .placeholderColor(ThemeColors.TEXT_HINT)
        .backgroundColor(ThemeColors.BG_CARD)
        .borderRadius(ThemeConstants.RADIUS_SM)
        .height(100)
        .padding(ThemeConstants.SPACE_MD)
        .onChange((v: string) => { this.editNotes = v; })
    }
  }

  @Builder
  DeleteDialog() {
    Stack() {
      // 遮罩
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.5)')
        .onClick(() => { this.showDeleteDialog = false; })

      // 弹窗
      Column({ space: 16 }) {
        Text('确认删除')
          .fontSize(ThemeConstants.FONT_SIZE_LG)
          .fontWeight(FontWeight.Medium)
          .fontColor(ThemeColors.TEXT_PRIMARY)

        Text('删除后无法恢复，确定要删除这条记录吗？')
          .fontSize(ThemeConstants.FONT_SIZE_BASE)
          .fontColor(ThemeColors.TEXT_SECONDARY)
          .textAlign(TextAlign.Center)

        Row({ space: 12 }) {
          Button('取消')
            .fontSize(ThemeConstants.FONT_SIZE_BASE)
            .fontColor(ThemeColors.TEXT_PRIMARY)
            .backgroundColor(ThemeColors.BG_TERTIARY)
            .layoutWeight(1)
            .height(44)
            .onClick(() => { this.showDeleteDialog = false; })

          Button('删除')
            .fontSize(ThemeConstants.FONT_SIZE_BASE)
            .fontColor(Color.White)
            .backgroundColor('#FF4444')
            .layoutWeight(1)
            .height(44)
            .onClick(() => {
              this.showDeleteDialog = false;
              this.deleteRecord();
            })
        }
        .width('100%')
      }
      .width('80%')
      .padding(24)
      .backgroundColor(ThemeColors.BG_CARD)
      .borderRadius(ThemeConstants.RADIUS_LG)
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
  }
}
