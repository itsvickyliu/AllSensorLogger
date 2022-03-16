//
//  ViewController.swift
//  SensorLogger
//
//  Created by Vicky Liu on 2/25/22.
//

import UIKit
import WatchConnectivity

class ViewController: UIViewController, WCSessionDelegate {
    
    @IBOutlet weak var participantIDField: UITextField!
    @IBOutlet weak var sessionIDField: UITextField!
    
    var participantText = ""
    var sessionText = ""
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        var motionURL = FileManager.default.getDocumentsDirectory()
        if (file.fileURL.absoluteString.contains(".txt")) {
            motionURL = FileManager.default.getDocumentsDirectory().appendingPathComponent("\(participantText)-\(sessionText).txt")
//            motionURL = FileManager.default.getDocumentsDirectory().appendingPathComponent("test.txt")
        } else if (file.fileURL.absoluteString.contains(".wav")) {
            motionURL = FileManager.default.getDocumentsDirectory().appendingPathComponent("\(participantText)-\(sessionText).wav")
//            motionURL = FileManager.default.getDocumentsDirectory().appendingPathComponent("test.wav")
        }
        print (motionURL.absoluteString)
        do {
            try FileManager.default.moveItem(at: file.fileURL, to: motionURL)
//            try FileManager.default.moveItem(atPath: file.fileURL.absoluteString, toPath: motionURL.absoluteString)
        }
        catch let error{
            // Handle any errors here
            print (error)
        }
        
//        self.read(fromDocumentsWithFileName: "p1-s1.txt")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if (WCSession.isSupported()) {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    @IBAction func startRecordingButtonPressed(_ sender: Any) {
        if (WCSession.default.isReachable) {
            do {
                participantText = participantIDField.text as String? ?? ""
                sessionText = sessionIDField.text as String? ?? ""
                
                try WCSession.default.updateApplicationContext(["participantID": participantText, "sessionID": sessionText])
                
                print ("pID and sID transferred")
            }
            catch {
                print(error)
            }
        } else {
            print ("watch is not reachable")
        }
    }
    
    @IBAction func endRecordingButtonPressed(_ sender: Any) {
    }
    
    @IBAction func shareFileButtonPressed(_ sender: Any) {
//        self.read(fromDocumentsWithFileName: "p1-s1.txt")
        
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
    
    func append(toPath path: String, withPathComponent pathComponent: String) -> String? {
        if var pathURL = URL(string: path) {
            pathURL.appendPathComponent(pathComponent)
            return pathURL.absoluteString
        }
        return nil
    }
    
    func documentDirectory() -> String {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        
        return documentDirectory[0]
    }
    
}

