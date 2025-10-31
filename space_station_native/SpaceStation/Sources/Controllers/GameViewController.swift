import UIKit
import SpriteKit
import AVFoundation

class GameViewController: UIViewController {
    private var skView: SKView!
    private var gameScene: GameScene!
    private var audioPlayer: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSKView()
        setupAudio()
        startHomeScreen()
    }

    private func setupSKView() {
        skView = SKView(frame: view.bounds)
        skView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(skView)

        // Debug options (remove in production)
//        skView.showsFPS = true
//        skView.showsNodeCount = true
//        skView.showsPhysics = true
    }

    private func setupAudio() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }

    private func startHomeScreen() {
        gameScene = GameScene(size: view.bounds.size)
        gameScene.scaleMode = .aspectFill
        gameScene.gameDelegate = self
        skView.presentScene(gameScene)
    }

    func pauseGame() {
        gameScene?.isPaused = true
        audioPlayer?.pause()
    }

    func resumeGame() {
        gameScene?.isPaused = false
        audioPlayer?.play()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
}

extension GameViewController: GameSceneDelegate {
    func gameSceneDidRequestRestart(_ scene: GameScene) {
        scene.resetGame()
    }
}
