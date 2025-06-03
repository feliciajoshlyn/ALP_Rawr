//
//  AgePredictionViewModel.swift
//  ALP_Rawr
//
//  Created by Dave Wirjoatmodjo on 23/05/25.
//

import SwiftUI
import CoreML
import Vision
import UIKit
import Combine

@MainActor
class AgePredictionViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var capturedImage: UIImage?
    @Published var predictionResult: String = "No prediction yet"
    @Published var isLoading: Bool = false
    @Published var showCamera: Bool = false
    @Published var errorMessage: String?
    @Published var isParentThere: Bool = false
    
    // MARK: - Private Properties
    private var visionModel: VNCoreMLModel?
    private var ageClassifierInstance: AgeClassifier? // Reference to the generated Core ML model class
    
    // MARK: - Initialization
    init() {
        loadModel()
    }
    
    // MARK: - Model Loading
    private func loadModel() {
        if isLoading { return }
        isLoading = true
        errorMessage = nil
        
        Task(priority: .userInitiated) {
            do {
                // Xcode generates the 'AgeClassifier' class from 'AgeClassifier.mlpackage'.
                let config = MLModelConfiguration()
                let classifier = try AgeClassifier(configuration: config)
                self.ageClassifierInstance = classifier
                
                // Vision uses this VNCoreMLModel to perform requests.
                let vnModel = try VNCoreMLModel(for: classifier.model)
                
                self.visionModel = vnModel
                self.isLoading = false
                print("Age prediction model loaded successfully.")
                
            } catch {
                self.visionModel = nil
                self.isLoading = false
                self.errorMessage = "Failed to load model: \(error.localizedDescription)"
                print("Error loading model: \(error)")
            }
        }
    }
    
    // MARK: - Camera Actions
    func openCamera() {
        if visionModel == nil && !isLoading {
            loadModel()
        }
        showCamera = true
    }
    
    func handleCapturedImage(_ image: UIImage) {
        self.capturedImage = image
        predictAge(from: image)
    }
    
    // MARK: - Age Prediction
    func predictAge(from image: UIImage) {
        guard let visionModel = self.visionModel else {
            self.errorMessage = "Model not loaded. Please wait or try reloading."
            self.predictionResult = "Error: Model not ready."
            if !isLoading { loadModel() }
            return
        }
        
        guard let cgImage = image.cgImage else {
            self.errorMessage = "Invalid image format: Could not convert UIImage to CGImage."
            self.predictionResult = "Error: Invalid image."
            return
        }
        
        self.isLoading = true
        self.errorMessage = nil
        self.predictionResult = "Predicting..."
        
        Task(priority: .userInitiated) {
            let request = VNCoreMLRequest(model: visionModel) { [weak self] request, error in
                Task { @MainActor in // Ensure UI updates are on the main actor
                    guard let self = self else { return }
                    self.isLoading = false
                    
                    if let error = error {
                        self.errorMessage = "Prediction error: \(error.localizedDescription)"
                        self.predictionResult = "Prediction failed."
                        print("VNRequest error: \(error)")
                        return
                    }
                    
                    // Process results: VNClassificationObservation contains 'identifier' (classLabel)
                    // and 'confidence' due to ClassifierConfig used during .mlmodel conversion.
                    guard let observations = request.results as? [VNClassificationObservation],
                          let topObservation = observations.first else {
                        self.errorMessage = "Could not process prediction results or no results returned."
                        self.predictionResult = "No prediction available."
                        print("Failed to get VNClassificationObservation results or results are empty.")
                        return
                    }
                    
                    self.predictionResult = self.formatPredictionResult(
                        identifier: topObservation.identifier
                    )
                    self.errorMessage = nil
                    print("Prediction successful: \(self.predictionResult)")
                }
            }
            
            // Vision handles resizing/cropping. Normalization (scale/bias) is part of the Core ML model.
            request.imageCropAndScaleOption = .centerCrop
            
            // Optionally pass image orientation if known, though Vision often infers it.
            // let imageOrientation = CGImagePropertyOrientation(image.imageOrientation)
            // let handler = VNImageRequestHandler(cgImage: cgImage, orientation: imageOrientation)
            let handler = VNImageRequestHandler(cgImage: cgImage)
            
            do {
                try handler.perform([request])
            } catch {
                Task { @MainActor in
                    self.isLoading = false
                    self.errorMessage = "Failed to perform image request: \(error.localizedDescription)"
                    self.predictionResult = "Prediction failed."
                    print("Image request handler error: \(error)")
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func formatPredictionResult(identifier: String) -> String {
        //        let confidencePercentage = confidence * 100
        return identifier
    }
    
    var isParentPresent: Bool {
        let result = predictionResult == "20-29" || predictionResult == "30-39" ||
               predictionResult == "40-49" || predictionResult == "50-59" ||
               predictionResult == "60-69" || predictionResult == "more than 70"
        
        print("DEBUG - predictionResult: '\(predictionResult)', isParentPresent: \(result)")
        return result
    }
    
    func resetPrediction() {
        capturedImage = nil
        predictionResult = "No prediction yet"
        errorMessage = nil
    }
    
    // MARK: - Computed Properties
    var hasValidModel: Bool {
        return visionModel != nil
    }
    
    var canPredict: Bool {
        return hasValidModel && !isLoading
    }
}

// Optional helper for explicit image orientation (Vision usually infers this)
// extension CGImagePropertyOrientation {
//     init(_ uiImageOrientation: UIImage.Orientation) {
//         switch uiImageOrientation {
//             case .up: self = .up
//             case .down: self = .down
//             case .left: self = .left
//             case .right: self = .right
//             case .upMirrored: self = .upMirrored
//             case .downMirrored: self = .downMirrored
//             case .leftMirrored: self = .leftMirrored
//             case .rightMirrored: self = .rightMirrored
//             @unknown default: self = .up
//         }
//     }
// }
