/**
 * 饵知道 - 路由管理
 */
import { router } from '@kit.ArkUI';
import { AppConstants } from '../common/constants/AppConstants';

// 路由参数类
export class RouteParams {
  recipeId?: string;
  recordId?: string;
  fish?: string;
  water?: string;
  season?: string;
  id?: string;
  isEdit?: boolean;
}

export class Router {
  /**
   * 跳转页面
   */
  static async push(url: string, params?: RouteParams): Promise<void> {
    try {
      const options: router.RouterOptions = { url: url };
      if (params) {
        options.params = params;
      }
      await router.pushUrl(options, router.RouterMode.Standard);
    } catch (error) {
      console.error(`[Router] push failed: ${(error as Error).message}`);
    }
  }

  /**
   * 替换页面
   */
  static async replace(url: string, params?: RouteParams): Promise<void> {
    try {
      const options: router.RouterOptions = { url: url };
      if (params) {
        options.params = params;
      }
      await router.replaceUrl(options, router.RouterMode.Standard);
    } catch (error) {
      console.error(`[Router] replace failed: ${(error as Error).message}`);
    }
  }

  /**
   * 返回上一页
   */
  static back(): void {
    router.back();
  }

  /**
   * 获取路由参数
   */
  static getParams(): RouteParams {
    const params = router.getParams();
    return (params as RouteParams) || {};
  }

  // 预定义路由方法
  static async goToMain(): Promise<void> {
    await Router.replace(AppConstants.ROUTE_MAIN);
  }

  static async goToRecipeDetail(recipeId: string): Promise<void> {
    const params = new RouteParams();
    params.recipeId = recipeId;
    await Router.push(AppConstants.ROUTE_RECIPE_DETAIL, params);
  }

  static async goToGeneratedRecipe(params: RouteParams): Promise<void> {
    await Router.push(AppConstants.ROUTE_GENERATED_RECIPE, params);
  }

  static async goToAddRecord(): Promise<void> {
    await Router.push(AppConstants.ROUTE_ADD_RECORD);
  }

  static async goToFavorite(): Promise<void> {
    await Router.push(AppConstants.ROUTE_FAVORITE);
  }

  static async goToSettings(): Promise<void> {
    await Router.push(AppConstants.ROUTE_SETTINGS);
  }

  static async goToRecordDetail(recordId: string, isEdit: boolean = false): Promise<void> {
    const params = new RouteParams();
    params.recordId = recordId;
    params.isEdit = isEdit;
    await Router.push(AppConstants.ROUTE_RECORD_DETAIL, params);
  }

  static async goToGeneratorHistory(): Promise<void> {
    await Router.push(AppConstants.ROUTE_GENERATOR_HISTORY);
  }

  static async goToMap(): Promise<void> {
    await Router.push(AppConstants.ROUTE_MAP);
  }
}
