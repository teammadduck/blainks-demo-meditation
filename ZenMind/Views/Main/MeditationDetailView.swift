import SwiftUI
import AVFoundation

public struct MeditationDetailView: View {
    @StateObject private var viewModel: MeditationDetailViewModel

    public init(viewModel: MeditationDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [MeditationTheme.background.opacity(0.95), MeditationTheme.background],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        headerSection
                        tagsSection
                        descriptionSection
                        AudioPlayer(viewModel: viewModel)
                        actionButtons
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Meditation")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.title)
                .font(.largeTitle).bold()
                .foregroundColor(.white)

            Text("Guided by \(viewModel.guideName)")
                .font(.subheadline)
                .foregroundColor(MeditationTheme.mutedText)
        }
    }

    private var tagsSection: some View {
        HStack(spacing: 12) {
            TagView(text: "\(viewModel.lengthInMinutes) min", color: MeditationTheme.primary.opacity(0.75))
            TagView(text: viewModel.levelDisplay, color: MeditationTheme.secondary.opacity(0.75))
            TagView(text: "Guide: \(viewModel.guideName)", color: MeditationTheme.accent.opacity(0.8))
        }
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Overview")
                .font(.headline)
                .foregroundColor(.white)
            Text(viewModel.description)
                .font(.body)
                .foregroundColor(MeditationTheme.mutedText)
        }
    }

    private var actionButtons: some View {
        VStack(alignment: .leading, spacing: 12) {
            NavigationLink {
                MeditationSessionView(title: viewModel.title, guide: viewModel.guideName, lengthInMinutes: viewModel.lengthInMinutes)
            } label: {
                Text("Start Session")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(MeditationTheme.primary)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }

            NavigationLink {
                PaywallView()
            } label: {
                Text("Unlock More With Premium")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(MeditationTheme.secondary.opacity(0.85))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }

            Button {
                viewModel.toggleFavorite()
            } label: {
                HStack {
                    Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                    Text(viewModel.isFavorite ? "Saved to Favorites" : "Save to Favorites")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(MeditationTheme.accent.opacity(0.25))
                .foregroundColor(MeditationTheme.accent)
                .cornerRadius(12)
            }
        }
    }
}

public final class MeditationDetailViewModel: ObservableObject {
    @Published public var isFavorite: Bool
    @Published public var isPreviewPlaying: Bool = false
    @Published public var previewProgress: Double = 0

    public let title: String
    public let lengthInMinutes: Int
    public let guideName: String
    public let description: String
    public let level: Level
    public let previewURL: URL?

    private var player: AVPlayer?
    private var timeObserver: Any?

    public init(
        title: String,
        lengthInMinutes: Int,
        guideName: String,
        description: String,
        level: Level = .beginner,
        previewURL: URL?,
        isFavorite: Bool = false
    ) {
        self.title = title
        self.lengthInMinutes = lengthInMinutes
        self.guideName = guideName
        self.description = description
        self.level = level
        self.previewURL = previewURL
        self.isFavorite = isFavorite
        if let previewURL {
            configurePlayer(with: previewURL)
        }
    }

    deinit {
        cleanupPlayer()
    }

    public func toggleFavorite() {
        isFavorite.toggle()
    }

    @MainActor
    public func togglePreview() {
        guard let player else {
            return
        }
        if isPreviewPlaying {
            player.pause()
            isPreviewPlaying = false
        } else {
            player.play()
            isPreviewPlaying = true
        }
    }

    public var levelDisplay: String {
        switch level {
        case .beginner: return "Beginner"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        }
    }

    private func configurePlayer(with url: URL) {
        player = AVPlayer(url: url)
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.updateProgress(with: time)
        }
    }

    private func updateProgress(with time: CMTime) {
        guard let duration = player?.currentItem?.duration.seconds, duration > 0 else {
            previewProgress = 0
            return
        }
        let current = time.seconds
        previewProgress = min(max(current / duration, 0), 1)
        if previewProgress >= 1 {
            isPreviewPlaying = false
        }
    }

    private func cleanupPlayer() {
        if let timeObserver {
            player?.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
        player = nil
    }

    public enum Level {
        case beginner
        case intermediate
        case advanced
    }
}

public struct AudioPlayer: View {
    @ObservedObject private var viewModel: MeditationDetailViewModel

    public init(viewModel: MeditationDetailViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Preview")
                .font(.headline)
                .foregroundColor(.white)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(MeditationTheme.mutedText.opacity(0.2))
                    .frame(height: 8)
                Capsule()
                    .fill(MeditationTheme.accent)
                    .frame(width: progressWidth(), height: 8)
            }
            .frame(maxWidth: .infinity)

            Button {
                viewModel.togglePreview()
            } label: {
                HStack {
                    Image(systemName: viewModel.isPreviewPlaying ? "pause.fill" : "play.fill")
                    Text(viewModel.isPreviewPlaying ? "Pause Preview" : "Play Preview")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(MeditationTheme.accent.opacity(0.2))
                .foregroundColor(MeditationTheme.accent)
                .cornerRadius(12)
            }
            .disabled(viewModel.previewURL == nil)
            .opacity(viewModel.previewURL == nil ? 0.6 : 1.0)

            if viewModel.previewURL == nil {
                Text("Preview unavailable for this session.")
                    .font(.footnote)
                    .foregroundColor(MeditationTheme.mutedText)
            }
        }
    }

    private func progressWidth() -> CGFloat {
        CGFloat(viewModel.previewProgress) * UIScreen.main.bounds.width * 0.9
    }
}

public struct TagView: View {
    private let text: String
    private let color: Color

    public init(text: String, color: Color) {
        self.text = text
        self.color = color
    }

    public var body: some View {
        Text(text)
            .font(.footnote).bold()
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .clipShape(Capsule())
    }
}

public struct MeditationSessionView: View {
    private let title: String
    private let guide: String
    private let lengthInMinutes: Int

    public init(title: String, guide: String, lengthInMinutes: Int) {
        self.title = title
        self.guide = guide
        self.lengthInMinutes = lengthInMinutes
    }

    public var body: some View {
        VStack(spacing: 12) {
            Text(title).font(.title).bold()
            Text("Guide: \(guide)").font(.subheadline)
            Text("Length: \(lengthInMinutes) minutes").font(.subheadline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(MeditationTheme.background.ignoresSafeArea())
        .foregroundColor(.white)
        .navigationTitle("Session")
    }
}

public enum MeditationTheme {
    public static let primary = Color(hex: "#6C63FF")
    public static let secondary = Color(hex: "#7C83FD")
    public static let background = Color(hex: "#0B1224")
    public static let accent = Color(hex: "#5EEAD4")
    public static let mutedText = Color.white.opacity(0.7)
}
