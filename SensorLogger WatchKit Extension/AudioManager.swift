//
//  AudioManager.swift
//  SensorLogger WatchKit Extension
//
//  Created by Vicky Liu on 2/28/22.
//

import WatchKit
import AVFoundation
import WatchConnectivity
//import CloudKit
//
//class AudioManager:  WKInterfaceController, AVAudioRecorderDelegate{
//    var recordingSession: AVAudioSession!
//    var recorder: AVAudioRecorder!
//    var audioURL = FileManager.default.getDocumentsDirectory()
//    var timeURL = FileManager.default.getDocumentsDirectory()
//    var audioPlayer: AVAudioPlayer!
//    var timeText = ""
//
//    func startRecording(participantID pID: String, sessionID sID: String) {
//        audioURL = audioURL.appendingPathComponent("\(pID)-\(sID).wav")
//        timeURL = timeURL.appendingPathComponent("\(pID)-\(sID)-audiotime.txt")
//
//        let settings = [
//          AVFormatIDKey: Int(kAudioFormatLinearPCM),
//          AVSampleRateKey: 32000,
//          AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
//        ]
//
//        do {
//            recorder = try AVAudioRecorder(url: audioURL, settings: settings)
//            recorder.delegate = self
//            recorder.record()
//            timeText += "Start time: \(NSDate().timeIntervalSince1970) \n"
//            print ("Start recording")
//        } catch {
//            print ("Recording failed")
//        }
//    }
//
//    func endRecording() {
//        recorder.stop()
//        timeText += "End time: \(NSDate().timeIntervalSince1970)"
//        print ("End recording")
//        do {
//            try timeText.write(to: timeURL, atomically: true, encoding: .utf8)
//        } catch {
//            print("Error", error)
//            return
//        }
//        recorder = nil
//    }
//
//    func setupView() {
//            recordingSession = AVAudioSession.sharedInstance()
//
//            do {
//                try recordingSession.setCategory(.playAndRecord, mode: .default)
//                try recordingSession.setActive(true)
//                recordingSession.requestRecordPermission() { [unowned self] allowed in
//                    DispatchQueue.main.async {
//                        if allowed {
//                        } else {
//                            print("Failed to record")
//                        }
//                    }
//                }
//            } catch {
//                print("Failed to record")
//            }
//        }
//
//}
//
//class AudioManager {
//    enum RecordingState {
//        case recording, stopped
//    }
//
//    var engine: AVAudioEngine!
//    var mixerNode: AVAudioMixerNode!
//    var state: RecordingState = .stopped
//    var audioURL = FileManager.default.getDocumentsDirectory()
//    var timeURL = FileManager.default.getDocumentsDirectory()
//
//    init() {
//        setupSession()
//        setupEngine()
//    }
//
//    func setupSession() {
//      let session = AVAudioSession.sharedInstance()
//      try? session.setCategory(.record)
//      try? session.setActive(true, options: .notifyOthersOnDeactivation)
//    }
//
//    func setupEngine() {
//        engine = AVAudioEngine()
//        mixerNode = AVAudioMixerNode()
//
//        mixerNode.volume = 0
//        engine.attach(mixerNode)
//
//        makeConnections()
//
//        engine.prepare()
//    }
//
//    func makeConnections() {
//        let inputNode = engine.inputNode
//        let inputFormat = inputNode.outputFormat(forBus: 0)
//        engine.connect(inputNode, to: mixerNode, format: inputFormat)
//        let mainMixerNode = engine.mainMixerNode
//        let mixerFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: inputFormat.sampleRate, channels: 1, interleaved: false)
//        engine.connect(mixerNode, to: mainMixerNode, format: mixerFormat)
//    }
//
//    func startRecording(participantID pID: String, sessionID sID: String) throws {
//        let tapNode: AVAudioNode = mixerNode
//        let format = tapNode.outputFormat(forBus: 0)
//        audioURL = audioURL.appendingPathComponent("\(pID)-\(sID).caf")
//        timeURL = timeURL.appendingPathComponent("\(pID)-\(sID)-audiotime.txt")
//
//        //let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//
//        // AVAudioFile uses the Core Audio Format (CAF) to write to disk.
//        // So we're using the caf file extension.
//        let file = try AVAudioFile(forWriting: audioURL, settings: format.settings)
//
//        tapNode.installTap(onBus: 0, bufferSize: 4096, format: format, block: {
//        (buffer, time) in
//            try? file.write(from: buffer)
//        })
//
//      try engine.start()
//      state = .recording
//    }
//
//    func endRecording() {
//      // Remove existing taps on nodes
//      mixerNode.removeTap(onBus: 0)
//
//      engine.stop()
//      state = .stopped
//    }
//}

class AudioManager {

    let engine = AVAudioEngine()
    var audioURL = FileManager.default.getDocumentsDirectory()

    struct K {
        static let secondsPerChunk: Float64 = 10
    }

    var chunkFile: AVAudioFile! = nil
    var outputFramesPerSecond: Float64 = 0  // aka input sample rate
    var chunkFrames: AVAudioFrameCount = 0
    var chunkFileNumber: Int = 0

    func writeBuffer(_ buffer: AVAudioPCMBuffer, participantID pID: String, sessionID sID: String) {
        let samplesPerSecond = buffer.format.sampleRate

        if chunkFile == nil {
            createNewChunkFile(numChannels: buffer.format.channelCount, samplesPerSecond: samplesPerSecond, participantID: pID, sessionID: sID)
        }

        try! chunkFile.write(from: buffer)
        chunkFrames += buffer.frameLength

        if chunkFrames > AVAudioFrameCount(K.secondsPerChunk * samplesPerSecond) {
            chunkFile = nil // close file
        }
    }

    func createNewChunkFile(numChannels: AVAudioChannelCount, samplesPerSecond: Float64, participantID pID: String, sessionID sID: String) {
//        audioURL = audioURL.appendingPathComponent("\(pID)-\(sID)-\(chunkFileNumber).aac")
//        audioURL = audioURL.appendingPathComponent("\(pID)-\(sID)")
        let audioURL = FileManager.default.getDocumentsDirectory().appendingPathComponent("\(pID)-\(sID)-\(chunkFileNumber).aac")
        print("writing chunk to \(audioURL)")

        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVEncoderBitRateKey: 64000,
            AVNumberOfChannelsKey: numChannels,
            AVSampleRateKey: samplesPerSecond
        ]

        chunkFile = try! AVAudioFile(forWriting: audioURL, settings: settings)
        
        if (WCSession.default.isReachable) {
            WCSession.default.transferFile(audioURL, metadata: nil)
            print ("Audio data transferred")
        } else {
            print ("WCSession is not activated")
        }

        chunkFileNumber += 1
        chunkFrames = 0
    }
    
    func startRecording(participantID pID: String, sessionID sID: String) {
        let input = engine.inputNode

        let bus = 0
        let inputFormat = input.inputFormat(forBus: bus)
        
        input.removeTap(onBus: bus)
        input.installTap(onBus: bus, bufferSize: 512, format: inputFormat) { (buffer, time) -> Void in
            DispatchQueue.main.async {
                self.writeBuffer(buffer, participantID: pID, sessionID: sID)
            }
        }

        try! engine.start()
    }
    
    func endRecording() {
        engine.stop()
        
    }

}
