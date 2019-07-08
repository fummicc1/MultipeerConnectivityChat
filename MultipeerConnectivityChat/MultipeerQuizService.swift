import Foundation
import MultipeerConnectivity

protocol QuizSessionAPI: class {
    func quizListRecieved(service: MultipeerQuizService, data: [QuizData], from peerID: MCPeerID)
    func requestStartQuizIfHost(service: MultipeerQuizService)
    func informBattlerAlreadyCleared(service: MultipeerQuizService)
}

protocol MCSessionAPI: class {
    func connectionEstablished(service: MultipeerQuizService, peerID: MCPeerID)
}

class MultipeerQuizService: NSObject {
    
    static let QuizServiceType = "quiz-service" // this is an identity less than 15 characters long.
    
    private lazy var serviceAdvertiser: MCNearbyServiceAdvertiser = {
        let serviceAdvertiser = MCNearbyServiceAdvertiser(peer: BattleManager.shared.me.peer!, discoveryInfo: nil, serviceType: MultipeerQuizService.QuizServiceType)
        serviceAdvertiser.delegate = self
        return serviceAdvertiser
    }()
    private lazy var  serviceBrowser: MCNearbyServiceBrowser = {
        let serviceBrowser = MCNearbyServiceBrowser(peer: BattleManager.shared.me.peer!, serviceType: MultipeerQuizService.QuizServiceType)
        serviceBrowser.delegate = self
        return serviceBrowser
    }()
    
    lazy var mainSession: MCSession = {
        let session = MCSession(peer: BattleManager.shared.me.peer!, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session
    }()
    
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
        if BattleManager.shared.opponent == nil {
            invitationHandler(true, mainSession)
        } else {
            invitationHandler(false, nil)
        }
    }
}

extension MultipeerQuizService: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        guard BattleManager.shared.opponent == nil else {
            return
        }
        browser.invitePeer(peerID, to: mainSession, withContext: nil, timeout: 5)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        
        guard
            let opponent = BattleManager.shared.opponent,
            let peer = opponent.peer,
            !mainSession.connectedPeers.contains(peer) else {
            return
        }
        BattleManager.shared.opponent = nil
    }
}

extension MultipeerQuizService: MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        if state == .connected {
            BattleManager.shared.opponent = User(peer: peerID)
            BattleManager.shared.connectionDelegate?.connectionEstablished(service: self, peerID: peerID)
        } else if state == .connecting {
        } else if state == .notConnected {
            fatalError("not connected")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let quizList = try? JSONDecoder().decode([QuizData].self, from: data) {
            BattleManager.shared.quizDelegate?.quizListRecieved(service: self, data: quizList, from: peerID)
        } else if let isHost = try? JSONDecoder().decode(IsHost.self, from: data) {
            // isHostは送信者の状態。
            if isHost.rawValue {
                BattleManager.shared.quizDelegate?.informBattlerAlreadyCleared(service: self)
            } else {
                BattleManager.shared.quizDelegate?.requestStartQuizIfHost(service: self)
            }
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
        guard let opponent = BattleManager.shared.opponent, let peer = opponent.peer, let data = try? JSONEncoder().encode(data) else {
            return
        }
        DispatchQueue.global(qos: .default).async {
            do {
                try self.mainSession.send(data, toPeers: [peer], with: .reliable)
            } catch(let error) {
                print(error)
            }
        }
    }
}
