/**
 * 饵知�?- 应用常量
 */
export class AppConstants {
  // 应用信息
  static readonly APP_NAME: string = '饵知�?;
  static readonly APP_VERSION: string = 'V1.0.0';
  static readonly APP_SLOGAN: string = '智能配方 · 记录渔获';

  // 路由
  static readonly ROUTE_WELCOME: string = 'pages/WelcomePage';
  static readonly ROUTE_MAIN: string = 'pages/MainTabPage';
  static readonly ROUTE_HOME: string = 'pages/HomePage';
  static readonly ROUTE_RECIPE_BROWSER: string = 'pages/RecipeBrowserPage';
  static readonly ROUTE_RECIPE_DETAIL: string = 'pages/RecipeDetailPage';
  static readonly ROUTE_FISHING_RECORD: string = 'pages/FishingRecordPage';
  static readonly ROUTE_ADD_RECORD: string = 'pages/AddRecordPage';
  static readonly ROUTE_MINE: string = 'pages/MinePage';
  static readonly ROUTE_GENERATED_RECIPE: string = 'pages/GeneratedRecipePage';
  static readonly ROUTE_FAVORITE: string = 'pages/FavoritePage';
  static readonly ROUTE_SETTINGS: string = 'pages/SettingsPage';
  static readonly ROUTE_RECORD_DETAIL: string = 'pages/RecordDetailPage';
  static readonly ROUTE_GENERATOR_HISTORY: string = 'pages/GeneratorHistoryPage';
  static readonly ROUTE_MAP: string = 'pages/MapPage';
  static readonly ROUTE_VICTORY_SHARE: string = 'pages/VictorySharePage';

  // 存储�?
  static readonly STORAGE_USER_PROFILE: string = 'user_profile';
  static readonly STORAGE_FAVORITES: string = 'favorite_recipes';
  static readonly STORAGE_RECORDS: string = 'fishing_records';
  static readonly STORAGE_GENERATOR_HISTORY: string = 'generator_history';
  static readonly STORAGE_WELCOME_BG_INDEX: string = 'welcome_bg_index';
  static readonly STORAGE_FIRST_LAUNCH: string = 'first_launch';

  // 水域类型
  static readonly WATER_POND: string = 'pond';
  static readonly WATER_RIVER: string = 'river';
  static readonly WATER_RESERVOIR: string = 'reservoir';
  static readonly WATER_LAKE: string = 'lake';

  // 季节
  static readonly SEASON_SPRING: string = 'spring';
  static readonly SEASON_SUMMER: string = 'summer';
  static readonly SEASON_AUTUMN: string = 'autumn';
  static readonly SEASON_WINTER: string = 'winter';
}
