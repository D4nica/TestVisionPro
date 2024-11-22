//
//  SessionConfig.swift
//  TestVisionPro
//
//  Created by Sunniva L on 7/3/24.
//

import Foundation
import UIKit

//private var ServerURL : String = "http://10.2.222.140:8080"
let ip = "10.2.222.140"
private var ServerURL: String {
    return "http://\(ip):8080"
}
// "http://192.168.0.142:8080" //STUDIO X
// 10.2.222.140 //WEGMANS

func DataToServer(input : String) -> String{
    //192.168.0.142 // 127.0.0.1
    guard let url = URL(string: ServerURL) else { return "URL not found" }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
    let postData = (input).data(using: .utf8) //"Hello from Vision OS"
    request.httpBody = postData
    var responseText : String = " "
    
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
    return responseText
}

//RECEIVE UPDATES
func DataFromServer(completion: @escaping (Bool,Bool, String, String, String, (Float, Float, Float, Float)) -> Void) {
    guard let url = URL(string: ServerURL + "/text") else {
        completion(true,true,"" ,"URL not found", "URL not found", (0, 0, 0, 0))
        return
    }
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data, error == nil else {
            print("Error while fetching data: \(error?.localizedDescription ?? "No error description")")
            completion(true,true, "", "", "",(0, 0, 0, 0)) // Call completion with error values
            return
        }
        do {
            let posts = try JSONDecoder().decode([Post].self, from: data)
            for post in posts {
                completion(post.showImmersiveSpace, post.isRecording, post.slideNumber, post.captionHighlight, post.summary, (post.slideX,post.slideY,post.slideW,post.slideH))
            }
        } catch let jsonError {
            print("Failed to decode json", jsonError)
            completion(true,true, "", "", "", (0, 0, 0, 0)) // Call completion with error values
        }
    }
    task.resume()
}


func ImageFromServer(completion: @escaping (UIImage?) -> Void) {
    let placeholderImage = UIImage(named: "hiddenlake")!
    var resultImage: UIImage = placeholderImage

    guard let url = URL(string: ServerURL + "/image") else {
        completion(placeholderImage)
        return
    }
    var request = URLRequest(url: url)
    request.httpMethod = "GET"

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data, error == nil else {
            print("Error while fetching image: \(error?.localizedDescription ?? "No error description")")
            DispatchQueue.main.async {
                completion(placeholderImage)
            }
            return
        }

        if let fetchedImage = UIImage(data: data) {
            resultImage = fetchedImage
            print("Image received successfully: \(fetchedImage)")
        } else {
            print("Failed to convert data to UIImage")
        }

        DispatchQueue.main.async {
            completion(resultImage)
        }
    }
    task.resume()
}


struct Post: Codable {
// The names of the variables should match with the keys used in the link. Also, the data types should match with the values of the URL link.
    let showImmersiveSpace: Bool
    let isRecording: Bool
    let ocrKeyword: String
    let slideNumber: String
    let captionHighlight: String
    let summary: String
    let slideX: Float
    let slideY: Float
    let slideW: Float
    let slideH: Float
}
    
func imageToData(image: UIImage) -> Data? {
    return image.jpegData(compressionQuality: 1.0)
}


