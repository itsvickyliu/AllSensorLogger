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
    var participantID = "p1"
    var sessionID = "s1"

    override func awake(withContext context: Any?) {
        // Configure interface objects here.
        audioManager.setupView()
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
            if let participantID = applicationContext["participantID"] as? String {
                print("\(participantID)")
            }

            if let sessionID = applicationContext["sessionID"] as? String {
                print("\(sessionID)")
            }
        }
    
    @IBAction func startMotionButtonPressed() {
        motionManager.startUpdates()
        audioManager.startRecording()
        
    }
    
    @IBAction func endMotionButtonPressed() {
        motionManager.endUpdates(participantID: participantID, sessionID: sessionID)
        audioManager.endRecording()
        
    }
    @IBAction func startAudioButtonPressed() {
//        audioManager.startRecording()
    }
    
    @IBAction func endAudioButtonPressed() {
//        audioManager.endRecording()
    }
    
    @IBAction func shareButtonPressed() {
        if (WCSession.default.isReachable) {
            WCSession.default.transferFile(FileManager.default.getDocumentsDirectory().appendingPathComponent("testFile1.wav"), metadata: nil)
            WCSession.default.transferFile(FileManager.default.getDocumentsDirectory().appendingPathComponent("p1-s1.txt"), metadata: nil)
            print ("Sucessfully shared")
        }
        
    }
    
        
}

