//
//  ApplicantModel.swift
//  JobUI
//
//  Created by 宋炫熠 on 2024/2/12.
//

import Foundation

struct Applicant: Codable {
    var resume: Resume = Resume()
    var personalInfo: PersonalInfo = PersonalInfo()
    var accountInfo: AccountInfo = AccountInfo()
    var applicationInfo: [ApplicationInfo] = []
}

struct Resume: Codable {
    var education: [Education] = []
    var skills: [String] = []
    var workExperience: [WorkExperience] = []
    var attachment: String = ""
    var resumeString: String = ""
}

struct Education: Codable {
    var degree: String = ""
    var schoolName: String = ""
    var major: String = ""
    var startDate: String = ""
    var endDate: String = ""
}

struct WorkExperience: Codable {
    var companyName: String = ""
    var positionName: String = ""
    var startDate: String = ""
    var endDate: String = ""
    var industry: String = ""
}

struct PersonalInfo: Codable {
    var name: String = ""
    var birthDate: String = ""
    var gender: String = ""
    var avatarBase64: String = ""
    var biography: String = ""
    var currentResidence: String = ""
    var hukouLocation: String = ""
    var phoneNumber: String = ""
    var politicalStatus: String = ""
    var email: String = ""
    var intendedPosition: String = ""
}

struct AccountInfo: Codable {
    var boundPhoneNumber: String = ""
    var password: String = ""
    var userId: String = ""
}

struct ApplicationInfo: Codable {
    var jobId: String = ""
    var appliedOn: String = ""
    var status: String = ""
}
