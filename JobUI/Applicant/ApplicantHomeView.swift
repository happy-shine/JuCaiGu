//
//  ApplicantHomeView.swift
//  JobUI
//
//  Created by 宋炫熠 on 2024/2/7.
//

import SwiftUI

struct ApplicantHomeView: View {
    @ObservedObject var viewModel = JobViewModel()
    @State private var searchKeyword: String = ""

    var body: some View {
        VStack {
            HStack {
                TextField("Search for jobs...", text: $searchKeyword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: {
                    if self.searchKeyword == "" {
                        viewModel.fetchJobs()
                    } else {
                        viewModel.searchJobs(keyword: searchKeyword)
                    }
                }) {
                    Image(systemName: "magnifyingglass")
                }
                .padding(.trailing)
            }

            ScrollView {
                VStack {
                    ForEach(viewModel.jobs, id: \.jobId) { job in
                        JobCardView(jobViewModel: viewModel, job: job)
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchJobs()
        }
    }
}

struct JobCardView: View {
    @State private var isFavorite: Bool = false
    @State private var showingJobInfo: Bool = false
    @State private var showingChatSheet: Bool = false
    @ObservedObject var jobViewModel: JobViewModel
    var job: Job
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(job.title)
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
                Text(job.salaryMonth)
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundColor(.blue)
            }
            Divider()
            Text(job.company)
                .font(.subheadline)
            Text(job.location)
                .font(.caption)
            Text(job.description)
                .font(.body)
                .lineLimit(showingJobInfo ? nil : 3)
                .contextMenu {
                    Button(action: {
                        UIPasteboard.general.string = job.description
                    }) {
                        Text("复制")
                        Image(systemName: "doc.on.doc")
                    }
                }
            Text("工作类型: \(job.type)")
                .font(.caption)
            Text("发布于: \(job.postedOn)")
                .font(.caption)
            
            if showingJobInfo {
                HStack(spacing: 20) {
                    Button(action: {
                        self.isFavorite.toggle()
                    }) {
                        Image(systemName: isFavorite ? "star.fill" : "star")
                            .foregroundColor(isFavorite ? .yellow : .gray)
                    }
                    Spacer()
                    Button(action: {
                        jobViewModel.applyForJob(jobId: job.jobId)
                    }) {
                        HStack {
                            Image(systemName: "paperplane")
                            Text("投递简历")
                        }
                    }
                    .alert(isPresented: $jobViewModel.isApplicationSuccessful) {
                        Alert(title: Text("投递成功"), message: Text("您已成功投递该职位"), dismissButton: .default(Text("好的")))
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 5)
        .padding(.horizontal)
        .onTapGesture {
            withAnimation(.easeInOut) {
                self.showingJobInfo.toggle()
            }
        }
        .contextMenu {
            Button(action: {
                self.showingChatSheet = true
            }) {
                Text("开始模拟面试")
                Image(systemName: "lasso.badge.sparkles")
            }
        }
        .sheet(isPresented: $showingChatSheet) {
            ApplicantChatView(prompt: "职位: \(job.title)\n职位要求: \(job.description)")
        }
    }
}

#Preview {
    ApplicantHomeView()
}
