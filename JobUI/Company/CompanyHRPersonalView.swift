//
//  CompanyHRPersonalView.swift
//  聚才谷
//
//  Created by 宋炫熠 on 2024/2/14.
//

import SwiftUI

struct CompanyHRPersonalView: View {
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
        
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    if let uiImage = UIImage.fromBase64("") {
                        Image(uiImage: uiImage)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "house.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("浙江聚创方舟科技有限公司")
                            .font(.headline)
                            .lineLimit(1)
                        Text("宋炫熠")
                            .font(.title3)
                            
                    }
                }
                .padding()
                
                List {

                    NavigationLink(destination: TalentListView(isBlackList: false)) {
                        HStack {
                            Image(systemName: "person.and.background.striped.horizontal")
                            Text("人才库")
                        }
                    }
                    
                    NavigationLink(destination: TalentListView(isBlackList: true)) {
                        HStack {
                            Image(systemName: "list.bullet.circle.fill")
                            Text("黑名单")
                        }
                    }
                    
                    NavigationLink(destination: ResumeApprovalView()) {
                        HStack {
                            Image(systemName: "doc.text.magnifyingglass")
                            Text("简历审批")
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
                            self.showingLoginView = true
                            self.isRefreshToggle.toggle()
                        }
                        .foregroundColor(Color.red)
                    }
                }
                Spacer()
            }
            .navigationBarTitle("我的", displayMode: .inline)
            .fullScreenCover(isPresented: $showingLoginView) {
                LoginView()
            }
        }
    }
}

struct BlackListView: View {
    var body: some View {
        Text("这是我的公司")
    }
}

struct ResumeApprovalView: View {
    var body: some View {
        Text("这是我的公司")
    }
}

#Preview {
    CompanyHRPersonalView()
}
