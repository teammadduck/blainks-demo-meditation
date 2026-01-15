import SwiftUI

public struct OnboardingBenefitsView: View {
    @StateObject private var viewModel: OnboardingBenefitsViewModel
    @State private var selectedIndex: Int = 0

    public init(viewModel: OnboardingBenefitsViewModel = OnboardingBenefitsViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()
                VStack(spacing: 28) {
                    header
                    benefitsPager
                    pageIndicator
                    NavigationLink(destination: OnboardingGetStartedView()) {
                        Text("Continue")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(theme.primary)
                            .foregroundColor(theme.background)
                            .cornerRadius(14)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
            }
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text("Better Sleep & Focus")
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundColor(.white)

            Text("Discover how consistent routines unlock calmer nights and sharper days.")
                .font(.system(.body, design: .rounded))
                .foregroundColor(.white.opacity(0.76))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private var benefitsPager: some View {
        TabView(selection: $selectedIndex) {
            ForEach(Array(viewModel.benefits.enumerated()), id: \.offset) { index, benefit in
                VStack(spacing: 16) {
                    Image(systemName: benefit.systemImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .foregroundColor(theme.accent)
                        .padding(18)
                        .background(theme.primary.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: 22))

                    Text(benefit.title)
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .foregroundColor(.white)

                    Text(benefit.subtitle)
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.white.opacity(0.78))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 12)
                }
                .padding(.vertical, 8)
                .tag(index)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 320)
#if os(iOS)
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
#endif
        .tint(theme.accent)
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(Array(viewModel.benefits.indices), id: \.self) { index in
                Circle()
                    .fill(index == selectedIndex ? theme.accent : .white.opacity(0.28))
                    .frame(width: index == selectedIndex ? 12 : 8, height: index == selectedIndex ? 12 : 8)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: selectedIndex)
    }

    private var theme: OnboardingTheme {
        .init(
            primary: Color(red: 0x6C / 255, green: 0x63 / 255, blue: 0xFF / 255),
            secondary: Color(red: 0x7C / 255, green: 0x83 / 255, blue: 0xFD / 255),
            background: Color(red: 0x0B / 255, green: 0x12 / 255, blue: 0x24 / 255),
            accent: Color(red: 0x5E / 255, green: 0xEA / 255, blue: 0xD4 / 255)
        )
    }
}

public struct OnboardingTheme {
    public let primary: Color
    public let secondary: Color
    public let background: Color
    public let accent: Color

    public init(primary: Color, secondary: Color, background: Color, accent: Color) {
        self.primary = primary
        self.secondary = secondary
        self.background = background
        self.accent = accent
    }
}

public final class OnboardingBenefitsViewModel: ObservableObject {
    @Published public var benefits: [Benefit]

    public init(benefits: [Benefit] = OnboardingBenefitsViewModel.defaultBenefits) {
        self.benefits = benefits
    }

    public static let defaultBenefits: [Benefit] = [
        Benefit(
            title: "Fall Asleep Faster",
            subtitle: "Wind down with guided breathing so your mind is ready to rest.",
            systemImage: "moon.zzz.fill"
        ),
        Benefit(
            title: "Stay Focused Longer",
            subtitle: "Use focused sessions to ship work without distractions.",
            systemImage: "target"
        ),
        Benefit(
            title: "Wake Up Energized",
            subtitle: "Morning check-ins align your day with what matters most.",
            systemImage: "sun.max.fill"
        )
    ]
}

public struct Benefit: Identifiable, Hashable {
    public let id: UUID
    public let title: String
    public let subtitle: String
    public let systemImage: String

    public init(id: UUID = UUID(), title: String, subtitle: String, systemImage: String) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
    }
}
