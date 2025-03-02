//
//  ContentView.swift
//  HelloSwiftUI
//
//  Created by 大橋蓮 on 2025/02/28.
//

import SwiftUI

struct ContentView: View {
    @State var str = "Hello, SwiftUI"

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text(str)
                .foregroundColor(.red)
            Button("ボタン"){
                str = "ハローSwiftUI"
                print("ボタンが押されたよ")
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
