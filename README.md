# KnowHealth iOS App

AI驱动的跨境医疗第二意见平台 - iOS客户端

## 环境要求

- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+

## 快速开始

```bash
# 1. 进入项目目录
cd KnowHealth-iOS

# 2. 生成Xcode项目 (如果需要重新生成)
xcodegen generate

# 3. 打开Xcode
open KnowHealth.xcodeproj
```

## 项目结构

```
KnowHealth-iOS/
├── Sources/KnowHealth/
│   ├── App/                    # 应用入口
│   │   ├── KnowHealthApp.swift # 主入口 + AppState
│   │   └── Info.plist          # 应用配置
│   ├── Models/                 # 数据模型
│   │   └── Models.swift        # User, Case, Expert, Order
│   ├── Views/                  # 视图层
│   │   ├── Home/               # 首页
│   │   ├── Cases/              # 病例管理
│   │   ├── Experts/            # 专家列表
│   │   ├── Profile/            # 个人中心 + AI聊天
│   │   └── Components/         # 通用组件
│   ├── Services/               # 业务服务
│   │   └── Services.swift      # Auth, Case, Expert, AI Chat
│   ├── Theme/                  # 设计系统
│   │   └── Theme.swift         # Colors, Typography, Spacing
│   └── Utilities/              # 工具类
├── Resources/
│   └── Assets.xcassets         # 图片资源
├── Package.swift               # SPM依赖
├── project.yml                 # xcodegen配置
└── KnowHealth.xcodeproj/       # Xcode项目(自动生成)
```

## 功能模块

### ✅ 已完成
- [x] 登录/注册
- [x] 首页 (Hero, 快捷操作, 最近病例, 服务展示, 平台数据)
- [x] 病例列表 (筛选, 详情)
- [x] 新建病例 (疾病类型, 紧急程度, 病情描述)
- [x] 专家列表 (国家筛选, 搜索, 详情)
- [x] AI助手聊天 (智能回复, 快捷回复)
- [x] 个人中心
- [x] 完整设计系统 (Theme)

### 🚧 待开发
- [ ] 病历文件上传
- [ ] 支付流程
- [ ] 视频会诊
- [ ] 推送通知
- [ ] 多语言支持
- [ ] 深色模式

## 设计系统

### 颜色
- Primary: `#3B5CEB` (蓝)
- Secondary: `#8C54E8` (紫)
- Accent: `#22C55E` (绿)

### 字体
- 标题: Rounded Design
- 正文: System Default

### 间距
- xs: 4, sm: 8, md: 16, lg: 24, xl: 32

## API对接

当前使用Demo数据。对接后端API：

```swift
// 修改 Services.swift 中的 baseURL
private let baseURL = "http://localhost:8080/api/v1"
```

## 依赖

- **Alamofire**: 网络请求
- **Kingfisher**: 图片加载

## 截图

(运行后添加截图)
