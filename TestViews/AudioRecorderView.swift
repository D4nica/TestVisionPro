

import Foundation
import SwiftUI
import AVFoundation

struct AudioRecorderView: View {
    @StateObject var speechRecognizer = SpeechRecognition()
    @State private var isRecording = false
    private var player: AVPlayer { AVPlayer.sharedDingPlayer }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16.0).fill(.black)
            VStack {
                    Button("Start"){startScrum()}
                    Button("End"){endScrum()}
                    Text("Transcript: " + speechRecognizer.transcript)
            }
        }
        .padding()
        .onAppear {
            print("Appeared")
        }
        .onDisappear {
            print("Disappeared")
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    private func startScrum() {
        player.seek(to: .zero)
        player.play()
        speechRecognizer.resetTranscript()
        speechRecognizer.startTranscribing()
        isRecording = true
    }
    
    private func endScrum() {
        speechRecognizer.stopTranscribing()
        isRecording = false
    }
    
}

struct MeetingView_Previews: PreviewProvider {
    static var previews: some View {
        AudioRecorderView()
    }
}

