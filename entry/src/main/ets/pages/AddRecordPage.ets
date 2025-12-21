/**
 * 饵知道 - 添加渔获记录页
 * 记录钓鱼成果
 */
import { ThemeColors } from '../theme/ThemeColors';
import { ThemeConstants } from '../theme/ThemeConstants';
import { Router } from '../router/Router';
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
struct AddRecordPage {
  @State selectedDate: string = '';
  @State location: string = '';
  @State selectedFish: string = '';
  @State weight: string = '';
  @State count: string = '1';
  @State selectedRecipe: string = '';
  @State weather: string = '晴朗';
  @State notes: string = '';
  @State isSaving: boolean = false;

  private fishOptions: FishOption[] = [
    { name: '鲤鱼', icon: $r('app.media.Carp') },
    { name: '草鱼', icon: $r('app.media.Grass_carp') },
    { name: '鲫鱼', icon: $r('app.media.Crucian_carp') },
    { name: '青鱼', icon: $r('app.media.Black_carp') },
    { name: '鲶鱼', icon: $r('app.media.Catfish') },
    { name: '鲢鱼', icon: $r('app.media.Fish') },
    { name: '鳙鱼', icon: $r('app.media.Fish') },
    { name: '黑鱼', icon: $r('app.media.Fish') },
    { name: '其他', icon: $r('app.media.Fish') }
  ];

  private weatherOptions: string[] = ['晴朗', '多云', '阴天', '小雨', '大风'];

  aboutToAppear(): void {
    // 默认今天日期
    const today = new Date();
    const year = today.getFullYear();
    const month = (today.getMonth() + 1).toString().padStart(2, '0');
    const day = today.getDate().toString().padStart(2, '0');
    this.selectedDate = `${year}-${month}-${day}`;
  }

  build() {
    Column() {
      this.HeaderBar()

      Scroll() {
        Column({ space: ThemeConstants.SPACE_MD }) {
          // 日期选择
          this.FormItem('📅 日期', this.selectedDate)

          // 钓点位置
          this.InputItem('📍 钓点位置', '请输入钓点名称', this.location, (value: string) => {
            this.location = value;
          })

          // 天气选择
          this.WeatherSelector()

          // 鱼种选择
          this.FishSelector()

          // 重量输入
          this.InputItem('⚖️ 总重量 (kg)', '请输入重量', this.weight, (value: string) => {
            this.weight = value;
          })

          // 数量输入
          this.InputItem('🔢 数量 (尾)', '请输入数量', this.count, (value: string) => {
            this.count = value;
          })

          // 使用配方
          this.InputItem('🧪 使用配方', '请输入配方名称', this.selectedRecipe, (value: string) => {
            this.selectedRecipe = value;
          })

          // 备注
          this.NotesInput()

          // 保存按钮
          this.SaveButton()
        }
        .padding({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD, bottom: 40 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeColors.BG_PRIMARY)
  }

  @Builder
  HeaderBar() {
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
    .height(56)
    .padding({ left: 16, right: 16, top: 40 })
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
      Text('🌤️ 天气')
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
      '晴朗': '☀️',
      '多云': '⛅',
      '阴天': '☁️',
      '小雨': '🌧️',
      '大风': '💨'
    };
    return icons[weather] || '🌤️';
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
              .fontColor(this.selectedFish === option.name ? ThemeColors.TEXT_PRIMARY : ThemeColors.TEXT_SECONDARY)
          }
          .width(64)
          .padding({ top: 8, bottom: 8 })
          .backgroundColor(this.selectedFish === option.name ? ThemeColors.PRIMARY : ThemeColors.BG_CARD)
          .borderRadius(ThemeConstants.RADIUS_SM)
          .margin({ right: 8, bottom: 8 })
          .shadow(this.selectedFish === option.name ? { radius: 4, color: 'rgba(232,168,73,0.3)', offsetY: 2 } : undefined)
          .onClick(() => {
            this.selectedFish = option.name;
          })
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

      TextArea({ placeholder: '记录一些心得体会...', text: this.notes })
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

  @Builder
  SaveButton() {
    Button() {
      if (this.isSaving) {
        Row({ space: 8 }) {
          LoadingProgress()
            .width(20)
            .height(20)
            .color(ThemeColors.TEXT_PRIMARY)
          Text('保存中...')
            .fontSize(ThemeConstants.FONT_SIZE_MD)
            .fontColor(ThemeColors.TEXT_PRIMARY)
        }
      } else {
        Row({ space: 8 }) {
          Text('✓')
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
    .enabled(!this.isSaving)
    .shadow({ radius: 8, color: 'rgba(232,168,73,0.4)', offsetY: 4 })
    .onClick(() => {
      this.saveRecord();
    })
  }

  private saveRecord(): void {
    // 验证必填字段
    if (!this.location.trim()) {
      promptAction.showToast({ message: '请输入钓点位置' });
      return;
    }
    if (!this.selectedFish) {
      promptAction.showToast({ message: '请选择鱼种' });
      return;
    }
    if (!this.weight || parseFloat(this.weight) <= 0) {
      promptAction.showToast({ message: '请输入有效重量' });
      return;
    }

    this.isSaving = true;

    // 创建记录
    const record = new FishingRecord();
    record.location = this.location.trim();
    record.fishName = this.selectedFish;
    record.fishIcon = '🐟';
    record.weight = parseFloat(this.weight) || 0;
    record.count = parseInt(this.count) || 1;
    record.maxSingle = record.count > 0 ? Math.round((record.weight / record.count) * 100) / 100 : record.weight;
    record.recipeName = this.selectedRecipe.trim();
    record.weather = this.weather;
    record.notes = this.notes.trim();
    record.date = new Date(this.selectedDate).getTime();
    record.dateStr = this.selectedDate;

    // 保存记录
    fishingRecordService.addRecord(record).then(() => {
      this.isSaving = false;
      promptAction.showToast({ message: '🎉 记录保存成功' });
      Router.back();
    }).catch(() => {
      this.isSaving = false;
      promptAction.showToast({ message: '保存失败，请重试' });
    });
  }
}
