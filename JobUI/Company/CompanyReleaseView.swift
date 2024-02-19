//
//  CompanyReleaseView.swift
//  聚才谷
//
//  Created by 宋炫熠 on 2024/2/14.
//

import SwiftUI

struct CompanyReleaseView: View {
    
    @ObservedObject var viewModel = HrJobViewModel()
    @State private var showingJobPostingView = false
    
    var body: some View {
        NavigationView {
            List(viewModel.jobs) { job in
                NavigationLink(destination: JobDetailView(job: job)) {
                    VStack(alignment: .leading) {
                        Text(job.title)
                            .font(.headline)
                        Text(job.jobId)
                            .font(.headline)
                        Text(job.company)
                            .font(.subheadline)
                    }
                }
            }
            .navigationTitle("职位列表")
            .navigationBarItems(trailing: Button(action: {
                showingJobPostingView.toggle()
            }) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $showingJobPostingView) {
                JobPostingView()
            }
        }
        .onAppear {
            viewModel.loadJobs()
        }
    }
}

#Preview {
    CompanyReleaseView()
}

struct JobPostingView: View {
    @ObservedObject var viewModel = JobPostingViewModel()
    @State private var message = ""
    @State private var postJobMessage = ""
    @State private var showingPostJobMessageAlter: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("职位信息")) {
                    TextField("职位名称", text: $viewModel.jobTitle)
                    TextField("职位要求", text: $viewModel.jobDescription)
                    TextField("工作地点", text: $viewModel.jobLocation)
                    TextField("职位类型", text: $viewModel.jobType)
                    TextField("月薪", text: $viewModel.jobSalaryMonth)
                }
                
                Button("提交职位") {
                    viewModel.postJob { success, msg in
                        self.message = msg
                        if success {
                            postJobMessage = "提交成功"
                        } else {
                            postJobMessage = "提交失败, 请重试"
                        }
                        showingPostJobMessageAlter = true
                    }
                }
            }
            .navigationBarTitle("发布职位")
            
        }
        .alert(isPresented: .constant(!message.isEmpty), content: {
            Alert(title: Text("提示"), message: Text(message), dismissButton: .default(Text("确定")) {
                self.message = ""
            })
        })
        .alert(isPresented: $showingPostJobMessageAlter) {
            Alert(title: Text("提交结果"), message: Text(postJobMessage), dismissButton: .default(Text("确定")) {
                self.postJobMessage = ""
            })
        }
    }
}

struct JobDetailView: View {
    @State var job: Job
    @ObservedObject var viewModel = HrJobViewModel()
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        Form {
            TextField("标题", text: $job.title)
            TextField("描述", text: $job.description)
            TextField("地点", text: $job.location)
            TextField("类型", text: $job.type)
            TextField("月薪", text: $job.salaryMonth)
            Button("保存更新") {
                viewModel.updateJob(job: job) { success, message in
                    alertMessage = message
                    showAlert = true
                    if success {
                        
                    }
                }
            }
        }
        .navigationTitle(job.title)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("修改结果"), message: Text(alertMessage), dismissButton: .default(Text("确定")) {
                self.alertMessage = ""
            })
        }
    }
}
