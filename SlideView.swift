//
//  SlideView.swift
//  TestVisionPro
//
//  Created by Sunniva L on 7/29/24.
//  Reference: // https://github.com/IvanCampos/visionOS-examples/blob/main/AnchorToslide/AnchorToslide
//

import Foundation
import SwiftUI
import RealityKit
import RealityKitContent
import ARKit

struct SlideView: View {
    @State private var immersiveSpaceIsShown = false

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    @Binding var ShowImmersiveSpace: Bool
    @Binding var CurrentTranscript: String
    @Binding var CurrentCaptionHighlight: String
    @Binding var CurrentSlideHighlight: (Float, Float, Float, Float)
    @Binding var CurrentSummary: String
    @Binding var CurrentSlideNumber: String
    @Binding var captionEntityInitalized: Bool

    var body: some View {
        
        //Load UI View
        VStack {
            Toggle("Show", isOn: $ShowImmersiveSpace)
                .font(.title)
                .frame(width: 360)
                .padding(24)
                .glassBackgroundEffect()
        }
        .padding(48)
        .onChange(of: ShowImmersiveSpace) { _, newValue in
            Task {
                if newValue {
                    switch await openImmersiveSpace(id: "ImageTracking") {
                    case .opened:
                        
                        immersiveSpaceIsShown = true
                        print("opened")
                    case .error, .userCancelled:
                        immersiveSpaceIsShown = false
                        print("error")
                    @unknown default:
                        immersiveSpaceIsShown = false
                    }
                } else if immersiveSpaceIsShown {
                    await dismissImmersiveSpace()
                    immersiveSpaceIsShown = false
                }
            }
        }
        
        PlainMainView(ShowImmersiveSpace:$ShowImmersiveSpace,CurrentTranscript:$CurrentTranscript, CurrentCaptionHighlight:$CurrentCaptionHighlight,CurrentSlideHighlight:$CurrentSlideHighlight,CurrentSummary:$CurrentSummary,CurrentSlideNumber:$CurrentSlideNumber, captionEntityInitalized:$captionEntityInitalized) //The other buttons


        //////        ///Debugging in preview (commented out in any build)
//        ImageTracking(CurrentTranscript:$CurrentTranscript, CurrentCaptionHighlight:$CurrentCaptionHighlight,CurrentSlideHighlight:$CurrentSlideHighlight,CurrentSummary:$CurrentSummary,CurrentSlideNumber:$CurrentSlideNumber, captionEntityInitalized: $captionEntityInitalized)

    }
}

extension UIColor {
    convenience init(hex: String) {
        
        let hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        
        var color: UInt64 = 0
        scanner.scanHexInt64(&color)
        
        let r = CGFloat((color & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((color & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(color & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}


//#Preview(windowStyle: .automatic) {
//    @Previewable @State var ShowImmersiveSpace: Bool = false
//    @Previewable @State var CurrentTranscript: String = "Today we're going to discuss how to handle real word spelling errors in natural language processing"
//    @Previewable @State var CurrentCaptionHighlight: String = "processing"
//    @Previewable @State var CurrentSlideHighlight: (Float, Float, Float, Float) = (-0.47, -0.275, 0.06, 0.01) //(-0.18, 0.17, 0.5, 0.01) //(-0.15, 0.095, 0.55, 0.01)
//    @Previewable @State var CurrentSummary: String = "Noisy Channel: The spelling data input that is unclear and fuzzy \n\n This slide is about spelling errors in real-world NLP practices."
//    @Previewable @State var CurrentSlideNumber: String =  "lec15-1"
//    
//    SlideView(ShowImmersiveSpace:$ShowImmersiveSpace,CurrentTranscript:$CurrentTranscript, CurrentCaptionHighlight:$CurrentCaptionHighlight, CurrentSlideHighlight:$CurrentSlideHighlight, CurrentSummary:$CurrentSummary, CurrentSlideNumber:$CurrentSlideNumber)
//
//        .frame(
//            minWidth: 200, maxWidth: 200,
//            minHeight: 200, maxHeight: 200, alignment: .center
//        )
//}
//
