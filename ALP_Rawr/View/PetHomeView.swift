//
//  HomeView.swift
//  ALP_Rawr
//
//  Created by student on 16/05/25.
//

import SwiftUI
import SpriteKit

//SpriteView(scene: scene)
//    .frame(width: 300, height: 400)
//    .background(Color.green.opacity(0.1))
//    .onAppear {
//        scene.onPet = {
//            petHomeViewModel.applyInteraction(.petting)
//        }
//    }

struct PetHomeView: View {
    @EnvironmentObject var petHomeViewModel: PetHomeViewModel
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    @State private var scene: SpriteScene = {
        let scene = SpriteScene()
        scene.size = CGSize(width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.height)
        scene.scaleMode = .resizeFill
        scene.backgroundColor = .clear
        return scene
    }()
    
    var body: some View {
//        GeometryReader { geometry in
            ZStack{
                LinearGradient(
                    gradient: Gradient(colors:[Color.blue.opacity(0.1), Color.green.opacity(0.1)]),
                   startPoint: .top,
                   endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(){
                    // Pet Status Section
                    HStack(spacing: 20){
                        ZStack{
                            Circle()
                                .fill(.white)
                                .frame(width: 80, height: 80)
                                .shadow(radius: 3)
                            
                            Image(petHomeViewModel.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70)
                                .clipShape(Circle())
                        }
                        
                        VStack(alignment: .leading, spacing: 8){
                            Text("\(petHomeViewModel.pet.name)")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            HStack(spacing: 8){
                                Text("Hunger: ")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Text("\(petHomeViewModel.pet.hunger)")
                                    .foregroundColor(.secondary)
                            }
                            
                            //Progress bar
                            ProgressView(value: Double(petHomeViewModel.pet.hunger), total: 100.0)
                                .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                                .scaleEffect(x: 1, y: 0.5)
                        }
                        
                        Spacer()
                    }
                    .padding([.top, .leading, .bottom], 15)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white.opacity(0.9))
                            .shadow(radius: 2)
                    )
                    .padding(.horizontal, 20)
                    
                    ZStack{
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.9))
                            .shadow(radius: 5)
                        
                        SpriteView(scene: scene)
                            .frame(width: 350, height: 600)
                            .background(Color.clear)
                            .onAppear {
                                scene.onPet = {
                                    petHomeViewModel.applyInteraction(.petting)
                                }
                                
                                scene.onShower = {
                                    print("Mandikan")
                                }
                                
                                scene.onShower = {
                                    print("Kasih makan")
                                }
                            }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
            }
//        }
        .onAppear{
            petHomeViewModel.fetchPetData()
        }
    }
}

private func actionButton(icon: String, title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 15)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.8))
                    .shadow(radius: 1)
            )
        }
    }

#Preview {
    PetHomeView()
        .environmentObject(PetHomeViewModel())
}
