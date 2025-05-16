//
//  HomeView.swift
//  ALP_Rawr
//
//  Created by student on 16/05/25.
//

import SwiftUI
import SpriteKit

struct HomeView: View {
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
            Text("🐾 Home Menu") // Example UI above
                .font(.title)

            SpriteView(scene: scene)
                .frame(width: 300, height: 400)
                .background(Color.clear)

            Button("Say Hi to Dog") {
                // Example future interaction
                print("Hello Dog!")
            }
        }
    }
}

#Preview {
    HomeView()
}
