//
//  ViewController.swift
//  SensorLogger
//
//  Created by Vicky Liu on 2/25/22.
//

import UIKit
import WatchConnectivity

class ViewController: UIViewController, WCSessionDelegate {
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var participantIDField: UITextField!
    @IBOutlet weak var sessionIDField: UITextField!
    
    var participantText = ""
    var sessionText = ""
    var savedText = ""
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        var dataURL = FileManager.default.getDocumentsDirectory()
        if (file.fileURL.absoluteString.contains(".txt")) {
            dataURL = dataURL.appendingPathComponent("\(participantText)-\(sessionText)-audiotime.txt")
        } else if (file.fileURL.absoluteString.contains(".wav")) {
            dataURL = dataURL.appendingPathComponent("\(participantText)-\(sessionText).wav")
        }
        do {
            try FileManager.default.moveItem(at: file.fileURL, to: dataURL)
        }
        catch let error{
            print (error)
        }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        if let motionData = userInfo["motionData"] as? String {
            print ("Received motion data")
            savedText += motionData
            do {
                try savedText.write(to: FileManager.default.getDocumentsDirectory().appendingPathComponent("\(participantText)-\(sessionText)-realtime.txt"), atomically: true, encoding: .utf8)
            } catch {
                print("Error", error)
                return
            }
            do {
                let savedString = try String(contentsOf: FileManager.default.getDocumentsDirectory().appendingPathComponent("\(participantText)-\(sessionText)-realtime.txt"))
                print(savedString)
            } catch {
                print("Error reading saved file")
            }
        }
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
        
        self.hideKeyboardWhenTapped()
        participantIDField.delegate = self
        sessionIDField.delegate = self
    }
    
    @IBAction func startRecordingButtonPressed(_ sender: Any) {
        if (WCSession.default.isReachable) && (participantIDField.text != "") && (sessionIDField.text != "") {
            do {
                participantText = participantIDField.text as String? ?? ""
                sessionText = sessionIDField.text as String? ?? ""
                
                try WCSession.default.updateApplicationContext(["participantID": participantText, "sessionID": sessionText])
                print ("pID and sID transferred")
            }
            catch {
                print(error)
            }
        } else if (participantIDField.text == "") || (sessionIDField.text == "") {
            infoLabel.text = "Participant field or session field is empty"
        } else {
            infoLabel.text = "Watch is not reachable"
        }
    }
//
//    func save(text: String, toDirectory directory: String, withparticipantID pID: String, withsessionID sID: String) {
//        let ID = pID.appending("-\(sID).txt")
//
//        guard let filePath = self.append(toPath: directory, withPathComponent: ID) else {
//            return
//        }
//
//        do {
//            try text.write(toFile: filePath, atomically: true, encoding: .utf8)
//        } catch {
//            print("Error", error)
//            return
//        }
//        print("Save successful")
//    }
//
//    func read(fromDocumentsWithFileName fileName: String) {
//        guard let filePath = self.append(toPath: self.documentDirectory(), withPathComponent: fileName) else {
//            return
//        }
//
//        do {
//            let savedString = try String(contentsOfFile: filePath)
//            print(savedString)
//        } catch {
//            print("Error reading saved file")
//        }
//    }
//
//    func append(toPath path: String, withPathComponent pathComponent: String) -> String? {
//        if var pathURL = URL(string: path) {
//            pathURL.appendPathComponent(pathComponent)
//            return pathURL.absoluteString
//        }
//        return nil
//    }
//
//    func documentDirectory() -> String {
//        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
//        return documentDirectory[0]
//    }
//
}

extension UIViewController {

    @objc func hideKeyboardWhenTapped() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

