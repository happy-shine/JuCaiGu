//
//  ApplicantService.swift
//  JobUI
//
//  Created by 宋炫熠 on 2024/2/8.
//

import Foundation
import SwiftUI
import Combine

struct UpdatePersonalInfoRequest: Codable {
    var personalInfo: PersonalInfo
}

class PersonalInfoViewModel: ObservableObject {
    @Published var personalInfo = ObservablePersonalInfo()
    private var loadedApplicant = Applicant()
    
    init() {
        self.loadedApplicant = loadApplicant()
        self.personalInfo.name = self.loadedApplicant.personalInfo.name
        self.personalInfo.birthDate = self.loadedApplicant.personalInfo.birthDate
        self.personalInfo.gender = self.loadedApplicant.personalInfo.gender
        self.personalInfo.avatarBase64 = self.loadedApplicant.personalInfo.avatarBase64
        self.personalInfo.biography = self.loadedApplicant.personalInfo.biography
        self.personalInfo.currentResidence = self.loadedApplicant.personalInfo.currentResidence
        self.personalInfo.hukouLocation = self.loadedApplicant.personalInfo.hukouLocation
        self.personalInfo.phoneNumber = self.loadedApplicant.personalInfo.phoneNumber
        self.personalInfo.politicalStatus = self.loadedApplicant.personalInfo.politicalStatus
        self.personalInfo.email = self.loadedApplicant.personalInfo.email
        self.personalInfo.intendedPosition = self.loadedApplicant.personalInfo.intendedPosition

    }
    
    func updatePersonalInfo(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(BASE_URL)/applicant/update-info") else { return }
        guard let token = UserDefaults.standard.string(forKey: "authToken") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let personalInfo = PersonalInfo(
                name: self.personalInfo.name,
                birthDate: self.personalInfo.birthDate,
                gender: self.personalInfo.gender,
                avatarBase64: self.personalInfo.avatarBase64,
                biography: self.personalInfo.biography,
                currentResidence: self.personalInfo.currentResidence,
                hukouLocation: self.personalInfo.hukouLocation,
                phoneNumber: self.personalInfo.phoneNumber,
                politicalStatus: self.personalInfo.politicalStatus,
                email: self.personalInfo.email,
                intendedPosition: self.personalInfo.intendedPosition
            )
            self.loadedApplicant.personalInfo = personalInfo
            saveApplicant(applicant: self.loadedApplicant)
            let requestdata = UpdatePersonalInfoRequest(personalInfo: personalInfo)
            let jsonData = try JSONEncoder().encode(requestdata)
            request.httpBody = jsonData
        } catch {
            print("Failed to encode personal info: \(error)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error updating personal info: \(error)")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                    print("Error updating personal info, HTTP Status: \(httpResponse.statusCode)")
                    return
                }
                completion(true)
                
            }
            
        }.resume()
    }
}




struct UpdateResumeRequest: Codable {
    var resume: Resume
}

class ResumeViewModel: ObservableObject {
    @Published var resume = ObservableResume()
    private var loadedApplicant = Applicant()
    
    init() {
        self.refreshData()
    }
    
    func updateResume(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(BASE_URL)/applicant/update-resume") else { return }
        guard let token = UserDefaults.standard.string(forKey: "authToken") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let resumeInfo = Resume(
                education: self.resume.education,
                skills: self.resume.skills,
                workExperience: self.resume.workExperience,
                attachment: self.resume.attachment,
                resumeString: self.resume.resumeString
            )
            self.loadedApplicant.resume = resumeInfo
            saveApplicant(applicant: self.loadedApplicant)
            self.refreshData()
            let requestdata = UpdateResumeRequest(resume: resumeInfo)
            let jsonData = try JSONEncoder().encode(requestdata)
            request.httpBody = jsonData
        } catch {
            print("Failed to encode resume info: \(error)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error updating resume info: \(error)")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                    print("Error updating resume info, HTTP Status: \(httpResponse.statusCode)")
                    return
                }
                completion(true)
            }
            
        }.resume()
    }
    
    func refreshData() {
        self.loadedApplicant = loadApplicant()
        self.resume.education = loadedApplicant.resume.education
        self.resume.skills = loadedApplicant.resume.skills
        self.resume.workExperience = loadedApplicant.resume.workExperience
        self.resume.attachment = loadedApplicant.resume.attachment
        self.resume.resumeString = loadedApplicant.resume.resumeString
    }
    
    func removeEducation(at offsets: IndexSet) {
        self.resume.education.remove(atOffsets: offsets)
    }
    
    func removeWorkExperience(at offsets: IndexSet) {
        self.resume.workExperience.remove(atOffsets: offsets)
    }
    
    func removeSkill(at offsets: IndexSet) {
        self.resume.skills.remove(atOffsets: offsets)
    }
    
    func addEducation() {
        self.objectWillChange.send()
        self.resume.education.append(Education())
    }

    func addWorkExperience() {
        self.objectWillChange.send()
        self.resume.workExperience.append(WorkExperience())
    }

    func addSkill() {
        self.objectWillChange.send()
        self.resume.skills.append("")
    }
    
    func uploadAttachment() {
        
    }
}


class JobViewModel: ObservableObject {
    @Published var jobs: [Job] = []
    @Published var isApplicationSuccessful: Bool = false
    
    private var cancellables = Set<AnyCancellable>()

    func fetchJobs() {
        guard let url = URL(string: "\(BASE_URL)/jobs") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        guard let token = UserDefaults.standard.string(forKey: "authToken") else { return }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return output.data
            }
            .decode(type: [Job].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }, receiveValue: { [weak self] jobs in
                self?.jobs = jobs
            })
            .store(in: &cancellables)
    }
    
    func searchJobs(keyword: String) {
        guard let url = URL(string: "\(BASE_URL)/search-jobs?keyword=\(keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        guard let token = UserDefaults.standard.string(forKey: "authToken") else { return }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return output.data
            }
            .decode(type: [Job].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }, receiveValue: { [weak self] jobs in
                self?.jobs = jobs
            })
            .store(in: &cancellables)
    }
    
    func applyForJob(jobId: String) {
        guard let url = URL(string: "\(BASE_URL)/apply-job") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let token = UserDefaults.standard.string(forKey: "authToken") else { return }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let body: [String: String] = ["jobId": jobId]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    self?.isApplicationSuccessful = true
                } else {
                    self?.isApplicationSuccessful = false
                }
            }
        }.resume()
    }
}


class JobApplicationsViewModel: ObservableObject {
    @Published var jobApplications = [JobApplication]()
    
    func fetchJobApplications() {
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            print("Auth token not found")
            return
        }
        
        let url = URL(string: "\(BASE_URL)/applicant/applications")!
        var request = URLRequest(url: url)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let response = try? JSONDecoder().decode([JobApplication].self, from: data) {
                    DispatchQueue.main.async {
                        self.jobApplications = response
                    }
                } else {
                    print("JSON Decoding Failed")
                }
            }
        }.resume()
    }
}
