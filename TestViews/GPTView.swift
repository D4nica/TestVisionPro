//
//  GPTView.swift
//  TestVisionPro
//
//  Created by Sunniva L on 7/1/24.
//

import SwiftUI

class SharedUserPrompt: ObservableObject {
    @Published var prompt: String = ""
}

struct GPTView: View {
    @ObservedObject var viewModel = ViewModel()
//    @State public var prompt = ""
    @ObservedObject var promptModel = SharedUserPrompt()
    
    @State var response = "Ask me anything"
    var body: some View {
        VStack(alignment: .leading) {
            Text(response)
            Spacer()
            HStack{
                TextField("Write a prompt...", text: $promptModel.prompt)
                Button("Send"){send()}
            }
        }
        .padding()
        .task {
            viewModel.initialize()
        }
    }
    
    func send(){
        guard !promptModel.prompt.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let promptToSend = promptModel.prompt
        promptModel.prompt = ""
        viewModel.send(text: promptToSend) { response in
            DispatchQueue.main.async {
                self.response = response //.choices.first?.text ?? "no response"
                
            }
        }
    }
}



#Preview {
    GPTView()
}





