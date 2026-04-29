import SwiftUI

// MARK: - Theme
struct KHTheme {
    // MARK: Colors
    struct Colors {
        static let primary = Color(red: 0.23, green: 0.35, blue: 0.92)      // #3B5CEB
        static let primaryLight = Color(red: 0.40, green: 0.53, blue: 0.95)
        static let primaryDark = Color(red: 0.14, green: 0.25, blue: 0.75)
        
        static let secondary = Color(red: 0.55, green: 0.33, blue: 0.91)    // #8C54E8
        static let accent = Color(red: 0.13, green: 0.77, blue: 0.37)       // #22C55E
        
        static let success = Color(red: 0.13, green: 0.77, blue: 0.37)
        static let warning = Color(red: 1.0, green: 0.72, blue: 0.0)
        static let error = Color(red: 0.91, green: 0.26, blue: 0.21)
        
        static let background = Color(red: 0.97, green: 0.98, blue: 0.99)
        static let surface = Color.white
        static let surfaceSecondary = Color(red: 0.95, green: 0.96, blue: 0.97)
        
        static let textPrimary = Color(red: 0.11, green: 0.11, blue: 0.12)
        static let textSecondary = Color(red: 0.42, green: 0.45, blue: 0.50)
        static let textTertiary = Color(red: 0.62, green: 0.65, blue: 0.70)
        
        static let border = Color(red: 0.88, green: 0.89, blue: 0.91)
        
        static let gradientPrimary = LinearGradient(
            colors: [primary, secondary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let gradientHero = LinearGradient(
            colors: [
                Color(red: 0.40, green: 0.48, blue: 0.93),
                Color(red: 0.46, green: 0.29, blue: 0.64)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: Typography
    struct Typography {
        static func largeTitle() -> Font { .system(size: 34, weight: .bold, design: .rounded) }
        static func title1() -> Font { .system(size: 28, weight: .bold, design: .rounded) }
        static func title2() -> Font { .system(size: 22, weight: .bold, design: .rounded) }
        static func title3() -> Font { .system(size: 20, weight: .semibold, design: .rounded) }
        static func headline() -> Font { .system(size: 17, weight: .semibold) }
        static func body() -> Font { .system(size: 17, weight: .regular) }
        static func callout() -> Font { .system(size: 16, weight: .regular) }
        static func subheadline() -> Font { .system(size: 15, weight: .regular) }
        static func footnote() -> Font { .system(size: 13, weight: .regular) }
        static func caption() -> Font { .system(size: 12, weight: .regular) }
        static func caption2() -> Font { .system(size: 11, weight: .regular) }
    }
    
    // MARK: Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: Corner Radius
    struct Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let pill: CGFloat = 100
    }
    
    // MARK: Shadows
    struct Shadow {
        static let small = ShadowStyle(
            color: Color.black.opacity(0.05),
            radius: 4, x: 0, y: 2
        )
        static let medium = ShadowStyle(
            color: Color.black.opacity(0.08),
            radius: 8, x: 0, y: 4
        )
        static let large = ShadowStyle(
            color: Color.black.opacity(0.12),
            radius: 16, x: 0, y: 8
        )
    }
    
    struct ShadowStyle {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
}

// MARK: - View Modifiers
extension View {
    func khCard() -> some View {
        self
            .background(KHTheme.Colors.surface)
            .cornerRadius(KHTheme.Radius.lg)
            .shadow(color: KHTheme.Shadow.medium.color, radius: KHTheme.Shadow.medium.radius, x: KHTheme.Shadow.medium.x, y: KHTheme.Shadow.medium.y)
    }
    
    func khButtonPrimary() -> some View {
        self
            .font(KHTheme.Typography.headline())
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(KHTheme.Colors.gradientPrimary)
            .cornerRadius(KHTheme.Radius.pill)
    }
    
    func khButtonSecondary() -> some View {
        self
            .font(KHTheme.Typography.headline())
            .foregroundColor(KHTheme.Colors.primary)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(KHTheme.Colors.primary.opacity(0.1))
            .cornerRadius(KHTheme.Radius.pill)
    }
    
    func khSectionHeader() -> some View {
        self
            .font(KHTheme.Typography.title2())
            .foregroundColor(KHTheme.Colors.textPrimary)
    }
}
