//
//  HomeView.swift
//  ALP_Rawr
//
//  Created by student on 16/05/25.
//

import SwiftUI
import SpriteKit

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
                petInfoHeader
                
                // Pet Stats Cards
                petStatsSection
                
                // Main Game Area with SpriteKit Scene
                gameArea
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 11)
            .padding(.bottom, 4)
        }
        .onAppear {
            petHomeViewModel.fetchPetData()
        }
    }
    
    // MARK: - Pet Info Header
    private var petInfoHeader: some View {
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
    }
    
    // MARK: - Pet Stats Section
    private var petStatsSection: some View {
        VStack(spacing: 10) {
            HStack(spacing: 15) {
                statCard(
                    title: "Health",
                    value: petHomeViewModel.pet.hp,
                    maxValue: 100,
                    color: .red,
                    icon: "heart.fill"
                )
                
                statCard(
                    title: "Hunger",
                    value: petHomeViewModel.pet.hunger,
                    maxValue: 100,
                    color: .orange,
                    icon: "fork.knife"
                )
            }
            
            HStack(spacing: 15) {
                moodCard()
            }
        }
    }
    
    // MARK: - Game Area
    private var gameArea: some View {
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
                    .frame(height: 400)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .padding(.horizontal, 15)
                    .padding(.bottom, 15)
                    .onAppear {
                        scene.onPet = {
                            petHomeViewModel.applyInteraction(.petting)
                        }
                        
                        scene.onShower = {
                            petHomeViewModel.applyInteraction(.showering)
                            print("Pet is being cleaned!")
                        }
                        
                        scene.onFeed = {
                            petHomeViewModel.applyInteraction(.feeding)
                            print("Pet is being fed!")
                        }
                    }
            }
        }
    }
    
    // MARK: - Helper Views
    private func statCard(title: String, value: Int, maxValue: Int, color: Color, icon: String) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.caption)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            
            Text("\(value)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // Progress bar
            ProgressView(value: Double(value), total: Double(maxValue))
                .progressViewStyle(LinearProgressViewStyle(tint: color))
                .scaleEffect(x: 1, y: 0.8)
        }
        .padding(15)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.white.opacity(0.9))
                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
        )
    }
    
    private func moodCard() -> some View {
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


#Preview {
    PetHomeView()
        .environmentObject(PetHomeViewModel())
}
