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

class MotionManager {
    
    let motionManager = CMMotionManager()
    let queue = OperationQueue()
    let sampleInterval = 1.0/50
    var dataText = ""
    var saveURL = FileManager.default.getDocumentsDirectory()
    
    init() {
        queue.maxConcurrentOperationCount = 1
        queue.name = "MotionManagerQueue"
    }
    
    func documentDirectory() -> String {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        
        return documentDirectory[0]
    }
    
    func append(toPath path: String, withPathComponent pathComponent: String) -> String? {
        if var pathURL = URL(string: path) {
            pathURL.appendPathComponent(pathComponent)
            return pathURL.absoluteString
        }
        return nil
    }
    
    func read(fromDocumentsWithFileName fileName: String) {
        guard let filePath = self.append(toPath: self.documentDirectory(), withPathComponent: fileName) else {
            return
        }

        do {
            let savedString = try String(contentsOfFile: filePath)

            print(savedString)
        } catch {
            print("Error reading saved file")
        }
    }
    
    func save(text: String, toDirectory directory: String, withparticipantID pID: String, withsessionID sID: String) {
        let ID = pID.appending("-\(sID).txt")
        
        guard let filePath = self.append(toPath: directory, withPathComponent: ID) else {
            return
        }
        
        do {
            try text.write(toFile: filePath, atomically: true, encoding: .utf8)
        } catch {
            print("Error", error)
            return
        }
        
        print("Save successful")
    }
    
    func startUpdates() {
        
        if !(motionManager.isDeviceMotionAvailable) {
            print ("Device motion is unavailable")
            return
        }
        
        if !(motionManager.isAccelerometerAvailable) {
            print ("Accelerometer is unavailable")
        }
        
        if !(motionManager.isGyroAvailable) {
            print ("Gyroscope is unavailable")
        }
        
        if !(motionManager.isMagnetometerAvailable) {
            print ("Magnetometer is unavailable")
        }
        
        print("Start updates")
        
        motionManager.deviceMotionUpdateInterval = sampleInterval
        motionManager.startDeviceMotionUpdates(to: queue) { (data, error) in
//        motionManager.startDeviceMotionUpdates(using: .xTrueNorthZVertical, to: queue) { (data, error) in
            
            guard error == nil else {
                print("Error")
                return
                }
            
            if let data = data {
                
                self.dataText += "\(NSDate().timeIntervalSince1970) \(data.userAcceleration.x + data.gravity.x) \(data.userAcceleration.y + data.gravity.y) \(data.userAcceleration.z + data.gravity.z) \(data.rotationRate.x) \(data.rotationRate.y) \(data.rotationRate.z) \(data.magneticField.field.x) \(data.magneticField.field.y) \(data.magneticField.field.z) \(data.attitude.roll) \(data.attitude.pitch)  \(data.attitude.yaw) \(data.attitude.quaternion.x) \(data.attitude.quaternion.y) \(data.attitude.quaternion.z) \(data.attitude.quaternion.w) \n"
                    
            }
        }
    }
    
    func endUpdates(participantID pID: String, sessionID sID: String) {
        if motionManager.isDeviceMotionAvailable {
            motionManager.stopDeviceMotionUpdates()
            print ("End updates")
//            saveURL = saveURL.appendingPathComponent(pID).appendingPathComponent(sID.appending(".txt"))
            saveURL = saveURL.appendingPathComponent("s1.txt")
            print (saveURL)
//            do {
//                try dataText.write(toFile: saveURL.absoluteString, atomically: true, encoding: .utf8)
//            } catch {
//                print ("Error")
//            }

            self.save(text: dataText,
                      toDirectory: self.documentDirectory(), withparticipantID: "p1", withsessionID: "s1")
            
            self.read(fromDocumentsWithFileName: "p1-s1.txt")
            
        }
    }
}
