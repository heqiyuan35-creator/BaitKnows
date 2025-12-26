# Requirements Document

## Introduction

精确匹配功能是饵知道App的核心差异化功能，与首页的"快速配方"形成对比。

### 差异化定位

| 维度 | 快速配方 | 精确匹配 |
|------|---------|---------|
| 入口 | 首页直接展示 | 加号菜单进入 |
| 定位 | 快速上手 | 专业深度 |
| 参数 | 4-5个基础 | 10+个专业 |
| 分析 | 无 | ArkWeb+ECharts图表 |
| 评分 | 无 | 0-100精确评分 |
| 换一换 | 随机换 | 询问原因后针对性换 |
| 过程 | 无 | 5步动画展示 |
| 备选 | 无 | 2-3个对比方案 |

### 核心价值
1. **专业深度**：比快速配方多3倍参数选项
2. **数据可视化**：ArkWeb+ECharts展示分析图表
3. **智能反馈**：换一换支持针对性调整
4. **透明分析**：展示配方生成的完整推理过程

## Glossary

- **Precise_Match_Engine**: 精确匹配引擎，负责根据多维度参数计算最优配方
- **Analysis_Dashboard**: 分析仪表盘，使用ArkWeb展示ECharts图表
- **Feedback_Dialog**: 反馈对话框，用户点击换一换时弹出的不满意原因选择
- **Match_Score**: 匹配度评分，0-100分表示配方与条件的契合程度
- **Parameter_Weight**: 参数权重，各条件对最终配方的影响程度

## Requirements

### Requirement 1: 专业参数输入界面

**User Story:** As a 钓鱼爱好者, I want 输入更多专业参数, so that 系统能更精确地推荐配方。

#### Acceptance Criteria

1. THE Precise_Match_Page SHALL display 基础参数区（目标鱼种、水域环境、季节天气）
2. THE Precise_Match_Page SHALL display 进阶参数区（水深、水质、光照、风向风力）
3. THE Precise_Match_Page SHALL display 专业参数区（溶氧量、水温分层、饵料状态偏好、味型偏好）
4. WHEN 用户选择目标鱼种 THEN THE System SHALL 自动推荐该鱼种的习性参数默认值
5. WHEN 用户切换水域环境 THEN THE System SHALL 更新可选鱼种列表和推荐参数

### Requirement 2: 数据分析可视化

**User Story:** As a 用户, I want 看到配方生成的分析过程, so that 我能理解为什么推荐这个配方。

#### Acceptance Criteria

1. THE Analysis_Dashboard SHALL 使用ArkWeb加载ECharts图表组件
2. WHEN 配方生成完成 THEN THE System SHALL display 雷达图展示配方各维度评分（诱鱼性、适口性、状态、留鱼性、性价比）
3. WHEN 配方生成完成 THEN THE System SHALL display 饼图展示原料配比
4. WHEN 配方生成完成 THEN THE System SHALL display 匹配度评分（0-100分）及评分依据
5. THE Analysis_Dashboard SHALL display 各参数对配方的影响权重条形图
6. WHEN 用户点击图表区域 THEN THE System SHALL 展示该维度的详细分析说明

### Requirement 3: 智能配方生成

**User Story:** As a 用户, I want 系统根据我的条件生成最优配方, so that 我能获得专业级的配方推荐。

#### Acceptance Criteria

1. WHEN 用户点击生成配方 THEN THE Precise_Match_Engine SHALL 计算所有参数的加权评分
2. THE Precise_Match_Engine SHALL 从原料库中筛选符合条件的原料组合
3. THE Precise_Match_Engine SHALL 输出匹配度最高的配方方案
4. THE System SHALL display 配方的详细原料列表、配比、制作步骤
5. THE System SHALL display 配方的预期效果说明和使用建议
6. THE System SHALL display 配方的适用场景和注意事项

### Requirement 4: 换一换智能反馈

**User Story:** As a 用户, I want 对不满意的配方提供反馈, so that 系统能针对性地调整推荐。

#### Acceptance Criteria

1. THE Precise_Match_Page SHALL display 右上角换一换按钮
2. WHEN 用户点击换一换 THEN THE Feedback_Dialog SHALL 弹出不满意原因选择
3. THE Feedback_Dialog SHALL 提供选项：味型不喜欢、原料难获取、状态不合适、想要更腥/更香/更淡、其他
4. WHEN 用户选择不满意原因 THEN THE Precise_Match_Engine SHALL 根据反馈调整配方
5. THE System SHALL 记录用户反馈用于优化推荐算法
6. WHEN 用户多次换一换 THEN THE System SHALL 提供完全不同风格的备选方案

### Requirement 5: 配方对比功能

**User Story:** As a 用户, I want 对比多个配方方案, so that 我能选择最适合的一个。

#### Acceptance Criteria

1. THE System SHALL 支持同时展示2-3个备选配方
2. THE Analysis_Dashboard SHALL display 多配方对比雷达图
3. WHEN 用户选择对比模式 THEN THE System SHALL 高亮显示各配方的优劣势
4. THE System SHALL 提供"为什么推荐这个"的详细解释

### Requirement 6: 高级选项扩展

**User Story:** As a 专业钓手, I want 更多专业选项, so that 我能精细调控配方参数。

#### Acceptance Criteria

1. THE Advanced_Options SHALL include 水深选择（浅水<1m、中层1-3m、深水>3m）
2. THE Advanced_Options SHALL include 水质选择（清澈、微浑、浑浊、肥水）
3. THE Advanced_Options SHALL include 光照条件（强光、阴天、晨昏、夜钓）
4. THE Advanced_Options SHALL include 风向风力（无风、微风、中风、大风）
5. THE Advanced_Options SHALL include 饵料状态偏好（雾化快、雾化慢、粘软、干散）
6. THE Advanced_Options SHALL include 味型强度（清淡、适中、浓郁、刺激）
7. THE Advanced_Options SHALL include 目标鱼体型（小型<1斤、中型1-5斤、大型>5斤）
8. WHEN 用户调整任意高级选项 THEN THE System SHALL 实时更新推荐预览

### Requirement 7: 分析过程动画展示

**User Story:** As a 用户, I want 看到分析计算的过程, so that 我能感受到系统的专业性。

#### Acceptance Criteria

1. WHEN 用户点击生成配方 THEN THE System SHALL 展示分析进度动画
2. THE Analysis_Animation SHALL 依次展示：参数解析→鱼种习性匹配→原料筛选→配比优化→结果生成
3. THE Analysis_Animation SHALL 在每个步骤显示关键数据点
4. THE System SHALL 在2-3秒内完成分析并展示结果
