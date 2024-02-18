//
//  ApplicantChatView.swift
//  JobUI
//
//  Created by 宋炫熠 on 2024/2/7.
//

import SwiftUI

struct ApplicantChatView: View {
    @StateObject private var chatModel = ChatModel()
    @State private var messageText: String = ""
    @State private var showingSettings: Bool = false
    @State private var prompt: String = ""
    @State private var apikey: String = OPENAI_API_KEY
    
    init() {}
    
    init(prompt: String) {
        self._prompt = State(initialValue: prompt)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    LazyVStack {
                        ForEach(chatModel.messages, id: \.self) { message in
                            MessageCardView(message: message)
                        }
                    }
                }
                .padding()

                HStack {
                    TextField("输入消息...", text: $messageText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 36, height: 36)
                            .foregroundColor(.blue)
                    }
                    .disabled(messageText.isEmpty)
                }
                .padding(.horizontal)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        self.showingSettings.toggle()
                    }) {
                        Image(systemName: "gearshape.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                PromptSettingsView(prompt: $prompt, apikey: $apikey, showingSettings: $showingSettings)
            }
            .alert(isPresented: $chatModel.showError) {
                Alert(
                    title: Text("网络错误"),
                    message: Text("请重试。"),
                    dismissButton: .default(Text("好的"))
                )
            }
        }
    }

    func sendMessage() {
        if !prompt.isEmpty {
            chatModel.fetchReplyFromOpenAI(prompt: prompt, message: messageText, apikey: apikey)
            messageText = ""
        } else {
            self.showingSettings = true
        }
    }
}

struct MessageCardView: View {
    var message: Message
    var avatarBase64: String = ""
    
    init(message: Message) {
        self.message = message
        let loadedAppicant = loadApplicant()
        self.avatarBase64 = loadedAppicant.personalInfo.avatarBase64
    }
    
    var body: some View {
        HStack(alignment: .top) {
            if message.role == .user {
                if let uiImage = UIImage.fromBase64(self.avatarBase64) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(Color.gray, lineWidth: 1)
                        )
                        .padding(.horizontal)
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(Color.gray, lineWidth: 1)
                        )
                        .padding(.horizontal)
                }
                
                Text(message.content)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            else if message.role == .assistant {
                Image("openaiIcon")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color.gray, lineWidth: 1)
                    )
                    .padding(.horizontal)
                
                Text(message.content)
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.black)
                    .cornerRadius(10)
            }
            


            Spacer()
        }
    }
}

struct PromptSettingsView: View {
    @Binding var prompt: String
    @Binding var apikey: String
    @Binding var showingSettings: Bool

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("openai api key")) {
                    TextField("输入您的apikey", text: $apikey)
                }
                
                Section(header: Text("岗位要求")) {
                    TextEditor(text: $prompt)
                        .frame(minHeight: 300)
                }
                
                Section {
                    Button("确认") {
                        showingSettings.toggle()
                    }
                }
            }
            .navigationTitle("请先输入岗位要求")
        }
    }
}

struct ApplicantChatView_Previews: PreviewProvider {
    static var previews: some View {
        ApplicantChatView()
    }
}


#Preview {
    ApplicantChatView()
}
