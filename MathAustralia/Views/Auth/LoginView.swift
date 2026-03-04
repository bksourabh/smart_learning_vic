import SwiftUI
import SwiftData

struct LoginView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isLoading = false

    var body: some View {
        Form {
            Section {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)

                SecureField("Password", text: $password)
                    .textContentType(.password)
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
                    login()
                } label: {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Log In")
                            .frame(maxWidth: .infinity)
                            .font(.headline)
                    }
                }
                .disabled(email.isEmpty || password.isEmpty || isLoading)
            }
        }
        .navigationTitle("Log In")
        .navigationBarTitleDisplayMode(.large)
    }

    private func login() {
        isLoading = true
        errorMessage = nil

        let authService = AuthService(modelContext: modelContext)
        do {
            let parent = try authService.login(email: email, password: password)
            appState.login(parent: parent)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
