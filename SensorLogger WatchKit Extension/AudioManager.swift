//
//  AudioManager.swift
//  SensorLogger WatchKit Extension
//
//  Created by Vicky Liu on 2/28/22.
//

import WatchKit
import AVFoundation
import WatchConnectivity

class AudioManager {
    
    // AVAudioEngine used to record
    var engine = AVAudioEngine()

    // Set this as per your liking (512, 1024, 2048)
    let estimatedBufferSize: AVAudioFrameCount = 1024

    // Will be configured to write the buffer to a file
    var file: AVAudioFile?

    // Chunk duration in seconds, adjust as needed
    let chunkDuration: Float64 = 3

    // Will be used to uniquely name the different chunks
    var currentChunkCount = 0

    // Keeps track of how many frames in current chunk
    // Used to check how much time has elapsed
    var framesInCurrentChunk: AVAudioFrameCount = 0
    
    var audioURL = FileManager.default.getDocumentsDirectory()
    
    func startRecording(participantID pID: String, sessionID sID: String) {
        
        print("Start audio updates")
            
        // Prepare how the AVAudioEngine should process input
        engine.inputNode.installTap(onBus: 0,
                                    bufferSize: 1024,
                                    format: engine.inputNode.inputFormat(forBus: 0))
        { [weak self] (buffer, time) -> Void in
                
            // Write the buffer to your file
            self?.writeBufferToFile(buffer: buffer, participantID: pID, sessionID: sID)
        }
            
        // Start recording
        try! engine.start()
    }
    
    func endRecording(participantID pID: String, sessionID sID: String) {
        
        print("End audio updates")
            
        // Clean up and reset
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
        file = nil
        framesInCurrentChunk = 0
            
        // Here is where you should upload any files that have not been uploaded
        // Delete files after upload if you want or manage file name duplicates
        if (WCSession.default.isReachable) {
            audioURL = FileManager.default.getDocumentsDirectory().appendingPathComponent("\(pID)-\(sID)-\(currentChunkCount).aac")
            WCSession.default.transferFile(audioURL, metadata: nil)
        } else {
            print ("WCSession is not activated")
        }
    
    }
    
    private func writeBufferToFile(buffer: AVAudioPCMBuffer, participantID pID: String, sessionID sID: String)
    {
        let samplesPerSecond = buffer.format.sampleRate
        
        // Check if we have an open file writer
        if file == nil
        {
            // Configure an AVAudioFile to write the audio buffer to file
            prepareOutputFile(participantID: pID, sessionID: sID)
        }
        
        do
        {
            try file?.write(from: buffer)
            framesInCurrentChunk += buffer.frameLength
        }
        catch
        {
            // error appending the chunk to file
            print(error)
        }
        
        
        // Check if the current chunk has reached it's duration
        if framesInCurrentChunk > AVAudioFrameCount(chunkDuration * samplesPerSecond)
        {
            // Here is where you have a valid chunk that has been saved in
            // the duration you want, put the last saved aac file in a queue to be
            // uploaded to your server here
            
            // De-initialize the current file writer so we can start a new one
            file = nil
        }
    }

    private func prepareOutputFile(participantID pID: String, sessionID sID: String)
    {
        // Increment the current chunk count to create a new file
        currentChunkCount += 1
        
        if (WCSession.default.isReachable && currentChunkCount > 1) {
            audioURL = FileManager.default.getDocumentsDirectory().appendingPathComponent("\(pID)-\(sID)-\(currentChunkCount-1).aac")
            WCSession.default.transferFile(audioURL, metadata: nil)
        } else {
            print ("WCSession is not activated")
        }
        
        audioURL = FileManager.default.getDocumentsDirectory().appendingPathComponent("\(pID)-\(sID)-\(currentChunkCount).aac")
        
        print("Recording audio to path: \(audioURL)")
        
        do
        {
            // Configure the AVAudioFile with the output path and output format
            file = try AVAudioFile(forWriting: audioURL,
                                   settings: [AVFormatIDKey: kAudioFormatMPEG4AAC])
            
        }
        catch
        {
            // Handle errors in configuring the the AVAudioFile
            print(error)
        }
        
        // Reset the frames saved in the current chunk
        framesInCurrentChunk = 0
    }
}
