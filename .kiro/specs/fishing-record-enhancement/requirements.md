# Requirements Document: 渔获记录功能增强

## Introduction

增强"饵知道"App的渔获记录功能，提供更完善的渔获数据记录、统计分析和历史查看能力。当前已有基础的记录服务和详情页，需要完善记录列表页、添加记录页、统计分析功能，以及与配方系统的关联。

## Glossary

- **Fishing_Record**: 渔获记录，包含日期、地点、鱼种、重量、数量等信息
- **Record_Statistics**: 记录统计，包括总渔获、最佳记录、出钓次数等汇总数据
- **Record_List**: 记录列表页，展示所有渔获记录
- **Add_Record**: 添加记录页，用于新增渔获记录
- **Record_Detail**: 记录详情页，查看和编辑单条记录
- **Recipe_Link**: 配方关联，记录使用的鱼饵配方

## Requirements

### Requirement 1: 渔获记录列表页

**User Story:** As a 钓鱼爱好者, I want 查看我的所有渔获记录, so that 我可以回顾钓鱼历程和成果。

#### Acceptance Criteria

1. THE Record_List SHALL 显示统计卡片区域，包含总渔获重量、总尾数、最大单尾、本月出钓次数
2. THE Record_List SHALL 按日期倒序显示所有渔获记录
3. WHEN 显示记录卡片时 THEN Record_List SHALL 显示日期、地点、鱼种、重量、数量信息
4. WHEN 用户点击记录卡片 THEN Record_List SHALL 跳转到记录详情页
5. WHEN 记录列表为空时 THEN Record_List SHALL 显示空状态提示和添加按钮
6. THE Record_List SHALL 支持下拉刷新数据

### Requirement 2: 添加渔获记录页

**User Story:** As a 钓鱼爱好者, I want 快速记录今天的渔获, so that 我可以保存钓鱼成果。

#### Acceptance Criteria

1. THE Add_Record SHALL 提供日期选择器，默认为当天
2. THE Add_Record SHALL 提供钓点位置输入框
3. THE Add_Record SHALL 提供天气选择（晴朗、多云、阴天、小雨、大风）
4. THE Add_Record SHALL 提供鱼种选择，支持从预设列表选择或自定义输入
5. THE Add_Record SHALL 提供重量输入（kg），支持小数
6. THE Add_Record SHALL 提供数量输入（尾），整数
7. THE Add_Record SHALL 提供最大单尾重量输入（可选）
8. THE Add_Record SHALL 提供配方关联选择（可选），可选择收藏的配方或历史生成的配方
9. THE Add_Record SHALL 提供备注输入框
10. WHEN 用户点击保存 THEN Add_Record SHALL 验证必填字段并保存记录
11. WHEN 保存成功 THEN Add_Record SHALL 返回列表页并显示成功提示

### Requirement 3: 记录详情与编辑

**User Story:** As a 钓鱼爱好者, I want 查看和修改渔获记录详情, so that 我可以补充或更正信息。

#### Acceptance Criteria

1. THE Record_Detail SHALL 显示记录的完整信息
2. THE Record_Detail SHALL 提供编辑功能，可修改所有字段
3. THE Record_Detail SHALL 提供删除功能，需二次确认
4. WHEN 关联了配方时 THEN Record_Detail SHALL 显示配方名称并支持点击查看配方详情
5. WHEN 用户保存修改 THEN Record_Detail SHALL 更新记录并刷新统计数据

### Requirement 4: 统计分析功能

**User Story:** As a 钓鱼爱好者, I want 查看我的钓鱼统计数据, so that 我可以了解自己的钓鱼水平和进步。

#### Acceptance Criteria

1. THE Record_Statistics SHALL 计算并显示总渔获重量
2. THE Record_Statistics SHALL 计算并显示总渔获尾数
3. THE Record_Statistics SHALL 记录并显示最大单尾重量
4. THE Record_Statistics SHALL 统计本月出钓次数
5. THE Record_Statistics SHALL 统计总出钓次数
6. WHEN 添加/修改/删除记录时 THEN Record_Statistics SHALL 自动更新统计数据

### Requirement 5: 筛选与搜索

**User Story:** As a 钓鱼爱好者, I want 筛选和搜索我的渔获记录, so that 我可以快速找到特定的记录。

#### Acceptance Criteria

1. THE Record_List SHALL 支持按鱼种筛选记录
2. THE Record_List SHALL 支持按日期范围筛选记录
3. THE Record_List SHALL 支持按钓点搜索记录
4. WHEN 应用筛选条件时 THEN Record_List SHALL 实时更新显示结果

### Requirement 6: 数据持久化

**User Story:** As a 用户, I want 我的渔获记录被安全保存, so that 数据不会丢失。

#### Acceptance Criteria

1. THE FishingRecordService SHALL 使用 Preferences 存储记录数据
2. THE FishingRecordService SHALL 在应用启动时自动加载历史记录
3. THE FishingRecordService SHALL 在数据变更时自动保存
4. THE FishingRecordService SHALL 与用户统计数据保持同步

### Requirement 7: 用户体验优化

**User Story:** As a 用户, I want 流畅的操作体验, so that 记录渔获变得简单快捷。

#### Acceptance Criteria

1. THE Add_Record SHALL 记住上次选择的钓点和天气作为默认值
2. THE Add_Record SHALL 在输入重量和数量时自动计算平均单尾重量
3. THE Record_List SHALL 使用卡片式布局，视觉效果美观
4. THE Record_List SHALL 支持滑动删除记录（需确认）
