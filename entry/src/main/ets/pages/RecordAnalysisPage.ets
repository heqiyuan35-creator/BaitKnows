/**
 * 饵知�?- 渔获分析页面（创意版�?
 * 钓鱼成就、个人画像、趣味数�?
 */
import { ThemeColors } from '../theme/ThemeColors';
import { ThemeConstants } from '../theme/ThemeConstants';
import { Router } from '../router/Router';
import { FishingRecord } from '../common/types/UserTypes';
import { fishingRecordService } from '../services/FishingRecordService';

// 成就定义
class Achievement {
  id: string = '';
  name: string = '';
  icon: string = '';
  desc: string = '';
  unlocked: boolean = false;
  progress: number = 0;
  target: number = 1;
}

// 钓鱼画像标签
class ProfileTag {
  label: string = '';
  color: string = '';
  icon: string = '';
}

// 配方统计
class RecipeStats {
  name: string = '';
  recipeId: string = '';
  trips: number = 0;
  totalWeight: number = 0;
  avgWeight: number = 0;
}

class RecipeMapValue {
  recipeId: string = '';
  trips: number = 0;
  totalWeight: number = 0;
}

// 鱼种统计
class FishStats {
  name: string = '';
  weight: number = 0;
  count: number = 0;
  percentage: number = 0;
}

class FishMapValue {
  weight: number = 0;
  count: number = 0;
}

@Entry
@Component
struct RecordAnalysisPage {
  @State records: FishingRecord[] = [];
  @State isLoading: boolean = true;
  @State achievements: Achievement[] = [];
  @State profileTags: ProfileTag[] = [];
  @State recipeStats: RecipeStats[] = [];
  @State fishStats: FishStats[] = [];
  @State mvpRecipe: RecipeStats | null = null;
  
  // 基础统计
  @State totalWeight: number = 0;
  @State totalTrips: number = 0;
  @State totalCount: number = 0;
  @State maxSingle: number = 0;
  @State avgWeight: number = 0;
  @State favoriteFish: string = '';
  @State favoriteLocation: string = '';
  @State favoriteWeather: string = '';
  
  // 趣味数据
  @State funFacts: string[] = [];

  aboutToAppear(): void {
    this.loadAndAnalyze();
  }

  private async loadAndAnalyze(): Promise<void> {
    this.isLoading = true;
    await fishingRecordService.load();
    this.records = fishingRecordService.records;
    if (this.records.length > 0) {
      this.calculateBasicStats();
      this.generateAchievements();
      this.generateProfileTags();
      this.generateFunFacts();
      this.analyzeRecipes();
      this.analyzeFish();
    }
    this.isLoading = false;
  }

  private calculateBasicStats(): void {
    this.totalTrips = this.records.length;
    let sumWeight = 0;
    let sumCount = 0;
    let maxW = 0;
    
    const locationMap = new Map<string, number>();
    const weatherMap = new Map<string, number>();
    const fishMap = new Map<string, number>();
    
    for (const r of this.records) {
      sumWeight += r.weight;
      sumCount += r.count;
      if (r.maxSingle > maxW) maxW = r.maxSingle;
      
      // 统计最爱钓�?
      const loc = r.location || '未知';
      locationMap.set(loc, (locationMap.get(loc) || 0) + r.weight);
      
      // 统计最爱天�?
      const weather = r.weather || '未知';
      weatherMap.set(weather, (weatherMap.get(weather) || 0) + r.weight);
      
      // 统计最爱鱼�?
      const fishNames = r.fishName.split('�?);
      for (const f of fishNames) {
        const name = f.trim();
        if (name) fishMap.set(name, (fishMap.get(name) || 0) + 1);
      }
    }
    
    this.totalWeight = Math.round(sumWeight * 10) / 10;
    this.totalCount = sumCount;
    this.maxSingle = Math.round(maxW * 10) / 10;
    this.avgWeight = this.totalTrips > 0 ? Math.round((sumWeight / this.totalTrips) * 10) / 10 : 0;
    
    // 找最�?
    let maxLoc = '';
    let maxLocW = 0;
    locationMap.forEach((w, loc) => { if (w > maxLocW) { maxLocW = w; maxLoc = loc; } });
    this.favoriteLocation = maxLoc;
    
    let maxWeather = '';
    let maxWeatherW = 0;
    weatherMap.forEach((w, weather) => { if (w > maxWeatherW) { maxWeatherW = w; maxWeather = weather; } });
    this.favoriteWeather = maxWeather;
    
    let maxFish = '';
    let maxFishC = 0;
    fishMap.forEach((c, fish) => { if (c > maxFishC) { maxFishC = c; maxFish = fish; } });
    this.favoriteFish = maxFish;
  }


  private generateAchievements(): void {
    const list: Achievement[] = [];
    
    // 初出茅庐 - 第一次记�?
    const a1 = new Achievement();
    a1.id = 'first'; a1.name = '初出茅庐'; a1.icon = '🎣';
    a1.desc = '完成第一次渔获记�?; a1.target = 1;
    a1.progress = Math.min(this.totalTrips, 1);
    a1.unlocked = this.totalTrips >= 1;
    list.push(a1);
    
    // 钓鱼达人 - 出钓10�?
    const a2 = new Achievement();
    a2.id = 'trips10'; a2.name = '钓鱼达人'; a2.icon = '🏆';
    a2.desc = '累计出钓10�?; a2.target = 10;
    a2.progress = Math.min(this.totalTrips, 10);
    a2.unlocked = this.totalTrips >= 10;
    list.push(a2);
    
    // 百斤渔王 - 总渔�?00kg
    const a3 = new Achievement();
    a3.id = 'weight100'; a3.name = '百斤渔王'; a3.icon = '👑';
    a3.desc = '累计渔获�?00kg'; a3.target = 100;
    a3.progress = Math.min(this.totalWeight, 100);
    a3.unlocked = this.totalWeight >= 100;
    list.push(a3);
    
    // 大物猎手 - 单尾�?kg
    const a4 = new Achievement();
    a4.id = 'big5'; a4.name = '大物猎手'; a4.icon = '🦈';
    a4.desc = '钓获单尾�?kg的大�?; a4.target = 5;
    a4.progress = Math.min(this.maxSingle, 5);
    a4.unlocked = this.maxSingle >= 5;
    list.push(a4);
    
    // 效率之王 - 场均�?0kg
    const a5 = new Achievement();
    a5.id = 'avg10'; a5.name = '效率之王'; a5.icon = '�?;
    a5.desc = '场均渔获超过10kg'; a5.target = 10;
    a5.progress = Math.min(this.avgWeight, 10);
    a5.unlocked = this.avgWeight >= 10;
    list.push(a5);
    
    // 多多益善 - 单次钓获10尾以�?
    let maxCount = 0;
    for (const r of this.records) { if (r.count > maxCount) maxCount = r.count; }
    const a6 = new Achievement();
    a6.id = 'count10'; a6.name = '多多益善'; a6.icon = '🐟';
    a6.desc = '单次钓获10尾以�?; a6.target = 10;
    a6.progress = Math.min(maxCount, 10);
    a6.unlocked = maxCount >= 10;
    list.push(a6);
    
    this.achievements = list;
  }

  private generateProfileTags(): void {
    const tags: ProfileTag[] = [];
    
    // 根据出钓频率
    if (this.totalTrips >= 20) {
      const t = new ProfileTag(); t.label = '钓鱼狂热�?; t.color = '#FF6B6B'; t.icon = '🔥'; tags.push(t);
    } else if (this.totalTrips >= 10) {
      const t = new ProfileTag(); t.label = '资深钓友'; t.color = '#4ECDC4'; t.icon = '�?; tags.push(t);
    } else if (this.totalTrips >= 5) {
      const t = new ProfileTag(); t.label = '钓鱼爱好�?; t.color = '#45B7D1'; t.icon = '💙'; tags.push(t);
    }
    
    // 根据场均渔获
    if (this.avgWeight >= 20) {
      const t = new ProfileTag(); t.label = '爆护专家'; t.color = '#F7DC6F'; t.icon = '💰'; tags.push(t);
    } else if (this.avgWeight >= 10) {
      const t = new ProfileTag(); t.label = '稳定输出'; t.color = '#82E0AA'; t.icon = '📈'; tags.push(t);
    }
    
    // 根据最大单�?
    if (this.maxSingle >= 10) {
      const t = new ProfileTag(); t.label = '巨物终结�?; t.color = '#BB8FCE'; t.icon = '🦈'; tags.push(t);
    } else if (this.maxSingle >= 5) {
      const t = new ProfileTag(); t.label = '大物猎人'; t.color = '#F8B500'; t.icon = '🎯'; tags.push(t);
    }
    
    // 根据最爱天�?
    if (this.favoriteWeather === '小雨') {
      const t = new ProfileTag(); t.label = '雨中垂钓�?; t.color = '#5DADE2'; t.icon = '🌧�?; tags.push(t);
    } else if (this.favoriteWeather === '晴朗') {
      const t = new ProfileTag(); t.label = '阳光钓手'; t.color = '#F39C12'; t.icon = '☀�?; tags.push(t);
    }
    
    // 默认标签
    if (tags.length === 0) {
      const t = new ProfileTag(); t.label = '钓鱼新手'; t.color = '#85C1E9'; t.icon = '🌱'; tags.push(t);
    }
    
    this.profileTags = tags.slice(0, 4);
  }

  private generateFunFacts(): void {
    const facts: string[] = [];
    
    // 鱼汤计算（假�?kg鱼可以做2碗鱼汤）
    const soupCount = Math.round(this.totalWeight * 2);
    if (soupCount > 0) facts.push(`🍜 你的渔获可以�?${soupCount} 碗鱼汤`);
    
    // 时间计算（假设每次出钓平�?小时�?
    const hours = this.totalTrips * 4;
    if (hours >= 24) {
      const days = Math.round(hours / 24 * 10) / 10;
      facts.push(`�?你已在水边度过约 ${days} 天`);
    } else if (hours > 0) {
      facts.push(`�?你已在水边度过约 ${hours} 小时`);
    }
    
    // 重量比喻
    if (this.totalWeight >= 100) {
      facts.push(`⚖️ 渔获总重相当�?${Math.round(this.totalWeight / 50)} 袋大米`);
    } else if (this.totalWeight >= 10) {
      facts.push(`⚖️ 渔获总重相当�?${Math.round(this.totalWeight / 3)} 只猫咪`);
    }
    
    // 鱼的数量
    if (this.totalCount >= 100) {
      facts.push(`🐟 钓获的鱼可以组成一个小鱼群了！`);
    } else if (this.totalCount >= 50) {
      facts.push(`🐟 你已经钓了一个鱼缸的量！`);
    }
    
    this.funFacts = facts;
  }


  private analyzeRecipes(): void {
    const recipeMap = new Map<string, RecipeMapValue>();
    for (const r of this.records) {
      if (!r.recipeName) continue;
      let existing = recipeMap.get(r.recipeName);
      if (!existing) {
        existing = new RecipeMapValue();
        existing.recipeId = r.recipeId || '';
        recipeMap.set(r.recipeName, existing);
      }
      existing.trips += 1;
      existing.totalWeight += r.weight;
    }
    
    const result: RecipeStats[] = [];
    recipeMap.forEach((v, k) => {
      const s = new RecipeStats();
      s.name = k; s.recipeId = v.recipeId; s.trips = v.trips;
      s.totalWeight = Math.round(v.totalWeight * 10) / 10;
      s.avgWeight = Math.round((v.totalWeight / v.trips) * 10) / 10;
      result.push(s);
    });
    this.recipeStats = result.sort((a, b) => b.totalWeight - a.totalWeight).slice(0, 3);
    if (this.recipeStats.length > 0) this.mvpRecipe = this.recipeStats[0];
  }

  private analyzeFish(): void {
    const fishMap = new Map<string, FishMapValue>();
    for (const r of this.records) {
      const names = r.fishName.split('�?);
      const wPerFish = r.weight / names.length;
      const cPerFish = Math.ceil(r.count / names.length);
      for (const f of names) {
        const name = f.trim();
        if (!name) continue;
        let existing = fishMap.get(name);
        if (!existing) { existing = new FishMapValue(); fishMap.set(name, existing); }
        existing.weight += wPerFish;
        existing.count += cPerFish;
      }
    }
    
    let totalW = 0;
    fishMap.forEach(v => { totalW += v.weight; });
    
    const result: FishStats[] = [];
    fishMap.forEach((v, k) => {
      const s = new FishStats();
      s.name = k; s.weight = Math.round(v.weight * 10) / 10;
      s.count = v.count; s.percentage = Math.round((v.weight / totalW) * 100);
      result.push(s);
    });
    this.fishStats = result.sort((a, b) => b.weight - a.weight).slice(0, 5);
  }

  build() {
    Column() {
      this.HeaderBar()
      if (this.isLoading) {
        this.LoadingView()
      } else if (this.records.length === 0) {
        this.EmptyView()
      } else {
        Scroll() {
          Column({ space: 16 }) {
            this.ProfileSection()
            this.AchievementSection()
            this.FunFactsSection()
            this.MVPSection()
            this.FishRankSection()
          }
          .padding({ left: 16, right: 16, bottom: 40 })
        }
        .layoutWeight(1).scrollBar(BarState.Off)
      }
    }
    .width('100%').height('100%').backgroundColor(ThemeColors.BG_PRIMARY)
  }

  @Builder
  HeaderBar() {
    Column() {
      Row().width('100%').height(36)
      Row() {
        Image($r('app.media.Left')).width(24).height(24)
          .fillColor(ThemeColors.TEXT_PRIMARY).onClick(() => Router.back())
        Blank()
        Text('渔获分析').fontSize(18).fontWeight(FontWeight.Medium).fontColor(ThemeColors.TEXT_PRIMARY)
        Blank()
        Row().width(24)
      }
      .width('100%').height(48).padding({ left: 16, right: 16 })
    }
    .width('100%')
  }

  @Builder
  LoadingView() {
    Column({ space: 12 }) {
      LoadingProgress().width(48).height(48).color(ThemeColors.PRIMARY)
      Text('正在分析你的钓鱼数据...').fontSize(14).fontColor(ThemeColors.TEXT_SECONDARY)
    }
    .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
  }

  @Builder
  EmptyView() {
    Column({ space: 16 }) {
      Text('📊').fontSize(56)
      Text('暂无渔获数据').fontSize(18).fontColor(ThemeColors.TEXT_PRIMARY)
      Text('记录你的第一次渔获，开启钓鱼之�?).fontSize(14).fontColor(ThemeColors.TEXT_SECONDARY)
      Button('去记�?).fontSize(14).fontColor(Color.White).backgroundColor(ThemeColors.PRIMARY)
        .borderRadius(20).height(40).padding({ left: 24, right: 24 }).margin({ top: 8 })
        .onClick(() => Router.push('pages/AddRecordPage'))
    }
    .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
  }


  @Builder
  ProfileSection() {
    Column({ space: 16 }) {
      // 个人画像标题
      Row({ space: 8 }) {
        Text('🎭').fontSize(20)
        Text('我的钓鱼画像').fontSize(16).fontWeight(FontWeight.Bold).fontColor(ThemeColors.TEXT_PRIMARY)
      }
      .width('100%')

      // 核心数据展示
      Row() {
        Column({ space: 4 }) {
          Text(`${this.totalTrips}`).fontSize(32).fontWeight(FontWeight.Bold).fontColor(ThemeColors.PRIMARY_DARK)
          Text('出钓次数').fontSize(12).fontColor(ThemeColors.TEXT_SECONDARY)
        }
        .layoutWeight(1).alignItems(HorizontalAlign.Center)

        Column({ space: 4 }) {
          Row() {
            Text(`${this.totalWeight}`).fontSize(32).fontWeight(FontWeight.Bold).fontColor(ThemeColors.SUCCESS)
            Text('kg').fontSize(14).fontColor(ThemeColors.TEXT_SECONDARY).margin({ top: 16 })
          }
          Text('总渔�?).fontSize(12).fontColor(ThemeColors.TEXT_SECONDARY)
        }
        .layoutWeight(1).alignItems(HorizontalAlign.Center)

        Column({ space: 4 }) {
          Row() {
            Text(`${this.maxSingle}`).fontSize(32).fontWeight(FontWeight.Bold).fontColor(ThemeColors.WARNING)
            Text('kg').fontSize(14).fontColor(ThemeColors.TEXT_SECONDARY).margin({ top: 16 })
          }
          Text('最大单�?).fontSize(12).fontColor(ThemeColors.TEXT_SECONDARY)
        }
        .layoutWeight(1).alignItems(HorizontalAlign.Center)
      }
      .width('100%').padding({ top: 8, bottom: 8 })

      // 个人标签
      if (this.profileTags.length > 0) {
        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Center }) {
          ForEach(this.profileTags, (tag: ProfileTag) => {
            Row({ space: 4 }) {
              Text(tag.icon).fontSize(12)
              Text(tag.label).fontSize(12).fontColor(Color.White)
            }
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .backgroundColor(tag.color)
            .borderRadius(14)
            .margin({ right: 8, bottom: 8 })
          }, (tag: ProfileTag) => tag.label)
        }
        .width('100%')
      }

      // 最爱信�?
      Row({ space: 8 }) {
        this.FavoriteItem('🐟', '最爱鱼�?, this.favoriteFish || '--')
        this.FavoriteItem('📍', '常去钓点', this.favoriteLocation || '--')
        this.FavoriteItem('🌤�?, '偏爱天气', this.favoriteWeather || '--')
      }
      .width('100%')
    }
    .width('100%').padding(16)
    .linearGradient({
      direction: GradientDirection.RightBottom,
      colors: [['#FFF8F0', 0], ['#FFF3E8', 1]]
    })
    .borderRadius(16)
  }

  @Builder
  FavoriteItem(icon: string, label: string, value: string) {
    Column({ space: 4 }) {
      Text(icon).fontSize(16)
      Text(value).fontSize(13).fontWeight(FontWeight.Medium).fontColor(ThemeColors.TEXT_PRIMARY)
        .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
      Text(label).fontSize(10).fontColor(ThemeColors.TEXT_MUTED)
    }
    .layoutWeight(1).padding(8).backgroundColor('rgba(255,255,255,0.8)')
    .borderRadius(8).alignItems(HorizontalAlign.Center)
  }

  @Builder
  AchievementSection() {
    Column({ space: 12 }) {
      Row({ space: 8 }) {
        Text('🏅').fontSize(20)
        Text('钓鱼成就').fontSize(16).fontWeight(FontWeight.Bold).fontColor(ThemeColors.TEXT_PRIMARY)
        Blank()
        Text(`${this.achievements.filter(a => a.unlocked).length}/${this.achievements.length}`)
          .fontSize(12).fontColor(ThemeColors.TEXT_SECONDARY)
      }
      .width('100%')

      // 成就网格
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.achievements, (ach: Achievement) => {
          Column({ space: 6 }) {
            Stack() {
              Text(ach.icon).fontSize(28).opacity(ach.unlocked ? 1 : 0.3)
              if (!ach.unlocked) {
                Text('🔒').fontSize(14).position({ x: '60%', y: '60%' })
              }
            }
            .width(48).height(48)

            Text(ach.name).fontSize(11).fontColor(ach.unlocked ? ThemeColors.TEXT_PRIMARY : ThemeColors.TEXT_MUTED)
              .fontWeight(ach.unlocked ? FontWeight.Medium : FontWeight.Normal)

            if (!ach.unlocked) {
              // 进度�?
              Stack({ alignContent: Alignment.Start }) {
                Row().width('100%').height(4).backgroundColor(ThemeColors.BG_TERTIARY).borderRadius(2)
                Row().width(`${(ach.progress / ach.target) * 100}%`).height(4)
                  .backgroundColor(ThemeColors.PRIMARY).borderRadius(2)
              }
              .width('80%')
            }
          }
          .width('33%').padding(8).alignItems(HorizontalAlign.Center)
        }, (ach: Achievement) => ach.id)
      }
      .width('100%')
    }
    .width('100%').padding(16).backgroundColor(ThemeColors.BG_CARD).borderRadius(16)
  }


  @Builder
  FunFactsSection() {
    if (this.funFacts.length > 0) {
      Column({ space: 12 }) {
        Row({ space: 8 }) {
          Text('�?).fontSize(20)
          Text('趣味数据').fontSize(16).fontWeight(FontWeight.Bold).fontColor(ThemeColors.TEXT_PRIMARY)
        }
        .width('100%')

        Column({ space: 8 }) {
          ForEach(this.funFacts, (fact: string, index: number) => {
            Row() {
              Text(fact).fontSize(14).fontColor(ThemeColors.TEXT_PRIMARY).layoutWeight(1)
            }
            .width('100%').padding(12)
            .backgroundColor(index % 2 === 0 ? 'rgba(232, 168, 73, 0.1)' : 'rgba(76, 175, 80, 0.1)')
            .borderRadius(8)
          }, (fact: string, index: number) => `fact_${index}`)
        }
        .width('100%')
      }
      .width('100%').padding(16).backgroundColor(ThemeColors.BG_CARD).borderRadius(16)
    }
  }

  @Builder
  MVPSection() {
    Column({ space: 12 }) {
      Row({ space: 8 }) {
        Text('🏆').fontSize(20)
        Text('配方MVP').fontSize(16).fontWeight(FontWeight.Bold).fontColor(ThemeColors.TEXT_PRIMARY)
      }
      .width('100%')

      if (this.mvpRecipe === null) {
        Column({ space: 8 }) {
          Text('🧪').fontSize(36).opacity(0.5)
          Text('暂无配方数据').fontSize(14).fontColor(ThemeColors.TEXT_SECONDARY)
          Text('记录时关联配方，看看哪个最给力').fontSize(12).fontColor(ThemeColors.TEXT_MUTED)
        }
        .width('100%').padding({ top: 16, bottom: 16 }).alignItems(HorizontalAlign.Center)
      } else {
        // MVP卡片
        Row({ space: 12 }) {
          Column() {
            Text('🥇').fontSize(36)
          }
          .width(64).height(64)
          .linearGradient({ direction: GradientDirection.Bottom, colors: [['#FFD700', 0], ['#FFA500', 1]] })
          .borderRadius(32).justifyContent(FlexAlign.Center)

          Column({ space: 4 }) {
            Text(this.mvpRecipe.name).fontSize(16).fontWeight(FontWeight.Bold)
              .fontColor(ThemeColors.TEXT_PRIMARY).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
            Text(`使用 ${this.mvpRecipe.trips} 次`).fontSize(12).fontColor(ThemeColors.TEXT_SECONDARY)
          }
          .alignItems(HorizontalAlign.Start).layoutWeight(1)

          Column({ space: 2 }) {
            Row() {
              Text(`${this.mvpRecipe.totalWeight}`).fontSize(24).fontWeight(FontWeight.Bold).fontColor(ThemeColors.PRIMARY_DARK)
              Text('kg').fontSize(12).fontColor(ThemeColors.TEXT_SECONDARY).margin({ left: 2, top: 10 })
            }
            Text('总渔�?).fontSize(10).fontColor(ThemeColors.TEXT_MUTED)
          }
          .alignItems(HorizontalAlign.End)
        }
        .width('100%').padding(12).backgroundColor('rgba(255, 215, 0, 0.1)').borderRadius(12)

        // 其他配方
        if (this.recipeStats.length > 1) {
          Column({ space: 6 }) {
            ForEach(this.recipeStats.slice(1), (recipe: RecipeStats, index: number) => {
              Row({ space: 8 }) {
                Text(index === 0 ? '🥈' : '🥉').fontSize(16)
                Text(recipe.name).fontSize(13).fontColor(ThemeColors.TEXT_PRIMARY)
                  .layoutWeight(1).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
                Text(`${recipe.totalWeight}kg`).fontSize(12).fontColor(ThemeColors.PRIMARY_DARK)
              }
              .width('100%').padding({ top: 6, bottom: 6 })
            }, (recipe: RecipeStats) => recipe.name)
          }
          .width('100%').margin({ top: 8 })
        }
      }
    }
    .width('100%').padding(16).backgroundColor(ThemeColors.BG_CARD).borderRadius(16)
  }

  @Builder
  FishRankSection() {
    Column({ space: 12 }) {
      Row({ space: 8 }) {
        Text('🐟').fontSize(20)
        Text('鱼种战绩').fontSize(16).fontWeight(FontWeight.Bold).fontColor(ThemeColors.TEXT_PRIMARY)
      }
      .width('100%')

      if (this.fishStats.length === 0) {
        Text('暂无数据').fontSize(14).fontColor(ThemeColors.TEXT_SECONDARY)
      } else {
        Column({ space: 8 }) {
          ForEach(this.fishStats, (fish: FishStats, index: number) => {
            Row({ space: 12 }) {
              // 排名徽章
              Column() {
                Text(index === 0 ? '🥇' : index === 1 ? '🥈' : index === 2 ? '🥉' : `${index + 1}`)
                  .fontSize(index < 3 ? 18 : 14)
                  .fontColor(index < 3 ? ThemeColors.PRIMARY : ThemeColors.TEXT_SECONDARY)
              }
              .width(32).alignItems(HorizontalAlign.Center)

              // 鱼种名和进度�?
              Column({ space: 4 }) {
                Row() {
                  Text(fish.name).fontSize(14).fontWeight(FontWeight.Medium).fontColor(ThemeColors.TEXT_PRIMARY)
                  Blank()
                  Text(`${fish.weight}kg`).fontSize(13).fontColor(ThemeColors.PRIMARY_DARK)
                }
                .width('100%')

                Stack({ alignContent: Alignment.Start }) {
                  Row().width('100%').height(8).backgroundColor(ThemeColors.BG_TERTIARY).borderRadius(4)
                  Row().width(`${fish.percentage}%`).height(8)
                    .linearGradient({ direction: GradientDirection.Right, 
                      colors: [[ThemeColors.PRIMARY, 0], ['#FFD700', 1]] })
                    .borderRadius(4)
                }
                .width('100%')
              }
              .layoutWeight(1)
            }
            .width('100%').padding({ top: 4, bottom: 4 })
          }, (fish: FishStats) => fish.name)
        }
        .width('100%')
      }
    }
    .width('100%').padding(16).backgroundColor(ThemeColors.BG_CARD).borderRadius(16)
  }
}
