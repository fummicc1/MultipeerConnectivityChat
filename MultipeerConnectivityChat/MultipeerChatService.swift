import Foundation
import MultipeerConnectivity

protocol ChatControlAPI {
    func connectedDeviceChanged(service: MultipeerChatService, devices: [String])    
    func textRecieved(service: MultipeerChatService, text: String)
}

class MultipeerChatService: NSObject {
    
    static let ChatServiceType = "chat-service" // this is an identity less than 15 characters long.
    
    var delegate: ChatControlAPI?
    private let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    private let serviceAdvertiser: MCNearbyServiceAdvertiser
    private let serviceBrowser: MCNearbyServiceBrowser
    
    lazy var session: MCSession = {
        let session = MCSession(peer: self.myPeerID, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session
    }()
    
    override init() {
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: MultipeerChatService.ChatServiceType)
        serviceBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: MultipeerChatService.ChatServiceType)
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

extension MultipeerChatService: MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
}

extension MultipeerChatService: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 5)
    }
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {}
}

extension MultipeerChatService: MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        delegate?.connectedDeviceChanged(service: self, devices: session.connectedPeers.map{$0.displayName})
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let text = String(data: data, encoding: .utf8) else {
            return
        }
        delegate?.textRecieved(service: self, text: text)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
    }
}

extension MultipeerChatService {
    func send(text: String) {
        if session.connectedPeers.count == 0 { return }
        try! session.send(text.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
    }
}
