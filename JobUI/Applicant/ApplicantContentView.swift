//
//  ApplicantContentView.swift
//  JobUI
//
//  Created by 宋炫熠 on 2024/2/7.
//

import SwiftUI

// 主视图，包含底部导航栏
struct ApplicantContentView: View {
    var body: some View {
        TabView {
            ApplicantHomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("找工作")
                }
            ApplicantChatView()
                .tabItem {
                    Image(systemName: "lasso.badge.sparkles")
                    Text("模拟面试")
                }
            ApplicantPersonView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("我的")
                }
        }
    }
}


#Preview {
    ApplicantContentView()
}
