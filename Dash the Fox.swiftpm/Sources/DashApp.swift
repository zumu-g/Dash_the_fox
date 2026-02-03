import SwiftUI
import SpriteKit

@main
struct DashApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .ignoresSafeArea()
        }
    }
}

struct ContentView: View {
    var body: some View {
        SpriteView(scene: GameScene(size: UIScreen.main.bounds.size))
            .ignoresSafeArea()
    }
}
