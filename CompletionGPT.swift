//
//  CompletionGPT.swift
//  TestVisionPro
//
//  Created by Sunniva L on 7/1/24.
//

import Foundation
import SwiftUI
import OpenAI


//Chat Model
final class ViewModel: ObservableObject {

    init(){}

    private var client: OpenAI?

    func initialize(){
        client = OpenAI(apiToken: "sk-proj-bJTn2urR0jcU1yDbrK9TT3BlbkFJgQxD2N070INz8rBoBFQn")
    }

    func send(text: String, completion: @escaping (String) -> Void ) {
        let Systemmsg: ChatQuery.ChatCompletionMessageParam = .user(.init(content: .string("I am a Deaf user. Please be my personal assistant today.")))
        let Usermsg: ChatQuery.ChatCompletionMessageParam = .user(.init(content: .string(text)))
        let query = ChatQuery(messages: [Systemmsg,Usermsg], model: .gpt4_o) //gpt3_5Turbo
        client?.chats(query: query)
        { result in
            switch result {
            case .success(let success):
                let output = success.self
                print(output.choices)
                print(output.choices[0].message.content ?? "NULL")
                if let firstChoice = success.choices.first,
                    case let .assistant(assistantMessage) = firstChoice.message, let content = assistantMessage.content {completion(content)}
                else {completion("No content available.")}
                
            case .failure(let error):
                print(error.localizedDescription)
                completion("Completion error.")
            }
        }
    }
}

////Completion Model
//final class ViewModel: ObservableObject {
//    
//    init(){
//    }
//    
//    private var client: OpenAI?
//
//    func initialize(){
//        client = OpenAI(apiToken: "sk-proj-bJTn2urR0jcU1yDbrK9TT3BlbkFJgQxD2N070INz8rBoBFQn")
//    }
//
//    func send(text: String, completion: @escaping (CompletionsResult) -> Void ) {
//        let query = CompletionsQuery(model: .gpt4_o, prompt: text, temperature: 0, maxTokens: 100, topP: 1, frequencyPenalty: 0, presencePenalty: 0, stop: ["\\n"])
//        client?.completions(query: query)
//        { result in
//            switch result {
//            case .success(let success):
//                let output = success.self
//                completion(output)
//            case .failure(let error):
//                print(error.localizedDescription)
//            }
//        }
//    }
//}



