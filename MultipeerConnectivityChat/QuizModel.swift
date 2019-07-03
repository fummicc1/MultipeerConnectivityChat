import Foundation

class QuizModel {
    
    private let quizData: SharedData
    private(set) var battlerData: SharedData?
    private let service: MultipeerQuizService
    
    private weak var delegate: QuizSessionAPI?
    
    init(quizData: SharedData, delegate: QuizSessionAPI, battlerData: SharedData?, service: MultipeerQuizService) {
        self.quizData = quizData
        self.delegate = delegate
        self.battlerData = battlerData
        self.service = service
    }
    
    public func shareData() {
    }
}
