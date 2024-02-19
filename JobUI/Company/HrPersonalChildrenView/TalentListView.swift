//
//  TalentListView.swift
//  聚才谷
//
//  Created by 宋炫熠 on 2024/2/16.
//

import SwiftUI

struct TalentListView: View {
    @ObservedObject var viewModel = TalentViewModel()

    var isBlackList: Bool

    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.applicants, id: \.accountInfo.userId) { applicant in
                    ApplicantCardView(viewModel: ApplicantListViewModel(), applicant: applicant)
                }
            }
        }
        .onAppear {
            viewModel.fetchTalents(isBlackList: isBlackList)
        }
    }
}

#Preview {
    TalentListView(isBlackList: false)
}


struct TalentCardView: View {
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
                .lineLimit(3)
            HStack {
                Text("技能: \(applicant.resume.skills.joined(separator: ", "))")
                    .font(.caption)
                Spacer()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
}

