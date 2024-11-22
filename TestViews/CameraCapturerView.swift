//
//  CameraCapturerView.swift
//  TestVisionPro
//
//  Created by Sunniva L on 7/19/24.
//
import Foundation
import SwiftUI
import AVFoundation

struct CameraCapturerView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

//func captureSetUp(){
//    // Create the capture session.
//    let captureSession = AVCaptureSession()
//
//    captureSession.beginConfiguration()
//    let videoDevice = AVCaptureDevice(.builtInWideAngleCamera,
//                                              for: .video, position: .unspecified)
//    guard
//        let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!),
//        captureSession.canAddInput(videoDeviceInput)
//        else { return }
//    captureSession.addInput(videoDeviceInput)
//    
//}

var isAuthorized: Bool {
    get async {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        // Determine if the user previously authorized camera access.
        var isAuthorized = status == .authorized
        
        // If the system hasn't determined the user's authorization status,
        // explicitly prompt them for approval.
        if status == .notDetermined {
            isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
        }
        
        return isAuthorized
    }
}

func setUpCaptureSession() async {
    guard await isAuthorized else { return }
    // Set up the capture session.
}

#Preview {
    CameraCapturerView()
}
