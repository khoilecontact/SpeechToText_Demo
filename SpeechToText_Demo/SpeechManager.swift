//
//  SpeechManager.swift
//  SpeechToText_Demo
//
//  Created by KhoiLe on 15/04/2023.
//

import Foundation
import UIKit
import Speech

class SpeechManager {
    
    // MARK: - Properties
    
    public static let shared = SpeechManager()
    
//     print(SFSpeechRecognizer.supportedLocales())
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    // MARK: - Public Methods
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                completion(authStatus == .authorized)
            }
        }
    }
    
    func requestMicrophone(completion: @escaping (Bool) -> Void) {
        var permission = false
        let semaphore = DispatchSemaphore(value: 1)
        
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            permission = granted
            semaphore.signal()
        }
        
        semaphore.wait()
        
        completion(permission)
    }
    
    func startRecording(completion: @escaping (String) -> Void) throws {
        // Check if the SFSpeechRecognizer is available
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            throw SpeechRecognitionError.unavailable
        }
        
        // Check whether another task is performed
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        // Create a request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw SpeechRecognitionError.unavailable
        }
        
        // Create a recognition task
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            // Check the result
            if let result = result {
                // Extract the transcription
                let transcript = result.bestTranscription.formattedString
                completion(transcript)
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.stopRecording()
            }
        }
        
        // Creates a new instance of AVAudioSession, which manages the audio for the app.
        let audioSession = AVAudioSession.sharedInstance()
        // Sets the category of the audio session to .record and the mode to .measurement, indicating that we want to record audio and measure its levels. The options parameter specifies that other audio should be ducked (i.e., lowered in volume) while recording.
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        // Activates the audio session, which allows the app to record audio
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        // Creates an AVAudioInputNode that represents the app's audio input.
        let inputNode = audioEngine.inputNode
        // Gets the output format of the input node
        // A bus is a specific input or output connection on an audio unit or engine
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        // Installs a tap on the input node that records audio data
        // The bufferSize parameter specifies the size of the audio buffer, and the format parameter specifies the format of the audio data
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
    }
}

enum SpeechRecognitionError: Error {
    case unavailable
}
