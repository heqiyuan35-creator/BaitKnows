# Requirements Document

## Introduction

智能配方推荐引擎是饵知道App的核心功能，旨在根据多维度环境因素（温度、水域、季节、鱼种、天气、时段等）智能分析并推荐最适合的鱼饵配方。该引擎需要具备丰富的配方变化能力，确保"换一换"功能能够提供真正不同且有价值的配方选择。

## Glossary

- **Recipe_Engine**: 配方推荐引擎，负责根据输入条件生成配方
- **Ingredient_Pool**: 原料池，包含所有可用原料及其属性
- **Flavor_Profile**: 味型配置，描述配方的味道特征（腥、香、甜、酸、臭）
- **State_Profile**: 状态配置，描述配方的物理特性（雾化、粘度、持钩、比重）
- **Context_Analyzer**: 环境分析器，分析钓鱼环境并生成推荐参数
- **Recipe_Variant**: 配方变体，同一条件下的不同配方选择

## Requirements

### Requirement 1: 多维度环境分析

**User Story:** As a 钓鱼爱好者, I want 系统能够综合分析多种环境因素, so that 我能获得最适合当前情况的配方推荐。

#### Acceptance Criteria

1. WHEN 用户选择目标鱼种 THEN THE Context_Analyzer SHALL 加载该鱼种的基础味型偏好和推荐原料
2. WHEN 用户输入当前温度 THEN THE Context_Analyzer SHALL 根据温度区间调整味型权重（低温增腥、高温减腥增酸）
3. WHEN 用户选择水域类型 THEN THE Context_Analyzer SHALL 调整状态参数（野河增粘度、黑坑增雾化）
4. WHEN 用户选择季节 THEN THE Context_Analyzer SHALL 应用季节性味型修正
5. WHEN 多个环境因素组合时 THEN THE Context_Analyzer SHALL 按优先级叠加各因素的影响

### Requirement 2: 丰富的原料库

**User Story:** As a 钓鱼爱好者, I want 系统拥有丰富的原料选择, so that 配方能够有足够的变化空间。

#### Acceptance Criteria

1. THE Ingredient_Pool SHALL 包含至少50种不同原料
2. WHEN 原料被添加到库中 THEN THE Ingredient_Pool SHALL 记录其味型属性（腥度、香度、甜度、酸度、臭度）
3. WHEN 原料被添加到库中 THEN THE Ingredient_Pool SHALL 记录其物理属性（雾化速度、粘度、比重）
4. THE Ingredient_Pool SHALL 按类别分组（主饵、辅饵、状态饵、添加剂、天然饵、活饵）
5. WHEN 查询原料时 THEN THE Ingredient_Pool SHALL 支持按味型、物理属性、适用鱼种筛选

### Requirement 3: 配方变体生成

**User Story:** As a 钓鱼爱好者, I want 换一换功能能给出真正不同的配方, so that 我有更多选择来应对不同情况。

#### Acceptance Criteria

1. WHEN 用户点击换一换 THEN THE Recipe_Engine SHALL 生成与当前配方明显不同的新配方
2. THE Recipe_Engine SHALL 为每个条件组合维护至少3种不同的配方变体
3. WHEN 生成配方变体时 THEN THE Recipe_Engine SHALL 确保主饵、辅饵、添加剂至少有一项不同
4. WHEN 生成配方变体时 THEN THE Recipe_Engine SHALL 保持配方的合理性和有效性
5. THE Recipe_Engine SHALL 记录已展示的配方，避免连续重复

### Requirement 4: 智能配比计算

**User Story:** As a 钓鱼爱好者, I want 配方的配比是科学合理的, so that 我能制作出效果好的鱼饵。

#### Acceptance Criteria

1. THE Recipe_Engine SHALL 根据原料类别自动计算合理配比（主饵40-50%、辅饵20-30%、状态15-20%、添加剂5-15%）
2. WHEN 计算配比时 THEN THE Recipe_Engine SHALL 考虑原料间的相容性
3. WHEN 计算配比时 THEN THE Recipe_Engine SHALL 确保总比例为100%
4. THE Recipe_Engine SHALL 支持按总重量（如500g）输出具体克数
5. WHEN 原料有特殊用量限制时 THEN THE Recipe_Engine SHALL 遵守该限制（如小药不超过3%）

### Requirement 5: 配方推荐理由

**User Story:** As a 钓鱼爱好者, I want 了解为什么推荐这个配方, so that 我能学习钓鱼知识并做出调整。

#### Acceptance Criteria

1. WHEN 生成配方时 THEN THE Recipe_Engine SHALL 生成至少3条推荐理由
2. WHEN 生成推荐理由时 THEN THE Recipe_Engine SHALL 解释温度对配方的影响
3. WHEN 生成推荐理由时 THEN THE Recipe_Engine SHALL 解释水域类型对配方的影响
4. WHEN 生成推荐理由时 THEN THE Recipe_Engine SHALL 解释目标鱼种的偏好
5. THE Recipe_Engine SHALL 使用通俗易懂的语言描述推荐理由

### Requirement 6: 特殊场景处理

**User Story:** As a 钓鱼爱好者, I want 系统能处理特殊钓鱼场景, so that 在极端条件下也能获得有效建议。

#### Acceptance Criteria

1. WHEN 温度低于5°C THEN THE Recipe_Engine SHALL 推荐高腥高蛋白配方
2. WHEN 温度高于30°C THEN THE Recipe_Engine SHALL 推荐清淡果酸配方
3. WHEN 目标鱼为肉食性鱼类 THEN THE Recipe_Engine SHALL 优先推荐活饵或高腥配方
4. WHEN 水域为黑坑 THEN THE Recipe_Engine SHALL 考虑添加小药增强诱鱼效果
5. IF 用户指定的条件组合无合适配方 THEN THE Recipe_Engine SHALL 返回最接近的替代方案并说明原因

### Requirement 7: 用户偏好学习

**User Story:** As a 钓鱼爱好者, I want 系统能记住我的偏好, so that 推荐越来越符合我的习惯。

#### Acceptance Criteria

1. WHEN 用户保存配方 THEN THE Recipe_Engine SHALL 记录用户的配方偏好
2. WHEN 用户多次选择某类原料 THEN THE Recipe_Engine SHALL 提高该原料的推荐权重
3. THE Recipe_Engine SHALL 支持用户设置常用原料列表
4. WHEN 生成配方时 THEN THE Recipe_Engine SHALL 优先使用用户常用原料
5. THE Recipe_Engine SHALL 支持重置用户偏好数据
