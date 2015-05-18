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

    var receivedAudio:RecordedAudio!
    
    var audioEngine:AVAudioEngine!
    var audioPlayer:AVAudioPlayer!
//    var audioPlayerNode:AVAudioPlayerNode!
    var audioBuffer:AVAudioPCMBuffer!
    
    var bufferedFiles:Int = 0
    var wasInterrupted:Bool = false
    
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
