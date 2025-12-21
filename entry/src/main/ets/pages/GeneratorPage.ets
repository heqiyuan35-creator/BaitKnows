/**
 * 饵知道 - 智能生成页面
 * 选择条件后生成配方
 */
import { ThemeColors } from '../theme/ThemeColors';
import { ThemeConstants } from '../theme/ThemeConstants';
import { Router, RouteParams } from '../router/Router';
import { AppConstants } from '../common/constants/AppConstants';

// 选项接口
interface SelectOption {
  id: string;
  name: string;
  icon: Resource;
  iconSelected: Resource;
}

@Component
export struct GeneratorPage {
  @State selectedFish: string = '';
  @State selectedWater: string = '';
  @State selectedSeason: string = '';
  @State isGenerating: boolean = false;

  private fishOptions: SelectOption[] = [
    { id: 'carp', name: '鲤鱼', icon: $r('app.media.Fish'), iconSelected: $r('app.media.Fishs') },
    { id: 'crucian', name: '鲫鱼', icon: $r('app.media.Fish'), iconSelected: $r('app.media.Fishs') },
    { id: 'grass', name: '草鱼', icon: $r('app.media.Fish'), iconSelected: $r('app.media.Fishs') },
    { id: 'silver', name: '鲢鱼', icon: $r('app.media.Fish'), iconSelected: $r('app.media.Fishs') }
  ];

  private waterOptions: SelectOption[] = [
    { id: 'pond', name: '池塘', icon: $r('app.media.Pond'), iconSelected: $r('app.media.Ponds') },
    { id: 'river', name: '河流', icon: $r('app.media.River'), iconSelected: $r('app.media.Rivers') },
    { id: 'reservoir', name: '水库', icon: $r('app.media.Reservoir'), iconSelected: $r('app.media.Reservoirs') },
    { id: 'lake', name: '湖泊', icon: $r('app.media.Lake'), iconSelected: $r('app.media.Lakes') }
  ];

  private seasonOptions: SelectOption[] = [
    { id: 'spring', name: '春季', icon: $r('app.media.Spring'), iconSelected: $r('app.media.Springs') },
    { id: 'summer', name: '夏季', icon: $r('app.media.Summer'), iconSelected: $r('app.media.Summers') },
    { id: 'autumn', name: '秋季', icon: $r('app.media.Autumn'), iconSelected: $r('app.media.Autumns') },
    { id: 'winter', name: '冬季', icon: $r('app.media.Winter'), iconSelected: $r('app.media.Winters') }
  ];

  build() {
    Column() {
      // 标题
      Text('智能配方生成')
        .fontSize(ThemeConstants.FONT_SIZE_XL)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeColors.TEXT_PRIMARY)
        .margin({ top: 60, bottom: ThemeConstants.SPACE_LG })

      Scroll() {
        Column({ space: ThemeConstants.SPACE_LG }) {
          // 选择目标鱼种
          this.SelectorSection('🐟 目标鱼种', this.fishOptions, this.selectedFish, (id: string) => {
            this.selectedFish = id;
          })

          // 选择水域类型
          this.SelectorSection('💧 水域类型', this.waterOptions, this.selectedWater, (id: string) => {
            this.selectedWater = id;
          })

          // 选择季节
          this.SelectorSection('🍂 当前季节', this.seasonOptions, this.selectedSeason, (id: string) => {
            this.selectedSeason = id;
          })

          // 生成按钮
          this.GenerateButton()
        }
        .padding({ left: ThemeConstants.SPACE_MD, right: ThemeConstants.SPACE_MD, bottom: 100 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeColors.BG_PRIMARY)
  }


  @Builder
  SelectorSection(title: string, options: SelectOption[], selected: string, onSelect: (id: string) => void) {
    Column({ space: ThemeConstants.SPACE_SM }) {
      Text(title)
        .fontSize(ThemeConstants.FONT_SIZE_MD)
        .fontWeight(FontWeight.Medium)
        .fontColor(ThemeColors.TEXT_PRIMARY)
        .width('100%')

      Row({ space: ThemeConstants.SPACE_SM }) {
        ForEach(options, (option: SelectOption) => {
          Column({ space: 6 }) {
            Image(selected === option.id ? option.iconSelected : option.icon)
              .width(36)
              .height(36)
              .fillColor(selected === option.id ? ThemeColors.PRIMARY : ThemeColors.TEXT_SECONDARY)

            Text(option.name)
              .fontSize(ThemeConstants.FONT_SIZE_SM)
              .fontColor(selected === option.id ? ThemeColors.PRIMARY : ThemeColors.TEXT_SECONDARY)
          }
          .layoutWeight(1)
          .padding({ top: 12, bottom: 12 })
          .backgroundColor(selected === option.id ? ThemeColors.BG_TERTIARY : ThemeColors.BG_CARD)
          .borderRadius(ThemeConstants.RADIUS_SM)
          .border({
            width: selected === option.id ? 2 : 0,
            color: ThemeColors.PRIMARY
          })
          .onClick(() => {
            onSelect(option.id);
          })
        })
      }
      .width('100%')
    }
  }

  @Builder
  GenerateButton() {
    Column({ space: ThemeConstants.SPACE_SM }) {
      Button() {
        Row({ space: 8 }) {
          if (this.isGenerating) {
            LoadingProgress()
              .width(20)
              .height(20)
              .color(ThemeColors.TEXT_PRIMARY)
          }
          Text(this.isGenerating ? '生成中...' : '✨ 一键生成配方')
            .fontSize(ThemeConstants.FONT_SIZE_MD)
            .fontWeight(FontWeight.Medium)
            .fontColor(ThemeColors.TEXT_PRIMARY)
        }
      }
      .width('100%')
      .height(52)
      .backgroundColor(this.canGenerate() ? ThemeColors.PRIMARY : ThemeColors.BG_TERTIARY)
      .borderRadius(ThemeConstants.RADIUS_MD)
      .enabled(this.canGenerate() && !this.isGenerating)
      .onClick(() => {
        this.generateRecipe();
      })

      if (!this.canGenerate()) {
        Text('请选择所有条件后生成')
          .fontSize(ThemeConstants.FONT_SIZE_XS)
          .fontColor(ThemeColors.TEXT_MUTED)
      }
    }
    .margin({ top: ThemeConstants.SPACE_MD })
  }

  private canGenerate(): boolean {
    return this.selectedFish !== '' && this.selectedWater !== '' && this.selectedSeason !== '';
  }

  private generateRecipe(): void {
    this.isGenerating = true;

    // 模拟生成延迟
    setTimeout(() => {
      this.isGenerating = false;
      const params = new RouteParams();
      params.fish = this.selectedFish;
      params.water = this.selectedWater;
      params.season = this.selectedSeason;
      Router.push(AppConstants.ROUTE_GENERATED_RECIPE, params);
    }, 1500);
  }
}
