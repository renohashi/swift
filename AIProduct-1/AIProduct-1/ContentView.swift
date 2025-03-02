import SwiftUI

struct ContentView: View {
    @State private var userInput: String = ""
    @State private var responseText: String = "ここにAIの返答が表示されます"
    @State var isShowDailog = false
    @State var modelnames = "gpt-3.5-turbo" // 初期モデル名
    private var openAIAPI: OpenAIAPI
    
    init() {
        // OpenAIAPIを初期化し、modelnamesを渡す
        openAIAPI = OpenAIAPI(modelname: "gpt-3.5-turbo")
    }
    
    var body: some View {
        VStack {
            Text("RenRenAI")
                .font(.title)
                .padding()
            
            TextField("メッセージを入力...", text: $userInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("送信") {
                sendMessage()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            
            // TextEditor を使って返答を修正可能にする
            TextEditor(text: $responseText)
                .padding()
                .frame(height: 200) // 高さを設定
                .border(Color.gray, width: 1)
            .frame(maxHeight: 300) // 高さを制限
            
            Spacer()
            Button("モデル選択: \(modelnames)") {
                isShowDailog = true
            }
            .padding()
        }
        .padding()
        .confirmationDialog("タイトル", isPresented: $isShowDailog) {
            Button("gpt3.5-turbo") {
                modelnames = "gpt-3.5-turbo"
                openAIAPI.modelname = "gpt-3.5-turbo" // モデルを変更
            }
            Button("gpt-4-turbo") {
                modelnames = "gpt-4-turbo"
                openAIAPI.modelname = "gpt-4-turbo" // モデルを変更
            }
            Button("gpt-4.5-preview") {
                modelnames = "gpt-4.5-preview"
                openAIAPI.modelname = "gpt-4.5-preview" // モデルを変更
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    func sendMessage() {
        openAIAPI.sendMessage(message: userInput) { response in
            DispatchQueue.main.async {
                if let response = response {
                    self.responseText = response
                } else {
                    self.responseText = "エラーが発生しました"
                }
            }
        }
    }
    // キーボードを閉じるための関数
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
