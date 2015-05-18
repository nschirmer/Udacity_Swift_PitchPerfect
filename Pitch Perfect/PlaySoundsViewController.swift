//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Nicholas Schirmer on 5/13/15.
//  Copyright (c) 2015 Shiny New Software, LLC. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController, AVAudioPlayerDelegate {

    // Our model
    var receivedAudio:RecordedAudio!
    
    // Necessary AVFoundation classes
    var audioEngine:AVAudioEngine!
    var audioPlayer:AVAudioPlayer!
    var audioBuffer:AVAudioPCMBuffer!
    
    // Specific to our audioEngine's audioPlayerNode
    // A way for us to know if we should hide the stopButton when the player node completes
    var bufferedFiles:Int = 0
    var wasInterrupted:Bool = false
    
    // Only UI element we need an outlet to
    @IBOutlet weak var stopButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // This player will be used for fast / slow where all we need to do is change the rate
        audioPlayer = AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl, error: nil)
        audioPlayer.enableRate = true
        audioPlayer.delegate = self
        
        // An audio engine player will be used for more complex effects
        audioEngine = AVAudioEngine()
        
        // We'll load in the file, and then read it into a buffer
        var audioFile = AVAudioFile(forReading: receivedAudio.filePathUrl, error: nil)
        audioBuffer = AVAudioPCMBuffer(PCMFormat: audioFile.processingFormat, frameCapacity: AVAudioFrameCount(audioFile.length))
        audioFile.readIntoBuffer(audioBuffer, error: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        stopButton.hidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        stopAllAudio()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func playSlowAudio(sender: UIButton) {
        playAudioWithVariableRate(0.5)
    }

    @IBAction func playFastAudio(sender: UIButton) {
        playAudioWithVariableRate(1.5)
    }
    
    func playAudioWithVariableRate(rate: Float) {
        stopAllAudio()
        
        // Set the variable rate, restart the audio, and play it
        audioPlayer.rate = rate
        audioPlayer.currentTime = 0.0
        audioPlayer.play()
        stopButton.hidden = false
    }
    
    @IBAction func playChipmunkAudio(sender: UIButton) {
        playAudioWithVariablePitch(1000)
    }
    
    @IBAction func playDarthVaderAudio(sender: UIButton) {
        playAudioWithVariablePitch(-1000)
    }
    
    @IBAction func playEchoAudio(sender: UIButton) {
        var setEchoEffect = AVAudioUnitDelay()
        setEchoEffect.delayTime = NSTimeInterval(0.3)
        
        playAudioWithNodeEffect(setEchoEffect)
    }
    
    @IBAction func playReverbAudio(sender: UIButton) {
        var setReverbEffect = AVAudioUnitReverb()
        setReverbEffect.loadFactoryPreset(AVAudioUnitReverbPreset.Cathedral)
        setReverbEffect.wetDryMix = 50
        
        playAudioWithNodeEffect(setReverbEffect);
    }
    
    func playAudioWithVariablePitch(pitch: Float) {
        var changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = pitch
        
        playAudioWithNodeEffect(changePitchEffect)
    }
    
    // Main function that all of our node-effect functions can pass through
    // Binds the effect node to the engine, creates the player node, and plays the buffer
    func playAudioWithNodeEffect(effectNode: AVAudioNode) {
        stopAllAudio()
        
        var audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)

        audioEngine.attachNode(effectNode)
        
        audioEngine.connect(audioPlayerNode, to: effectNode, format: nil)
        audioEngine.connect(effectNode, to: audioEngine.outputNode, format: nil)
        
        // Set the initial state of wasInterrupted, and increase our bufferedFiles
        wasInterrupted = false
        bufferedFiles = bufferedFiles + 1
        
        // We're using scheduleBuffer instead of scheduleFile since the completionHandler
        // is more reliable about executing when the file finishes playing
        audioPlayerNode.scheduleBuffer(audioBuffer, completionHandler: {
            () -> Void in
            // We need our completionHandler to execute on the main thread,
            // since we may be altering the View (by hiding the stop button)
            dispatch_async(dispatch_get_main_queue(), {
                // Decrease our buffered files by one, since this file stopped playing
                if(self.bufferedFiles > 0) {
                    self.bufferedFiles = self.bufferedFiles - 1
                } else {
                    return
                }
                
                // We won't hide the stop button if playback was interrupted, or if
                // we have a pending bufferedFile
                if(!self.wasInterrupted && self.bufferedFiles == 0) {
                    self.hideStopButton()
                }
            })
        })
        
        audioEngine.startAndReturnError(nil)
        
        audioPlayerNode.play()
        stopButton.hidden = false
    }
    
    @IBAction func stopAudio(sender: UIButton) {
        stopAllAudio()
    }
    
    func stopAllAudio() {
        wasInterrupted = true
        
        if(audioPlayer.playing) {
            audioPlayer.stop()
        }

        audioEngine.stop()
        audioEngine.reset()
        
        hideStopButton()
    }
    
    // This function is sent from the AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        hideStopButton()
    }
    
    func hideStopButton() {
        stopButton.hidden = true
    }

}
