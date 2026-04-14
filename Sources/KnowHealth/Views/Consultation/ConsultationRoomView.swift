import SwiftUI

// MARK: - Consultation Room View
/// 医患讨论室 — AI Agent 驱动的多角色讨论界面

struct ConsultationRoomView: View {
    let room: ConsultationRoom
    @StateObject private var agentEngine = AgentEngine()
    @State private var inputText = ""
    @State private var currentRole: ConsultationRole = .patient  // 当前发言角色
    @State private var showAgentPanel = false
    @State private var showSummary = false
    @State private var showRoleSwitcher = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Top bar
            topBar
            
            // Active agents strip
            activeAgentsStrip
            
            // Messages
            messagesList
            
            // Agent suggestions (contextual)
            if let suggestion = contextualSuggestion {
                suggestionBar(suggestion)
            }
            
            // Input area
            inputArea
        }
        .background(KHTheme.Colors.background)
        .sheet(isPresented: $showAgentPanel) {
            AgentPanelView(engine: agentEngine)
        }
        .sheet(isPresented: $showSummary) {
            SummaryView(engine: agentEngine)
        }
        .confirmationDialog("切换发言角色", isPresented: $showRoleSwitcher) {
            Button("👤 患者") { currentRole = .patient }
            Button("👨‍⚕️ 医生") { currentRole = .doctor }
        }
        .onAppear {
            agentEngine.initializeRoom(diseaseType: room.diseaseType)
        }
    }
    
    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
            }
            
            VStack(spacing: 2) {
                Text("医患讨论室")
                    .font(KHTheme.Typography.headline())
                HStack(spacing: 4) {
                    Circle()
                        .fill(room.status == .active ? KHTheme.Colors.success : KHTheme.Colors.warning)
                        .frame(width: 6, height: 6)
                    Text(room.status.displayName)
                        .font(KHTheme.Typography.caption())
                        .foregroundColor(KHTheme.Colors.textSecondary)
                }
            }
            
            Spacer()
            
            // Agent count badge
            Button { showAgentPanel = true } label: {
                HStack(spacing: 4) {
                    Image(systemName: "cpu")
                    Text("\(agentEngine.activeAgents.count)")
                        .font(KHTheme.Typography.caption())
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(KHTheme.Colors.primary.opacity(0.1))
                .foregroundColor(KHTheme.Colors.primary)
                .cornerRadius(KHTheme.Radius.pill)
            }
            
            // Summary button
            Button { showSummary = true } label: {
                Image(systemName: "doc.text")
            }
            .padding(.leading, 8)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(KHTheme.Colors.surface)
    }
    
    // MARK: - Active Agents Strip
    private var activeAgentsStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(agentEngine.activeAgents, id: \.role) { agent in
                    HStack(spacing: 4) {
                        Image(systemName: agent.role.avatar)
                            .font(.system(size: 10))
                        Text(agent.name.components(separatedBy: " · ").last ?? "")
                            .font(KHTheme.Typography.caption2())
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(agent.role.color.opacity(0.15))
                    .foregroundColor(agent.role.color)
                    .cornerRadius(KHTheme.Radius.sm)
                }
                
                if agentEngine.isProcessing {
                    HStack(spacing: 4) {
                        ProgressView()
                            .scaleEffect(0.6)
                        Text("处理中...")
                            .font(KHTheme.Typography.caption2())
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(KHTheme.Colors.surfaceSecondary)
                    .cornerRadius(KHTheme.Radius.sm)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(KHTheme.Colors.surfaceSecondary)
    }
    
    // MARK: - Messages List
    private var messagesList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(agentEngine.messages) { message in
                        ConsultationMessageBubble(message: message)
                            .id(message.id)
                    }
                }
                .padding(16)
            }
            .onChange(of: agentEngine.messages.count) { _ in
                if let last = agentEngine.messages.last {
                    withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }
        }
    }
    
    // MARK: - Contextual Suggestion
    private var contextualSuggestion: String? {
        guard let lastMessage = agentEngine.messages.last,
              lastMessage.isAgentMessage,
              lastMessage.messageType == .suggestion else { return nil }
        return lastMessage.content
    }
    
    private func suggestionBar(_ text: String) -> some View {
        HStack {
            Text(text)
                .font(KHTheme.Typography.footnote())
                .foregroundColor(KHTheme.Colors.primary)
                .lineLimit(2)
            
            Spacer()
            
            Button {
                inputText = text.replacingOccurrences(of: "💡 **提示**：您可以", with: "").replacingOccurrences(of: "💡 **参考信息**：", with: "")
            } label: {
                Image(systemName: "arrow.right.circle.fill")
                    .foregroundColor(KHTheme.Colors.primary)
            }
        }
        .padding(12)
        .background(KHTheme.Colors.primary.opacity(0.08))
        .cornerRadius(KHTheme.Radius.md)
        .padding(.horizontal, 16)
    }
    
    // MARK: - Input Area
    private var inputArea: some View {
        VStack(spacing: 8) {
            // Role indicator
            HStack {
                Button { showRoleSwitcher = true } label: {
                    HStack(spacing: 4) {
                        Image(systemName: currentRole.avatar)
                            .font(.system(size: 14))
                        Text("以\(currentRole.displayName)身份发言")
                            .font(KHTheme.Typography.caption())
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(currentRole.color.opacity(0.15))
                    .foregroundColor(currentRole.color)
                    .cornerRadius(KHTheme.Radius.pill)
                }
                
                Spacer()
                
                Text("\(agentEngine.messages.filter { !$0.isAgentMessage }.count) 条对话")
                    .font(KHTheme.Typography.caption2())
                    .foregroundColor(KHTheme.Colors.textTertiary)
            }
            .padding(.horizontal, 16)
            
            HStack(spacing: 12) {
                // Attachment
                Button {} label: {
                    Image(systemName: "paperclip")
                        .font(.system(size: 20))
                        .foregroundColor(KHTheme.Colors.textTertiary)
                }
                
                // Text input
                TextField("输入消息...", text: $inputText, axis: .vertical)
                    .font(KHTheme.Typography.body())
                    .lineLimit(1...4)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(KHTheme.Colors.surfaceSecondary)
                    .cornerRadius(KHTheme.Radius.pill)
                
                // Send
                Button {
                    if !inputText.isEmpty {
                        agentEngine.processUserMessage(inputText, from: currentRole)
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
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 12)
        .background(KHTheme.Colors.surface)
        .shadow(color: KHTheme.Shadow.small.color, radius: 4, x: 0, y: -2)
    }
}

// MARK: - Message Bubble
struct ConsultationMessageBubble: View {
    let message: ConsultationMessage
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            if message.role == .patient { Spacer() }
            
            // Avatar (for non-patient)
            if message.role != .patient {
                avatarView
            }
            
            // Message content
            VStack(alignment: message.role == .patient ? .trailing : .leading, spacing: 4) {
                // Role label
                HStack(spacing: 4) {
                    if message.role.isAI {
                        Image(systemName: message.role.avatar)
                            .font(.system(size: 10))
                    }
                    Text(message.role.displayName)
                        .font(KHTheme.Typography.caption2())
                        .foregroundColor(message.role.color)
                }
                
                // Message bubble
                Group {
                    if message.isKeyMessage {
                        // Key messages (summary, suggestion, medical term) get special treatment
                        specialMessageContent
                    } else {
                        normalMessageContent
                    }
                }
                
                // Timestamp
                Text(message.timestamp, style: .time)
                    .font(.system(size: 10))
                    .foregroundColor(KHTheme.Colors.textTertiary)
            }
            
            if message.role == .doctor || message.role.isAI {
                Spacer()
            }
        }
    }
    
    private var avatarView: some View {
        ZStack {
            Circle()
                .fill(message.role.color.opacity(0.2))
                .frame(width: 32, height: 32)
            Image(systemName: message.role.avatar)
                .font(.system(size: 14))
                .foregroundColor(message.role.color)
        }
    }
    
    private var normalMessageContent: some View {
        Text(message.content)
            .font(KHTheme.Typography.body())
            .padding(12)
            .background(backgroundForRole)
            .foregroundColor(foregroundForRole)
            .cornerRadius(KHTheme.Radius.lg)
            .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: message.role == .patient ? .trailing : .leading)
    }
    
    private var specialMessageContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with icon
            HStack(spacing: 6) {
                Text(message.messageType.icon)
                Text(headerForType)
                    .font(KHTheme.Typography.caption())
                    .foregroundColor(headerColor)
            }
            
            // Content
            Text(message.content)
                .font(KHTheme.Typography.footnote())
                .foregroundColor(KHTheme.Colors.textPrimary)
        }
        .padding(12)
        .frame(maxWidth: UIScreen.main.bounds.width * 0.8, alignment: .leading)
        .background(specialBackground)
        .cornerRadius(KHTheme.Radius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: KHTheme.Radius.lg)
                .stroke(message.role.color.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var backgroundForRole: Color {
        switch message.role {
        case .patient: return KHTheme.Colors.primary
        case .doctor: return KHTheme.Colors.success.opacity(0.15)
        default: return KHTheme.Colors.surfaceSecondary
        }
    }
    
    private var foregroundForRole: Color {
        switch message.role {
        case .patient: return .white
        default: return KHTheme.Colors.textPrimary
        }
    }
    
    private var specialBackground: Color {
        message.role.color.opacity(0.05)
    }
    
    private var headerForType: String {
        switch message.messageType {
        case .summary: return "阶段性总结"
        case .suggestion: return "AI建议"
        case .medicalTerm: return "术语解释"
        case .clarification: return "请求澄清"
        case .question: return "引导问题"
        case .translation: return "翻译"
        case .system: return "系统消息"
        default: return ""
        }
    }
    
    private var headerColor: Color {
        message.role.color
    }
}

// MARK: - Agent Panel
struct AgentPanelView: View {
    @ObservedObject var engine: AgentEngine
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section("可用AI Agents") {
                    ForEach(AgentDefinition.allAgents, id: \.role) { agent in
                        AgentRow(
                            agent: agent,
                            isActive: engine.activeAgents.contains(where: { $0.role == agent.role }),
                            onToggle: { engine.toggleAgent(agent) }
                        )
                    }
                }
                
                Section("Agent能力") {
                    ForEach(AgentDefinition.allAgents, id: \.role) { agent in
                        DisclosureGroup {
                            ForEach(agent.capabilities, id: \.name) { cap in
                                HStack {
                                    Image(systemName: cap.icon)
                                        .foregroundColor(agent.role.color)
                                    VStack(alignment: .leading) {
                                        Text(cap.name)
                                            .font(KHTheme.Typography.subheadline())
                                        Text(cap.description)
                                            .font(KHTheme.Typography.caption())
                                            .foregroundColor(KHTheme.Colors.textSecondary)
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: agent.role.avatar)
                                    .foregroundColor(agent.role.color)
                                Text(agent.name)
                            }
                        }
                    }
                }
            }
            .navigationTitle("AI Agent 控制面板")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }
}

struct AgentRow: View {
    let agent: AgentDefinition
    let isActive: Bool
    let onToggle: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: agent.role.avatar)
                .font(.system(size: 20))
                .foregroundColor(agent.role.color)
                .frame(width: 36, height: 36)
                .background(agent.role.color.opacity(0.1))
                .cornerRadius(KHTheme.Radius.sm)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(agent.name)
                    .font(KHTheme.Typography.body())
                Text(agent.description)
                    .font(KHTheme.Typography.caption())
                    .foregroundColor(KHTheme.Colors.textSecondary)
            }
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: { isActive },
                set: { _ in onToggle() }
            ))
            .labelsHidden()
        }
    }
}

// MARK: - Summary View
struct SummaryView: View {
    @ObservedObject var engine: AgentEngine
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Final summary
                    Text(engine.generateFinalSummary().content)
                        .font(KHTheme.Typography.body())
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(KHTheme.Colors.surface)
                        .cornerRadius(KHTheme.Radius.lg)
                    
                    // All summaries
                    let summaries = engine.messages.filter { $0.messageType == .summary }
                    if !summaries.isEmpty {
                        Text("讨论过程总结")
                            .font(KHTheme.Typography.headline())
                        
                        ForEach(summaries) { summary in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(summary.timestamp, style: .time)
                                    .font(KHTheme.Typography.caption())
                                    .foregroundColor(KHTheme.Colors.textTertiary)
                                Text(summary.content)
                                    .font(KHTheme.Typography.footnote())
                            }
                            .padding(12)
                            .background(KHTheme.Colors.surfaceSecondary)
                            .cornerRadius(KHTheme.Radius.md)
                        }
                    }
                    
                    // Suggested next steps
                    Text("建议下一步")
                        .font(KHTheme.Typography.headline())
                    
                    ForEach(["确认治疗方案细节", "预约进一步检查", "准备病历翻译件", "联系海外医院"], id: \.self) { step in
                        HStack {
                            Image(systemName: "circle")
                                .foregroundColor(KHTheme.Colors.textTertiary)
                            Text(step)
                                .font(KHTheme.Typography.body())
                        }
                    }
                }
                .padding(16)
            }
            .background(KHTheme.Colors.background)
            .navigationTitle("讨论总结")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        // Share summary
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
    }
}
