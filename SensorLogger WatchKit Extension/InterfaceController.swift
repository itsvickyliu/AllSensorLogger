//
//  InterfaceController.swift
//  SensorLogger WatchKit Extension
//
//  Created by Vicky Liu on 2/25/22.
//

import WatchKit
import Foundation
import WatchConnectivity
import UIKit
import AVFoundation


class InterfaceController: WKInterfaceController, WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    let motionManager = MotionManager()
    let audioManager = AudioManager()
    var url = FileManager.default.getDocumentsDirectory()
    var participantID = ""
    var sessionID = ""
    @IBOutlet weak var pIDLabel: WKInterfaceLabel!
    @IBOutlet weak var sIDLabel: WKInterfaceLabel!
    @IBOutlet weak var recordingLabel: WKInterfaceLabel!
    @IBOutlet weak var motionEndButton: WKInterfaceButton!
    @IBOutlet weak var shareButton: WKInterfaceButton!
    
    override func awake(withContext context: Any?) {
        // Configure interface objects here.
        audioManager.setupView()
        motionEndButton.setEnabled(false)
        shareButton.setEnabled(false)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        if let pID = applicationContext["participantID"] as? String {
            participantID = pID
        }

        if let sID = applicationContext["sessionID"] as? String {
            sessionID = sID
        }
        
        motionManager.startRecording(participantID: participantID, sessionID: sessionID)
        audioManager.startRecording(participantID: participantID, sessionID: sessionID)
        recordingLabel.setText("Recording")
        motionEndButton.setEnabled(true)
        pIDLabel.setText(participantID)
        sIDLabel.setText(sessionID)
    }
    
    @IBAction func endMotionButtonPressed() {
        motionManager.endRecording(participantID: participantID, sessionID: sessionID)
        audioManager.endRecording()
        recordingLabel.setText("Not Recording")
        shareButton.setEnabled(true)
        motionEndButton.setEnabled(false)
    }
    
    @IBAction func shareButtonPressed() {
        if (WCSession.default.isReachable) {
            WCSession.default.transferFile(url.appendingPathComponent("\(participantID)-\(sessionID).wav"), metadata: nil)
            WCSession.default.transferFile(url.appendingPathComponent("\(participantID)-\(sessionID)-audiotime.txt"), metadata: nil)
            print ("Sucessfully shared")
        }
    }
}

