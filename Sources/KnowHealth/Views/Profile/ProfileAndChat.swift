import SwiftUI

// MARK: - Profile View
struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var showSettings = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // User header
                    userHeader
                    
                    // Stats
                    statsSection
                    
                    // Menu items
                    menuSection
                    
                    // Logout
                    logoutButton
                }
                .padding(16)
                .padding(.bottom, 100)
            }
            .background(KHTheme.Colors.background)
            .navigationTitle("我的")
        }
    }
    
    private var userHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(KHTheme.Colors.gradientPrimary)
                    .frame(width: 80, height: 80)
                Text(authManager.currentUser?.name.prefix(1) ?? "U")
                    .font(KHTheme.Typography.largeTitle())
                    .foregroundColor(.white)
            }
            
            Text(authManager.currentUser?.name ?? "用户")
                .font(KHTheme.Typography.title2())
            
            Text(authManager.currentUser?.phone ?? "")
                .font(KHTheme.Typography.subheadline())
                .foregroundColor(KHTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(KHTheme.Colors.surface)
        .cornerRadius(KHTheme.Radius.xl)
    }
    
    private var statsSection: some View {
        HStack(spacing: 12) {
            ProfileStat(value: "2", label: "病例", icon: "doc.text.fill", color: .blue)
            ProfileStat(value: "1", label: "已完成", icon: "checkmark.circle.fill", color: .green)
            ProfileStat(value: "¥4,999", label: "已消费", icon: "yensign.circle.fill", color: .orange)
        }
    }
    
    private var menuSection: some View {
        VStack(spacing: 0) {
            ProfileMenuItem(icon: "doc.text", title: "我的病例", subtitle: "查看所有病例")
            Divider().padding(.leading, 52)
            ProfileMenuItem(icon: "heart", title: "收藏专家", subtitle: "已收藏的专家")
            Divider().padding(.leading, 52)
            ProfileMenuItem(icon: "bell", title: "消息通知", subtitle: "通知设置")
            Divider().padding(.leading, 52)
            ProfileMenuItem(icon: "creditcard", title: "支付管理", subtitle: "支付方式和账单")
            Divider().padding(.leading, 52)
            ProfileMenuItem(icon: "shield.checkerboard", title: "隐私安全", subtitle: "数据保护设置")
            Divider().padding(.leading, 52)
            ProfileMenuItem(icon: "questionmark.circle", title: "帮助中心", subtitle: "常见问题")
            Divider().padding(.leading, 52)
            ProfileMenuItem(icon: "info.circle", title: "关于我们", subtitle: "版本 1.0.0")
        }
        .background(KHTheme.Colors.surface)
        .cornerRadius(KHTheme.Radius.lg)
    }
    
    private var logoutButton: some View {
        Button {
            authManager.logout()
        } label: {
            Text("退出登录")
                .font(KHTheme.Typography.headline())
                .foregroundColor(KHTheme.Colors.error)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(KHTheme.Colors.error.opacity(0.1))
                .cornerRadius(KHTheme.Radius.pill)
        }
    }
}

struct ProfileStat: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            Text(value)
                .font(KHTheme.Typography.headline())
            Text(label)
                .font(KHTheme.Typography.caption())
                .foregroundColor(KHTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(KHTheme.Colors.surface)
        .cornerRadius(KHTheme.Radius.lg)
    }
}

struct ProfileMenuItem: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(KHTheme.Colors.primary)
                .frame(width: 36, height: 36)
                .background(KHTheme.Colors.primary.opacity(0.1))
                .cornerRadius(KHTheme.Radius.sm)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(KHTheme.Typography.body())
                    .foregroundColor(KHTheme.Colors.textPrimary)
                Text(subtitle)
                    .font(KHTheme.Typography.caption())
                    .foregroundColor(KHTheme.Colors.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(KHTheme.Colors.textTertiary)
        }
        .padding(16)
    }
}

// MARK: - AI Chat View
struct AIChatView: View {
    @EnvironmentObject var chatService: AIChatService
    @Environment(\.dismiss) var dismiss
    @State private var inputText = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(chatService.messages) { message in
                                ChatBubble(message: message)
                                    .id(message.id)
                            }
                            
                            if chatService.isTyping {
                                HStack {
                                    TypingIndicator()
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                        .padding(.vertical, 16)
                    }
                    .onChange(of: chatService.messages.count) { _ in
                        if let lastMessage = chatService.messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Quick replies
                if chatService.messages.count <= 1 {
                    quickReplies
                }
                
                // Input
                inputBar
            }
            .background(KHTheme.Colors.background)
            .navigationTitle("AI医疗助手")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(KHTheme.Colors.gradientPrimary)
                    }
                }
            }
            .onAppear {
                chatService.startChat()
            }
        }
    }
    
    private var quickReplies: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                QuickReply(text: "💰 服务价格") {
                    chatService.sendMessage("服务价格是多少？")
                }
                QuickReply(text: "📋 咨询流程") {
                    chatService.sendMessage("咨询流程是什么？")
                }
                QuickReply(text: "👨‍⚕️ 专家信息") {
                    chatService.sendMessage("有哪些专家？")
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
    
    private var inputBar: some View {
        HStack(spacing: 12) {
            Button {} label: {
                Image(systemName: "paperclip")
                    .font(.system(size: 20))
                    .foregroundColor(KHTheme.Colors.textTertiary)
            }
            
            TextField("输入消息...", text: $inputText)
                .font(KHTheme.Typography.body())
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(KHTheme.Colors.surfaceSecondary)
                .cornerRadius(KHTheme.Radius.pill)
            
            Button {
                if !inputText.isEmpty {
                    chatService.sendMessage(inputText)
                    inputText = ""
                }
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(KHTheme.Colors.gradientPrimary)
            }
            .disabled(inputText.isEmpty)
            .opacity(inputText.isEmpty ? 0.5 : 1)
        }
        .padding(16)
        .background(KHTheme.Colors.surface)
        .shadow(color: KHTheme.Shadow.small.color, radius: 4, x: 0, y: -2)
    }
}

struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isFromUser { Spacer() }
            
            VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(KHTheme.Typography.body())
                    .padding(12)
                    .background(message.isFromUser ? KHTheme.Colors.primary : KHTheme.Colors.surface)
                    .foregroundColor(message.isFromUser ? .white : KHTheme.Colors.textPrimary)
                    .cornerRadius(KHTheme.Radius.lg)
                
                Text(message.timestamp, style: .time)
                    .font(KHTheme.Typography.caption2())
                    .foregroundColor(KHTheme.Colors.textTertiary)
                    .padding(.horizontal, 12)
            }
            
            if !message.isFromUser { Spacer() }
        }
        .padding(.horizontal, 16)
    }
}

struct TypingIndicator: View {
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(KHTheme.Colors.textTertiary)
                    .frame(width: 8, height: 8)
                    .offset(y: animationOffset)
                    .animation(
                        Animation.easeInOut(duration: 0.5)
                            .repeatForever()
                            .delay(Double(index) * 0.15),
                        value: animationOffset
                    )
            }
        }
        .padding(12)
        .background(KHTheme.Colors.surface)
        .cornerRadius(KHTheme.Radius.lg)
        .onAppear {
            animationOffset = -5
        }
    }
}

struct QuickReply: View {
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(KHTheme.Typography.subheadline())
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(KHTheme.Colors.primary.opacity(0.1))
                .foregroundColor(KHTheme.Colors.primary)
                .cornerRadius(KHTheme.Radius.pill)
        }
    }
}
