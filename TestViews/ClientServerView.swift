//
//  ClientServerVie.swift
//  TestVisionPro
//
//  Created by Sunniva L on 7/3/24.
//
//  Mac terminal start server command: python3 -m http.server 8080
//  Mac terminal check ip address command: ipconfig getifaddr en0

import SwiftUI
import UIKit

struct ClientServerView: View {
    @State private var responseText: String = ""
    @State private var resultImage: UIImage?
    @State private var resultText: String = ""
    @State private var ip: String = "10.2.222.140"
    private var MacServerURL: String {
           return "http://\(ip):8080"
       }
    //@State private var MacServerURL : String = "http://10.2.222.140:8080"
    var body: some View {
        VStack {
            Text("VisionOS Client")
                .font(.largeTitle)
                .padding()
            
            Button(action: {
                sendDataToServer()
            }) {
                Text("Send Text")
                    .padding()
            }
            .foregroundColor(.white)
            .background(.blue)
            .cornerRadius(20)
            
            Text("Response: \(responseText)")
                .padding()
            
            Button(action: {
                fetchDataFromServer()
            }) {
                Text("Fetch Text")
                    .padding()
                }
            .foregroundColor(.white)
            .background(.blue)
            .cornerRadius(20)

            Text("Result: \(resultText)")
                .padding()
            
            Button(action: {
                fetchImageFromServer()
            }) {
                Text("Fetch Image")
                    .padding()
                }
            .foregroundColor(.white)
            .background(.blue)
            .cornerRadius(20)
            if let resultImage = resultImage{Image(uiImage: resultImage)}
            else{Image(.hiddenlake)}
        }
        .padding()
    }
    
    func sendDataToServer() {
        //192.168.0.142 // 127.0.0.1
        guard let url = URL(string: MacServerURL) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
        let postData = ("Hello from VisionOS").data(using: .utf8)
        request.httpBody = postData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "No error description")")
                return
            }
            if let responseString = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    responseText = responseString
                }
            }
        }
        task.resume()
    }
    
    func fetchDataFromServer(){
        guard let url = URL(string: MacServerURL+"/text") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request){ data, response, error in
            guard let data = data, error == nil else { //if not (error contains a value, and data is nil)
                print("Error while fetching data: \(error?.localizedDescription ?? "No error description")")
                return
            }
            do {
                   let posts = try JSONDecoder().decode([Post].self, from: data)
                                for post in posts {
//                                    resultText = post.title + post.body
                                }
                            } catch let jsonError {
                                print("Failed to decode json", jsonError)
                            }
        }
        task.resume()
    }
    
    func fetchImageFromServer() {
        guard let url = URL(string: MacServerURL+"/image") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error while fetching image: \(error?.localizedDescription ?? "No error description")")
                return
            }
            DispatchQueue.main.async {
                if UIImage(data: data) != nil {
                    resultImage = UIImage(data: data)
                    print("Image received successfully")
                } else {
                    print("Failed to convert data to UIImage")
                }
            }
        }
        task.resume()
    }
    
}



#Preview {
    ClientServerView()
}





