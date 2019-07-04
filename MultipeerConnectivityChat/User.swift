import Foundation

struct User: Codable {
    var answeredDate: Date
    var score: Int
    var selectedAnswer: Int
    let deviceName: String
}
