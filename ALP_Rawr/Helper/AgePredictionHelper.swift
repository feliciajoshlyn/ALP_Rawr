//
//  AgePredictionHelper.swift
//  ALP_Rawr
//
//  Created by Dave Wirjoatmodjo on 23/05/25.
//

import CoreML
import Vision
import UIKit

class AgePredictionHelper {
    static let shared = AgePredictionHelper()

    func predictAge(from image: UIImage, completion: @escaping (String, Float) -> Void) {
        guard let cgImage = image.cgImage else {
            print("Invalid image.")
            return
        }

        do {
            let config = MLModelConfiguration()
            let model = try AgeClassifier(configuration: config).model
            let vnModel = try VNCoreMLModel(for: model)

            let request = VNCoreMLRequest(model: vnModel) { request, error in
                if let results = request.results as? [VNClassificationObservation],
                   let top = results.first {
                    completion(top.identifier, top.confidence)
                } else {
                    print("Prediction failed.")
                }
            }

            let handler = VNImageRequestHandler(cgImage: cgImage)
            try handler.perform([request])
        } catch {
            print("Failed to run model: \(error.localizedDescription)")
        }
    }
}

