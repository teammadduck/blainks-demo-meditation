import SwiftUI

public struct OnboardingIntroView: View {
    @StateObject private var viewModel: OnboardingIntroViewModel

    public init(viewModel: OnboardingIntroViewModel = OnboardingIntroViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                background
                VStack(alignment: .leading, spacing: 24) {
                    header
                    TabView(selection: $viewModel.selectedIndex) {
                        ForEach(Array(viewModel.slides.enumerated()), id: \.element.id) { index, slide in
                            slideCard(for: slide)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))

                    indicatorRow

                    NavigationLink(destination: OnboardingBenefitsView()) {
                        actionButton
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var background: some View {
        LinearGradient(
            colors: [Color(hex: "#0B1224"), Color(hex: "#0B1224").opacity(0.85)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 40))
                .foregroundStyle(Color(hex: "#5EEAD4"))
                .padding(12)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            Circle()
                                .stroke(Color(hex: "#5EEAD4").opacity(0.3), lineWidth: 1)
                        )
                )

            Text("Welcome to ZenMind")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(Color.white)

            Text("Daily calm, mindful routines, and gentle reminders to breathe.")
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func slideCard(for slide: IntroSlide) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: slide.iconName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color(hex: "#5EEAD4"))
                    .frame(width: 40, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.white.opacity(0.08))
                    )

                Text(slide.title)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.white)
            }

            Text(slide.subtitle)
                .font(.system(size: 16))
                .foregroundStyle(Color.white.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(LinearGradient(
                            colors: [Color(hex: "#6C63FF").opacity(0.5), Color(hex: "#7C83FD").opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ), lineWidth: 1)
                )
        )
    }

    private var indicatorRow: some View {
        HStack(spacing: 10) {
            ForEach(viewModel.slides.indices, id: \.self) { index in
                Capsule()
                    .fill(index == viewModel.selectedIndex ? Color(hex: "#6C63FF") : Color.white.opacity(0.2))
                    .frame(width: index == viewModel.selectedIndex ? 24 : 10, height: 6)
                    .animation(.easeInOut(duration: 0.25), value: viewModel.selectedIndex)
                    .onTapGesture {
                        viewModel.selectedIndex = index
                    }
            }
            Spacer()
        }
    }

    private var actionButton: some View {
        Text("Continue")
            .font(.system(size: 17, weight: .bold))
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color(hex: "#6C63FF"), Color(hex: "#7C83FD")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
            .shadow(color: Color(hex: "#6C63FF").opacity(0.35), radius: 16, x: 0, y: 10)
    }
}

public final class OnboardingIntroViewModel: ObservableObject {
    @Published public var slides: [IntroSlide]
    @Published public var selectedIndex: Int

    public init(
        slides: [IntroSlide] = [
            IntroSlide(
                title: "Set your tone",
                subtitle: "Start each day with a moment of quiet to center your mind.",
                iconName: "sun.and.horizon.fill"
            ),
            IntroSlide(
                title: "Gentle reminders",
                subtitle: "Timely nudges keep you grounded when the day gets busy.",
                iconName: "bell.badge.fill"
            ),
            IntroSlide(
                title: "Restful nights",
                subtitle: "Wind down with soft guidance that prepares you for deep sleep.",
                iconName: "moon.zzz.fill"
            )
        ],
        selectedIndex: Int = 0
    ) {
        self.slides = slides
        self.selectedIndex = selectedIndex
    }
}

public struct IntroSlide: Identifiable, Hashable {
    public let id: UUID
    public let title: String
    public let subtitle: String
    public let iconName: String

    public init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        iconName: String
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.iconName = iconName
    }
}
