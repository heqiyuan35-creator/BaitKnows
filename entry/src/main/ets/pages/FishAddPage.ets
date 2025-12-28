/**
 * 饵知�?- 鱼类新增页面
 * 用户自定义添加鱼种数�?
 */
import { router } from '@kit.ArkUI';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { ThemeColors } from '../theme/ThemeColors';
import { ThemeConstants } from '../theme/ThemeConstants';
import { userDataService } from '../services/UserDataService';

// 选项�?
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
  @State selectedTempRange: string = 'medium';  // 适宜水温范围
  @State selectedFoods: string[] = [];  // 喜食饵料（多选）
  @State description: string = '';
  @State fishIcon: string = '';  // 鱼种图标路径
  @State showToast: boolean = false;
  @State toastMessage: string = '';
  @State isSaving: boolean = false;

  private waterTypes: SelectOption[] = [
    makeOption('pond', '池塘'),
    makeOption('river', '河流'),
    makeOption('reservoir', '水库'),
    makeOption('lake', '湖泊')
  ];

  private feedingTypes: SelectOption[] = [
    makeOption('herbivore', '草食�?),
    makeOption('carnivore', '肉食�?),
    makeOption('omnivore', '杂食�?)
  ];

  private waterLayers: SelectOption[] = [
    makeOption('surface', '上层'),
    makeOption('middle', '中层'),
    makeOption('bottom', '底层'),
    makeOption('all', '全水�?)
  ];

  private activityTimes: SelectOption[] = [
    makeOption('day', '白天'),
    makeOption('night', '夜间'),
    makeOption('dawn_dusk', '晨昏'),
    makeOption('all', '全天')
  ];

  // 适宜水温范围选项
  private tempRanges: SelectOption[] = [
    makeOption('cold', '低温 (5-15°C)'),
    makeOption('cool', '凉爽 (10-20°C)'),
    makeOption('medium', '适中 (15-25°C)'),
    makeOption('warm', '温暖 (20-30°C)'),
    makeOption('hot', '高温 (25-35°C)')
  ];

  // 喜食饵料选项
  private foodOptions: SelectOption[] = [
    makeOption('earthworm', '蚯蚓'),
    makeOption('bloodworm', '红虫'),
    makeOption('corn', '玉米'),
    makeOption('wheat', '小麦'),
    makeOption('pellet', '颗粒饲料'),
    makeOption('dough', '面饵'),
    makeOption('shrimp', '�?),
    makeOption('snail', '螺蛳'),
    makeOption('grass', '水草'),
    makeOption('insect', '昆虫'),
    makeOption('fish', '小鱼'),
    makeOption('commercial', '商品�?)
  ];

  build() {
    Column() {
      // 顶部导航�?
      this.NavBar()

      // 表单内容
      Scroll() {
        Column({ space: 20 }) {
          // 鱼种图片
          this.FishIconSection()

          // 鱼种名称
          this.FishNameSection()

          // 英文�?
          this.FishNameEnSection()

          // 适合水域
          this.WaterTypeSection()

          // 食�?
          this.FeedingTypeSection()

          // 活动水层
          this.WaterLayerSection()

          // 活动时段
          this.ActivityTimeSection()

          // 适宜水温
          this.TempSection()

          // 喜食饵料
          this.FavoriteFoodSection()

          // 习性描�?
          this.DescriptionSection()

          // 保存按钮
          Button('保存鱼种')
            .width('100%')
            .height(48)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .backgroundColor(this.isSaving ? ThemeColors.TEXT_MUTED : ThemeColors.PRIMARY)
            .fontColor(ThemeColors.TEXT_PRIMARY)
            .margin({ top: 16, bottom: 32 })
            .enabled(!this.isSaving)
            .onClick(() => this.saveFish())
        }
        .padding(16)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      // Toast 提示
      if (this.showToast) {
        Column() {
          Text(this.toastMessage)
            .fontSize(14)
            .fontColor(Color.White)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor('rgba(0, 0, 0, 0.7)')
            .borderRadius(20)
        }
        .width('100%')
        .position({ x: 0, y: '40%' })
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeColors.BG_PRIMARY)
  }

  @Builder
  FishIconSection() {
    Column({ space: 8 }) {
      Text('鱼种图片')
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .fontWeight(FontWeight.Medium)

      Row() {
        if (this.fishIcon) {
          // 已选择图片
          Stack() {
            Image(this.fishIcon)
              .width(100)
              .height(100)
              .borderRadius(12)
              .objectFit(ImageFit.Cover)

            // 删除按钮
            Text('×')
              .fontSize(16)
              .fontColor(Color.White)
              .width(24)
              .height(24)
              .textAlign(TextAlign.Center)
              .backgroundColor('rgba(0,0,0,0.5)')
              .borderRadius(12)
              .position({ x: 76, y: 0 })
              .onClick(() => {
                this.fishIcon = '';
              })
          }
          .width(100)
          .height(100)
        } else {
          // 上传占位
          Column({ space: 8 }) {
            Image($r('app.media.fishImage'))
              .width(48)
              .height(48)
              .objectFit(ImageFit.Contain)

            Text('点击上传')
              .fontSize(12)
              .fontColor(ThemeColors.TEXT_MUTED)
          }
          .width(100)
          .height(100)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(ThemeColors.BG_CARD)
          .borderRadius(12)
          .border({ width: 1, color: ThemeColors.PRIMARY, style: BorderStyle.Dashed })
          .onClick(() => {
            // 调用图片选择�?
            this.selectImageFromGallery();
          })
        }

        // 提示文字
        Column({ space: 4 }) {
          Text('建议上传正方形图�?)
            .fontSize(12)
            .fontColor(ThemeColors.TEXT_MUTED)

          Text('支持 JPG、PNG 格式')
            .fontSize(12)
            .fontColor(ThemeColors.TEXT_MUTED)

          Text('不上传将使用默认图标')
            .fontSize(12)
            .fontColor(ThemeColors.TEXT_HINT)
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 16 })
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  NavBar() {
    Row() {
      Text('�?)
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
    .margin({ top: 44 })
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
      Text('食�?*')
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

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.tempRanges, (item: SelectOption) => {
          Text(item.name)
            .fontSize(ThemeConstants.FONT_SIZE_SM)
            .fontColor(this.selectedTempRange === item.id ? ThemeColors.PRIMARY : ThemeColors.TEXT_SECONDARY)
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .backgroundColor(this.selectedTempRange === item.id ? 'rgba(232, 168, 73, 0.15)' : ThemeColors.BG_CARD)
            .borderRadius(ThemeConstants.RADIUS_FULL)
            .border({
              width: 1,
              color: this.selectedTempRange === item.id ? ThemeColors.PRIMARY : Color.Transparent
            })
            .margin({ right: 8, bottom: 8 })
            .onClick(() => {
              this.selectedTempRange = item.id;
            })
        })
      }
      .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  FavoriteFoodSection() {
    Column({ space: 8 }) {
      Text('喜食饵料（可多选）')
        .fontSize(ThemeConstants.FONT_SIZE_SM)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .fontWeight(FontWeight.Medium)

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.foodOptions, (item: SelectOption) => {
          Row() {
            Checkbox()
              .select(this.selectedFoods.includes(item.id))
              .selectedColor(ThemeColors.PRIMARY)
              .width(16)
              .height(16)
              .onChange((checked: boolean) => {
                if (checked) {
                  this.selectedFoods.push(item.id);
                } else {
                  const idx = this.selectedFoods.indexOf(item.id);
                  if (idx > -1) {
                    this.selectedFoods.splice(idx, 1);
                  }
                }
                this.selectedFoods = this.selectedFoods.slice();
              })

            Text(item.name)
              .fontSize(ThemeConstants.FONT_SIZE_SM)
              .fontColor(ThemeColors.TEXT_PRIMARY)
              .margin({ left: 4 })
          }
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .backgroundColor(this.selectedFoods.includes(item.id) ? 'rgba(232, 168, 73, 0.15)' : ThemeColors.BG_CARD)
          .borderRadius(ThemeConstants.RADIUS_SM)
          .margin({ right: 8, bottom: 8 })
        })
      }
      .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  DescriptionSection() {
    Column({ space: 8 }) {
      Text('习性描�?)
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
    Row({ space: 8 }) {
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
    Row({ space: 8 }) {
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
    Row({ space: 8 }) {
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
    if (this.isSaving) return;

    // 验证名称
    const trimmedName = this.fishName.trim();
    if (!trimmedName) {
      this.showToastMessage('请输入鱼种名�?);
      return;
    }

    if (trimmedName.length < 2) {
      this.showToastMessage('鱼种名称至少2个字�?);
      return;
    }

    // 验证水域
    if (this.selectedWaterTypes.length === 0) {
      this.showToastMessage('请选择适合水域');
      return;
    }

    this.isSaving = true;

    try {
      // 保存�?UserDataService（包含图片路径）
      await userDataService.addFish(
        trimmedName,
        this.fishNameEn.trim(),
        this.fishIcon,  // 图片路径
        this.selectedWaterTypes.slice(),
        this.selectedFeedingType,
        this.selectedWaterLayer,
        this.selectedActivityTime,
        this.selectedTempRange,  // 适宜水温范围
        this.selectedFoods.slice(),  // 喜食饵料（多选）
        this.description.trim()
      );

      this.showToastMessage('鱼种保存成功');

      setTimeout(() => {
        router.back();
      }, 800);

    } catch (error) {
      console.error('保存鱼种失败:', error);
      this.showToastMessage('保存失败，请重试');
      this.isSaving = false;
    }
  }

  // 从相册选择图片
  private selectImageFromGallery(): void {
    const photoPicker = new photoAccessHelper.PhotoViewPicker();
    photoPicker.select({
      MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE,
      maxSelectNumber: 1
    }).then((res: photoAccessHelper.PhotoSelectResult) => {
      if (res.photoUris && res.photoUris.length > 0) {
        this.fishIcon = res.photoUris[0];
        this.showToastMessage('图片选择成功');
      }
    }).catch((err: Error) => {
      console.error('选择图片失败:', err);
      this.showToastMessage('选择图片失败');
    });
  }

  private showToastMessage(message: string): void {
    this.toastMessage = message;
    this.showToast = true;
    setTimeout(() => {
      this.showToast = false;
    }, 2000);
  }
}
