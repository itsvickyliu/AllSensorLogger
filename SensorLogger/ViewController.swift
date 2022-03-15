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
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
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
//        if (WCSession.default.isReachable) {
//            do {
//                try WCSession.default.updateApplicationContext(["participantID": participantIDField, "sessionID": sessionIDField])
//            }
//            catch {
//                print(error)
//            }
//        }
    }
    
    @IBAction func endRecordingButtonPressed(_ sender: Any) {
    }
    
    @IBAction func shareFileButtonPressed(_ sender: Any) {
    }
    
}

