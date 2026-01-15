import SwiftUI

public final class SessionCompletedViewModel: ObservableObject {
    @Published public var sessionTitle: String
    @Published public var completionMessage: String
    @Published public var streakCount: Int
    @Published public var bestStreak: Int
    @Published public var duration: TimeInterval
    @Published public var pointsEarned: Int?
    @Published public var shareMessage: String
    @Published public var isConfettiActive: Bool

    public init(
        sessionTitle: String = "Session Completed",
        completionMessage: String = "Great job finishing today's session.",
        streakCount: Int = 0,
        bestStreak: Int = 0,
        duration: TimeInterval = 0,
        pointsEarned: Int? = nil,
        shareMessage: String? = nil,
        isConfettiActive: Bool = true
    ) {
        self.sessionTitle = sessionTitle
        self.completionMessage = completionMessage
        self.streakCount = streakCount
        self.bestStreak = bestStreak
        self.duration = duration
        self.pointsEarned = pointsEarned
        self.shareMessage = shareMessage ?? "I just wrapped up a session! Current streak: \(streakCount) days."
        self.isConfettiActive = isConfettiActive
    }

    public var durationText: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02dm %02ds", minutes, seconds)
    }

    public var streakHeadline: String {
        streakCount > 0 ? "Streak Extended" : "Streak Started"
    }
}

public struct SessionCompletedView: View {
    @StateObject private var viewModel: SessionCompletedViewModel
    @State private var navigationPath = NavigationPath()

    public init(viewModel: SessionCompletedViewModel = SessionCompletedViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "#0B1224"), Color(hex: "#0B1224").opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                if viewModel.isConfettiActive {
                    ConfettiView()
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }

                VStack(spacing: 24) {
                    headerSection
                    streakSection
                    summarySection
                    shareSection
                    actionButtons
                }
                .padding(24)
            }
            .navigationDestination(for: Destination.self) { destination in
                switch destination {
                case .home:
                    HomeView()
                case .progress:
                    ProgressView()
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text(viewModel.sessionTitle)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)

            Text(viewModel.completionMessage)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
    }

    private var streakSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(viewModel.streakHeadline)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(hex: "#6C63FF"))

            HStack(spacing: 16) {
                streakCard(title: "Current Streak", value: "\(viewModel.streakCount)d")
                streakCard(title: "Best Streak", value: "\(viewModel.bestStreak)d")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func streakCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.white.opacity(0.7))
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Session Summary")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)

            HStack(spacing: 16) {
                summaryItem(title: "Duration", value: viewModel.durationText)
                if let points = viewModel.pointsEarned {
                    summaryItem(title: "Points", value: "+\(points)")
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color(hex: "#7C83FD").opacity(0.4), lineWidth: 1)
                )
        )
    }

    private func summaryItem(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color.white.opacity(0.6))
            Text(value)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(hex: "#5EEAD4"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var shareSection: some View {
        ShareLink(item: viewModel.shareMessage) {
            HStack(spacing: 12) {
                Image(systemName: "square.and.arrow.up")
                Text("Share your progress")
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(hex: "#7C83FD"))
            )
        }
        .buttonStyle(.plain)
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                navigationPath.append(Destination.progress)
            } label: {
                Text("View Progress")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())

            Button {
                navigationPath.append(Destination.home)
            } label: {
                Text("Back to Home")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(SecondaryButtonStyle())
        }
    }

    private enum Destination: Hashable {
        case home
        case progress
    }
}

public struct PrimaryButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(hex: "#6C63FF"))
            )
            .foregroundColor(.white)
            .opacity(configuration.isPressed ? 0.8 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

public struct SecondaryButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.white.opacity(0.06))
                    )
            )
            .foregroundColor(.white)
            .opacity(configuration.isPressed ? 0.8 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

public struct ConfettiView: View {
    public init() {}

    public var body: some View {
        Color.clear
    }
}
