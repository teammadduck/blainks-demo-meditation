import SwiftUI

/// Main app entry point
/// To run this as a standalone app, add @main attribute
public struct ZenMindApp: App {
    public init() {}

    public var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}

/// Public entry view for the app
public struct ZenMindEntryView: View {
    public init() {}

    public var body: some View {
        HomeView()
    }
}