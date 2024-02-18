//
//  CompanyContentView.swift
//  聚才谷
//
//  Created by 宋炫熠 on 2024/2/14.
//

import SwiftUI

struct CompanyContentView: View {
    var body: some View {
        TabView {
            CompanyHomeView()
                .tabItem {
                    Image(systemName: "figure.wave")
                    Text("找人才")
                }
            CompanyReleaseView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("职位管理")
                }
            CompanyHRPersonalView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("我的")
                }
        }
    }
}

#Preview {
    CompanyContentView()
}
