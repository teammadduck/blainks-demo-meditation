import SwiftUI

public struct SleepSoundsView: View {
    @StateObject private var viewModel = SleepSoundsViewModel()
    private let theme = SleepSoundsTheme()

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                theme.background
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    header
                    soundList
                    PlayerControls(
                        isPlaying: viewModel.isPlaying,
                        onPlay: viewModel.play,
                        onPause: viewModel.pause,
                        onStop: viewModel.stop,
                        theme: theme
                    )
                    paywallLink
                }
                .padding()
            }
            .navigationTitle("Sleep Sounds")
#if os(iOS)
            .toolbarColorScheme(.dark, for: .navigationBar)
#endif
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text("Mix ambient sounds to relax and fall asleep.")
                .font(.subheadline)
                .foregroundStyle(theme.accent)

            Text("Fine-tune rain, ocean, forest, and white noise to create your ideal sleep environment.")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal)
    }

    private var soundList: some View {
        List {
            ForEach(viewModel.sounds) { sound in
                SleepSoundRow(
                    sound: sound,
                    isEnabled: viewModel.isEnabled(sound),
                    volume: viewModel.volume(for: sound),
                    onToggle: { isOn in viewModel.setEnabled(isOn, for: sound) },
                    onVolumeChange: { value in viewModel.setVolume(value, for: sound) },
                    theme: theme
                )
                .listRowBackground(theme.card)
            }
        }
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
        .cornerRadius(12)
    }

    private var paywallLink: some View {
        NavigationLink {
            PaywallView()
        } label: {
            Text("Unlock More Sounds")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(theme.primary)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
}

public final class SleepSoundsViewModel: ObservableObject {
    @Published private(set) var sounds: [SleepSound]
    @Published var activeStates: [UUID: SleepSoundState]
    @Published var isPlaying: Bool

    public init() {
        let defaults = [
            SleepSound(name: "Rain", systemIcon: "cloud.rain"),
            SleepSound(name: "Ocean", systemIcon: "water.waves"),
            SleepSound(name: "Forest", systemIcon: "tree"),
            SleepSound(name: "White Noise", systemIcon: "waveform")
        ]

        self.sounds = defaults
        self.activeStates = Dictionary(
            uniqueKeysWithValues: defaults.map { ($0.id, SleepSoundState(isEnabled: false, volume: 0.6)) }
        )
        self.isPlaying = false
    }

    public func isEnabled(_ sound: SleepSound) -> Bool {
        activeStates[sound.id]?.isEnabled ?? false
    }

    public func volume(for sound: SleepSound) -> Double {
        activeStates[sound.id]?.volume ?? 0.6
    }

    public func setEnabled(_ isEnabled: Bool, for sound: SleepSound) {
        var state = activeStates[sound.id] ?? SleepSoundState(isEnabled: false, volume: 0.6)
        state.isEnabled = isEnabled
        activeStates[sound.id] = state

        if !activeStates.values.contains(where: { $0.isEnabled }) {
            isPlaying = false
        }
    }

    public func setVolume(_ volume: Double, for sound: SleepSound) {
        var state = activeStates[sound.id] ?? SleepSoundState(isEnabled: false, volume: volume)
        state.volume = volume
        activeStates[sound.id] = state
    }

    public func play() {
        guard activeStates.values.contains(where: { $0.isEnabled }) else { return }
        isPlaying = true
    }

    public func pause() {
        isPlaying = false
    }

    public func stop() {
        isPlaying = false
        activeStates = Dictionary(
            uniqueKeysWithValues: sounds.map { ($0.id, SleepSoundState(isEnabled: false, volume: 0.6)) }
        )
    }
}

public struct SleepSound: Identifiable, Hashable {
    public let id: UUID
    public let name: String
    public let systemIcon: String

    public init(id: UUID = UUID(), name: String, systemIcon: String) {
        self.id = id
        self.name = name
        self.systemIcon = systemIcon
    }
}

public struct SleepSoundState: Equatable {
    public var isEnabled: Bool
    public var volume: Double

    public init(isEnabled: Bool, volume: Double) {
        self.isEnabled = isEnabled
        self.volume = volume
    }
}

public struct SleepSoundRow: View {
    public let sound: SleepSound
    public let isEnabled: Bool
    public let volume: Double
    public let onToggle: (Bool) -> Void
    public let onVolumeChange: (Double) -> Void
    public let theme: SleepSoundsTheme

    public init(
        sound: SleepSound,
        isEnabled: Bool,
        volume: Double,
        onToggle: @escaping (Bool) -> Void,
        onVolumeChange: @escaping (Double) -> Void,
        theme: SleepSoundsTheme
    ) {
        self.sound = sound
        self.isEnabled = isEnabled
        self.volume = volume
        self.onToggle = onToggle
        self.onVolumeChange = onVolumeChange
        self.theme = theme
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label(sound.name, systemImage: sound.systemIcon)
                    .foregroundStyle(.white)
                Spacer()
                Toggle("", isOn: Binding(
                    get: { isEnabled },
                    set: onToggle
                ))
                .toggleStyle(SwitchToggleStyle(tint: theme.primary))
            }

            Slider(value: Binding(
                get: { volume },
                set: onVolumeChange
            ), in: 0...1)
            .accentColor(theme.accent)
        }
        .padding(.vertical, 6)
    }
}

public struct PlayerControls: View {
    public let isPlaying: Bool
    public let onPlay: () -> Void
    public let onPause: () -> Void
    public let onStop: () -> Void
    public let theme: SleepSoundsTheme

    public init(
        isPlaying: Bool,
        onPlay: @escaping () -> Void,
        onPause: @escaping () -> Void,
        onStop: @escaping () -> Void,
        theme: SleepSoundsTheme
    ) {
        self.isPlaying = isPlaying
        self.onPlay = onPlay
        self.onPause = onPause
        self.onStop = onStop
        self.theme = theme
    }

    public var body: some View {
        HStack(spacing: 16) {
            ControlButton(
                icon: "backward.end.fill",
                label: "Reset",
                action: onStop,
                color: theme.secondary
            )

            ControlButton(
                icon: isPlaying ? "pause.fill" : "play.fill",
                label: isPlaying ? "Pause" : "Play",
                action: isPlaying ? onPause : onPlay,
                color: theme.primary
            )

            ControlButton(
                icon: "stop.fill",
                label: "Stop",
                action: onStop,
                color: theme.accent
            )
        }
    }
}

public struct ControlButton: View {
    public let icon: String
    public let label: String
    public let action: () -> Void
    public let color: Color

    public init(icon: String, label: String, action: @escaping () -> Void, color: Color) {
        self.icon = icon
        self.label = label
        self.action = action
        self.color = color
    }

    public var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(label)
            }
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
        .shadow(color: color.opacity(0.35), radius: 10, x: 0, y: 6)
    }
}

public struct SleepSoundsTheme: Equatable {
    public let primary: Color
    public let secondary: Color
    public let background: Color
    public let accent: Color
    public let card: Color

    public init(
        primary: Color = Color(hex: "#6C63FF"),
        secondary: Color = Color(hex: "#7C83FD"),
        background: Color = Color(hex: "#0B1224"),
        accent: Color = Color(hex: "#5EEAD4")
    ) {
        self.primary = primary
        self.secondary = secondary
        self.background = background
        self.accent = accent
        self.card = Color.white.opacity(0.06)
    }
}
