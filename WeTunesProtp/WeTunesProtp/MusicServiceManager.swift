//
//  MusicServiceManager.swift
//  WeTunesProtp
//
//  Created by Stefan Lin on 11/14/16.
//  Copyright © 2016 Jino Wu. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol MusicServiceManagerDelegate {
	func connectedDevicesChanged(manager : MusicServiceManager, connectedDevices: [String])
	func dataChanged(manager : MusicServiceManager, data: Data)
}



class MusicServiceManager: NSObject {
	private let MusicServiceType = "WeTunes-Music"
	private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
	private let serviceAdvertiser: MCNearbyServiceAdvertiser
	private let serviceBrowser: MCNearbyServiceBrowser
	var delegate: MusicServiceManagerDelegate?
	lazy var session: MCSession = {
		let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .required)
		session.delegate = self
		return session
	}()
	
	override init() {
		serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: MusicServiceType)
		serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: MusicServiceType)
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
	
	func sendMusic(data: Data) {
		print("sendData")
		if session.connectedPeers.count > 0 {
			do {
				try session.send(data, toPeers: self.session.connectedPeers, with: MCSessionSendDataMode.reliable)
			} catch let error {
				print(error.localizedDescription)
			}
		}
	}
}

extension MusicServiceManager: MCNearbyServiceAdvertiserDelegate {
	func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
		print("didNotStartAdvertisingPeer: \(error)")
	}
	func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
		print("didReceiveInvitationFromPeer \(peerID)")
		invitationHandler(true, self.session)//accept invitation
	}
}
extension MusicServiceManager: MCNearbyServiceBrowserDelegate {
	func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
		print("didNotStartBrowsingForPeers: \(error)")
	}
	func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
		print("foundPeer: \(peerID)")
		print("invitePeer: \(peerID)")
		browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)//invite found device automatically
	}
	func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
		print("lostPeer: \(peerID)")
	}
}
extension MCSessionState {
	func stringValue() -> String {
		switch(self) {
		case .notConnected: return "NotConnected"
		case .connecting: return "Connecting"
		case .connected: return "Connected"
		}
	}
}
extension MusicServiceManager: MCSessionDelegate {
	func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
		print("peer \(peerID) didChangeState: \(state.stringValue())")
		self.delegate?.connectedDevicesChanged(manager: self, connectedDevices: session.connectedPeers.map({$0.displayName}))
	}
	func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
		//receive data here
		print("didReceiveData: \(data.count) bytes")
//		let str = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
		self.delegate?.dataChanged(manager: self, data: data)
	}
	func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
		print("didReceiveStream")
	}
	func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
		print("didFinishReceivingResourceWithName")
	}
	func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
		print("didStartReceivingResourceWithName")
	}
}
