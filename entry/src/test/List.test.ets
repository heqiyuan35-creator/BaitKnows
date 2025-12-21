/**
 * 测试套件入口
 * BaitKnows - 鱼饵大师
 */
import localUnitTest from './LocalUnit.test';
import recipeServiceTest from './RecipeService.test';
import generatorServiceTest from './GeneratorService.test';
import recipeDetailTest from './RecipeDetail.test';
import fishingRecordTest from './FishingRecord.test';
import storageServiceTest from './StorageService.test';

export default function testsuite() {
  // 基础测试
  localUnitTest();
  
  // 属性测试
  recipeServiceTest();      // Property 1, 2, 7, 8
  generatorServiceTest();   // Property 4
  recipeDetailTest();       // Property 5, 6, 9
  fishingRecordTest();      // Property 10
  storageServiceTest();     // Property 11
}
