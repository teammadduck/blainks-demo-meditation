import SwiftUI

// MARK: - ViewModel

public final class OnboardingGetStartedViewModel: ObservableObject {
    @Published public var selectedIndex: Int
    public let slides: [OnboardingSlide]

    public init(
        slides: [OnboardingSlide] = OnboardingSlide.defaults,
        selectedIndex: Int = 0
    ) {
        self.slides = slides
        self.selectedIndex = selectedIndex
    }
}

// MARK: - Models

public struct OnboardingSlide: Identifiable, Hashable {
    public let id: UUID
    public let title: String
    public let subtitle: String
    public let imageSystemName: String

    public init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        imageSystemName: String
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.imageSystemName = imageSystemName
    }

    public static let defaults: [OnboardingSlide] = [
        OnboardingSlide(
            title: "Stay Connected",
            subtitle: "Keep track of your progress and stay in sync across all devices.",
            imageSystemName: "dot.radiowaves.left.and.right"
        ),
        OnboardingSlide(
            title: "Organize Effortlessly",
            subtitle: "Create an account to unlock personalized insights and reminders.",
            imageSystemName: "tray.full"
        ),
        OnboardingSlide(
            title: "Secure & Private",
            subtitle: "Your data stays encrypted and safe with industry-leading standards.",
            imageSystemName: "lock.shield"
        )
    ]
}

// MARK: - View

public struct OnboardingGetStartedView: View {
    @StateObject private var viewModel: OnboardingGetStartedViewModel

    public init(viewModel: OnboardingGetStartedViewModel = OnboardingGetStartedViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color.themeBackground
                    .ignoresSafeArea()

                VStack(spacing: 32) {
                    Spacer().frame(height: 12)
                    onboardingCarousel
                    pageIndicators
                    callToAction
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
            }
        }
    }

    private var onboardingCarousel: some View {
        TabView(selection: $viewModel.selectedIndex) {
            ForEach(Array(viewModel.slides.enumerated()), id: \.element.id) { index, slide in
                VStack(spacing: 20) {
                    Image(systemName: slide.imageSystemName)
                        .font(.system(size: 64, weight: .regular))
                        .foregroundStyle(Color.themeAccent)
                        .padding()
                        .background(
                            Circle()
                                .fill(Color.themePrimary.opacity(0.12))
                        )

                    Text(slide.title)
                        .foregroundStyle(Color.white)
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .multilineTextAlignment(.center)

                    Text(slide.subtitle)
                        .foregroundStyle(Color.white.opacity(0.75))
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 8)
                }
                .padding(.horizontal, 12)
                .tag(index)
            }
        }
#if os(iOS)
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .never))
#endif
        .frame(maxWidth: .infinity, maxHeight: 360)
    }

    private var pageIndicators: some View {
        HStack(spacing: 10) {
            ForEach(viewModel.slides.indices, id: \.self) { index in
                Capsule()
                    .fill(index == viewModel.selectedIndex ? Color.themePrimary : Color.white.opacity(0.25))
                    .frame(width: index == viewModel.selectedIndex ? 26 : 12, height: 6)
                    .animation(.easeInOut(duration: 0.2), value: viewModel.selectedIndex)
            }
        }
        .padding(.top, 6)
    }

    private var callToAction: some View {
        VStack(spacing: 16) {
            NavigationLink {
                SignupView()
            } label: {
                Text("Create Account")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [Color.themePrimary, Color.themeSecondary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)

            NavigationLink {
                LoginView()
            } label: {
                HStack(spacing: 6) {
                    Text("Already have an account?")
                        .foregroundStyle(Color.white.opacity(0.8))
                    Text("Log In")
                        .foregroundStyle(Color.themeAccent)
                        .fontWeight(.semibold)
                }
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Color Theme

public extension Color {
    static let themePrimary: Color = Color(hex: "#6C63FF")
    static let themeSecondary: Color = Color(hex: "#7C83FD")
    static let themeBackground: Color = Color(hex: "#0B1224")
    static let themeAccent: Color = Color(hex: "#5EEAD4")
}
