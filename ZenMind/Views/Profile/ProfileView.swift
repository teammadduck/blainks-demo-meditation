import SwiftUI

public struct ProfileView: View {
    @StateObject private var viewModel: ProfileViewModel

    public init(viewModel: ProfileViewModel = ProfileViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                ProfileTheme.background
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    headerSection
                    quickActions
                    historySection
                    sessionsSection
                }
                .padding()
            }
            .navigationTitle("Profile")
        }
    }

    private var headerSection: some View {
        HStack(alignment: .center, spacing: 16) {
            AvatarView(initials: viewModel.profile.initials, size: 72)

            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.profile.name)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                Text(viewModel.profile.tagline)
                    .font(.subheadline)
                    .foregroundStyle(ProfileTheme.accent)

                HStack(spacing: 12) {
                    MetricBadge(title: "Streak", value: "\(viewModel.profile.currentStreak) days")
                    MetricBadge(title: "Minutes", value: "\(viewModel.profile.totalMinutes)")
                }
            }
            Spacer()
        }
    }

    private var quickActions: some View {
        HStack(spacing: 12) {
            NavigationLink(destination: ProgressView()) {
                Label("Progress", systemImage: "chart.line.uptrend.xyaxis")
            }
            .buttonStyle(FilledCapsuleButtonStyle(color: ProfileTheme.primary))

            NavigationLink(destination: SettingsView()) {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .buttonStyle(FilledCapsuleButtonStyle(color: ProfileTheme.secondary))

            Button {
                viewModel.startNewSession()
            } label: {
                Label("Start", systemImage: "play.fill")
            }
            .buttonStyle(FilledCapsuleButtonStyle(color: ProfileTheme.accent))
        }
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Meditation History")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.9))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.recentHistory) { item in
                        HistoryCard(history: item)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    private var sessionsSection: some View {
        List {
            Section(header: Text("Saved Sessions").foregroundStyle(.white.opacity(0.8))) {
                ForEach(viewModel.savedSessions) { session in
                    NavigationLink(
                        destination: MeditationDetailView(
                            viewModel: MeditationDetailViewModel(
                                title: session.title,
                                lengthInMinutes: session.duration,
                                guideName: session.focus,
                                description: "Guided session focused on \(session.focus).",
                                level: .beginner,
                                previewURL: nil,
                                isFavorite: session.isFavorite
                            )
                        )
                    ) {
                        SessionRow(session: session)
                    }
                    .listRowBackground(ProfileTheme.surface)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
        .frame(maxHeight: 340)
    }
}

public final class ProfileViewModel: ObservableObject {
    @Published public var profile: UserProfile
    @Published public var recentHistory: [MeditationHistory]
    @Published public var savedSessions: [MeditationSession]

    public init(
        profile: UserProfile = UserProfile.sample,
        recentHistory: [MeditationHistory] = MeditationHistory.samples,
        savedSessions: [MeditationSession] = MeditationSession.samples
    ) {
        self.profile = profile
        self.recentHistory = recentHistory
        self.savedSessions = savedSessions
    }

    public func startNewSession() {
        // Integrate session start logic with your player/recorder
    }
}

public struct UserProfile {
    public let name: String
    public let tagline: String
    public let currentStreak: Int
    public let totalMinutes: Int

    public init(name: String, tagline: String, currentStreak: Int, totalMinutes: Int) {
        self.name = name
        self.tagline = tagline
        self.currentStreak = currentStreak
        self.totalMinutes = totalMinutes
    }

    public var initials: String {
        let components = name.split(separator: " ")
        let first = components.first?.first.map(String.init) ?? ""
        let last = components.dropFirst().first?.first.map(String.init) ?? ""
        return (first + last).uppercased()
    }

    public static let sample = UserProfile(
        name: "Avery Lee",
        tagline: "Staying mindful every day",
        currentStreak: 12,
        totalMinutes: 186
    )
}

public struct MeditationSession: Identifiable {
    public let id: UUID
    public let title: String
    public let duration: Int
    public let focus: String
    public let isFavorite: Bool

    public init(
        id: UUID = UUID(),
        title: String,
        duration: Int,
        focus: String,
        isFavorite: Bool = false
    ) {
        self.id = id
        self.title = title
        self.duration = duration
        self.focus = focus
        self.isFavorite = isFavorite
    }

    public static let samples: [MeditationSession] = [
        MeditationSession(title: "Morning Calm", duration: 12, focus: "Breathwork", isFavorite: true),
        MeditationSession(title: "Focus Boost", duration: 18, focus: "Productivity"),
        MeditationSession(title: "Evening Unwind", duration: 15, focus: "Relaxation")
    ]
}

public struct MeditationHistory: Identifiable {
    public let id: UUID
    public let title: String
    public let duration: Int
    public let mood: String

    public init(id: UUID = UUID(), title: String, duration: Int, mood: String) {
        self.id = id
        self.title = title
        self.duration = duration
        self.mood = mood
    }

    public static let samples: [MeditationHistory] = [
        MeditationHistory(title: "Sunrise Session", duration: 10, mood: "Centered"),
        MeditationHistory(title: "Midday Reset", duration: 8, mood: "Refreshed"),
        MeditationHistory(title: "Night Reflection", duration: 14, mood: "Calm")
    ]
}

public struct HistoryCard: View {
    public let history: MeditationHistory

    public init(history: MeditationHistory) {
        self.history = history
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(history.title)
                .font(.headline)
                .foregroundStyle(.white)
                .lineLimit(1)
            Text("\(history.duration) min • \(history.mood)")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding()
        .background(
            LinearGradient(
                colors: [ProfileTheme.primary.opacity(0.9), ProfileTheme.secondary.opacity(0.9)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

public struct SessionRow: View {
    public let session: MeditationSession

    public init(session: MeditationSession) {
        self.session = session
    }

    public var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(ProfileTheme.accent.opacity(0.2))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: session.isFavorite ? "heart.fill" : "leaf.fill")
                        .font(.headline)
                        .foregroundStyle(session.isFavorite ? .pink : ProfileTheme.accent)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(session.title)
                    .foregroundStyle(.white)
                    .font(.headline)
                Text("\(session.duration) min • \(session.focus)")
                    .foregroundStyle(.white.opacity(0.7))
                    .font(.subheadline)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.white.opacity(0.6))
        }
        .padding(.vertical, 6)
    }
}

public struct MetricBadge: View {
    public let title: String
    public let value: String

    public init(title: String, value: String) {
        self.title = title
        self.value = value
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title.uppercased())
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.7))
            Text(value)
                .font(.subheadline.bold())
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(ProfileTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

public struct AvatarView: View {
    public let initials: String
    public let size: CGFloat

    public init(initials: String, size: CGFloat = 64) {
        self.initials = initials
        self.size = size
    }

    public var body: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [ProfileTheme.primary, ProfileTheme.secondary],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: size, height: size)
            .overlay(
                Text(initials)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
            )
            .overlay(
                Circle()
                    .stroke(ProfileTheme.accent, lineWidth: 3)
                    .opacity(0.8)
            )
            .shadow(color: ProfileTheme.primary.opacity(0.4), radius: 8, x: 0, y: 6)
    }
}

public struct FilledCapsuleButtonStyle: ButtonStyle {
    public let color: Color

    public init(color: Color) {
        self.color = color
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.bold())
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(color.opacity(configuration.isPressed ? 0.7 : 1.0))
            .clipShape(Capsule())
            .shadow(color: color.opacity(0.35), radius: 8, x: 0, y: 6)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

public enum ProfileTheme {
    public static let primary = Color(red: 108 / 255, green: 99 / 255, blue: 255 / 255)
    public static let secondary = Color(red: 124 / 255, green: 131 / 255, blue: 253 / 255)
    public static let background = Color(red: 11 / 255, green: 18 / 255, blue: 36 / 255)
    public static let accent = Color(red: 94 / 255, green: 234 / 255, blue: 212 / 255)
    public static let surface = Color.white.opacity(0.06)
}

// Placeholder destinations. Replace with app-specific screens.

#if DEBUG
public struct ProfileView_Previews: PreviewProvider {
    public init() {}

    public static var previews: some View {
        ProfileView()
            .preferredColorScheme(.dark)
    }
}
#endif
