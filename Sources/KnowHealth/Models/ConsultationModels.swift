import Foundation
import SwiftUI
import Combine

// MARK: - Consultation Room Models

/// 讨论室中的角色
enum ConsultationRole: String, Codable, CaseIterable {
    case patient = "patient"
    case doctor = "doctor"
    case agentMediator = "agent_mediator"      // 主协调Agent
    case agentTranslator = "agent_translator"   // 翻译Agent
    case agentSummarizer = "agent_summarizer"   // 总结Agent
    case agentSuggester = "agent_suggester"     // 建议Agent
    
    var displayName: String {
        switch self {
        case .patient: return "患者"
        case .doctor: return "医生"
        case .agentMediator: return "AI协调员"
        case .agentTranslator: return "AI翻译"
        case .agentSummarizer: return "AI总结"
        case .agentSuggester: return "AI顾问"
        }
    }
    
    var avatar: String {
        switch self {
        case .patient: return "person.fill"
        case .doctor: return "stethoscope"
        case .agentMediator: return "bubble.left.and.bubble.right.fill"
        case .agentTranslator: return "globe"
        case .agentSummarizer: return "doc.text.magnifyingglass"
        case .agentSuggester: return "lightbulb.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .patient: return .blue
        case .doctor: return .green
        case .agentMediator: return .purple
        case .agentTranslator: return .orange
        case .agentSummarizer: return .cyan
        case .agentSuggester: return .yellow
        }
    }
    
    var isAI: Bool {
        switch self {
        case .patient, .doctor: return false
        default: return true
        }
    }
}

/// 讨论室消息类型
enum MessageType: String, Codable {
    case text = "text"               // 普通消息
    case translation = "translation" // 翻译结果
    case summary = "summary"         // 阶段性总结
    case suggestion = "suggestion"   // AI建议
    case question = "question"       // AI引导提问
    case clarification = "clarification" // AI请求澄清
    case medicalTerm = "medical_term"    // 医学术语解释
    case system = "system"           // 系统消息
    
    var icon: String {
        switch self {
        case .text: return ""
        case .translation: return "🌐"
        case .summary: return "📋"
        case .suggestion: return "💡"
        case .question: return "❓"
        case .clarification: return "🔍"
        case .medicalTerm: return "📖"
        case .system: return "ℹ️"
        }
    }
}

/// 讨论室消息
struct ConsultationMessage: Identifiable {
    let id = UUID()
    let content: String
    let role: ConsultationRole
    let messageType: MessageType
    let timestamp: Date
    let replyTo: UUID?       // 回复某条消息
    let metadata: [String: String]?  // 额外信息 (翻译原文、术语链接等)
    
    /// 是否是Agent的消息
    var isAgentMessage: Bool { role.isAI }
    
    /// 是否是关键消息 (总结、建议)
    var isKeyMessage: Bool {
        [.summary, .suggestion, .medicalTerm].contains(messageType)
    }
}

/// 讨论室状态
enum RoomStatus: String {
    case waiting = "waiting"     // 等待加入
    case active = "active"       // 进行中
    case paused = "paused"       // 暂停
    case completed = "completed" // 已结束
    
    var displayName: String {
        switch self {
        case .waiting: return "等待中"
        case .active: return "讨论中"
        case .paused: return "已暂停"
        case .completed: return "已结束"
        }
    }
}

/// 讨论室
struct ConsultationRoom: Identifiable, Hashable {
    let id: String
    let caseId: String
    let patientName: String
    let doctorName: String
    let doctorHospital: String
    let diseaseType: String
    let status: RoomStatus
    let createdAt: Date
    let scheduledDuration: Int  // 计划时长(分钟)
    
    /// 活跃的Agent
    let activeAgents: [ConsultationRole]
    
    /// 讨论主题
    let topics: [DiscussionTopic]
    
    static func == (lhs: ConsultationRoom, rhs: ConsultationRoom) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

/// 讨论主题
struct DiscussionTopic: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    var isCompleted: Bool = false
    var messages: [ConsultationMessage] = []
}

// MARK: - Agent Definitions

/// Agent的能力定义
struct AgentCapability {
    let name: String
    let description: String
    let icon: String
    let isEnabled: Bool
}

/// 各Agent的角色描述
struct AgentDefinition {
    let role: ConsultationRole
    let name: String
    let description: String
    let capabilities: [AgentCapability]
    let systemPrompt: String
}

// MARK: - Predefined Agents

extension AgentDefinition {
    static let mediator = AgentDefinition(
        role: .agentMediator,
        name: "AI协调员 · 小和",
        description: "主持讨论流程，确保医患双方有效沟通",
        capabilities: [
            AgentCapability(name: "流程引导", description: "按照预设话题引导讨论", icon: "arrow.triangle.branch", isEnabled: true),
            AgentCapability(name: "问题生成", description: "根据讨论内容生成关键问题", icon: "questionmark.bubble", isEnabled: true),
            AgentCapability(name: "澄清请求", description: "检测歧义并请求双方澄清", icon: "magnifyingglass", isEnabled: true),
            AgentCapability(name: "时间管理", description: "控制讨论节奏，提醒时间", icon: "clock", isEnabled: true),
        ],
        systemPrompt: """
        你是KnowHealth的AI协调员"小和"。你的职责是主持医患讨论，确保双方有效沟通。
        
        核心职责：
        1. 按照讨论主题引导对话流程
        2. 当患者表达不清时，用通俗语言重述并确认
        3. 当医生使用专业术语时，主动解释
        4. 生成关键问题帮助深入讨论
        5. 在每个主题结束时生成简短总结
        
        语气要求：
        - 温和、中立、专业
        - 不偏袒任何一方
        - 用简洁的语言
        - 适时使用emoji增加亲和力
        """
    )
    
    static let translator = AgentDefinition(
        role: .agentTranslator,
        name: "AI翻译 · 小译",
        description: "实时翻译医患对话，处理跨语言沟通",
        capabilities: [
            AgentCapability(name: "实时翻译", description: "中英日韩多语言实时互译", icon: "globe", isEnabled: true),
            AgentCapability(name: "医学术语", description: "专业医学名词准确翻译", icon: "text.book.closed", isEnabled: true),
            AgentCapability(name: "文化适配", description: "考虑文化差异的表达调整", icon: "person.2", isEnabled: true),
        ],
        systemPrompt: """
        你是KnowHealth的AI翻译"小译"。你专注于医患对话的跨语言翻译。
        
        翻译原则：
        1. 医学术语保持准确，必要时附上原文
        2. 口语化表达，避免过于书面
        3. 保留说话者的语气和情感
        4. 标注可能的文化差异
        """
    )
    
    static let summarizer = AgentDefinition(
        role: .agentSummarizer,
        name: "AI总结 · 小结",
        description: "实时总结讨论要点，生成结构化记录",
        capabilities: [
            AgentCapability(name: "实时摘要", description: "每轮对话后生成要点", icon: "doc.text", isEnabled: true),
            AgentCapability(name: "阶段总结", description: "每个话题结束时生成总结", icon: "list.clipboard", isEnabled: true),
            AgentCapability(name: "行动项提取", description: "自动提取待办事项", icon: "checkmark.circle", isEnabled: true),
        ],
        systemPrompt: """
        你是KnowHealth的AI总结员"小结"。你负责实时总结医患讨论内容。
        
        总结格式：
        - 用要点形式，简洁明了
        - 区分"医生建议"和"患者反馈"
        - 标注需要跟进的事项
        - 每个话题结束时生成结构化总结
        """
    )
    
    static let suggester = AgentDefinition(
        role: .agentSuggester,
        name: "AI顾问 · 小智",
        description: "提供讨论建议，帮助双方深入沟通",
        capabilities: [
            AgentCapability(name: "问题建议", description: "建议患者可以问的问题", icon: "bubble.left", isEnabled: true),
            AgentCapability(name: "信息补充", description: "补充相关医学知识", icon: "book", isEnabled: true),
            AgentCapability(name: "决策支持", description: "提供治疗选择对比", icon: "scalemass", isEnabled: true),
        ],
        systemPrompt: """
        你是KnowHealth的AI顾问"小智"。你为医患讨论提供建议和支持。
        
        建议原则：
        1. 建议患者可以问的关键问题
        2. 补充患者可能不知道的相关信息
        3. 帮助患者理解不同治疗选择的利弊
        4. 不代替医生做诊断或治疗决策
        5. 建议以"💡 提示："或"❓ 您可以问："的形式呈现
        """
    )
    
    static let allAgents: [AgentDefinition] = [.mediator, .translator, .summarizer, .suggester]
}
