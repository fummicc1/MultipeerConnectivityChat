import Foundation

struct User: Codable {
    var score: Int
    var havefinishedAllQuestions: Bool
    let deviceName: String
    var haveChosenCorrectAnswer: Bool?
    var answeredDate: Date?
    var isHost: Bool?
    
    init(deviceName: String) {
        score = 0
        havefinishedAllQuestions = false
        self.deviceName = deviceName
    }
}
