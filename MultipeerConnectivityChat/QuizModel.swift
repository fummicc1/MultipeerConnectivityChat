import Foundation

class QuizModel {
    
    var user: User
    var opponent: User?
    let service: MultipeerQuizService
    
    init(
        quizDelegate: QuizSessionAPI,
        service: MultipeerQuizService,
        connectionDelegate: MCSessionAPI
        ) {
        self.service = service
        service.quizDelegate = quizDelegate
        service.connectionDelegate = connectionDelegate
        self.user = User(deviceName: service.myPeerID.displayName)
    }
    
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
}
