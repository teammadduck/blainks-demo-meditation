import SwiftUI

public final class AchievementDetailViewModel: ObservableObject {
    @Published public private(set) var progress: Double
    public let title: String
    public let subtitle: String
    public let criteria: [String]
    public let actionButtonTitle: String
    public let ctaDescription: String

    public init(
        title: String,
        subtitle: String,
        criteria: [String],
        progress: Double = 0.0,
        actionButtonTitle: String = "Update Progress",
        ctaDescription: String = "Keep going to reach this achievement."
    ) {
        self.title = title
        self.subtitle = subtitle
        self.criteria = criteria
        self.progress = progress
        self.actionButtonTitle = actionButtonTitle
        self.ctaDescription = ctaDescription
    }

    public var progressText: String {
        let percent = Int((progress * 100).rounded())
        return "\(percent)% complete"
    }

    public func advanceProgress(by value: Double = 0.05) {
        progress = min(1.0, max(0.0, progress + value))
    }
}

public struct AchievementDetailView: View {
    @ObservedObject public var viewModel: AchievementDetailViewModel

    public init(viewModel: AchievementDetailViewModel) {
        self.viewModel = viewModel
    }

    public init(achievement: Achievement) {
        let viewModel = AchievementDetailViewModel(
            title: achievement.title,
            subtitle: achievement.subtitle,
            criteria: [],
            progress: achievement.progress
        )
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                AchievementPalette.background.ignoresSafeArea()
                VStack(alignment: .leading, spacing: 24) {
                    header
                    progressSection
                    criteriaSection
                    actionButtons
                    Spacer()
                }
                .padding(24)
            }
            .navigationTitle("Achievement")
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
        }
        .tint(AchievementPalette.accent)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.title)
                .font(.system(.largeTitle, design: .rounded))
                .fontWeight(.bold)
                .foregroundStyle(AchievementPalette.primary)
            Text(viewModel.subtitle)
                .font(.system(.body, design: .rounded))
                .foregroundStyle(.white.opacity(0.8))
        }
    }

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Progress")
                .font(.system(.title3, design: .rounded))
                .fontWeight(.semibold)
                .foregroundStyle(.white)
            SwiftUI.ProgressView(value: viewModel.progress, total: 1.0)
                .tint(AchievementPalette.accent)
                .progressViewStyle(.linear)
            Text(viewModel.progressText)
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(.white.opacity(0.8))
            Text(viewModel.ctaDescription)
                .font(.system(.callout, design: .rounded))
                .foregroundStyle(AchievementPalette.secondary)
        }
    }

    private var criteriaSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Criteria")
                .font(.system(.title3, design: .rounded))
                .fontWeight(.semibold)
                .foregroundStyle(.white)
            ForEach(viewModel.criteria, id: \.self) { item in
                HStack(alignment: .top, spacing: 8) {
                    Text("•")
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundStyle(AchievementPalette.accent)
                    Text(item)
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(.white.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: { viewModel.advanceProgress() }) {
                Text(viewModel.actionButtonTitle)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(AchievementPrimaryButtonStyle())

            NavigationLink {
                AchievementProgressView(title: viewModel.title, progress: viewModel.progress)
            } label: {
                Text("View Progress Details")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(AchievementSecondaryButtonStyle())
        }
    }
}

public struct AchievementProgressView: View {
    public let title: String
    public let progress: Double

    public init(title: String, progress: Double) {
        self.title = title
        self.progress = progress
    }

    public var body: some View {
        VStack(spacing: 24) {
            Text(title)
                .font(.system(.title, design: .rounded))
                .fontWeight(.bold)
                .foregroundStyle(AchievementPalette.primary)
            SwiftUI.ProgressView(value: progress, total: 1.0)
                .tint(AchievementPalette.accent)
                .progressViewStyle(.linear)
            Text("\(Int((progress * 100).rounded()))% complete")
                .font(.system(.body, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))
            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(AchievementPalette.background.ignoresSafeArea())
        .navigationTitle("Progress")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
    }
}

public struct AchievementPrimaryButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.headline, design: .rounded))
            .fontWeight(.semibold)
            .padding()
            .background(AchievementPalette.primary)
            .foregroundStyle(Color.white)
            .cornerRadius(12)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
    }
}

public struct AchievementSecondaryButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.headline, design: .rounded))
            .fontWeight(.semibold)
            .padding()
            .foregroundStyle(AchievementPalette.accent)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AchievementPalette.accent, lineWidth: 1.5)
            )
            .background(AchievementPalette.background)
            .cornerRadius(12)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
    }
}

private enum AchievementPalette {
    static let primary = Color(red: 108 / 255, green: 99 / 255, blue: 255 / 255)
    static let secondary = Color(red: 124 / 255, green: 131 / 255, blue: 253 / 255)
    static let background = Color(red: 11 / 255, green: 18 / 255, blue: 36 / 255)
    static let accent = Color(red: 94 / 255, green: 234 / 255, blue: 212 / 255)
}
