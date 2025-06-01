//
//  HomeView.swift
//  ALP_Rawr
//
//  Created by student on 16/05/25.
//

import SwiftUI
import SpriteKit

struct PetHomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var petHomeViewModel: PetHomeViewModel
    @EnvironmentObject var diaryViewModel: DiaryViewModel
    
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
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.green.opacity(0.1)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 10) {
                // Pet Info Header
                HStack(spacing: 15) {
                    // Pet Avatar with Mood Badge
                    ZStack {
                        Circle()
                            .fill(.white)
                            .frame(width: 80, height: 80)
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                        
                        // Pet SF Symbol
                        Image(systemName: "dog.fill")
                            .font(.system(size: 35))
                            .foregroundColor(.brown)
                    }
                    
                    // Pet Name and Level
                    VStack(alignment: .leading, spacing: 5) {
                        Text(petHomeViewModel.pet.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                )
                
                // Pet Stats Cards
                VStack(spacing: 10) {
                    HStack(spacing: 15) {
                        StatusCardView(
                            title: "Health",
                            value: Int(petHomeViewModel.pet.hp),
                            maxValue: 100,
                            color: .red,
                            icon: "heart.fill"
                        )
                        
                        StatusCardView(
                            title: "Hunger",
                            value: Int(petHomeViewModel.pet.hunger),
                            maxValue: 100,
                            color: .orange,
                            icon: "fork.knife"
                        )
                    }
                    
                    HStack(spacing: 15) {
                        VStack(spacing: 2) {
                            Text("Mood")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            Image(petHomeViewModel.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.white.opacity(0.9))
                                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
                        )
                    }
                }
                
                // Main Game Area with SpriteKit Scene
                ZStack {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(.white.opacity(0.95))
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    VStack {
                        // Game area title
                        HStack {
                            Text("Pet Area")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 15)
                        
                        // SpriteKit Scene
                        SpriteView(scene: scene)
                            .frame(height: UIDevice.current.userInterfaceIdiom == .pad ? 800 : 400)
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .padding(.horizontal, 15)
                            .padding(.bottom, 15)
                            .onAppear {
                                scene.onPet = {
                                    petHomeViewModel.applyInteraction(.petting)
                                }
                                
                                scene.onShower = {
                                    petHomeViewModel.applyInteraction(.showering)
                                }
                                
                                scene.onFeed = {
                                    petHomeViewModel.applyInteraction(.feeding)
                                }
                            }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 11)
            .padding(.bottom, 4)
        }
        .onAppear {
            if authViewModel.isSigningIn, let user = authViewModel.user {
                petHomeViewModel.fetchPetData()
                petHomeViewModel.checkCurrEmotion()
            }
            
            if !petHomeViewModel.hasFetchData {
                petHomeViewModel.fetchPetData()
            }
        }
        .onChange(of: authViewModel.user) { _, newUser in
            if let _ = newUser {
                petHomeViewModel.fetchPetData()
                petHomeViewModel.checkCurrEmotion()
            }
        }
        .onChange(of: petHomeViewModel.pet.currMood) {_, newMood in
            diaryViewModel.addEntry(DiaryEntry(id: UUID().uuidString, data: ["userId": authViewModel.myUser.uid, "title": petHomeViewModel.pet.currMood, "text": "\(petHomeViewModel.pet.name) is now \(petHomeViewModel.pet.currMood)", "createdAt": Date()]))
        }
//        .onChange(of: petHomeViewModel.pet.bond) {_, newMood in
//            diaryViewModel.addEntry(DiaryEntry(id: UUID().uuidString, data: ["userId": authViewModel.myUser.uid, "title": petHomeViewModel.pet.currMood, "text": "\(authViewModel.myUser.displayName)'s bond with \(petHomeViewModel.pet.name) is now \(petHomeViewModel.pet.currMood)", "createdAt": Date()]))
//        }
        .onChange(of: petHomeViewModel.pet.hunger) { _, newHunger in
            let petName = petHomeViewModel.pet.name
            let userId = authViewModel.myUser.uid

            var text: String = ""
            var title: String = ""

            if newHunger == 0 {
                text = "\(petName) is starving :("
                title = "😿"
            } else if newHunger == 100 {
                text = "\(petName) is well fed!"
                title = "😄"
            } else {
                return
            }

            let entry = DiaryEntry(
                id: UUID().uuidString,
                data: [
                    "userId": userId,
                    "title": title,
                    "text": text,
                    "createdAt": Date()
                ]
            )

            diaryViewModel.addEntry(entry)
        }
    }
}


#Preview {
    PetHomeView()
        .environmentObject(AuthViewModel())
        .environmentObject(PetHomeViewModel(petService: LivePetService()))
        .environmentObject(DiaryViewModel())
}
