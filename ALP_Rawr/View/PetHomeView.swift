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
        return scene
    }()
    
    var body: some View {
        VStack {
            Text("🐾 Dog Home Menu") // Example UI above
                .font(.title)
            HStack{
                Image(petHomeViewModel.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70
                    )
                Text(
                    "\(petHomeViewModel.pet.emotions["Happy"]?.level ?? 0)"
                )
            }
            
            SpriteView(scene: scene)
                .frame(width: 300, height: 400)
                .background(Color.clear)
                .onAppear {
                    scene.onPet = {
                        petHomeViewModel.applyInteraction(.petting)
                    }
                }
            
            Button("Say Hi to Dog") {
                // Example future interaction
                print("Hello Dog!")
            }
        }
        .onAppear{
            petHomeViewModel.fetchPetData()
        }
    }
}

#Preview {
    PetHomeView()
        .environmentObject(PetHomeViewModel())
}
