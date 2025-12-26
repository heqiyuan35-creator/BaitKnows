# 精确匹配功能 - 开发任务分解

## 开发优先级说明

- **P0**: 核心功能，必须完成
- **P1**: 差异化特性，重要
- **P2**: 体验增强，可延后

---

## Phase 1: 基础架构 (P0)

### Task 1.1: 创建类型定义文件
- [x] 创建 `PreciseMatchTypes.ets`
- [x] 定义高级参数类型（WaterDepth, WaterQuality, LightCondition等）
- [x] 定义引擎输入输出接口
- [x] 定义维度评分接口

**文件**: `entry/src/main/ets/common/types/PreciseMatchTypes.ets`

### Task 1.2: 创建精确匹配参数页
- [x] 创建 `PreciseMatchPage.ets`
- [x] 实现基础参数区（复用现有鱼种、水域、季节组件）
- [x] 实现高级选项折叠面板
- [x] 添加7个高级参数选择器
- [x] 实现水域切换时鱼种列表联动更新
- [x] 添加页面路由配置

**文件**: `entry/src/main/ets/pages/PreciseMatchPage.ets`

### Task 1.3: 创建精确匹配引擎
- [x] 创建 `PreciseMatchEngine.ets`
- [x] 实现参数权重计算算法
- [x] 实现鱼种习性匹配逻辑
- [x] 实现原料筛选逻辑
- [x] 实现配比优化算法
- [x] 实现五维评分计算
- [x] 实现备选方案生成

**文件**: `entry/src/main/ets/services/engine/PreciseMatchEngine.ets`

---

## Phase 2: 数据可视化 (P1)

### Task 2.1: 准备ECharts资源
- [x] 创建 `rawfile/charts/` 目录
- [x] 下载并放入 `echarts.min.js`
- [x] 创建雷达图模板 `radar.html`
- [x] 创建饼图模板 `pie.html`
- [x] 创建条形图模板 `bar.html`
- [x] 实现JS与ArkTS数据通信

**文件**: 
- `entry/src/main/resources/rawfile/charts/echarts.min.js`
- `entry/src/main/resources/rawfile/charts/radar.html`
- `entry/src/main/resources/rawfile/charts/pie.html`
- `entry/src/main/resources/rawfile/charts/bar.html`

### Task 2.2: 创建分析仪表盘组件
- [x] 创建 `AnalysisDashboard.ets`
- [x] 集成ArkWeb加载ECharts
- [x] 实现雷达图数据绑定（五维评分）
- [x] 实现饼图数据绑定（原料配比）
- [x] 实现条形图数据绑定（参数权重）
- [x] 添加图表切换Tab

**文件**: `entry/src/main/ets/components/AnalysisDashboard.ets`

**注意**: 结果页已集成 AnalysisDashboard 组件，使用 ArkWeb + ECharts 展示专业图表

### Task 2.3: 创建分析过程动画
- [x] 创建 `AnalysisAnimation.ets`
- [x] 实现5步进度展示
- [x] 添加步骤切换动画效果
- [x] 显示每步关键数据
- [x] 控制总时长2-3秒

**文件**: `entry/src/main/ets/components/AnalysisAnimation.ets`

---

## Phase 3: 结果展示页 (P0)

### Task 3.1: 创建精确匹配结果页
- [x] 创建 `PreciseResultPage.ets`
- [x] 实现顶部标题栏（返回 + 换一换按钮）
- [x] 实现匹配度评分卡片（大数字 + 进度环）
- [x] 集成分析仪表盘组件
- [x] 实现配方详情卡片
- [x] 实现原料列表展示
- [x] 实现制作步骤展示
- [x] 实现使用建议展示

**文件**: `entry/src/main/ets/pages/PreciseResultPage.ets`

### Task 3.2: 实现备选方案展示
- [x] 添加备选方案横向滑动区域
- [x] 实现方案切换交互
- [x] 高亮显示各方案优劣势
- [x] 支持点击切换主方案

**文件**: `entry/src/main/ets/pages/PreciseResultPage.ets`

---

## Phase 4: 智能反馈系统 (P1)

### Task 4.1: 创建反馈对话框
- [x] 创建 `FeedbackDialog.ets`
- [x] 实现7个反馈选项
- [x] 支持多选
- [x] 实现"其他"选项文本输入
- [x] 添加确认/取消按钮
- [x] 添加弹出/关闭动画

**文件**: `entry/src/main/ets/components/FeedbackDialog.ets`

### Task 4.2: 实现反馈调整逻辑
- [x] 在引擎中添加 `adjustByFeedback()` 方法
- [x] 实现"味型不喜欢"调整逻辑
- [x] 实现"原料难获取"替换逻辑
- [x] 实现"状态不合适"调整逻辑
- [x] 实现"更腥/更香/更淡"强度调整
- [x] 记录反馈历史

**文件**: `entry/src/main/ets/services/engine/PreciseMatchEngine.ets`

### Task 4.3: 集成换一换功能
- [x] 结果页添加换一换按钮
- [x] 点击弹出反馈对话框
- [x] 根据反馈重新生成配方
- [x] 多次换一换后提供完全不同风格

**文件**: `entry/src/main/ets/pages/PreciseResultPage.ets`

---

## Phase 5: 集成与优化 (P2)

### Task 5.1: 路由配置
- [x] 在 `main_pages.json` 添加新页面
- [x] 更新 `AddMenuSheet` 跳转到新页面
- [x] 实现页面间参数传递

**文件**: 
- `entry/src/main/resources/base/profile/main_pages.json`
- `entry/src/main/ets/components/AddMenuSheet.ets`

### Task 5.2: 数据持久化
- [x] 保存用户高级选项偏好
- [x] 保存反馈历史
- [x] 保存生成配方到历史记录

**文件**: `entry/src/main/ets/services/UserDataService.ets`

### Task 5.3: 性能与体验优化
- [ ] 优化ECharts加载速度
- [ ] 添加图表数据缓存
- [ ] 优化配方计算性能
- [x] 添加加载状态指示
- [x] 统一颜色主题
- [x] 添加过渡动画
- [ ] 适配不同屏幕尺寸

---

## 开发时间估算

| Phase | 任务 | 预计时间 |
|-------|------|---------|
| Phase 1 | 基础架构 | 2-3天 |
| Phase 2 | 数据可视化 | 2-3天 |
| Phase 3 | 结果展示页 | 1-2天 |
| Phase 4 | 智能反馈 | 1-2天 |
| Phase 5 | 集成优化 | 1天 |
| **总计** | | **7-11天** |

---

## 当前进度

- [x] 需求文档完成
- [x] 设计文档完成
- [x] Phase 1 基础架构完成
- [x] Phase 2 数据可视化完成（ECharts模板+AnalysisDashboard组件+分析动画）
- [x] Phase 3 结果展示页完成（已集成ECharts图表）
- [x] Phase 4 智能反馈系统完成
- [x] Phase 5.1 路由配置完成
- [x] Phase 5.2 数据持久化完成
- [x] Phase 5.3 体验优化部分完成（加载状态、颜色主题、过渡动画）

**功能已完成！** 所有核心功能均已实现：
- 10+专业参数输入（基础4个+高级7个）
- 0-100匹配度评分
- 5步分析动画
- ArkWeb+ECharts专业图表（雷达图、饼图、条形图）
- 换一换功能（询问原因后针对性调整）
- 2-3个备选方案对比
- 高级参数（水深、水质、光照、风力、目标体型）全部参与配方计算
