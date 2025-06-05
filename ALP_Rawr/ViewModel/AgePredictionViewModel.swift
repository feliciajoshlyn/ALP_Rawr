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
    
    @Published var capturedImage: UIImage?
    @Published var predictionResult: String = "No prediction yet"
    @Published var isLoading: Bool = false
    @Published var showCamera: Bool = false
    @Published var errorMessage: String?
    @Published var isParentThere: Bool = false
    
    
    private var visionModel: VNCoreMLModel?
    private var ageClassifierInstance: AgeClassifier?
    
    
    init() {
        loadModel()
    }
    

    private func loadModel() {
        if isLoading { return }
        isLoading = true
        errorMessage = nil
        
        Task(priority: .userInitiated) {
            do {
                let config = MLModelConfiguration() // config untuk parameter ML nya
                let classifier = try AgeClassifier(configuration: config)
                self.ageClassifierInstance = classifier
                
                let vnModel = try VNCoreMLModel(for: classifier.model) // karena ini yang dipake utk masuk ke vision
                
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
    
    func openCamera() {
        if visionModel == nil && !isLoading {
            loadModel() // ngeload model dulu
        }
        showCamera = true // toggle boolean showCamera
    }
    
    func handleCapturedImage(_ image: UIImage) {
        self.capturedImage = image
        predictAge(from: image)
    }
    
    // untuk predict, terima image, and return result disini
    func predictAge(from image: UIImage) {
        guard let visionModel = self.visionModel else { // pake variable visionModel yang sudah diisi vnModel
            self.errorMessage = "Model not loaded. Please wait or try reloading."
            self.predictionResult = "Error: Model not ready."
            if !isLoading { loadModel() }
            return
        } // guard supaya each of the variable harus keisi dulu, semisal fail maka early exit
        
        guard let cgImage = image.cgImage else {
            self.errorMessage = "Invalid image format: Could not convert UIImage to CGImage."
            self.predictionResult = "Error: Invalid image."
            return
        } // ini untuk isi image sama cgImage -> format image yang diinput user
        
        self.isLoading = true
        self.errorMessage = nil
        self.predictionResult = "Predicting..."
        
        
        Task(priority: .userInitiated) { // async tapi biar dianggap jadi main thread di background
            let request = VNCoreMLRequest(model: visionModel) { [weak self] request, error in //Prevents memory leaks makanya buat self baru
                Task { @MainActor in // Ensure UI updates are on the main actor
                    guard let self = self else { return }
                    self.isLoading = false
                    
                    if let error = error {
                        self.errorMessage = "Prediction error: \(error.localizedDescription)"
                        self.predictionResult = "Prediction failed."
                        print("VNRequest error: \(error)")
                        return
                    }
                    
                    // ini untuk masukin result classification ke observations variable
                    guard let observations = request.results as? [VNClassificationObservation],
                          let topObservation = observations.first else { // untuk cari prediction paling pertama ketemu dan cocok
                        self.errorMessage = "Could not process prediction results or no results returned."
                        self.predictionResult = "No prediction available."
                        print("Failed to get VNClassificationObservation results or results are empty.")
                        return
                    }
                    
                    // masukin hasil topObersvation ke predictionResult
                    self.predictionResult = self.formatPredictionResult(
                        identifier: topObservation.identifier
                    )
                    self.errorMessage = nil
                    print("Prediction successful: \(self.predictionResult)")
                }
            }
            
            request.imageCropAndScaleOption = .centerCrop // supaya vision bisa handle resizing/cropping
            
            // terima request image
            let handler = VNImageRequestHandler(cgImage: cgImage)
            
            do {
                try handler.perform([request]) // masukin semua request deh
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
    
    private func formatPredictionResult(identifier: String) -> String {
        //        let confidencePercentage = confidence * 100
        return identifier
    }
    
    
    // variable yang tentukan nanti apakah parent sudah verify apa blm
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

