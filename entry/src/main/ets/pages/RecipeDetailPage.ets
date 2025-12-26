/**
 * 饵知道 - 配方详情页
 * 支持显示预设配方和用户保存的配方
 */
import { ThemeColors } from '../theme/ThemeColors';
import { ThemeConstants } from '../theme/ThemeConstants';
import { Router } from '../router/Router';
import { router } from '@kit.ArkUI';
import { userDataService, CustomRecipe, CustomRecipeIngredient, RecipeStateProfile, RecipeFlavorProfile } from '../services/UserDataService';

// 配方材料类
class RecipeIngredientItem {
  name: string = '';
  amount: string = '';
  unit: string = '';

  constructor(name: string = '', amount: string = '', unit: string = '') {
    this.name = name;
    this.amount = amount;
    this.unit = unit;
  }
}

// 推荐理由类
class RecommendReasonItem {
  title: string = '';
  description: string = '';

  constructor(title: string = '', description: string = '') {
    this.title = title;
    this.description = description;
  }
}

// 配方详情类
class RecipeDetailData {
  id: string = '';
  name: string = '';
  description: string = '';
  targetFish: string[] = [];
  waterTypes: string[] = [];
  seasons: string[] = [];
  difficulty: string = '简单';
  prepTime: string = '10分钟';
  ingredients: RecipeIngredientItem[] = [];
  steps: string[] = [];
  tips: string[] = [];
  rating: number = 4.5;
  usageCount: number = 0;
  flavorPrimary: string = '';
  flavorIntensity: number = 3;
  suitableTemp: string = '15-25°C';
  atomization: number = 3;
  viscosity: number = 3;
  hookHolding: number = 3;
  weight: number = 3;
  reasons: RecommendReasonItem[] = [];
  isUserRecipe: boolean = false;
}


// 预设配方数据库
class PresetRecipeDatabase {
  private static recipes: Map<string, RecipeDetailData> = new Map();
  private static initialized: boolean = false;

  static initialize(): void {
    if (PresetRecipeDatabase.initialized) return;

    // 池塘配方
    PresetRecipeDatabase.addRecipe('r_001', '池塘鲫鱼散炮', '专为池塘钓鲫鱼设计的散炮配方，雾化快，诱鱼效果好。', ['鲫鱼'], ['池塘'], ['春季'],
      [new RecipeIngredientItem('麸皮', '200', 'g'), new RecipeIngredientItem('雪花粉', '100', 'g'), new RecipeIngredientItem('拉丝粉', '50', 'g')],
      ['将麸皮和雪花粉按2:1比例混合', '加入拉丝粉搅拌均匀', '按1:0.8比例加水', '静置5分钟后使用'],
      ['散炮不宜太湿', '抛竿频率要快'], '谷香', 3, 4, 2, 3, 3);

    PresetRecipeDatabase.addRecipe('r_002', '黑坑鲤鱼颗粒', '黑坑钓鲤鱼专用，原塘颗粒为主，适口性好。', ['鲤鱼'], ['池塘'], ['四季'],
      [new RecipeIngredientItem('原塘颗粒', '300', 'g'), new RecipeIngredientItem('小药', '5', 'ml'), new RecipeIngredientItem('状态粉', '50', 'g')],
      ['颗粒用水泡软', '加入小药搅拌', '加入状态粉调整', '揉成软硬适中的饵团'],
      ['颗粒要泡透', '小药不宜过量'], '原塘味', 4, 3, 4, 4, 4);

    PresetRecipeDatabase.addRecipe('r_003', '池塘草鱼青草饵', '夏季浮钓草鱼专用，清香自然。', ['草鱼'], ['池塘'], ['夏季'],
      [new RecipeIngredientItem('嫩草', '适量', ''), new RecipeIngredientItem('玉米', '100', 'g'), new RecipeIngredientItem('麦麸', '50', 'g')],
      ['嫩草切段备用', '玉米煮熟', '麦麸加水调成糊', '草段蘸麦麸糊使用'],
      ['草要新鲜嫩绿', '浮钓效果更好'], '草香', 3, 4, 2, 3, 2);

    PresetRecipeDatabase.addRecipe('r_004', '池塘鳙鱼酸臭饵', '夏季浮钓鳙鱼专用，酸臭味型诱鱼效果极佳。', ['鳙鱼'], ['池塘'], ['夏季'],
      [new RecipeIngredientItem('臭豆腐汁', '50', 'ml'), new RecipeIngredientItem('蒜粉', '30', 'g'), new RecipeIngredientItem('雪花粉', '200', 'g')],
      ['雪花粉倒入盆中', '加入臭豆腐汁搅拌', '撒入蒜粉混合均匀', '加水调成散炮状态'],
      ['味道要够冲', '雾化要快', '浮钓效果最佳'], '酸臭', 5, 5, 1, 2, 2);

    PresetRecipeDatabase.addRecipe('r_005', '池塘鲢鱼酸饵', '夏季浮钓鲢鱼专用，果酸味型清爽诱鱼。', ['鲢鱼'], ['池塘'], ['夏季'],
      [new RecipeIngredientItem('果酸', '30', 'ml'), new RecipeIngredientItem('白醋', '20', 'ml'), new RecipeIngredientItem('雪花粉', '200', 'g')],
      ['雪花粉倒入盆中', '加入果酸和白醋', '快速搅拌均匀', '调成散炮状态使用'],
      ['酸味要足', '雾化要快', '钓浮效果好'], '果酸', 4, 5, 1, 2, 2);

    PresetRecipeDatabase.addRecipe('r_006', '南方罗非专用饵', '南方池塘钓罗非鱼专用，腥味浓郁适口性好。', ['罗非鱼'], ['池塘'], ['夏季'],
      [new RecipeIngredientItem('罗非颗粒', '200', 'g'), new RecipeIngredientItem('虾粉', '50', 'g'), new RecipeIngredientItem('蚯蚓膏', '20', 'ml')],
      ['罗非颗粒用水泡软', '加入虾粉搅拌', '滴入蚯蚓膏增腥', '揉成软硬适中饵团'],
      ['颗粒要泡透', '腥味要足', '底钓效果好'], '浓腥', 5, 3, 4, 4, 4);

    PresetRecipeDatabase.addRecipe('r_007', '黑坑叉尾专用饵', '黑坑夜钓斑点叉尾鮰专用，浓腥味型诱鱼快。', ['斑点叉尾鮰'], ['池塘'], ['四季'],
      [new RecipeIngredientItem('鲶鱼颗粒', '200', 'g'), new RecipeIngredientItem('鸡肝粉', '80', 'g'), new RecipeIngredientItem('虾粉', '50', 'g')],
      ['鲶鱼颗粒泡软', '加入鸡肝粉和虾粉', '充分搅拌均匀', '揉成较粘饵团'],
      ['腥味要浓', '夜钓效果最佳', '饵团要粘'], '浓腥', 5, 2, 4, 5, 4);

    PresetRecipeDatabase.addRecipe('r_008', '池塘鲶鱼腥饵', '池塘夜钓鲶鱼专用，鸡肝蚯蚓组合效果极佳。', ['鲶鱼'], ['池塘'], ['四季'],
      [new RecipeIngredientItem('鸡肝', '200', 'g'), new RecipeIngredientItem('蚯蚓', '适量', ''), new RecipeIngredientItem('血粉', '30', 'g')],
      ['鸡肝切小块备用', '蚯蚓穿钩使用', '血粉拌入鸡肝增腥', '鸡肝挂钩或打窝'],
      ['鸡肝要新鲜', '夜钓效果最佳', '腥味要足'], '血腥', 5, 1, 5, 5, 5);

    PresetRecipeDatabase.addRecipe('r_009', '池塘泥鳅饵', '池塘钓泥鳅专用，蚯蚓红虫效果最佳。', ['泥鳅'], ['池塘'], ['夏季'],
      [new RecipeIngredientItem('蚯蚓', '适量', ''), new RecipeIngredientItem('红虫', '适量', '')],
      ['蚯蚓切段穿钩', '红虫多条挂钩', '钓底效果好', '保持安静等待'],
      ['用细线小钩', '动作要轻', '泥底区域效果好'], '腥香', 4, 1, 5, 4, 3);

    PresetRecipeDatabase.addRecipe('r_010', '池塘黑鱼雷蛙', '池塘路亚黑鱼专用，雷蛙是黑鱼克星。', ['黑鱼'], ['池塘'], ['夏季'],
      [new RecipeIngredientItem('雷蛙', '1', '只'), new RecipeIngredientItem('软虫', '适量', ''), new RecipeIngredientItem('泥鳅', '适量', '')],
      ['雷蛙绑好线组', '抛投到草边或障碍区', '模拟青蛙跳动', '黑鱼炸水后扬竿'],
      ['草边障碍区效果好', '早晚时段最佳', '扬竿要有力'], '路亚', 5, 1, 5, 5, 5);

    PresetRecipeDatabase.addRecipe('r_011', '池塘甲鱼饵', '池塘夜钓甲鱼专用，动物内脏效果极佳。', ['甲鱼'], ['池塘'], ['夏季'],
      [new RecipeIngredientItem('鸡肝', '200', 'g'), new RecipeIngredientItem('猪肝', '100', 'g'), new RecipeIngredientItem('蚯蚓', '适量', '')],
      ['鸡肝猪肝切块', '蚯蚓穿钩使用', '内脏打窝诱鱼', '耐心守钓'],
      ['夜钓效果最佳', '内脏要新鲜', '钩要锋利'], '血腥', 5, 1, 5, 5, 5);

    // 河流配方
    PresetRecipeDatabase.addRecipe('r_101', '野河鲫鱼蚯蚓伴侣', '野河钓鲫鱼经典配方，蚯蚓粉增加诱鱼效果。', ['鲫鱼'], ['河流'], ['四季'],
      [new RecipeIngredientItem('蚯蚓粉', '50', 'g'), new RecipeIngredientItem('红虫', '适量', ''), new RecipeIngredientItem('酒米', '100', 'g')],
      ['酒米提前打窝', '蚯蚓粉拌入饵料', '红虫挂钩使用', '保持安静等待'],
      ['野河要找鱼道', '酒米窝量要足'], '腥香', 4, 3, 3, 4, 3);

    PresetRecipeDatabase.addRecipe('r_102', '江河鲤鱼玉米饵', '江河守钓大鲤专用，发酵玉米诱鱼效果极佳。', ['鲤鱼'], ['河流'], ['夏秋'],
      [new RecipeIngredientItem('发酵玉米', '500', 'g'), new RecipeIngredientItem('蜂蜜', '30', 'ml'), new RecipeIngredientItem('麦粒', '200', 'g')],
      ['发酵玉米打重窝', '蜂蜜拌入玉米', '麦粒混合使用', '耐心守钓'],
      ['窝量要大', '守钓要有耐心'], '酒香', 5, 2, 5, 5, 4);

    PresetRecipeDatabase.addRecipe('r_103', '河流草鱼嫩草饵', '河流浮钓草鱼专用，嫩草芦苇芯自然清香。', ['草鱼'], ['河流'], ['夏季'],
      [new RecipeIngredientItem('嫩草', '适量', ''), new RecipeIngredientItem('芦苇芯', '适量', ''), new RecipeIngredientItem('玉米粒', '100', 'g')],
      ['嫩草切段备用', '芦苇芯取嫩心', '玉米粒煮熟打窝', '草段挂钩浮钓'],
      ['草要新鲜嫩绿', '浮钓中上层', '早晚效果好'], '草香', 3, 4, 2, 3, 2);

    PresetRecipeDatabase.addRecipe('r_104', '河流鲶鱼腥饵', '河流夜钓鲶鱼专用，深潭区域效果极佳。', ['鲶鱼'], ['河流'], ['四季'],
      [new RecipeIngredientItem('鸡肝', '200', 'g'), new RecipeIngredientItem('蚯蚓', '适量', ''), new RecipeIngredientItem('泥鳅', '适量', '')],
      ['鸡肝切块打窝', '蚯蚓或泥鳅挂钩', '选择深潭区域', '夜钓守候'],
      ['深潭效果好', '夜钓最佳', '腥味要足'], '血腥', 5, 1, 5, 5, 5);

    PresetRecipeDatabase.addRecipe('r_105', '河流黄颡鱼饵', '河流夜钓黄颡鱼专用，石缝乱石区效果好。', ['黄颡鱼'], ['河流'], ['夏季'],
      [new RecipeIngredientItem('蚯蚓', '适量', ''), new RecipeIngredientItem('鸡肝', '100', 'g'), new RecipeIngredientItem('红虫', '适量', '')],
      ['蚯蚓穿钩使用', '鸡肝切小块打窝', '红虫备用', '石缝区域作钓'],
      ['石缝乱石区效果好', '夜钓最佳', '用小钩细线'], '腥香', 4, 2, 4, 4, 3);

    PresetRecipeDatabase.addRecipe('r_106', '河流鳊鱼素饵', '河流钓鳊鱼专用，香甜味型中层效果好。', ['鳊鱼'], ['河流'], ['春夏'],
      [new RecipeIngredientItem('麸皮', '150', 'g'), new RecipeIngredientItem('玉米粉', '100', 'g'), new RecipeIngredientItem('蜂蜜', '20', 'ml')],
      ['麸皮玉米粉混合', '加入蜂蜜搅拌', '加水调成软饵', '钓中层效果好'],
      ['味型要香甜', '钓中层', '春夏效果好'], '香甜', 4, 4, 3, 3, 3);

    PresetRecipeDatabase.addRecipe('r_107', '河流翘嘴路亚饵', '河流路亚翘嘴专用，亮片活虾效果极佳。', ['翘嘴'], ['河流'], ['夏秋'],
      [new RecipeIngredientItem('亮片', '1', '只'), new RecipeIngredientItem('活虾', '适量', ''), new RecipeIngredientItem('小鱼', '适量', '')],
      ['亮片绑好线组', '抛投到水面', '快速收线模拟小鱼', '翘嘴追咬后扬竿'],
      ['早晚效果最佳', '水面有鱼花时作钓', '收线要快'], '路亚', 5, 1, 5, 5, 4);

    PresetRecipeDatabase.addRecipe('r_108', '溪流马口饵', '溪流路亚马口专用，小型拟饵效果好。', ['马口'], ['河流'], ['夏季'],
      [new RecipeIngredientItem('蚂蚱', '适量', ''), new RecipeIngredientItem('蟋蟀', '适量', ''), new RecipeIngredientItem('亮片', '1', '只')],
      ['蚂蚱蟋蟀挂钩', '小亮片抛投', '溪流浅滩作钓', '轻装简行'],
      ['溪流浅滩效果好', '用超轻装备', '夏季最佳'], '路亚', 4, 1, 4, 4, 3);

    PresetRecipeDatabase.addRecipe('r_109', '急流鲃鱼饵', '急流钓鲃鱼专用，活饵效果最佳。', ['鲃鱼'], ['河流'], ['夏季'],
      [new RecipeIngredientItem('蚯蚓', '适量', ''), new RecipeIngredientItem('活虾', '适量', ''), new RecipeIngredientItem('螺蛳', '适量', '')],
      ['蚯蚓穿钩使用', '活虾挂钩', '螺蛳打窝', '急流区域作钓'],
      ['急流区效果好', '用重坠', '活饵最佳'], '腥香', 4, 2, 4, 4, 4);

    PresetRecipeDatabase.addRecipe('r_110', '河钓赤眼鳟饵', '河流钓赤眼鳟专用，中层作钓效果好。', ['赤眼鳟'], ['河流'], ['春夏'],
      [new RecipeIngredientItem('蚯蚓', '适量', ''), new RecipeIngredientItem('玉米粉', '100', 'g'), new RecipeIngredientItem('面粉', '50', 'g')],
      ['玉米粉面粉混合', '加水调成面饵', '蚯蚓备用', '钓中层'],
      ['中层效果好', '春夏最佳', '面饵要软'], '谷香', 3, 3, 3, 3, 3);

    PresetRecipeDatabase.addRecipe('r_111', '河流泥鳅饵', '河流钓泥鳅专用，泥底区域效果好。', ['泥鳅'], ['河流'], ['夏季'],
      [new RecipeIngredientItem('蚯蚓', '适量', ''), new RecipeIngredientItem('红虫', '适量', '')],
      ['蚯蚓切段穿钩', '红虫多条挂钩', '泥底区域作钓', '保持安静'],
      ['泥底效果好', '用细线小钩', '动作要轻'], '腥香', 4, 1, 5, 4, 3);

    PresetRecipeDatabase.addRecipe('r_112', '河流鳜鱼活饵', '河流钓鳜鱼专用，活饵是鳜鱼最爱。', ['河鳜'], ['河流'], ['春秋'],
      [new RecipeIngredientItem('活泥鳅', '适量', ''), new RecipeIngredientItem('活虾', '适量', ''), new RecipeIngredientItem('小鱼', '适量', '')],
      ['活泥鳅挂钩', '活虾备用', '小鱼打窝', '障碍区作钓'],
      ['障碍区效果好', '活饵要鲜活', '春秋最佳'], '活饵', 5, 1, 5, 5, 5);

    // 水库配方
    PresetRecipeDatabase.addRecipe('r_201', '水库大鲤守钓饵', '水库守钓大鲤专用配方，发酵玉米配合药酒，诱鱼留鱼效果极佳。', ['鲤鱼'], ['水库'], ['秋季'],
      [new RecipeIngredientItem('发酵玉米', '500', 'g'), new RecipeIngredientItem('红薯', '200', 'g'), new RecipeIngredientItem('药酒', '50', 'ml')],
      ['发酵玉米提前准备', '红薯蒸熟捣碎', '加入药酒搅拌', '打重窝守钓'],
      ['窝量要足', '守钓需耐心', '药酒不宜过量'], '酒香', 5, 2, 5, 5, 5);

    PresetRecipeDatabase.addRecipe('r_205', '水库青鱼螺蛳饵', '水库钓青鱼专用，螺蛳是青鱼最爱。', ['青鱼'], ['水库'], ['四季'],
      [new RecipeIngredientItem('田螺', '500', 'g'), new RecipeIngredientItem('螺蛳粉', '100', 'g'), new RecipeIngredientItem('蚌肉粉', '50', 'g')],
      ['田螺砸碎打窝', '螺蛳粉拌饵', '蚌肉粉增腥', '整螺挂钩'],
      ['螺蛳要新鲜', '钩要用大号'], '腥香', 5, 2, 5, 5, 5);

    PresetRecipeDatabase.addRecipe('r_202', '水库草鱼浮钓饵', '水库浮钓草鱼专用，嫩玉米青草自然清香。', ['草鱼'], ['水库'], ['夏季'],
      [new RecipeIngredientItem('嫩玉米', '200', 'g'), new RecipeIngredientItem('青草', '适量', ''), new RecipeIngredientItem('麦麸', '100', 'g')],
      ['嫩玉米剥粒备用', '青草切段', '麦麸打窝诱鱼', '玉米或草段挂钩'],
      ['浮钓中上层', '早晚效果好', '草要新鲜'], '草香', 3, 4, 2, 3, 2);

    PresetRecipeDatabase.addRecipe('r_203', '水库鳙鱼浮钓饵', '水库浮钓鳙鱼专用，酸臭味型诱鱼快。', ['鳙鱼'], ['水库'], ['夏季'],
      [new RecipeIngredientItem('藿香正气水', '20', 'ml'), new RecipeIngredientItem('臭豆腐汁', '50', 'ml'), new RecipeIngredientItem('轻麸', '200', 'g')],
      ['轻麸倒入盆中', '加入藿香正气水', '加入臭豆腐汁搅拌', '调成散炮状态'],
      ['味道要够冲', '雾化要快', '浮钓效果好'], '酸臭', 5, 5, 1, 2, 2);

    PresetRecipeDatabase.addRecipe('r_204', '水库鲢鱼手竿饵', '水库手竿钓鲢鱼专用，果酸味型清爽。', ['鲢鱼'], ['水库'], ['夏季'],
      [new RecipeIngredientItem('果酸', '30', 'ml'), new RecipeIngredientItem('白醋', '20', 'ml'), new RecipeIngredientItem('雪花粉', '200', 'g')],
      ['雪花粉倒入盆中', '加入果酸白醋', '快速搅拌均匀', '调成散炮使用'],
      ['酸味要足', '雾化要快', '浮钓效果好'], '果酸', 4, 5, 1, 2, 2);

    PresetRecipeDatabase.addRecipe('r_206', '水库鳜鱼活饵', '水库钓鳜鱼专用，活饵是鳜鱼最爱。', ['鳜鱼'], ['水库'], ['春秋'],
      [new RecipeIngredientItem('活泥鳅', '适量', ''), new RecipeIngredientItem('活虾', '适量', ''), new RecipeIngredientItem('小鱼', '适量', '')],
      ['活泥鳅挂钩', '活虾备用', '小鱼打窝', '障碍区守钓'],
      ['障碍区效果好', '活饵要鲜活', '春秋最佳'], '活饵', 5, 1, 5, 5, 5);

    PresetRecipeDatabase.addRecipe('r_207', '水库武昌鱼素饵', '水库钓武昌鱼专用，香甜味型中层效果好。', ['武昌鱼'], ['水库'], ['春夏'],
      [new RecipeIngredientItem('麸皮', '150', 'g'), new RecipeIngredientItem('玉米粉', '100', 'g'), new RecipeIngredientItem('蜂蜜', '20', 'ml')],
      ['麸皮玉米粉混合', '加入蜂蜜搅拌', '加水调成软饵', '钓中层效果好'],
      ['味型要香甜', '钓中层', '春夏效果好'], '香甜', 4, 4, 3, 3, 3);

    PresetRecipeDatabase.addRecipe('r_208', '水库巨鲤重窝饵', '水库守钓巨鲤专用，重窝守大物。', ['巨鲤'], ['水库'], ['春秋'],
      [new RecipeIngredientItem('发酵玉米', '1000', 'g'), new RecipeIngredientItem('红薯', '300', 'g'), new RecipeIngredientItem('药酒', '100', 'ml')],
      ['发酵玉米提前准备', '红薯蒸熟捣碎', '加入药酒搅拌', '打重窝守钓'],
      ['窝量要足', '守钓需耐心', '大物专用'], '酒香', 5, 2, 5, 5, 5);

    PresetRecipeDatabase.addRecipe('r_209', '水库黄尾鲴饵', '水库钓黄尾鲴专用，底钓效果好。', ['黄尾鲴'], ['水库'], ['春夏'],
      [new RecipeIngredientItem('混合颗粒', '150', 'g'), new RecipeIngredientItem('麸皮', '100', 'g'), new RecipeIngredientItem('蚯蚓粉', '30', 'g')],
      ['颗粒泡软', '加入麸皮混合', '蚯蚓粉增腥', '调成软饵底钓'],
      ['底钓效果好', '饵料要软', '春夏最佳'], '腥香', 4, 3, 4, 4, 4);

    PresetRecipeDatabase.addRecipe('r_210', '南方鲮鱼专用饵', '南方水库钓鲮鱼专用，花生粉是鲮鱼最爱。', ['鲮鱼'], ['水库'], ['夏秋'],
      [new RecipeIngredientItem('花生粉', '150', 'g'), new RecipeIngredientItem('麸皮', '100', 'g'), new RecipeIngredientItem('玉米粉', '50', 'g')],
      ['花生粉麸皮混合', '加入玉米粉', '加水调成软饵', '底钓效果好'],
      ['花生味要足', '底钓', '南方特色'], '花生香', 4, 3, 4, 4, 4);

    PresetRecipeDatabase.addRecipe('r_211', '水库黑鲈路亚饵', '水库路亚大口黑鲈专用，软虫效果极佳。', ['大口黑鲈'], ['水库'], ['春夏秋'],
      [new RecipeIngredientItem('软虫', '适量', ''), new RecipeIngredientItem('活虾', '适量', ''), new RecipeIngredientItem('小鱼', '适量', '')],
      ['软虫绑好钩组', '抛投到障碍区', '慢速拖动', '感觉咬口后扬竿'],
      ['障碍区效果好', '慢速拖动', '春夏秋皆可'], '路亚', 5, 1, 5, 5, 4);

    PresetRecipeDatabase.addRecipe('r_212', '水库翘嘴路亚饵', '水库路亚翘嘴专用，亮片效果极佳。', ['翘嘴'], ['水库'], ['夏秋'],
      [new RecipeIngredientItem('亮片', '1', '只'), new RecipeIngredientItem('活虾', '适量', ''), new RecipeIngredientItem('小鱼', '适量', '')],
      ['亮片绑好线组', '抛投到水面', '快速收线', '翘嘴追咬后扬竿'],
      ['早晚效果最佳', '水面有鱼花时作钓', '收线要快'], '路亚', 5, 1, 5, 5, 4);

    // 湖泊配方
    PresetRecipeDatabase.addRecipe('r_301', '湖泊鲫鱼传统钓', '湖泊传统钓鲫鱼经典配方，酒米打窝，蚯蚓红虫挂钩。', ['鲫鱼'], ['湖泊'], ['四季'],
      [new RecipeIngredientItem('酒米', '200', 'g'), new RecipeIngredientItem('蚯蚓', '适量', ''), new RecipeIngredientItem('红虫', '适量', '')],
      ['酒米打窝诱鱼', '蚯蚓或红虫挂钩', '七星漂调灵', '逗钓效果好'],
      ['窝点要准', '逗钓增加咬口'], '腥香', 4, 3, 3, 4, 3);

    PresetRecipeDatabase.addRecipe('r_302', '湖泊鲤鱼爆炸钩', '湖泊海竿钓鲤鱼专用，糠饼玉米效果好。', ['鲤鱼'], ['湖泊'], ['夏秋'],
      [new RecipeIngredientItem('糠饼', '500', 'g'), new RecipeIngredientItem('玉米', '200', 'g'), new RecipeIngredientItem('麦粒', '100', 'g')],
      ['糠饼泡软捏碎', '玉米麦粒混合', '装入爆炸钩', '海竿远投守钓'],
      ['远投深水', '守钓要耐心', '夏秋效果好'], '谷香', 4, 3, 4, 4, 5);

    PresetRecipeDatabase.addRecipe('r_303', '湖泊草鱼浮钓饵', '湖泊浮钓草鱼专用，嫩草芦苇芯效果好。', ['草鱼'], ['湖泊'], ['夏季'],
      [new RecipeIngredientItem('嫩草', '适量', ''), new RecipeIngredientItem('芦苇芯', '适量', ''), new RecipeIngredientItem('玉米粒', '100', 'g')],
      ['嫩草切段备用', '芦苇芯取嫩心', '玉米粒打窝', '草段挂钩浮钓'],
      ['草要新鲜', '浮钓中上层', '早晚效果好'], '草香', 3, 4, 2, 3, 2);

    PresetRecipeDatabase.addRecipe('r_304', '湖泊鳜鱼活饵', '湖泊钓鳜鱼专用，活饵是鳜鱼最爱。', ['鳜鱼'], ['湖泊'], ['夏秋'],
      [new RecipeIngredientItem('活泥鳅', '适量', ''), new RecipeIngredientItem('活虾', '适量', ''), new RecipeIngredientItem('小鱼', '适量', '')],
      ['活泥鳅挂钩', '活虾备用', '小鱼打窝', '障碍区守钓'],
      ['障碍区效果好', '活饵要鲜活', '夏秋最佳'], '活饵', 5, 1, 5, 5, 5);

    PresetRecipeDatabase.addRecipe('r_305', '湖泊青鱼螺蛳饵', '湖泊钓青鱼专用，螺蛳蚌肉效果极佳。', ['青鱼'], ['湖泊'], ['夏秋'],
      [new RecipeIngredientItem('田螺', '500', 'g'), new RecipeIngredientItem('螺蛳粉', '100', 'g'), new RecipeIngredientItem('蚌肉', '200', 'g')],
      ['田螺砸碎打窝', '螺蛳粉拌饵', '蚌肉切块挂钩', '底钓守大物'],
      ['螺蛳要新鲜', '钩要大号', '守钓要耐心'], '腥香', 5, 2, 5, 5, 5);

    PresetRecipeDatabase.addRecipe('r_306', '湖泊黑鱼雷蛙', '湖泊路亚黑鱼专用，雷蛙效果极佳。', ['黑鱼'], ['湖泊'], ['夏季'],
      [new RecipeIngredientItem('雷蛙', '1', '只'), new RecipeIngredientItem('软虫', '适量', ''), new RecipeIngredientItem('泥鳅', '适量', '')],
      ['雷蛙绑好线组', '抛投到草边', '模拟青蛙跳动', '黑鱼炸水后扬竿'],
      ['草边效果好', '早晚最佳', '扬竿要有力'], '路亚', 5, 1, 5, 5, 5);

    PresetRecipeDatabase.addRecipe('r_307', '北方狗鱼饵', '北方湖泊路亚狗鱼专用，大型拟饵效果好。', ['狗鱼'], ['湖泊'], ['春秋冬'],
      [new RecipeIngredientItem('大型软虫', '适量', ''), new RecipeIngredientItem('小鱼', '适量', ''), new RecipeIngredientItem('亮片', '1', '只')],
      ['大型软虫绑钩', '抛投到深水', '慢速拖动', '感觉咬口后扬竿'],
      ['深水效果好', '用大号拟饵', '秋冬最佳'], '路亚', 5, 1, 5, 5, 5);

    PresetRecipeDatabase.addRecipe('r_308', '湖钓鲈鱼饵', '湖泊钓鲈鱼专用，活饵效果好。', ['鲈鱼'], ['湖泊'], ['春秋'],
      [new RecipeIngredientItem('活虾', '适量', ''), new RecipeIngredientItem('小鱼', '适量', ''), new RecipeIngredientItem('蚯蚓', '适量', '')],
      ['活虾挂钩', '小鱼打窝', '蚯蚓备用', '障碍区作钓'],
      ['障碍区效果好', '活饵要鲜活', '春秋最佳'], '腥香', 4, 2, 4, 4, 4);

    PresetRecipeDatabase.addRecipe('r_309', '银鱼专用饵', '湖泊钓银鱼专用，细线小钩效果好。', ['银鱼'], ['湖泊'], ['春秋'],
      [new RecipeIngredientItem('红虫', '适量', ''), new RecipeIngredientItem('小虫', '适量', '')],
      ['红虫单条挂钩', '小虫备用', '用极细线组', '轻提慢放'],
      ['用极细线', '小钩', '动作要轻'], '腥香', 3, 1, 4, 3, 2);

    PresetRecipeDatabase.addRecipe('r_310', '红鳍鲌路亚饵', '湖泊路亚红鳍鲌专用，亮片效果好。', ['红鳍鲌'], ['湖泊'], ['夏秋'],
      [new RecipeIngredientItem('亮片', '1', '只'), new RecipeIngredientItem('活虾', '适量', ''), new RecipeIngredientItem('小鱼', '适量', '')],
      ['亮片绑好线组', '抛投到水面', '快速收线', '感觉咬口后扬竿'],
      ['早晚效果好', '收线要快', '夏秋最佳'], '路亚', 4, 1, 4, 4, 3);

    PresetRecipeDatabase.addRecipe('r_311', '湖泊甲鱼饵', '湖泊夜钓甲鱼专用，动物内脏效果好。', ['甲鱼'], ['湖泊'], ['夏季'],
      [new RecipeIngredientItem('鸡肝', '200', 'g'), new RecipeIngredientItem('猪肝', '100', 'g'), new RecipeIngredientItem('蚯蚓', '适量', '')],
      ['鸡肝猪肝切块', '蚯蚓穿钩', '内脏打窝', '夜钓守候'],
      ['夜钓效果好', '内脏要新鲜', '钩要锋利'], '血腥', 5, 1, 5, 5, 5);

    PresetRecipeDatabase.addRecipe('r_312', '湖泊黄鳝饵', '湖泊夜钓黄鳝专用，蚯蚓效果最佳。', ['黄鳝'], ['湖泊'], ['夏季'],
      [new RecipeIngredientItem('蚯蚓', '适量', ''), new RecipeIngredientItem('小鱼', '适量', '')],
      ['蚯蚓穿钩', '找洞穴作钓', '夜钓效果好', '轻提慢放'],
      ['洞穴区效果好', '夜钓最佳', '动作要轻'], '腥香', 4, 1, 5, 4, 3);

    PresetRecipeDatabase.addRecipe('r_313', '秋季河蟹饵', '秋季湖泊钓河蟹专用，动物内脏效果好。', ['河蟹'], ['湖泊'], ['秋季'],
      [new RecipeIngredientItem('鸡肝', '200', 'g'), new RecipeIngredientItem('鱼肉', '100', 'g'), new RecipeIngredientItem('玉米', '100', 'g')],
      ['鸡肝鱼肉切块', '玉米备用', '装入蟹笼', '傍晚下笼早晨收'],
      ['秋季效果最佳', '傍晚下笼', '内脏要新鲜'], '腥香', 4, 1, 5, 5, 4);

    PresetRecipeDatabase.addRecipe('r_314', '湖泊河虾饵', '湖泊钓河虾专用，蚯蚓红虫效果好。', ['河虾'], ['湖泊'], ['夏秋'],
      [new RecipeIngredientItem('蚯蚓', '适量', ''), new RecipeIngredientItem('红虫', '适量', ''), new RecipeIngredientItem('面粉', '50', 'g')],
      ['蚯蚓红虫装笼', '面粉调糊诱虾', '傍晚下笼', '早晨收笼'],
      ['傍晚下笼', '浅水区效果好', '夏秋最佳'], '腥香', 3, 1, 4, 3, 3);

    PresetRecipeDatabase.addRecipe('r_315', '湖泊鳊鱼素饵', '湖泊浮钓鳊鱼专用，香甜味型效果好。', ['鳊鱼'], ['湖泊'], ['春夏'],
      [new RecipeIngredientItem('麸皮', '150', 'g'), new RecipeIngredientItem('玉米粉', '100', 'g'), new RecipeIngredientItem('拉丝粉', '30', 'g')],
      ['麸皮玉米粉混合', '加入拉丝粉', '加水调成软饵', '浮钓中层'],
      ['味型要香甜', '浮钓中层', '春夏效果好'], '香甜', 4, 4, 3, 3, 3);

    PresetRecipeDatabase.initialized = true;
  }

  private static addRecipe(id: string, name: string, desc: string, fish: string[], water: string[], season: string[],
    ings: RecipeIngredientItem[], steps: string[], tips: string[], flavor: string, intensity: number,
    atom: number, visc: number, hook: number, wt: number): void {
    const r = new RecipeDetailData();
    r.id = id;
    r.name = name;
    r.description = desc;
    r.targetFish = fish;
    r.waterTypes = water;
    r.seasons = season;
    r.ingredients = ings;
    r.steps = steps;
    r.tips = tips;
    r.flavorPrimary = flavor;
    r.flavorIntensity = intensity;
    r.atomization = atom;
    r.viscosity = visc;
    r.hookHolding = hook;
    r.weight = wt;
    r.difficulty = ings.length <= 3 ? '简单' : (ings.length <= 5 ? '中等' : '复杂');
    r.prepTime = ings.length <= 3 ? '10分钟' : '15分钟';
    r.usageCount = Math.floor(Math.random() * 1000) + 500;
    r.reasons = [
      new RecommendReasonItem('适合目标鱼种', `针对${fish[0]}的食性特点设计`),
      new RecommendReasonItem('水域适配', `适合${water[0]}环境使用`),
      new RecommendReasonItem('季节匹配', `${season[0]}使用效果最佳`)
    ];
    PresetRecipeDatabase.recipes.set(id, r);
  }

  static getRecipe(id: string): RecipeDetailData | null {
    PresetRecipeDatabase.initialize();
    const recipe = PresetRecipeDatabase.recipes.get(id);
    return recipe !== undefined ? recipe : null;
  }
}


@Entry
@Component
struct RecipeDetailPage {
  @State recipe: RecipeDetailData = new RecipeDetailData();
  @State isFavorite: boolean = false;
  @State currentTab: number = 0;
  @State isLoading: boolean = true;

  private tabTitles: string[] = ['概览', '配料', '步骤'];

  aboutToAppear(): void {
    this.loadRecipeData();
  }

  // 切换收藏状态
  private async toggleFavorite(): Promise<void> {
    if (!this.recipe.id) return;

    // 所有配方（包括用户配方）都可以切换收藏状态
    this.isFavorite = await userDataService.toggleFavorite(this.recipe.id);
    console.info('[RecipeDetailPage] toggleFavorite:', this.recipe.id, 'new state:', this.isFavorite);
  }

  // 删除用户配方
  private async deleteUserRecipe(): Promise<void> {
    if (!this.recipe.id || !this.recipe.isUserRecipe) return;

    // 弹出确认对话框
    AlertDialog.show({
      title: '删除配方',
      message: `确定要删除「${this.recipe.name}」吗？此操作不可恢复。`,
      primaryButton: {
        value: '取消',
        action: () => {}
      },
      secondaryButton: {
        value: '删除',
        fontColor: '#F44336',
        action: async () => {
          const success = await userDataService.deleteRecipe(this.recipe.id);
          if (success) {
            Router.back();
          }
        }
      }
    });
  }

  // 加载配方数据
  private async loadRecipeData(): Promise<void> {
    try {
      // 强制重新加载，确保获取最新的收藏状态
      await userDataService.load(true);
      const params = router.getParams();
      if (params) {
        const p = params as Record<string, Object>;
        const recipeId = p.recipeId as string;

        if (recipeId) {
          // 检查收藏状态
          this.isFavorite = userDataService.isFavorite(recipeId);

          // 判断是用户配方还是预设配方
          if (recipeId.startsWith('user_recipe_')) {
            await this.loadUserRecipe(recipeId);
          } else {
            this.loadPresetRecipe(recipeId);
          }
        }
      }
    } catch (err) {
      console.error('Load recipe failed:', err);
    }
    this.isLoading = false;
  }

  // 加载用户保存的配方
  private async loadUserRecipe(recipeId: string): Promise<void> {
    const userRecipes = userDataService.getCustomRecipes();

    for (let i = 0; i < userRecipes.length; i++) {
      if (userRecipes[i].id === recipeId) {
        const ur = userRecipes[i];
        this.recipe = this.convertUserRecipe(ur);
        // 用户配方的收藏状态也从收藏列表读取（不再强制为true）
        // isFavorite 已经在 loadRecipeData 中设置过了
        return;
      }
    }
  }

  // 转换用户配方为详情格式
  private convertUserRecipe(ur: CustomRecipe): RecipeDetailData {
    const r = new RecipeDetailData();
    r.id = ur.id;
    r.name = ur.name;
    r.isUserRecipe = true;

    // 目标鱼种
    r.targetFish = ur.targetFish.map((fishId: string) => this.getFishNameById(fishId));

    // 水域类型
    r.waterTypes = [this.getWaterTypeName(ur.waterType)];

    // 季节
    r.seasons = [this.getSeasonName(ur.season)];

    // 配料 - 使用保存的完整信息
    r.ingredients = [];
    for (let i = 0; i < ur.ingredients.length; i++) {
      const ing = ur.ingredients[i];
      // 优先使用重量，如果没有则使用比例
      const amount = ing.weight > 0 ? `${ing.weight}` : `${ing.ratio}`;
      const unit = ing.weight > 0 ? 'g' : '%';
      r.ingredients.push(new RecipeIngredientItem(ing.name, amount, unit));
    }

    // 步骤
    r.steps = ur.steps.slice();

    // 技巧
    if (ur.tips.length > 0) {
      r.tips = ur.tips.split('；');
    }

    // 描述
    const fishNames = r.targetFish.join('、');
    const waterName = r.waterTypes[0];
    const seasonName = r.seasons[0];
    r.description = `${seasonName}${waterName}钓${fishNames}的自定义配方。`;

    // 难度和时间
    r.difficulty = ur.ingredients.length <= 3 ? '简单' : (ur.ingredients.length <= 5 ? '中等' : '复杂');
    r.prepTime = ur.ingredients.length <= 3 ? '10分钟' : '15分钟';

    // 状态特性 - 使用保存的数据
    if (ur.stateProfile) {
      r.atomization = ur.stateProfile.atomization;
      r.viscosity = ur.stateProfile.viscosity;
      r.hookHolding = ur.stateProfile.hookHolding;
      r.weight = ur.stateProfile.weight;
    } else {
      r.atomization = 3;
      r.viscosity = 3;
      r.hookHolding = 3;
      r.weight = 3;
    }

    // 味型特性 - 使用保存的数据
    if (ur.flavorProfile) {
      // 只显示主味型，副味型单独处理
      r.flavorPrimary = ur.flavorProfile.primary || '综合';
      r.flavorIntensity = ur.flavorProfile.intensity || 3;
      r.suitableTemp = ur.flavorProfile.suitableTemp || '15-25°C';
    } else {
      r.flavorPrimary = '综合';
      r.flavorIntensity = 3;
      r.suitableTemp = '15-25°C';
    }

    r.rating = 4.5;
    r.usageCount = 0;

    // 推荐理由
    r.reasons = [
      new RecommendReasonItem('我的配方', '根据个人经验定制'),
      new RecommendReasonItem('目标鱼种', `针对${fishNames}设计`),
      new RecommendReasonItem('适用场景', `${seasonName}${waterName}使用`)
    ];

    return r;
  }

  // 加载预设配方
  private loadPresetRecipe(recipeId: string): void {
    const preset = PresetRecipeDatabase.getRecipe(recipeId);
    if (preset !== null) {
      this.recipe = preset;
    } else {
      // 如果找不到预设配方，显示默认数据
      this.recipe = this.getDefaultRecipe(recipeId);
    }
  }

  // 获取默认配方（当找不到配方时）
  private getDefaultRecipe(recipeId: string): RecipeDetailData {
    const r = new RecipeDetailData();
    r.id = recipeId;
    r.name = '配方详情';
    r.description = '暂无配方详情信息';
    r.targetFish = ['鲫鱼'];
    r.waterTypes = ['池塘'];
    r.seasons = ['四季'];
    r.ingredients = [new RecipeIngredientItem('基础饵', '100', 'g')];
    r.steps = ['按配方比例混合', '加水搅拌', '静置后使用'];
    r.tips = ['根据实际情况调整'];
    r.reasons = [new RecommendReasonItem('通用配方', '适合多种场景')];
    return r;
  }

  // 辅助方法：获取鱼种名称
  private getFishNameById(fishId: string): string {
    const fishMap: Map<string, string> = new Map([
      ['crucian', '鲫鱼'], ['carp', '鲤鱼'], ['grass', '草鱼'],
      ['black', '青鱼'], ['black_carp', '青鱼'], ['catfish', '鲶鱼'],
      ['bighead', '鳙鱼'], ['silver', '鲢鱼'], ['tilapia', '罗非鱼'],
      ['grass_carp', '草鱼'], ['silver_carp', '鲢鱼'], ['bighead_carp', '鳙鱼'],
      ['yellow_catfish', '黄颡鱼'], ['mandarin_fish', '鳜鱼'], ['snakehead', '黑鱼'],
      ['bream', '鳊鱼'], ['topmouth_culter', '翘嘴']
    ]);
    const name = fishMap.get(fishId);
    return name !== undefined ? name : fishId;
  }

  // 辅助方法：获取水域名称
  private getWaterTypeName(waterType: string): string {
    if (waterType === 'river') return '河流';
    if (waterType === 'pond') return '池塘';
    if (waterType === 'reservoir') return '水库';
    if (waterType === 'wild_pond') return '野塘';
    if (waterType === 'lake') return '湖泊';
    return waterType;
  }

  // 辅助方法：获取季节名称
  private getSeasonName(season: string): string {
    if (season === 'spring') return '春季';
    if (season === 'summer') return '夏季';
    if (season === 'autumn') return '秋季';
    if (season === 'winter') return '冬季';
    return season;
  }


  build() {
    Column() {
      this.HeaderBar()

      if (this.isLoading) {
        Column() {
          LoadingProgress().width(40).height(40)
          Text('加载中...').fontSize(14).fontColor(ThemeColors.TEXT_SECONDARY).margin({ top: 12 })
        }.width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: 0 }) {
            this.RecipeHeader()
            this.TabNavigation()

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

      // 所有配方都显示收藏按钮
      Row() {
        Text(this.isFavorite ? '♥' : '♡')
          .fontSize(22)
          .fontColor(this.isFavorite ? '#F44336' : ThemeColors.TEXT_PRIMARY)
      }
      .width(40)
      .height(40)
      .justifyContent(FlexAlign.Center)
      .onClick(() => { this.toggleFavorite(); })
    }
    .width('100%')
    .height(56)
    .padding({ left: 8, right: 8 })
    .margin({ top: 44 })
  }

  @Builder
  RecipeHeader() {
    Column({ space: 12 }) {
      Row() {
        Column({ space: 4 }) {
          if (this.recipe.isUserRecipe) {
            Row({ space: 4 }) {
              Text('⭐').fontSize(12)
              Text('我的配方').fontSize(12).fontColor(ThemeColors.PRIMARY)
            }
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor('rgba(232, 168, 73, 0.15)')
            .borderRadius(10)
          }
          Text(this.recipe.name)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.TEXT_PRIMARY)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Row({ space: 4 }) {
          Text('☆').fontSize(18).fontColor(ThemeColors.PRIMARY)
          Text(this.recipe.rating.toFixed(1))
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.PRIMARY)
        }
      }
      .width('100%')

      Text(this.recipe.description)
        .fontSize(14)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .lineHeight(20)

      Row({ space: 16 }) {
        this.InfoTag('⏱️', this.recipe.prepTime)
        this.InfoTag('📊', this.recipe.difficulty)
        this.InfoTag('👥', this.recipe.isUserRecipe ? '我的配方' : `${this.recipe.usageCount}人使用`)
      }
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 16, bottom: 20 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  InfoTag(icon: string, text: string) {
    Row({ space: 4 }) {
      Text(icon).fontSize(12)
      Text(text).fontSize(12).fontColor(ThemeColors.TEXT_SECONDARY)
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
      this.TagsCard()
      this.FlavorCard()
      this.StateCard()
      this.ReasonsCard()
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 16 })
  }

  @Builder
  TagsCard() {
    Column({ space: 12 }) {
      Row({ space: 12 }) {
        Row({ space: 4 }) {
          Text('🐟').fontSize(14)
          Text('目标鱼种').fontSize(14).fontColor(ThemeColors.TEXT_SECONDARY)
        }.width(90)

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
      }.width('100%')

      Row({ space: 12 }) {
        Row({ space: 4 }) {
          Text('💧').fontSize(14)
          Text('适用水域').fontSize(14).fontColor(ThemeColors.TEXT_SECONDARY)
        }.width(90)

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
      }.width('100%')

      Row({ space: 12 }) {
        Row({ space: 4 }) {
          Text('🍂').fontSize(14)
          Text('适用季节').fontSize(14).fontColor(ThemeColors.TEXT_SECONDARY)
        }.width(90)

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
      }.width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
  }

  @Builder
  FlavorCard() {
    Column({ space: 16 }) {
      Text('味型特点').fontSize(16).fontWeight(FontWeight.Medium).fontColor(ThemeColors.TEXT_PRIMARY)

      Row() {
        Column({ space: 4 }) {
          Text('主味型').fontSize(12).fontColor(ThemeColors.TEXT_MUTED)
          Text(this.getFlavorName(this.recipe.flavorPrimary))
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.PRIMARY)
        }.layoutWeight(1)

        Column({ space: 4 }) {
          Text('浓度').fontSize(12).fontColor(ThemeColors.TEXT_MUTED)
          Row({ space: 3 }) {
            ForEach([1, 2, 3, 4, 5], (i: number) => {
              Circle()
                .width(8)
                .height(8)
                .fill(i <= this.recipe.flavorIntensity ? ThemeColors.PRIMARY : '#E5E5E5')
            })
          }
        }.layoutWeight(1)

        Column({ space: 4 }) {
          Text('适用水温').fontSize(12).fontColor(ThemeColors.TEXT_MUTED)
          Text(this.recipe.suitableTemp).fontSize(16).fontColor(ThemeColors.TEXT_PRIMARY)
        }.layoutWeight(1)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  // 获取味型中文名称
  private getFlavorName(flavorId: string): string {
    const flavorNames: Record<string, string> = {
      'fishy': '腥',
      'fragrant': '香',
      'sweet': '甜',
      'sour': '酸',
      'smelly': '臭',
      'plain': '本味',
      '腥': '腥',
      '香': '香',
      '甜': '甜',
      '酸': '酸',
      '臭': '臭',
      '本味': '本味'
    };
    return flavorNames[flavorId] || flavorId || '未知';
  }

  @Builder
  StateCard() {
    Column({ space: 16 }) {
      Text('状态特性').fontSize(16).fontWeight(FontWeight.Medium).fontColor(ThemeColors.TEXT_PRIMARY)

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
      Text(label).fontSize(12).fontColor(ThemeColors.TEXT_MUTED)
      Stack({ alignContent: Alignment.Start }) {
        Row().width('100%').height(6).borderRadius(3).backgroundColor('#F0F0F0')
        Row().width(`${value * 20}%`).height(6).borderRadius(3).backgroundColor(ThemeColors.PRIMARY)
      }.width('100%')
      Text(`${value}/5`).fontSize(11).fontColor(ThemeColors.TEXT_MUTED)
    }
    .layoutWeight(1)
    .padding({ left: 4, right: 4 })
  }

  @Builder
  ReasonsCard() {
    Column({ space: 12 }) {
      Text('为什么推荐').fontSize(16).fontWeight(FontWeight.Medium).fontColor(ThemeColors.TEXT_PRIMARY)

      ForEach(this.recipe.reasons, (reason: RecommendReasonItem, index: number) => {
        Row({ space: 12 }) {
          Row() {
            Text(`${index + 1}`).fontSize(12).fontColor(Color.White)
          }
          .width(24)
          .height(24)
          .borderRadius(12)
          .backgroundColor(ThemeColors.PRIMARY)
          .justifyContent(FlexAlign.Center)

          Column({ space: 2 }) {
            Text(reason.title).fontSize(14).fontColor(ThemeColors.TEXT_PRIMARY)
            Text(reason.description).fontSize(13).fontColor(ThemeColors.PRIMARY)
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
      Row({ space: 8 }) {
        Text('📦').fontSize(18)
        Text('材料清单').fontSize(16).fontWeight(FontWeight.Medium).fontColor(ThemeColors.TEXT_PRIMARY)
      }
      .width('100%')
      .padding({ left: 4 })

      Column({ space: 0 }) {
        ForEach(this.recipe.ingredients, (item: RecipeIngredientItem, index: number) => {
          Row() {
            Text(item.name).fontSize(15).fontColor(ThemeColors.TEXT_PRIMARY)
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
      Column({ space: 16 }) {
        Row({ space: 8 }) {
          Text('📝').fontSize(18)
          Text('制作步骤').fontSize(16).fontWeight(FontWeight.Medium).fontColor(ThemeColors.TEXT_PRIMARY)
        }.width('100%')

        ForEach(this.recipe.steps, (step: string, index: number) => {
          Row({ space: 12 }) {
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

      Column({ space: 12 }) {
        Row({ space: 8 }) {
          Text('💡').fontSize(18)
          Text('使用技巧').fontSize(16).fontWeight(FontWeight.Medium).fontColor(ThemeColors.TEXT_PRIMARY)
        }.width('100%')

        Column({ space: 8 }) {
          ForEach(this.recipe.tips, (tip: string) => {
            Row({ space: 8 }) {
              Text('•').fontSize(14).fontColor(ThemeColors.PRIMARY)
              Text(tip)
                .fontSize(13)
                .fontColor(ThemeColors.TEXT_SECONDARY)
                .layoutWeight(1)
                .lineHeight(18)
            }.width('100%')
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
