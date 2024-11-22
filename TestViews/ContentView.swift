//
//  ContentView.swift
//  TestVisionPro
//
//  Created by Sunniva L on 6/21/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {

    @State private var showImmersiveSpace = false
    @State private var immersiveSpaceIsShown = false
    @State private var showBallonSpace = false
    @State private var ballonSpaceIsShown = false
    @State private var scale = false

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var body: some View {
        VStack {
            Model3D(named: "Scene", bundle: realityKitContentBundle)
                .padding(.bottom, 50)
            
            Text("Hello, world!")
            
            Toggle("Start Calibrate", isOn: $showImmersiveSpace)
                .font(.title)
                .frame(width: 360)
                .padding(24)
                .glassBackgroundEffect()
        }
        .padding()
        .onChange(of: showImmersiveSpace) { _, newValue in
            Task {
                if newValue {
                    switch await openImmersiveSpace(id: "ImageTracking") {
                    case .opened:
                        immersiveSpaceIsShown = true
                        print("opened")
                    case .error, .userCancelled:
                        immersiveSpaceIsShown = false
                        showImmersiveSpace = false
                        print("error")
                    @unknown default:
                        immersiveSpaceIsShown = false
                        showImmersiveSpace = false
                    }
                } else if immersiveSpaceIsShown {
                    await dismissImmersiveSpace()
                    immersiveSpaceIsShown = false
                }
            }
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
