//
//  AudioManager.swift
//  SensorLogger WatchKit Extension
//
//  Created by Vicky Liu on 2/28/22.
//

import WatchKit
import AVFoundation
import CloudKit

class AudioManager:  WKInterfaceController, AVAudioRecorderDelegate{
    var recordingSession: AVAudioSession!
    var recorder: AVAudioRecorder!
    let saveURL = FileManager.default.getDocumentsDirectory().appendingPathComponent("testFile1.wav")
    var audioPlayer: AVAudioPlayer!
    
    func startRecording() {
        let settings = [
          AVFormatIDKey: Int(kAudioFormatLinearPCM),
          AVSampleRateKey: 32000,
          AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            recorder = try AVAudioRecorder(url: saveURL, settings: settings)
            recorder.delegate = self
            recorder.record()
            print ("Start recording")
        } catch {
            print ("Recording failed")
        }
    }
    
    func endRecording() {
        recorder.stop()
        print ("End recording")
        print (saveURL)
        recorder = nil
        try? audioPlayer = AVAudioPlayer(contentsOf: saveURL)
        audioPlayer?.play()
        print("Success play audio")
    }
    
    func upload() {
        
    }
    
    func setupView() {
            recordingSession = AVAudioSession.sharedInstance()

            do {
                try recordingSession.setCategory(.playAndRecord, mode: .default)
                try recordingSession.setActive(true)
                recordingSession.requestRecordPermission() { [unowned self] allowed in
                    DispatchQueue.main.async {
                        if allowed {
                            self.loadRecordingUI()
                        } else {
                            print("Failed to record")
                        }
                    }
                }
            } catch {
                print("Failed to record")
            }
        }
    
    func loadRecordingUI(){
    }

}

