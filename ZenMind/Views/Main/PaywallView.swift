import SwiftUI

public final class PaywallViewModel: ObservableObject {
    @Published public var selectedPlan: SubscriptionPlan?
    @Published public var isPresentingSheet: Bool = false
    public let features: [Feature]
    public let plans: [SubscriptionPlan]

    public init(
        features: [Feature] = Feature.defaultFeatures,
        plans: [SubscriptionPlan] = SubscriptionPlan.defaultPlans
    ) {
        self.features = features
        self.plans = plans
    }

    public func select(plan: SubscriptionPlan) {
        selectedPlan = plan
        isPresentingSheet = true
    }
}

public struct Feature: Identifiable {
    public let id: UUID
    public let title: String
    public let subtitle: String
    public let icon: String

    public init(id: UUID = UUID(), title: String, subtitle: String, icon: String) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
    }

    public static let defaultFeatures: [Feature] = [
        Feature(title: "Unlimited Access", subtitle: "All premium content unlocked", icon: "infinity"),
        Feature(title: "Real-time Sync", subtitle: "Devices stay perfectly in sync", icon: "arrow.triangle.2.circlepath"),
        Feature(title: "Priority Support", subtitle: "24/7 expert assistance", icon: "bolt.fill"),
        Feature(title: "Offline Mode", subtitle: "Work without a connection", icon: "wifi.slash")
    ]
}

public struct SubscriptionPlan: Identifiable {
    public let id: UUID
    public let name: String
    public let price: String
    public let frequency: String
    public let badge: String?

    public init(
        id: UUID = UUID(),
        name: String,
        price: String,
        frequency: String,
        badge: String? = nil
    ) {
        self.id = id
        self.name = name
        self.price = price
        self.frequency = frequency
        self.badge = badge
    }

    public static let defaultPlans: [SubscriptionPlan] = [
        SubscriptionPlan(name: "Monthly", price: "$7.99", frequency: "per month"),
        SubscriptionPlan(name: "Yearly", price: "$59.99", frequency: "per year", badge: "Best Value")
    ]
}

public struct PaywallView: View {
    @StateObject private var viewModel: PaywallViewModel
    private let palette = Palette()

    public init(viewModel: PaywallViewModel = PaywallViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                palette.background
                    .ignoresSafeArea()
                VStack(spacing: 24) {
                    header
                    planSelector
                    featureList
                    primaryCTA
                    navigationLinks
                }
                .padding()
            }
            .navigationTitle("Premium")
        }
        .sheet(isPresented: $viewModel.isPresentingSheet) {
            if let plan = viewModel.selectedPlan {
                PlanDetailSheet(plan: plan)
                    .presentationDetents([.fraction(0.35), .medium])
            }
        }
    }

    private var header: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 48, weight: .semibold))
                .foregroundStyle(palette.accent)
            Text("Upgrade to Premium")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)
            Text("Unlock all tools, faster performance, and exclusive perks.")
                .font(.callout)
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            LinearGradient(
                colors: [palette.primary, palette.secondary.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .opacity(0.25)
            .blur(radius: 6)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(palette.primary.opacity(0.25), lineWidth: 1)
        )
        .cornerRadius(20)
    }

    private var planSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Choose your plan")
                .font(.headline)
                .foregroundStyle(.white)
            ForEach(viewModel.plans) { plan in
                Button {
                    viewModel.select(plan: plan)
                } label: {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(plan.name)
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                if let badge = plan.badge {
                                    Badge(badge)
                                        .foregroundStyle(palette.accent)
                                }
                            }
                            Text("\(plan.price) \(plan.frequency)")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(palette.primary.opacity(0.2))
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var featureList: some View {
        List {
            Section(header: Text("What's included").foregroundStyle(.white.opacity(0.8))) {
                ForEach(viewModel.features) { feature in
                    HStack(spacing: 12) {
                        Image(systemName: feature.icon)
                            .frame(width: 32, height: 32)
                            .foregroundStyle(palette.accent)
                            .background(
                                Circle()
                                    .fill(palette.primary.opacity(0.15))
                            )
                        VStack(alignment: .leading, spacing: 4) {
                            Text(feature.title)
                                .font(.headline)
                                .foregroundStyle(.white)
                            Text(feature.subtitle)
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.75))
                        }
                    }
                    .listRowBackground(Color.clear)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .frame(maxHeight: 260)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var primaryCTA: some View {
        VStack(spacing: 8) {
            Button {
                guard let plan = viewModel.plans.last ?? viewModel.plans.first else { return }
                viewModel.select(plan: plan)
            } label: {
                Text("Start Free Trial")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(palette.primary)
                    .foregroundStyle(.white)
                    .cornerRadius(14)
            }
            Button {
                if viewModel.selectedPlan == nil {
                    viewModel.selectedPlan = viewModel.plans.first
                }
                viewModel.isPresentingSheet = viewModel.selectedPlan != nil
            } label: {
                Text("View Terms")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .foregroundStyle(palette.accent)
            }
        }
    }

    private var navigationLinks: some View {
        HStack(spacing: 16) {
            NavigationLink(destination: HomeView()) {
                Text("Home")
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(palette.secondary.opacity(0.2))
                    .foregroundStyle(.white)
                    .cornerRadius(12)
            }
            NavigationLink(destination: SettingsView()) {
                Text("Settings")
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(palette.secondary.opacity(0.2))
                    .foregroundStyle(.white)
                    .cornerRadius(12)
            }
        }
    }
}

public struct Palette {
    public let primary = Color(red: 0.423, green: 0.388, blue: 1.0) // #6C63FF
    public let secondary = Color(red: 0.486, green: 0.514, blue: 0.992) // #7C83FD
    public let background = Color(red: 0.043, green: 0.071, blue: 0.141) // #0B1224
    public let accent = Color(red: 0.369, green: 0.918, blue: 0.831) // #5EEAD4

    public init() {}
}

public struct PlanDetailSheet: View {
    public let plan: SubscriptionPlan

    public init(plan: SubscriptionPlan) {
        self.plan = plan
    }

    public var body: some View {
        VStack(spacing: 16) {
            Capsule()
                .fill(Color.white.opacity(0.2))
                .frame(width: 36, height: 4)
                .padding(.top, 8)
            Text(plan.name)
                .font(.title2.bold())
            Text("\(plan.price) \(plan.frequency)")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("Cancel anytime. Your subscription automatically renews unless canceled at least 24 hours before the end of the current period.")
                .font(.footnote)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            Button {
                // Hook up to purchase flow
            } label: {
                Text("Continue with \(plan.name)")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Palette().accent)
                    .foregroundStyle(.white)
                    .cornerRadius(14)
            }
            Spacer()
        }
        .padding()
        .presentationBackground(Palette().background.opacity(0.95))
    }
}

public struct HomeView: View {
    public init() {}

    public var body: some View {
        Text("Home")
            .navigationTitle("Home")
    }
}

public struct SettingsView: View {
    public init() {}

    public var body: some View {
        Text("Settings")
            .navigationTitle("Settings")
    }
}

#if DEBUG
public struct PaywallView_Previews: PreviewProvider {
    public static var previews: some View {
        PaywallView()
    }
}
#endif
