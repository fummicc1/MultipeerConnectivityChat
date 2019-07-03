import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var chatTextView: UITextView! // shared interface among all users.
    @IBOutlet weak var chatTextField: UITextField! //  Userself can input text.
    @IBOutlet weak var connectedDevicesLabel: UILabel! // show current connected devices.
    
    private var quizModel: QuizModel?
    weak var quizViewController: QuizViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        let quizViewController = QuizViewController(nibName: "", bundle: nil)
        quizModel = QuizModel(delegate: quizViewController, service: MultipeerQuizService())
    }
    // send text to others via P2P(BlueTooth).
}

extension HomeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
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
