import SwiftUI
import KeychainAccess

class KeychainViewModel: ObservableObject {
    private let keychain = Keychain(service: "com.example.yourapp")

    @Published var loginName: String = ""
    @Published var password: String = ""

    func saveCredentials() {
        do {
            try keychain.set(loginName, key: "loginName")
            try keychain.set(password, key: "password")
        } catch {
            // Handle errors
            print("Error saving credentials: \(error)")
        }
    }

    func retrieveCredentials() {
        do {
            loginName = try keychain.getString("loginName") ?? ""
            password = try keychain.getString("password") ?? ""
        } catch {
            // Handle errors
            print("Error retrieving credentials: \(error)")
        }
    }
}

struct PassportView: View {
    @StateObject private var viewModel = KeychainViewModel()

    var body: some View {
        NavigationView {
            VStack {
                TextField("Login Name", text: $viewModel.loginName)
                    .padding()
                SecureField("Password", text: $viewModel.password)
                    .padding()
                Button("Save") {
                    viewModel.saveCredentials()
                }
                NavigationLink("Display Credentials", destination: DisplayCredentialsView(viewModel: viewModel))
                    .padding()
            }
            .navigationTitle("Keychain Demo")
        }
    }
}

struct DisplayCredentialsView: View {
    @ObservedObject var viewModel: KeychainViewModel

    var body: some View {
        VStack {
            Text("Login Name: \(viewModel.loginName)")
            Text("Password: \(viewModel.password)")
        }
        .onAppear {
            viewModel.retrieveCredentials()
        }
        .padding()
    }
}

struct PassportView_Previews: PreviewProvider {
    static var previews: some View {
        PassportView()
    }
}

