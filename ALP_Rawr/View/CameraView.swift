//
//  CameraView.swift
//  ALP_Rawr
//
//  Created by Dave Wirjoatmodjo on 23/05/25.
//

import SwiftUI

struct CameraView: View {
    @ObservedObject var viewModel: AgePredictionViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToMapView = false
    
    @ObservedObject private var watchConnectivity = WatchConnectivityManager.shared
    
    init(viewModel: AgePredictionViewModel) {
        self.viewModel = viewModel
        WatchConnectivityManager.shared.agePredictionVM = viewModel
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
 
                VStack(spacing: 8) {
                    Image(systemName: "figure.2.and.child.holdinghands")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                    
                    Text("Parent Check Required!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Choose a photo with your parent or guardian to start walking your pet safely!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.orange.opacity(0.1))
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
                
                // Image Display Section
                VStack(spacing: 12) {
                    if let image = viewModel.capturedImage {
                        VStack(spacing: 8) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 250)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.green.opacity(0.6), lineWidth: 3)
                                )
                                .shadow(color: .green.opacity(0.3), radius: 8, x: 0, y: 4)
                            
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Photo captured!")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                    .fontWeight(.medium)
                            }
                        }
                    } else { // buat placeholder kalo blm ada foto
                        VStack(spacing: 16) {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(height: 250)
                                .overlay(
                                    VStack(spacing: 12) {
                                        Image(systemName: "photo.fill")
                                            .font(.system(size: 50))
                                            .foregroundColor(.blue.opacity(0.7))
                                        
                                        VStack(spacing: 4) {
                                            Text("Ready to choose a photo!")
                                                .font(.headline)
                                                .fontWeight(.semibold)
                                            
                                            Text("Select a picture of your parent")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .multilineTextAlignment(.center)
                                        }
                                    }
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [10, 5]))
                                        .foregroundColor(.blue.opacity(0.4))
                                )
                        }
                    }
                }
                
                // Analysis Result Section
                VStack(spacing: 12) {
                    if viewModel.isLoading { // buat tunjukin loading view nya gmn
                        VStack(spacing: 8) {
                            HStack {
                                ProgressView()
                                    .scaleEffect(1.2)
                                    .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                                Text("Checking for parent...")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            
                            Text("This might take a moment")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.orange.opacity(0.1))
                        )
                    } else if !viewModel.predictionResult.isEmpty && viewModel.predictionResult != "No prediction yet" { // kalo sudah selesai loading dan predictionresult sudah ada isi
                        
                        let parentPresent = viewModel.isParentPresent
                        
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: parentPresent ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                    .foregroundColor(parentPresent ? .green : .orange)
                                    .font(.title3)
                                
                                Text(parentPresent ? "Parent/Guardian Detected!" : "No Parent/Guardian Found")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .multilineTextAlignment(.center)
                            }
                            
                            if parentPresent { // kalo true maka jadi warna ijo
                                VStack(spacing: 4) {
                                    Text("Great! You can now go on a walk!")
                                        .font(.subheadline)
                                        .foregroundColor(.green)
                                        .fontWeight(.semibold)
                                    
                                    Text("Your parent or guardian has been verified. Stay safe and have fun!")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                        .multilineTextAlignment(.center)
                                }
                            } else { // kalo false dikasih tunjuk
                                VStack(spacing: 4) {
                                    Text("Please take a photo with your parent or guardian")
                                        .font(.subheadline)
                                        .foregroundColor(.red)
                                        .fontWeight(.medium)
                                    
                                    Text("Age detected: \(viewModel.predictionResult)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(parentPresent ? Color.green.opacity(0.1) : Color.orange.opacity(0.1))
                        )
                    }
                    
                    // Error Message
                    if let errorMessage = viewModel.errorMessage {
                        VStack(spacing: 4) {
                            HStack {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(.red)
                                Text("Oops! Something went wrong")
                                    .fontWeight(.medium)
                            }
                            
                            Text(errorMessage)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                        }
                        .foregroundColor(.red)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.red.opacity(0.1))
                        )
                    }
                }
                
                Spacer()
                
                VStack(spacing: 12) {
                    // Primary Camera Button
                    Button(action: {
                        viewModel.openCamera() // untuk load model dan toggle camera boolean
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "camera.fill")
                                .font(.title3)
                            Text("Choose Photo")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: viewModel.canPredict ? [Color.blue, Color.blue.opacity(0.8)] : [Color.gray, Color.gray.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: viewModel.canPredict ? .blue.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
                    }
                    .disabled(!viewModel.canPredict)
                    .scaleEffect(viewModel.canPredict ? 1.0 : 0.95)
                    .animation(.easeInOut(duration: 0.2), value: viewModel.canPredict)
                    
                    HStack(spacing: 12) {
                        //
                        if viewModel.capturedImage != nil {
                            Button(action: {
                                viewModel.resetPrediction()
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "arrow.clockwise")
                                    Text("Try Again")
                                }
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                        
                        if !viewModel.predictionResult.isEmpty && viewModel.predictionResult != "No prediction yet" && viewModel.isParentPresent { // semisal sudah parent verified, maka nanti status nya disend ke watch dan navigate auto ke map view
                            Button(action: {
                                watchConnectivity.sendStatusToWatch()
                                navigateToMapView = true
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "figure.walk")
                                    Text("Start Walking!")
                                }
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    LinearGradient(
                                        colors: [Color.green, Color.green.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                                .shadow(color: .green.opacity(0.3), radius: 4, x: 0, y: 2)
                            }
                        } else {
                            Button(action: {
                                dismiss()
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "xmark")
                                    Text("Cancel")
                                }
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.secondary.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                    }
                }
                .navigationDestination(isPresented: $navigateToMapView) {
                    MapView()
                }
            }
            .padding()
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
        .alert("Loading AI Model", isPresented: .constant(viewModel.isLoading && !viewModel.hasValidModel)) {
        } message: {
            Text("Getting ready to check for parents... Please wait!")
        }
        .onChange(of: viewModel.isParentPresent) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                watchConnectivity.sendStatusToWatch()
                navigateToMapView = true
            }
        }
        .onChange(of: watchConnectivity.shouldShowCameraView) {
            if !watchConnectivity.shouldShowCameraView {
                dismiss()
            }
        }
    }
}


#Preview {
    //    CameraView()
}
