import UIKit
import PKHUD
import MultipeerConnectivity

class QuizViewController: UIViewController {

    @IBOutlet private weak var quizChapterLabel: UILabel!
    @IBOutlet private weak var quizContentLabel: UILabel!
    @IBOutlet private weak var answerViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var answerView: UIView!
    @IBOutlet private weak var choiceButton1: UIButton!
    @IBOutlet private weak var choiceButton2: UIButton!
    
    var model: QuizModel?
    
    var opponentAnsweredText: String = "問1." {
        didSet {
            quizChapterLabel.text = opponentAnsweredText
        }
    }
    var quizList: [QuizData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateQuizData()
        startQuiz()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let touch = touches.first!
        if touch.phase == .began {
            manageViewHeight()
        }
    }
    
    func populateQuizData() {
        let quiz1 = QuizData(
            question: "Swiftに関する問題.\n 変数を宣言する時に使用するワードは次のうちどちらでしょう。",
            answer: "var",
            fault: "func")
        let quiz2 = QuizData(
            question: "Unityに関する問題.\n RigidbodyコンポーネントをCubeにアタッチすると、Cubeにはどんな力がかかるでしょう。",
            answer: "重力",
            fault: "浮力")
        let quiz3 = QuizData(
            question: "Swiftに関する問題.\n Int型の変数numberに1を足すコードは次のうちどれでしょう。",
            answer: "number += 1",
            fault: "1 += number")
        let quiz4 = QuizData(
            question: "Unityに関する問題.\n ゲームオブジェクトの位置や大きさ、角度などを知っている変数は何でしょう。",
            answer: "transform",
            fault: "transition")
        let quiz5 = QuizData(
            question: "Programmingに関する問題.\n if文は「もし〜だったら」という意味で使われますが、「もし〜以外だったら」という文を続けてプログラムしたいときに用いるワードを選びましょう。",
            answer: "else",
            fault: "but")
        let quiz6 = QuizData(
            question: "Unityに関する問題.\n 自身のRigidbodyコンポーネントをプログラムから取得したい場合のコードを選びましょう。",
            answer: "GetComponent<Rigidbody>()",
            fault: "Find(\"Rigidbody\")")
        let quiz7 = QuizData(
            question: "Unityに関する問題.\n iPhoneアプリもAndrpidアプリもUnityコースなら作成することができる。⚫︎か×か",
            answer: "●",
            fault: "×")
        let quiz8 = QuizData(
            question: "Swift.\n 変数を宣言する時に使用するワードは次のうちどちらでしょう。",
            answer: "var",
            fault: "func")
        let quiz9 = QuizData(
            question: "Swift.\n 変数を宣言する時に使用するワードは次のうちどちらでしょう。",
            answer: "var",
            fault: "func")
        quizList = [
            quiz1,
            quiz2,
            quiz3,
            quiz4,
            quiz5,
            quiz6,
            quiz7,
            quiz8,
            quiz9,
        ]
        quizList.shuffle()
    }
    
    func manageViewHeight() {
        self.answerViewHeight.constant += self.answerViewHeight.constant == 0 ? 300 : -300
        UIView.transition(with: answerView, duration: 0.3, options: [.curveEaseIn], animations: {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func startQuiz() {
        setTag()
        if model?.user.isHost == true {
            quizContentLabel.text = ""
            model?.sendQuiz(quizList: quizList)
        }
    }
    
    func displayQuiz(_ quizList: [QuizData]) {
        self.quizChapterLabel.text = "問\(10 - self.quizList.count + 1)."
        let quiz = quizList.first!
        if self.choiceButton1.tag == 10 {
            self.choiceButton1.setTitle(quiz.answer, for: .normal)
            self.choiceButton2.setTitle(quiz.fault, for: .normal)
        } else if self.choiceButton2.tag == 10 {
            self.choiceButton1.setTitle(quiz.fault, for: .normal)
            self.choiceButton2.setTitle(quiz.answer, for: .normal)
        }
        for c in quiz.question {
            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.05))
            quizContentLabel.text?.append(c)
        }
    }
    
    func setTag() {
        let tag = 10 + Int.random(in: 0...1)
        choiceButton1.tag = tag
        choiceButton2.tag = 21 - tag
    }
    
    @IBAction func tappedAnswerButton(sender: UIButton) {
        if sender.tag == 10 {
            model?.user.score += 10
            HUD.show(.label("正解！"))
            HUD.hide(afterDelay: 1.0)
        } else if sender.tag == 11 {
            HUD.show(.label("不正解..."))
            HUD.hide(afterDelay: 1.0)
        }
        model?.user.answeredDate = Date()
        model?.sendMyData()
        quizList.removeFirst()
        HUD.show(.label("通信中..."))
    }
}

extension QuizViewController: QuizSessionAPI {
    func quizListRecieved(service: MultipeerQuizService, data: [QuizData], from peerID: MCPeerID) {
        self.quizList = data
        DispatchQueue.main.async {
            self.quizContentLabel.text = ""
            self.displayQuiz(self.quizList)
            if self.model?.user.isHost != true {
                let data = try! JSONEncoder().encode(data)
                try! self.model?.service.session.send(data, toPeers: [peerID], with: .reliable)
            }
        }
    }
    
    func opponentDataRecieved(service: MultipeerQuizService, data: User) {
        model?.opponent = data
    }
}
