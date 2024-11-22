//
//  HighlightManager.swift
//  TestVisionPro
//
//  Created by Sunniva L on 7/31/24.
//

import Foundation
import SwiftUI
//
//class ServerInfoModel: ObservableObject {
//    @Published var caption: String = "Today we're going to discuss how to handle real word spelling errors in natural language processing"
//    @Published var captionhighlight: String = "processing"
//    
//    func updateLoadCaption(newCaption: String, newHighlight: String) {
//        self.caption = newCaption
//        self.captionhighlight = newHighlight
//    }
//    //Change to self
//    func UpdateSlideHighlight(inX: Float, inY: Float, slideW: Float, slideH: Float) -> (Float, Float, Float, Float){
//        let outX = inX
//        let outY = inY
//        let outWidth = slideW
//        let outHeight = slideH
//        //Function Call to update highlight slide boxes
//        return (outX, outY, outWidth, outHeight)
//    }
//    func SummaryAndJargonUpdate(inSummary: String, inJargon: String) -> String{
//        let formatted = "Summary /n " + inSummary + "/n/n/n Jargon /n" + inJargon
//        return formatted
//    }
//}


func UpdateSlideHighlight(inX: Float, inY: Float, slideW: Float, slideH: Float) -> (Float, Float, Float, Float){
    let outX = inX
    let outY = inY
    let outWidth = slideW
    let outHeight = slideH
    //Function Call to update highlight slide boxes
    return (outX, outY, outWidth, outHeight)
}
func SummaryAndJargonUpdate(inSummary: String, inJargon: String) -> String{
    let formatted = "Summary /n " + inSummary + "/n/n/n Jargon /n" + inJargon
    return formatted
}
