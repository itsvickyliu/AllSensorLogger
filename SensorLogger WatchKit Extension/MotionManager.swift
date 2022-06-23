//
//  MotionManager.swift
//  SensorLogger WatchKit Extension
//
//  Created by Vicky Liu on 2/25/22.
//

import Foundation
import CoreMotion
import UIKit
import WatchKit
import WatchConnectivity

class MotionManager {
    
    let motionManager = CMMotionManager()
    let queue = OperationQueue()
    let sampleInterval = 1.0/50
    var saveURL = FileManager.default.getDocumentsDirectory()
    var tempText = ""
    
    init() {
        queue.maxConcurrentOperationCount = 1
        queue.name = "MotionManagerQueue"
    }
  
    func startRecording(participantID pID: String, sessionID sID: String) {
        
        saveURL = saveURL.appendingPathComponent("\(pID)-\(sID).txt")
        
        if !(motionManager.isDeviceMotionAvailable) {
            print ("Device motion is unavailable")
            return
        }

        print("Start motion updates")
        
        motionManager.deviceMotionUpdateInterval = sampleInterval
        motionManager.startDeviceMotionUpdates(to: queue) { (data, error) in
            
            guard error == nil else {
                print("Error")
                return
                }
            
            if let data = data {
                
                self.tempText = "\(NSDate().timeIntervalSince1970) \(data.userAcceleration.x + data.gravity.x) \(data.userAcceleration.y + data.gravity.y) \(data.userAcceleration.z + data.gravity.z) \(data.rotationRate.x) \(data.rotationRate.y) \(data.rotationRate.z) \(data.magneticField.field.x) \(data.magneticField.field.y) \(data.magneticField.field.z) \(data.attitude.roll) \(data.attitude.pitch)  \(data.attitude.yaw) \(data.attitude.quaternion.x) \(data.attitude.quaternion.y) \(data.attitude.quaternion.z) \(data.attitude.quaternion.w) \n"
                
                if (WCSession.default.isReachable) {
                    WCSession.default.sendMessage(["motionData": self.tempText], replyHandler: nil)
                } else {
                    print ("WCSession is not activated")
                }
            }
        }
    }
    
    func endRecording() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.stopDeviceMotionUpdates()
            print ("End motion updates")
        }
    }
}
