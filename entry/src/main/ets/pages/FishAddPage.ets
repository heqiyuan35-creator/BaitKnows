/**
 * 饵知道 - 鱼类新增页面
 * 用户自定义添加鱼种数据
 */
import { router } from '@kit.ArkUI';
import { ThemeColors } from '../theme/ThemeColors';
import { ThemeConstants } from '../theme/ThemeConstants';
import { userDataService } from '../services/UserDataService';

// 选项类
class SelectOption {
  id: string = '';
  name: string = '';
}

// 创建选项辅助函数
function makeOption(id: string, name: string): SelectOption {
  const opt = new SelectOption();
  opt.id = id;
  opt.name = name;
  return opt;
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
    makeOption('pond', '池塘'),
    makeOption('river', '河流'),
    makeOption('reservoir', '水库'),
    makeOption('lake', '湖泊')
  ];

  private feedingTypes: SelectOption[] = [
    makeOption('herbivore', '草食性'),
    makeOption('carnivore', '肉食性'),
    makeOption('omnivore', '杂食性')
  ];

  private waterLayers: SelectOption[] = [
    makeOption('surface', '上层'),
    makeOption('middle', '中层'),
    makeOption('bottom', '底层'),
    makeOption('all', '全水层')
  ];

  private activityTimes: SelectOption[] = [
    makeOption('day', '白天'),
    makeOption('night', '夜间'),
    makeOption('dawn_dusk', '晨昏'),
    makeOption('all', '全天')
  ];

  build() {
    Column() {
      // 顶部导航栏
      this.NavBar()

      // 表单内容
      Scroll() {
        Column({ space: 20 }) {
          // 鱼种名称
          this.FishNameSection()

          // 英文名
          this.FishNameEnSection()

          // 适合水域
          this.WaterTypeSection()

          // 食性
          this.FeedingTypeSection()

          // 活动水层
          this.WaterLayerSection()

          // 活动时段
          this.ActivityTimeSection()

          // 适宜水温
          this.TempSection()

          // 喜食饵料
          this.FavoriteFoodSection()

          // 习性描述
          this.DescriptionSection()

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
  FishNameSection() {
    Column({ space: 8 }) {
      Text('鱼种名称 *')
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .fontWeight(FontWeight.Medium)

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
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  FishNameEnSection() {
    Column({ space: 8 }) {
      Text('英文名（可选）')
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .fontWeight(FontWeight.Medium)

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
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  WaterTypeSection() {
    Column({ space: 8 }) {
      Text('适合水域 *')
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .fontWeight(FontWeight.Medium)

      this.WaterTypeSelector()
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  FeedingTypeSection() {
    Column({ space: 8 }) {
      Text('食性 *')
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .fontWeight(FontWeight.Medium)

      this.FeedingTypeSelector()
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  WaterLayerSection() {
    Column({ space: 8 }) {
      Text('活动水层')
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .fontWeight(FontWeight.Medium)

      this.WaterLayerSelector()
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  ActivityTimeSection() {
    Column({ space: 8 }) {
      Text('活动时段')
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .fontWeight(FontWeight.Medium)

      this.ActivityTimeSelector()
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  TempSection() {
    Column({ space: 8 }) {
      Text('适宜水温')
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .fontWeight(FontWeight.Medium)

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
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  FavoriteFoodSection() {
    Column({ space: 8 }) {
      Text('喜食饵料')
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .fontWeight(FontWeight.Medium)

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
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  DescriptionSection() {
    Column({ space: 8 }) {
      Text('习性描述')
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .fontWeight(FontWeight.Medium)

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
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  WaterTypeSelector() {
    // 使用 Flex 替代 Row + flexWrap
    Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(8), cross: LengthMetrics.vp(8) } }) {
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
              this.selectedWaterTypes = this.selectedWaterTypes.slice();
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
  }

  @Builder
  FeedingTypeSelector() {
    Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(8), cross: LengthMetrics.vp(8) } }) {
      ForEach(this.feedingTypes, (item: SelectOption) => {
        Text(item.name)
          .fontSize(ThemeConstants.FONT_SIZE_SM)
          .fontColor(this.selectedFeedingType === item.id ? ThemeColors.PRIMARY : ThemeColors.TEXT_SECONDARY)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .backgroundColor(this.selectedFeedingType === item.id ? 'rgba(232, 168, 73, 0.15)' : ThemeColors.BG_CARD)
          .borderRadius(ThemeConstants.RADIUS_FULL)
          .border({
            width: 1,
            color: this.selectedFeedingType === item.id ? ThemeColors.PRIMARY : Color.Transparent
          })
          .onClick(() => {
            this.selectedFeedingType = item.id;
          })
      })
    }
    .width('100%')
  }

  @Builder
  WaterLayerSelector() {
    Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(8), cross: LengthMetrics.vp(8) } }) {
      ForEach(this.waterLayers, (item: SelectOption) => {
        Text(item.name)
          .fontSize(ThemeConstants.FONT_SIZE_SM)
          .fontColor(this.selectedWaterLayer === item.id ? ThemeColors.PRIMARY : ThemeColors.TEXT_SECONDARY)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .backgroundColor(this.selectedWaterLayer === item.id ? 'rgba(232, 168, 73, 0.15)' : ThemeColors.BG_CARD)
          .borderRadius(ThemeConstants.RADIUS_FULL)
          .border({
            width: 1,
            color: this.selectedWaterLayer === item.id ? ThemeColors.PRIMARY : Color.Transparent
          })
          .onClick(() => {
            this.selectedWaterLayer = item.id;
          })
      })
    }
    .width('100%')
  }

  @Builder
  ActivityTimeSelector() {
    Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(8), cross: LengthMetrics.vp(8) } }) {
      ForEach(this.activityTimes, (item: SelectOption) => {
        Text(item.name)
          .fontSize(ThemeConstants.FONT_SIZE_SM)
          .fontColor(this.selectedActivityTime === item.id ? ThemeColors.PRIMARY : ThemeColors.TEXT_SECONDARY)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .backgroundColor(this.selectedActivityTime === item.id ? 'rgba(232, 168, 73, 0.15)' : ThemeColors.BG_CARD)
          .borderRadius(ThemeConstants.RADIUS_FULL)
          .border({
            width: 1,
            color: this.selectedActivityTime === item.id ? ThemeColors.PRIMARY : Color.Transparent
          })
          .onClick(() => {
            this.selectedActivityTime = item.id;
          })
      })
    }
    .width('100%')
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
    const foodList: string[] = [];
    const parts = this.favoriteFood.split(/[、,，]/);
    for (let i = 0; i < parts.length; i++) {
      const s = parts[i].trim();
      if (s.length > 0) {
        foodList.push(s);
      }
    }

    // 保存到 UserDataService
    await userDataService.addFish(
      this.fishName.trim(),
      this.fishNameEn.trim(),
      this.selectedWaterTypes.slice(),
      this.selectedFeedingType,
      this.selectedWaterLayer,
      this.selectedActivityTime,
      this.preferredTemp.trim(),
      foodList,
      this.description.trim()
    );

    console.info('鱼种保存成功:', this.fishName);
    router.back();
  }
}
