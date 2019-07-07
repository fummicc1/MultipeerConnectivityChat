import Foundation
import MultipeerConnectivity

protocol QuizSessionAPI: class {
    func opponentDataRecieved(service: MultipeerQuizService, data: User)
    func quizListRecieved(service: MultipeerQuizService, data: [QuizData], from peerID: MCPeerID)
    func requestStartQuizIfHost(service: MultipeerQuizService)
}

protocol MCSessionAPI: class {
    func connectionEstablished(service: MultipeerQuizService, peerID: MCPeerID)
}

class MultipeerQuizService: NSObject {
    
    static let QuizServiceType = "quiz-service" // this is an identity less than 15 characters long.
    
    weak var quizDelegate: QuizSessionAPI?
    weak var connectionDelegate: MCSessionAPI?
    let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    var currentBattleID: MCPeerID?
    private let serviceAdvertiser: MCNearbyServiceAdvertiser
    private let serviceBrowser: MCNearbyServiceBrowser
    
    lazy var session: MCSession = {
        let session = MCSession(peer: self.myPeerID, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session
    }()
    
    override init() {
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: MultipeerQuizService.QuizServiceType)
        serviceBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: MultipeerQuizService.QuizServiceType)        
        super.init()
        serviceAdvertiser.delegate = self
        serviceBrowser.delegate = self
    }
    
    deinit {
        stopObseving()
    }
    
    public func startObserving(isHost: Bool) {
        if isHost {
            serviceAdvertiser.startAdvertisingPeer()
        } else {
            serviceBrowser.startBrowsingForPeers()
        }
    }
    
    public func stopObseving() {
        serviceAdvertiser.stopAdvertisingPeer()
        serviceBrowser.stopBrowsingForPeers()
    }
}

extension MultipeerQuizService: MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        if currentBattleID == nil {
            invitationHandler(true, session)
        } else {
            invitationHandler(false, nil)
        }
    }
}

extension MultipeerQuizService: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        if currentBattleID != nil { return }
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 5)        
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        if let currentBattleID = currentBattleID, !session.connectedPeers.contains(currentBattleID) {
            self.currentBattleID = nil
        }
    }
}

extension MultipeerQuizService: MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        if state == .connected {
            currentBattleID = peerID
            connectionDelegate?.connectionEstablished(service: self, peerID: peerID)
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let opponent = try? JSONDecoder().decode(User.self, from: data) {
            quizDelegate?.opponentDataRecieved(service: self, data: opponent)
        } else if let quizList = try? JSONDecoder().decode([QuizData].self, from: data) {
            quizDelegate?.quizListRecieved(service: self, data: quizList, from: peerID)
        } else if let emptyData = try? JSONDecoder().decode(Data.self, from: data), emptyData.count == 0 {
            quizDelegate?.requestStartQuizIfHost(service: self)
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
    }
}

extension MultipeerQuizService {
    func send<T: Codable>(data: T) {
        guard let currentBattleID = currentBattleID, let data = try? JSONEncoder().encode(data) else {
            return
        }
        try! session.send(data, toPeers: [currentBattleID], with: .reliable)
    }
}
