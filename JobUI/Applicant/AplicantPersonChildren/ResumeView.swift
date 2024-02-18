//
//  ResumeView.swift
//  聚才谷
//
//  Created by 宋炫熠 on 2024/2/14.
//

import SwiftUI
import UIKit
import PDFKit

struct ResumeView: View {
    @StateObject var viewModel = ResumeViewModel()
    @State private var showingDocumentPicker = false
    
    let degrees = ["小学", "初中", "高中", "大专", "本科", "硕士", "博士"]
    let industries = ["互联网", "硬件", "机械", "IT", "金融", "农业", "化工", "教育","其他行业"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("教育背景")) {
                    ForEach($viewModel.resume.education.indices, id: \.self) { index in
                        VStack {
                            EducationView(education: $viewModel.resume.education[index], degrees: degrees)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding([.horizontal, .top])
                    }
                    .onDelete(perform: viewModel.removeEducation)
                    
                    Button(action: {
                        viewModel.addEducation()
                    }) {
                        Image(systemName: "plus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.blue)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                Section(header: Text("技术栈")) {
                    ForEach($viewModel.resume.skills.indices, id: \.self) { index in
                        TextField("技能", text: $viewModel.resume.skills[index])
                    }
                    .onDelete(perform: viewModel.removeSkill)
                    
                    Button(action: {
                        viewModel.addSkill()
                    }) {
                        Image(systemName: "plus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.blue)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                Section(header: Text("工作经验")) {
                    ForEach($viewModel.resume.workExperience.indices, id: \.self) { index in
                        VStack {
                            WorkExperienceView(workExperience: $viewModel.resume.workExperience[index], industries: industries)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding([.horizontal, .top])
                    }
                    .onDelete(perform: viewModel.removeWorkExperience)
                    
                    Button(action: {
                        viewModel.addWorkExperience()
                    }) {
                        Image(systemName: "plus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.blue)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                Button(action: {
                    viewModel.updateResume { _ in
                        
                    }
                }) {
                    Text("保存修改")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle("简历填写")
            .onDisappear {
                viewModel.refreshData()
            }
        }
    }
}

struct EducationView: View {
    @Binding var education: Education
    var degrees: [String]
    @State private var startDate = Date()
    @State private var endDate = Date()
    
    var body: some View {
        Picker("学位", selection: $education.degree) {
            ForEach(degrees, id: \.self) { degree in
                Text(degree).tag(degree)
            }
        }
        TextField("学校名称", text: $education.schoolName)
        TextField("专业", text: $education.major)
        DatePicker("开始日期", selection: $startDate, displayedComponents: .date)
            .onAppear {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                if let date = dateFormatter.date(from: education.startDate) {
                    self.startDate = date
                }
            }
            .onChange(of: startDate) { newStartDate, oldValue in
                let dateString = dateFormatter(date: newStartDate)
                education.startDate = dateString
            }
        DatePicker("结束日期", selection: $endDate, displayedComponents: .date)
            .onAppear {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                if let date = dateFormatter.date(from: education.endDate) {
                    self.endDate = date
                }
            }
            .onChange(of: endDate) { newStartDate, oldValue in
                let dateString = dateFormatter(date: newStartDate)
                education.endDate = dateString
            }
    }
}

struct WorkExperienceView: View {
    @Binding var workExperience: WorkExperience
    var industries: [String]
    @State private var startDate = Date()
    @State private var endDate = Date()
    
    
    var body: some View {
        TextField("公司名称", text: $workExperience.companyName)
        TextField("职位名称", text: $workExperience.positionName)
        DatePicker("开始日期", selection: $startDate, displayedComponents: .date)
            .onAppear {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                if let date = dateFormatter.date(from: workExperience.startDate) {
                    self.startDate = date
                }
            }
            .onChange(of: startDate) { newStartDate, oldValue in
                let dateString = dateFormatter(date: newStartDate)
                workExperience.startDate = dateString
            }
        DatePicker("结束日期", selection: $endDate, displayedComponents: .date)
            .onAppear {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                if let date = dateFormatter.date(from: workExperience.endDate) {
                    self.endDate = date
                }
            }
            .onChange(of: endDate) { newStartDate, oldValue in
                let dateString = dateFormatter(date: newStartDate)
                workExperience.endDate = dateString
            }
        Picker("行业", selection: $workExperience.industry) {
            ForEach(industries, id: \.self) { industry in
                Text(industry).tag(industry)
            }
        }
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    var callback: (URL) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf], asCopy: true)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // 不需要更新UIViewController
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            parent.callback(url)
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImageBase64: String?
    @Environment(\.presentationMode) var presentationMode
    var onImagePicked: () -> Void  // 定义一个回调闭包，图片选择后将调用它

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                if let imageData = image.jpegData(compressionQuality: 0.3) {
                    let base64String = imageData.base64EncodedString()
                    parent.selectedImageBase64 = base64String
                    parent.onImagePicked()  // 在这里调用闭包
                }
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
    }
}

struct PDFViewer: UIViewRepresentable {
    var url: URL

    // 创建并配置PDFView
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true // 自动缩放以适应视图
        return pdfView
    }

    // 更新PDFView的pdf文档
    func updateUIView(_ uiView: PDFView, context: Context) {
        if let document = PDFDocument(url: url) {
            uiView.document = document
        }
    }
}

extension UIImage {
    static func fromBase64(_ base64String: String) -> UIImage? {
        // 移除"data:image/png;base64,"前缀
        let base64StringWithoutPrefix = base64String.replacingOccurrences(of: "data:image/png;base64,", with: "")
        
        // 解码Base64字符串
        guard let imageData = Data(base64Encoded: base64StringWithoutPrefix) else { return nil }
        return UIImage(data: imageData)
    }
}

func dateFormatter(date: Date)-> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let dateString = dateFormatter.string(from: date)
    return dateString
}
