//
//  JobApplicationsView.swift
//  聚才谷
//
//  Created by 宋炫熠 on 2024/2/19.
//

import SwiftUI

struct JobApplicationsView: View {
    @ObservedObject var viewModel = JobApplicationsViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.jobApplications) { application in
                    VStack(alignment: .leading) {
                        Text(application.jobTitle)
                            .font(.headline)
                        Text(application.company)
                            .font(.subheadline)
                        Text(application.location)
                            .font(.caption)
                        Text(application.status)
                            .font(.caption)
                            .foregroundColor(application.status == "Applied" ? .blue : .gray)
                    }
                }
            }
            .navigationBarTitle("已投递的工作")
            .onAppear {
                viewModel.fetchJobApplications()
            }
        }
    }
}
#Preview {
    JobApplicationsView()
}
