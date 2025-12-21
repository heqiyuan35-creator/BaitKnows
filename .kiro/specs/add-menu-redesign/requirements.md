# Requirements Document

## Introduction

重新设计"饵知道"App底部Tab栏中间的加号(+)按钮功能。当前加号按钮直接进入智能配方生成页面，需要改为弹出一个功能菜单，提供四个入口：精确匹配、个人创作、原料新增、鱼类新增。

## Glossary

- **Add_Menu**: 加号菜单组件，点击加号按钮后弹出的功能选择菜单
- **Precise_Match**: 精确匹配功能，根据用户选择的条件精确匹配配方
- **Personal_Creation**: 个人创作功能，用户自定义创建鱼饵配方
- **Ingredient_Add**: 原料新增功能，用户添加自定义饵料原料
- **Fish_Add**: 鱼类新增功能，用户添加自定义鱼种数据
- **Bottom_Sheet**: 底部弹出菜单，从屏幕底部向上滑出的菜单样式

## Requirements

### Requirement 1: 加号按钮交互

**User Story:** As a 用户, I want 点击加号按钮时弹出功能菜单, so that 我可以快速选择需要的功能入口。

#### Acceptance Criteria

1. WHEN 用户点击底部Tab栏的加号按钮 THEN Add_Menu SHALL 从底部弹出显示功能菜单
2. WHEN Add_Menu 显示时 THEN Add_Menu SHALL 显示半透明遮罩层覆盖页面内容
3. WHEN 用户点击遮罩层 THEN Add_Menu SHALL 关闭菜单并恢复原页面
4. WHEN 用户向下滑动菜单 THEN Add_Menu SHALL 关闭菜单

### Requirement 2: 菜单布局设计

**User Story:** As a 用户, I want 看到清晰美观的功能菜单, so that 我可以快速识别并选择需要的功能。

#### Acceptance Criteria

1. THE Add_Menu SHALL 采用底部弹出卡片样式，顶部带圆角
2. THE Add_Menu SHALL 显示四个功能入口，采用2x2网格布局
3. WHEN 显示功能入口时 THEN Add_Menu SHALL 每个入口包含图标、标题和简短描述
4. THE Add_Menu SHALL 使用与App主题一致的配色方案（主色调#E8A849）

### Requirement 3: 精确匹配入口

**User Story:** As a 用户, I want 通过精确匹配功能找到最适合的配方, so that 我可以根据具体条件获得精准推荐。

#### Acceptance Criteria

1. THE Add_Menu SHALL 显示"精确匹配"入口，图标使用🎯或类似精准定位图标
2. WHEN 用户点击精确匹配入口 THEN Add_Menu SHALL 关闭菜单并跳转到SmartGeneratorPage
3. THE 精确匹配入口 SHALL 显示描述文字"根据条件精准推荐"

### Requirement 4: 个人创作入口

**User Story:** As a 用户, I want 自己创作鱼饵配方, so that 我可以保存和分享自己的独特配方。

#### Acceptance Criteria

1. THE Add_Menu SHALL 显示"个人创作"入口，图标使用✏️或类似创作图标
2. WHEN 用户点击个人创作入口 THEN Add_Menu SHALL 关闭菜单并跳转到配方创作页面
3. THE 个人创作入口 SHALL 显示描述文字"创建自定义配方"

### Requirement 5: 原料新增入口

**User Story:** As a 用户, I want 添加新的饵料原料, so that 我可以使用系统中没有的原料来创建配方。

#### Acceptance Criteria

1. THE Add_Menu SHALL 显示"原料新增"入口，图标使用🧪或类似原料图标
2. WHEN 用户点击原料新增入口 THEN Add_Menu SHALL 关闭菜单并跳转到原料添加页面
3. THE 原料新增入口 SHALL 显示描述文字"添加自定义原料"

### Requirement 6: 鱼类新增入口

**User Story:** As a 用户, I want 添加新的鱼种, so that 我可以为系统中没有的鱼种创建配方。

#### Acceptance Criteria

1. THE Add_Menu SHALL 显示"鱼类新增"入口，图标使用🐟或类似鱼类图标
2. WHEN 用户点击鱼类新增入口 THEN Add_Menu SHALL 关闭菜单并跳转到鱼类添加页面
3. THE 鱼类新增入口 SHALL 显示描述文字"添加自定义鱼种"

### Requirement 7: 动画效果

**User Story:** As a 用户, I want 看到流畅的菜单动画, so that 交互体验更加自然舒适。

#### Acceptance Criteria

1. WHEN Add_Menu 打开时 THEN Add_Menu SHALL 从底部向上滑入，动画时长200-300ms
2. WHEN Add_Menu 关闭时 THEN Add_Menu SHALL 向下滑出消失，动画时长200-300ms
3. WHEN Add_Menu 打开时 THEN 遮罩层 SHALL 渐显出现
4. WHEN Add_Menu 关闭时 THEN 遮罩层 SHALL 渐隐消失
