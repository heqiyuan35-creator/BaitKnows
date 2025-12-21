/**
 * 饵知道 - 鱼类新增页面
 * 用户自定义添加鱼种数据
 */
import { router } from '@kit.ArkUI';
import { ThemeColors } from '../theme/ThemeColors';
import { ThemeConstants } from '../theme/ThemeConstants';
import { userDataService } from '../services/UserDataService';

// 选项接口
interface SelectOption {
  id: string;
  name: string;
}

@Entry
@Component
struct FishAddPage {
  @State fishName: string = '';
  @State fishNameEn: string = '';
  @State selectedWaterTypes: string[] = [];
  @State selectedFeedingType: string = 'omnivore';
  @State selectedWaterLayer: string = 'bottom';
  @State selectedActivityTime: string = 'all';
  @State preferredTemp: string = '';
  @State description: string = '';
  @State favoriteFood: string = '';

  private waterTypes: SelectOption[] = [
    { id: 'pond', name: '池塘' },
    { id: 'river', name: '河流' },
    { id: 'reservoir', name: '水库' },
    { id: 'lake', name: '湖泊' }
  ];

  private feedingTypes: SelectOption[] = [
    { id: 'herbivore', name: '草食性' },
    { id: 'carnivore', name: '肉食性' },
    { id: 'omnivore', name: '杂食性' }
  ];

  private waterLayers: SelectOption[] = [
    { id: 'surface', name: '上层' },
    { id: 'middle', name: '中层' },
    { id: 'bottom', name: '底层' },
    { id: 'all', name: '全水层' }
  ];

  private activityTimes: SelectOption[] = [
    { id: 'day', name: '白天' },
    { id: 'night', name: '夜间' },
    { id: 'dawn_dusk', name: '晨昏' },
    { id: 'all', name: '全天' }
  ];

  build() {
    Column() {
      // 顶部导航栏
      this.NavBar()

      // 表单内容
      Scroll() {
        Column({ space: 20 }) {
          // 鱼种名称
          this.FormSection('鱼种名称 *', () => {
            TextInput({ placeholder: '请输入鱼种中文名', text: this.fishName })
              .width('100%')
              .height(48)
              .fontSize(ThemeConstants.FONT_SIZE_BASE)
              .backgroundColor(ThemeColors.BG_CARD)
              .borderRadius(ThemeConstants.RADIUS_SM)
              .padding({ left: 12, right: 12 })
              .onChange((value: string) => {
                this.fishName = value;
              })
          })

          // 英文名
          this.FormSection('英文名（可选）', () => {
            TextInput({ placeholder: '请输入英文名', text: this.fishNameEn })
              .width('100%')
              .height(48)
              .fontSize(ThemeConstants.FONT_SIZE_BASE)
              .backgroundColor(ThemeColors.BG_CARD)
              .borderRadius(ThemeConstants.RADIUS_SM)
              .padding({ left: 12, right: 12 })
              .onChange((value: string) => {
                this.fishNameEn = value;
              })
          })

          // 适合水域
          this.FormSection('适合水域 *', () => {
            this.WaterTypeSelector()
          })

          // 食性
          this.FormSection('食性 *', () => {
            this.SingleSelector(this.feedingTypes, this.selectedFeedingType, (id: string) => {
              this.selectedFeedingType = id;
            })
          })

          // 活动水层
          this.FormSection('活动水层', () => {
            this.SingleSelector(this.waterLayers, this.selectedWaterLayer, (id: string) => {
              this.selectedWaterLayer = id;
            })
          })

          // 活动时段
          this.FormSection('活动时段', () => {
            this.SingleSelector(this.activityTimes, this.selectedActivityTime, (id: string) => {
              this.selectedActivityTime = id;
            })
          })

          // 适宜水温
          this.FormSection('适宜水温', () => {
            TextInput({ placeholder: '如：15-25°C', text: this.preferredTemp })
              .width('100%')
              .height(48)
              .fontSize(ThemeConstants.FONT_SIZE_BASE)
              .backgroundColor(ThemeColors.BG_CARD)
              .borderRadius(ThemeConstants.RADIUS_SM)
              .padding({ left: 12, right: 12 })
              .onChange((value: string) => {
                this.preferredTemp = value;
              })
          })

          // 喜食饵料
          this.FormSection('喜食饵料', () => {
            TextInput({ placeholder: '如：蚯蚓、玉米、红虫（顿号分隔）', text: this.favoriteFood })
              .width('100%')
              .height(48)
              .fontSize(ThemeConstants.FONT_SIZE_BASE)
              .backgroundColor(ThemeColors.BG_CARD)
              .borderRadius(ThemeConstants.RADIUS_SM)
              .padding({ left: 12, right: 12 })
              .onChange((value: string) => {
                this.favoriteFood = value;
              })
          })

          // 习性描述
          this.FormSection('习性描述', () => {
            TextArea({ placeholder: '描述该鱼种的生活习性、垂钓技巧等', text: this.description })
              .width('100%')
              .height(100)
              .fontSize(ThemeConstants.FONT_SIZE_BASE)
              .backgroundColor(ThemeColors.BG_CARD)
              .borderRadius(ThemeConstants.RADIUS_SM)
              .padding(12)
              .onChange((value: string) => {
                this.description = value;
              })
          })

          // 保存按钮
          Button('保存鱼种')
            .width('100%')
            .height(48)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .backgroundColor(ThemeColors.PRIMARY)
            .fontColor(ThemeColors.TEXT_PRIMARY)
            .margin({ top: 16, bottom: 32 })
            .onClick(() => this.saveFish())
        }
        .padding(16)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeColors.BG_PRIMARY)
  }

  @Builder
  NavBar() {
    Row() {
      Text('←')
        .fontSize(24)
        .fontColor(ThemeColors.TEXT_PRIMARY)
        .onClick(() => router.back())
        .padding(8)

      Text('添加鱼种')
        .fontSize(ThemeConstants.FONT_SIZE_LG)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeColors.TEXT_PRIMARY)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Text('')
        .width(40)
    }
    .width('100%')
    .height(56)
    .padding({ left: 8, right: 16 })
    .backgroundColor(ThemeColors.BG_SECONDARY)
  }

  @Builder
  FormSection(title: string, content: () => void) {
    Column({ space: 8 }) {
      Text(title)
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .fontWeight(FontWeight.Medium)

      content()
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  WaterTypeSelector() {
    Row({ space: 8 }) {
      ForEach(this.waterTypes, (item: SelectOption) => {
        Row() {
          Checkbox()
            .select(this.selectedWaterTypes.includes(item.id))
            .selectedColor(ThemeColors.PRIMARY)
            .width(18)
            .height(18)
            .onChange((checked: boolean) => {
              if (checked) {
                this.selectedWaterTypes.push(item.id);
              } else {
                const idx = this.selectedWaterTypes.indexOf(item.id);
                if (idx > -1) {
                  this.selectedWaterTypes.splice(idx, 1);
                }
              }
              this.selectedWaterTypes = [...this.selectedWaterTypes];
            })

          Text(item.name)
            .fontSize(ThemeConstants.FONT_SIZE_SM)
            .fontColor(ThemeColors.TEXT_PRIMARY)
            .margin({ left: 4 })
        }
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .backgroundColor(this.selectedWaterTypes.includes(item.id) ? 'rgba(232, 168, 73, 0.15)' : ThemeColors.BG_CARD)
        .borderRadius(ThemeConstants.RADIUS_SM)
      })
    }
    .width('100%')
    .flexWrap(FlexWrap.Wrap)
  }

  @Builder
  SingleSelector(options: SelectOption[], selected: string, onSelect: (id: string) => void) {
    Row({ space: 8 }) {
      ForEach(options, (item: SelectOption) => {
        Text(item.name)
          .fontSize(ThemeConstants.FONT_SIZE_SM)
          .fontColor(selected === item.id ? ThemeColors.PRIMARY : ThemeColors.TEXT_SECONDARY)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .backgroundColor(selected === item.id ? 'rgba(232, 168, 73, 0.15)' : ThemeColors.BG_CARD)
          .borderRadius(ThemeConstants.RADIUS_FULL)
          .border({
            width: 1,
            color: selected === item.id ? ThemeColors.PRIMARY : Color.Transparent
          })
          .onClick(() => {
            onSelect(item.id);
          })
      })
    }
    .width('100%')
    .flexWrap(FlexWrap.Wrap)
  }

  private async saveFish(): Promise<void> {
    if (!this.fishName.trim()) {
      console.info('请输入鱼种名称');
      return;
    }
    if (this.selectedWaterTypes.length === 0) {
      console.info('请选择适合水域');
      return;
    }

    // 解析喜食饵料
    const foodList = this.favoriteFood
      .split(/[、,，]/)
      .map((s: string) => s.trim())
      .filter((s: string) => s.length > 0);

    // 保存到 UserDataService
    await userDataService.addFish({
      name: this.fishName.trim(),
      nameEn: this.fishNameEn.trim(),
      waterTypes: [...this.selectedWaterTypes],
      feedingType: this.selectedFeedingType,
      waterLayer: this.selectedWaterLayer,
      activityTime: this.selectedActivityTime,
      preferredTemp: this.preferredTemp.trim(),
      favoriteFood: foodList,
      description: this.description.trim()
    });

    console.info('鱼种保存成功:', this.fishName);
    router.back();
  }
}
