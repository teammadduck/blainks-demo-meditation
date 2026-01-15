import SwiftUI
import Combine

public struct MeditationSessionView: View {
    @StateObject private var viewModel: MeditationSessionViewModel
    @State private var showCompletion = false
    @State private var breathing = false

    public init(viewModel: MeditationSessionViewModel = .init()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.background
                    .ignoresSafeArea()

                VStack(spacing: 32) {
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.theme.secondary.opacity(0.18),
                                        Color.theme.primary.opacity(0.05)
                                    ],
                                    center: .center,
                                    startRadius: 20,
                                    endRadius: 220
                                )
                            )
                            .scaleEffect(breathing ? 1.08 : 0.96)
                            .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: breathing)

                        Circle()
                            .stroke(Color.theme.primary.opacity(0.25), lineWidth: 18)

                        Circle()
                            .trim(from: 0, to: viewModel.progress)
                            .stroke(
                                AngularGradient(
                                    gradient: Gradient(colors: [Color.theme.primary, Color.theme.secondary, Color.theme.accent]),
                                    center: .center
                                ),
                                style: StrokeStyle(lineWidth: 18, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.progress)

                        VStack(spacing: 8) {
                            Text(viewModel.formattedRemaining)
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundColor(.white)

                            Text(viewModel.isPlaying ? "In Progress" : "Paused")
                                .font(.headline)
                                .foregroundColor(Color.theme.accent.opacity(0.85))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 24)

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Session length")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.9))

                        Slider(
                            value: $viewModel.selectedMinutes,
                            in: 5...30,
                            step: 1
                        ) {
                            Text("Session length")
                        } minimumValueLabel: {
                            Text("5m").foregroundColor(.white.opacity(0.7))
                        } maximumValueLabel: {
                            Text("30m").foregroundColor(.white.opacity(0.7))
                        }
                        .tint(Color.theme.accent)
                        .onChange(of: viewModel.selectedMinutes) { newValue in
                            viewModel.setMinutes(newValue)
                        }

                        HStack {
                            Text("Selected: \(Int(viewModel.selectedMinutes)) min")
                                .foregroundColor(.white.opacity(0.8))
                            Spacer()
                            Text("Remaining: \(viewModel.formattedRemaining)")
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .font(.subheadline)
                    }
                    .padding(.horizontal, 24)

                    HStack(spacing: 16) {
                        Button {
                            viewModel.reset()
                        } label: {
                            Label("Reset", systemImage: "gobackward")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(Color.theme.secondary)

                        Button {
                            viewModel.togglePlayPause()
                        } label: {
                            Label(viewModel.isPlaying ? "Pause" : "Play", systemImage: viewModel.isPlaying ? "pause.fill" : "play.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color.theme.primary)
                    }
                    .padding(.horizontal, 24)

                    Spacer()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation(.easeInOut) {
                            viewModel.reset()
                        }
                    } label: {
                        Image(systemName: "stop.circle")
                            .foregroundColor(.white)
                    }
                }
            }
            .navigationTitle("Meditation")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: viewModel.didComplete) { completed in
                if completed {
                    showCompletion = true
                }
            }
            .onAppear {
                breathing = true
            }
            .navigationDestination(isPresented: $showCompletion) {
                SessionCompletedView()
            }
        }
    }
}

public final class MeditationSessionViewModel: ObservableObject {
    @Published public var selectedMinutes: Double
    @Published public private(set) var elapsed: Double
    @Published public private(set) var isPlaying: Bool
    @Published public private(set) var didComplete: Bool

    private var timerCancellable: AnyCancellable?

    public init(selectedMinutes: Double = 10) {
        self.selectedMinutes = selectedMinutes
        self.elapsed = 0
        self.isPlaying = false
        self.didComplete = false
    }

    public func togglePlayPause() {
        isPlaying ? pause() : start()
    }

    public func start() {
        guard !isPlaying else { return }
        didComplete = false
        isPlaying = true
        beginTimer()
    }

    public func pause() {
        isPlaying = false
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    public func reset() {
        pause()
        elapsed = 0
        didComplete = false
    }

    public func setMinutes(_ value: Double) {
        selectedMinutes = value
        if !isPlaying {
            elapsed = 0
            didComplete = false
        }
    }

    public var remaining: Double {
        max(totalSeconds - elapsed, 0)
    }

    public var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return min(elapsed / totalSeconds, 1)
    }

    public var formattedRemaining: String {
        let totalSeconds = Int(remaining)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private var totalSeconds: Double {
        selectedMinutes * 60
    }

    private func beginTimer() {
        timerCancellable?.cancel()
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.handleTick()
            }
    }

    private func handleTick() {
        guard isPlaying else { return }
        let total = totalSeconds
        guard total > 0 else {
            finish()
            return
        }

        if elapsed < total {
            elapsed += 1
        } else {
            finish()
        }
    }

    private func finish() {
        pause()
        didComplete = true
    }
}

public struct SessionCompletedView: View {
    public init() {}

    public var body: some View {
        ZStack {
            Color.theme.background
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Circle()
                    .fill(Color.theme.accent.opacity(0.2))
                    .frame(width: 180, height: 180)
                    .overlay(
                        Image(systemName: "checkmark.seal.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(Color.theme.accent)
                            .padding(40)
                    )

                Text("Session Complete")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text("Take a moment to notice how you feel and carry that calm with you.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 32)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

public extension Color {
    enum theme {
        public static let primary = Color(hex: "#6C63FF")
        public static let secondary = Color(hex: "#7C83FD")
        public static let background = Color(hex: "#0B1224")
        public static let accent = Color(hex: "#5EEAD4")
    }
}
