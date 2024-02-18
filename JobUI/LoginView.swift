//
//  LoginView.swift
//  JobUI
//
//  Created by 宋炫熠 on 2024/2/8.
//

import SwiftUI


struct LoginView: View {
    @StateObject var viewModel = LoginViewModel()
    @StateObject var companyViewModel = CompanyAuthViewModel()
    @State private var loginType: LoginType = .personal
    @State private var isAuthenticated: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                if loginType == .personal {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipped()
                        .padding(.top, 50)
                } else {
                    Image(systemName: "house.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipped()
                        .padding(.top, 50)
                }
                

                VStack(spacing: 15) {
                    TextField("账号", text: $viewModel.phoneNumber)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding([.horizontal, .top])

                    SecureField("密码", text: $viewModel.password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                }

                Picker("Login Type", selection: $loginType) {
                    Text("我要求职").tag(LoginType.personal)
                    Text("我要招聘").tag(LoginType.business)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                Button(action: {
                    if loginType == .personal {
                        viewModel.login { success in
                            saveLoginType(type: loginType)
                            self.isAuthenticated = success
                        }
                    }
                    else {
                        companyViewModel.login(username: viewModel.phoneNumber, password: viewModel.password) { success in
                            saveLoginType(type: loginType)
                            self.isAuthenticated = success
                        }
                    }
                }) {
                    Text("登陆")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
                .alert(isPresented: $viewModel.showErrorAlert) {
                    Alert(title: Text("Error"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("OK")))
                }
                .alert(isPresented: $companyViewModel.showErrorAlert, content: {
                    Alert(title: Text("Error"), message: Text(companyViewModel.errorMessage), dismissButton: .default(Text("OK")))
                })
                .fullScreenCover(isPresented: $isAuthenticated) {
                    if viewModel.loadLoginType() == .personal {
                        ApplicantContentView()
                    } else {
                        CompanyContentView()
                    }
                }


                NavigationLink(destination: RegisterView()) {
                    Text("注册")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .padding(.bottom, 50)

                Spacer()
            }
            .navigationTitle("请登陆")
        }
        .onAppear {
            if viewModel.isLoggedIn() {
                self.loginType = viewModel.loadLoginType()
                if self.loginType == .personal {
                    self.isAuthenticated = viewModel.isLoggedIn()
                }
                else {
                    self.isAuthenticated = companyViewModel.isHRLoggedIn()
                }
            }
        }
    }
}

struct RegisterView: View {
    @ObservedObject var viewModel = RegisterViewModel()
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("手机号码")
                    .frame(width: 80, alignment: .leading)
                TextField("", text: $viewModel.phoneNumber)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Spacer()
            }
            
            HStack {
                Text("性别")
                    .frame(width: 80, alignment: .leading)
                Picker("Gender", selection: $viewModel.selectedGenderIndex) {
                    ForEach(0..<viewModel.genders.count, id: \.self) { index in
                        Text(self.viewModel.genders[index]).tag(index)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                Spacer()
            }

            HStack {
                Text("邮箱")
                    .frame(width: 80, alignment: .leading)
                TextField("", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Spacer()
            }

            HStack {
                Text("密码")
                    .frame(width: 80, alignment: .leading)
                SecureField("", text: $viewModel.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Spacer()
            }


            Button("注册") {
                viewModel.register { success in
                    if success {
                        // 注册成功，Alert将会显示
                    } else {
                        // 处理注册失败的情况
                    }
                }
            }
            .disabled(!viewModel.validateInputs())
            .alert(isPresented: $viewModel.isRegistrationSuccessful) {
                Alert(
                    title: Text("注册成功"),
                    message: Text("您的账户已成功注册。"),
                    dismissButton: .default(Text("返回登录")) {
                        // 用户点击确认后返回登录界面
                        self.presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }
        .padding()
        .navigationTitle("注册")
    }
}



#Preview {
    LoginView()
}
