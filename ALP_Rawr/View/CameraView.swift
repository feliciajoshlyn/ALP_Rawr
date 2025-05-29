//
//  CameraView.swift
//  ALP_Rawr
//
//  Created by Dave Wirjoatmodjo on 23/05/25.
//

import SwiftUI

struct CameraView: View {
    @StateObject private var viewModel = AgePredictionViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let image = viewModel.capturedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 300)
                        .overlay(
                            VStack {
                                Image(systemName: "camera")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                                Text("No image captured")
                                    .foregroundColor(.gray)
                            }
                        )
                }
                
                // Prediction Result
                VStack(spacing: 8) {
                    if viewModel.isLoading {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Analyzing...")
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Text(viewModel.predictionResult)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // Error Message
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        viewModel.openCamera()
                    }) {
                        HStack {
                            Image(systemName: "camera")
                            Text("Open Camera")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.canPredict ? Color.blue : Color.gray)
                        .cornerRadius(12)
                    }
                    .disabled(!viewModel.canPredict)
                    
                    if viewModel.capturedImage != nil {
                        Button(action: {
                            viewModel.resetPrediction()
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Reset")
                            }
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("Age Prediction")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $viewModel.showCamera) {
            ImagePicker(image: Binding(
                get: { viewModel.capturedImage },
                set: { image in
                    if let image = image {
                        viewModel.handleCapturedImage(image)
                    }
                }
            ))
        }
        .alert("Model Loading", isPresented: .constant(viewModel.isLoading && !viewModel.hasValidModel)) {
            // Alert will show while loading
        } message: {
            Text("Loading age prediction model...")
        }
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.image = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.image = originalImage
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    CameraView()
}
