//
//  MusicServiceManager.swift
//  WeTunesProtp
//
//  Created by Stefan Lin on 11/14/16.
//  Copyright © 2016 Jino Wu. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import MediaPlayer
import AudioToolbox
protocol MusicServiceManagerDelegate {
	func connectedDevicesChanged(manager : MusicServiceManager, connectedDevices: [String])
	func dataChanged(manager : MusicServiceManager, data: Data)
	func streamChanged(manager: MusicServiceManager, _ aStream: Stream, handle eventCode: Stream.Event )
	func stateReceived(manager: MusicServiceManager, state: String)
}

class MusicServiceManager: NSObject {
// MARK: - Variables
	private let MusicServiceType = "WeTunes-Music"
    
//    static var num = 0
    public static let sharedInstance:MusicServiceManager = MusicServiceManager()
    // MCPeerId uses displayName as its unique ID !
    // But currently name of devices can be duplicated
    let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    
    
	private let serviceAdvertiser: MCNearbyServiceAdvertiser
	private let serviceBrowser: MCNearbyServiceBrowser
	var delegate: MusicServiceManagerDelegate?
	lazy var session: MCSession = {
		let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .required)
		session.delegate = self
		return session
	}()
	var transferingStatus = [Bool]()
// MARK: - Functions
	override init() {
//        MusicServiceManager.num += 1
//        print("number of manager: \(MusicServiceManager.num)")
		serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: MusicServiceType)
		serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: MusicServiceType)
		super.init()
		serviceAdvertiser.delegate = self
		serviceAdvertiser.startAdvertisingPeer()
		serviceBrowser.delegate = self
		serviceBrowser.startBrowsingForPeers()
	}
	
	deinit {
		self.session.disconnect()
		serviceAdvertiser.stopAdvertisingPeer()
		serviceBrowser.stopBrowsingForPeers()
	}
	func disconnect() {
		self.session.disconnect()
	}
	func sendData(data: Data) {
		print("sendData")
		if session.connectedPeers.count > 0 {
			do {
				try session.send(data, toPeers: self.session.connectedPeers, with: MCSessionSendDataMode.reliable)
			} catch let error {
				print(error.localizedDescription)
			}
		}
	}
	func sendState(state : String) {
		print("sendState\(state)")
		let data = state.data(using: .utf8)!
		if session.connectedPeers.count > 0 {
			do {
				try session.send(data, toPeers: session.connectedPeers, with: .unreliable)
			} catch let error {
				print(error.localizedDescription)
			}
		}
	}
    
	func sendMediaItem(item: MPMediaItem) {
		print("sendData")
		if session.connectedPeers.count > 0 {
			if let exporter = createSongExporter(item: item) {
				exporter.exportAsynchronously(completionHandler: { () -> Void in
					DispatchQueue.main.async(execute: {() -> Void in
						switch exporter.status {
						case .completed:
							do {
								let rawData = try Data(contentsOf: exporter.outputURL!)
								try self.session.send(rawData, toPeers: self.session.connectedPeers, with: .reliable)
								self.removeExportedFile(url: exporter.outputURL!)
							} catch let error {
								print(error.localizedDescription)
							}
						default:
							break
						}
						
					})
				})
			}
		} else {
			print("no connected device")
		}
	}
	
	func convertDataToAVAsset(data: Data) -> (AVAsset,URL)?{
		do {
			let docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
			let fileName = self.createFileName()
			let url = URL(fileURLWithPath: docDir).appendingPathComponent(fileName)
			try data.write(to: url)
			let asset = AVAsset(url: url)
			return (asset,url)
		} catch let error {
			print(error.localizedDescription)
			return nil
		}
	}
	

	
	private func sendingMusicStream(item: MPMediaItem) {
		guard let url = item.assetURL else {
			print("Error: No item.assetURL is nil")
			return
		}
		let asset = AVURLAsset(url: url)
		do {
			let assetReader = try AVAssetReader(asset: asset)
			let assetOutput = AVAssetReaderTrackOutput(track: asset.tracks[0], outputSettings: nil)
			assetReader.add(assetOutput)
			assetReader.startReading()
			
			guard let sampleBuffer:CMSampleBuffer = assetOutput.copyNextSampleBuffer() else {
				print("Error: sampleBuffer:CMSampleBuffer = assetOutput.copyNextSampleBuffer()")
				return
			}
			var audioBufferList = AudioBufferList(mNumberBuffers: 1, mBuffers: AudioBuffer(mNumberChannels: 0, mDataByteSize: 0, mData: nil))
			var blockBufferOut:CMBlockBuffer? = nil
			
			CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(
				sampleBuffer,
				nil,
				&audioBufferList,
				MemoryLayout<AudioBufferList>.size,
				kCFAllocatorDefault,
				kCFAllocatorDefault,
				UInt32(kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment),
				&blockBufferOut
			)
			if session.connectedPeers.count > 0 {
				let stream = try session.startStream(withName: "music", toPeer: session.connectedPeers[0])
				for _ in 0...audioBufferList.mNumberBuffers-1 {
					let audioBuffer = AudioBuffer.init(mNumberChannels: audioBufferList.mBuffers.mNumberChannels, mDataByteSize: audioBufferList.mBuffers.mDataByteSize, mData: audioBufferList.mBuffers.mData)
					guard let i8mData = (audioBuffer.mData?.assumingMemoryBound(to: UInt8.self)) else {
						print("error: i8")
						return
					}
					stream.write(i8mData, maxLength: Int(audioBuffer.mDataByteSize))
				}
			}
		} catch let error {
			print(error.localizedDescription)
		}
	}
	
	
	
	private func createSongExporter(item: MPMediaItem) -> AVAssetExportSession? {
		if let url = item.assetURL {
			let asset = AVURLAsset(url: url)
			let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A)
			exporter?.outputFileType = "com.apple.m4a-audio"
			let docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
			let filename = createFileName()
			exporter?.outputURL = URL(fileURLWithPath: docDir).appendingPathComponent(filename)
			return exporter
		} else {
			return nil
		}
	}
	private func createFileName() -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyyMMddhhmmss"
		let dateString = dateFormatter.string(from: Date())
		return String(format: "%@.m4a", dateString)
	}
	private func removeExportedFile(url: URL) {
		let manager = FileManager()
		do {
			try manager.removeItem(at: url)
		} catch let error {
			print(error)
		}
	}
//	private func streamParser(stream:Stream) {
//		let audioFileStream: UnsafeMutablePointer<AudioFileStreamID?>
//		let inClientData: UnsafeMutableRawPointer? = nil
//		AudioFileStreamOpen(inClientData, { (inClientData: UnsafeMutableRawPointer, inFileStreamId: AudioFileStreamID, inPropertyId: AudioFileStreamPropertyID, ioFlages: UnsafeMutablePointer<AudioFileStreamPropertyFlags>) in
//			
//			
//		}, { (inClientData: UnsafeMutableRawPointer, inNumberOfBytes:UInt32, inNumberOfPackets: UInt32, _:UnsafeRawPointer, inPacketDescriptions: UnsafeMutablePointer<AudioStreamPacketDescription>) in
//			
//		}, kAudioFileM4AType, audioFileStream)
//		
//	}
//	enum AudioFileTypeID {
//		case <#case#>
//	}
//	private func propertyProc(inClientData: UnsafeMutableRawPointer,inFileStreamId: AudioFileStreamID,inPropertyId: AudioFileStreamPropertyID,ioFlags: UnsafeMutablePointer<UInt32>) -> Void {
//	}
//	
//	private func packetProc(inClientData: UnsafeMutableRawPointer,inNumberOfBytes: UInt32,inNumberOfPackets: UInt32, _: UnsafeMutableRawPointer, inPacketDescriptions: UnsafePointer<AudioStreamPacketDescription>) -> Void {
//	}
}
// MARK: - Delegates
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
		print("invitePeer: \(myPeerId)")
//        print(peerID.isEqual(myPeerId))
//        if peerID.displayName != self.myPeerId.displayName {
            browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
//            //invite found device automatically
//            print("Try to connecting others")
//        } else {
//            print("Bad:yourself!!!!!!!!!")
//        }
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
		print("didReceiveData: \(data.count) bytes")
		if data.count < 1000 && data.count > 0{
			if let str = String(data: data, encoding: .utf8) {
				if str == "ready" {
					transferingStatus.append(true)
				}
				self.delegate?.stateReceived(manager: self, state: str)
			}
		}
		if data.count >= 1000 {
			self.transferingStatus.removeAll()
			self.delegate?.dataChanged(manager: self, data: data)
		}
	}
    
	func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
		print("didReceiveStream from \(peerID)")
		if streamName == "music" {
			stream.delegate = self
			stream.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
			stream.open()
		}
	}
	func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
		print("didFinishReceivingResourceWithName")
	}
	func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
		print("didStartReceivingResourceWithName")
	}
}

extension MusicServiceManager: StreamDelegate {
	func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
		self.delegate?.streamChanged(manager: self, aStream, handle: eventCode)
		switch eventCode {
		case Stream.Event.hasBytesAvailable:
			break
		case Stream.Event.endEncountered:
			break
		case Stream.Event.errorOccurred:
			break
		default:
			break
		}
	}
}
