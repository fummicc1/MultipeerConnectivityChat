import UIKit
import MultipeerConnectivity
import PKHUD

class HomeViewController: UIViewController {
    
    private var quizModel: QuizModel?
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
        quizModel = QuizModel(quizDelegate: quizViewController!, service: MultipeerQuizService(), connectionDelegate: self)
    }
    
    @IBAction func tappedCreateRoomButton() {
        quizModel?.user.isHost = IsHost(rawValue: true)
        quizModel?.startObserving(isHost: true)
    }
    
    @IBAction func tappedJoinRoomButton() {
        quizModel?.user.isHost = IsHost(rawValue: false)
        quizModel?.startObserving(isHost: false)
    }
}

extension HomeViewController: MCSessionAPI {
    func connectionEstablished(service: MultipeerQuizService, peerID: MCPeerID) {
         DispatchQueue.main.async {
            HUD.flash(.label("接続完了"))
            guard let quizViewController = self.quizViewController else { return }
            quizViewController.model = self.quizModel
            self.present(quizViewController, animated: true, completion: {
                self.quizModel?.stopObseving()
            })
        }
    }
}
