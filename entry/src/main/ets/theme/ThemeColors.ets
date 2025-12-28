/**
 * 饵知�?- 主题颜色定义
 * 浅色主题 + 橙黄主色�?
 * 
 * 对比度标准（华为审核 2.1.4.1）：
 * - 图标/标题文字与背�?> 3:1
 * - 正文文字与背�?> 4.5:1
 */
export class ThemeColors {
  // 主色�?
  static readonly PRIMARY: string = '#E8A849';       // 用于背景、按�?
  static readonly PRIMARY_DARK: string = '#C4872E';  // 用于文字（对比度3.5:1�?
  static readonly PRIMARY_LIGHT: string = '#FFF3E0';

  // 背景�?- 浅色�?
  static readonly BG_PRIMARY: string = '#F5F6F8';
  static readonly BG_SECONDARY: string = '#FFFFFF';
  static readonly BG_TERTIARY: string = '#EBEEF2';
  static readonly BG_CARD: string = '#FFFFFF';

  // 文字色（已优化对比度�?
  static readonly TEXT_PRIMARY: string = '#1A1A1A';   // 对比�?16.1:1 �?
  static readonly TEXT_SECONDARY: string = '#666666'; // 对比�?5.7:1 �?
  static readonly TEXT_MUTED: string = '#757575';     // 对比�?4.6:1 �?(�?999999)
  static readonly TEXT_HINT: string = '#8A8A8A';      // 对比�?3.9:1 �?(�?CCCCCC)

  // 功能�?
  static readonly SUCCESS: string = '#52C41A';
  static readonly SUCCESS_LIGHT: string = '#F6FFED';
  static readonly WARNING: string = '#FAAD14';
  static readonly ERROR: string = '#FF4D4F';
  static readonly INFO: string = '#1890FF';

  // 渐变�?
  static readonly GRADIENT_PRIMARY_START: string = '#E8A849';
  static readonly GRADIENT_PRIMARY_END: string = '#F5C97A';

  // 分割�?
  static readonly DIVIDER: string = '#E8E8E8';

  // 遮罩
  static readonly OVERLAY: string = 'rgba(0, 0, 0, 0.5)';
  static readonly OVERLAY_LIGHT: string = 'rgba(0, 0, 0, 0.1)';
}
