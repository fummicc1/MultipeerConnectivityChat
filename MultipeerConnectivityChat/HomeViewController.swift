import UIKit
import MultipeerConnectivity
import PKHUD

class HomeViewController: UIViewController {
    
    private var quizModel: QuizModel?
    var quizViewController: QuizViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        quizViewController = storyboard?.instantiateViewController(withIdentifier: "quizViewController") as? QuizViewController
        quizModel = QuizModel(quizDelegate: quizViewController!, service: MultipeerQuizService(), connectionDelegate: self)
    }
}

extension HomeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
}

extension HomeViewController: MCSessionAPI {
    func connectionEstablished(service: MultipeerQuizService, peerID: MCPeerID) {
         DispatchQueue.main.async {
            HUD.flash(.label("接続完了"))
            guard let quizViewController = self.quizViewController else { return }
            self.present(quizViewController, animated: true, completion: {
                self.quizModel?.stopObseving()
            })
        }
    }
}

//extension HomeViewController: QuizSessionAPI {
//    func quizRecieved(service: MultipeerQuizService, data: SharedData) {
//
//    }
//
//
//    func connectedDeviceChanged(service: MultipeerQuizService, devices: [String]) {
//        DispatchQueue.main.async {
//            self.connectedDevicesLabel.text = "Connected devices: \(devices.joined(separator: ","))"
//        }
//    }
//
//    func textRecieved(service: MultipeerQuizService, text: String) {
//        DispatchQueue.main.async {
//            self.chatTextView.text += text
//        }
//    }
//}
