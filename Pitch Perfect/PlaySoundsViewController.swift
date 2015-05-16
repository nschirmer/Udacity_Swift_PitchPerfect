//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Nicholas Schirmer on 5/13/15.
//  Copyright (c) 2015 Shiny New Software, LLC. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {

    var audioPlayer:AVAudioPlayer!
    var receivedAudio:RecordedAudio!
    
    @IBOutlet weak var stopButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        if var filePath = NSBundle.mainBundle().pathForResource("movie_quote", ofType: "mp3") {
//            var filePathUrl = NSURL.fileURLWithPath(filePath)
//        } else {
//            println("the filePath is empty")
//        }
        
        audioPlayer = AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl, error: nil)
        audioPlayer.enableRate = true

    }
    
    override func viewWillAppear(animated: Bool) {
        stopButton.hidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        audioPlayer.stop()
        stopButton.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func playSlowAudio(sender: UIButton) {
        playAudioEffect(0.5)
    }

    @IBAction func playFastAudio(sender: UIButton) {
        playAudioEffect(1.5)
    }
    
    @IBAction func playChipmunkAudio(sender: UIButton) {
        
    }
    
    @IBAction func stopAudio(sender: UIButton) {
        audioPlayer.stop()
        stopButton.hidden = true
    }
    
    func playAudioEffect(rate: Float) {
        audioPlayer.stop()
        audioPlayer.rate = rate
        audioPlayer.currentTime = 0.0
        audioPlayer.play()
        stopButton.hidden = false
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
