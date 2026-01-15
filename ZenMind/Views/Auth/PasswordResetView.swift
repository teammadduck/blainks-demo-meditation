import SwiftUI

public struct PasswordResetView: View {
    @StateObject private var viewModel: PasswordResetViewModel
    @State private var navigateToLogin = false

    public init(viewModel: PasswordResetViewModel = PasswordResetViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                background

                VStack(spacing: 24) {
                    header
                    inputSection
                    actionButton
                }
                .padding(24)
            }
            .navigationTitle("Reset Password")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $navigateToLogin) {
                LoginView()
            }
            .alert(viewModel.alertTitle, isPresented: $viewModel.isShowingAlert) {
                Button("OK") {
                    if viewModel.didSucceed {
                        navigateToLogin = true
                    }
                }
            } message: {
                Text(viewModel.alertMessage)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Forgot your password?")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            Text("Enter your email address and we'll send you instructions to reset your password.")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.75))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Email")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.85))
            TextField("you@example.com", text: $viewModel.email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .padding()
                .background(Color.white.opacity(0.08))
                .foregroundColor(.white)
                .cornerRadius(12)
        }
    }

    private var actionButton: some View {
        Button(action: viewModel.sendReset) {
            HStack {
                if viewModel.isSending {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
                Text(viewModel.isSending ? "Sending..." : "Send Reset Email")
                    .font(.system(size: 16, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(viewModel.canSubmit ? Color.primaryPurple : Color.primaryPurple.opacity(0.5))
            .foregroundColor(.white)
            .cornerRadius(14)
        }
        .disabled(!viewModel.canSubmit)
    }

    private var background: some View {
        LinearGradient(
            colors: [.backgroundDeep, .backgroundDeep.opacity(0.9)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

public final class PasswordResetViewModel: ObservableObject {
    @Published public var email: String
    @Published public var isSending: Bool
    @Published public var isShowingAlert: Bool
    @Published public var alertTitle: String
    @Published public var alertMessage: String
    @Published public var didSucceed: Bool

    public init(
        email: String = "",
        isSending: Bool = false,
        isShowingAlert: Bool = false,
        alertTitle: String = "",
        alertMessage: String = "",
        didSucceed: Bool = false
    ) {
        self.email = email
        self.isSending = isSending
        self.isShowingAlert = isShowingAlert
        self.alertTitle = alertTitle
        self.alertMessage = alertMessage
        self.didSucceed = didSucceed
    }

    public var canSubmit: Bool {
        !isSending && email.isValidEmail
    }

    public func sendReset() {
        guard canSubmit else { return }
        isSending = true
        didSucceed = false

        // Simulate network delay; replace with real API integration.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.isSending = false
            self.didSucceed = true
            self.alertTitle = "Email Sent"
            self.alertMessage = "Check your inbox for a password reset link."
            self.isShowingAlert = true
        }
    }
}

public struct LoginView: View {
    public init() {}

    public var body: some View {
        Text("Login Screen")
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.backgroundDeep)
            .ignoresSafeArea()
            .navigationTitle("Login")
    }
}

public extension Color {
    static let primaryPurple = Color(hex: 0x6C63FF)
    static let secondaryPurple = Color(hex: 0x7C83FD)
    static let accentMint = Color(hex: 0x5EEAD4)
    static let backgroundDeep = Color(hex: 0x0B1224)

    init(hex: UInt, alpha: Double = 1.0) {
        let red = Double((hex & 0xFF0000) >> 16) / 255.0
        let green = Double((hex & 0x00FF00) >> 8) / 255.0
        let blue = Double(hex & 0x0000FF) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}

private extension String {
    var isValidEmail: Bool {
        let pattern = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$"#
        return range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil
    }
}
