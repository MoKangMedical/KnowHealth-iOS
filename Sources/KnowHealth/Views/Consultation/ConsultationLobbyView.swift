import SwiftUI

// MARK: - Consultation Lobby
/// 讨论室大厅 — 查看和管理所有医患讨论

struct ConsultationLobbyView: View {
    @State private var rooms: [ConsultationRoom] = ConsultationRoom.demoRooms
    @State private var showNewRoom = false
    @State private var selectedRoom: ConsultationRoom? = nil
    @State private var filter: RoomFilter = .all
    
    enum RoomFilter: String, CaseIterable {
        case all = "全部"
        case active = "进行中"
        case waiting = "等待中"
        case completed = "已完成"
    }
    
    var filteredRooms: [ConsultationRoom] {
        switch filter {
        case .all: return rooms
        case .active: return rooms.filter { $0.status == .active }
        case .waiting: return rooms.filter { $0.status == .waiting }
        case .completed: return rooms.filter { $0.status == .completed }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter
                Picker("筛选", selection: $filter) {
                    ForEach(RoomFilter.allCases, id: \.self) { f in
                        Text(f.rawValue).tag(f)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                // Active agents overview
                activeAgentsOverview
                
                // Room list
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredRooms) { room in
                            Button {
                                selectedRoom = room
                            } label: {
                                RoomCard(room: room)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(16)
                    .padding(.bottom, 100)
                }
            }
            .background(KHTheme.Colors.background)
            .navigationTitle("讨论室")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showNewRoom = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(KHTheme.Colors.gradientPrimary)
                    }
                }
            }
            .navigationDestination(item: $selectedRoom) { room in
                ConsultationRoomView(room: room)
            }
            .sheet(isPresented: $showNewRoom) {
                NewRoomView()
            }
        }
    }
    
    // MARK: - Active Agents Overview
    private var activeAgentsOverview: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(AgentDefinition.allAgents, id: \.role) { agent in
                    VStack(spacing: 6) {
                        ZStack {
                            Circle()
                                .fill(agent.role.color.opacity(0.15))
                                .frame(width: 44, height: 44)
                            Image(systemName: agent.role.avatar)
                                .font(.system(size: 18))
                                .foregroundColor(agent.role.color)
                        }
                        
                        Text(agent.name.components(separatedBy: " · ").last ?? "")
                            .font(KHTheme.Typography.caption2())
                            .foregroundColor(KHTheme.Colors.textPrimary)
                        
                        Text(agent.description.prefix(8) + "...")
                            .font(.system(size: 9))
                            .foregroundColor(KHTheme.Colors.textTertiary)
                            .lineLimit(1)
                    }
                    .frame(width: 72)
                    .padding(.vertical, 8)
                    .background(KHTheme.Colors.surface)
                    .cornerRadius(KHTheme.Radius.md)
                    .shadow(color: KHTheme.Shadow.small.color, radius: 2, x: 0, y: 1)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(KHTheme.Colors.surfaceSecondary)
    }
}

// MARK: - Room Card
struct RoomCard: View {
    let room: ConsultationRoom
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(room.diseaseType)
                        .font(KHTheme.Typography.headline())
                        .foregroundColor(KHTheme.Colors.textPrimary)
                    
                    HStack(spacing: 8) {
                        Label(room.patientName, systemImage: "person.fill")
                        Label(room.doctorName, systemImage: "stethoscope")
                    }
                    .font(KHTheme.Typography.caption())
                    .foregroundColor(KHTheme.Colors.textSecondary)
                }
                
                Spacer()
                
                RoomStatusBadge(status: room.status)
            }
            
            // Doctor info
            HStack(spacing: 8) {
                Image(systemName: "building.2")
                    .font(.system(size: 12))
                    .foregroundColor(KHTheme.Colors.textTertiary)
                Text(room.doctorHospital)
                    .font(KHTheme.Typography.footnote())
                    .foregroundColor(KHTheme.Colors.textSecondary)
            }
            
            // Active agents
            HStack(spacing: 6) {
                Text("活跃Agent:")
                    .font(KHTheme.Typography.caption())
                    .foregroundColor(KHTheme.Colors.textTertiary)
                
                ForEach(room.activeAgents, id: \.self) { role in
                    Image(systemName: role.avatar)
                        .font(.system(size: 12))
                        .foregroundColor(role.color)
                        .frame(width: 24, height: 24)
                        .background(role.color.opacity(0.1))
                        .cornerRadius(KHTheme.Radius.sm)
                }
            }
            
            // Topics progress
            HStack {
                ForEach(room.topics.prefix(5)) { topic in
                    Image(systemName: topic.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 14))
                        .foregroundColor(topic.isCompleted ? KHTheme.Colors.success : KHTheme.Colors.textTertiary)
                }
                Spacer()
                Text("\(room.topics.filter { $0.isCompleted }.count)/\(room.topics.count) 主题")
                    .font(KHTheme.Typography.caption())
                    .foregroundColor(KHTheme.Colors.textTertiary)
            }
            
            // Time
            HStack {
                Image(systemName: "clock")
                    .font(.system(size: 12))
                Text("计划 \(room.scheduledDuration) 分钟")
                Spacer()
                Text(room.createdAt, style: .date)
            }
            .font(KHTheme.Typography.caption())
            .foregroundColor(KHTheme.Colors.textTertiary)
        }
        .padding(16)
        .background(KHTheme.Colors.surface)
        .cornerRadius(KHTheme.Radius.lg)
        .shadow(color: KHTheme.Shadow.small.color, radius: 4, x: 0, y: 2)
    }
}

struct RoomStatusBadge: View {
    let status: RoomStatus
    
    var color: Color {
        switch status {
        case .waiting: return KHTheme.Colors.warning
        case .active: return KHTheme.Colors.success
        case .paused: return KHTheme.Colors.textTertiary
        case .completed: return KHTheme.Colors.primary
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

// MARK: - New Room View
struct NewRoomView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedDisease = "肺癌"
    @State private var selectedDoctor = ""
    @State private var duration = 30
    @State private var enableMediator = true
    @State private var enableTranslator = false
    @State private var enableSummarizer = true
    @State private var enableSuggester = true
    
    let diseases = ["肺癌", "乳腺癌", "结直肠癌", "肝癌", "胃癌", "白血病", "淋巴瘤", "脑肿瘤", "罕见病"]
    let durations = [15, 30, 45, 60]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("病例信息") {
                    Picker("疾病类型", selection: $selectedDisease) {
                        ForEach(diseases, id: \.self) { Text($0) }
                    }
                }
                
                Section("医生选择") {
                    NavigationLink {
                        DoctorPickerView(selectedDoctor: $selectedDoctor)
                    } label: {
                        HStack {
                            Text("选择医生")
                            Spacer()
                            Text(selectedDoctor.isEmpty ? "未选择" : selectedDoctor)
                                .foregroundColor(selectedDoctor.isEmpty ? KHTheme.Colors.textTertiary : KHTheme.Colors.primary)
                        }
                    }
                }
                
                Section("讨论设置") {
                    Picker("计划时长", selection: $duration) {
                        ForEach(durations, id: \.self) { Text("\($0) 分钟") }
                    }
                }
                
                Section("AI Agent 配置") {
                    ToggleRow(icon: "bubble.left.and.bubble.right.fill", name: "AI协调员 · 小和", desc: "主持讨论流程", isOn: $enableMediator, color: .purple)
                    ToggleRow(icon: "globe", name: "AI翻译 · 小译", desc: "实时翻译", isOn: $enableTranslator, color: .orange)
                    ToggleRow(icon: "doc.text.magnifyingglass", name: "AI总结 · 小结", desc: "生成总结", isOn: $enableSummarizer, color: .cyan)
                    ToggleRow(icon: "lightbulb.fill", name: "AI顾问 · 小智", desc: "提供参考建议", isOn: $enableSuggester, color: .yellow)
                }
                
                Section {
                    Button {
                        dismiss()
                    } label: {
                        Text("创建讨论室")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .navigationTitle("新建讨论室")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消") { dismiss() }
                }
            }
        }
    }
}

struct ToggleRow: View {
    let icon: String
    let name: String
    let desc: String
    @Binding var isOn: Bool
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 36, height: 36)
                .background(color.opacity(0.1))
                .cornerRadius(KHTheme.Radius.sm)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(KHTheme.Typography.body())
                Text(desc)
                    .font(KHTheme.Typography.caption())
                    .foregroundColor(KHTheme.Colors.textSecondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
    }
}

struct DoctorPickerView: View {
    @Binding var selectedDoctor: String
    @Environment(\.dismiss) var dismiss
    
    let doctors = ExpertService.demoExperts
    
    var body: some View {
        List(doctors) { doctor in
            Button {
                selectedDoctor = doctor.name
                dismiss()
            } label: {
                HStack {
                    Text(doctor.countryFlag)
                        .font(.system(size: 28))
                    VStack(alignment: .leading) {
                        Text(doctor.name)
                            .font(KHTheme.Typography.body())
                        Text(doctor.hospital)
                            .font(KHTheme.Typography.caption())
                            .foregroundColor(KHTheme.Colors.textSecondary)
                    }
                    Spacer()
                    if selectedDoctor == doctor.name {
                        Image(systemName: "checkmark")
                            .foregroundColor(KHTheme.Colors.primary)
                    }
                }
            }
        }
        .navigationTitle("选择医生")
    }
}

// MARK: - Demo Data
extension ConsultationRoom {
    static let demoRooms: [ConsultationRoom] = [
        ConsultationRoom(
            id: "room_001",
            caseId: "case_001",
            patientName: "张先生",
            doctorName: "Dr. James Wilson",
            doctorHospital: "Mayo Clinic",
            diseaseType: "肺癌 (NSCLC III期)",
            status: .active,
            createdAt: Date(),
            scheduledDuration: 45,
            activeAgents: [.agentMediator, .agentSummarizer, .agentSuggester],
            topics: [
                DiscussionTopic(title: "病情介绍", description: "", isCompleted: true),
                DiscussionTopic(title: "当前状况评估", description: "", isCompleted: true),
                DiscussionTopic(title: "治疗方案讨论", description: "", isCompleted: false),
                DiscussionTopic(title: "风险与副作用", description: "", isCompleted: false),
                DiscussionTopic(title: "下一步计划", description: "", isCompleted: false),
            ]
        ),
        ConsultationRoom(
            id: "room_002",
            caseId: "case_002",
            patientName: "李女士",
            doctorName: "Dr. Rachel Cohen",
            doctorHospital: "Sheba Medical Center",
            diseaseType: "罕见血液病",
            status: .waiting,
            createdAt: Date().addingTimeInterval(3600),
            scheduledDuration: 60,
            activeAgents: [.agentMediator, .agentTranslator, .agentSummarizer, .agentSuggester],
            topics: [
                DiscussionTopic(title: "病情介绍", description: ""),
                DiscussionTopic(title: "基因检测解读", description: ""),
                DiscussionTopic(title: "治疗方案讨论", description: ""),
            ]
        ),
        ConsultationRoom(
            id: "room_003",
            caseId: "case_003",
            patientName: "王先生",
            doctorName: "Dr. Michael Chen",
            doctorHospital: "Cleveland Clinic",
            diseaseType: "脑肿瘤",
            status: .completed,
            createdAt: Date().addingTimeInterval(-86400),
            scheduledDuration: 30,
            activeAgents: [.agentMediator, .agentSummarizer],
            topics: [
                DiscussionTopic(title: "病情介绍", description: "", isCompleted: true),
                DiscussionTopic(title: "手术方案", description: "", isCompleted: true),
                DiscussionTopic(title: "术后康复", description: "", isCompleted: true),
            ]
        ),
    ]
}
