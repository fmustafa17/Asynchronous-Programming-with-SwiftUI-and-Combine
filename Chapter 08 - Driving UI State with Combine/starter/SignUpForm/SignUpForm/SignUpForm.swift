//
//  ContentView.swift
//  SignUpForm
//
//  Created by Peter Friese on 27.12.21.
//

import SwiftUI
import Combine

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
        Publishers.CombineLatest(passwordLengthValidator, isPasswordMatching)
            .map { $0 && $1 }
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
                !password.isEmpty && password.count >= 8
            }
            .eraseToAnyPublisher()
    }()
    
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
