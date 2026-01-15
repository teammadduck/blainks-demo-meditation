import SwiftUI

public final class SettingsViewModel: ObservableObject {
    @Published public var notificationsEnabled: Bool
    @Published public var notificationPreviews: Bool
    @Published public var selectedTheme: ThemeOption
    @Published public var marketingUpdates: Bool
    
    public init(
        notificationsEnabled: Bool = true,
        notificationPreviews: Bool = true,
        selectedTheme: ThemeOption = .system,
        marketingUpdates: Bool = false
    ) {
        self.notificationsEnabled = notificationsEnabled
        self.notificationPreviews = notificationPreviews
        self.selectedTheme = selectedTheme
        self.marketingUpdates = marketingUpdates
    }
    
    public func signOut() {
        // Hook for sign-out logic integration
    }
}

public enum ThemeOption: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
}

public struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel
    
    public init(viewModel: SettingsViewModel = SettingsViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                SettingsPalette.background
                    .ignoresSafeArea()
                Form {
                    notificationSection
                    appearanceSection
                    accountSection
                }
                .scrollContentBackground(.hidden)
                .tint(SettingsPalette.primary)
            }
            .navigationTitle("Settings")
        }
    }
    
    private var notificationSection: some View {
        Section("Notifications") {
            Toggle("Enable notifications", isOn: $viewModel.notificationsEnabled)
            Toggle("Show previews", isOn: $viewModel.notificationPreviews)
                .disabled(!viewModel.notificationsEnabled)
            Toggle("Marketing updates", isOn: $viewModel.marketingUpdates)
        }
    }
    
    private var appearanceSection: some View {
        Section("Appearance") {
            Picker("Theme", selection: $viewModel.selectedTheme) {
                ForEach(ThemeOption.allCases) { option in
                    Text(option.displayName)
                        .tag(option)
                }
            }
            .pickerStyle(.segmented)
            
            HStack {
                Label("Primary", systemImage: "circle.fill")
                    .foregroundStyle(SettingsPalette.primary)
                Spacer()
                Label("Secondary", systemImage: "circle.fill")
                    .foregroundStyle(SettingsPalette.secondary)
                Label("Accent", systemImage: "circle.fill")
                    .foregroundStyle(SettingsPalette.accent)
            }
            .font(.footnote)
        }
    }
    
    private var accountSection: some View {
        Section("Account") {
            NavigationLink {
                ProfileView()
            } label: {
                Label("Profile", systemImage: "person.crop.circle")
            }
            
            NavigationLink {
                PaywallView()
            } label: {
                Label("Subscription", systemImage: "creditcard")
            }
            
            Button(role: .destructive) {
                viewModel.signOut()
            } label: {
                Label("Sign out", systemImage: "arrow.backward.square")
                    .foregroundStyle(SettingsPalette.accent)
            }
        }
    }
}

public struct ProfileView: View {
    public init() {}
    
    public var body: some View {
        Text("Profile")
            .foregroundStyle(SettingsPalette.primary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(SettingsPalette.background)
    }
}

public struct PaywallView: View {
    public init() {}
    
    public var body: some View {
        Text("Paywall")
            .foregroundStyle(SettingsPalette.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(SettingsPalette.background)
    }
}

public struct SettingsPalette {
    public static let primary = Color(red: 108/255, green: 99/255, blue: 255/255)
    public static let secondary = Color(red: 124/255, green: 131/255, blue: 253/255)
    public static let background = Color(red: 11/255, green: 18/255, blue: 36/255)
    public static let accent = Color(red: 94/255, green: 234/255, blue: 212/255)
    
    public init() {}
}
