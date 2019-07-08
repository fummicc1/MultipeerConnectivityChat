import UIKit

class ResultViewController: UIViewController {

    @IBOutlet var resultLabel: UILabel!
    @IBOutlet var myScoreLabel: UILabel!
    @IBOutlet var opponentScoreLabel: UILabel!
    
    var gradientLayer: CAGradientLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if BattleManager.shared.me.isHost?.rawValue == true {
            BattleManager.shared.sendMyData()
        }
    }
    
    func createGradientView(isWin: Bool) {
        gradientLayer = CAGradientLayer()
        if isWin {
            let green = UIColor.green
            let yellow = UIColor.yellow
            let orange = UIColor.orange
            let red = UIColor.red
            gradientLayer.colors = [
                red.cgColor,
                orange.cgColor,
                yellow.cgColor,
                green.cgColor,
            ]
        } else {
            let purple = UIColor.purple
            let amber = UIColor(red: 22/255, green: 94/255, blue: 131/255, alpha: 1)
            let blue = UIColor.blue
            gradientLayer.colors = [
                blue.cgColor,
                amber.cgColor,
                purple.cgColor,
            ]
        }        
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if gradientLayer == nil { return }
        gradientLayer.frame = view.bounds
    }
    
    func setResultData() {
        guard let opponent = BattleManager.shared.opponent else {
            return
        }
        if BattleManager.shared.me.score > opponent.score {
            resultLabel.text = "勝利！！"
            createGradientView(isWin: true)
        } else if BattleManager.shared.me.score < opponent.score {
            resultLabel.text = "敗北..!"
            createGradientView(isWin: false)
        } else {
            resultLabel.text = "同点〜"
        }
        myScoreLabel.text = "\(BattleManager.shared.me.score)点"
        opponentScoreLabel.text = "\(opponent.score)点"
    }
    
    @IBAction func retry() {
        BattleManager.shared.resetGame()
        guard let homeViewController = storyboard?.instantiateInitialViewController() else { return }
        present(homeViewController, animated: true, completion: nil)
    }
    
}
