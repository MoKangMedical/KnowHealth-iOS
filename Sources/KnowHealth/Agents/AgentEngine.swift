import Foundation
import SwiftUI

// MARK: - Agent Engine
/// 多Agent协作引擎 — 模拟多个AI Agent在讨论室中的协作

class AgentEngine: ObservableObject {
    @Published var messages: [ConsultationMessage] = []
    @Published var activeAgents: [AgentDefinition] = []
    @Published var currentTopicIndex: Int = 0
    @Published var isProcessing = false
    
    private var discussionTopics: [DiscussionTopic] = []
    private var conversationContext: [String] = []
    
    // MARK: - 初始化讨论室
    
    func initializeRoom(diseaseType: String) {
        // 根据疾病类型生成讨论主题
        discussionTopics = generateTopics(for: diseaseType)
        activeAgents = [.mediator, .summarizer, .suggester] // 默认激活3个Agent
        
        // AI协调员开场
        let welcomeMessage = ConsultationMessage(
            content: """
            👋 大家好！我是AI协调员小和。
            
            今天的讨论主题是：**\(diseaseType)**
            
            我将协助大家进行高效的医患沟通。讨论将围绕以下主题展开：
            
            \(discussionTopics.enumerated().map { "  \($0.offset + 1). \($0.element.title)" }.joined(separator: "\n"))
            
            医生和患者可以自由发言，我会适时：
            - 🔄 帮助解释专业术语
            - ❓ 引导关键问题
            - 📋 生成阶段总结
            
            让我们开始吧！患者方请先介绍一下您的情况。
            """,
            role: .agentMediator,
            messageType: .system,
            timestamp: Date(),
            replyTo: nil,
            metadata: nil
        )
        messages.append(welcomeMessage)
    }
    
    // MARK: - 处理用户消息
    
    func processUserMessage(_ content: String, from role: ConsultationRole) {
        // 1. 添加用户消息
        let userMessage = ConsultationMessage(
            content: content,
            role: role,
            messageType: .text,
            timestamp: Date(),
            replyTo: nil,
            metadata: nil
        )
        messages.append(userMessage)
        conversationContext.append("[\(role.displayName)] \(content)")
        
        isProcessing = true
        
        // 2. 各Agent并行处理
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.processWithAgents(userMessage: userMessage)
            self.isProcessing = false
        }
    }
    
    // MARK: - Agent 并行处理
    
    private func processWithAgents(userMessage: ConsultationMessage) {
        let content = userMessage.content.lowercased()
        let isFromPatient = userMessage.role == .patient
        
        // Agent 1: 协调员 — 检测是否需要引导
        processMediatorAgent(content: content, isFromPatient: isFromPatient)
        
        // Agent 2: 总结员 — 检测是否需要总结
        processSummarizerAgent(content: content)
        
        // Agent 3: 建议员 — 检测是否需要建议
        processSuggesterAgent(content: content, isFromPatient: isFromPatient)
    }
    
    // MARK: - 协调员处理
    
    private func processMediatorAgent(content: String, isFromPatient: Bool) {
        var response: String? = nil
        var messageType: MessageType = .text
        
        // 检测医学术语并解释
        let medicalTerms = detectMedicalTerms(in: content)
        if !medicalTerms.isEmpty {
            for term in medicalTerms {
                let explanation = explainMedicalTerm(term)
                let termMessage = ConsultationMessage(
                    content: "📖 **\(term)**：\(explanation)",
                    role: .agentMediator,
                    messageType: .medicalTerm,
                    timestamp: Date().addingTimeInterval(0.5),
                    replyTo: messages.last?.id,
                    metadata: ["term": term]
                )
                messages.append(termMessage)
            }
        }
        
        // 检测需要澄清的情况
        if isFromPatient && (content.contains("嗯") || content.contains("就是") || content.count < 10) {
            response = "🔍 患者方，您能再详细描述一下吗？比如症状是什么时候开始的？"
            messageType = .clarification
        }
        
        // 检测讨论卡壳 — 引导问题
        if conversationContext.count >= 4 && conversationContext.suffix(2).allSatisfy({ $0.contains("[医生]") }) {
            response = "❓ 小和建议：患者方对医生刚才说的有什么疑问吗？或者您想了解哪些方面的信息？"
            messageType = .question
        }
        
        if let response = response {
            let message = ConsultationMessage(
                content: response,
                role: .agentMediator,
                messageType: messageType,
                timestamp: Date().addingTimeInterval(1.0),
                replyTo: messages.last?.id,
                metadata: nil
            )
            messages.append(message)
        }
    }
    
    // MARK: - 总结员处理
    
    private func processSummarizerAgent(content: String) {
        // 每4条消息生成一次小总结
        let userMessages = messages.filter { !$0.isAgentMessage }
        if userMessages.count > 0 && userMessages.count % 4 == 0 {
            let recentMessages = userMessages.suffix(4)
            
            var doctorPoints: [String] = []
            var patientPoints: [String] = []
            
            for msg in recentMessages {
                if msg.role == .doctor {
                    doctorPoints.append(msg.content)
                } else if msg.role == .patient {
                    patientPoints.append(msg.content)
                }
            }
            
            if !doctorPoints.isEmpty || !patientPoints.isEmpty {
                var summary = "📋 **阶段性总结**\n\n"
                
                if !doctorPoints.isEmpty {
                    summary += "👨‍⚕️ 医生要点：\n"
                    for (i, point) in doctorPoints.enumerated() {
                        summary += "  \(i+1). \(point.prefix(50))...\n"
                    }
                }
                
                if !patientPoints.isEmpty {
                    summary += "\n👤 患者反馈：\n"
                    for (i, point) in patientPoints.enumerated() {
                        summary += "  \(i+1). \(point.prefix(50))...\n"
                    }
                }
                
                let summaryMessage = ConsultationMessage(
                    content: summary,
                    role: .agentSummarizer,
                    messageType: .summary,
                    timestamp: Date().addingTimeInterval(1.5),
                    replyTo: nil,
                    metadata: nil
                )
                messages.append(summaryMessage)
            }
        }
    }
    
    // MARK: - 建议员处理
    
    private func processSuggesterAgent(content: String, isFromPatient: Bool) {
        // 当医生给出诊断/治疗建议时，为患者提供参考问题
        let treatmentKeywords = ["治疗", "手术", "化疗", "靶向", "免疫", "方案", "建议", "recommend", "treatment", "surgery"]
        
        if !isFromPatient && treatmentKeywords.contains(where: content.contains) {
            let suggestions = [
                "💡 **提示**：您可以询问医生这个治疗方案的成功率",
                "💡 **提示**：您可以问一下治疗的副作用有哪些",
                "💡 **提示**：您可以询问是否有其他替代方案",
                "💡 **提示**：您可以了解治疗的费用和周期",
                "💡 **提示**：您可以询问治疗后的生活质量影响",
            ]
            
            let suggestion = ConsultationMessage(
                content: suggestions.randomElement()!,
                role: .agentSuggester,
                messageType: .suggestion,
                timestamp: Date().addingTimeInterval(2.0),
                replyTo: messages.last?.id,
                metadata: nil
            )
            messages.append(suggestion)
        }
        
        // 当患者问到费用/时间时，补充信息
        let patientQuestionKeywords = ["费用", "多少钱", "多久", "时间", "cost", "how long", "how much"]
        if isFromPatient && patientQuestionKeywords.contains(where: content.contains) {
            let infoMessage = ConsultationMessage(
                content: "💡 **参考信息**：跨境就医通常需要2-4周准备期，费用包括医疗费、翻译费、差旅费等。具体费用因医院和治疗方案而异。",
                role: .agentSuggester,
                messageType: .suggestion,
                timestamp: Date().addingTimeInterval(1.5),
                replyTo: messages.last?.id,
                metadata: nil
            )
            messages.append(infoMessage)
        }
    }
    
    // MARK: - 医学术语检测和解释
    
    private func detectMedicalTerms(in text: String) -> [String] {
        let termDict: [String: String] = [
            "NSCLC": "非小细胞肺癌",
            "SCLC": "小细胞肺癌",
            "EGFR": "表皮生长因子受体",
            "PD-L1": "程序性死亡配体1",
            "HER2": "人表皮生长因子受体2",
            "BRCA": "乳腺癌易感基因",
            "化疗": "使用药物杀死或抑制癌细胞",
            "靶向": "针对特定基因突变的精准治疗",
            "免疫治疗": "激活自身免疫系统抗癌",
            "放疗": "使用放射线杀死癌细胞",
            "转移": "癌细胞扩散到身体其他部位",
            "分期": "癌症发展的阶段",
        ]
        
        var foundTerms: [String] = []
        for term in termDict.keys {
            if text.uppercased().contains(term.uppercased()) {
                foundTerms.append(term)
            }
        }
        return foundTerms
    }
    
    private func explainMedicalTerm(_ term: String) -> String {
        let explanations: [String: String] = [
            "NSCLC": "非小细胞肺癌，占所有肺癌的80-85%，是最常见的肺癌类型。",
            "SCLC": "小细胞肺癌，占所有肺癌的10-15%，生长较快。",
            "EGFR": "表皮生长因子受体，突变后会促进癌细胞生长，可用靶向药物治疗。",
            "PD-L1": "程序性死亡配体1，表达水平高的患者可能对免疫治疗更敏感。",
            "HER2": "人表皮生长因子受体2，过度表达与乳腺癌等恶性肿瘤相关。",
            "BRCA": "乳腺癌易感基因，突变会增加患乳腺癌和卵巢癌的风险。",
            "化疗": "使用化学药物杀死快速分裂的细胞（包括癌细胞）的治疗方法。",
            "靶向": "针对癌细胞特定分子靶点的精准治疗，副作用通常比化疗小。",
            "免疫治疗": "通过激活或增强人体自身免疫系统来识别和攻击癌细胞。",
            "放疗": "使用高能射线照射肿瘤区域，杀死或抑制癌细胞。",
            "转移": "癌细胞从原发部位扩散到身体其他器官或组织。",
            "分期": "描述癌症在体内的扩散程度，常用I-IV期表示。",
        ]
        return explanations[term] ?? "相关医学术语"
    }
    
    // MARK: - 生成讨论主题
    
    private func generateTopics(for diseaseType: String) -> [DiscussionTopic] {
        return [
            DiscussionTopic(
                title: "病情介绍",
                description: "患者介绍病情和治疗历史"
            ),
            DiscussionTopic(
                title: "当前状况评估",
                description: "医生评估患者当前状态"
            ),
            DiscussionTopic(
                title: "治疗方案讨论",
                description: "讨论可能的治疗选择"
            ),
            DiscussionTopic(
                title: "风险与副作用",
                description: "了解治疗的风险和副作用"
            ),
            DiscussionTopic(
                title: "下一步计划",
                description: "确定下一步行动"
            ),
        ]
    }
    
    // MARK: - 生成最终总结
    
    func generateFinalSummary() -> ConsultationMessage {
        let doctorMessages = messages.filter { $0.role == .doctor }
        let patientMessages = messages.filter { $0.role == .patient }
        let suggestions = messages.filter { $0.messageType == .suggestion }
        
        let summary = """
        📋 **讨论总结**
        
        **基本信息**
        - 讨论时长：\(messages.count) 条消息
        - 医生发言：\(doctorMessages.count) 次
        - 患者发言：\(patientMessages.count) 次
        - AI建议：\(suggestions.count) 条
        
        **主要讨论内容**
        \(messages.filter { !$0.isAgentMessage }.suffix(6).map { "- [\($0.role.displayName)] \($0.content.prefix(60))" }.joined(separator: "\n"))
        
        **待跟进事项**
        - [ ] 确认治疗方案
        - [ ] 预约下一步检查
        - [ ] 准备病历翻译
        
        ---
        _此总结由AI自动生成，仅供参考_
        """
        
        return ConsultationMessage(
            content: summary,
            role: .agentSummarizer,
            messageType: .summary,
            timestamp: Date(),
            replyTo: nil,
            metadata: nil
        )
    }
    
    // MARK: - 切换Agent
    
    func toggleAgent(_ agent: AgentDefinition) {
        if activeAgents.contains(where: { $0.role == agent.role }) {
            activeAgents.removeAll { $0.role == agent.role }
        } else {
            activeAgents.append(agent)
        }
    }
}
