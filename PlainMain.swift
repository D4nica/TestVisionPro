//
//  MainView.swift
//  TestVisionPro
//
//  Created by Sunniva L on 7/17/24.
///Listen to audio, output the transcription and send to python file
///(slide is captured by casting)
///Display augmented captions from python file outputs that is sent back to here
/////  Mac terminal start server command: python3 -m http.server 8080
//  Mac terminal check ip address command: ipconfig getifaddr en0
//

import Foundation
import SwiftUI
import AVFoundation

struct PlainMainView: View {
    @StateObject var speechRecognizer = SpeechRecognition()
    @State private var isRecording : Bool = false
    private var player: AVPlayer { AVPlayer.sharedDingPlayer }
    @State private var TestImage: UIImage?
    
    @State var NewAddedTranscript : String = ""
    @Binding var ShowImmersiveSpace: Bool
    @Binding var CurrentTranscript: String
    @Binding var CurrentCaptionHighlight: String
    @Binding var CurrentSlideHighlight: (Float, Float, Float, Float)
    @Binding var CurrentSummary: String
    @Binding var CurrentSlideNumber: String
    @Binding var captionEntityInitalized: Bool
    
    var body: some View {
        HStack {
            Button(action: {startTranscribe()})
            {Text("Start")
                    .frame(width: 150)
            }
            .background(isRecording ? Color.green : nil).cornerRadius(20)

            Spacer(minLength: 20)
            
            Button(action: {endTranscribe()})
            {Text("End")
                    .frame(width: 150)
            }
            
            .onAppear(){
                            startTranscribe() //START ONSET
            }
            .onDisappear(){
                //            stopcallFunc() //DONT STOP
            }
        }
    }
    func callUpdateTranscript() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { //Update slower
                processTranscript()
                callUpdateTranscript()
        }
    }
    
    func callUpdateServer(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { //Send faster
                _ = DataToServer(input: CurrentTranscript)
                print("-----> server current transcript: " + CurrentTranscript) //print("-->speechRecognizer: " + speechRecognizer.transcript)
                callUpdateServer()
        }
    }
    
    func callGetFromServer(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { //Receive faster
                DataFromServer {showImmersiveSpace_server, isRecording_server, slideNumber, captionHighlight, summary, slideHighlight in
                        print("Is Recording: \(isRecording_server)", " local: ", isRecording)
                        print("Slide Number: \(slideNumber)")
                        print("Caption Highlight: \(captionHighlight)")
                        print("Summary: \(summary)")
                        print("Slide Highlight: \(slideHighlight)")
                        if (isRecording == false && isRecording_server == true){
                            startTranscribe()
                            print("pressed start transcribe")
                        }
                        if (isRecording == true && isRecording_server == false){
                            endTranscribe()
                            print("pressed end transcribe")
                        }
                        ShowImmersiveSpace = showImmersiveSpace_server
                        CurrentSlideNumber = slideNumber
                        CurrentCaptionHighlight = captionHighlight
                        CurrentSlideHighlight.0 = slideHighlight.0
                        CurrentSlideHighlight.1 = slideHighlight.1
                        CurrentSlideHighlight.2 = slideHighlight.2
                        CurrentSlideHighlight.3 = slideHighlight.3
                        CurrentSummary = summary
                        callGetFromServer()

            }
        }
    }
    
    func stopcallFunc(){
        isRecording = false
    }
        
    private func startTranscribe() {
        player.seek(to: .zero)
        player.play()
        speechRecognizer.resetTranscript()
        speechRecognizer.startTranscribing()
        isRecording = true
        print("start transcribing")
        callUpdateTranscript()
        callUpdateServer()
        callGetFromServer()
        captionEntityInitalized = false
    }
    
    private func endTranscribe() {
        speechRecognizer.stopTranscribing()
        stopcallFunc()
        CurrentTranscript = ""
        captionEntityInitalized = true
    }
    
    private func processTranscript(){
        let SR_words : [String] = speechRecognizer.transcript.split(separator: " ").map { String($0)}
        var SR_words_checked : [String] = []
        for w in SR_words {
            SR_words_checked.append(checkCaptionEdgeCase(word: w))
        }
        CurrentTranscript = SR_words_checked.joined(separator: " ")//speechRecognizer.transcript //CleanTranscript(RawTranscript: speechRecognizer.transcript, Current: CurrentTranscript)
    }
    
}
