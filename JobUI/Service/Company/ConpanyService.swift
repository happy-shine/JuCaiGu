//
//  ConpanyService.swift
//  聚才谷
//
//  Created by 宋炫熠 on 2024/2/15.
//

import Foundation
import Combine


class ApplicantListViewModel: ObservableObject {
    @Published var applicants: [Applicant] = []

    func fetchApplicants() {
        guard let url = URL(string: "\(BASE_URL)/hr/applicants") else {
            print("Invalid URL")
            return
        }

        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            print("authToken not found in UserDefaults")
            return
        }

        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode([Applicant].self, from: data) {
                    DispatchQueue.main.async {
                        self.applicants = decodedResponse
                    }
                } else {
                    print("Decoding failed")
                }
            } else {
                print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }.resume()
    }
    
    func searchApplicants(keyword: String) {
        guard let url = URL(string: "\(BASE_URL)/hr/search-applicants?keyword=\(keyword)") else {
            print("Invalid URL")
            return
        }

        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            print("authToken not found in UserDefaults")
            return
        }

        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode([Applicant].self, from: data) {
                    DispatchQueue.main.async {
                        self.applicants = decodedResponse
                    }
                } else {
                    print("Decoding failed")
                }
            } else {
                print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }.resume()
    }
    
    func manageTalentPool(userId: String, status: String) {
        guard let url = URL(string: "\(BASE_URL)/hr/manage-talent-pool") else {
            print("Invalid URL")
            return
        }

        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            print("authToken not found in UserDefaults")
            return
        }

        let body: [String: Any] = [
            "userId": userId,
            "status": status
        ]
        
        guard let bodyData = try? JSONSerialization.data(withJSONObject: body, options: []) else {
            print("Error: Cannot create JSON body")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = bodyData

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Error: Invalid response from server")
                return
            }
            // Handle the response or update the UI as needed
            DispatchQueue.main.async {
//                self.fetchApplicants()
            }
        }.resume()
    }
}
