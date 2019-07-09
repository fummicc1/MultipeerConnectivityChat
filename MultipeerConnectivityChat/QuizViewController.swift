import UIKit
import PKHUD
import MultipeerConnectivity

class QuizViewController: UIViewController {
    
    @IBOutlet private weak var quizChapterLabel: UILabel!
    @IBOutlet private weak var quizContentLabel: AnimationLabel!
    @IBOutlet private weak var answerViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var answerView: UIView!
    @IBOutlet private weak var choiceButton1: UIButton!
    @IBOutlet private weak var choiceButton2: UIButton!
    
    var opponentAnsweredText: String = "問1." {
        didSet {
            quizChapterLabel.text = opponentAnsweredText
        }
    }
    var quizList: [QuizData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateQuizData()
        let hideGesture = UITapGestureRecognizer(target: self, action: #selector(hideHUD))
        (UIApplication.shared.delegate as! AppDelegate).window?.addGestureRecognizer(hideGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startQuiz()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let touch = touches.first!
        if touch.phase == .began {
            manageViewHeight()
        }
    }
    
    @objc private func hideHUD() {
        HUD.hide()
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
        if BattleManager.shared.me.isHost?.rawValue == true {
            DispatchQueue.global(qos: .default).async {
                BattleManager.shared.sendQuiz(quizList: self.quizList)
            }            
        }
    }
    
    func startNextQuiz() {
        if BattleManager.shared.me.isHost?.rawValue == true {
            quizList.removeFirst()
            DispatchQueue.global(qos: .default).async {
                BattleManager.shared.sendQuiz(quizList: self.quizList)
            }
        }
        DispatchQueue.main.async {
            self.setTag()
            if self.quizList.isEmpty {
                guard let resultViewController = self.storyboard?.instantiateViewController(withIdentifier: "ResultViewController") else { return }
                self.present(resultViewController, animated: true, completion: nil)
            }
        }
    }
    
    func displayQuiz(_ quizList: [QuizData]) {
        self.quizChapterLabel.text = "問\(9 - self.quizList.count + 1)."
        let quiz = quizList.first!
        if self.choiceButton1.tag == 10 {
            self.choiceButton1.setTitle(quiz.answer, for: .normal)
            self.choiceButton2.setTitle(quiz.fault, for: .normal)
        } else if self.choiceButton2.tag == 10 {
            self.choiceButton1.setTitle(quiz.fault, for: .normal)
            self.choiceButton2.setTitle(quiz.answer, for: .normal)
        }
        quizContentLabel.title = quiz.question
        quizContentLabel.animate()
    }
    
    func setTag() {
        let tag = 10 + Int.random(in: 0...1)
        choiceButton1.tag = tag
        choiceButton2.tag = 21 - tag
    }
    
    @IBAction func tappedAnswerButton(sender: UIButton) {
        if sender.tag == 10 {
            BattleManager.shared.me.getScore(10)
            HUD.show(.label("正解！"))
            HUD.hide(afterDelay: 1.0)
            BattleManager.shared.me.playerStateChanged(true)
        } else if sender.tag == 11 {
            HUD.show(.label("不正解..."))
            BattleManager.shared.me.getScore(-10)
            HUD.hide(afterDelay: 1.0)
            BattleManager.shared.me.playerStateChanged(false)
        }
        BattleManager.shared.me.updateAnsweredDate(Date())
        DispatchQueue.global(qos: .default).async {
            BattleManager.shared.sendIfIAmHost(BattleManager.shared.me.isHost!)
        }
    }
}

extension QuizViewController: QuizSessionAPI {
    
    func recievedOpponentData(service: MultipeerQuizService, data: User) {
        DispatchQueue.main.async {
            BattleManager.shared.opponent = data
            guard let presentedViewController = self.presentedViewController as? ResultViewController else { return }
            DispatchQueue.main.async {
                presentedViewController.setResultData()
            }
            if BattleManager.shared.me.isHost?.rawValue != true {
                BattleManager.shared.sendMyData()
            }
        }
    }
    
    func requestStartQuizIfHost(service: MultipeerQuizService) {
        if BattleManager.shared.me.isHost?.rawValue == true {
            self.startNextQuiz()
        }
    }
    
    func informBattlerAlreadyCleared(service: MultipeerQuizService) {
        DispatchQueue.main.async {
            HUD.show(.label("相手が先に回答しました..."))
            HUD.hide(afterDelay: 1.0)
            DispatchQueue.global(qos: .default).async {
                if BattleManager.shared.me.isHost?.rawValue != true {
                    BattleManager.shared.sendIfIAmHost(IsHost(rawValue: false))
                }
            }
        }
    }
    
    func quizListRecieved(service: MultipeerQuizService, data: [QuizData], from peerID: MCPeerID) {
        self.quizList = data
        DispatchQueue.main.async {
            if data.isEmpty {
                guard let resultViewController = self.storyboard?.instantiateViewController(withIdentifier: "ResultViewController") else { return }
                self.present(resultViewController, animated: true, completion: nil)
                return
            }
            DispatchQueue.global(qos: .default).async {
                if BattleManager.shared.me.isHost?.rawValue != true {                    
                    BattleManager.shared.sendQuiz(quizList: data)
                }
            }            
            self.displayQuiz(self.quizList)
        }
    }
    
    
}
