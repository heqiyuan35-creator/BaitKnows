/**
 * 饵知道 - 配方详情页
 * 参考设计图重新设计
 */
import { ThemeColors } from '../theme/ThemeColors';
import { ThemeConstants } from '../theme/ThemeConstants';
import { Router } from '../router/Router';

// 配方材料接口
interface RecipeIngredient {
  name: string;
  amount: string;
  unit: string;
}

// 配方详情接口
interface RecipeDetail {
  id: string;
  name: string;
  description: string;
  targetFish: string[];
  waterTypes: string[];
  seasons: string[];
  difficulty: string;
  prepTime: string;
  ingredients: RecipeIngredient[];
  steps: string[];
  tips: string[];
  rating: number;
  usageCount: number;
  // 味型特点
  flavorPrimary: string;
  flavorIntensity: number;
  suitableTemp: string;
  // 状态特性
  atomization: number;
  viscosity: number;
  hookHolding: number;
  weight: number;
  // 推荐理由
  reasons: RecommendReason[];
}

interface RecommendReason {
  title: string;
  description: string;
}

@Entry
@Component
struct RecipeDetailPage {
  @State recipe: RecipeDetail = {
    id: 'recipe_001',
    name: '经典玉米酒香饵',
    description: '专为水库湖泊钓鲤鱼设计，酒香味型，适合15-25°C水温使用。',
    targetFish: ['鲤鱼', '草鱼', '鲫鱼'],
    waterTypes: ['水库', '湖泊'],
    seasons: ['春季', '秋季'],
    difficulty: '简单',
    prepTime: '15分钟',
    ingredients: [
      { name: '玉米粉', amount: '300', unit: 'g' },
      { name: '面粉', amount: '100', unit: 'g' },
      { name: '白酒', amount: '50', unit: 'ml' },
      { name: '蜂蜜', amount: '20', unit: 'ml' },
      { name: '玉米香精', amount: '3', unit: 'ml' }
    ],
    steps: [
      '将玉米粉和面粉按3:1比例混合',
      '加入适量温水，搅拌成糊状',
      '倒入白酒和蜂蜜，充分搅拌',
      '加入玉米香精，揉成软硬适中的面团',
      '密封静置30分钟后使用'
    ],
    tips: [
      '白酒选用52度以上的高度酒效果更好',
      '面团不宜太硬，否则入水后不易雾化',
      '可根据水温调整蜂蜜用量，水温低多加'
    ],
    rating: 4.8,
    usageCount: 1256,
    flavorPrimary: '酒香',
    flavorIntensity: 4,
    suitableTemp: '15-25°C',
    atomization: 3,
    viscosity: 4,
    hookHolding: 4,
    weight: 3,
    reasons: [
      { title: '水温适中(18°C)', description: '酒香浓郁，快速诱鱼' },
      { title: '水库深水环境', description: '增加粘度，慢雾化留鱼' },
      { title: '目标鲤鱼', description: '甜香为主，大颗粒' }
    ]
  };
  @State isFavorite: boolean = false;
  @State currentTab: number = 0;

  private tabTitles: string[] = ['概览', '配料', '步骤'];

  build() {
    Column() {
      this.HeaderBar()

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
        }
        .width('100%')
        .padding({ bottom: 100 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFBF5')
  }

  @Builder
  HeaderBar() {
    Row() {
      Row() {
        Text('←')
          .fontSize(22)
          .fontColor(ThemeColors.TEXT_PRIMARY)
      }
      .width(40)
      .height(40)
      .justifyContent(FlexAlign.Center)
      .onClick(() => Router.back())

      Blank()

      Text('配方详情')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor(ThemeColors.TEXT_PRIMARY)

      Blank()

      Row() {
        Text(this.isFavorite ? '♥' : '♡')
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

  @Builder
  RecipeHeader() {
    Column({ space: 12 }) {
      // 配方名称和评分
      Row() {
        Text(this.recipe.name)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.TEXT_PRIMARY)
          .layoutWeight(1)

        Row({ space: 4 }) {
          Text('☆')
            .fontSize(18)
            .fontColor(ThemeColors.PRIMARY)
          Text(this.recipe.rating.toString())
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.PRIMARY)
        }
      }
      .width('100%')

      // 配方描述
      Text(this.recipe.description)
        .fontSize(14)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .lineHeight(20)

      // 标签行
      Row({ space: 16 }) {
        this.InfoTag('⏱️', this.recipe.prepTime)
        this.InfoTag('📊', this.recipe.difficulty)
        this.InfoTag('👥', `${this.recipe.usageCount}人使用`)
      }
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 16, bottom: 20 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  InfoTag(icon: string, text: string) {
    Row({ space: 4 }) {
      Text(icon)
        .fontSize(12)
      Text(text)
        .fontSize(12)
        .fontColor(ThemeColors.TEXT_SECONDARY)
    }
    .padding({ left: 10, right: 10, top: 6, bottom: 6 })
    .backgroundColor(Color.White)
    .borderRadius(16)
  }

  @Builder
  TabNavigation() {
    Row({ space: 0 }) {
      ForEach(this.tabTitles, (title: string, index: number) => {
        Column() {
          Text(title)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.currentTab === index ? ThemeColors.PRIMARY : '#999999')
        }
        .layoutWeight(1)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(this.currentTab === index ? Color.White : Color.Transparent)
        .borderRadius(22)
        .onClick(() => { this.currentTab = index; })
      })
    }
    .width('100%')
    .height(52)
    .padding({ left: 20, right: 20 })
    .backgroundColor(Color.White)
  }

  // ========== 概览Tab ==========
  @Builder
  OverviewContent() {
    Column({ space: 16 }) {
      // 标签信息卡片
      this.TagsCard()

      // 味型特点卡片
      this.FlavorCard()

      // 状态特性卡片
      this.StateCard()

      // 推荐理由
      this.ReasonsCard()
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 16 })
  }

  @Builder
  TagsCard() {
    Column({ space: 12 }) {
      // 目标鱼种
      Row({ space: 12 }) {
        Row({ space: 4 }) {
          Text('🐟')
            .fontSize(14)
          Text('目标鱼种')
            .fontSize(14)
            .fontColor(ThemeColors.TEXT_SECONDARY)
        }
        .width(90)

        Row({ space: 8 }) {
          ForEach(this.recipe.targetFish, (fish: string) => {
            Text(fish)
              .fontSize(13)
              .fontColor(ThemeColors.PRIMARY)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .borderRadius(16)
              .border({ width: 1, color: ThemeColors.PRIMARY })
          })
        }
      }
      .width('100%')

      // 适用水域
      Row({ space: 12 }) {
        Row({ space: 4 }) {
          Text('💧')
            .fontSize(14)
          Text('适用水域')
            .fontSize(14)
            .fontColor(ThemeColors.TEXT_SECONDARY)
        }
        .width(90)

        Row({ space: 8 }) {
          ForEach(this.recipe.waterTypes, (water: string) => {
            Text(water)
              .fontSize(13)
              .fontColor(ThemeColors.TEXT_PRIMARY)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .backgroundColor(ThemeColors.BG_TERTIARY)
              .borderRadius(16)
          })
        }
      }
      .width('100%')

      // 适用季节
      Row({ space: 12 }) {
        Row({ space: 4 }) {
          Text('🍂')
            .fontSize(14)
          Text('适用季节')
            .fontSize(14)
            .fontColor(ThemeColors.TEXT_SECONDARY)
        }
        .width(90)

        Row({ space: 8 }) {
          ForEach(this.recipe.seasons, (season: string) => {
            Text(season)
              .fontSize(13)
              .fontColor(ThemeColors.TEXT_PRIMARY)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .backgroundColor(ThemeColors.BG_TERTIARY)
              .borderRadius(16)
          })
        }
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
  }

  @Builder
  FlavorCard() {
    Column({ space: 16 }) {
      Text('味型特点')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(ThemeColors.TEXT_PRIMARY)

      Row() {
        // 主味型
        Column({ space: 4 }) {
          Text('主味型')
            .fontSize(12)
            .fontColor(ThemeColors.TEXT_MUTED)
          Text(this.recipe.flavorPrimary)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.PRIMARY)
        }
        .layoutWeight(1)

        // 浓度
        Column({ space: 4 }) {
          Text('浓度')
            .fontSize(12)
            .fontColor(ThemeColors.TEXT_MUTED)
          Row({ space: 3 }) {
            ForEach([1, 2, 3, 4, 5], (i: number) => {
              Circle()
                .width(8)
                .height(8)
                .fill(i <= this.recipe.flavorIntensity ? ThemeColors.PRIMARY : '#E5E5E5')
            })
          }
        }
        .layoutWeight(1)

        // 适用水温
        Column({ space: 4 }) {
          Text('适用水温')
            .fontSize(12)
            .fontColor(ThemeColors.TEXT_MUTED)
          Text(this.recipe.suitableTemp)
            .fontSize(16)
            .fontColor(ThemeColors.TEXT_PRIMARY)
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  StateCard() {
    Column({ space: 16 }) {
      Text('状态特性')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(ThemeColors.TEXT_PRIMARY)

      Row() {
        this.StateItem('雾化', this.recipe.atomization)
        this.StateItem('粘度', this.recipe.viscosity)
        this.StateItem('持钩', this.recipe.hookHolding)
        this.StateItem('比重', this.recipe.weight)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  StateItem(label: string, value: number) {
    Column({ space: 8 }) {
      Text(label)
        .fontSize(12)
        .fontColor(ThemeColors.TEXT_MUTED)

      // 进度条
      Stack({ alignContent: Alignment.Start }) {
        Row()
          .width('100%')
          .height(6)
          .borderRadius(3)
          .backgroundColor('#F0F0F0')
        Row()
          .width(`${value * 20}%`)
          .height(6)
          .borderRadius(3)
          .backgroundColor(ThemeColors.PRIMARY)
      }
      .width('100%')

      Text(`${value}/5`)
        .fontSize(11)
        .fontColor(ThemeColors.TEXT_MUTED)
    }
    .layoutWeight(1)
    .padding({ left: 4, right: 4 })
  }

  @Builder
  ReasonsCard() {
    Column({ space: 12 }) {
      Text('为什么推荐')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(ThemeColors.TEXT_PRIMARY)

      ForEach(this.recipe.reasons, (reason: RecommendReason, index: number) => {
        Row({ space: 12 }) {
          // 编号圆圈
          Row() {
            Text(`${index + 1}`)
              .fontSize(12)
              .fontColor(Color.White)
          }
          .width(24)
          .height(24)
          .borderRadius(12)
          .backgroundColor(ThemeColors.PRIMARY)
          .justifyContent(FlexAlign.Center)

          Column({ space: 2 }) {
            Text(reason.title)
              .fontSize(14)
              .fontColor(ThemeColors.TEXT_PRIMARY)
            Text(reason.description)
              .fontSize(13)
              .fontColor(ThemeColors.PRIMARY)
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
  @Builder
  IngredientsContent() {
    Column({ space: 16 }) {
      // 材料清单标题
      Row({ space: 8 }) {
        Text('📦')
          .fontSize(18)
        Text('材料清单')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(ThemeColors.TEXT_PRIMARY)
      }
      .width('100%')
      .padding({ left: 4 })

      // 材料列表
      Column({ space: 0 }) {
        ForEach(this.recipe.ingredients, (item: RecipeIngredient, index: number) => {
          Row() {
            Text(item.name)
              .fontSize(15)
              .fontColor(ThemeColors.TEXT_PRIMARY)
            Blank()
            Text(`${item.amount}${item.unit}`)
              .fontSize(15)
              .fontColor(ThemeColors.PRIMARY)
          }
          .width('100%')
          .padding({ top: 16, bottom: 16, left: 16, right: 16 })
          .border({
            width: { bottom: index < this.recipe.ingredients.length - 1 ? 1 : 0 },
            color: '#F5F5F5'
          })
        })
      }
      .width('100%')
      .backgroundColor(Color.White)
      .borderRadius(12)
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 16 })
  }

  // ========== 步骤Tab ==========
  @Builder
  StepsContent() {
    Column({ space: 16 }) {
      // 制作步骤
      Column({ space: 16 }) {
        Row({ space: 8 }) {
          Text('📝')
            .fontSize(18)
          Text('制作步骤')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(ThemeColors.TEXT_PRIMARY)
        }
        .width('100%')

        ForEach(this.recipe.steps, (step: string, index: number) => {
          Row({ space: 12 }) {
            // 步骤编号
            Row() {
              Text(`${index + 1}`)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor(Color.White)
            }
            .width(28)
            .height(28)
            .borderRadius(14)
            .backgroundColor(ThemeColors.PRIMARY)
            .justifyContent(FlexAlign.Center)

            Text(step)
              .fontSize(14)
              .fontColor(ThemeColors.TEXT_PRIMARY)
              .lineHeight(20)
              .layoutWeight(1)
          }
          .width('100%')
          .padding({ top: 8, bottom: 8 })
          .alignItems(VerticalAlign.Top)
        })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .borderRadius(12)
      .alignItems(HorizontalAlign.Start)

      // 使用技巧
      Column({ space: 12 }) {
        Row({ space: 8 }) {
          Text('💡')
            .fontSize(18)
          Text('使用技巧')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(ThemeColors.TEXT_PRIMARY)
        }
        .width('100%')

        Column({ space: 8 }) {
          ForEach(this.recipe.tips, (tip: string) => {
            Row({ space: 8 }) {
              Text('•')
                .fontSize(14)
                .fontColor(ThemeColors.PRIMARY)
              Text(tip)
                .fontSize(13)
                .fontColor(ThemeColors.TEXT_SECONDARY)
                .layoutWeight(1)
                .lineHeight(18)
            }
            .width('100%')
          })
        }
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFF9F0')
      .borderRadius(12)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 16 })
  }
}
