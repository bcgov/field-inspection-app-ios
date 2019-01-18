//
//  AudioRecorderViewController.swift
//  EAOInspect
//
//  Created by Amir Shayegh on 2018-02-03.
//  Copyright © 2018 Amir Shayegh. All rights reserved.
//

import UIKit
import AVFoundation

class AudioRecorderViewController: UIViewController {

    // MARK: IB Outlets
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var container2: UIView!
    @IBOutlet weak var fieldNameContainer: UIView!
    @IBOutlet weak var label: UILabel!

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!

    @IBOutlet weak var titleField: UITextField!

    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var playBUtton: UIButton!
    @IBOutlet weak var stopButton: UIButton!

    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!

    // MARK: Constants
    let MAX_FILE_SIZE: Double = 9
    
    // MARK: Variable
    var callBack: ((_ close: Bool) -> Void )?
    var updater: CADisplayLink! = nil
    var meterTimer: Timer!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var isAudioRecordingGranted: Bool!
    var isRecording = false {
        didSet {
            if isRecording {
                self.recordButton.setImage(#imageLiteral(resourceName: "recing"), for: .normal)
            } else {
                self.recordButton.setImage(#imageLiteral(resourceName: "rec"), for: .normal)
            }
        }
    }
    
    var inspectionID = ""
    var observationID = ""
    let tempid = String.random()
    
    var isPlaying = false

    override func viewDidLoad() {
        super.viewDidLoad()
        checkRecordingPermission()
        style()
        disablePlaybackButtons()
        self.progressLabel.text = ""
        self.sizeLabel.text = ""
    }

    func style() {
        playBUtton.setImage(#imageLiteral(resourceName: "playdisabled"), for: .disabled)
        stopButton.setImage(#imageLiteral(resourceName: "stopdisabled"), for: .disabled)
        deleteButton.setImage(#imageLiteral(resourceName: "deletedisabled"), for: .disabled)
        playBUtton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        stopButton.setImage(#imageLiteral(resourceName: "stop"), for: .normal)
        deleteButton.setImage(#imageLiteral(resourceName: "delete"), for: .normal)
        styleContainer(view: container.layer)
        roundContainer(view: fieldNameContainer.layer)
        roundContainer(view: container2.layer)
        progressBar.progress = 0
        styleContainer(view: titleField.layer)
    }

    func styleContainer(view: CALayer) {
        roundContainer(view: view)
        view.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        view.shadowOffset = CGSize(width: 0, height: 2)
        view.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        view.shadowOpacity = 1
        view.shadowRadius = 3
    }

    func roundContainer(view: CALayer) {
        view.cornerRadius = 8
    }

    @IBAction func toggleRec(_ sender: UIButton) {
        if isRecording {
            isRecording = false
            sender.isEnabled  = false
            self.recordButton.setImage(#imageLiteral(resourceName: "recdisabled"), for: .normal)
            stopRec()
        } else {
            beginRec()
        }
    }

    @IBAction func togglePlay(_ sender: UIButton) {
        playback()
    }

    @IBAction func toggleStop(_ sender: UIButton) {
        stopPlayback()
    }

    @IBAction func toggleDelete(_ sender: UIButton) {
        disablePlaybackButtons()
        stopPlayback()
        recordButton.isEnabled = true
        recordButton.setImage(#imageLiteral(resourceName: "rec"), for: .normal)
        progressBar.progress = 0
        progressLabel.text = ""
        sizeLabel.text = ""
    }

    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func savePressed(_ sender: Any) {
        var notes = ""
        if textView.text != nil {
            notes = textView.text
        }
        var title = ""
        if titleField.text != nil {
            title = titleField.text!
        }
        DataServices.saveAudio(audioURL: getFileUrl(), index: 0, observationID: observationID,inspectionID: inspectionID ,notes: notes, title: title) { (done) in
            self.dismiss(animated: true, completion: {
                return self.callBack!(true)
            })
        }
    }

    func disablePlaybackButtons() {
        deleteButton.isEnabled  = false
        playBUtton.isEnabled  = false
        stopButton.isEnabled  = false
    }

    func enablePlaybackButtons() {
        deleteButton.isUserInteractionEnabled = true
        playBUtton.isUserInteractionEnabled = true
        stopButton.isUserInteractionEnabled = true
    }

    func getFileUrl() -> URL {
        let filename = "\(tempid).m4a"
        let filePath = getDocumentsDirectory().appendingPathComponent(filename)
        return filePath
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func getSizeString(size: Double) -> String {
        let fileSizeWithUnit = ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)
        return "\(fileSizeWithUnit)"
    }
    
    func getSize(url: URL?) -> Double {
        guard let filePath = url?.path else {
            return 0.0
        }
        do {
            let attribute = try FileManager.default.attributesOfItem(atPath: filePath)
            if let size = attribute[FileAttributeKey.size] as? NSNumber {
                return size.doubleValue
            }
        } catch {
            print("Error: \(error)")
        }
        return 0.0
    }
    
    func isFileSizeLessThan(size: Double, maxMB: Double) -> Bool {
        let max = 1000000 * maxMB
        return size < max
    }
    
    func getRemaining(size: Double, maxMB: Double) -> Double {
        let max = 1000000 * maxMB
        return max - size
    }
    
    func getRemainingPercent(size: Double, maxMB: Double) -> Float {
        let max = 1000000 * maxMB
        return Float(size / max)
    }
}

extension AudioRecorderViewController: AVAudioRecorderDelegate {
    
    func beginRec() {
        if initRecorder() {
            audioRecorder.record()
            meterTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateAudioMeter(timer:)), userInfo: nil, repeats: true)
            isRecording = true
        }
    }

    func stopRec() {
        audioRecorder.stop()
        audioRecorder = nil
        meterTimer.invalidate()

        playBUtton.isEnabled  = true
        deleteButton.isEnabled = true
    }

    @objc func updateAudioMeter(timer: Timer) {
        if audioRecorder.isRecording {
            // set time from getCurrentRecordingTime()

            // get current size
            let size = getSize(url: getFileUrl())

            // if passed max size, stop recording
            if isFileSizeLessThan(size: size, maxMB: MAX_FILE_SIZE) {
//                recordingTimeLabel.textColor = .green
            } else {
                stopRec()
            }
            updateProgress(size: size)
            sizeLabel.text = getSizeString(size: size)
            progressLabel.text = getCurrentRecordingTime()
            audioRecorder.updateMeters()
        }
    }

    func updateProgress(size: Double) {
        let rem = getRemainingPercent(size: size, maxMB: MAX_FILE_SIZE)
        self.progressBar.setProgress(rem, animated: true)
    }

    func getCurrentRecordingTime() -> String {
        if audioRecorder.isRecording {
            let hr = Int((audioRecorder.currentTime / 60) / 60)
            let min = Int(audioRecorder.currentTime / 60)
            let sec = Int(audioRecorder.currentTime.truncatingRemainder(dividingBy: 60))
            let totalTimeString = String(format: "%02d:%02d:%02d", hr, min, sec)
            return totalTimeString
        } else {
            return ""
        }
    }

    func initRecorder() -> Bool {

        if AVAudioSession.sharedInstance().recordPermission == .granted {
            let session = AVAudioSession.sharedInstance()
            do {
                try session.setCategory(.playAndRecord, mode: .default)
                try session.setActive(true)
                let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 44100,
                    AVNumberOfChannelsKey: 2,
                    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                ]
                audioRecorder = try AVAudioRecorder(url: getFileUrl(), settings: settings)
                audioRecorder.delegate = self
                audioRecorder.isMeteringEnabled = true
                audioRecorder.prepareToRecord()
                return true
            } catch let error {
                print("\(#function)\(error.localizedDescription)")
                return false
            }
        } else {

            // warn is not permitted

            return false
        }
    }

    func checkRecordingPermission() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSession.RecordPermission.granted:
            isAudioRecordingGranted = true
            break
        case AVAudioSession.RecordPermission.denied:
            isAudioRecordingGranted = false
            break
        case AVAudioSession.RecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.isAudioRecordingGranted = true
                    } else {
                        self.isAudioRecordingGranted = false
                    }
                }
            }
            break
        }
    }

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        enablePlaybackButtons()
        recordButton.isEnabled = false
    }
}

// Playback
extension AudioRecorderViewController: AVAudioPlayerDelegate {

    func playback() {
        if FileManager.default.fileExists(atPath: getFileUrl().path) {
            if initPlay() {
                audioPlayer.play()
                isPlaying = true
                playBUtton.isEnabled = false
                stopButton.isEnabled = true
            }
        } else {
            // error: could not find audio file
        }
    }

    func stopPlayback() {
        if(isPlaying) {
            audioPlayer.stop()
            isPlaying = false

            stopButton.isEnabled = false
            playBUtton.isEnabled = true
        }
    }

    func initPlay() -> Bool {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: getFileUrl())
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            return true
        } catch {
            print("Error")
            return false
        }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopPlayback()
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
