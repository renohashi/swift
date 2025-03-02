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
    
    // テキストメッセージの送信
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
    
    // 画像生成メソッドの追加
    func generateImage(prompt: String, completion: @escaping (UIImage?) -> Void) {
        let url = URL(string: "https://api.openai.com/v1/images/generations")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": modelname,
            "prompt": prompt,
            "n": 1,
            "size": "1024x1024"
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let dataArray = json["data"] as? [[String: String]],
               let imageUrlString = dataArray.first?["url"],
               let imageUrl = URL(string: imageUrlString) {
                let imageData = try? Data(contentsOf: imageUrl)
                DispatchQueue.main.async {
                    if let imageData = imageData {
                        completion(UIImage(data: imageData))
                    } else {
                        completion(nil)
                    }
                }
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
}
