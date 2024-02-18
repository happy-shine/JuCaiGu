//
//  CompanyAuthService.swift
//  聚才谷
//
//  Created by 宋炫熠 on 2024/2/14.
//

import Foundation

struct HRUser: Codable {
    var username: String
    var password: String
}

struct HRLoginResponse: Codable {
    var token: String
}

class CompanyAuthViewModel: ObservableObject {
    @Published var showErrorAlert: Bool = false
    @Published var errorMessage: String = ""
    
    // 登录方法
    func login(username: String, password: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(BASE_URL)/hr/login") else { return }
        let hrUser = HRUser(username: username, password: password)
        
        guard let jsonData = try? JSONEncoder().encode(hrUser) else { return }

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
                        if let data = data, let hrLoginResponse = try? JSONDecoder().decode(HRLoginResponse.self, from: data) {
                            self.saveToken(token: hrLoginResponse.token)
                            completion(true)
                        } else {
                            self.errorMessage = "网络开小差了，请重试。"
                            self.showErrorAlert = true
                            completion(false)
                        }
                    case 401:
                        self.errorMessage = "用户名或密码错误。"
                        self.showErrorAlert = true
                        completion(false)
                    case 500:
                        self.errorMessage = "服务器异常，请稍后再试。"
                        self.showErrorAlert = true
                        completion(false)
                    default:
                        self.errorMessage = "网络开小差了，请重试。"
                        self.showErrorAlert = true
                        completion(false)
                    }
                }
            } else if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "网络错误：\(error.localizedDescription)"
                    self.showErrorAlert = true
                    completion(false)
                }
            }
        }.resume()
    }
    
    // 保存Token到UserDefaults
    private func saveToken(token: String) {
        UserDefaults.standard.set(token, forKey: "authToken")
    }
    
    // 检查HR是否已登录
    func isHRLoggedIn() -> Bool {
        return UserDefaults.standard.string(forKey: "authToken") != nil
    }
}

