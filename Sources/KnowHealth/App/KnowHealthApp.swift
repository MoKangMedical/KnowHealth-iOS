import SwiftUI

@main
struct KnowHealthApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var authManager = AuthManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(authManager)
                .preferredColorScheme(.light)
        }
    }
}

// MARK: - App State
class AppState: ObservableObject {
    @Published var selectedTab: Tab = .home
    @Published var showOnboarding: Bool = false
    @Published var isLoading: Bool = false
    
    enum Tab: String, CaseIterable {
        case home = "首页"
        case cases = "我的病例"
        case experts = "专家"
        case profile = "我的"
        
        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .cases: return "doc.text.fill"
            case .experts: return "person.2.fill"
            case .profile: return "person.circle.fill"
            }
        }
    }
}

// MARK: - Content View
struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        if authManager.isLoggedIn {
            MainTabView()
        } else {
            LoginView()
        }
    }
}
