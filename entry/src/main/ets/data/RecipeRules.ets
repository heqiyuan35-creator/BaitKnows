/**
 * 智能配方生成规则�?
 * 基于确定性规则的配方生成数据
 */
import {
  FishRecipeRule, FlavorModifier, StateModifier,
  SeasonModifierMap, WaterModifierMap, IngredientRecommend,
  TemperatureRule, ModeModifier, ReasonTemplate
} from '../common/types/RecipeTypes';

// ============================================================
// 鱼种配方规则
// ============================================================

// 创建鲫鱼规则
function createCrucianRule(): FishRecipeRule {
  const rule = new FishRecipeRule();
  rule.fishId = 'crucian';
  rule.fishName = '鲫鱼';

  // 基础味型：腥香为主，甜味辅助
  rule.baseFlavor = FlavorModifier.create(60, 70, 50, 20, 10);

  // 季节修正
  rule.seasonModifier.spring = FlavorModifier.create(20, -10, 0, 0, 0);   // 春：增腥
  rule.seasonModifier.summer = FlavorModifier.create(-30, 10, -10, 20, 0); // 夏：减腥增酸
  rule.seasonModifier.autumn = FlavorModifier.create(0, 20, 10, 0, 0);    // 秋：增香�?
  rule.seasonModifier.winter = FlavorModifier.create(40, 10, 10, -10, 0); // 冬：浓腥浓香

  // 水域修正
  rule.waterModifier.river = StateModifier.create(-20, 20, -10);      // 野河：慢雾化高粘�?
  rule.waterModifier.pond = StateModifier.create(20, -10, 30);        // 黑坑：快雾化味型�?
  rule.waterModifier.reservoir = StateModifier.create(-10, 10, 0);    // 水库：适中
  rule.waterModifier.wild_pond = StateModifier.create(0, 10, 0);      // 野塘：适中

  // 推荐原料
  rule.recommendedIngredients.main = ['corn_flour', 'wheat_bran', 'soybean_flour'];
  rule.recommendedIngredients.auxiliary = ['fish_meal', 'shrimp_powder', 'bloodworm_powder'];
  rule.recommendedIngredients.state = ['drawing_powder', 'snowflake_powder', 'light_bran'];
  rule.recommendedIngredients.additive = ['dmpt', 'sweet_corn_essence'];

  return rule;
}

// 创建鲤鱼规则
function createCarpRule(): FishRecipeRule {
  const rule = new FishRecipeRule();
  rule.fishId = 'carp';
  rule.fishName = '鲤鱼';

  // 基础味型：甜香为主，腥味辅助
  rule.baseFlavor = FlavorModifier.create(50, 70, 85, 30, 20);

  // 季节修正
  rule.seasonModifier.spring = FlavorModifier.create(15, 0, 10, 0, 0);
  rule.seasonModifier.summer = FlavorModifier.create(-20, 10, 20, 25, 0);
  rule.seasonModifier.autumn = FlavorModifier.create(0, 25, 15, 0, 0);
  rule.seasonModifier.winter = FlavorModifier.create(35, 15, 0, -15, 0);

  // 水域修正
  rule.waterModifier.river = StateModifier.create(-25, 25, -15);
  rule.waterModifier.pond = StateModifier.create(25, -15, 35);
  rule.waterModifier.reservoir = StateModifier.create(-15, 15, 5);
  rule.waterModifier.wild_pond = StateModifier.create(-5, 10, 0);

  // 推荐原料
  rule.recommendedIngredients.main = ['corn_flour', 'sweet_potato_flour', 'soybean_flour'];
  rule.recommendedIngredients.auxiliary = ['shrimp_powder', 'silkworm_pupa', 'fish_meal'];
  rule.recommendedIngredients.state = ['drawing_powder', 'snowflake_powder'];
  rule.recommendedIngredients.additive = ['sweet_corn_essence', 'dmpt'];

  return rule;
}


// 创建草鱼规则
function createGrassRule(): FishRecipeRule {
  const rule = new FishRecipeRule();
  rule.fishId = 'grass_carp';
  rule.fishName = '草鱼';

  // 基础味型：香甜酸为主
  rule.baseFlavor = FlavorModifier.create(20, 90, 60, 50, 30);

  // 季节修正
  rule.seasonModifier.spring = FlavorModifier.create(10, 10, 0, 15, 0);
  rule.seasonModifier.summer = FlavorModifier.create(-15, 15, 0, 30, 0);
  rule.seasonModifier.autumn = FlavorModifier.create(0, 20, 20, 10, 0);
  rule.seasonModifier.winter = FlavorModifier.create(25, 10, 0, -20, 0);

  // 水域修正
  rule.waterModifier.river = StateModifier.create(-20, 20, -10);
  rule.waterModifier.pond = StateModifier.create(15, -10, 25);
  rule.waterModifier.reservoir = StateModifier.create(-10, 15, 5);
  rule.waterModifier.wild_pond = StateModifier.create(-5, 10, 0);

  // 推荐原料
  rule.recommendedIngredients.main = ['corn_flour', 'wheat_bran', 'sweet_potato_flour'];
  rule.recommendedIngredients.auxiliary = ['soybean_flour', 'silkworm_pupa'];
  rule.recommendedIngredients.state = ['drawing_powder', 'light_bran'];
  rule.recommendedIngredients.additive = ['sweet_corn_essence', 'garlic_powder'];

  return rule;
}

// 创建青鱼规则
function createBlackRule(): FishRecipeRule {
  const rule = new FishRecipeRule();
  rule.fishId = 'black_carp';
  rule.fishName = '青鱼';

  // 基础味型：腥香为主，大鱼偏重�?
  rule.baseFlavor = FlavorModifier.create(70, 50, 40, 20, 40);

  // 季节修正
  rule.seasonModifier.spring = FlavorModifier.create(15, 10, 0, 0, 10);
  rule.seasonModifier.summer = FlavorModifier.create(-10, 15, 0, 15, 0);
  rule.seasonModifier.autumn = FlavorModifier.create(10, 20, 15, 0, 5);
  rule.seasonModifier.winter = FlavorModifier.create(30, 10, 10, -10, 15);

  // 水域修正
  rule.waterModifier.river = StateModifier.create(-30, 30, -10);
  rule.waterModifier.pond = StateModifier.create(10, -5, 20);
  rule.waterModifier.reservoir = StateModifier.create(-20, 20, 0);
  rule.waterModifier.wild_pond = StateModifier.create(-15, 15, -5);

  // 推荐原料
  rule.recommendedIngredients.main = ['corn_flour', 'soybean_flour', 'wheat_bran'];
  rule.recommendedIngredients.auxiliary = ['fish_meal', 'silkworm_pupa', 'shrimp_powder'];
  rule.recommendedIngredients.state = ['drawing_powder', 'snowflake_powder'];
  rule.recommendedIngredients.additive = ['dmpt'];

  return rule;
}

// 创建鲢鱼规则
function createSilverRule(): FishRecipeRule {
  const rule = new FishRecipeRule();
  rule.fishId = 'silver_carp';
  rule.fishName = '鲢鱼';

  // 基础味型：酸臭为�?
  rule.baseFlavor = FlavorModifier.create(40, 50, 30, 90, 85);

  // 季节修正
  rule.seasonModifier.spring = FlavorModifier.create(10, 0, 0, 10, 5);
  rule.seasonModifier.summer = FlavorModifier.create(-10, 0, 0, 20, 20);
  rule.seasonModifier.autumn = FlavorModifier.create(0, 10, 0, 15, 10);
  rule.seasonModifier.winter = FlavorModifier.create(20, 10, 0, -20, -10);

  // 水域修正
  rule.waterModifier.river = StateModifier.create(10, -10, 0);
  rule.waterModifier.pond = StateModifier.create(30, -20, 20);
  rule.waterModifier.reservoir = StateModifier.create(20, -15, 10);
  rule.waterModifier.wild_pond = StateModifier.create(15, -10, 5);

  // 推荐原料
  rule.recommendedIngredients.main = ['wheat_bran', 'soybean_flour'];
  rule.recommendedIngredients.auxiliary = ['fish_meal'];
  rule.recommendedIngredients.state = ['snowflake_powder', 'light_bran'];
  rule.recommendedIngredients.additive = ['garlic_powder'];

  return rule;
}


// 创建鳙鱼规则
function createBigheadRule(): FishRecipeRule {
  const rule = new FishRecipeRule();
  rule.fishId = 'bighead';
  rule.fishName = '鳙鱼';

  // 基础味型：臭味为主，酸味辅助
  rule.baseFlavor = FlavorModifier.create(50, 40, 25, 80, 95);

  // 季节修正
  rule.seasonModifier.spring = FlavorModifier.create(10, 0, 0, 5, 10);
  rule.seasonModifier.summer = FlavorModifier.create(-5, 0, 0, 15, 25);
  rule.seasonModifier.autumn = FlavorModifier.create(5, 10, 0, 10, 15);
  rule.seasonModifier.winter = FlavorModifier.create(20, 15, 0, -15, -10);

  // 水域修正
  rule.waterModifier.river = StateModifier.create(15, -15, 5);
  rule.waterModifier.pond = StateModifier.create(35, -25, 25);
  rule.waterModifier.reservoir = StateModifier.create(25, -20, 15);
  rule.waterModifier.wild_pond = StateModifier.create(20, -15, 10);

  // 推荐原料
  rule.recommendedIngredients.main = ['wheat_bran', 'soybean_flour'];
  rule.recommendedIngredients.auxiliary = ['fish_meal', 'silkworm_pupa'];
  rule.recommendedIngredients.state = ['snowflake_powder', 'light_bran'];
  rule.recommendedIngredients.additive = ['garlic_powder'];

  return rule;
}

// 创建鲶鱼规则
function createCatfishRule(): FishRecipeRule {
  const rule = new FishRecipeRule();
  rule.fishId = 'catfish';
  rule.fishName = '鲶鱼';

  // 基础味型：浓腥臭为主
  rule.baseFlavor = FlavorModifier.create(95, 20, 10, 15, 90);

  // 季节修正
  rule.seasonModifier.spring = FlavorModifier.create(10, 0, 0, 0, 10);
  rule.seasonModifier.summer = FlavorModifier.create(5, 0, 0, 5, 15);
  rule.seasonModifier.autumn = FlavorModifier.create(10, 5, 0, 0, 10);
  rule.seasonModifier.winter = FlavorModifier.create(15, 10, 5, -5, 5);

  // 水域修正
  rule.waterModifier.river = StateModifier.create(-15, 15, 10);
  rule.waterModifier.pond = StateModifier.create(10, -5, 20);
  rule.waterModifier.reservoir = StateModifier.create(-10, 10, 5);
  rule.waterModifier.wild_pond = StateModifier.create(-5, 10, 10);

  // 推荐原料
  rule.recommendedIngredients.main = ['fish_meal', 'wheat_bran'];
  rule.recommendedIngredients.auxiliary = ['shrimp_powder', 'bloodworm_powder'];
  rule.recommendedIngredients.state = ['drawing_powder'];
  rule.recommendedIngredients.additive = ['dmpt'];

  return rule;
}

// 创建鳊鱼规则
function createBreamRule(): FishRecipeRule {
  const rule = new FishRecipeRule();
  rule.fishId = 'bream';
  rule.fishName = '鳊鱼';

  // 基础味型：香甜为�?
  rule.baseFlavor = FlavorModifier.create(45, 85, 75, 25, 15);

  // 季节修正
  rule.seasonModifier.spring = FlavorModifier.create(15, 5, 5, 0, 0);
  rule.seasonModifier.summer = FlavorModifier.create(-15, 15, 10, 20, 0);
  rule.seasonModifier.autumn = FlavorModifier.create(5, 20, 15, 5, 0);
  rule.seasonModifier.winter = FlavorModifier.create(30, 10, 5, -10, 0);

  // 水域修正
  rule.waterModifier.river = StateModifier.create(-15, 15, -10);
  rule.waterModifier.pond = StateModifier.create(20, -10, 25);
  rule.waterModifier.reservoir = StateModifier.create(-10, 10, 0);
  rule.waterModifier.wild_pond = StateModifier.create(-5, 10, -5);

  // 推荐原料
  rule.recommendedIngredients.main = ['corn_flour', 'wheat_bran', 'soybean_flour'];
  rule.recommendedIngredients.auxiliary = ['shrimp_powder', 'fish_meal'];
  rule.recommendedIngredients.state = ['drawing_powder', 'snowflake_powder'];
  rule.recommendedIngredients.additive = ['honey_essence', 'dmpt'];

  return rule;
}

// 创建黄颡鱼规�?
function createYellowCatfishRule(): FishRecipeRule {
  const rule = new FishRecipeRule();
  rule.fishId = 'yellow_catfish';
  rule.fishName = '黄颡�?;

  // 基础味型：浓腥为�?
  rule.baseFlavor = FlavorModifier.create(95, 30, 15, 10, 60);

  rule.seasonModifier.spring = FlavorModifier.create(10, 5, 0, 0, 10);
  rule.seasonModifier.summer = FlavorModifier.create(5, 0, 0, 5, 15);
  rule.seasonModifier.autumn = FlavorModifier.create(10, 10, 0, 0, 10);
  rule.seasonModifier.winter = FlavorModifier.create(20, 10, 5, -5, 5);

  rule.waterModifier.river = StateModifier.create(-20, 20, 10);
  rule.waterModifier.pond = StateModifier.create(10, -5, 20);
  rule.waterModifier.reservoir = StateModifier.create(-10, 15, 5);
  rule.waterModifier.wild_pond = StateModifier.create(-5, 10, 10);

  rule.recommendedIngredients.main = ['fish_meal', 'earthworm_powder'];
  rule.recommendedIngredients.auxiliary = ['shrimp_powder', 'liver_powder', 'bloodworm_powder'];
  rule.recommendedIngredients.state = ['drawing_powder', 'sticky_powder'];
  rule.recommendedIngredients.additive = ['fishy_essence', 'dmpt'];

  return rule;
}

// 创建翘嘴规则
function createCulterRule(): FishRecipeRule {
  const rule = new FishRecipeRule();
  rule.fishId = 'culter';
  rule.fishName = '翘嘴';

  // 基础味型：腥香为主，路亚为主
  rule.baseFlavor = FlavorModifier.create(80, 50, 30, 15, 20);

  rule.seasonModifier.spring = FlavorModifier.create(15, 10, 0, 0, 0);
  rule.seasonModifier.summer = FlavorModifier.create(-10, 15, 0, 10, 0);
  rule.seasonModifier.autumn = FlavorModifier.create(10, 20, 10, 0, 0);
  rule.seasonModifier.winter = FlavorModifier.create(25, 10, 5, -10, 0);

  rule.waterModifier.river = StateModifier.create(-15, 15, 0);
  rule.waterModifier.pond = StateModifier.create(15, -10, 20);
  rule.waterModifier.reservoir = StateModifier.create(-10, 10, 5);
  rule.waterModifier.wild_pond = StateModifier.create(-5, 10, 0);

  rule.recommendedIngredients.main = ['fish_meal', 'shrimp_powder'];
  rule.recommendedIngredients.auxiliary = ['silkworm_pupa_powder', 'squid_powder'];
  rule.recommendedIngredients.state = ['drawing_powder', 'snowflake_powder'];
  rule.recommendedIngredients.additive = ['fishy_essence', 'dmpt'];

  return rule;
}

// 创建罗非鱼规�?
function createTilapiaRule(): FishRecipeRule {
  const rule = new FishRecipeRule();
  rule.fishId = 'tilapia';
  rule.fishName = '罗非�?;

  // 基础味型：腥香甜
  rule.baseFlavor = FlavorModifier.create(70, 60, 50, 20, 30);

  rule.seasonModifier.spring = FlavorModifier.create(10, 10, 5, 0, 5);
  rule.seasonModifier.summer = FlavorModifier.create(0, 15, 10, 15, 10);
  rule.seasonModifier.autumn = FlavorModifier.create(5, 15, 10, 5, 5);
  rule.seasonModifier.winter = FlavorModifier.create(20, 10, 5, -10, 0);

  rule.waterModifier.river = StateModifier.create(-10, 15, 0);
  rule.waterModifier.pond = StateModifier.create(20, -10, 25);
  rule.waterModifier.reservoir = StateModifier.create(-5, 10, 5);
  rule.waterModifier.wild_pond = StateModifier.create(0, 10, 5);

  rule.recommendedIngredients.main = ['corn_flour', 'fish_meal', 'soybean_flour'];
  rule.recommendedIngredients.auxiliary = ['shrimp_powder', 'earthworm_powder'];
  rule.recommendedIngredients.state = ['drawing_powder', 'pellet_powder'];
  rule.recommendedIngredients.additive = ['fishy_essence', 'garlic_essence'];

  return rule;
}

// 创建鳜鱼规则
function createMandarinFishRule(): FishRecipeRule {
  const rule = new FishRecipeRule();
  rule.fishId = 'mandarin_fish';
  rule.fishName = '鳜鱼';

  // 基础味型：浓腥，活饵为主
  rule.baseFlavor = FlavorModifier.create(100, 20, 10, 5, 30);

  rule.seasonModifier.spring = FlavorModifier.create(5, 5, 0, 0, 5);
  rule.seasonModifier.summer = FlavorModifier.create(0, 5, 0, 5, 10);
  rule.seasonModifier.autumn = FlavorModifier.create(10, 10, 0, 0, 5);
  rule.seasonModifier.winter = FlavorModifier.create(15, 10, 5, -5, 0);

  rule.waterModifier.river = StateModifier.create(-20, 20, 10);
  rule.waterModifier.pond = StateModifier.create(5, 0, 15);
  rule.waterModifier.reservoir = StateModifier.create(-15, 15, 5);
  rule.waterModifier.wild_pond = StateModifier.create(-10, 10, 5);

  rule.recommendedIngredients.main = ['fish_meal', 'shrimp_powder'];
  rule.recommendedIngredients.auxiliary = ['squid_powder', 'liver_powder'];
  rule.recommendedIngredients.state = ['sticky_powder', 'drawing_powder'];
  rule.recommendedIngredients.additive = ['fishy_essence', 'fish_oil'];

  return rule;
}

// 创建武昌鱼规�?
function createWuchangFishRule(): FishRecipeRule {
  const rule = new FishRecipeRule();
  rule.fishId = 'wuchang_fish';
  rule.fishName = '武昌�?;

  // 基础味型：香甜为主，类似鳊鱼
  rule.baseFlavor = FlavorModifier.create(40, 80, 70, 20, 10);

  rule.seasonModifier.spring = FlavorModifier.create(15, 10, 5, 0, 0);
  rule.seasonModifier.summer = FlavorModifier.create(-10, 15, 10, 15, 0);
  rule.seasonModifier.autumn = FlavorModifier.create(5, 20, 15, 5, 0);
  rule.seasonModifier.winter = FlavorModifier.create(25, 10, 5, -10, 0);

  rule.waterModifier.river = StateModifier.create(-15, 15, -5);
  rule.waterModifier.pond = StateModifier.create(15, -10, 20);
  rule.waterModifier.reservoir = StateModifier.create(-10, 10, 0);
  rule.waterModifier.wild_pond = StateModifier.create(-5, 10, -5);

  rule.recommendedIngredients.main = ['corn_flour', 'wheat_bran', 'soybean_flour'];
  rule.recommendedIngredients.auxiliary = ['shrimp_powder', 'fish_meal'];
  rule.recommendedIngredients.state = ['drawing_powder', 'snowflake_powder'];
  rule.recommendedIngredients.additive = ['honey_essence', 'vanilla_essence'];

  return rule;
}

// 创建黑鱼规则
function createSnakeheadRule(): FishRecipeRule {
  const rule = new FishRecipeRule();
  rule.fishId = 'snakehead';
  rule.fishName = '黑鱼';

  // 基础味型：极浓腥，活�?路亚为主
  rule.baseFlavor = FlavorModifier.create(100, 15, 5, 5, 50);

  rule.seasonModifier.spring = FlavorModifier.create(5, 5, 0, 0, 10);
  rule.seasonModifier.summer = FlavorModifier.create(5, 0, 0, 5, 15);
  rule.seasonModifier.autumn = FlavorModifier.create(10, 5, 0, 0, 10);
  rule.seasonModifier.winter = FlavorModifier.create(10, 10, 5, -5, 5);

  rule.waterModifier.river = StateModifier.create(-15, 15, 10);
  rule.waterModifier.pond = StateModifier.create(5, 0, 15);
  rule.waterModifier.reservoir = StateModifier.create(-10, 10, 5);
  rule.waterModifier.wild_pond = StateModifier.create(-5, 10, 10);

  rule.recommendedIngredients.main = ['fish_meal', 'blood_meal'];
  rule.recommendedIngredients.auxiliary = ['liver_powder', 'earthworm_powder'];
  rule.recommendedIngredients.state = ['sticky_powder', 'drawing_powder'];
  rule.recommendedIngredients.additive = ['fishy_essence', 'fish_oil'];

  return rule;
}

// 创建鲮鱼规则
function createCatlaRule(): FishRecipeRule {
  const rule = new FishRecipeRule();
  rule.fishId = 'catla';
  rule.fishName = '鲮鱼';

  // 基础味型：香甜为主，南方特色
  rule.baseFlavor = FlavorModifier.create(50, 85, 70, 25, 15);

  rule.seasonModifier.spring = FlavorModifier.create(10, 10, 5, 0, 0);
  rule.seasonModifier.summer = FlavorModifier.create(-10, 15, 10, 15, 0);
  rule.seasonModifier.autumn = FlavorModifier.create(5, 20, 15, 5, 0);
  rule.seasonModifier.winter = FlavorModifier.create(20, 10, 5, -10, 0);

  rule.waterModifier.river = StateModifier.create(-15, 15, -5);
  rule.waterModifier.pond = StateModifier.create(20, -10, 25);
  rule.waterModifier.reservoir = StateModifier.create(-10, 10, 5);
  rule.waterModifier.wild_pond = StateModifier.create(-5, 10, 0);

  rule.recommendedIngredients.main = ['peanut_flour', 'corn_flour', 'wheat_bran'];
  rule.recommendedIngredients.auxiliary = ['shrimp_powder', 'fish_meal'];
  rule.recommendedIngredients.state = ['drawing_powder', 'snowflake_powder'];
  rule.recommendedIngredients.additive = ['honey_essence', 'dmpt'];

  return rule;
}

// 创建大口黑鲈规则
function createBassRule(): FishRecipeRule {
  const rule = new FishRecipeRule();
  rule.fishId = 'bass';
  rule.fishName = '大口黑鲈';

  // 基础味型：浓腥，路亚为主
  rule.baseFlavor = FlavorModifier.create(95, 30, 15, 10, 25);

  rule.seasonModifier.spring = FlavorModifier.create(10, 10, 0, 0, 5);
  rule.seasonModifier.summer = FlavorModifier.create(0, 10, 0, 10, 10);
  rule.seasonModifier.autumn = FlavorModifier.create(10, 15, 5, 0, 5);
  rule.seasonModifier.winter = FlavorModifier.create(15, 10, 5, -5, 0);

  rule.waterModifier.river = StateModifier.create(-15, 15, 5);
  rule.waterModifier.pond = StateModifier.create(10, -5, 20);
  rule.waterModifier.reservoir = StateModifier.create(-10, 10, 5);
  rule.waterModifier.wild_pond = StateModifier.create(-5, 10, 5);

  rule.recommendedIngredients.main = ['fish_meal', 'shrimp_powder'];
  rule.recommendedIngredients.auxiliary = ['squid_powder', 'earthworm_powder'];
  rule.recommendedIngredients.state = ['drawing_powder', 'sticky_powder'];
  rule.recommendedIngredients.additive = ['fishy_essence', 'dmpt'];

  return rule;
}

// 创建斑点叉尾鮰规�?
function createChannelCatfishRule(): FishRecipeRule {
  const rule = new FishRecipeRule();
  rule.fishId = 'channel_catfish';
  rule.fishName = '斑点叉尾�?;

  // 基础味型：浓腥臭
  rule.baseFlavor = FlavorModifier.create(90, 25, 15, 15, 80);

  rule.seasonModifier.spring = FlavorModifier.create(10, 5, 0, 0, 10);
  rule.seasonModifier.summer = FlavorModifier.create(5, 0, 0, 10, 20);
  rule.seasonModifier.autumn = FlavorModifier.create(10, 10, 0, 5, 15);
  rule.seasonModifier.winter = FlavorModifier.create(15, 10, 5, -5, 5);

  rule.waterModifier.river = StateModifier.create(-15, 20, 10);
  rule.waterModifier.pond = StateModifier.create(10, -5, 25);
  rule.waterModifier.reservoir = StateModifier.create(-10, 15, 10);
  rule.waterModifier.wild_pond = StateModifier.create(-5, 10, 10);

  rule.recommendedIngredients.main = ['fish_meal', 'liver_powder'];
  rule.recommendedIngredients.auxiliary = ['shrimp_powder', 'blood_meal', 'earthworm_powder'];
  rule.recommendedIngredients.state = ['drawing_powder', 'sticky_powder'];
  rule.recommendedIngredients.additive = ['fishy_essence', 'dmpt'];

  return rule;
}

// 创建马口规则
function createTopmouthCulterRule(): FishRecipeRule {
  const rule = new FishRecipeRule();
  rule.fishId = 'topmouth_culter';
  rule.fishName = '马口';

  rule.baseFlavor = FlavorModifier.create(70, 50, 30, 15, 15);

  rule.seasonModifier.spring = FlavorModifier.create(10, 10, 0, 0, 0);
  rule.seasonModifier.summer = FlavorModifier.create(-5, 15, 0, 10, 0);
  rule.seasonModifier.autumn = FlavorModifier.create(10, 15, 5, 0, 0);
  rule.seasonModifier.winter = FlavorModifier.create(20, 10, 5, -10, 0);

  rule.waterModifier.river = StateModifier.create(-10, 10, 0);
  rule.waterModifier.pond = StateModifier.create(10, -5, 15);
  rule.waterModifier.reservoir = StateModifier.create(-5, 10, 5);
  rule.waterModifier.wild_pond = StateModifier.create(0, 10, 0);

  rule.recommendedIngredients.main = ['fish_meal', 'shrimp_powder'];
  rule.recommendedIngredients.auxiliary = ['earthworm_powder', 'bloodworm_powder'];
  rule.recommendedIngredients.state = ['drawing_powder', 'snowflake_powder'];
  rule.recommendedIngredients.additive = ['fishy_essence', 'dmpt'];

  return rule;
}

// 创建泥鳅规则
function createLoachRule(): FishRecipeRule {
  const rule = new FishRecipeRule();
  rule.fishId = 'loach';
  rule.fishName = '泥鳅';

  rule.baseFlavor = FlavorModifier.create(80, 40, 25, 15, 30);

  rule.seasonModifier.spring = FlavorModifier.create(10, 5, 0, 0, 5);
  rule.seasonModifier.summer = FlavorModifier.create(5, 5, 0, 10, 10);
  rule.seasonModifier.autumn = FlavorModifier.create(10, 10, 5, 0, 5);
  rule.seasonModifier.winter = FlavorModifier.create(15, 10, 5, -5, 0);

  rule.waterModifier.river = StateModifier.create(-15, 15, 5);
  rule.waterModifier.pond = StateModifier.create(10, -5, 15);
  rule.waterModifier.reservoir = StateModifier.create(-10, 10, 5);
  rule.waterModifier.wild_pond = StateModifier.create(-5, 10, 5);

  rule.recommendedIngredients.main = ['earthworm_powder', 'fish_meal'];
  rule.recommendedIngredients.auxiliary = ['bloodworm_powder', 'shrimp_powder'];
  rule.recommendedIngredients.state = ['drawing_powder', 'sticky_powder'];
  rule.recommendedIngredients.additive = ['fishy_essence', 'dmpt'];

  return rule;
}

// 创建巨鲤规则
function createGiantCarpRule(): FishRecipeRule {
  const rule = new FishRecipeRule();
  rule.fishId = 'giant_carp';
  rule.fishName = '巨鲤';

  rule.baseFlavor = FlavorModifier.create(55, 75, 90, 35, 25);

  rule.seasonModifier.spring = FlavorModifier.create(15, 5, 10, 0, 0);
  rule.seasonModifier.summer = FlavorModifier.create(-15, 15, 20, 20, 0);
  rule.seasonModifier.autumn = FlavorModifier.create(5, 25, 20, 5, 0);
  rule.seasonModifier.winter = FlavorModifier.create(30, 15, 5, -15, 0);

  rule.waterModifier.river = StateModifier.create(-30, 30, -15);
  rule.waterModifier.pond = StateModifier.create(20, -15, 30);
  rule.waterModifier.reservoir = StateModifier.create(-20, 20, 5);
  rule.waterModifier.wild_pond = StateModifier.create(-10, 15, 0);

  rule.recommendedIngredients.main = ['corn_flour', 'sweet_potato_flour', 'soybean_flour'];
  rule.recommendedIngredients.auxiliary = ['shrimp_powder', 'fish_meal'];
  rule.recommendedIngredients.state = ['drawing_powder', 'heavy_powder'];
  rule.recommendedIngredients.additive = ['honey_essence', 'dmpt'];

  return rule;
}

// 创建狗鱼规则
function createPikeRule(): FishRecipeRule {
  const rule = new FishRecipeRule();
  rule.fishId = 'pike';
  rule.fishName = '狗鱼';

  rule.baseFlavor = FlavorModifier.create(100, 20, 10, 5, 30);

  rule.seasonModifier.spring = FlavorModifier.create(5, 5, 0, 0, 5);
  rule.seasonModifier.summer = FlavorModifier.create(0, 5, 0, 5, 10);
  rule.seasonModifier.autumn = FlavorModifier.create(10, 10, 0, 0, 5);
  rule.seasonModifier.winter = FlavorModifier.create(10, 10, 5, -5, 0);

  rule.waterModifier.river = StateModifier.create(-15, 15, 10);
  rule.waterModifier.pond = StateModifier.create(5, 0, 15);
  rule.waterModifier.reservoir = StateModifier.create(-10, 10, 5);
  rule.waterModifier.wild_pond = StateModifier.create(-5, 10, 5);

  rule.recommendedIngredients.main = ['fish_meal', 'blood_meal'];
  rule.recommendedIngredients.auxiliary = ['squid_powder', 'liver_powder'];
  rule.recommendedIngredients.state = ['sticky_powder', 'drawing_powder'];
  rule.recommendedIngredients.additive = ['fishy_essence', 'fish_oil'];

  return rule;
}

// 创建鲈鱼规则
function createPerchRule(): FishRecipeRule {
  const rule = new FishRecipeRule();
  rule.fishId = 'perch';
  rule.fishName = '鲈鱼';

  rule.baseFlavor = FlavorModifier.create(90, 35, 20, 10, 20);

  rule.seasonModifier.spring = FlavorModifier.create(10, 10, 0, 0, 5);
  rule.seasonModifier.summer = FlavorModifier.create(0, 10, 0, 10, 10);
  rule.seasonModifier.autumn = FlavorModifier.create(10, 15, 5, 0, 5);
  rule.seasonModifier.winter = FlavorModifier.create(15, 10, 5, -5, 0);

  rule.waterModifier.river = StateModifier.create(-15, 15, 5);
  rule.waterModifier.pond = StateModifier.create(10, -5, 20);
  rule.waterModifier.reservoir = StateModifier.create(-10, 10, 5);
  rule.waterModifier.wild_pond = StateModifier.create(-5, 10, 5);

  rule.recommendedIngredients.main = ['fish_meal', 'shrimp_powder'];
  rule.recommendedIngredients.auxiliary = ['squid_powder', 'earthworm_powder'];
  rule.recommendedIngredients.state = ['drawing_powder', 'sticky_powder'];
  rule.recommendedIngredients.additive = ['fishy_essence', 'dmpt'];

  return rule;
}

// 创建黄鳝规则
function createEelRule(): FishRecipeRule {
  const rule = new FishRecipeRule();
  rule.fishId = 'eel';
  rule.fishName = '黄鳝';

  rule.baseFlavor = FlavorModifier.create(95, 25, 10, 10, 70);

  rule.seasonModifier.spring = FlavorModifier.create(10, 5, 0, 0, 10);
  rule.seasonModifier.summer = FlavorModifier.create(5, 0, 0, 5, 20);
  rule.seasonModifier.autumn = FlavorModifier.create(10, 10, 0, 0, 15);
  rule.seasonModifier.winter = FlavorModifier.create(15, 10, 5, -5, 5);

  rule.waterModifier.river = StateModifier.create(-20, 20, 10);
  rule.waterModifier.pond = StateModifier.create(5, 0, 20);
  rule.waterModifier.reservoir = StateModifier.create(-10, 15, 10);
  rule.waterModifier.wild_pond = StateModifier.create(-5, 10, 10);

  rule.recommendedIngredients.main = ['earthworm_powder', 'fish_meal'];
  rule.recommendedIngredients.auxiliary = ['liver_powder', 'blood_meal'];
  rule.recommendedIngredients.state = ['sticky_powder', 'drawing_powder'];
  rule.recommendedIngredients.additive = ['fishy_essence', 'dmpt'];

  return rule;
}

// 创建甲鱼规则
function createSoftshellTurtleRule(): FishRecipeRule {
  const rule = new FishRecipeRule();
  rule.fishId = 'softshell_turtle';
  rule.fishName = '甲鱼';

  rule.baseFlavor = FlavorModifier.create(95, 30, 15, 10, 60);

  rule.seasonModifier.spring = FlavorModifier.create(10, 5, 0, 0, 10);
  rule.seasonModifier.summer = FlavorModifier.create(5, 0, 0, 5, 15);
  rule.seasonModifier.autumn = FlavorModifier.create(10, 10, 0, 0, 10);
  rule.seasonModifier.winter = FlavorModifier.create(15, 10, 5, -5, 5);

  rule.waterModifier.river = StateModifier.create(-15, 20, 10);
  rule.waterModifier.pond = StateModifier.create(5, 0, 20);
  rule.waterModifier.reservoir = StateModifier.create(-10, 15, 10);
  rule.waterModifier.wild_pond = StateModifier.create(-5, 10, 10);

  rule.recommendedIngredients.main = ['liver_powder', 'fish_meal'];
  rule.recommendedIngredients.auxiliary = ['earthworm_powder', 'blood_meal'];
  rule.recommendedIngredients.state = ['sticky_powder', 'drawing_powder'];
  rule.recommendedIngredients.additive = ['fishy_essence', 'dmpt'];

  return rule;
}

// 创建鲃鱼规则
function createBarbelRule(): FishRecipeRule {
  const rule = new FishRecipeRule();
  rule.fishId = 'barbel';
  rule.fishName = '鲃鱼';

  rule.baseFlavor = FlavorModifier.create(70, 55, 35, 20, 20);

  rule.seasonModifier.spring = FlavorModifier.create(10, 10, 5, 0, 0);
  rule.seasonModifier.summer = FlavorModifier.create(-5, 15, 5, 15, 0);
  rule.seasonModifier.autumn = FlavorModifier.create(10, 15, 10, 5, 0);
  rule.seasonModifier.winter = FlavorModifier.create(20, 10, 5, -10, 0);

  rule.waterModifier.river = StateModifier.create(-20, 20, 0);
  rule.waterModifier.pond = StateModifier.create(10, -5, 15);
  rule.waterModifier.reservoir = StateModifier.create(-10, 15, 5);
  rule.waterModifier.wild_pond = StateModifier.create(-5, 10, 0);

  rule.recommendedIngredients.main = ['corn_flour', 'wheat_bran', 'soybean_flour'];
  rule.recommendedIngredients.auxiliary = ['shrimp_powder', 'earthworm_powder'];
  rule.recommendedIngredients.state = ['drawing_powder', 'snowflake_powder'];
  rule.recommendedIngredients.additive = ['fishy_essence', 'dmpt'];

  return rule;
}

// 创建赤眼鳟规�?
function createChubRule(): FishRecipeRule {
  const rule = new FishRecipeRule();
  rule.fishId = 'chub';
  rule.fishName = '赤眼�?;

  rule.baseFlavor = FlavorModifier.create(60, 60, 40, 20, 15);

  rule.seasonModifier.spring = FlavorModifier.create(15, 10, 5, 0, 0);
  rule.seasonModifier.summer = FlavorModifier.create(-10, 15, 5, 15, 0);
  rule.seasonModifier.autumn = FlavorModifier.create(5, 20, 10, 5, 0);
  rule.seasonModifier.winter = FlavorModifier.create(25, 10, 5, -10, 0);

  rule.waterModifier.river = StateModifier.create(-15, 15, -5);
  rule.waterModifier.pond = StateModifier.create(15, -10, 20);
  rule.waterModifier.reservoir = StateModifier.create(-10, 10, 0);
  rule.waterModifier.wild_pond = StateModifier.create(-5, 10, -5);

  rule.recommendedIngredients.main = ['corn_flour', 'wheat_bran', 'soybean_flour'];
  rule.recommendedIngredients.auxiliary = ['shrimp_powder', 'earthworm_powder'];
  rule.recommendedIngredients.state = ['drawing_powder', 'snowflake_powder'];
  rule.recommendedIngredients.additive = ['honey_essence', 'dmpt'];

  return rule;
}

// 创建河鳜规则
function createRiverMandarinFishRule(): FishRecipeRule {
  const rule = new FishRecipeRule();
  rule.fishId = 'mandarin_fish_river';
  rule.fishName = '河鳜';

  rule.baseFlavor = FlavorModifier.create(100, 20, 10, 5, 30);

  rule.seasonModifier.spring = FlavorModifier.create(5, 5, 0, 0, 5);
  rule.seasonModifier.summer = FlavorModifier.create(0, 5, 0, 5, 10);
  rule.seasonModifier.autumn = FlavorModifier.create(10, 10, 0, 0, 5);
  rule.seasonModifier.winter = FlavorModifier.create(15, 10, 5, -5, 0);

  rule.waterModifier.river = StateModifier.create(-20, 20, 10);
  rule.waterModifier.pond = StateModifier.create(5, 0, 15);
  rule.waterModifier.reservoir = StateModifier.create(-15, 15, 5);
  rule.waterModifier.wild_pond = StateModifier.create(-10, 10, 5);

  rule.recommendedIngredients.main = ['fish_meal', 'shrimp_powder'];
  rule.recommendedIngredients.auxiliary = ['squid_powder', 'liver_powder'];
  rule.recommendedIngredients.state = ['sticky_powder', 'drawing_powder'];
  rule.recommendedIngredients.additive = ['fishy_essence', 'fish_oil'];

  return rule;
}

// 创建黄尾鲴规�?
function createYellowCheekRule(): FishRecipeRule {
  const rule = new FishRecipeRule();
  rule.fishId = 'yellow_cheek';
  rule.fishName = '黄尾�?;

  rule.baseFlavor = FlavorModifier.create(55, 70, 50, 25, 15);

  rule.seasonModifier.spring = FlavorModifier.create(15, 10, 5, 0, 0);
  rule.seasonModifier.summer = FlavorModifier.create(-10, 15, 5, 15, 0);
  rule.seasonModifier.autumn = FlavorModifier.create(5, 20, 15, 5, 0);
  rule.seasonModifier.winter = FlavorModifier.create(25, 10, 5, -10, 0);

  rule.waterModifier.river = StateModifier.create(-15, 15, -5);
  rule.waterModifier.pond = StateModifier.create(15, -10, 20);
  rule.waterModifier.reservoir = StateModifier.create(-10, 10, 0);
  rule.waterModifier.wild_pond = StateModifier.create(-5, 10, -5);

  rule.recommendedIngredients.main = ['corn_flour', 'wheat_bran', 'soybean_flour'];
  rule.recommendedIngredients.auxiliary = ['shrimp_powder', 'earthworm_powder'];
  rule.recommendedIngredients.state = ['drawing_powder', 'snowflake_powder'];
  rule.recommendedIngredients.additive = ['honey_essence', 'dmpt'];

  return rule;
}

// 创建银鱼规则
function createWhitebaitRule(): FishRecipeRule {
  const rule = new FishRecipeRule();
  rule.fishId = 'whitebait';
  rule.fishName = '银鱼';

  rule.baseFlavor = FlavorModifier.create(75, 45, 30, 15, 15);

  rule.seasonModifier.spring = FlavorModifier.create(10, 10, 0, 0, 0);
  rule.seasonModifier.summer = FlavorModifier.create(-5, 10, 0, 10, 0);
  rule.seasonModifier.autumn = FlavorModifier.create(10, 15, 5, 0, 0);
  rule.seasonModifier.winter = FlavorModifier.create(20, 10, 5, -10, 0);

  rule.waterModifier.river = StateModifier.create(-10, 10, 0);
  rule.waterModifier.pond = StateModifier.create(15, -10, 15);
  rule.waterModifier.reservoir = StateModifier.create(-5, 10, 5);
  rule.waterModifier.wild_pond = StateModifier.create(0, 10, 0);

  rule.recommendedIngredients.main = ['fish_meal', 'shrimp_powder'];
  rule.recommendedIngredients.auxiliary = ['bloodworm_powder', 'earthworm_powder'];
  rule.recommendedIngredients.state = ['drawing_powder', 'snowflake_powder'];
  rule.recommendedIngredients.additive = ['fishy_essence', 'dmpt'];

  return rule;
}

// 创建红鳍鲌规�?
function createRedfinCulterRule(): FishRecipeRule {
  const rule = new FishRecipeRule();
  rule.fishId = 'redfin_culter';
  rule.fishName = '红鳍�?;

  rule.baseFlavor = FlavorModifier.create(80, 50, 30, 15, 20);

  rule.seasonModifier.spring = FlavorModifier.create(15, 10, 0, 0, 0);
  rule.seasonModifier.summer = FlavorModifier.create(-10, 15, 0, 10, 0);
  rule.seasonModifier.autumn = FlavorModifier.create(10, 20, 10, 0, 0);
  rule.seasonModifier.winter = FlavorModifier.create(25, 10, 5, -10, 0);

  rule.waterModifier.river = StateModifier.create(-15, 15, 0);
  rule.waterModifier.pond = StateModifier.create(15, -10, 20);
  rule.waterModifier.reservoir = StateModifier.create(-10, 10, 5);
  rule.waterModifier.wild_pond = StateModifier.create(-5, 10, 0);

  rule.recommendedIngredients.main = ['fish_meal', 'shrimp_powder'];
  rule.recommendedIngredients.auxiliary = ['silkworm_pupa_powder', 'squid_powder'];
  rule.recommendedIngredients.state = ['drawing_powder', 'snowflake_powder'];
  rule.recommendedIngredients.additive = ['fishy_essence', 'dmpt'];

  return rule;
}

// 创建河蟹规则
function createCrabRule(): FishRecipeRule {
  const rule = new FishRecipeRule();
  rule.fishId = 'crab';
  rule.fishName = '河蟹';

  rule.baseFlavor = FlavorModifier.create(85, 40, 25, 15, 50);

  rule.seasonModifier.spring = FlavorModifier.create(10, 5, 0, 0, 10);
  rule.seasonModifier.summer = FlavorModifier.create(5, 5, 0, 10, 15);
  rule.seasonModifier.autumn = FlavorModifier.create(15, 10, 5, 0, 10);
  rule.seasonModifier.winter = FlavorModifier.create(10, 10, 5, -5, 5);

  rule.waterModifier.river = StateModifier.create(-15, 15, 10);
  rule.waterModifier.pond = StateModifier.create(5, 0, 15);
  rule.waterModifier.reservoir = StateModifier.create(-10, 10, 5);
  rule.waterModifier.wild_pond = StateModifier.create(-5, 10, 10);

  rule.recommendedIngredients.main = ['fish_meal', 'liver_powder'];
  rule.recommendedIngredients.auxiliary = ['earthworm_powder', 'shrimp_powder'];
  rule.recommendedIngredients.state = ['sticky_powder', 'drawing_powder'];
  rule.recommendedIngredients.additive = ['fishy_essence', 'dmpt'];

  return rule;
}

// 创建河虾规则
function createShrimpRule(): FishRecipeRule {
  const rule = new FishRecipeRule();
  rule.fishId = 'shrimp';
  rule.fishName = '河虾';

  rule.baseFlavor = FlavorModifier.create(70, 50, 35, 20, 30);

  rule.seasonModifier.spring = FlavorModifier.create(10, 10, 5, 0, 5);
  rule.seasonModifier.summer = FlavorModifier.create(5, 10, 5, 10, 10);
  rule.seasonModifier.autumn = FlavorModifier.create(10, 15, 10, 5, 5);
  rule.seasonModifier.winter = FlavorModifier.create(15, 10, 5, -5, 0);

  rule.waterModifier.river = StateModifier.create(-10, 15, 5);
  rule.waterModifier.pond = StateModifier.create(10, -5, 15);
  rule.waterModifier.reservoir = StateModifier.create(-5, 10, 5);
  rule.waterModifier.wild_pond = StateModifier.create(0, 10, 5);

  rule.recommendedIngredients.main = ['fish_meal', 'earthworm_powder'];
  rule.recommendedIngredients.auxiliary = ['bloodworm_powder', 'shrimp_powder'];
  rule.recommendedIngredients.state = ['drawing_powder', 'sticky_powder'];
  rule.recommendedIngredients.additive = ['fishy_essence', 'dmpt'];

  return rule;
}


// ============================================================
// 温度规则
// ============================================================

function getTemperatureRules(): TemperatureRule[] {
  const rules: TemperatureRule[] = [];

  // 极低�?0-10°C
  const rule1 = new TemperatureRule();
  rule1.minTemp = 0; rule1.maxTemp = 10;
  rule1.flavorModifier = FlavorModifier.create(40, 10, 10, -20, 0);
  rule1.stateModifier = StateModifier.create(-30, 20, 20);
  rule1.description = '极低温，鱼活性很低，需浓腥浓香，慢雾化';
  rules.push(rule1);

  // 低温 10-15°C
  const rule2 = new TemperatureRule();
  rule2.minTemp = 10; rule2.maxTemp = 15;
  rule2.flavorModifier = FlavorModifier.create(20, 10, 0, 0, 0);
  rule2.stateModifier = StateModifier.create(-15, 10, 10);
  rule2.description = '低温，适当增腥，雾化偏�?;
  rules.push(rule2);

  // 适宜温度 15-25°C
  const rule3 = new TemperatureRule();
  rule3.minTemp = 15; rule3.maxTemp = 25;
  rule3.flavorModifier = FlavorModifier.create(0, 0, 0, 0, 0);
  rule3.stateModifier = StateModifier.create(0, 0, 0);
  rule3.description = '适宜温度，味型均�?;
  rules.push(rule3);

  // 高温 25-30°C
  const rule4 = new TemperatureRule();
  rule4.minTemp = 25; rule4.maxTemp = 30;
  rule4.flavorModifier = FlavorModifier.create(-20, 10, -10, 20, 0);
  rule4.stateModifier = StateModifier.create(15, -10, -10);
  rule4.description = '高温，减腥增酸，清淡为主，雾化加�?;
  rules.push(rule4);

  // 极高�?30-40°C
  const rule5 = new TemperatureRule();
  rule5.minTemp = 30; rule5.maxTemp = 40;
  rule5.flavorModifier = FlavorModifier.create(-40, 0, -20, 30, 0);
  rule5.stateModifier = StateModifier.create(25, -20, -20);
  rule5.description = '极高温，极清淡，果酸为主，快雾化';
  rules.push(rule5);

  return rules;
}

// ============================================================
// 鱼情修正规则
// ============================================================

// 鱼密度修�?
export function getDensityModifier(density: string): StateModifier {
  if (density === 'high') {
    return StateModifier.create(20, -10, -10);  // 高密度：快雾化抢�?
  } else if (density === 'low') {
    return StateModifier.create(-20, 15, 10);   // 低密度：慢雾化留�?
  }
  return StateModifier.create(0, 0, 0);         // 中等：不修正
}

// 开口情况修�?
export function getActivityModifier(activity: string): StateModifier {
  if (activity === 'good') {
    return StateModifier.create(5, 0, -10);     // 开口好：味型可�?
  } else if (activity === 'poor') {
    return StateModifier.create(-5, -10, 20);   // 开口差：味型要浓，状态要�?
  }
  return StateModifier.create(0, 0, 0);         // 一般：不修�?
}

// 作钓方式修正
export function getMethodModifier(method: string): StateModifier {
  if (method === 'pull') {
    return StateModifier.create(10, 15, 0);     // 拉饵：需要拉�?
  } else if (method === 'scatter') {
    return StateModifier.create(30, -20, 0);    // 散炮：极快雾�?
  } else if (method === 'wrap') {
    return StateModifier.create(-10, 10, 0);    // 包食：外雾化内粘
  }
  return StateModifier.create(0, 5, 0);         // 搓饵：默�?
}


// ============================================================
// 模式修正规则
// ============================================================

// 获取模式修正
export function getModeModifier(mode: string): ModeModifier {
  if (mode === 'conservative') {
    return ModeModifier.create(0.8, -15);
  } else if (mode === 'aggressive') {
    return ModeModifier.create(1.3, 15);
  }
  return ModeModifier.create(1.0, 0);  // balanced
}

// ============================================================
// 生成理由模板
// ============================================================

// 获取温度理由
export function getTempReasonTemplate(temp: number): ReasonTemplate {
  if (temp < 10) {
    return ReasonTemplate.create(`水温极低(${temp}°C)`, '浓腥浓香，慢雾化留鱼', '❄️');
  } else if (temp < 15) {
    return ReasonTemplate.create(`水温偏低(${temp}°C)`, '增加腥味比例', '🌡�?);
  } else if (temp < 25) {
    return ReasonTemplate.create(`水温适宜(${temp}°C)`, '味型均衡', '�?);
  } else if (temp < 30) {
    return ReasonTemplate.create(`水温较高(${temp}°C)`, '减腥增酸，清淡为�?, '☀�?);
  }
  return ReasonTemplate.create(`水温极高(${temp}°C)`, '极清淡，果酸为主', '🔥');
}

// 获取水域理由
export function getWaterReasonTemplate(waterType: string): ReasonTemplate {
  if (waterType === 'river') {
    return ReasonTemplate.create('野河流水环境', '降低雾化，增加粘�?, '🌊');
  } else if (waterType === 'pond') {
    return ReasonTemplate.create('黑坑竞争激�?, '加快雾化，味型加�?, '🏊');
  } else if (waterType === 'reservoir') {
    return ReasonTemplate.create('水库深水�?, '大颗粒，留鱼持久', '🏔�?);
  }
  return ReasonTemplate.create('野塘自然环境', '味型适中，状态自�?, '🌿');
}

// 获取鱼情理由
export function getDensityReasonTemplate(density: string): ReasonTemplate | null {
  if (density === 'high') {
    return ReasonTemplate.create('鱼密度较�?, '快雾化抢�?, '📈');
  } else if (density === 'low') {
    return ReasonTemplate.create('鱼密度较�?, '慢雾化留鱼，增加诱鱼成分', '📉');
  }
  return null;
}

// 获取开口理�?
export function getActivityReasonTemplate(activity: string): ReasonTemplate | null {
  if (activity === 'good') {
    return ReasonTemplate.create('鱼开口情况好', '味型可适当减淡', '😊');
  } else if (activity === 'poor') {
    return ReasonTemplate.create('鱼开口情况差', '味型加重，状态要�?, '😐');
  }
  return null;
}

// 获取模式理由
export function getModeReasonTemplate(mode: string): ReasonTemplate | null {
  if (mode === 'conservative') {
    return ReasonTemplate.create('保守模式', '经典配方，稳定出�?, '🛡�?);
  } else if (mode === 'aggressive') {
    return ReasonTemplate.create('激进模�?, '味型浓烈，可能爆�?, '�?);
  }
  return null;
}

// 获取鱼种理由
export function getFishReasonTemplate(fishId: string): ReasonTemplate {
  const fishReasons: Map<string, ReasonTemplate> = new Map();
  fishReasons.set('crucian', ReasonTemplate.create('目标鲫鱼', '细颗粒、轻状�?, '🐟'));
  fishReasons.set('carp', ReasonTemplate.create('目标鲤鱼', '甜香为主，大颗粒', '🐟'));
  fishReasons.set('grass_carp', ReasonTemplate.create('目标草鱼', '香甜酸味，发酵饵', '🐟'));
  fishReasons.set('silver_carp', ReasonTemplate.create('目标鲢鱼', '酸臭味，快雾�?, '🐟'));
  fishReasons.set('bighead', ReasonTemplate.create('目标鳙鱼', '臭味为主，雾化好', '🐟'));
  fishReasons.set('catfish', ReasonTemplate.create('目标鲶鱼', '浓腥臭味', '🐟'));
  fishReasons.set('bream', ReasonTemplate.create('目标鳊鱼', '香甜味，中层�?, '🐟'));
  fishReasons.set('black_carp', ReasonTemplate.create('目标青鱼', '腥香重口，大饵守�?, '🐟'));
  fishReasons.set('yellow_catfish', ReasonTemplate.create('目标黄颡�?, '浓腥味，蚯蚓鸡肝效果�?, '🐟'));
  fishReasons.set('culter', ReasonTemplate.create('目标翘嘴', '腥香味，路亚或活�?, '🐟'));
  fishReasons.set('tilapia', ReasonTemplate.create('目标罗非�?, '腥香甜，颗粒饵效果好', '🐟'));
  fishReasons.set('mandarin_fish', ReasonTemplate.create('目标鳜鱼', '浓腥味，活饵为主', '🐟'));
  fishReasons.set('wuchang_fish', ReasonTemplate.create('目标武昌�?, '香甜味，中层�?, '🐟'));
  fishReasons.set('snakehead', ReasonTemplate.create('目标黑鱼', '极浓腥，活饵路亚', '🐟'));
  fishReasons.set('catla', ReasonTemplate.create('目标鲮鱼', '香甜味，花生粉效果好', '🐟'));
  fishReasons.set('bass', ReasonTemplate.create('目标大口黑鲈', '浓腥味，路亚为主', '🐟'));
  fishReasons.set('channel_catfish', ReasonTemplate.create('目标斑点叉尾�?, '浓腥臭味，夜钓效果好', '🐟'));
  fishReasons.set('topmouth_culter', ReasonTemplate.create('目标马口', '腥香味，溪流路亚', '🐟'));
  fishReasons.set('loach', ReasonTemplate.create('目标泥鳅', '浓腥味，蚯蚓红虫', '🐟'));
  fishReasons.set('giant_carp', ReasonTemplate.create('目标巨鲤', '甜香重口，大饵守�?, '🐟'));
  fishReasons.set('pike', ReasonTemplate.create('目标狗鱼', '极浓腥，活饵路亚', '🐟'));
  fishReasons.set('perch', ReasonTemplate.create('目标鲈鱼', '浓腥味，活饵效果�?, '🐟'));
  fishReasons.set('eel', ReasonTemplate.create('目标黄鳝', '浓腥臭味，蚯蚓效果好', '🐟'));
  fishReasons.set('softshell_turtle', ReasonTemplate.create('目标甲鱼', '浓腥味，鸡肝猪肝', '🐟'));
  fishReasons.set('barbel', ReasonTemplate.create('目标鲃鱼', '腥香味，急流�?, '🐟'));
  fishReasons.set('chub', ReasonTemplate.create('目标赤眼�?, '香甜腥味，中层钓', '🐟'));
  fishReasons.set('mandarin_fish_river', ReasonTemplate.create('目标河鳜', '浓腥味，活饵为主', '🐟'));
  fishReasons.set('yellow_cheek', ReasonTemplate.create('目标黄尾�?, '香甜味，底钓', '🐟'));
  fishReasons.set('whitebait', ReasonTemplate.create('目标银鱼', '腥香味，细线小钩', '🐟'));
  fishReasons.set('redfin_culter', ReasonTemplate.create('目标红鳍�?, '腥香味，路亚或活�?, '🐟'));
  fishReasons.set('crab', ReasonTemplate.create('目标河蟹', '浓腥味，蟹笼诱捕', '🐟'));
  fishReasons.set('shrimp', ReasonTemplate.create('目标河虾', '腥香味，虾笼诱捕', '🐟'));

  const r = fishReasons.get(fishId);
  if (r) return r;
  return ReasonTemplate.create('目标�?, '通用配方', '🐟');
}

// ============================================================
// 数据库类
// ============================================================

class RecipeRulesDatabase {
  private fishRules: Map<string, FishRecipeRule> = new Map();
  private temperatureRules: TemperatureRule[] = [];

  constructor() {
    // 初始化鱼种规�?
    const crucian = createCrucianRule();
    const carp = createCarpRule();
    const grass = createGrassRule();
    const black = createBlackRule();
    const silver = createSilverRule();
    const bighead = createBigheadRule();
    const catfish = createCatfishRule();
    const bream = createBreamRule();
    const yellowCatfish = createYellowCatfishRule();
    const culter = createCulterRule();
    const tilapia = createTilapiaRule();
    const mandarinFish = createMandarinFishRule();
    const wuchangFish = createWuchangFishRule();
    const snakehead = createSnakeheadRule();
    const catla = createCatlaRule();
    const bass = createBassRule();
    const channelCatfish = createChannelCatfishRule();
    const topmouthCulter = createTopmouthCulterRule();
    const loach = createLoachRule();
    const giantCarp = createGiantCarpRule();
    const pike = createPikeRule();
    const perch = createPerchRule();
    const eel = createEelRule();
    const softshellTurtle = createSoftshellTurtleRule();
    const barbel = createBarbelRule();
    const chub = createChubRule();
    const riverMandarinFish = createRiverMandarinFishRule();
    const yellowCheek = createYellowCheekRule();
    const whitebait = createWhitebaitRule();
    const redfinCulter = createRedfinCulterRule();
    const crab = createCrabRule();
    const shrimp = createShrimpRule();

    this.fishRules.set(crucian.fishId, crucian);
    this.fishRules.set(carp.fishId, carp);
    this.fishRules.set(grass.fishId, grass);
    this.fishRules.set(black.fishId, black);
    this.fishRules.set(silver.fishId, silver);
    this.fishRules.set(bighead.fishId, bighead);
    this.fishRules.set(catfish.fishId, catfish);
    this.fishRules.set(bream.fishId, bream);
    this.fishRules.set(yellowCatfish.fishId, yellowCatfish);
    this.fishRules.set(culter.fishId, culter);
    this.fishRules.set(tilapia.fishId, tilapia);
    this.fishRules.set(mandarinFish.fishId, mandarinFish);
    this.fishRules.set(wuchangFish.fishId, wuchangFish);
    this.fishRules.set(snakehead.fishId, snakehead);
    this.fishRules.set(catla.fishId, catla);
    this.fishRules.set(bass.fishId, bass);
    this.fishRules.set(channelCatfish.fishId, channelCatfish);
    this.fishRules.set(topmouthCulter.fishId, topmouthCulter);
    this.fishRules.set(loach.fishId, loach);
    this.fishRules.set(giantCarp.fishId, giantCarp);
    this.fishRules.set(pike.fishId, pike);
    this.fishRules.set(perch.fishId, perch);
    this.fishRules.set(eel.fishId, eel);
    this.fishRules.set(softshellTurtle.fishId, softshellTurtle);
    this.fishRules.set(barbel.fishId, barbel);
    this.fishRules.set(chub.fishId, chub);
    this.fishRules.set(riverMandarinFish.fishId, riverMandarinFish);
    this.fishRules.set(yellowCheek.fishId, yellowCheek);
    this.fishRules.set(whitebait.fishId, whitebait);
    this.fishRules.set(redfinCulter.fishId, redfinCulter);
    this.fishRules.set(crab.fishId, crab);
    this.fishRules.set(shrimp.fishId, shrimp);

    // 初始化温度规�?
    this.temperatureRules = getTemperatureRules();
  }

  getFishRule(fishId: string): FishRecipeRule | null {
    const rule = this.fishRules.get(fishId);
    if (rule) return rule;
    return null;
  }

  getAllFishRules(): FishRecipeRule[] {
    const rules: FishRecipeRule[] = [];
    this.fishRules.forEach((rule) => rules.push(rule));
    return rules;
  }

  getTemperatureRule(temp: number): TemperatureRule {
    for (let i = 0; i < this.temperatureRules.length; i++) {
      const rule = this.temperatureRules[i];
      if (temp >= rule.minTemp && temp < rule.maxTemp) {
        return rule;
      }
    }
    // 默认返回适宜温度规则
    return this.temperatureRules[2];
  }

  getAllTemperatureRules(): TemperatureRule[] {
    return this.temperatureRules;
  }
}

// 导出单例
export const recipeRulesDatabase = new RecipeRulesDatabase();

// 导出便捷函数
export function getFishRule(fishId: string): FishRecipeRule | null {
  return recipeRulesDatabase.getFishRule(fishId);
}

export function getTemperatureRule(temp: number): TemperatureRule {
  return recipeRulesDatabase.getTemperatureRule(temp);
}

export function getAllFishRules(): FishRecipeRule[] {
  return recipeRulesDatabase.getAllFishRules();
}
