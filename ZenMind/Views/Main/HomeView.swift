import SwiftUI

public struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    private let destinationBuilder: (HomeViewModel.Destination) -> AnyView

    public init(
        viewModel: HomeViewModel = HomeViewModel(),
        destinationBuilder: @escaping (HomeViewModel.Destination) -> AnyView = HomeView.defaultDestinationBuilder
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.destinationBuilder = destinationBuilder
    }

    public var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    streakSection
                    quickStartSection
                    recommendedSection
                    libraryLinksSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .background(LinearGradient(
                gradient: Gradient(colors: [ColorPalette.background, ColorPalette.background.opacity(0.9)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea())
            .navigationTitle("Dashboard")
#if os(iOS)
            .toolbarBackground(ColorPalette.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
#endif
            .navigationDestination(for: HomeViewModel.Destination.self) { destination in
                destinationBuilder(destination)
            }
        }
    }
}

extension HomeView {
    private var streakSection: some View {
        HomeCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Daily Streak")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.85))
                HStack(alignment: .center, spacing: 16) {
                    Text("\(viewModel.streakDays)")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundColor(ColorPalette.accent)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("days in a row")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                        SwiftUI.ProgressView(value: viewModel.streakProgress)
                            .tint(ColorPalette.primary)
                            .progressViewStyle(.linear)
                        Text("\(Int(viewModel.streakProgress * 100))% toward weekly goal")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
        }
    }

    private var quickStartSection: some View {
        HomeCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Quick Start")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.85))
                Text("Begin a focused \(viewModel.quickStartDuration)-minute session right away.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                Button {
                    viewModel.startQuickSession()
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                            .font(.headline)
                        Text("Start \(viewModel.quickStartDuration) min Timer")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(AccentButtonStyle())
            }
        }
    }

    private var recommendedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recommended for you")
                .font(.headline)
                .foregroundColor(.white.opacity(0.85))
            VStack(spacing: 12) {
                ForEach(viewModel.recommendedMeditations) { meditation in
                    NavigationLink(value: HomeViewModel.Destination.meditationSession(meditation)) {
                        HomeCard {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(meditation.title)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundColor(.white)
                                    Text("\(meditation.duration) min • \(meditation.focus)")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.65))
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(ColorPalette.accent)
                                    .font(.caption.weight(.bold))
                            }
                        }
                    }
                }
            }
        }
    }

    private var libraryLinksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Explore")
                .font(.headline)
                .foregroundColor(.white.opacity(0.85))
            VStack(spacing: 12) {
                NavigationLink(value: HomeViewModel.Destination.library) {
                    HomeCard {
                        linkRow(title: "Library", subtitle: "Browse all meditations", icon: "books.vertical")
                    }
                }
                NavigationLink(value: HomeViewModel.Destination.sleepSounds) {
                    HomeCard {
                        linkRow(title: "Sleep Sounds", subtitle: "Wind down with calming audio", icon: "moon.zzz")
                    }
                }
                NavigationLink(value: HomeViewModel.Destination.progress) {
                    HomeCard {
                        linkRow(title: "Progress", subtitle: "Track your mindfulness journey", icon: "chart.bar.xaxis")
                    }
                }
                NavigationLink(value: HomeViewModel.Destination.paywall) {
                    HomeCard {
                        linkRow(title: "Upgrade", subtitle: "Unlock premium meditations", icon: "star.circle")
                    }
                }
            }
        }
    }

    private func linkRow(title: String, subtitle: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(ColorPalette.accent)
                .frame(width: 32, height: 32)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.65))
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(ColorPalette.accent)
                .font(.caption.weight(.bold))
        }
    }

    public static func defaultDestinationBuilder(destination: HomeViewModel.Destination) -> AnyView {
        switch destination {
        case .meditationSession(let meditation):
            return AnyView(Text("Meditation: \(meditation.title)").foregroundColor(.white))
        case .library:
            return AnyView(Text("Library").foregroundColor(.white))
        case .sleepSounds:
            return AnyView(Text("Sleep Sounds").foregroundColor(.white))
        case .progress:
            return AnyView(Text("Progress").foregroundColor(.white))
        case .paywall:
            return AnyView(Text("Upgrade").foregroundColor(.white))
        }
    }
}

public final class HomeViewModel: ObservableObject {
    public enum Destination: Hashable {
        case meditationSession(MeditationItem)
        case library
        case sleepSounds
        case progress
        case paywall
    }

    @Published public var streakDays: Int
    @Published public var streakProgress: Double
    @Published public var recommendedMeditations: [MeditationItem]
    @Published public var quickStartDuration: Int

    public init(
        streakDays: Int = 5,
        streakProgress: Double = 0.6,
        recommendedMeditations: [MeditationItem] = HomeViewModel.sampleMeditations,
        quickStartDuration: Int = 10
    ) {
        self.streakDays = streakDays
        self.streakProgress = streakProgress
        self.recommendedMeditations = recommendedMeditations
        self.quickStartDuration = quickStartDuration
    }

    public func startQuickSession() {
        // Hook for starting a quick session timer; integrate with real timer logic here.
    }
}

public struct MeditationItem: Identifiable, Hashable {
    public let id: UUID
    public let title: String
    public let duration: Int
    public let focus: String

    public init(id: UUID = UUID(), title: String, duration: Int, focus: String) {
        self.id = id
        self.title = title
        self.duration = duration
        self.focus = focus
    }
}

public struct HomeCard<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
                .padding(16)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(ColorPalette.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}

public struct AccentButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
            .background(
                LinearGradient(
                    colors: [ColorPalette.primary, ColorPalette.secondary],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .foregroundColor(ColorPalette.background)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

public enum ColorPalette {
    public static let primary = Color(hex: "#6C63FF")
    public static let secondary = Color(hex: "#7C83FD")
    public static let background = Color(hex: "#0B1224")
    public static let accent = Color(hex: "#5EEAD4")
    public static let cardBackground = Color.white.opacity(0.04)
}

public extension HomeViewModel {
    static let sampleMeditations: [MeditationItem] = [
        MeditationItem(title: "Morning Focus", duration: 12, focus: "Productivity"),
        MeditationItem(title: "Stress Release", duration: 15, focus: "Calm"),
        MeditationItem(title: "Evening Unwind", duration: 10, focus: "Sleep")
    ]
}
