//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by Nicholas Schirmer on 5/12/15.
//  Copyright (c) 2015 Shiny New Software, LLC. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
  
    // Our UI elements
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var recordingInProgress: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    // For creating and storing the recorded audio
    var audioRecorder:AVAudioRecorder!
    var recordedAudio:RecordedAudio!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        resetView()
    }
    
    // Call this when the UI should reset to its default view (pre-recording)
    func resetView() {
        stopButton.hidden = true
        pauseButton.hidden = true
        pauseButton.enabled = true
        
        recordingInProgress.hidden = false
        recordButton.enabled = true
        
        recordingInProgress.text = "Tap to Record"
    }
    
    @IBAction func pauseRecording(sender: UIButton) {
        audioRecorder.pause()
        pauseButton.enabled = false
        recordButton.enabled = true
        recordingInProgress.text = "Tap to Resume"
    }
    
    @IBAction func recordAudio(sender: UIButton) {
        // A few UI changes...
        recordButton.enabled = false
        recordingInProgress.text = "Recording in Progress"
        stopButton.hidden = false
        pauseButton.hidden = false
        
        if(pauseButton.enabled == false) {
            // The recording is currently paused
            pauseButton.enabled = true
            audioRecorder.record()
        } else {
            // Start a fresh recording
            
            // We need to retrieve the directory where we're allowed to store files
            let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
            
            // Grab the current DateTime, formatted in a way we like, and use that as the .wav filename
            let currentDateTime = NSDate()
            let formatter = NSDateFormatter()
            formatter.dateFormat = "ddMMyyyy-HHmmss"
            let recordingName = formatter.stringFromDate(currentDateTime) + ".wav"
            let pathArray = [dirPath, recordingName]
            let filePath = NSURL.fileURLWithPathComponents(pathArray)
            println(filePath)
            
            // Set our session to Play And Record
            var session = AVAudioSession.sharedInstance()
            session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
            
            // Set up the recorder using our file path, and begin recording
            audioRecorder = AVAudioRecorder(URL: filePath, settings: nil, error: nil)
            audioRecorder.delegate = self;
            audioRecorder.meteringEnabled = true
            audioRecorder.record()
        }
    }
    
    @IBAction func stopRecording(sender: UIButton) {
        // Hide/disable some UI elements so nothing interferes while we wait for the response to be delegated
        stopButton.hidden = true
        recordingInProgress.hidden = true
        pauseButton.hidden = true
        recordButton.enabled = false
        
        audioRecorder.stop()
        var audioSession = AVAudioSession.sharedInstance()
        audioSession.setActive(false, error: nil)
        
        println("in stopRecording")
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        if(flag) {
            // Store the recorded audio
            recordedAudio = RecordedAudio(filePathUrl: recorder.url, title: recorder.url.lastPathComponent!)
            // Move on to the next scene
            self.performSegueWithIdentifier("stopRecording", sender: recordedAudio)
        } else {
            println("Recording was not successful")
            resetView()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "stopRecording") {
            let playSoundsVC:PlaySoundsViewController = segue.destinationViewController as! PlaySoundsViewController
            let data = sender as! RecordedAudio
            playSoundsVC.receivedAudio = data
        }
    }
}

