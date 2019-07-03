import UIKit

class QuizViewController: UIViewController {

    @IBOutlet private weak var quizChapterLabel: UILabel!
    @IBOutlet private weak var quizContentLabel: UILabel!
    @IBOutlet private weak var answerViewHeight: NSLayoutConstraint!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
    }
}
