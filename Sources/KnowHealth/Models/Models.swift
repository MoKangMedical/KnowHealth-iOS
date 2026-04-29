import Foundation

// MARK: - User
struct User: Codable, Identifiable {
    let id: String
    let phone: String
    let name: String
    let email: String?
    let role: UserRole
    let language: String
    let createdAt: Date
    
    enum UserRole: String, Codable, CaseIterable {
        case patient = "patient"
        case expert = "expert"
        case admin = "admin"
        
        var displayName: String {
            switch self {
            case .patient: return "患者"
            case .expert: return "专家"
            case .admin: return "管理员"
            }
        }
    }
}

// MARK: - Medical Case
struct MedicalCase: Codable, Identifiable {
    let id: String
    let patientId: String
    let diseaseType: DiseaseType
    let diseaseSubtype: String?
    let description: String
    let status: CaseStatus
    let urgency: Urgency
    let aiSummary: String?
    let matchedExperts: [String]?
    let createdAt: Date
    let updatedAt: Date
    
    enum DiseaseType: String, Codable, CaseIterable {
        case lungCancer = "lung_cancer"
        case breastCancer = "breast_cancer"
        case colonCancer = "colon_cancer"
        case liverCancer = "liver_cancer"
        case gastricCancer = "gastric_cancer"
        case leukemia = "leukemia"
        case lymphoma = "lymphoma"
        case brainTumor = "brain_tumor"
        case pancreaticCancer = "pancreatic_cancer"
        case ovarianCancer = "ovarian_cancer"
        case prostateCancer = "prostate_cancer"
        case rareDisease = "rare_disease"
        case other = "other"
        
        var displayName: String {
            switch self {
            case .lungCancer: return "肺癌"
            case .breastCancer: return "乳腺癌"
            case .colonCancer: return "结直肠癌"
            case .liverCancer: return "肝癌"
            case .gastricCancer: return "胃癌"
            case .leukemia: return "白血病"
            case .lymphoma: return "淋巴瘤"
            case .brainTumor: return "脑肿瘤"
            case .pancreaticCancer: return "胰腺癌"
            case .ovarianCancer: return "卵巢癌"
            case .prostateCancer: return "前列腺癌"
            case .rareDisease: return "罕见病"
            case .other: return "其他"
            }
        }
        
        var icon: String {
            switch self {
            case .lungCancer: return "🫁"
            case .breastCancer: return "🎀"
            case .colonCancer: return "🏥"
            case .liverCancer: return "🫀"
            case .gastricCancer: return "🏥"
            case .leukemia: return "🩸"
            case .lymphoma: return "🔬"
            case .brainTumor: return "🧠"
            case .pancreaticCancer: return "🏥"
            case .ovarianCancer: return "🏥"
            case .prostateCancer: return "🏥"
            case .rareDisease: return "🧬"
            case .other: return "📋"
            }
        }
    }
    
    enum CaseStatus: String, Codable {
        case pending = "pending"
        case aiProcessing = "ai_processing"
        case expertAssigned = "expert_assigned"
        case opinionSubmitted = "opinion_submitted"
        case completed = "completed"
        case cancelled = "cancelled"
        
        var displayName: String {
            switch self {
            case .pending: return "待处理"
            case .aiProcessing: return "AI分析中"
            case .expertAssigned: return "专家已分配"
            case .opinionSubmitted: return "意见已提交"
            case .completed: return "已完成"
            case .cancelled: return "已取消"
            }
        }
        
        var color: String {
            switch self {
            case .pending: return "orange"
            case .aiProcessing: return "blue"
            case .expertAssigned: return "purple"
            case .opinionSubmitted: return "green"
            case .completed: return "green"
            case .cancelled: return "red"
            }
        }
    }
    
    enum Urgency: String, Codable {
        case normal = "normal"
        case urgent = "urgent"
        case emergency = "emergency"
        
        var displayName: String {
            switch self {
            case .normal: return "常规"
            case .urgent: return "紧急"
            case .emergency: return "非常紧急"
            }
        }
    }
}

// MARK: - Expert
struct Expert: Codable, Identifiable {
    let id: String
    let name: String
    let nameCn: String?
    let hospital: String
    let hospitalCn: String?
    let country: String
    let specialties: [String]
    let languages: [String]
    let rating: Double
    let totalCases: Int
    let avgResponseHours: Int
    let bio: String?
    
    var countryFlag: String {
        switch country {
        case "US": return "🇺🇸"
        case "JP": return "🇯🇵"
        case "IL": return "🇮🇱"
        case "KR": return "🇰🇷"
        case "DE": return "🇩🇪"
        case "SG": return "🇸🇬"
        default: return "🌍"
        }
    }
}

// MARK: - Order
struct Order: Codable, Identifiable {
    let id: String
    let caseId: String
    let serviceTier: ServiceTier
    let amount: Double
    let currency: String
    let paymentStatus: PaymentStatus
    let createdAt: Date
    
    enum ServiceTier: String, Codable, CaseIterable {
        case aiAnalysis = "ai_analysis"
        case standard = "standard"
        case premium = "premium"
        case vip = "vip"
        case annual = "annual"
        
        var displayName: String {
            switch self {
            case .aiAnalysis: return "AI分析"
            case .standard: return "标准第二意见"
            case .premium: return "高级多学科"
            case .vip: return "VIP全程服务"
            case .annual: return "年度会员"
            }
        }
        
        var price: Int {
            switch self {
            case .aiAnalysis: return 499
            case .standard: return 4999
            case .premium: return 9999
            case .vip: return 29999
            case .annual: return 99999
            }
        }
        
        var icon: String {
            switch self {
            case .aiAnalysis: return "brain.head.profile"
            case .standard: return "doc.text"
            case .premium: return "person.3"
            case .vip: return "crown.fill"
            case .annual: return "star.circle.fill"
            }
        }
    }
    
    enum PaymentStatus: String, Codable {
        case pending = "pending"
        case paid = "paid"
        case refunded = "refunded"
        
        var displayName: String {
            switch self {
            case .pending: return "待支付"
            case .paid: return "已支付"
            case .refunded: return "已退款"
            }
        }
    }
}

// MARK: - Expert Opinion
struct ExpertOpinion: Codable, Identifiable {
    let id: String
    let caseId: String
    let expertName: String
    let hospital: String
    let diagnosisConfirmation: String
    let treatmentRecommendations: String
    let additionalTests: String?
    let confidenceLevel: String
    let followUpNeeded: Bool
    let submittedAt: Date
}

// MARK: - API Response
struct APIResponse<T: Codable>: Codable {
    let data: T?
    let error: String?
    let message: String?
}

// MARK: - Chat Message
struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isFromUser: Bool
    let timestamp: Date
}
