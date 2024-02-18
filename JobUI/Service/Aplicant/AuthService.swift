//
//  LoginService.swift
//  JobUI
//
//  Created by 宋炫熠 on 2024/2/8.
//

import Foundation
import SwiftUI

enum LoginType: String, Codable {
    case personal
    case business
}

struct User: Codable {
    var phoneNumber: String
    var password: String
}

struct LoginResponse: Codable {
    var token: String
    var applicant: Applicant
}

class LoginViewModel: ObservableObject {
    @Published var phoneNumber: String = ""
    @Published var password: String = ""
    @Published var showErrorAlert: Bool = false
    @Published var errorMessage: String = ""
    @Published var obApplicant: ObservableApplicant = ObservableApplicant()
    private var loadedApplicant: Applicant = Applicant()
    
    init() {
        self.refreshData()
    }
    
    func login(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(BASE_URL)/login") else { return }
        let user = User(phoneNumber: phoneNumber, password: password)
        
        guard let jsonData = try? JSONEncoder().encode(user) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

            if let httpResponse = response as? HTTPURLResponse {
                DispatchQueue.main.async {
                    switch httpResponse.statusCode {
                    case 200:
                        if let data = data, let loginResponse = try? JSONDecoder().decode(LoginResponse.self, from: data) {
                            self.saveToken(token: loginResponse.token)
                            saveApplicant(applicant: loginResponse.applicant)
                            self.refreshData()
                            completion(true)
                        } else {
                            self.errorMessage = "网络开小差了, 请重试"
                            self.showErrorAlert = true
                            completion(false)
                        }
                    case 401:
                        self.errorMessage = "账号或密码错误"
                        self.showErrorAlert = true
                        completion(false)
                    case 500:
                        self.errorMessage = "服务器异常, 请稍后再试"
                        self.showErrorAlert = true
                        completion(false)
                    default:
                        self.errorMessage = "网络开小差了, 请重试"
                        self.showErrorAlert = true
                        completion(false)
                    }
                }
            } else if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    self.showErrorAlert = true
                    completion(false)
                }
            }
        }.resume()
    }
    
    // 检查用户是否已登录
    func isLoggedIn() -> Bool {
        return UserDefaults.standard.string(forKey: "authToken") != nil
    }
    
    // 保存Token
    func saveToken(token: String) {
        UserDefaults.standard.set(token, forKey: "authToken")
    }
    
    // 加载登录类型
    func loadLoginType() -> LoginType {
        guard let rawValue = UserDefaults.standard.string(forKey: "loginType"),
              let type = LoginType(rawValue: rawValue) else {
            return .personal // 默认值
        }
        return type
    }
    
    func refreshData() {
        self.objectWillChange.send()
        self.loadedApplicant = loadApplicant()
        self.obApplicant.resume.education = self.loadedApplicant.resume.education
        self.obApplicant.resume.skills = self.loadedApplicant.resume.skills
        self.obApplicant.resume.workExperience = self.loadedApplicant.resume.workExperience
        self.obApplicant.resume.attachment = self.loadedApplicant.resume.attachment
        self.obApplicant.resume.resumeString = self.loadedApplicant.resume.resumeString
        self.obApplicant.personalInfo.name = self.loadedApplicant.personalInfo.name
        self.obApplicant.personalInfo.birthDate = self.loadedApplicant.personalInfo.birthDate
        self.obApplicant.personalInfo.gender = self.loadedApplicant.personalInfo.gender
        self.obApplicant.personalInfo.avatarBase64 = self.loadedApplicant.personalInfo.avatarBase64
        self.obApplicant.personalInfo.biography = self.loadedApplicant.personalInfo.biography
        self.obApplicant.personalInfo.currentResidence = self.loadedApplicant.personalInfo.currentResidence
        self.obApplicant.personalInfo.hukouLocation = self.loadedApplicant.personalInfo.hukouLocation
        self.obApplicant.personalInfo.phoneNumber = self.loadedApplicant.personalInfo.phoneNumber
        self.obApplicant.personalInfo.politicalStatus = self.loadedApplicant.personalInfo.politicalStatus
        self.obApplicant.personalInfo.email = self.loadedApplicant.personalInfo.email
        self.obApplicant.personalInfo.intendedPosition = self.loadedApplicant.personalInfo.intendedPosition
        self.obApplicant.accountInfo.boundPhoneNumber = self.loadedApplicant.accountInfo.boundPhoneNumber
        self.obApplicant.accountInfo.password = self.loadedApplicant.accountInfo.password
        self.obApplicant.accountInfo.userId = self.loadedApplicant.accountInfo.userId
        self.obApplicant.applicationInfo = self.loadedApplicant.applicationInfo
    }
}

// 保存applicant信息
func saveApplicant(applicant: Applicant) {
    if let data = try? JSONEncoder().encode(applicant) {
        UserDefaults.standard.set(data, forKey: "applicant")
        print("Applicant saved to UserDefaults")
    } else {
        print("Failed to encode applicant")
    }
}

func loadApplicant() -> Applicant {
    guard let data = UserDefaults.standard.data(forKey: "applicant"),
          let applicant = try? JSONDecoder().decode(Applicant.self, from: data) else {
        print("error decoder")
        return Applicant()
    }
    return applicant
}

// 保存登录类型
func saveLoginType(type: LoginType) {
    UserDefaults.standard.set(type.rawValue, forKey: "loginType")
}

// 注册
struct RegistrationDetails: Codable {
    var phoneNumber: String
    var gender: String
    var email: String
    var password: String
}


class RegisterViewModel: ObservableObject {
    @Published var phoneNumber: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var showErrorAlert: Bool = false
    @Published var errorMessage: String = ""
    @Published var isRegistrationSuccessful: Bool = false
    
    let genders = ["男", "女"]
    @Published var selectedGenderIndex: Int = 0
    var gender: String {
        genders[selectedGenderIndex]
    }

    func register(completion: @escaping (Bool) -> Void) {
        guard validateInputs() else {
            self.errorMessage = "All fields are required."
            self.showErrorAlert = true
            return
        }
        guard let url = URL(string: "\(BASE_URL)/register") else { return }
        let registrationDetails = RegistrationDetails(phoneNumber: phoneNumber, gender: gender, email: email, password: password)
        
        guard let jsonData = try? JSONEncoder().encode(registrationDetails) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { [weak self] _, response, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    self.isRegistrationSuccessful = true
                    completion(true)
                } else {
                    self.errorMessage = "Registration failed: \(error?.localizedDescription ?? "Unknown error")"
                    self.showErrorAlert = true
                    completion(false)
                }
            }
        }.resume()
    }
    
    func validateInputs() -> Bool {
        return !phoneNumber.isEmpty && !gender.isEmpty && !email.isEmpty && !password.isEmpty
    }
}



