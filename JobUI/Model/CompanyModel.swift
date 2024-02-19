//
//  CompanyModel.swift
//  聚才谷
//
//  Created by 宋炫熠 on 2024/2/14.
//

import Foundation

struct Company: Codable {
    var companyId: String = ""
    var name: String = ""
    var industry: String = ""
    var address: String = ""
    var hrTeam: [HR] = []
    var companyProfile: String = ""
    var permissions: [Permission] = []
    var superAdminUser: String = ""
    var superAdminPwd: String = ""
    var jobList: [Job] = []
}

struct Job: Codable, Identifiable {
    let id: UUID
    var jobId: String = ""
    var title: String = ""
    var description: String = ""
    var company: String = ""
    var location: String = ""
    var type: String = ""
    var postedOn: String = ""
    var salaryMonth: String = ""
    
    enum CodingKeys: String, CodingKey {
        case id = "jobId"
        case title, description, company, location, type, postedOn, salaryMonth
    }
}

struct HR: Codable {
    var personalInfo: PersonalInfo = PersonalInfo()
    var accountInfo: AccountInfo = AccountInfo()
    var hrId: String = ""
    var permissions: [Permission] = []
}

struct Permission: Codable {
    var resourceId: String = ""
    var resourceType: String = ""
    var actions: [Action] = []
}

struct Action: Codable {
    var name: String = ""
    var description: String = ""
}
