import SwiftUI

// MARK: - Main Tab View
struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var caseService = CaseService()
    @StateObject private var expertService = ExpertService()
    @StateObject private var chatService = AIChatService()
    
    var body: some View {
        TabView(selection: $appState.selectedTab) {
            HomeView()
                .tabItem {
                    Label("首页", systemImage: "house.fill")
                }
                .tag(AppState.Tab.home)
            
            ConsultationLobbyView()
                .tabItem {
                    Label("讨论室", systemImage: "bubble.left.and.bubble.right.fill")
                }
                .tag(AppState.Tab.cases)
            
            ExpertListView()
                .tabItem {
                    Label("专家", systemImage: "person.2.fill")
                }
                .tag(AppState.Tab.experts)
            
            ProfileView()
                .tabItem {
                    Label("我的", systemImage: "person.circle.fill")
                }
                .tag(AppState.Tab.profile)
        }
        .tint(KHTheme.Colors.primary)
        .environmentObject(caseService)
        .environmentObject(expertService)
        .environmentObject(chatService)
    }
}

// MARK: - Login View
struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var phone = ""
    @State private var name = ""
    @State private var isRegistering = false
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                KHTheme.Colors.gradientHero
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Logo
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(.white.opacity(0.2))
                                .frame(width: 100, height: 100)
                            Image(systemName: "heart.text.square.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                        }
                        
                        Text("KnowHealth")
                            .font(KHTheme.Typography.largeTitle())
                            .foregroundColor(.white)
                        
                        Text("AI驱动的跨境医疗第二意见平台")
                            .font(KHTheme.Typography.subheadline())
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    // Login Form
                    VStack(spacing: 16) {
                        if isRegistering {
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundColor(KHTheme.Colors.textTertiary)
                                TextField("您的姓名", text: $name)
                                    .font(KHTheme.Typography.body())
                            }
                            .padding()
                            .background(.white)
                            .cornerRadius(KHTheme.Radius.md)
                        }
                        
                        HStack {
                            Image(systemName: "phone.fill")
                                .foregroundColor(KHTheme.Colors.textTertiary)
                            TextField("手机号码", text: $phone)
                                .font(KHTheme.Typography.body())
                                .keyboardType(.phonePad)
                        }
                        .padding()
                        .background(.white)
                        .cornerRadius(KHTheme.Radius.md)
                        
                        Button {
                            Task {
                                isLoading = true
                                if isRegistering {
                                    try? await authManager.register(name: name.isEmpty ? "用户" : name, phone: phone, email: nil)
                                } else {
                                    try? await authManager.login(phone: phone)
                                }
                                isLoading = false
                            }
                        } label: {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text(isRegistering ? "注册" : "登录")
                            }
                        }
                        .khButtonPrimary()
                        .disabled(phone.isEmpty || isLoading)
                        .opacity(phone.isEmpty ? 0.6 : 1)
                        
                        Button {
                            withAnimation { isRegistering.toggle() }
                        } label: {
                            Text(isRegistering ? "已有账号？登录" : "没有账号？注册")
                                .font(KHTheme.Typography.subheadline())
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                    
                    // Footer
                    Text("继续即表示您同意我们的服务条款和隐私政策")
                        .font(KHTheme.Typography.caption())
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.bottom, 32)
                }
            }
        }
    }
}

// MARK: - Home View
struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var caseService: CaseService
    @EnvironmentObject var chatService: AIChatService
    @State private var showNewCase = false
    @State private var showAIChat = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Hero Section
                    heroSection
                    
                    // Quick Actions
                    quickActionsSection
                    
                    // Recent Cases
                    recentCasesSection
                    
                    // Services
                    servicesSection
                    
                    // Stats
                    statsSection
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 100)
            }
            .background(KHTheme.Colors.background)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 8) {
                        Image(systemName: "heart.text.square.fill")
                            .foregroundStyle(KHTheme.Colors.gradientPrimary)
                        Text("KnowHealth")
                            .font(KHTheme.Typography.headline())
                            .foregroundStyle(KHTheme.Colors.gradientPrimary)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAIChat = true
                    } label: {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .foregroundStyle(KHTheme.Colors.gradientPrimary)
                    }
                }
            }
            .sheet(isPresented: $showNewCase) {
                NewCaseView()
            }
            .sheet(isPresented: $showAIChat) {
                AIChatView()
            }
        }
        .task {
            await caseService.fetchCases()
        }
    }
    
    // MARK: Hero
    private var heroSection: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                Text("让全球最好的\n医疗决策触手可及")
                    .font(KHTheme.Typography.title1())
                    .foregroundColor(.white)
                
                Text("AI赋能让跨境医疗更简单")
                    .font(KHTheme.Typography.subheadline())
                    .foregroundColor(.white.opacity(0.8))
                
                Button {
                    showNewCase = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("开始咨询")
                    }
                    .font(KHTheme.Typography.headline())
                    .foregroundColor(KHTheme.Colors.primary)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(.white)
                    .cornerRadius(KHTheme.Radius.pill)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
        }
        .background(KHTheme.Colors.gradientHero)
        .cornerRadius(KHTheme.Radius.xl)
    }
    
    // MARK: Quick Actions
    private var quickActionsSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
        ], spacing: 16) {
                    QuickAction(icon: "doc.badge.plus", title: "新建病例", color: .blue) {
                        showNewCase = true
                    }
                    QuickAction(icon: "bubble.left.and.text.bubble.right", title: "讨论室", color: .purple) {
                        appState.selectedTab = .cases
                    }
                    QuickAction(icon: "person.crop.circle.badge.checkmark", title: "找专家", color: .green) {
                        appState.selectedTab = .experts
                    }
                    QuickAction(icon: "clock.arrow.circlepath", title: "AI助手", color: .orange) {
                        showAIChat = true
                    }
        }
    }
    
    // MARK: Recent Cases
    private var recentCasesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("最近病例")
                    .khSectionHeader()
                Spacer()
                Button("查看全部") {
                    appState.selectedTab = .cases
                }
                .font(KHTheme.Typography.subheadline())
                .foregroundColor(KHTheme.Colors.primary)
            }
            
            if caseService.cases.isEmpty {
                emptyCaseView
            } else {
                ForEach(caseService.cases.prefix(2)) { caseItem in
                    CaseCard(caseItem: caseItem)
                }
            }
        }
    }
    
    private var emptyCaseView: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(KHTheme.Colors.textTertiary)
            Text("暂无病例")
                .font(KHTheme.Typography.headline())
                .foregroundColor(KHTheme.Colors.textSecondary)
            Text("点击上方按钮创建您的第一个病例")
                .font(KHTheme.Typography.footnote())
                .foregroundColor(KHTheme.Colors.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(KHTheme.Colors.surface)
        .cornerRadius(KHTheme.Radius.lg)
    }
    
    // MARK: Services
    private var servicesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("服务类型")
                .khSectionHeader()
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ServiceCard(icon: "brain.head.profile", title: "AI分析", price: "¥499", color: .blue)
                    ServiceCard(icon: "doc.text", title: "标准意见", price: "¥4,999", color: .purple, isPopular: true)
                    ServiceCard(icon: "person.3", title: "高级多学科", price: "¥9,999", color: .green)
                }
            }
        }
    }
    
    // MARK: Stats
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("平台数据")
                .khSectionHeader()
            
            HStack(spacing: 12) {
                StatCard(value: "500+", label: "全球专家", icon: "person.2.fill", color: .blue)
                StatCard(value: "50+", label: "合作医院", icon: "building.2.fill", color: .purple)
            }
            HStack(spacing: 12) {
                StatCard(value: "10K+", label: "成功案例", icon: "checkmark.circle.fill", color: .green)
                StatCard(value: "24h", label: "平均响应", icon: "clock.fill", color: .orange)
            }
        }
    }
}

// MARK: - Supporting Components
struct QuickAction: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                    .frame(width: 56, height: 56)
                    .background(color.opacity(0.1))
                    .cornerRadius(KHTheme.Radius.md)
                Text(title)
                    .font(KHTheme.Typography.caption())
                    .foregroundColor(KHTheme.Colors.textPrimary)
            }
        }
    }
}

struct ServiceCard: View {
    let icon: String
    let title: String
    let price: String
    let color: Color
    var isPopular: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if isPopular {
                Text("最受欢迎")
                    .font(KHTheme.Typography.caption2())
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(KHTheme.Colors.primary)
                    .cornerRadius(KHTheme.Radius.sm)
            }
            
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)
            
            Text(title)
                .font(KHTheme.Typography.headline())
                .foregroundColor(KHTheme.Colors.textPrimary)
            
            Text(price)
                .font(KHTheme.Typography.title3())
                .foregroundColor(color)
        }
        .frame(width: 150, alignment: .leading)
        .padding(16)
        .background(KHTheme.Colors.surface)
        .cornerRadius(KHTheme.Radius.lg)
        .shadow(color: KHTheme.Shadow.small.color, radius: KHTheme.Shadow.small.radius, x: 0, y: 2)
    }
}

struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(KHTheme.Typography.title2())
                    .foregroundColor(KHTheme.Colors.textPrimary)
                Text(label)
                    .font(KHTheme.Typography.caption())
                    .foregroundColor(KHTheme.Colors.textSecondary)
            }
            
            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(KHTheme.Colors.surface)
        .cornerRadius(KHTheme.Radius.lg)
    }
}

// MARK: - Case Card
struct CaseCard: View {
    let caseItem: MedicalCase
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(caseItem.diseaseType.icon)
                    .font(.system(size: 32))
                    .frame(width: 56, height: 56)
                    .background(KHTheme.Colors.primary.opacity(0.1))
                    .cornerRadius(KHTheme.Radius.md)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(caseItem.diseaseType.displayName)
                        .font(KHTheme.Typography.headline())
                        .foregroundColor(KHTheme.Colors.textPrimary)
                    
                    if let subtype = caseItem.diseaseSubtype {
                        Text(subtype)
                            .font(KHTheme.Typography.subheadline())
                            .foregroundColor(KHTheme.Colors.textSecondary)
                    }
                }
                
                Spacer()
                
                CaseStatusBadge(status: caseItem.status)
            }
            
            Text(caseItem.description)
                .font(KHTheme.Typography.footnote())
                .foregroundColor(KHTheme.Colors.textSecondary)
                .lineLimit(2)
            
            HStack {
                Label(caseItem.urgency.displayName, systemImage: "clock")
                    .font(KHTheme.Typography.caption())
                    .foregroundColor(caseItem.urgency == .urgent ? KHTheme.Colors.error : KHTheme.Colors.textTertiary)
                
                Spacer()
                
                Text(caseItem.createdAt, style: .date)
                    .font(KHTheme.Typography.caption())
                    .foregroundColor(KHTheme.Colors.textTertiary)
            }
        }
        .padding(16)
        .background(KHTheme.Colors.surface)
        .cornerRadius(KHTheme.Radius.lg)
    }
}

struct CaseStatusBadge: View {
    let status: MedicalCase.CaseStatus
    
    var color: Color {
        switch status {
        case .pending: return KHTheme.Colors.warning
        case .aiProcessing: return .blue
        case .expertAssigned: return .purple
        case .opinionSubmitted: return KHTheme.Colors.success
        case .completed: return KHTheme.Colors.success
        case .cancelled: return KHTheme.Colors.error
        }
    }
    
    var body: some View {
        Text(status.displayName)
            .font(KHTheme.Typography.caption())
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.1))
            .cornerRadius(KHTheme.Radius.sm)
    }
}
