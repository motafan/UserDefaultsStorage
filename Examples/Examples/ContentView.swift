//
//  ContentView.swift
//  Examples
//
//  Created by 风起兮 on 2024/11/14.
//

import SwiftUI
import UserDefaultsStorage

struct ContentView: View {
   
    @AppStorage("int") var value: Int = 0
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world! \(value)")
            
            Button(action: {
                value = 18
            }) {
                Text("Set value")
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
