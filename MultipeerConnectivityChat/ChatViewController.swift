import UIKit

class ChatViewController: UIViewController {

    @IBOutlet weak var chatTextView: UITextView! // shared interface among all users.
    @IBOutlet weak var chatTextField: UITextField! //  Userself can input text.
    @IBOutlet weak var connectedDevicesLabel: UILabel! // show current connected devices.
    
    private let chatService = MultipeerChatService()        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        chatTextView.isEditable = false
        chatTextField.delegate = self
        chatService.delegate = self
    }
    
    // send text to others via P2P(BlueTooth).
    func sendText(_ text: String) {
        chatService.send(text: text)
    }
}

extension ChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        sendText(textField.text!)
    }
}

extension ChatViewController: ChatControlAPI {
    
    func connectedDeviceChanged(service: MultipeerChatService, devices: [String]) {
        DispatchQueue.main.async {
            self.connectedDevicesLabel.text = "Connected devices: \(devices.joined(separator: ","))"
        }
    }
    
    func textRecieved(service: MultipeerChatService, text: String) {
        DispatchQueue.main.async {
            self.chatTextView.text += text
        }
    }
}
