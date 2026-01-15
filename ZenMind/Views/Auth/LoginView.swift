import SwiftUI

public struct LoginView: View {
    @StateObject private var viewModel: LoginViewModel
    @State private var navigationPath: [LoginRoute] = []
    @FocusState private var focusedField: Field?

    public init(viewModel: LoginViewModel = .init()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                Theme.background
                    .ignoresSafeArea()

                VStack(spacing: 32) {
                    header
                    form
                    actions
                    NavigationLink("Create an account", value: LoginRoute.signup)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.accent)
                        .padding(.top, 8)
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 48)
            }
            .navigationDestination(for: LoginRoute.self) { route in
                switch route {
                case .home:
                    HomeView()
                case .signup:
                    SignupView()
                case .reset:
                    PasswordResetView()
                }
            }
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text("Welcome Back")
                .font(.system(.largeTitle, weight: .bold))
                .foregroundStyle(Theme.primary)

            Text("Sign in with your email to continue")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
        }
        .multilineTextAlignment(.center)
    }

    private var form: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
                TextField("name@example.com", text: $viewModel.email)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .focused($focusedField, equals: .email)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .password }
                    .padding()
                    .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(Theme.primary.opacity(0.4), lineWidth: 1)
                    )
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
                SecureField("••••••••", text: $viewModel.password)
                    .focused($focusedField, equals: .password)
                    .submitLabel(.go)
                    .onSubmit(triggerLogin)
                    .padding()
                    .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(Theme.primary.opacity(0.4), lineWidth: 1)
                    )
                    .foregroundStyle(.white)
            }

            if let message = viewModel.errorMessage {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(.opacity)
            }
        }
    }

    private var actions: some View {
        VStack(spacing: 16) {
            Button(action: triggerLogin) {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    }
                    Text("Log In")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [Theme.primary, Theme.secondary],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .foregroundStyle(.white)
            }
            .disabled(!viewModel.isFormValid || viewModel.isLoading)
            .opacity(viewModel.isFormValid ? 1 : 0.6)

            Button {
                navigationPath.append(.reset)
            } label: {
                Text("Forgot password?")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Theme.accent)
            }
        }
    }

    private func triggerLogin() {
        Task {
            let success = await viewModel.login()
            if success {
                navigationPath.append(.home)
            }
        }
    }

    private enum Field {
        case email, password
    }
}

public final class LoginViewModel: ObservableObject {
    @Published public var email: String
    @Published public var password: String
    @Published public private(set) var isLoading: Bool
    @Published public private(set) var errorMessage: String?

    public init(email: String = "", password: String = "", isLoading: Bool = false, errorMessage: String? = nil) {
        self.email = email
        self.password = password
        self.isLoading = isLoading
        self.errorMessage = errorMessage
    }

    public var isFormValid: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    @MainActor
    public func login() async -> Bool {
        guard isFormValid else {
            errorMessage = "Please enter your email and password."
            return false
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        // Simulate async login call. Replace with real service integration.
        try? await Task.sleep(nanoseconds: 500_000_000)

        let isAuthenticated = email.lowercased() == "demo@example.com" && password == "password"
        if !isAuthenticated {
            errorMessage = "Invalid credentials. Please try again."
        }
        return isAuthenticated
    }
}

public enum LoginRoute: Hashable {
    case home
    case signup
    case reset
}

public enum Theme {
    public static let primary = Color(hex: "#6C63FF")
    public static let secondary = Color(hex: "#7C83FD")
    public static let background = Color(hex: "#0B1224")
    public static let accent = Color(hex: "#5EEAD4")
}

#Preview {
    LoginView()
        .preferredColorScheme(.dark)
}
