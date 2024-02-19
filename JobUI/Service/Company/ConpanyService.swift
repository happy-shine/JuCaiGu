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


class JobPostingViewModel: ObservableObject {
    @Published var jobTitle: String = ""
    @Published var jobDescription: String = ""
    @Published var jobLocation: String = ""
    @Published var jobType: String = ""
    @Published var jobSalaryMonth: String = ""
    
    func postJob(completion: @escaping (Bool, String) -> Void) {
        guard let url = URL(string: "\(BASE_URL)/hr/post-job") else {
            completion(false, "Invalid URL")
            return
        }
        
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            completion(false, "Authentication token not found")
            return
        }
        
        let job = JobPosting(title: jobTitle, description: jobDescription, location: jobLocation, type: jobType, salaryMonth: jobSalaryMonth)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(job)
            request.httpBody = jsonData
        } catch {
            completion(false, "Error encoding job data")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(false, "Network error: \(error!.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                completion(true, "职位发布成功")
            } else {
                completion(false, "职位发布失败, 请重试")
            }
        }
        
        task.resume()
    }
}

struct JobPosting: Codable {
    var title: String
    var description: String
    var location: String
    var type: String
    var salaryMonth: String
}


import Foundation
import Combine

class TalentViewModel: ObservableObject {
    @Published var applicants: [Applicant] = []
    
    private let talentPoolURL = "\(BASE_URL)/hr/talent-pool?status=1"
    private let blackListURL = "\(BASE_URL)/hr/talent-pool?status=-1"

    func fetchTalents(isBlackList: Bool = false) {
        guard let url = URL(string: isBlackList ? blackListURL : talentPoolURL) else { return }

        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            print("authToken not found in UserDefaults")
            return
        }
        print("fetchTalents")
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
}



class HrJobViewModel: ObservableObject {
    @Published var jobs: [Job] = []
    
    func loadJobs() {
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            print("AuthToken not found.")
            return
        }
        
        let url = URL(string: "\(BASE_URL)/hr/list-jobs")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode([Job].self, from: data) {
                    DispatchQueue.main.async {
                        self.jobs = decodedResponse
                    }
                    return
                }
            }
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
        }.resume()
    }
    
    func updateJob(job: Job, completion: @escaping (Bool, String) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            completion(false, "AuthToken not found.")
            return
        }
        
        // 更新 URL，移除 jobId 参数
        let url = URL(string: "\(BASE_URL)/hr/update-job")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let updateJobRequest = UpdateJobRequest(jobId: job.id.uuidString.lowercased(), title: job.title, description: job.description, location: job.location, company: job.company, type: job.type, postedOn: job.postedOn, salaryMonth: job.salaryMonth)
            print(updateJobRequest)
            let jsonData = try JSONEncoder().encode(updateJobRequest)
            print(jsonData)
            request.httpBody = jsonData
        } catch {
            DispatchQueue.main.async {
                completion(false, "Failed to encode job data.")
            }
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(false, "Update failed: \(error.localizedDescription)")
                }
                return
            }
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    completion(true, "修改成功")
                }
            } else {
                DispatchQueue.main.async {
                    completion(false, "Update failed with status code: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                }
            }
        }.resume()
    }
}

struct UpdateJobRequest: Codable {
    let jobId: String
    let title: String
    let description: String
    let location: String
    let company: String
    let type: String
    let postedOn: String
    let salaryMonth: String
}

