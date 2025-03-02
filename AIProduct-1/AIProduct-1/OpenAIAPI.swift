import Foundation
import SwiftUI

struct OpenAIRequest: Codable {
    let model: String
    let messages: [[String: String]]
    let max_tokens: Int
}

struct OpenAIResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
        
        struct Message: Codable {
            let role: String
            let content: String
        }
    }
}

class OpenAIAPI {
    var modelname: String  // モデル名をプロパティとして保持
    
    // 初期化時にモデル名を渡す
    init(modelname: String) {
        self.modelname = modelname
    }
    private let apiKey = ""
    
    func sendMessage(message: String, completion: @escaping (String?) -> Void) {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = OpenAIRequest(
            model: modelname,
            messages: [["role": "user", "content": message]],
            max_tokens: 3000
        )
        
        request.httpBody = try? JSONEncoder().encode(requestBody)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            let result = try? JSONDecoder().decode(OpenAIResponse.self, from: data)
            DispatchQueue.main.async {
                completion(result?.choices.first?.message.content)
            }
        }
        task.resume()
    }
}
