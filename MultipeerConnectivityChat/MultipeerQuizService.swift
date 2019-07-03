import Foundation
import MultipeerConnectivity

protocol QuizSessionAPI: class {
    func connectedDeviceChanged(service: MultipeerQuizService, devices: [String])    
    func quizRecieved(service: MultipeerQuizService, data: SharedData)
}

class MultipeerQuizService: NSObject {
    
    static let QuizServiceType = "quiz-service" // this is an identity less than 15 characters long.
    
    var delegate: QuizSessionAPI?
    private let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    private var currentBattleID: MCPeerID?
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
        serviceAdvertiser.startAdvertisingPeer()
        serviceBrowser.delegate = self
        serviceBrowser.startBrowsingForPeers()
    }
    
    deinit {
        serviceAdvertiser.stopAdvertisingPeer()
        serviceBrowser.stopBrowsingForPeers()
    }
}

extension MultipeerQuizService: MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        if currentBattleID == nil {
            invitationHandler(true, session)
        }
    }
}

extension MultipeerQuizService: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        if currentBattleID != nil { return }
        currentBattleID = peerID
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
        delegate?.connectedDeviceChanged(service: self, devices: session.connectedPeers.map{$0.displayName})
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let data = try? JSONDecoder().decode(SharedData.self, from: data) else { return }
        delegate?.quizRecieved(service: self, data: data)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
    }
}

extension MultipeerQuizService {
    func send(text: String) {
        if session.connectedPeers.count == 0 { return }
        try! session.send(text.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
    }
}
