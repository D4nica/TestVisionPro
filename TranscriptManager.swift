//
//  TranscriptManager.swift
//  TestVisionPro
//
//  Created by Sunniva L on 7/1/24.
//  Latest Modification on 8/26/24.
//

import Foundation
import SwiftUI
import ARKit
import RealityKit
import RealityKitContent


func CleanTranscript(RawTranscript: String, Current: String) -> (String, String) {
    let rawWords = RawTranscript.split(separator: " ").map { String($0) }
    let currentWords = Current.split(separator: " ").map { String($0) }
    
    // Find the last index of the current transcript in the raw transcript
    if let overlapIndex = rawWords.lastIndex(where: { word in currentWords.contains(word) }) {
        let newWords = Array(rawWords.suffix(from: overlapIndex + 1))
        let updatedWords = currentWords + newWords
        return (updatedWords.joined(separator: " "), newWords.joined(separator: " "))
    } else {
        // If no overlap is found, just add all new words
        return (RawTranscript, RawTranscript)
    }
}

func countCommonPrefixCharacters(_ string1: String, _ string2: String) -> Int {
    let minLength = min(string1.count, string2.count)
    var commonCount = 0
    for i in 0..<minLength {
        let index1 = string1.index(string1.startIndex, offsetBy: i)
        let index2 = string2.index(string2.startIndex, offsetBy: i)
        if string1[index1] == string2[index2] {
            commonCount += 1
        } else {
            break
        }
    }
    return commonCount
}


func getWordWidth(wordText: String, FontSize: CGFloat) -> Float {
    let mesh = MeshResource.generateText(
        wordText,
        extrusionDepth: 0.001,
        font: .systemFont(ofSize: FontSize),
        containerFrame: CGRect(x: 0, y: 0, width: 10, height: 0.1), // Large container frame
        alignment: .left,
        lineBreakMode: .byWordWrapping
    )
    let material = UnlitMaterial(color: .label)
    let wordEntity = ModelEntity(mesh: mesh, materials: [material])
    let boundingBox = wordEntity.visualBounds(relativeTo: wordEntity)
    let wordWidth = boundingBox.extents.x
    return wordWidth
}


func checkCaptionEdgeCase(word: String) -> String{
    if (String(word.lowercased()) == String("-")){
        print("checkCaptionEdgeCase",word)
        return "hyphen"
    }
    if (String(word.lowercased()) == "diagram"){
        print("checkCaptionEdgeCase",word)
        return "bigram"
    }
    if (String(word.lowercased()) == "g" || String(word.lowercased()) == "graham" || String(word.lowercased()) == "grand"){
        print("checkCaptionEdgeCase",word)
        return "gram"
    }
    if (String(word.lowercased()) == "headphone"){
        print("checkCaptionEdgeCase",word)
        return "head pose"
    }
    if (String(word.lowercased()) == "added"){
        print("checkCaptionEdgeCase",word)
        return "edit"
    }
    if (String(word.lowercased()) == "no"){
        print("checkCaptionEdgeCase",word)
        return "non"
    }
    if (String(word.lowercased()) == "occurrence"){
        print("checkCaptionEdgeCase",word)
        return "co-occurrence"
    }
    if (String(word.lowercased()) == "eager"){
        print("checkCaptionEdgeCase",word)
        return "eigen"
    }
    return word
}

///Load Caption with Highlights
///CurrentTranscript: @Binding value of processed caption
///localCurrentTranscript: private variable of caption since last call
///x: entity's x position
///currentX: the last caption word's X
///currentY: the last caption word's Y
func loadCaptionNoFlash(CurrentTranscript: String,  localCurrentTranscript: String, underlineWord: String, x: Float, in captionEntity: Entity,
                    CurrentX: Float, CurrentY: Float, LineAmount: Int, EntitiesByLine: [[ModelEntity]], WordbyLine: [[String]]) -> (Entity, String, Float, Float, Int, [[ModelEntity]],[[String]]) {
    var newWords : String = ""
    var CurrentTranscriptNEW : String = CurrentTranscript
    let maxLineAmount: Int = 4 //DEBUG //4
    let maxLineWidth : Float = 0.55  //DEBUG // 0.6
    let FontSize: CGFloat = 0.02
    let LineSize: Float = 0.025
    var currentX: Float = CurrentX
    var currentY: Float = CurrentY
    var lineAmount: Int = LineAmount
    var wordbyLine: [[String]] = WordbyLine
    var entitiesByLine: [[ModelEntity]] = EntitiesByLine

    (CurrentTranscriptNEW, newWords) = CleanTranscript(RawTranscript: CurrentTranscript, Current: localCurrentTranscript)
    let CurrentTranscriptList = CurrentTranscript.split(separator: " ").map { String($0)}
    let localCurrentTranscriptList = localCurrentTranscript.split(separator: " ").map { String($0)}
    let newWordsList = newWords.split(separator: " ").map { String($0)}
    print("CurrentTranscriptNEW -> ", CurrentTranscriptNEW, " - Get new words -> ", newWords, " - localCurrentTranscriptList ->", localCurrentTranscriptList)
    if (newWords == "" || newWords == localCurrentTranscriptList.last){return (captionEntity, CurrentTranscriptNEW, currentX, currentY, lineAmount, entitiesByLine, wordbyLine) }
    
//    //Edge case in Self-Correction: If the last word in the RawTranscript is a correction, remove the last word and let newWord render it
//    if let currentLastWord = localCurrentTranscriptList.last, let rawLastWord = CurrentTranscriptList.last {
//        if (countCommonPrefixCharacters(String(currentLastWord),String(rawLastWord)) >= 3) {
//            if !wordbyLine.isEmpty && !wordbyLine.last!.isEmpty && !entitiesByLine.isEmpty && !entitiesByLine.last!.isEmpty {
//                wordbyLine[wordbyLine.count - 1] = Array(wordbyLine[wordbyLine.count - 1].prefix(wordbyLine[wordbyLine.count - 1].count-1))
//                if let lastEntity = entitiesByLine.last?.last {captionEntity.removeChild(lastEntity)}
//                entitiesByLine[entitiesByLine.count - 1] = Array(entitiesByLine[entitiesByLine.count - 1].prefix(entitiesByLine[entitiesByLine.count - 1].count-1))
//                currentX -= (getWordWidth(wordText: currentLastWord, FontSize: FontSize) + 0.01)
//            }
//        }
//    }
    
    for (_, word) in newWordsList.enumerated(){
        
        //Edge case in Self-Correction: If the last word in the RawTranscript is a correction, remove the last word and let newWord render it
        if let currentLastWord = localCurrentTranscriptList.last {
            if (countCommonPrefixCharacters(String(currentLastWord),String(word)) >= 2) {
                if !wordbyLine.isEmpty && !wordbyLine.last!.isEmpty && !entitiesByLine.isEmpty && !entitiesByLine.last!.isEmpty {
                    wordbyLine[wordbyLine.count - 1] = Array(wordbyLine[wordbyLine.count - 1].prefix(wordbyLine[wordbyLine.count - 1].count-1))
                    if let lastEntity = entitiesByLine.last?.last {captionEntity.removeChild(lastEntity)}
                    entitiesByLine[entitiesByLine.count - 1] = Array(entitiesByLine[entitiesByLine.count - 1].prefix(entitiesByLine[entitiesByLine.count - 1].count-1))
                    currentX -= (getWordWidth(wordText: currentLastWord, FontSize: FontSize) + 0.01)
                }
            }
        }
        
        //Edge Case in Transcription
        let word_checked = checkCaptionEdgeCase(word: word)
        //Have Linebreak
        if (currentX > maxLineWidth)
        {
            currentX = 0.0
            currentY -= LineSize
            lineAmount += 1
            entitiesByLine.append([])
            wordbyLine.append([]) //Append when initialize this line
        }
        let wordText = String(word_checked) + " "
        let mesh = MeshResource.generateText(
            wordText,
            extrusionDepth: 0.001,
            font: .systemFont(ofSize: FontSize),
            containerFrame: CGRect(x: 0, y: 0, width: 10, height: 0.1), // Large container frame
            alignment: .left,
            lineBreakMode: .byWordWrapping
        )
        let material = UnlitMaterial(color: .label)
        let wordEntity = ModelEntity(mesh: mesh, materials: [material])
        wordEntity.position = SIMD3<Float>(currentX, currentY, 0)
        let boundingBox = wordEntity.visualBounds(relativeTo: wordEntity)
        let wordWidth = boundingBox.extents.x
        captionEntity.addChild(wordEntity)
        
        entitiesByLine[entitiesByLine.count-1].append(wordEntity)
        wordbyLine[entitiesByLine.count-1].append(wordText)
        currentX += (wordWidth + 0.01)
        print("after linebreaking word", word, wordbyLine," CurrentTranscriptNEW " ,CurrentTranscriptNEW,currentY,CurrentY)
    }
    
    print("--> wordbyLine", wordbyLine, "CurrentTranscriptNEW -> ", CurrentTranscriptNEW)
    
    // Move previous children up and remove the first line for karaoke-style effect when line amount exceeds maxLineAmount
    while lineAmount > maxLineAmount {
        //Entity
        if let firstLineEntities = entitiesByLine.first, !firstLineEntities.isEmpty {
            for entity in firstLineEntities {
                captionEntity.removeChild(entity)
            }
            entitiesByLine.removeFirst()
        }
        //Position (remaining entities move up)
        for child in captionEntity.children {
            child.position.y += LineSize
        }
        //Update CurrentTranscript
        if let firstLineWords = wordbyLine.first, !firstLineWords.isEmpty {
            print("-->remove firstLineWords", firstLineWords, wordbyLine)
            wordbyLine.removeFirst()
            let flattenedArray = wordbyLine.flatMap { $0 }
            CurrentTranscriptNEW = flattenedArray.joined(separator: " ")
        }
        currentY += LineSize
        lineAmount -= 1
    }
    captionEntity.scale = SIMD3<Float>(1.5, 1.5, 1.0)
    captionEntity.position = SIMD3<Float>(x, -0.45, 0) ////SIMD3<Float>(x, -0.4, 0) //No scaling
    return (captionEntity, CurrentTranscriptNEW, currentX, currentY, lineAmount,entitiesByLine, wordbyLine)
}


func loadCaptionHighlightNoFlash(CurrentTranscript: String, underlineWord: String, in captionEntity: Entity,
                                 EntitiesByLine: [[ModelEntity]], WordbyLine: [[String]]) -> (Entity, [[ModelEntity]])
{
    let FontSize: CGFloat = 0.02
    let LineSize: Float = 0.025
    var entitiesByLine: [[ModelEntity]] = EntitiesByLine
    let underlineWords = underlineWord.split(separator: " ").map {String($0.lowercased())}
    var isUnderlined: Bool = false
    var wordWidth: Float = 0.0
    var currentX : Float = 0.0
    var currentY : Float = 0.0
    
    for (l_i, line) in WordbyLine.enumerated() {
        if (WordbyLine.count - (l_i + 1) < 2) { //Last two lines - 1-1=0, 2-1=1, 2-2=0, 3-1=2, 3-2=1, 3-1=2, 4-1=3, 4-2=2, 4-3=1, 4-4=0
            for (_, word) in line.enumerated(){
                
                // Check underline
                wordWidth = getWordWidth(wordText: word, FontSize: FontSize)
                let trimmedWord = word.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                if (underlineWords.contains(String(trimmedWord)) && word.lowercased() != "the") {isUnderlined = true} else {isUnderlined = false}
                print("underlineWords", underlineWords, "word", String(word.lowercased()),underlineWords.contains(String(trimmedWord)))
                
                // Check if the word is already underlined
                var alreadyUnderlined = false
                for entity in entitiesByLine[l_i] {
                    if entity.position == SIMD3<Float>(currentX + wordWidth / 2 + 0.001, currentY + 0.077, 0) {
                        alreadyUnderlined = true
                    }
                }
                if isUnderlined && !alreadyUnderlined {
                    let underlineMesh = MeshResource.generatePlane(width: wordWidth + 0.01, height: 0.0035) //height: 0.0025
                    let underlineMaterial = UnlitMaterial(color: .green)
                    let underlineEntity = ModelEntity(mesh: underlineMesh, materials: [underlineMaterial])
                    underlineEntity.position = SIMD3<Float>(currentX + wordWidth / 2 + 0.001, currentY + 0.077, 0)
                    captionEntity.addChild(underlineEntity)
                    entitiesByLine[l_i].append(underlineEntity)
//                    return (captionEntity, entitiesByLine) //RETURN WHEN ONE HIGHLIGHT IS FOUND "Individual individual"
                }
                currentX += (wordWidth + 0.01)
            }
        }
        currentX = 0.0
        currentY -= LineSize
    }
    return (captionEntity, entitiesByLine)
}



///UNUSED - Underline highlight in loadCaptionNoFlash()
//        if (underlineWords.contains(String(word.lowercased())) && word.lowercased() != "the") {isUnderlined = true} else {isUnderlined = false}
//        print("underlineWords", underlineWords, "word", String(word.lowercased()),underlineWords.contains(String(word.lowercased())))
//        if isUnderlined {
//            let underlineMesh = MeshResource.generatePlane(width: wordWidth + 0.01, height: 0.0035) //height: 0.0025
//            let underlineMaterial = UnlitMaterial(color: .green)
//            let underlineEntity = ModelEntity(mesh: underlineMesh, materials: [underlineMaterial])
//            underlineEntity.position = SIMD3<Float>(currentX + wordWidth / 2 + 0.001, currentY + 0.077, 0)
//            captionEntity.addChild(underlineEntity)
//            entitiesByLine[entitiesByLine.count-1].append(underlineEntity)
//        }

/////UNUSED - Get add new transcript to dictionary
/////SpeechRecognizer transcript can update values, and we will keep track of new upates
/////Only  remove old transcripts when there is line changes
/////Extract dictionary difference https://stackoverflow.com/questions/38861786/how-to-extract-differences-between-dictionaries
//extension Dictionary where Key: Comparable, Value: Equatable {
//    func DictMinus(dict: [Key:Value]) -> [Key:Value] {
//        let entriesInSelfAndNotInDict = filter { dict[$0.0] != self[$0.0] }
//        return entriesInSelfAndNotInDict.reduce([Key:Value]()) { (res, entry) -> [Key:Value] in
//            var res = res
//            res[entry.0] = entry.1
//            return res
//        }
//    }
//}


///Get updated transcript string (if there is live modification, the newWords will start from there, but usually only the most recent ones)
//func CleanTranscript(RawTranscript : String, Current: String) -> (String, String) {
//    let rawWords = RawTranscript.split(separator: " ").map { String($0)}
//    let currentWords = Current.split(separator: " ").map { String($0)}
//    var newWords : [String] = rawWords
//    var currentWordLast = currentWords.last
//    var updatedWordInit = Array(currentWords)
//    if currentWords.count > 1 {currentWordLast = currentWords[currentWords.count - 1]}
//    // Identify new words from rawWords based on overlap
//    if let overlapIndex = rawWords.lastIndex(of: currentWordLast ?? "") {
//        newWords = Array(rawWords.suffix(from: overlapIndex)) //Overlap Index + 1
//        if (currentWords.count > 1){
//            updatedWordInit = Array(updatedWordInit.prefix(currentWords.count - 1))
//        }
//    }
//    //Edge cases:
//    if (newWords.first == updatedWordInit.last){updatedWordInit = Array(updatedWordInit.prefix(currentWords.count - 1))}
//    print("updatedWordInit",updatedWordInit, "new Words", newWords)
//    let updatedWords = updatedWordInit + newWords
//    return (Array(updatedWords).joined(separator: " "), Array(newWords).joined(separator: " "))
//}

