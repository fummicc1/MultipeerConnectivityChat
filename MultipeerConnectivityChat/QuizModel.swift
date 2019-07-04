import Foundation

class QuizModel {
    
    var user: User?
    var opponent: User?
    private let service: MultipeerQuizService    
    private weak var quizDelegate: QuizSessionAPI?
    
    init(quizDelegate: QuizSessionAPI, service: MultipeerQuizService, connectionDelegate: MCSessionAPI) {
        self.quizDelegate = quizDelegate
        self.service = service
        service.connectionDelegate = connectionDelegate
    }
    
    public func shareData() {
        guard let user = user else { return }
        service.send(user: user)
    }
    
    public func stopObseving() {
        service.stopObseving()
    }
}
