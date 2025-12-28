/**
 * 饵知�?- 筛选面板组�?
 * 用于渔获记录的筛选功�?
 */
import { ThemeColors } from '../theme/ThemeColors';
import { ThemeConstants } from '../theme/ThemeConstants';

@Component
export struct FilterSheet {
  @Link visible: boolean;
  @Link filterFish: string;
  @Link filterLocation: string;
  @Prop fishOptions: string[] = [];
  @Prop locationOptions: string[] = [];
  onApply?: () => void;
  onReset?: () => void;

  @State tempFish: string = '';
  @State tempLocation: string = '';

  aboutToAppear(): void {
    this.tempFish = this.filterFish;
    this.tempLocation = this.filterLocation;
  }

  build() {
    if (this.visible) {
      Stack() {
        // 遮罩�?
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor(ThemeColors.OVERLAY)
          .onClick(() => {
            this.visible = false;
          })

        // 筛选面�?
        Column() {
          // 拖动�?
          Row() {
            Column()
              .width(40)
              .height(4)
              .backgroundColor(ThemeColors.DIVIDER)
              .borderRadius(2)
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .padding({ top: 12, bottom: 16 })

          // 标题�?
          Row() {
            Text('筛�?)
              .fontSize(ThemeConstants.FONT_SIZE_LG)
              .fontWeight(FontWeight.Bold)
              .fontColor(ThemeColors.TEXT_PRIMARY)

            Blank()

            Text('重置')
              .fontSize(ThemeConstants.FONT_SIZE_SM)
              .fontColor(ThemeColors.PRIMARY_DARK)
              .onClick(() => {
                this.tempFish = '';
                this.tempLocation = '';
                this.filterFish = '';
                this.filterLocation = '';
                if (this.onReset) {
                  this.onReset();
                }
              })
          }
          .width('100%')
          .padding({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD })

          // 鱼种筛�?
          Column({ space: 8 }) {
            Text('🐟 鱼种')
              .fontSize(ThemeConstants.FONT_SIZE_SM)
              .fontColor(ThemeColors.TEXT_SECONDARY)
              .width('100%')

            if (this.fishOptions.length > 0) {
              Scroll() {
                Row({ space: 8 }) {
                  // 全部选项
                  Text('全部')
                    .fontSize(ThemeConstants.FONT_SIZE_SM)
                    .fontColor(this.tempFish === '' ? ThemeColors.TEXT_PRIMARY : ThemeColors.TEXT_SECONDARY)
                    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                    .backgroundColor(this.tempFish === '' ? ThemeColors.PRIMARY : ThemeColors.BG_TERTIARY)
                    .borderRadius(ThemeConstants.RADIUS_FULL)
                    .onClick(() => {
                      this.tempFish = '';
                    })

                  ForEach(this.fishOptions, (fish: string) => {
                    Text(fish)
                      .fontSize(ThemeConstants.FONT_SIZE_SM)
                      .fontColor(this.tempFish === fish ? ThemeColors.TEXT_PRIMARY : ThemeColors.TEXT_SECONDARY)
                      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                      .backgroundColor(this.tempFish === fish ? ThemeColors.PRIMARY : ThemeColors.BG_TERTIARY)
                      .borderRadius(ThemeConstants.RADIUS_FULL)
                      .onClick(() => {
                        this.tempFish = fish;
                      })
                  })
                }
              }
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)
              .width('100%')
            } else {
              Text('暂无记录')
                .fontSize(ThemeConstants.FONT_SIZE_SM)
                .fontColor(ThemeColors.TEXT_MUTED)
            }
          }
          .width('100%')
          .padding({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD, top: ThemeConstants.SPACE_MD })

          // 钓点搜索
          Column({ space: 8 }) {
            Text('📍 钓点')
              .fontSize(ThemeConstants.FONT_SIZE_SM)
              .fontColor(ThemeColors.TEXT_SECONDARY)
              .width('100%')

            TextInput({ placeholder: '搜索钓点...', text: this.tempLocation })
              .fontSize(ThemeConstants.FONT_SIZE_BASE)
              .fontColor(ThemeColors.TEXT_PRIMARY)
              .placeholderColor(ThemeColors.TEXT_HINT)
              .backgroundColor(ThemeColors.BG_TERTIARY)
              .borderRadius(ThemeConstants.RADIUS_SM)
              .height(44)
              .padding({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD })
              .onChange((value: string) => {
                this.tempLocation = value;
              })

            // 常用钓点快捷选择
            if (this.locationOptions.length > 0) {
              Scroll() {
                Row({ space: 8 }) {
                  ForEach(this.locationOptions.slice(0, 5), (location: string) => {
                    Text(location)
                      .fontSize(ThemeConstants.FONT_SIZE_XS)
                      .fontColor(ThemeColors.TEXT_SECONDARY)
                      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                      .backgroundColor(ThemeColors.BG_TERTIARY)
                      .borderRadius(ThemeConstants.RADIUS_FULL)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .onClick(() => {
                        this.tempLocation = location;
                      })
                  })
                }
              }
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)
              .width('100%')
              .margin({ top: 8 })
            }
          }
          .width('100%')
          .padding({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD, top: ThemeConstants.SPACE_MD })

          // 应用按钮
          Button('应用筛�?)
            .fontSize(ThemeConstants.FONT_SIZE_MD)
            .fontColor(Color.White)
            .backgroundColor(ThemeColors.PRIMARY)
            .borderRadius(ThemeConstants.RADIUS_MD)
            .width('90%')
            .height(48)
            .margin({ top: ThemeConstants.SPACE_XL, bottom: ThemeConstants.SPACE_MD })
            .onClick(() => {
              this.filterFish = this.tempFish;
              this.filterLocation = this.tempLocation;
              this.visible = false;
              if (this.onApply) {
                this.onApply();
              }
            })
        }
        .width('100%')
        .backgroundColor(ThemeColors.BG_CARD)
        .borderRadius({ topLeft: ThemeConstants.RADIUS_LG, topRight: ThemeConstants.RADIUS_LG })
        .position({ x: 0, y: '100%' })
        .translate({ y: -380 })
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
    }
  }
}
