import Foundation
import SwiftUI
import Combine

// MARK: - Auth Manager
class AuthManager: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: User?
    @Published var token: String?
    
    private let baseURL = "http://localhost:8080/api/v1"
    
    func login(phone: String) async throws {
        // Simulate login
        await MainActor.run {
            self.currentUser = User(
                id: "user_001",
                phone: phone,
                name: "张先生",
                email: nil,
                role: .patient,
                language: "zh-CN",
                createdAt: Date()
            )
            self.token = "kh_demo_token"
            self.isLoggedIn = true
        }
    }
    
    func register(name: String, phone: String, email: String?) async throws {
        await MainActor.run {
            self.currentUser = User(
                id: UUID().uuidString.prefix(12).description,
                phone: phone,
                name: name,
                email: email,
                role: .patient,
                language: "zh-CN",
                createdAt: Date()
            )
            self.token = "kh_demo_token"
            self.isLoggedIn = true
        }
    }
    
    func logout() {
        currentUser = nil
        token = nil
        isLoggedIn = false
    }
}

// MARK: - Case Service
class CaseService: ObservableObject {
    @Published var cases: [MedicalCase] = []
    @Published var isLoading = false
    
    // Demo data
    static let demoCases: [MedicalCase] = [
        MedicalCase(
            id: "case_001",
            patientId: "user_001",
            diseaseType: .lungCancer,
            diseaseSubtype: "NSCLC III期",
            description: "患者男性，58岁，肺腺癌III期，EGFR L858R突变阳性",
            status: .expertAssigned,
            urgency: .urgent,
            aiSummary: "AI摘要：肺腺癌III期，建议靶向治疗...",
            matchedExperts: ["exp_001", "exp_004"],
            createdAt: Date().addingTimeInterval(-86400 * 3),
            updatedAt: Date()
        ),
        MedicalCase(
            id: "case_002",
            patientId: "user_001",
            diseaseType: .breastCancer,
            diseaseSubtype: "HER2阳性",
            description: "患者女性，45岁，乳腺癌HER2阳性",
            status: .completed,
            urgency: .normal,
            aiSummary: "AI摘要：HER2阳性乳腺癌...",
            matchedExperts: ["exp_005"],
            createdAt: Date().addingTimeInterval(-86400 * 10),
            updatedAt: Date().addingTimeInterval(-86400 * 2)
        )
    ]
    
    func fetchCases() async {
        await MainActor.run { isLoading = true }
        try? await Task.sleep(nanoseconds: 500_000_000)
        await MainActor.run {
            self.cases = Self.demoCases
            self.isLoading = false
        }
    }
    
    func createCase(diseaseType: MedicalCase.DiseaseType, description: String, urgency: MedicalCase.Urgency) async {
        await MainActor.run { isLoading = true }
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        let newCase = MedicalCase(
            id: "case_\(Int.random(in: 100...999))",
            patientId: "user_001",
            diseaseType: diseaseType,
            diseaseSubtype: nil,
            description: description,
            status: .aiProcessing,
            urgency: urgency,
            aiSummary: nil,
            matchedExperts: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        await MainActor.run {
            self.cases.insert(newCase, at: 0)
            self.isLoading = false
        }
    }
}

// MARK: - Expert Service
class ExpertService: ObservableObject {
    @Published var experts: [Expert] = []
    @Published var isLoading = false
    
    static let demoExperts: [Expert] = [
        Expert(id: "exp_001", name: "Dr. James Wilson", nameCn: nil,
               hospital: "Mayo Clinic", hospitalCn: "梅奥诊所",
               country: "US", specialties: ["lung_cancer", "breast_cancer", "colon_cancer"],
               languages: ["en"], rating: 4.9, totalCases: 342, avgResponseHours: 48,
               bio: "25年肿瘤治疗经验，擅长实体瘤的靶向治疗和免疫治疗。"),
        Expert(id: "exp_002", name: "Dr. Yuki Tanaka", nameCn: "田中由纪",
               hospital: "National Cancer Center Japan", hospitalCn: "日本国立癌症中心",
               country: "JP", specialties: ["gastric_cancer", "liver_cancer"],
               languages: ["ja", "en"], rating: 4.8, totalCases: 278, avgResponseHours: 36,
               bio: "消化道癌症手术专家，微创手术先驱。"),
        Expert(id: "exp_003", name: "Dr. Rachel Cohen", nameCn: nil,
               hospital: "Sheba Medical Center", hospitalCn: "谢巴医疗中心",
               country: "IL", specialties: ["rare_disease", "leukemia", "lymphoma"],
               languages: ["en", "he"], rating: 4.95, totalCases: 156, avgResponseHours: 24,
               bio: "全球罕见血液病领域权威，精准医疗先驱。"),
        Expert(id: "exp_004", name: "Dr. Michael Chen", nameCn: "陈明",
               hospital: "Cleveland Clinic", hospitalCn: "克利夫兰诊所",
               country: "US", specialties: ["brain_tumor", "lung_cancer"],
               languages: ["en", "zh"], rating: 4.85, totalCases: 198, avgResponseHours: 40,
               bio: "复杂脑肿瘤手术专家，精通清醒开颅技术，中英双语服务。"),
        Expert(id: "exp_005", name: "Dr. Sarah Park", nameCn: "朴智妍",
               hospital: "Samsung Medical Center", hospitalCn: "三星医疗中心",
               country: "KR", specialties: ["breast_cancer", "ovarian_cancer"],
               languages: ["ko", "en"], rating: 4.92, totalCases: 412, avgResponseHours: 30,
               bio: "乳腺癌治疗权威，靶向和免疫治疗经验丰富。"),
    ]
    
    func fetchExperts() async {
        await MainActor.run { isLoading = true }
        try? await Task.sleep(nanoseconds: 500_000_000)
        await MainActor.run {
            self.experts = Self.demoExperts
            self.isLoading = false
        }
    }
}

// MARK: - AI Chat Service
class AIChatService: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isTyping = false
    
    private let greetings = [
        "您好！我是KnowHealth的AI医疗助手小知 🏥\n\n我可以帮助您：\n📋 收集和整理您的病历信息\n🌍 匹配最适合的全球顶级专家\n❓ 解答关于跨境医疗咨询的流程问题\n\n请问您今天需要什么帮助？"
    ]
    
    func startChat() {
        if messages.isEmpty {
            messages.append(ChatMessage(content: greetings[0], isFromUser: false, timestamp: Date()))
        }
    }
    
    func sendMessage(_ text: String) {
        messages.append(ChatMessage(content: text, isFromUser: true, timestamp: Date()))
        
        isTyping = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let response = self.generateResponse(for: text)
            self.messages.append(ChatMessage(content: response, isFromUser: false, timestamp: Date()))
            self.isTyping = false
        }
    }
    
    private func generateResponse(for message: String) -> String {
        let lower = message.lowercased()
        
        if lower.contains("费用") || lower.contains("价格") || lower.contains("多少钱") {
            return """
            我们的服务定价如下：
            
            💰 AI病历分析：¥499
            💰 标准第二意见：¥4,999
            💰 高级多学科：¥9,999
            💰 VIP全程服务：¥29,999
            💰 年度会员：¥99,999
            
            您想了解哪种服务的更多详情？
            """
        } else if lower.contains("流程") || lower.contains("步骤") {
            return """
            获取第二意见只需4步：
            
            1️⃣ 上传病历
            2️⃣ AI智能分析
            3️⃣ 专家审阅
            4️⃣ 获取报告
            
            您现在想开始上传病历吗？
            """
        } else if lower.contains("专家") || lower.contains("医生") {
            return """
            我们合作的专家来自全球顶级医院：
            
            🇺🇸 美国：梅奥诊所、克利夫兰诊所
            🇮🇱 以色列：谢巴医疗中心
            🇯🇵 日本：国立癌症中心
            🇰🇷 韩国：三星医疗中心
            
            您有偏好的国家或医院吗？
            """
        } else {
            return """
            感谢您的信息。为了更好地帮助您，请告诉我：
            
            1. 患者的诊断是什么？
            2. 目前接受了哪些治疗？
            3. 您希望咨询哪个国家的专家？
            
            您也可以点击下方按钮上传病历资料 📎
            """
        }
    }
}
