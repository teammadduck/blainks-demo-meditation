import SwiftUI
import Foundation

#if os(iOS)
import UIKit
private typealias SignupKeyboardType = UIKeyboardType
private let signupDefaultKeyboardType: SignupKeyboardType = .default
#else
private enum SignupKeyboardType {
    case `default`
    case emailAddress
}
private let signupDefaultKeyboardType: SignupKeyboardType = .default
#endif

public final class SignupViewModel: ObservableObject {
    @Published public var fullName: String
    @Published public var email: String
    @Published public var password: String
    @Published public var acceptsTerms: Bool
    @Published public var isLoading: Bool
    @Published public var errorMessage: String?
    @Published public var navigateToHome: Bool

    public init(
        fullName: String = "",
        email: String = "",
        password: String = "",
        acceptsTerms: Bool = true,
        isLoading: Bool = false,
        errorMessage: String? = nil,
        navigateToHome: Bool = false
    ) {
        self.fullName = fullName
        self.email = email
        self.password = password
        self.acceptsTerms = acceptsTerms
        self.isLoading = isLoading
        self.errorMessage = errorMessage
        self.navigateToHome = navigateToHome
    }

    public var isFormValid: Bool {
        !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        email.contains("@") &&
        password.count >= 8 &&
        acceptsTerms
    }

    public func signUp() {
        errorMessage = nil

        guard isFormValid else {
            errorMessage = "Please complete all fields, use a valid email, accept the terms, and use at least 8 characters for the password."
            return
        }

        isLoading = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) { [weak self] in
            guard let self else { return }
            self.isLoading = false
            self.navigateToHome = true
        }
    }
}

public struct SignupView: View {
    @StateObject private var viewModel: SignupViewModel
    private let homeDestination: AnyView
    private let loginDestination: AnyView

    public init(
        viewModel: SignupViewModel = SignupViewModel(),
        homeDestination: AnyView = AnyView(Text("Home")),
        loginDestination: AnyView = AnyView(Text("Login"))
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.homeDestination = homeDestination
        self.loginDestination = loginDestination
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#0B1224")
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    header

                    VStack(spacing: 16) {
                        textField(
                            title: "Full Name",
                            text: $viewModel.fullName,
                            systemImage: "person.fill"
                        )

                        textField(
                            title: "Email",
                            text: $viewModel.email,
                            systemImage: "envelope.fill",
                            keyboardType: .emailAddress
                        )

                        secureField(
                            title: "Password (min 8 characters)",
                            text: $viewModel.password,
                            systemImage: "lock.fill"
                        )

                        Toggle(isOn: $viewModel.acceptsTerms) {
                            Text("I agree to the Terms and Conditions")
                                .foregroundColor(.white.opacity(0.9))
                                .font(.subheadline.weight(.medium))
                        }
                        .toggleStyle(SwitchToggleStyle(tint: Color(hex: "#5EEAD4")))
                    }

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.footnote)
                            .foregroundColor(.red.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    Button(action: viewModel.signUp) {
                        HStack {
                            if viewModel.isLoading {
                                SwiftUI.ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "#0B1224")))
                            }
                            Text(viewModel.isLoading ? "Signing Up..." : "Create Account")
                        }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(SignupPrimaryButtonStyle())
                .disabled(viewModel.isLoading)

                    NavigationLink(destination: homeDestination, isActive: $viewModel.navigateToHome) {
                        EmptyView()
                    }
                    .hidden()

                    NavigationLink(destination: loginDestination) {
                        HStack(spacing: 4) {
                            Text("Already have an account?")
                                .foregroundColor(.white.opacity(0.75))
                            Text("Log In")
                                .foregroundColor(Color(hex: "#7C83FD"))
                                .fontWeight(.semibold)
                        }
                        .font(.subheadline)
                    }

                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 32)
            }
            .navigationTitle("Sign Up")
#if os(iOS)
            .toolbarColorScheme(.dark, for: .navigationBar)
#endif
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text("Join Us")
                .font(.largeTitle.weight(.bold))
                .foregroundColor(.white)
            Text("Create an account to continue to Home.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func textField(
        title: String,
        text: Binding<String>,
        systemImage: String,
        keyboardType: SignupKeyboardType = signupDefaultKeyboardType
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundColor(.white.opacity(0.8))

            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .foregroundColor(Color(hex: "#5EEAD4"))

                #if os(iOS)
                TextField("", text: text)
                    .keyboardType(keyboardType)
                    .foregroundColor(Color.white)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                #else
                TextField("", text: text)
                    .foregroundColor(Color.white)
                #endif
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.08)))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "#6C63FF").opacity(0.6), lineWidth: 1)
            )
        }
    }

    private func secureField(
        title: String,
        text: Binding<String>,
        systemImage: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundColor(.white.opacity(0.8))

            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .foregroundColor(Color(hex: "#5EEAD4"))

                #if os(iOS)
                SecureField("", text: text)
                    .foregroundColor(Color.white)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                #else
                SecureField("", text: text)
                    .foregroundColor(Color.white)
                #endif
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.08)))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "#7C83FD").opacity(0.7), lineWidth: 1)
            )
        }
    }
}

public struct SignupPrimaryButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .padding()
            .background(
                LinearGradient(
                    colors: [Color(hex: "#6C63FF"), Color(hex: "#7C83FD")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(Color(hex: "#0B1224"))
            .cornerRadius(14)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
