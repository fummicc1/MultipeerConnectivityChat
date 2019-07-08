import UIKit

class ResultViewController: UIViewController {

    @IBOutlet var resultLabel: UILabel!
    @IBOutlet var scoreLabel: UILabel!
    
    var gradientLayer: CAGradientLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if BattleManager.shared.me.score > BattleManager.shared.opponent?.score ?? 0 {
            resultLabel.text = "勝利！！"
            createGradientView(isWin: true)
        } else if BattleManager.shared.me.score < BattleManager.shared.opponent?.score ?? 0 {
            resultLabel.text = "敗北..!"
            createGradientView(isWin: false)
        } else {
            resultLabel.text = "同点〜"
        }
        scoreLabel.text = "\(BattleManager.shared.me.score)点"
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
        gradientLayer.frame = view.bounds
    }
    
    @IBAction func retry() {
        BattleManager.shared.resetGame()
        guard let homeViewController = storyboard?.instantiateInitialViewController() else { return }
        present(homeViewController, animated: true, completion: nil)
    }
    
}
