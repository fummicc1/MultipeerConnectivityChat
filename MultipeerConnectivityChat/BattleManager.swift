import Foundation
import UIKit

class BattleManager {
    private init() {
        me = User(displayName: UIDevice.current.name)
        service = MultipeerQuizService()
    }
    static let shared: BattleManager = BattleManager()
    private var service: MultipeerQuizService
    var opponent: User? {
        didSet {
            if opponent?.peer == nil {
                print("opponent peer is nil.")
            }
        }
    }
    var me: User
    weak var connectionDelegate: MCSessionAPI?
    weak var quizDelegate: QuizSessionAPI?
}

extension BattleManager {
    public func sendQuiz(quizList: [QuizData]) {
        service.send(data: quizList)
    }
    
    public func sendIfIAmHost(_ isHost: IsHost) {
        service.send(data: isHost)
    }
    
    public func requestStartQuizToHost() {
        service.send(data: Data())
    }
    
    public func stopObseving() {
        service.stopObseving()
    }
    
    public func startObserving(isHost: Bool) {
        service.startObserving(isHost: isHost)
    }
    
    public func sendMyData() {
        service.send(data: me)
    }
    
    public func resetGame() {
        opponent = nil
        me.clearScore()
        me.clearState()
        connectionDelegate = nil
        quizDelegate = nil
    }
    
}
