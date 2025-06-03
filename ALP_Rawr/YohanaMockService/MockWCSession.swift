//
//  MockWCSession.swift
//  ALP_Rawr
//
//  Created by Dapur Gili on 01/06/25.
//

import Foundation
import WatchConnectivity

//class MockWCSession: WCSession {
//    var delegateAssigned: WCSessionDelegate?
//    var isActivated = false
//    var didSendMessage = false
//    var sentMessage: [String: Any]?
//
//    override var isPaired: Bool { true }
//    override var isWatchAppInstalled: Bool { true }
//    override var isReachable: Bool { true }
//
//    override var delegate: WCSessionDelegate? {
//        get { delegateAssigned }
//        set { delegateAssigned = newValue }
//    }
//
//    override func activate() {
//        isActivated = true
//        delegateAssigned?.session?(self, activationDidCompleteWith: .activated, error: nil)
//    }
//
//    override func sendMessage(_ message: [String : Any],
//                              replyHandler: (([String : Any]) -> Void)? = nil,
//                              errorHandler: ((Error) -> Void)? = nil) {
//        didSendMessage = true
//        sentMessage = message
//        replyHandler?(["status": "ok"])
//    }
//
//    func simulateIncomingMessage(_ message: [String: Any]) {
//        delegateAssigned?.session?(self, didReceiveMessage: message)
//    }
//}
