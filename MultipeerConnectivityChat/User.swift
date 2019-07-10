import Foundation
import MultipeerConnectivity

struct User: Codable {
    private(set) var score: Int
    private(set) var havefinishedAllQuestions: Bool
    private(set) var peer: MCPeerID?
    private(set) var displayName: String
    private(set) var isCorrectAnswer: Bool?
    private(set) var answeredDate: Date?
    private(set) var isHost: IsHost?
    
    init(displayName: String) {
        score = 0
        havefinishedAllQuestions = false
        self.displayName = displayName
        peer = MCPeerID(displayName: displayName)
    }
    
    init(peer: MCPeerID) {
        score = 0
        havefinishedAllQuestions = false
        self.peer = peer
        displayName = peer.displayName
    }
    
    public mutating func refreshQuizStatus() {
        isCorrectAnswer = nil
        answeredDate = nil
    }
    
    public mutating func updateMyDeviceName(_ deviceName: String) {
        self.displayName = deviceName
    }
    
    public mutating func updatePeer(_ peerID: MCPeerID) {
        self.peer = peerID
    }
    
    public mutating func setIsHost(_ value: Bool) {
        self.isHost = IsHost(rawValue: value)
    }
    
    public mutating func getScore(_ value: Int) {
        self.score += value
    }
    
    public mutating func updateAnsweredDate(_ value: Date) {
        self.answeredDate = value
    }
    
    public mutating func playerStateChanged(_ value: Bool) {
        self.isCorrectAnswer = value
    }
    
    public mutating func clearScore() {
        score = 0
    }
    
    public mutating func clearState() {
        isHost = nil
    }
    
    enum CodingKeys: String, CodingKey {
        case score
        case havefinishedAllQuestions
        case displayName
        case isCorrectAnswer
        case answeredDate
        case isHost
    }
}

struct IsHost: Codable {
    let rawValue: Bool
}
