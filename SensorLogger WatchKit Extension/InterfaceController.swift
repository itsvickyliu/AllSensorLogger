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


class InterfaceController: WKInterfaceController {
    
    let motionManager = MotionManager()
    let audioManager = AudioManager()
    var url = FileManager.default.getDocumentsDirectory()
    var participantID = ""
    var sessionID = ""
    @IBOutlet weak var pIDLabel: WKInterfaceLabel!
    @IBOutlet weak var sIDLabel: WKInterfaceLabel!
    @IBOutlet weak var recordingLabel: WKInterfaceLabel!
    @IBOutlet weak var startButton: WKInterfaceButton!
    @IBOutlet weak var stopButton: WKInterfaceButton!
    
    override func awake(withContext context: Any?) {
        // Configure interface objects here.
        recordingLabel.setText("Pair from Phone")
        startButton.setEnabled(false)
        stopButton.setEnabled(false)
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
    
    private func start() {
        audioManager.startRecording(participantID: participantID, sessionID: sessionID)
        motionManager.startRecording(participantID: participantID, sessionID: sessionID)
        recordingLabel.setText("Recording")
        startButton.setEnabled(false)
        stopButton.setEnabled(true)
    }
    
    private func stop() {
        audioManager.endRecording(participantID: participantID, sessionID: sessionID)
        motionManager.endRecording()
        recordingLabel.setText("Not Recording")
        startButton.setEnabled(false)
        stopButton.setEnabled(false)
    }
    
    @IBAction func startButtonPressed() {

        do {
            try WCSession.default.sendMessage(["command": "start"], replyHandler: nil)
            start()
        }
        catch {
            print(error)
        }

        
    }
    
    @IBAction func stopButtonPressed() {
        
        do {
            try WCSession.default.sendMessage(["command": "stop"], replyHandler: nil)
            stop()
        }
        catch {
            print(error)
        }
    }
}

extension InterfaceController: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        
        if let command = applicationContext["command"] as? String {
            
            if command == "start" {
                start()
            } else if command == "stop" {
                stop()
            }
        } else {
            if let pID = applicationContext["participantID"] as? String {
                participantID = pID
                pIDLabel.setText(participantID)
            }

            if let sID = applicationContext["sessionID"] as? String {
                sessionID = sID
                sIDLabel.setText(sessionID)
            }
            
            if participantID != "" && sessionID != "" {
                startButton.setEnabled(true)
                stopButton.setEnabled(false)
            }
        }
    }
}
