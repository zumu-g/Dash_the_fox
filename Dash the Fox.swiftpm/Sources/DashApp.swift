//
//  DashApp.swift
//  Dash the Fox
//
//  A SwiftUI app that hosts the SpriteKit game scene.
//  This is the main entry point for the iOS app.
//
//  Created with Claude Code assistance.
//

import SwiftUI
import SpriteKit

@main
struct DashApp: App {
    var body: some Scene {
        WindowGroup {
            GameView()
                .ignoresSafeArea()
                .statusBarHidden()
        }
    }
}

struct GameView: View {
    var scene: SKScene {
        let scene = GameScene()
        scene.size = UIScreen.main.bounds.size
        scene.scaleMode = .resizeFill
        return scene
    }

    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
    }
}
