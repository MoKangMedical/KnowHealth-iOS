import SwiftUI

// MARK: - Case List View
struct CaseListView: View {
    @EnvironmentObject var caseService: CaseService
    @State private var showNewCase = false
    @State private var selectedFilter: CaseFilter = .all
    
    enum CaseFilter: String, CaseIterable {
        case all = "全部"
        case pending = "处理中"
        case completed = "已完成"
    }
    
    var filteredCases: [MedicalCase] {
        switch selectedFilter {
        case .all: return caseService.cases
        case .pending: return caseService.cases.filter { [.pending, .aiProcessing, .expertAssigned].contains($0.status) }
        case .completed: return caseService.cases.filter { $0.status == .completed }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter tabs
                Picker("筛选", selection: $selectedFilter) {
                    ForEach(CaseFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                if caseService.isLoading {
                    Spacer()
                    ProgressView("加载中...")
                    Spacer()
                } else if filteredCases.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundColor(KHTheme.Colors.textTertiary)
                        Text("暂无病例")
                            .font(KHTheme.Typography.headline())
                            .foregroundColor(KHTheme.Colors.textSecondary)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredCases) { caseItem in
                                NavigationLink(destination: CaseDetailView(caseItem: caseItem)) {
                                    CaseCard(caseItem: caseItem)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(16)
                        .padding(.bottom, 100)
                    }
                }
            }
            .background(KHTheme.Colors.background)
            .navigationTitle("我的病例")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showNewCase = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(KHTheme.Colors.gradientPrimary)
                    }
                }
            }
            .sheet(isPresented: $showNewCase) {
                NewCaseView()
            }
            .task {
                await caseService.fetchCases()
            }
        }
    }
}

// MARK: - Case Detail View
struct CaseDetailView: View {
    let caseItem: MedicalCase
    @State private var showExpertOpinion = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Status header
                statusHeader
                
                // AI Summary
                if let summary = caseItem.aiSummary {
                    aiSummarySection(summary)
                }
                
                // Matched Experts
                if let expertIds = caseItem.matchedExperts, !expertIds.isEmpty {
                    matchedExpertsSection(expertIds)
                }
                
                // Case Info
                caseInfoSection
                
                // Actions
                actionButtons
            }
            .padding(16)
            .padding(.bottom, 50)
        }
        .background(KHTheme.Colors.background)
        .navigationTitle(caseItem.diseaseType.displayName)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var statusHeader: some View {
        VStack(spacing: 12) {
            HStack {
                Text(caseItem.diseaseType.icon)
                    .font(.system(size: 48))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(caseItem.diseaseType.displayName)
                        .font(KHTheme.Typography.title2())
                    if let subtype = caseItem.diseaseSubtype {
                        Text(subtype)
                            .font(KHTheme.Typography.subheadline())
                            .foregroundColor(KHTheme.Colors.textSecondary)
                    }
                }
                
                Spacer()
                
                CaseStatusBadge(status: caseItem.status)
            }
            
            ProgressView(value: progressValue)
                .tint(KHTheme.Colors.primary)
        }
        .padding(20)
        .background(KHTheme.Colors.surface)
        .cornerRadius(KHTheme.Radius.lg)
    }
    
    private var progressValue: Double {
        switch caseItem.status {
        case .pending: return 0.1
        case .aiProcessing: return 0.3
        case .expertAssigned: return 0.5
        case .opinionSubmitted: return 0.8
        case .completed: return 1.0
        case .cancelled: return 0.0
        }
    }
    
    private func aiSummarySection(_ summary: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("AI分析摘要", systemImage: "brain.head.profile")
                .font(KHTheme.Typography.headline())
                .foregroundColor(KHTheme.Colors.primary)
            
            Text(summary)
                .font(KHTheme.Typography.body())
                .foregroundColor(KHTheme.Colors.textPrimary)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(KHTheme.Colors.primary.opacity(0.05))
        .cornerRadius(KHTheme.Radius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: KHTheme.Radius.lg)
                .stroke(KHTheme.Colors.primary.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func matchedExpertsSection(_ expertIds: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("匹配专家", systemImage: "person.crop.circle.badge.checkmark")
                .font(KHTheme.Typography.headline())
            
            ForEach(ExpertService.demoExperts.filter { expertIds.contains($0.id) }) { expert in
                ExpertRowCompact(expert: expert)
            }
        }
        .padding(20)
        .background(KHTheme.Colors.surface)
        .cornerRadius(KHTheme.Radius.lg)
    }
    
    private var caseInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("病例信息")
                .font(KHTheme.Typography.headline())
            
            InfoRow(label: "诊断", value: caseItem.diseaseType.displayName)
            InfoRow(label: "紧急程度", value: caseItem.urgency.displayName)
            InfoRow(label: "创建时间", value: caseItem.createdAt.formatted())
            
            VStack(alignment: .leading, spacing: 4) {
                Text("病情描述")
                    .font(KHTheme.Typography.subheadline())
                    .foregroundColor(KHTheme.Colors.textSecondary)
                Text(caseItem.description)
                    .font(KHTheme.Typography.body())
            }
        }
        .padding(20)
        .background(KHTheme.Colors.surface)
        .cornerRadius(KHTheme.Radius.lg)
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                showExpertOpinion = true
            } label: {
                Label("查看专家意见", systemImage: "doc.text.fill")
            }
            .khButtonPrimary()
            
            Button {} label: {
                Label("联系客服", systemImage: "bubble.left.and.bubble.right")
            }
            .khButtonSecondary()
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(KHTheme.Typography.subheadline())
                .foregroundColor(KHTheme.Colors.textSecondary)
            Spacer()
            Text(value)
                .font(KHTheme.Typography.subheadline())
                .foregroundColor(KHTheme.Colors.textPrimary)
        }
    }
}

struct ExpertRowCompact: View {
    let expert: Expert
    
    var body: some View {
        HStack(spacing: 12) {
            Text(expert.countryFlag)
                .font(.system(size: 28))
                .frame(width: 44, height: 44)
                .background(KHTheme.Colors.surfaceSecondary)
                .cornerRadius(KHTheme.Radius.md)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(expert.name)
                    .font(KHTheme.Typography.subheadline())
                    .foregroundColor(KHTheme.Colors.textPrimary)
                Text(expert.hospital)
                    .font(KHTheme.Typography.caption())
                    .foregroundColor(KHTheme.Colors.textSecondary)
            }
            
            Spacer()
            
            HStack(spacing: 2) {
                Image(systemName: "star.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.yellow)
                Text(String(format: "%.1f", expert.rating))
                    .font(KHTheme.Typography.caption())
            }
        }
        .padding(12)
        .background(KHTheme.Colors.surfaceSecondary)
        .cornerRadius(KHTheme.Radius.md)
    }
}

// MARK: - New Case View
struct NewCaseView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var caseService: CaseService
    @State private var selectedDisease: MedicalCase.DiseaseType = .lungCancer
    @State private var description = ""
    @State private var urgency: MedicalCase.Urgency = .normal
    @State private var isSubmitting = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Disease type
                    VStack(alignment: .leading, spacing: 12) {
                        Text("疾病类型")
                            .font(KHTheme.Typography.headline())
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                            ForEach(MedicalCase.DiseaseType.allCases, id: \.self) { disease in
                                Button {
                                    selectedDisease = disease
                                } label: {
                                    HStack(spacing: 4) {
                                        Text(disease.icon)
                                        Text(disease.displayName)
                                            .font(KHTheme.Typography.caption())
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .frame(maxWidth: .infinity)
                                    .background(selectedDisease == disease ? KHTheme.Colors.primary : KHTheme.Colors.surfaceSecondary)
                                    .foregroundColor(selectedDisease == disease ? .white : KHTheme.Colors.textPrimary)
                                    .cornerRadius(KHTheme.Radius.md)
                                }
                            }
                        }
                    }
                    
                    // Urgency
                    VStack(alignment: .leading, spacing: 12) {
                        Text("紧急程度")
                            .font(KHTheme.Typography.headline())
                        
                        HStack(spacing: 12) {
                            ForEach([MedicalCase.Urgency.normal, .urgent, .emergency], id: \.self) { urg in
                                Button {
                                    urgency = urg
                                } label: {
                                    Text(urg.displayName)
                                        .font(KHTheme.Typography.subheadline())
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(urgency == urg ? KHTheme.Colors.primary : KHTheme.Colors.surfaceSecondary)
                                        .foregroundColor(urgency == urg ? .white : KHTheme.Colors.textPrimary)
                                        .cornerRadius(KHTheme.Radius.md)
                                }
                            }
                        }
                    }
                    
                    // Description
                    VStack(alignment: .leading, spacing: 12) {
                        Text("病情描述")
                            .font(KHTheme.Typography.headline())
                        
                        TextEditor(text: $description)
                            .frame(minHeight: 150)
                            .padding(12)
                            .background(KHTheme.Colors.surfaceSecondary)
                            .cornerRadius(KHTheme.Radius.md)
                            .overlay(
                                RoundedRectangle(cornerRadius: KHTheme.Radius.md)
                                    .stroke(KHTheme.Colors.border, lineWidth: 1)
                            )
                        
                        if description.isEmpty {
                            Text("请详细描述：诊断时间、已接受的治疗、当前状况、想咨询的问题等")
                                .font(KHTheme.Typography.footnote())
                                .foregroundColor(KHTheme.Colors.textTertiary)
                        }
                    }
                    
                    // Upload hint
                    VStack(spacing: 8) {
                        Image(systemName: "doc.badge.plus")
                            .font(.system(size: 32))
                            .foregroundColor(KHTheme.Colors.primary)
                        Text("上传病历资料")
                            .font(KHTheme.Typography.subheadline())
                            .foregroundColor(KHTheme.Colors.primary)
                        Text("支持PDF、图片、Word格式")
                            .font(KHTheme.Typography.caption())
                            .foregroundColor(KHTheme.Colors.textTertiary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(24)
                    .background(KHTheme.Colors.primary.opacity(0.05))
                    .cornerRadius(KHTheme.Radius.lg)
                    .overlay(
                        RoundedRectangle(cornerRadius: KHTheme.Radius.lg)
                            .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [6]))
                            .foregroundColor(KHTheme.Colors.primary.opacity(0.3))
                    )
                }
                .padding(16)
            }
            .background(KHTheme.Colors.background)
            .navigationTitle("新建病例")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button {
                    Task {
                        isSubmitting = true
                        await caseService.createCase(diseaseType: selectedDisease, description: description, urgency: urgency)
                        isSubmitting = false
                        dismiss()
                    }
                } label: {
                    if isSubmitting {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("提交病例")
                    }
                }
                .khButtonPrimary()
                .padding(16)
                .background(KHTheme.Colors.background)
            }
        }
    }
}
