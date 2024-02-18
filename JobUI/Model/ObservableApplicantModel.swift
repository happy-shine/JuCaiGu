//
//  ObservableModel.swift
//  JobUI
//
//  Created by 宋炫熠 on 2024/2/12.
//

import Foundation
import SwiftUI

class ObservableApplicant: ObservableObject {
    @Published var resume: ObservableResume = ObservableResume()
    @Published var personalInfo: ObservablePersonalInfo = ObservablePersonalInfo()
    @Published var accountInfo: ObservableAccountInfo = ObservableAccountInfo()
    @Published var applicationInfo: [ApplicationInfo] = []
    
    init() {}
    
    init(resume: ObservableResume, personalInfo: ObservablePersonalInfo, accountInfo: ObservableAccountInfo, applicationInfo: [ApplicationInfo]) {
        self.resume = resume
        self.personalInfo = personalInfo
        self.accountInfo = accountInfo
        self.applicationInfo = applicationInfo
    }
}

class ObservableResume: ObservableObject {
    @Published var education: [Education] = []
    @Published var skills: [String] = []
    @Published var workExperience: [WorkExperience] = []
    @Published var attachment: String = ""
    @Published var resumeString: String = ""
    
    init() {}
    
    init(education: [Education], skills: [String], workExperience: [WorkExperience], attachment: String, resumeString: String) {
        self.education = education
        self.skills = skills
        self.workExperience = workExperience
        self.attachment = attachment
        self.resumeString = resumeString
    }
    
    func uploadAttachment(url: String) {
        // 在这里处理文件上传逻辑
        self.attachment = url
    }
}

class ObservablePersonalInfo: ObservableObject {
    @Published var name: String = "您好, 请登陆"
    @Published var birthDate: String = ""
    @Published var gender: String = ""
    @Published var avatarBase64: String = ""
    @Published var biography: String = ""
    @Published var currentResidence: String = ""
    @Published var hukouLocation: String = ""
    @Published var phoneNumber: String = ""
    @Published var politicalStatus: String = ""
    @Published var email: String = ""
    @Published var intendedPosition: String = ""
    
    init() {}
    
    init(name: String, birthDate: String, gender: String, avatarBase64: String, biography: String, currentResidence: String, hukouLocation: String, phoneNumber: String, politicalStatus: String, email: String, intendedPosition: String) {
        self.name = name
        self.birthDate = birthDate
        self.gender = gender
        self.avatarBase64 = avatarBase64
        self.biography = biography
        self.currentResidence = currentResidence
        self.hukouLocation = hukouLocation
        self.phoneNumber = phoneNumber
        self.politicalStatus = politicalStatus
        self.email = email
        self.intendedPosition = intendedPosition
    }
}

class ObservableAccountInfo: ObservableObject {
    @Published var boundPhoneNumber: String = ""
    @Published var password: String = ""
    @Published var userId: String = ""
    
    init() {}
    
    init(boundPhoneNumber: String, password: String, userId: String) {
        self.boundPhoneNumber = boundPhoneNumber
        self.password = password
        self.userId = userId
    }
}

class ObservableApplicationInfo: ObservableObject {
    @Published var jobId: String = ""
    @Published var appliedOn: String = ""
    @Published var status: String = ""
    
    init() {}
    
    init(jobId: String, appliedOn: String, status: String) {
        self.jobId = jobId
        self.appliedOn = appliedOn
        self.status = status
    }
}
