# Implementation Plan: 加号菜单重设计

## Overview

将底部Tab栏的加号按钮从直接跳转改为弹出功能菜单，包含四个入口：精确匹配、个人创作、原料新增、鱼类新增。同时创建三个新页面用于用户自定义内容。

## Tasks

- [x] 1. 创建 AddMenuSheet 组件
  - 在 `entry/src/main/ets/components/` 下创建 `AddMenuSheet.ets`
  - 实现底部弹出卡片样式，顶部圆角
  - 实现2x2网格布局显示四个功能入口
  - 每个入口包含图标、标题、描述
  - 实现遮罩层点击关闭功能
  - 实现滑入/滑出动画效果
  - _Requirements: 1.1, 1.2, 1.3, 2.1, 2.2, 2.3, 2.4, 7.1, 7.2, 7.3, 7.4_

- [x] 2. 修改 WelcomePage 集成菜单
  - 添加 `showAddMenu` 状态变量
  - 修改加号按钮点击事件，显示菜单而非跳转
  - 集成 AddMenuSheet 组件
  - 处理菜单项点击跳转逻辑
  - _Requirements: 1.1, 3.2, 4.2, 5.2, 6.2_

- [x] 3. 创建配方创作页面 RecipeCreatePage
  - 在 `entry/src/main/ets/pages/` 下创建 `RecipeCreatePage.ets`
  - 实现配方名称、目标鱼种、水域、季节选择
  - 实现原料添加和比例设置
  - 实现制作步骤编辑
  - 实现保存到本地存储
  - 注册页面路由
  - _Requirements: 4.1, 4.2, 4.3_

- [x] 4. 创建原料新增页面 IngredientAddPage
  - 在 `entry/src/main/ets/pages/` 下创建 `IngredientAddPage.ets`
  - 实现原料名称、分类、描述输入
  - 实现保存到本地存储
  - 注册页面路由
  - _Requirements: 5.1, 5.2, 5.3_

- [x] 5. 创建鱼类新增页面 FishAddPage
  - 在 `entry/src/main/ets/pages/` 下创建 `FishAddPage.ets`
  - 实现鱼种名称、英文名、水域类型、食性输入
  - 实现保存到本地存储
  - 注册页面路由
  - _Requirements: 6.1, 6.2, 6.3_

- [x] 6. 创建用户数据服务 UserDataService
  - 在 `entry/src/main/ets/services/` 下创建 `UserDataService.ets`
  - 实现自定义原料的增删改查
  - 实现自定义鱼种的增删改查
  - 实现自定义配方的增删改查
  - 使用 preferences 持久化存储
  - _Requirements: 4.2, 5.2, 6.2_

- [x] 7. Checkpoint - 确保所有页面可正常访问
  - 确保所有新页面路由注册正确
  - 测试从菜单跳转到各页面
  - 测试数据保存和读取功能

- [x] 8. 集成用户数据到现有系统
  - 修改 IngredientDatabase 支持加载用户自定义原料
  - 修改 FishData 支持加载用户自定义鱼种
  - 修改 RecipeService 支持加载用户自定义配方
  - 在配方生成时包含用户自定义数据
  - _Requirements: 4.2, 5.2, 6.2_

- [x] 9. Final Checkpoint - 完整功能测试
  - 测试加号菜单显示和关闭
  - 测试四个入口跳转正确
  - 测试用户数据创建和保存
  - 测试用户数据在系统中正确显示

## Notes

- 使用 ArkTS 语法，避免对象字面量作为类型声明
- 所有新页面需要在 `main_pages.json` 中注册
- 用户数据使用 `user_` 前缀区分系统数据
- 动画使用 ArkUI 的 animateTo 实现
