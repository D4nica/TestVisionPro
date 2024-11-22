import Foundation
import SwiftUI

@main
struct VisionOSObjectTrackingDemoApp: App {
    @State var ShowImmersiveSpace: Bool = false
    @State private var currentTranscript: String = "[placeholder]"
    @State private var currentCaptionHighlight: String = ""
    @State var CurrentSlideHighlight: (Float, Float, Float, Float) = (0, 0, 0, 0)
    @State var CurrentSummary: String = "[Summary Here]"
    @State var CurrentSlideNumber: String = "lec15-1"
    @State var captionEntityInitalized : Bool = false

    var body: some Scene {
        WindowGroup {
            SlideView(ShowImmersiveSpace: $ShowImmersiveSpace, CurrentTranscript: $currentTranscript, CurrentCaptionHighlight: $currentCaptionHighlight,CurrentSlideHighlight:$CurrentSlideHighlight, CurrentSummary: $CurrentSummary, CurrentSlideNumber: $CurrentSlideNumber, captionEntityInitalized: $captionEntityInitalized)
        }
        .defaultSize(CGSize(width: 4, height: 3))
        
        ImmersiveSpace(id: "ImageTracking") {
            ImageTracking(CurrentTranscript: $currentTranscript, CurrentCaptionHighlight: $currentCaptionHighlight,CurrentSlideHighlight:$CurrentSlideHighlight, CurrentSummary: $CurrentSummary, CurrentSlideNumber: $CurrentSlideNumber, captionEntityInitalized: $captionEntityInitalized)
        }
    }
}

