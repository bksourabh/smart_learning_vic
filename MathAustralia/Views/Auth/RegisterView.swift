import SwiftUI
import SwiftData

struct RegisterView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var displayName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?
    @State private var isLoading = false

    private var isValid: Bool {
        !displayName.isEmpty && !email.isEmpty && password.count >= 6 && password == confirmPassword
    }

    var body: some View {
        Form {
            Section("Your Details") {
                TextField("Display Name", text: $displayName)
                    .textContentType(.name)

                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
            }

            Section("Password") {
                SecureField("Password (min 6 characters)", text: $password)
                    .textContentType(.newPassword)

                SecureField("Confirm Password", text: $confirmPassword)
                    .textContentType(.newPassword)

                if !password.isEmpty && !confirmPassword.isEmpty && password != confirmPassword {
                    Text("Passwords do not match")
                        .foregroundStyle(.red)
                        .font(.caption)
                }
            }

            if let error = errorMessage {
                Section {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.caption)
                }
            }

            Section {
                Button {
                    register()
                } label: {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Create Account")
                            .frame(maxWidth: .infinity)
                            .font(.headline)
                    }
                }
                .disabled(!isValid || isLoading)
            }
        }
        .navigationTitle("Create Account")
        .navigationBarTitleDisplayMode(.large)
    }

    private func register() {
        isLoading = true
        errorMessage = nil

        let authService = AuthService(modelContext: modelContext)
        do {
            let parent = try authService.register(
                email: email,
                password: password,
                displayName: displayName
            )
            appState.login(parent: parent)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
