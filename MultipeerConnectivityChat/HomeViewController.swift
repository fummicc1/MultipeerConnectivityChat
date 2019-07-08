import UIKit
import MultipeerConnectivity
import PKHUD

class HomeViewController: UIViewController {
    
    var quizViewController: QuizViewController?
    
    @IBOutlet var joinRoomButton: UIButton!
    @IBOutlet var createRoomButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
        joinRoomButton.layer.cornerRadius = 30
        createRoomButton.layer.cornerRadius = 30
    }
    
    func setup() {
        quizViewController = storyboard?.instantiateViewController(withIdentifier: "quizViewController") as? QuizViewController
        BattleManager.shared.quizDelegate = quizViewController
        BattleManager.shared.connectionDelegate = self
    }
    
    @IBAction func tappedCreateRoomButton() {
        BattleManager.shared.me.setIsHost(true)
        BattleManager.shared.startObserving(isHost: true)
    }
    
    @IBAction func tappedJoinRoomButton() {
        BattleManager.shared.me.setIsHost(false)
        BattleManager.shared.startObserving(isHost: false)
    }
}

extension HomeViewController: MCSessionAPI {
    func connectionEstablished(service: MultipeerQuizService, peerID: MCPeerID) {
         DispatchQueue.main.async {
            HUD.flash(.label("接続完了"))
            guard let quizViewController = self.quizViewController else { return }
            self.present(quizViewController, animated: true, completion: {
                BattleManager.shared.stopObseving()
            })
        }
    }
}
