//
//  ObservableCompanyModel.swift
//  聚才谷
//
//  Created by 宋炫熠 on 2024/2/14.
//

import Foundation
import Combine

class ObservableCompany: ObservableObject {
    @Published var companyId: String = ""
    @Published var name: String = ""
    @Published var industry: String = ""
    @Published var address: String = ""
    @Published var hrTeam: [ObservableHR] = []
    @Published var companyProfile: String = ""
    @Published var permissions: [ObservablePermission] = []
    @Published var superAdminUser: String = ""
    @Published var superAdminPwd: String = ""
    @Published var jobList: [ObservableJob] = []
}

class ObservableJob: ObservableObject {
    @Published var jobId: String = ""
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var company: String = ""
    @Published var location: String = ""
    @Published var type: String = ""
    @Published var postedOn: String = ""
    @Published var salaryMonth: String = ""
    init() {}
    
    init(jobId: String, title: String, description: String, company: String, location: String, type: String, postedOn: String, salaryMonth: String) {
        self.jobId = jobId
        self.title = title
        self.description = description
        self.company = company
        self.location = location
        self.type = type
        self.postedOn = postedOn
        self.salaryMonth = salaryMonth
    }
}

class ObservableHR: ObservableObject {
    @Published var personalInfo: ObservablePersonalInfo = ObservablePersonalInfo()
    @Published var accountInfo: AccountInfo = AccountInfo()
    @Published var hrId: String = ""
    @Published var permissions: [ObservablePermission] = []
}

class ObservablePermission: ObservableObject {
    @Published var resourceId: String = ""
    @Published var resourceType: String = "" // e.g. "Resume", "Interview", "Report"
    @Published var actions: [ObservableAction] = [] // e.g. "Read", "Write", "Delete"
}

class ObservableAction: ObservableObject {
    @Published var name: String = ""
    @Published var description: String = ""
}
