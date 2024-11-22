//
//  VisualizationView.swift
//  TestVisionPro
//
//  Created by Sunniva L on 7/2/24.
//
//  Putting everything together, server, transcript, prompt

import SwiftUI

struct VisualizationView: View {
    @ObservedObject var promptModel = SharedUserPrompt()
    
    var body: some View {
        Text("Hello, World!")
        GPTView()
            .frame(height: 300)
        
        AudioRecorderView()
        
        .onAppear {
            promptModel.prompt = "Hey type something"
        }
    }

}

#Preview {
    VisualizationView()
}
