//
//  ContentView.swift
//  SignUpForm
//
//  Created by Peter Friese on 27.12.21.
//

import SwiftUI
import Combine
import Navajo_Swift

// MARK: - View Model
class SignUpFormViewModel: ObservableObject {
    
    // MARK: Input
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var passwordConfirmation: String = ""
    
    // MARK: Output
    @Published var usernameValidationMessage: String = ""
    @Published var passwordMessage: String = ""
    @Published var isValid: Bool = false
    
    private let validStrengths = [
        PasswordStrength.reasonable,
        PasswordStrength.strong,
        PasswordStrength.veryStrong
    ]
    
    // MARK: - Publishers
    private lazy var isUsernameLengthValidPublisher: AnyPublisher<Bool, Never> = {
        $username
            .map { username in
                username.count >= 3 // implicit return
            }
            .eraseToAnyPublisher()
    }()
    
    private lazy var isPasswordMatching: AnyPublisher<Bool, Never> = {
        Publishers.CombineLatest($password, $passwordConfirmation)
            .map(==)
            .eraseToAnyPublisher()
    }()
    
    private lazy var isPasswordValidPublisher: AnyPublisher<Bool, Never> = {
        Publishers.CombineLatest3(
            passwordLengthValidator,
            passwordStrengthValidator,
            isPasswordMatching
        )
        .map { $0 && $1 && $2 }
        .eraseToAnyPublisher()
    }()
    
    private lazy var isFormValidPublisher: AnyPublisher<Bool, Never> = {
        Publishers.CombineLatest(isUsernameLengthValidPublisher, isPasswordValidPublisher)
            .map { $0 && $1 }
            .eraseToAnyPublisher()
    }()
    
    // Exercise 1
    // Display warning message if password is less than 8 characters
    private lazy var passwordLengthValidator: AnyPublisher<Bool, Never> = {
        $password
            .map { password in
                password.count >= 8
            }
            .eraseToAnyPublisher()
    }()
    
    // Exercise 2
    // Check if the password's strength is at least `reasonable`
    private lazy var passwordStrengthValidator: AnyPublisher<Bool, Never> = {
        $password
            .map { password in
                let currentStrength = Navajo.strength(ofPassword: password)
                return self.getPasswordStrength(currentStrength)
            }
            .eraseToAnyPublisher()
    }()
    
    // Exercise 3
    // Display the number and color of the progress bar based on password strength
    @Published var passwordStrengthValue = 0.0
    @Published var passwordProgressColor: Color = Color.red
    @Published var passwordProgressMessage: String = ""
    
    private func getPasswordStrength(_ currentStrength: PasswordStrength) -> Bool {
        if currentStrength == PasswordStrength.veryWeak ||
            currentStrength == PasswordStrength.weak {
            passwordStrengthValue = 0.3
            passwordProgressColor = .red
            return false
        } else if currentStrength == PasswordStrength.reasonable {
            passwordStrengthValue = 0.6
            passwordProgressColor = .yellow
            return false
        }
        passwordStrengthValue = 1.0
        passwordProgressColor = .green
        return true
    }
    
    init() {
        isFormValidPublisher
            .assign(to: &$isValid)
        
        isUsernameLengthValidPublisher
            .map {
                $0 ? "" : "Username needs to be at least 3 characters"
            }
            .assign(to: &$usernameValidationMessage)

        Publishers.CombineLatest(passwordLengthValidator, isPasswordMatching)
            .map { passwordLengthValid, passwordsMatch in
                if !passwordLengthValid {
                    return "Password needs to be at least 8 characters"
                } else if !passwordsMatch {
                    return "Passwords do not match"
                }
                return ""
            }
            .assign(to: &$passwordMessage)
        
        Publishers.CombineLatest3(
            passwordLengthValidator,
            isPasswordMatching,
            passwordStrengthValidator
        )
        .map { passwordLengthValid, passwordsMatch, passwordIsStrongEnough in
            
            if passwordLengthValid && passwordsMatch {
                if !passwordIsStrongEnough {
                    return "Password is not strong enough"
                }
            }

            return ""
        }
        .assign(to: &$passwordProgressMessage)
    }
}

// MARK: - View
struct SignUpForm: View {
    @StateObject var viewModel = SignUpFormViewModel()
    
    var body: some View {
        Form {
            // Username
            Section {
                TextField("Username", text: $viewModel.username)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            } footer: {
                Text(viewModel.usernameValidationMessage)
                    .foregroundColor(.red)
            }
            
            // Password
            Section {
                SecureField("Password", text: $viewModel.password)
                SecureField("Repeat password", text: $viewModel.passwordConfirmation)
            } footer: {
                Text(viewModel.passwordMessage)
                    .foregroundColor(.red)
                ProgressView(value: viewModel.passwordStrengthValue, total: 1.0) {
                        Text(viewModel.passwordProgressMessage)
                    }
                .tint(viewModel.passwordProgressColor)
            }
            
            // Submit button
            Section {
                Button("Sign up") {
                    print("Signing up as \(viewModel.username)")
                }
                .disabled(!viewModel.isValid)
            }
        }
    }
}

// MARK: - Preview
struct SignUpForm_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SignUpForm()
                .navigationTitle("Sign up")
        }
    }
}
