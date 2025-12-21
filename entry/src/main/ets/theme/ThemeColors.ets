/**
 * 饵知道 - 主题颜色定义
 * 浅色主题 + 橙黄主色调
 */
export class ThemeColors {
  // 主色调
  static readonly PRIMARY: string = '#E8A849';
  static readonly PRIMARY_DARK: string = '#C4872E';
  static readonly PRIMARY_LIGHT: string = '#FFF3E0';

  // 背景色 - 浅色系
  static readonly BG_PRIMARY: string = '#F5F6F8';
  static readonly BG_SECONDARY: string = '#FFFFFF';
  static readonly BG_TERTIARY: string = '#EBEEF2';
  static readonly BG_CARD: string = '#FFFFFF';

  // 文字色
  static readonly TEXT_PRIMARY: string = '#1A1A1A';
  static readonly TEXT_SECONDARY: string = '#666666';
  static readonly TEXT_MUTED: string = '#999999';
  static readonly TEXT_HINT: string = '#CCCCCC';

  // 功能色
  static readonly SUCCESS: string = '#52C41A';
  static readonly WARNING: string = '#FAAD14';
  static readonly ERROR: string = '#FF4D4F';
  static readonly INFO: string = '#1890FF';

  // 渐变色
  static readonly GRADIENT_PRIMARY_START: string = '#E8A849';
  static readonly GRADIENT_PRIMARY_END: string = '#F5C97A';

  // 分割线
  static readonly DIVIDER: string = '#E8E8E8';

  // 遮罩
  static readonly OVERLAY: string = 'rgba(0, 0, 0, 0.5)';
  static readonly OVERLAY_LIGHT: string = 'rgba(0, 0, 0, 0.1)';
}
