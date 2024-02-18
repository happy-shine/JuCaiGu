//
//  EditPersonalInfoView.swift
//  聚才谷
//
//  Created by 宋炫熠 on 2024/2/14.
//

import SwiftUI

struct EditPersonalInfoView: View {
    @StateObject var viewModel: PersonalInfoViewModel = PersonalInfoViewModel()
    
    @State private var selectedDate: Date = Date()
    private let genders = ["男", "女"]
    
    @Binding var showingEditPersonalInfo: Bool
    @ObservedObject var loginViewModel: LoginViewModel
    
    
    var body: some View {
        Form {
            Section(header: Text("基本信息")) {
                TextField("姓名", text: $viewModel.personalInfo.name)
                
                DatePicker(
                   "出生日期",
                   selection: $selectedDate,
                   displayedComponents: .date
                )
                .onAppear {
                    // 当视图出现时，将字符串转换为 Date 对象并更新 selectedDate
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    if let date = dateFormatter.date(from: viewModel.personalInfo.birthDate) {
                        self.selectedDate = date
                    }
                }
                
                HStack {
                    Text("性别")
                    Spacer()
                    Picker("性别", selection: $viewModel.personalInfo.gender) {
                        ForEach(genders, id: \.self) { gender in
                            Text(gender).tag(gender) // 每个选项的标签
                        }
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                TextField("政治面貌", text: $viewModel.personalInfo.politicalStatus)
                TextField("意向职位", text: $viewModel.personalInfo.intendedPosition)
                TextField("个人简介", text: $viewModel.personalInfo.biography)
            }
            
            Section(header: Text("联系信息")) {
                TextField("当前居住地", text: $viewModel.personalInfo.currentResidence)
                TextField("户口所在地", text: $viewModel.personalInfo.hukouLocation)
                TextField("手机号码", text: $viewModel.personalInfo.phoneNumber)
                TextField("邮箱", text: $viewModel.personalInfo.email)
            }
            
            Button("保存修改") {
                viewModel.personalInfo.birthDate = dateFormatter(date: selectedDate)
                viewModel.updatePersonalInfo { _ in
                    loginViewModel.login { _ in }
                    print(loginViewModel.obApplicant.personalInfo.$name)
                }
                
                showingEditPersonalInfo.toggle()
            }
        }
        .navigationBarTitle("修改个人信息", displayMode: .inline)
    }
    
}
