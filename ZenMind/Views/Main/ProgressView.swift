import SwiftUI
import Charts

public struct ProgressView: View {
    @StateObject private var viewModel: ProgressViewModel

    public init(viewModel: ProgressViewModel = ProgressViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    rangePicker
                    chartSection
                    statGrid
                    achievementsSection
                }
                .padding(20)
            }
            .background(ProgressTheme.background.ignoresSafeArea())
#if os(iOS)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: ProfileView()) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.title2)
                            .foregroundStyle(ProgressTheme.accent)
                    }
                }
            }
#endif
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Progress Overview")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                Text("Track your weekly and monthly achievements.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.72))
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 6) {
                Text("Completion")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.72))
                Text(viewModel.completionRateFormatted)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(ProgressTheme.accent)
                Text("vs last month: \(viewModel.trendText)")
                    .font(.caption)
                    .foregroundStyle(viewModel.trendColor)
            }
        }
    }

    private var rangePicker: some View {
        HStack {
            Text("Insights")
                .font(.title2.bold())
                .foregroundStyle(.white)
            Spacer()
            Picker("Range", selection: $viewModel.selectedRange) {
                ForEach(ProgressRange.allCases) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(.segmented)
            .tint(ProgressTheme.primary)
            .frame(maxWidth: 220)
        }
    }

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(viewModel.selectedRange.rawValue) Activity")
                .font(.headline)
                .foregroundStyle(.white)
            Chart(viewModel.chartData) { item in
                BarMark(
                    x: .value("Period", item.label),
                    y: .value("Progress", item.value)
                )
                .foregroundStyle(LinearGradient(
                    colors: [ProgressTheme.primary, ProgressTheme.secondary],
                    startPoint: .bottom,
                    endPoint: .top)
                )
                LineMark(
                    x: .value("Period", item.label),
                    y: .value("Progress", item.value)
                )
                .interpolationMethod(.cardinal)
                .foregroundStyle(ProgressTheme.accent)
                PointMark(
                    x: .value("Period", item.label),
                    y: .value("Progress", item.value)
                )
                .foregroundStyle(ProgressTheme.accent)
            }
            .frame(height: 220)
            .chartYAxis {
                AxisMarks(preset: .aligned, position: .leading)
            }
            .chartXAxis {
                AxisMarks(values: .automatic)
            }
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(ProgressTheme.cardBackground)
            )
        }
    }

    private var statGrid: some View {
        Grid(horizontalSpacing: 16, verticalSpacing: 16) {
            GridRow {
                StatCard(
                    title: "Weekly Avg",
                    value: viewModel.weeklyAverageFormatted,
                    subtitle: "Tasks completed"
                )
                StatCard(
                    title: "Monthly Avg",
                    value: viewModel.monthlyAverageFormatted,
                    subtitle: "Hours focused"
                )
            }
            GridRow {
                StatCard(
                    title: "Streak",
                    value: "\(viewModel.streak) days",
                    subtitle: "Keep going"
                )
                StatCard(
                    title: "Next Goal",
                    value: viewModel.nextGoal.title,
                    subtitle: viewModel.nextGoal.subtitle
                )
            }
        }
    }

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Achievements")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                NavigationLink("See all") {
                    ProfileView()
                }
                .font(.subheadline.bold())
                .foregroundStyle(ProgressTheme.accent)
            }
            LazyVStack(spacing: 12) {
                ForEach(viewModel.achievements) { achievement in
                    NavigationLink {
                        AchievementDetailView(achievement: achievement)
                    } label: {
                        AchievementCard(achievement: achievement)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

public final class ProgressViewModel: ObservableObject {
    @Published public var selectedRange: ProgressRange = .weekly
    @Published public var weeklyData: [ProgressDataPoint]
    @Published public var monthlyData: [ProgressDataPoint]
    @Published public var achievements: [Achievement]
    @Published public var completionRate: Double
    @Published public var trend: Double
    @Published public var streak: Int
    @Published public var nextGoal: Goal

    public init(
        selectedRange: ProgressRange = .weekly,
        weeklyData: [ProgressDataPoint] = ProgressViewModel.sampleWeekly(),
        monthlyData: [ProgressDataPoint] = ProgressViewModel.sampleMonthly(),
        achievements: [Achievement] = ProgressViewModel.sampleAchievements(),
        completionRate: Double = 0.82,
        trend: Double = 0.06,
        streak: Int = 12,
        nextGoal: Goal = Goal(title: "50 tasks", subtitle: "Complete by Friday")
    ) {
        self.selectedRange = selectedRange
        self.weeklyData = weeklyData
        self.monthlyData = monthlyData
        self.achievements = achievements
        self.completionRate = completionRate
        self.trend = trend
        self.streak = streak
        self.nextGoal = nextGoal
    }

    public var chartData: [ProgressDataPoint] {
        switch selectedRange {
        case .weekly:
            return weeklyData
        case .monthly:
            return monthlyData
        }
    }

    public var completionRateFormatted: String {
        NumberFormatter.percent.string(from: completionRate as NSNumber) ?? "\(Int(completionRate * 100))%"
    }

    public var trendText: String {
        let formatter = NumberFormatter.percent
        let formatted = formatter.string(from: abs(trend) as NSNumber) ?? "\(Int(abs(trend) * 100))%"
        return trend >= 0 ? "+\(formatted)" : "-\(formatted)"
    }

    public var trendColor: Color {
        trend >= 0 ? ProgressTheme.accent : Color.red
    }

    public var weeklyAverageFormatted: String {
        let average = weeklyData.map(\.value).reduce(0, +) / Double(max(weeklyData.count, 1))
        return NumberFormatter.decimal.string(from: average as NSNumber) ?? "\(Int(average))"
    }

    public var monthlyAverageFormatted: String {
        let average = monthlyData.map(\.value).reduce(0, +) / Double(max(monthlyData.count, 1))
        return NumberFormatter.decimal.string(from: average as NSNumber) ?? "\(Int(average))"
    }

    public static func sampleWeekly() -> [ProgressDataPoint] {
        [
            .init(label: "Mon", value: 6),
            .init(label: "Tue", value: 8),
            .init(label: "Wed", value: 7),
            .init(label: "Thu", value: 5),
            .init(label: "Fri", value: 9),
            .init(label: "Sat", value: 4),
            .init(label: "Sun", value: 6)
        ]
    }

    public static func sampleMonthly() -> [ProgressDataPoint] {
        [
            .init(label: "W1", value: 26),
            .init(label: "W2", value: 31),
            .init(label: "W3", value: 28),
            .init(label: "W4", value: 35)
        ]
    }

    public static func sampleAchievements() -> [Achievement] {
        [
            .init(title: "Consistency", subtitle: "7-day streak", progress: 0.9),
            .init(title: "Productivity", subtitle: "40 tasks this month", progress: 0.75),
            .init(title: "Focus Master", subtitle: "15 focused hours", progress: 0.6)
        ]
    }
}

public enum ProgressRange: String, CaseIterable, Identifiable {
    case weekly = "Weekly"
    case monthly = "Monthly"

    public var id: String { rawValue }
}

public struct ProgressDataPoint: Identifiable {
    public let id = UUID()
    public let label: String
    public let value: Double

    public init(label: String, value: Double) {
        self.label = label
        self.value = value
    }
}

public struct Achievement: Identifiable {
    public let id = UUID()
    public let title: String
    public let subtitle: String
    public let progress: Double

    public init(title: String, subtitle: String, progress: Double) {
        self.title = title
        self.subtitle = subtitle
        self.progress = progress
    }
}

public struct Goal {
    public let title: String
    public let subtitle: String

    public init(title: String, subtitle: String) {
        self.title = title
        self.subtitle = subtitle
    }
}

private struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.72))
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(.white)
            Text(subtitle)
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.72))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [ProgressTheme.cardBackground, ProgressTheme.cardBackground.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(ProgressTheme.primary.opacity(0.25))
        )
        .cornerRadius(14)
    }
}

private struct AchievementCard: View {
    let achievement: Achievement

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(ProgressTheme.primary.opacity(0.18))
                    .frame(width: 50, height: 50)
                Image(systemName: "star.fill")
                    .foregroundStyle(ProgressTheme.primary)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text(achievement.subtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.72))
                ProgressViewStyleBar(progress: achievement.progress)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.white.opacity(0.5))
        }
        .padding()
        .background(ProgressTheme.cardBackground)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(ProgressTheme.primary.opacity(0.25))
        )
    }
}

private struct ProgressViewStyleBar: View {
    let progress: Double

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.08))
                Capsule()
                    .fill(LinearGradient(
                        colors: [ProgressTheme.primary, ProgressTheme.secondary],
                        startPoint: .leading,
                        endPoint: .trailing)
                    )
                    .frame(width: proxy.size.width * progress)
            }
        }
        .frame(height: 8)
        .clipShape(Capsule())
    }
}

private enum ProgressTheme {
    static let primary = Color(hex: "#6C63FF")
    static let secondary = Color(hex: "#7C83FD")
    static let background = Color(hex: "#0B1224")
    static let accent = Color(hex: "#5EEAD4")
    static let cardBackground = Color.white.opacity(0.06)
}

private extension NumberFormatter {
    static let percent: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    static let decimal: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        return formatter
    }()
}
