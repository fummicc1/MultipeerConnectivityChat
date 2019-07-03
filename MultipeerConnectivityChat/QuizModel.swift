import Foundation

class QuizModel {
    
    private var quizData: SharedData?
    private(set) var battlerData: SharedData?
    private let service: MultipeerQuizService    
    private weak var delegate: QuizSessionAPI?
    
    init(delegate: QuizSessionAPI, service: MultipeerQuizService) {
        self.delegate = delegate
        self.service = service
    }
    
    public func shareData() {
    }
}
