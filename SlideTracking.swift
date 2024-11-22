//
//  ImageTracking.swift
//  TestVisionPro
//
//  Created by Sunniva L on 7/23/24.
//
import Foundation
import SwiftUI
import ARKit
import RealityKit
import RealityKitContent

struct ImageTracking: View {
    var arkitSession = ARKitSession()
    @State var entityMap : [UUID: ModelEntity] = [:]
    @State var entityView : [UUID: ViewModel] = [:]
    let imageInfo = ImageTrackingProvider(
        referenceImages: ReferenceImage.loadReferenceImages(inGroupNamed: "AR Image Resources")
    )
    var rootEntity = Entity()

    ///Use this when in simulator
    @State var worldEntity: Entity = {
        let slideAnchor: AnchorEntity
        slideAnchor = AnchorEntity(.head)
        slideAnchor.position = [0, 0, -1]
        return slideAnchor
    }()
    
    ///Define Contents:
    ///additionPlane: summary panel
    ///captionEntity: caption
    ///slideEntity: refererence slide position
    ///highlightEntity: highlights on slides
    let  additionPlane = Entity()
    let  additionModel = ModelComponent(
        mesh: .generatePlane(width: 0.3, height: 0.5, cornerRadius: 0.01),
        materials: [UnlitMaterial(color: .quaternarySystemFill)])
    let sphereEntity = ModelEntity(mesh: .generateSphere(radius: 0.01))
    var highlightEntity = ModelEntity()
    var slideEntity = ModelEntity()
    var summaryEntity = Entity()
    @State var captionEntity = Entity()

    @State var newWord: [String] = []
    @State var localCurrentTranscript: String = ""
    @State var currentWordX: Float = 0.0
    @State var currentWordY: Float = 0.0
    @State var lineAmount: Int = 1
    @State var entitiesByLine: [[ModelEntity]] = [[]]
    @State var wordsByLine: [[String]] = [[]]
    
    @State private var localCurrentCaptionHighlight: String = ""
    @State private var previousSummary: String = ""
    @State private var localSlideNumber: String = ""
    
    @Binding var CurrentTranscript: String
    @Binding var CurrentCaptionHighlight: String
    @Binding var CurrentSlideHighlight: (Float, Float, Float, Float)
    @Binding var CurrentSummary: String
    @Binding var CurrentSlideNumber: String
    @Binding var captionEntityInitalized: Bool

    
    //Tracking update
    func updateImage(_ anchor: ImageAnchor) {
        if entityMap[anchor.id] == nil {
            entityMap[anchor.id] =  sphereEntity
//            rootEntity.addChild( sphereEntity)
            rootEntity.addChild( additionPlane)
            rootEntity.addChild( summaryEntity)
            rootEntity.addChild( slideEntity)
            rootEntity.addChild( captionEntity)
            rootEntity.addChild( highlightEntity)
            print("added plane tracking")
        }
        if anchor.isTracked {
//            rootEntity.transform = Transform(matrix: anchor.originFromAnchorTransform) //entityMap[anchor.id]?.transform = Transform(matrix: anchor.originFromAnchorTransform) //Original code that warp the entire thing
            // Set position first:
            let transformMatrix = anchor.originFromAnchorTransform
            let position = SIMD3<Float>(
                transformMatrix.columns.3.x - 0.02,
                transformMatrix.columns.3.y - 0.002,
                transformMatrix.columns.3.z - 0.025
            )
            rootEntity.position = position
            // Scale from the transformation matrix
            let scaleX = length(SIMD3<Float>(transformMatrix.columns.0.x, transformMatrix.columns.0.y, transformMatrix.columns.0.z))
            let scaleY = length(SIMD3<Float>(transformMatrix.columns.1.x, transformMatrix.columns.1.y, transformMatrix.columns.1.z))
            let scaleZ = length(SIMD3<Float>(transformMatrix.columns.2.x, transformMatrix.columns.2.y, transformMatrix.columns.2.z))
            let scale = SIMD3<Float>(scaleX*1.2, scaleY*1.2, scaleZ)
            rootEntity.scale = scale
            
            // Get anchor's orientation
            let forward = SIMD3<Float>(transformMatrix.columns.2.x, transformMatrix.columns.2.y, transformMatrix.columns.2.z)
            let up = SIMD3<Float>(transformMatrix.columns.1.x, transformMatrix.columns.1.y, transformMatrix.columns.1.z)
            let right = cross(up, forward) // Compute the right vector
            let rotationMatrix = float3x3([right, up, forward])
            let orientationAnchor = simd_quatf(rotationMatrix)

            // Set a fixed orientation (facing forward along the Z-axis)
            let angleInRadianZ = 1.0 * (Float.pi / 180.0)
            var fixedRotation = simd_quatf(angle: angleInRadianZ, axis: SIMD3<Float>(0, 0, 1)) //Change Z
            let angleInRadianX = -82 * (Float.pi / 180.0)
            fixedRotation = simd_quatf(angle: angleInRadianX, axis: SIMD3<Float>(1, 0, 0)) //Change Z
            rootEntity.orientation = orientationAnchor * fixedRotation
            print("is tracking")
        }
        else{
            print("error in sphere tracking")
        }
    }
    
    //Call update every xxx seconds
    @State private var timer: Timer?
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { _ in
            callUpdateCaptionHighlight()
        }
    }
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func callUpdateCaptionHighlight() {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.25) { ///Update buffer time
            if (localCurrentTranscript != CurrentTranscript) {

                ///Old flashing method
//                captionEntity.children.removeAll()
//               loadCaption(text: CurrentTranscript, newWord: newWord, underlineWord: CurrentCaptionHighlight, x: -0.4, in: captionEntity)
//               localCurrentTranscript = String(CurrentTranscript)
                
                (captionEntity, localCurrentTranscript, currentWordX, currentWordY, lineAmount,entitiesByLine, wordsByLine) = loadCaptionNoFlash(CurrentTranscript: CurrentTranscript, localCurrentTranscript: localCurrentTranscript, underlineWord: CurrentCaptionHighlight, x: -0.4, in: captionEntity, CurrentX: currentWordX, CurrentY: currentWordY, LineAmount: lineAmount, EntitiesByLine: entitiesByLine, WordbyLine: wordsByLine)
                
                ///Not highlighted here
//                (captionEntity,entitiesByLine) = loadCaptionHighlightNoFlash(CurrentTranscript: CurrentTranscript, underlineWord: CurrentCaptionHighlight, in: captionEntity,EntitiesByLine: entitiesByLine, WordbyLine:wordsByLine)
            }
            if  (localCurrentCaptionHighlight != CurrentCaptionHighlight){
                loadHighlight(x: CurrentSlideHighlight.0, y: CurrentSlideHighlight.1, w: CurrentSlideHighlight.2, h: CurrentSlideHighlight.3, in:  highlightEntity)
                
                (captionEntity,entitiesByLine) = loadCaptionHighlightNoFlash(CurrentTranscript: CurrentTranscript, underlineWord: CurrentCaptionHighlight, in: captionEntity,EntitiesByLine: entitiesByLine, WordbyLine:wordsByLine)
                
                localCurrentCaptionHighlight = String(CurrentCaptionHighlight)
            }
            if (previousSummary != CurrentSummary){
                loadSummary(text: CurrentSummary, x: 0.66, y: -0.3, in: summaryEntity) //0.525, -0.45
                previousSummary = CurrentSummary
            }
            if (localSlideNumber != CurrentSlideNumber)
            {
                loadImageEntity(named: CurrentSlideNumber, in: slideEntity)
                loadHighlight(x: CurrentSlideHighlight.0, y: CurrentSlideHighlight.1, w: CurrentSlideHighlight.2, h: CurrentSlideHighlight.3, in:  highlightEntity)
                localSlideNumber = CurrentSlideNumber
            }
            if (captionEntityInitalized)
            {
                captionEntity.children.removeAll()
                CurrentTranscript = ""
                localCurrentTranscript = ""
               currentWordX = 0.0
               currentWordY = 0.0
               lineAmount = 1
                entitiesByLine = [[]]
               wordsByLine = [[]]
            }
        }
    }
    

    ////UNUSED - Load Caption with Highlights loadCaptionNoFlast() in TranscriptManager.swift
    func loadCaption(text: String, newWord: [String], underlineWord: String, x: Float, in captionEntity: Entity) {
        let words = text.split(separator: " ")
        let underlineWords = underlineWord.split(separator: " ").map { $0.lowercased()}
        let linebreakNumber: Int = 8
        let maxLineAmount: Int = 2 //4
        let FontSize: CGFloat = 0.02 //0.025
        let LineSize: Float = 0.025
        var isUnderlined: Bool = false
        var currentX: Float = 0.0
        var currentY: Float = 0.0
        var lineAmount: Int = 1
        var wordInCurrentLine: [String] = []
        var wordbyLine: [[String]] = []
        var entitiesInCurrentLine: [ModelEntity] = []
        var entitiesByLine: [[ModelEntity]] = []
        
        //re-initialize
        for (index, word) in words.enumerated() {
            let wordText = String(word) + " "
            let mesh = MeshResource.generateText(
                wordText,
                extrusionDepth: 0.0,
                font: .systemFont(ofSize: FontSize),
                containerFrame: CGRect(x: 0, y: 0, width: 10, height: 0.1), // Large container frame
                alignment: .left,
                lineBreakMode: .byWordWrapping
            )
            let material = UnlitMaterial(color: .white)
            let wordEntity = ModelEntity(mesh: mesh, materials: [material])
            wordEntity.position = SIMD3<Float>(currentX, currentY, 0)
            captionEntity.addChild(wordEntity)
            let boundingBox = wordEntity.visualBounds(relativeTo: wordEntity)
            let wordWidth = boundingBox.extents.x

            //Underline highlight
            if (underlineWords.contains(word.lowercased().trimmingCharacters(in: .whitespaces))) {isUnderlined = true} else {isUnderlined = false}
            if isUnderlined {
                let underlineMesh = MeshResource.generatePlane(width: wordWidth + 0.01, height: 0.0035) //height: 0.0025
                let underlineMaterial = UnlitMaterial(color: .green)
                let underlineEntity = ModelEntity(mesh: underlineMesh, materials: [underlineMaterial])
                underlineEntity.position = SIMD3<Float>(currentX + wordWidth / 2 + 0.001, currentY + 0.077, 0)
                captionEntity.addChild(underlineEntity)
                entitiesInCurrentLine.append(underlineEntity)
            }
            entitiesInCurrentLine.append(wordEntity)
            wordInCurrentLine.append(wordText)
            currentX += (wordWidth + 0.01)
            
            //Linebreak
            if (index % linebreakNumber == 0 && index != 0)
            {
                currentX = 0.0
                currentY -= LineSize
                lineAmount += 1
                entitiesByLine.append(entitiesInCurrentLine)
                entitiesInCurrentLine = []
                wordbyLine.append(wordInCurrentLine)
                wordInCurrentLine = []
            }
        }
        // Add remaining entities and words
        if !entitiesInCurrentLine.isEmpty {
            entitiesByLine.append(entitiesInCurrentLine)
            print("--> entitiesInCurrentLine.isEmpty ", entitiesInCurrentLine)
        }
        if !wordInCurrentLine.isEmpty {
            wordbyLine.append(wordInCurrentLine)
            print("wordInCurrentLine ", wordInCurrentLine)
        }

        // Move previous children up and remove the first line for karaoke-style effect when line amount exceeds 3
        while lineAmount > maxLineAmount {
            //Entity
            if let firstLineEntities = entitiesByLine.first {
                for entity in firstLineEntities {
                    captionEntity.removeChild(entity)
                }
                entitiesByLine.removeFirst()
            }
            //Position
            for child in captionEntity.children {
                child.position.y += LineSize
            }
            //CurrentTranscript
            if let firstLineWords = wordbyLine.first {
                var currentTranscriptList = CurrentTranscript.split(separator: " ").map { String($0) }
                currentTranscriptList = Array(currentTranscriptList.suffix(from: firstLineWords.count))
                print("firstLineWords ", firstLineWords, currentTranscriptList)
                CurrentTranscript = currentTranscriptList.joined(separator: " ") //CURRENT TRANSCRIPT
                wordbyLine.removeFirst()
            }
            lineAmount -= 1
        }
        
        captionEntity.scale = SIMD3<Float>(1.5, 1.5, 1.0)
        captionEntity.position = SIMD3<Float>(x, -0.45, 0)
//        captionEntity.position = SIMD3<Float>(x, -0.4, 0) //No scaling
    }


    //Load Summary
    func loadSummary (text: String, x: Float, y: Float, in sumEntity: Entity)
    {
        sumEntity.children.removeAll()
        let FontSize: CGFloat = 0.02 //0.025
        let mesh = MeshResource.generateText(
            String(CurrentSlideNumber) + "\n\n" + text,
            extrusionDepth: 0.001,
            font: .systemFont(ofSize: FontSize),
            containerFrame: CGRect(x: 0, y: 0, width: 0.2, height: 0.55),
            alignment: .left,
            lineBreakMode: .byWordWrapping //.byTruncatingTail
        )
        let material = UnlitMaterial(color: .secondaryLabel)
        let captionModelComponent = ModelComponent(mesh: mesh, materials: [material])
        let offsetEntity = Entity()
        offsetEntity.components.set(captionModelComponent)
        let boundingBox = mesh.bounds
        let width = boundingBox.extents.x
        let height = boundingBox.extents.y
        offsetEntity.position = SIMD3<Float>(-width / 2, -height / 2, 0)
        sumEntity.addChild(offsetEntity)
        sumEntity.position = SIMD3<Float>(x, y, 0)
        sumEntity.scale = SIMD3<Float>(1.4, 1.4, 1.0)
    }
    
    //Load Slide Highlights
    func loadHighlight(x: Float, y: Float, w: Float, h: Float, in greenPlaneEntity: Entity) {
        let greenPlaneEntityComponent = ModelComponent(
            mesh: .generatePlane(width: w, height: 0.01, cornerRadius: 0.01), //h=0.01 if underline is used
            materials: [UnlitMaterial(color: .green)])
        greenPlaneEntity.components.set(greenPlaneEntityComponent)
        greenPlaneEntity.components.set(OpacityComponent(opacity: 0.8))
        greenPlaneEntity.position = SIMD3<Float>(x, y, 0.01)
    }
    

    //Load Slide
    func loadImageEntity(named name: String, in imageEntity: ModelEntity) {
        Task {
            do {
                let texture = try await TextureResource.load(named: name)
                let planeMesh = MeshResource.generatePlane(width: 1, height: 0.5624) //Assumed width = 1 (image dimension)
                var material = UnlitMaterial()
                material.color = .init(tint: .white, texture: .init(texture))
                imageEntity.model = ModelComponent(mesh: planeMesh, materials: [material])
                imageEntity.components.set(OpacityComponent(opacity: 0.0)) //SET TO 0.0
            } catch {
                print("Failed to load entity: \(error)")
            }
        }
        imageEntity.position = SIMD3<Float>(0, 0, 0)
    }
     

    var body: some View {
        RealityView { content in

            ////For in actual Device
            print("image anchor")
            content.add(rootEntity)
            Task {
                do {
                    //try await arkitSession.run([imageInfo]);
                    for await update in imageInfo.anchorUpdates {
                        updateImage(update.anchor)
                    }
                }
                catch {
                    print("Failed to run ARKit session: \(error.localizedDescription)")
                }
            }

//           ///For debugging in Simulator (Imagetracking() in the SlideView)
//            content.add(worldEntity)
//            Task{
//                do{
//                    worldEntity.addChild( sphereEntity)
//                    worldEntity.addChild( additionPlane)
//                    worldEntity.addChild( slideEntity)
//                    worldEntity.addChild( captionEntity)
//                    worldEntity.addChild( highlightEntity)
//                    worldEntity.addChild( summaryEntity)
//                    print("world anchor")
//                }
//                catch{
//                    print("Failed to run world anchor: \(error.localizedDescription)")
//                }
//            }

        }
        .onAppear {
            ///Additional Plane is the Background of Summary Panel
            additionPlane.components.set(additionModel)
            additionPlane.components.set(OpacityComponent(opacity: 0.8))
            additionPlane.position = SIMD3<Float>(0.67, 0, -0.01)
//            loadCaption(text: CurrentTranscript, newWord: newWord, underlineWord: CurrentCaptionHighlight, x: -0.4, in: captionEntity)
            loadSummary(text: CurrentSummary, x: 0.66, y: -0.3, in: summaryEntity) //x: 0.525, y: -0.45
            loadImageEntity(named: CurrentSlideNumber, in: slideEntity)
            loadHighlight(x: CurrentSlideHighlight.0, y: CurrentSlideHighlight.1, w: CurrentSlideHighlight.2, h: CurrentSlideHighlight.3, in:  highlightEntity)
            startTimer()
            print("Entering immersive space.")
        }
        .onDisappear {
            print("Leaving immersive space.")
        }
    }

}


