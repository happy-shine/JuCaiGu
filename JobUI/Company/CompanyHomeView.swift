//
//  CompanyHomeView.swift
//  聚才谷
//
//  Created by 宋炫熠 on 2024/2/14.
//

import SwiftUI

struct CompanyHomeView: View {
    @ObservedObject var viewModel = ApplicantListViewModel()
    @State private var searchKeyword: String = ""

    var body: some View {
        VStack {
            HStack {
                TextField("Search for applicant...", text: $searchKeyword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: {
                    if self.searchKeyword.isEmpty {
                        viewModel.fetchApplicants()
                    } else {
                        viewModel.searchApplicants(keyword: searchKeyword)
                    }
                }) {
                    Image(systemName: "magnifyingglass")
                }
                .padding(.trailing)
            }

            ScrollView {
                VStack {
                    ForEach(viewModel.applicants, id: \.accountInfo.userId) { applicant in
                        ApplicantCardView(viewModel: viewModel, applicant: applicant)
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchApplicants()
        }
    }
}



struct ApplicantCardView: View {
    @State private var showingDocumentprev: Bool = false
    @State private var showingMoreInfo: Bool = false
    @State private var isTrash: Bool = false
    @State private var isFavorite = false
    @ObservedObject var viewModel: ApplicantListViewModel
    var applicant: Applicant

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(applicant.personalInfo.name)
                    .font(.headline)
                Spacer()
                if let education = applicant.resume.education.first {
                    Text("学历: \(education.schoolName) (\(education.degree))")
                        .font(.caption)
                }
                
            }
            Divider()
            Text(applicant.personalInfo.biography)
                .font(.body)
                .lineLimit(showingMoreInfo ? nil : 3)
            HStack {
                Text("技能: \(applicant.resume.skills.joined(separator: ", "))")
                    .font(.caption)
                Spacer()
            }
            
            HStack {
                Button(action: {
                    // 收藏或取消收藏的逻辑
                    self.isFavorite.toggle()
                    self.isTrash = false
                    let status = self.isFavorite ? "1" : "-1024"
                    viewModel.manageTalentPool(userId: applicant.accountInfo.userId, status: status)
                }) {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .foregroundColor(isFavorite ? .yellow : .gray)
                    Text("人才库")
                }
                Spacer()
                Button(action: {
                    self.isTrash.toggle()
                    self.isFavorite = false
                    let status = self.isTrash ? "-1" : "-1024"
                    viewModel.manageTalentPool(userId: applicant.accountInfo.userId, status: status)
                }) {
                    Image(systemName: isTrash ? "arrow.up.trash.fill": "arrow.up.trash")
                        .foregroundColor(isTrash ? .gray : .black)
                    Text("黑名单")
                }
                Spacer()
                Button(action: {
                    self.showingDocumentprev = true
                }) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .foregroundColor(.black)
                    Text("查看简历")
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.horizontal)
        .onTapGesture {
            withAnimation(.easeInOut) {
                self.showingMoreInfo.toggle()
            }
        }
        .sheet(isPresented: $showingDocumentprev) {
            if let pdfUrl = URL(string: applicant.resume.attachment) {
                PDFViewer(url: pdfUrl)
            } else {
                Text("该求职者暂未上传简历")
            }
        }
    }
}


#Preview {
    CompanyHomeView()
}
