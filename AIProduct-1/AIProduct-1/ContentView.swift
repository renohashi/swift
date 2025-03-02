import SwiftUI

struct ContentView: View {
    @State private var userInput: String = ""
    @State private var responseText: String = "ここにAIの返答が表示されます"
    @State var isShowDailog = false
    @State var modelnames = "gpt-3.5-turbo" // 初期モデル名
    @State var showImageModal = false // 画像モーダル表示用
    @State var generatedImage: UIImage? = nil // 生成された画像用
    @State var isSending = false // 送信中かどうか
    
    private var openAIAPI: OpenAIAPI
    
    init() {
        openAIAPI = OpenAIAPI(modelname: "gpt-3.5-turbo")
    }
    
    var body: some View {
        ZStack {
            VStack {
                Text("AIPIPE")
                    .font(.title)
                    .padding()
                
                TextField("メッセージを入力...", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: {
                    sendMessage()
                }) {
                    HStack {
                        if isSending {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("送信")
                        }
                    }
                    .padding()
                    .background(isSending ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .disabled(isSending)
                
                TextEditor(text: $responseText)
                    .padding()
                    .frame(height: 200)
                    .border(Color.gray, width: 1)
                    .frame(maxHeight: 300)
                
                Spacer()
                Button("モデル選択: \(modelnames)") {
                    isShowDailog = true
                }
                .padding()
            }
            .padding()
            
            if showImageModal {
                ImageGenerationModal(image: $generatedImage, isPresented: $showImageModal)
                    .zIndex(1)  // モーダルを最前面に表示
            }
        }
        .confirmationDialog("タイトル", isPresented: $isShowDailog) {
            Button("gpt3.5-turbo") {
                modelnames = "gpt-3.5-turbo"
                openAIAPI.modelname = "gpt-3.5-turbo"
            }
            Button("gpt-4-turbo") {
                modelnames = "gpt-4-turbo"
                openAIAPI.modelname = "gpt-4-turbo"
            }
            Button("gpt-4.5-preview") {
                modelnames = "gpt-4.5-preview"
                openAIAPI.modelname = "gpt-4.5-preview"
            }
            Button("dall-e-3") {
                modelnames = "dall-e-3"
                openAIAPI.modelname = "dall-e-3"
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    func sendMessage() {
        isSending = true
        
        if modelnames == "dall-e-3" {
            openAIAPI.generateImage(prompt: userInput) { image in
                DispatchQueue.main.async {
                    if let image = image {
                        self.generatedImage = image
                        self.showImageModal = true
                    } else {
                        self.responseText = "画像生成に失敗しました"
                    }
                    isSending = false
                }
            }
        } else {
            openAIAPI.sendMessage(message: userInput) { response in
                DispatchQueue.main.async {
                    if let response = response {
                        self.responseText = response
                    } else {
                        self.responseText = "エラーが発生しました"
                    }
                    isSending = false
                }
            }
        }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ImageGenerationModal: View {
    @Binding var image: UIImage?
    @Binding var isPresented: Bool
    @State private var zoomedIn = false
    
    var body: some View {
        VStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)  // 親ビューに合わせて広げる
                    .scaleEffect(zoomedIn ? 2 : 1)
                    .onTapGesture {
                        zoomedIn.toggle()
                    }
                    .padding()
            } else {
                Text("画像の生成中...")
                    .padding()
            }
            
            Button("閉じる") {
                isPresented = false
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(8)
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)  // モーダル全体を広げる
        .background(Color.black.opacity(0.8))  // 背景を濃くしてフルスクリーン感を強調
        .edgesIgnoringSafeArea(.all)  // 画面全体を使う
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
