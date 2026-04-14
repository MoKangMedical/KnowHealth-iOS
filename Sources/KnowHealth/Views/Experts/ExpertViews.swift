import SwiftUI

// MARK: - Expert List View
struct ExpertListView: View {
    @EnvironmentObject var expertService: ExpertService
    @State private var searchText = ""
    @State private var selectedCountry: String? = nil
    
    let countries = [
        ("全部", nil),
        ("🇺🇸 美国", "US"),
        ("🇯🇵 日本", "JP"),
        ("🇮🇱 以色列", "IL"),
        ("🇰🇷 韩国", "KR"),
    ]
    
    var filteredExperts: [Expert] {
        var result = expertService.experts
        if let country = selectedCountry {
            result = result.filter { $0.country == country }
        }
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                ($0.nameCn?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                $0.hospital.localizedCaseInsensitiveContains(searchText)
            }
        }
        return result
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Country filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(countries, id: \.1) { name, code in
                            Button {
                                selectedCountry = code
                            } label: {
                                Text(name)
                                    .font(KHTheme.Typography.subheadline())
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedCountry == code ? KHTheme.Colors.primary : KHTheme.Colors.surfaceSecondary)
                                    .foregroundColor(selectedCountry == code ? .white : KHTheme.Colors.textPrimary)
                                    .cornerRadius(KHTheme.Radius.pill)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                
                if expertService.isLoading {
                    Spacer()
                    ProgressView("加载专家列表...")
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredExperts) { expert in
                                NavigationLink(destination: ExpertDetailView(expert: expert)) {
                                    ExpertCard(expert: expert)
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
            .navigationTitle("全球专家")
            .searchable(text: $searchText, prompt: "搜索专家或医院")
            .task {
                await expertService.fetchExperts()
            }
        }
    }
}

// MARK: - Expert Card
struct ExpertCard: View {
    let expert: Expert
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(KHTheme.Colors.gradientPrimary)
                        .frame(width: 72, height: 72)
                    Text(expert.name.prefix(2).uppercased())
                        .font(KHTheme.Typography.title2())
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(expert.name)
                        .font(KHTheme.Typography.headline())
                        .foregroundColor(KHTheme.Colors.textPrimary)
                    
                    if let nameCn = expert.nameCn {
                        Text(nameCn)
                            .font(KHTheme.Typography.subheadline())
                            .foregroundColor(KHTheme.Colors.textSecondary)
                    }
                    
                    HStack(spacing: 4) {
                        Text(expert.countryFlag)
                        Text(expert.hospital)
                            .font(KHTheme.Typography.footnote())
                            .foregroundColor(KHTheme.Colors.textSecondary)
                    }
                }
                
                Spacer()
                
                // Rating
                VStack(spacing: 2) {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", expert.rating))
                            .font(KHTheme.Typography.headline())
                    }
                    Text("\(expert.totalCases)案例")
                        .font(KHTheme.Typography.caption2())
                        .foregroundColor(KHTheme.Colors.textTertiary)
                }
            }
            
            // Specialties
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(expert.specialties, id: \.self) { specialty in
                        Text(specialty.replacingOccurrences(of: "_", with: " "))
                            .font(KHTheme.Typography.caption())
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(KHTheme.Colors.primary.opacity(0.1))
                            .foregroundColor(KHTheme.Colors.primary)
                            .cornerRadius(KHTheme.Radius.sm)
                    }
                }
            }
            
            // Bio
            if let bio = expert.bio {
                Text(bio)
                    .font(KHTheme.Typography.footnote())
                    .foregroundColor(KHTheme.Colors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(16)
        .background(KHTheme.Colors.surface)
        .cornerRadius(KHTheme.Radius.lg)
        .shadow(color: KHTheme.Shadow.small.color, radius: KHTheme.Shadow.small.radius, x: 0, y: 2)
    }
}

// MARK: - Expert Detail View
struct ExpertDetailView: View {
    let expert: Expert
    @State private var showBooking = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(KHTheme.Colors.gradientPrimary)
                            .frame(width: 100, height: 100)
                        Text(expert.name.prefix(2).uppercased())
                            .font(KHTheme.Typography.largeTitle())
                            .foregroundColor(.white)
                    }
                    
                    Text(expert.name)
                        .font(KHTheme.Typography.title2())
                    
                    if let nameCn = expert.nameCn {
                        Text(nameCn)
                            .font(KHTheme.Typography.headline())
                            .foregroundColor(KHTheme.Colors.textSecondary)
                    }
                    
                    HStack(spacing: 4) {
                        Text(expert.countryFlag)
                        Text(expert.hospital)
                            .font(KHTheme.Typography.body())
                    }
                    
                    HStack(spacing: 20) {
                        VStack(spacing: 4) {
                            HStack(spacing: 2) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text(String(format: "%.1f", expert.rating))
                                    .font(KHTheme.Typography.title3())
                            }
                            Text("评分")
                                .font(KHTheme.Typography.caption())
                                .foregroundColor(KHTheme.Colors.textSecondary)
                        }
                        
                        Divider().frame(height: 40)
                        
                        VStack(spacing: 4) {
                            Text("\(expert.totalCases)")
                                .font(KHTheme.Typography.title3())
                            Text("案例数")
                                .font(KHTheme.Typography.caption())
                                .foregroundColor(KHTheme.Colors.textSecondary)
                        }
                        
                        Divider().frame(height: 40)
                        
                        VStack(spacing: 4) {
                            Text("\(expert.avgResponseHours)h")
                                .font(KHTheme.Typography.title3())
                            Text("响应时间")
                                .font(KHTheme.Typography.caption())
                                .foregroundColor(KHTheme.Colors.textSecondary)
                        }
                    }
                }
                .padding(24)
                .background(KHTheme.Colors.surface)
                .cornerRadius(KHTheme.Radius.xl)
                
                // Specialties
                VStack(alignment: .leading, spacing: 12) {
                    Text("擅长领域")
                        .font(KHTheme.Typography.headline())
                    
                    ForEach(expert.specialties, id: \.self) { specialty in
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(KHTheme.Colors.success)
                            Text(specialty.replacingOccurrences(of: "_", with: " ").capitalized)
                                .font(KHTheme.Typography.body())
                        }
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(KHTheme.Colors.surface)
                .cornerRadius(KHTheme.Radius.lg)
                
                // Languages
                VStack(alignment: .leading, spacing: 12) {
                    Text("支持语言")
                        .font(KHTheme.Typography.headline())
                    
                    HStack(spacing: 12) {
                        ForEach(expert.languages, id: \.self) { lang in
                            Text(languageName(lang))
                                .font(KHTheme.Typography.subheadline())
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(KHTheme.Colors.surfaceSecondary)
                                .cornerRadius(KHTheme.Radius.pill)
                        }
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(KHTheme.Colors.surface)
                .cornerRadius(KHTheme.Radius.lg)
                
                // Bio
                if let bio = expert.bio {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("专家简介")
                            .font(KHTheme.Typography.headline())
                        Text(bio)
                            .font(KHTheme.Typography.body())
                            .foregroundColor(KHTheme.Colors.textSecondary)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(KHTheme.Colors.surface)
                    .cornerRadius(KHTheme.Radius.lg)
                }
            }
            .padding(16)
            .padding(.bottom, 100)
        }
        .background(KHTheme.Colors.background)
        .navigationTitle("专家详情")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            Button {
                showBooking = true
            } label: {
                Text("预约此专家")
            }
            .khButtonPrimary()
            .padding(16)
            .background(KHTheme.Colors.background)
        }
    }
    
    private func languageName(_ code: String) -> String {
        switch code {
        case "en": return "🇺🇸 English"
        case "zh": return "🇨🇳 中文"
        case "ja": return "🇯🇵 日本語"
        case "ko": return "🇰🇷 한국어"
        case "he": return "🇮🇱 עברית"
        default: return code
        }
    }
}
