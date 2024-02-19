//
//  ApplicantPersonView.swift
//  JobUI
//
//  Created by 宋炫熠 on 2024/2/7.
//

import SwiftUI



struct ApplicantPersonView: View {
    @State private var showingActionSheet = false
    @State private var showingEditPersonalInfo = false
    @State private var showingImagePicker = false
    @State private var selectedImageBase64: String?
    @State private var showingLoginView = false
    @State private var isRefreshToggle: Bool = false
    @State private var showingDocumentPicker: Bool = false
    @State private var showingDocumentprev: Bool = false
    @State private var uploadMessage: String = ""
    @State private var showingUploadMessage: Bool = false
    @State private var showingDocPrevAlter: Bool = false
    @State private var showingResumeSuggestSheet: Bool = false
    @State private var showingResumeSuggestAlter: Bool = false
    
    @StateObject private var viewModel = LoginViewModel()
    @StateObject private var chatViewModel = ChatModel()
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button(action: {
                        if UserDefaults.standard.string(forKey: "authToken") == nil {
                            // 如果 authToken 为空，跳转到登录界面
                            self.showingLoginView = true
                        } else {
                            // 否则显示 ActionSheet
                            self.showingActionSheet = true
                        }
                    }) {
                        if let uiImage = UIImage.fromBase64(viewModel.obApplicant.personalInfo.avatarBase64) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                        }
                        Spacer()
                        Text(viewModel.obApplicant.personalInfo.name)
                    }
                    .actionSheet(isPresented: $showingActionSheet) {
                        ActionSheet(title: Text("选择操作"), buttons: [
                            .default(Text("修改头像")) {
                                self.showingImagePicker = true
                            },
                            .default(Text("修改个人信息")) {
                                self.showingEditPersonalInfo = true
                            },
                            .cancel()
                        ])
                    }
                    .fullScreenCover(isPresented: $showingLoginView) {
                        LoginView()
                    }
                    
                    Spacer()
                }
                .padding()
                .sheet(isPresented: $showingEditPersonalInfo) {
                    EditPersonalInfoView(showingEditPersonalInfo: $showingEditPersonalInfo, loginViewModel: viewModel)
                }
                .sheet(isPresented: $showingImagePicker) {
                    ImagePicker(selectedImageBase64: self.$selectedImageBase64) {
                        let personalInfoView = PersonalInfoViewModel()
                        personalInfoView.personalInfo.avatarBase64 = selectedImageBase64 ?? ""
                        personalInfoView.updatePersonalInfo { success in
                                
                        }
                    }
                }
                .sheet(isPresented: $showingDocumentPicker) {
                    DocumentPicker { url in
                        self.uploadDocument(url: url)
                    }
                }
                .sheet(isPresented: $showingDocumentprev) {
                    if let pdfUrl = URL(string: viewModel.obApplicant.resume.attachment) {
                        PDFViewer(url: pdfUrl)
                    } else {
                        Text("无法加载PDF文件。")
                    }
                }
                .sheet(isPresented: $showingResumeSuggestSheet) {
                    ScrollView {
                        Text(chatViewModel.resumeSuggest)
                    }
                }
                
                List {
                    NavigationLink(destination: ResumeView()) {
                        HStack {
                            Image(systemName: "doc.richtext")
                            Text("完善简历")
                        }
                    }
                    
                    HStack {
                        Image(systemName: "doc.badge.arrow.up")
                        Button("附件简历上传") {
                            self.showingDocumentPicker = true
                        }
                    }
                    .alert(isPresented: $showingUploadMessage) {
                        Alert(title: Text("上传结果"), message: Text(uploadMessage), dismissButton: .default(Text("好的")))
                    }
                    
                    HStack {
                        Image(systemName: "doc")
                        Button("预览附件简历") {
                            if viewModel.obApplicant.resume.attachment == "" {
                                self.showingDocPrevAlter = true
                            } else {
                                self.showingDocumentprev = true
                            }
                        }
                    }
                    .alert(isPresented: $showingDocPrevAlter) {
                        Alert(title: Text("预览简历"), message: Text("您还没有上传简历"), dismissButton: .default(Text("好的")))
                    }
                    
                    HStack {
                        Image(systemName: "ellipsis.bubble")
                        Button("简历优化建议") {
                            if viewModel.obApplicant.resume.resumeString == "" {
                                self.showingResumeSuggestAlter = true
                            } else {
                                chatViewModel.getResumeGPTSuggest(resumeString: viewModel.obApplicant.resume.resumeString)
                                self.showingResumeSuggestSheet = true
                            }
                        }
                    }
                    .alert(isPresented: $showingResumeSuggestAlter) {
                        Alert(title: Text("简历优化建议"), message: Text("您还没有上传简历"), dismissButton: .default(Text("好的")))
                    }
                    
                    NavigationLink(destination: JobApplicationsView()) {
                        HStack {
                            Image(systemName: "doc.questionmark.rtl")
                            Text("投递结果")
                        }
                    }
                    
                    NavigationLink(destination: AboutUsView()) {
                        HStack {
                            Image(systemName: "info.square")
                            Text("关于我们")
                        }
                    }
                    
                    HStack {
                        Image(systemName: "exclamationmark.shield")
                        Button("退出登录") {
                            UserDefaults.standard.removeObject(forKey: "authToken")
                            UserDefaults.standard.removeObject(forKey: "loginType")
                            UserDefaults.standard.removeObject(forKey: "applicant")
                            viewModel.refreshData()
                            self.showingLoginView = true
                            self.isRefreshToggle.toggle()
                        }
                        .foregroundColor(Color.red)
                    }
                }
                Spacer()
            }
            .navigationBarTitle("我的", displayMode: .inline)
        }
    }
    
    func uploadDocument(url: URL) {
        guard let token = UserDefaults.standard.string(forKey: "authToken") else { return }
        
        let filename = url.lastPathComponent
        let fileData = try? Data(contentsOf: url)
        var request = URLRequest(url: URL(string: "\(BASE_URL)/upload-resume")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        var data = Data()
        
        if let fileData = fileData {
            data.append("--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"resume\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
            data.append("Content-Type: application/pdf\r\n\r\n".data(using: .utf8)!)
            data.append(fileData)
            data.append("\r\n".data(using: .utf8)!)
        }
        
        data.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = data

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.uploadMessage = "上传失败: \(error.localizedDescription)"
                    self.showingUploadMessage = true
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    self.uploadMessage = "上传成功"
                    self.showingUploadMessage = true
                }
            } else {
                DispatchQueue.main.async {
                    self.uploadMessage = "上传失败: \(response.debugDescription)"
                    self.showingUploadMessage = true
                }
            }
        }
        task.resume()
    }
}

struct AboutUsView: View {
    var body: some View {
        Text("本 app 由 happy-shine 开发")
    }
}

#Preview {
    ApplicantPersonView()
}
