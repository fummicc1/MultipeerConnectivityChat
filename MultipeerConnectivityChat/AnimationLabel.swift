import UIKit

class AnimationLabel: UIView, CAAnimationDelegate {
    var title: String
    var charMarginWidth: CGFloat = 1
    var charMarginHeight: CGFloat = 30
    var font = UIFont.boldSystemFont(ofSize: 24)
    var textColor = UIColor.black
    var roopCount = 0    
    var animateDuration: Double = 0.04
    var labelRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    private var labelArray: [UILabel] = []
    
    init(frame: CGRect, title: String) {
        self.title = title
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.title = ""
        super.init(coder: aDecoder)
    }
    
    func animate(random: Bool = false) {
        // reset cache.
        subviews.forEach { $0.removeFromSuperview() }
        labelArray.removeAll()
        labelRect = .zero
        
        var startX = labelRect.origin.x
        title.insert(" ", at: String.Index(encodedOffset: 0))
        for index in title.indices {
            let label = UILabel()
            label.text = String(title[index])
            label.textColor = self.textColor
            label.font = self.font
            label.sizeToFit()
            label.frame.origin.x = startX
            startX += label.frame.width + charMarginWidth
            label.frame.origin.y = labelRect.origin.y
            label.alpha = 0
            if bounds.width < label.frame.maxX {
                startX = bounds.origin.x
                labelRect.origin.y += charMarginHeight
                label.frame.origin.y = labelRect.origin.y
                label.frame.origin.x = startX
                startX += label.frame.width + charMarginWidth
            }
            addSubview(label)
            labelArray.append(label)
        }
        
        roopCount = 0
        if random {
            self.labelArray.shuffle()
        }
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = animateDuration
        animationGroup.fillMode = CAMediaTimingFillMode.forwards
        animationGroup.isRemovedOnCompletion = false
        
        let animation1 = CABasicAnimation(keyPath: "opacity")
        animation1.fromValue = 1.0
        animation1.toValue = 0.0
        
        animationGroup.animations = [animation1]
        animationGroup.delegate = self
        self.labelArray[0].layer.add(animationGroup, forKey: "\(roopCount)")
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    }
    
    func animationDidStart(_ anim: CAAnimation) {
        if roopCount < labelArray.count - 1 {
            
            roopCount += 1
            
            let animationGroup = CAAnimationGroup()
            animationGroup.duration = animateDuration
            animationGroup.fillMode = .forwards
            animationGroup.isRemovedOnCompletion = false
            
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.fromValue = 0.0
            animation.toValue = 1.0
            
            animationGroup.animations = [animation]
            animationGroup.delegate = self
            animationGroup.beginTime = CACurrentMediaTime() + 0.05
            labelArray[roopCount].layer.add(animationGroup, forKey: nil)
        }
    }
}


//class animationLabel:UIView, CAAnimationDelegate{
//
//    //プロパティ
//    var title:String = ""
//    var charMargin:CGFloat = 1
//    var font:UIFont = UIFont(name: "Zapfino", size: 15.0)!
//    var textColor : UIColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
//    var roopCount : Int = 0
//    var shuffledLabel : [UILabel]!
//    var animateDuration : Double = 5
//    var labelRect : CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
//
//    private var labelArray : [UILabel] = []
//
//    //イニシャライザ
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//    }
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    //文字列をランダムにフェードインさせる関数
//    func shuffleFadeAppear(){
//        self.animate(animationID: 1,random: true)
//    }
//
//
//    private func animate(animationID:Int , random:Bool = false){
//
//        if(animationID == 1){
//
//            var startx : CGFloat = labelRect.origin.x
//
//            for chr in self.title{
//                let label = UILabel()
//                label.text = String(chr)
//                label.textColor = self.textColor
//                label.font = self.font
//                label.sizeToFit()
//                label.frame.origin.x = startx
//                startx += label.frame.width + self.charMargin
//                label.frame.origin.y = labelRect.origin.y
//                label.alpha = 0
//                self.addSubview(label)
//                self.labelArray.append(label)
//            }
//
//            roopCount = 0
//            if(random){
//                self.labelArray.shuffle()
//            }
//            let animationGroup = CAAnimationGroup()
//            animationGroup.duration = animateDuration
//            animationGroup.fillMode = CAMediaTimingFillMode.forwards
//            animationGroup.isRemovedOnCompletion = false
//
//            //透明度(opacity)を1から0にする
//            let animation1 = CABasicAnimation(keyPath: "opacity")
//            animation1.fromValue = 0.0
//            animation1.toValue = 1.0
//
//            animationGroup.animations = [animation1]
//            animationGroup.delegate = self
//            self.labelArray[0].layer.add(animationGroup, forKey: nil)
//
//
//
//        }
//    }
//
//
//    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
//        // アニメーションの終了
//        if(roopCount == self.labelArray.count - 1){
//            let animationGroup = CAAnimationGroup()
//            animationGroup.duration = animateDuration
//            animationGroup.fillMode = CAMediaTimingFillMode.forwards
//            animationGroup.isRemovedOnCompletion = false
//
//            //透明度(opacity)を1から0にする
//            let animation1 = CABasicAnimation(keyPath: "opacity")
//            animation1.fromValue = 1.0
//            animation1.toValue = 0.0
//
//            animationGroup.animations = [animation1]
//            animationGroup.delegate = self
//            animationGroup.beginTime = CACurrentMediaTime() + 0.1
//            self.layer.add(animationGroup, forKey: nil)
//            roopCount += 1
//        }
//    }
//
//    func animationDidStart(_ anim: CAAnimation){
//        // アニメーションの開始
//        if(roopCount < self.labelArray.count - 1){
//            roopCount += 1
//
//            let animationGroup = CAAnimationGroup()
//            animationGroup.duration = animateDuration
//            animationGroup.fillMode = CAMediaTimingFillMode.forwards
//            animationGroup.isRemovedOnCompletion = false
//
//            //透明度(opacity)を0から1にする
//            let animation1 = CABasicAnimation(keyPath: "opacity")
//            animation1.fromValue = 0.0
//            animation1.toValue = 1.0
//
//            animationGroup.animations = [animation1]
//            animationGroup.delegate = self
//            animationGroup.beginTime = CACurrentMediaTime() + 0.5
//            self.labelArray[roopCount].layer.add(animationGroup, forKey: nil)
//        }
//    }
//
//}
//
//class ViewController: UIViewController {
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        let label = animationLabel(frame: self.view.frame)
//        label.labelRect.origin.x = 100
//        label.labelRect.origin.y = 50
//        label.title = "Hello World!!"
//
//        view.addSubview(label)
//        label.shuffleFadeAppear()
//
//        // Do any additional setup after loading the view.
//    }
//
//}
//
////配列シャッフル用拡張メソッド
//extension Array {
//
//    mutating func shuffle() {
//        for i in 0..<self.count {
//            let j = Int(arc4random_uniform(UInt32(self.indices.last!)))
//            if i != j {
//                self.swapAt(i, j)
//            }
//        }
//    }
//
//    var shuffled: Array {
//        var temp = Array<Element>(self)
//        temp.shuffle()
//        return temp
//    }
//}
