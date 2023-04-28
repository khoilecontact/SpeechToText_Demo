//
//  ViewController.swift
//  SpeechToText_Demo
//
//  Created by KhoiLe on 15/04/2023.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var speechLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SpeechManager.shared.requestMicrophone(completion: { [weak self] isGranted in
            guard let self = self else { return }
            if !isGranted {
                self.showAlert(message: "Cannot access Microphone")
            }
        })
        
        SpeechManager.shared.requestAuthorization(completion: { [weak self] isAuthorized in
            guard let self = self else { return }
            if !isAuthorized {
                self.showAlert(message: "Cannot access Speech To Text")
            }
        })
    }

    private func configView() {
        speechLabel.numberOfLines = 0
        speechLabel.font = .systemFont(ofSize: 15)
        speechLabel.text = ""
        
        recordButton.setTitle("", for: .normal)
        recordButton.setImage(UIImage(systemName: "mic"), for: .normal)
        recordButton.setImage(UIImage(systemName: "mic.filled"), for: [.highlighted, .selected])
        recordButton.layer.cornerRadius = recordButton.frame.height / 2
        
        // Add long press gesture recognizer to the button
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        recordButton.addGestureRecognizer(longPressGesture)
    }

    // Handle long press gesture
    @objc func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            // Start speech recognition
            speechLabel.text = ""
            do {
                try SpeechManager.shared.startRecording(completion: { [weak self] speech in
                    guard let self = self else { return }
                    self.speechLabel.text = speech
                })
            } catch {
                showAlert(message: "Error in start recording: \(error)")
            }
            recordButton.isSelected = true
        } else if sender.state == .ended {
            // Stop speech recognition
            SpeechManager.shared.stopRecording()
            recordButton.isSelected = false
        }
    }
}
