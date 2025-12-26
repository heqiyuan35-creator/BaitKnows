# Implementation Plan: 渔获记录功能增强

## Overview

完善渔获记录功能，包括记录列表页、添加记录页、统计分析和筛选搜索。基于现有的 FishingRecordService 和 RecordDetailPage 进行扩展。

## Tasks

- [x] 1. 创建 FishingRecordPage 记录列表页
  - 在 `entry/src/main/ets/pages/` 下创建 `FishingRecordPage.ets`
  - 实现顶部导航栏，包含标题和筛选按钮
  - 实现统计卡片区域（总渔获、最大单尾、本月出钓、总出钓）
  - 实现记录列表，按日期分组显示
  - 实现空状态展示
  - 实现底部添加记录按钮
  - 注册页面路由
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

- [x] 2. 创建 RecordCard 记录卡片组件
  - 在 `entry/src/main/ets/components/` 下创建 `RecordCard.ets`
  - 显示日期、天气图标、钓点位置
  - 显示鱼种、数量、重量
  - 显示关联配方名称（如有）
  - 实现点击事件回调
  - 使用主题色彩和圆角卡片样式
  - _Requirements: 1.3, 7.3_

- [x] 3. 创建 AddRecordPage 添加记录页
  - 在 `entry/src/main/ets/pages/` 下创建 `AddRecordPage.ets`
  - 实现日期选择器（DatePicker）
  - 实现钓点位置输入框
  - 实现天气选择（横向按钮组）
  - 实现鱼种选择（网格布局，支持自定义）
  - 实现重量和数量输入
  - 实现最大单尾输入
  - 实现配方选择（可选）
  - 实现备注输入
  - 实现表单验证和保存逻辑
  - 注册页面路由
  - _Requirements: 2.1-2.11_

- [x] 4. 增强 FishingRecordService 服务
  - 添加按钓点搜索方法 `searchByLocation(keyword: string)`
  - 添加获取所有钓点列表方法 `getAllLocations()`
  - 添加获取所有鱼种列表方法 `getAllFishNames()`
  - 优化统计计算性能
  - _Requirements: 5.3, 6.1-6.4_

- [x] 5. Checkpoint - 基础功能测试
  - 测试记录列表页正常显示
  - 测试添加记录功能
  - 测试记录详情页跳转
  - 测试统计数据正确计算

- [x] 6. 创建 FilterSheet 筛选面板组件
  - 在 `entry/src/main/ets/components/` 下创建 `FilterSheet.ets`
  - 实现鱼种筛选下拉选择
  - 实现日期范围选择
  - 实现钓点搜索输入
  - 实现应用和重置按钮
  - 使用底部弹出样式
  - _Requirements: 5.1, 5.2, 5.3, 5.4_

- [x] 7. 集成筛选功能到 FishingRecordPage
  - 添加筛选按钮和筛选状态
  - 集成 FilterSheet 组件
  - 实现筛选逻辑和结果更新
  - 显示当前筛选条件标签
  - _Requirements: 5.1-5.4_

- [x] 8. 实现配方关联功能
  - 在 AddRecordPage 添加配方选择弹窗
  - 显示收藏的配方和历史生成的配方
  - 在 RecordDetailPage 显示关联配方并支持跳转
  - _Requirements: 2.8, 3.4_

- [x] 9. 用户体验优化
  - 实现记住上次钓点和天气
  - 实现自动计算平均单尾重量
  - 实现下拉刷新功能
  - 优化加载状态和动画
  - _Requirements: 1.6, 7.1, 7.2_

- [x] 10. Final Checkpoint - 完整功能测试
  - 测试所有页面正常工作
  - 测试筛选和搜索功能
  - 测试配方关联功能
  - 测试数据持久化
  - 测试统计数据同步更新

## Notes

- 使用 ArkTS 语法，遵循 HarmonyOS 开发规范
- 所有新页面需要在 `main_pages.json` 中注册
- 使用现有的 ThemeColors 和 ThemeConstants 保持UI一致性
- 复用现有的 FishData 中的鱼种数据
- 日期格式统一使用时间戳存储，显示时格式化

## File Structure

```
entry/src/main/ets/
├── pages/
│   ├── FishingRecordPage.ets    # 新建 - 记录列表页
│   ├── AddRecordPage.ets        # 新建 - 添加记录页
│   └── RecordDetailPage.ets     # 已存在 - 可能需要增强
├── components/
│   ├── RecordCard.ets           # 新建 - 记录卡片
│   ├── FilterSheet.ets          # 新建 - 筛选面板
│   └── StatCard.ets             # 已存在 - 可复用
└── services/
    └── FishingRecordService.ets # 已存在 - 需要增强
```
