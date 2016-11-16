//
//  ViewController.swift
//  VideoPlayer
//
//  Created by Ajey Simha on 16/11/16.
//  Copyright © 2016 Sakhatech. All rights reserved.
//

import UIKit
import MediaPlayer
import AVKit
import AVFoundation

private var playbackLikelyToKeepUpContext = 0
class ViewController: UIViewController {
    let avPlayer = AVPlayer()
    var avPlayerLayer: AVPlayerLayer!
    let invisibleButton = UIButton()
    var timeObserver: AnyObject!
    let timeRemainingLabel = UILabel()
    let seekSlider = UISlider()
    var playerRateBeforeSeek: Float = 0
    let loadingIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)

    var moviePlayer:MPMoviePlayerController!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //view.backgroundColor = .black
        
        // An AVPlayerLayer is a CALayer instance to which the AVPlayer can
        // direct its visual output. Without it, the user will see nothing.
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        view.layer.insertSublayer(avPlayerLayer, at: 0)
        
        view.addSubview(invisibleButton)
        invisibleButton.addTarget(self, action: #selector(invisibleButtonTapped),
                                  for: .touchUpInside)
        
        let url:NSURL = NSURL(string: "http://jplayer.org/video/m4v/Big_Buck_Bunny_Trailer.m4v")!
        let playerItem = AVPlayerItem(url: url as URL)
        avPlayer.replaceCurrentItem(with: playerItem)
        
        let timeInterval: CMTime = CMTimeMakeWithSeconds(1.0, 10)
        let videoAVURLAsset:AVURLAsset = AVURLAsset.init(url: url as URL)
        let durationV:CMTime = videoAVURLAsset.duration
        timeObserver = avPlayer.addPeriodicTimeObserver(forInterval: timeInterval, queue: DispatchQueue.main) { (elapsedTime: CMTime) -> Void in                                                                    print("elapsedTime now:", CMTimeGetSeconds(elapsedTime))
            let dTotalSeconds = CMTimeGetSeconds(elapsedTime)
            let dHours:Int = Int(dTotalSeconds/3600)
            let dMinutes:Int = Int(dTotalSeconds.truncatingRemainder(dividingBy: 3600) / 60)
            let dSeconds:Int = Int((dTotalSeconds.truncatingRemainder(dividingBy: 3600)).truncatingRemainder(dividingBy: 60))
            
            if(CMTimeGetSeconds(durationV) >= 3600){
                self.timeRemainingLabel.text = String(format: "%i:%02i:%02i", dHours,dMinutes,dSeconds)
            }
            else{
                self.timeRemainingLabel.text = String(format: "%02i:%02i", dMinutes,dSeconds)
            }
            
            self.seekSlider.minimumValue = 0
            self.seekSlider.maximumValue = Float(CMTimeGetSeconds(durationV))
            self.seekSlider.value = Float(dSeconds)
            
        } as AnyObject!
        
        timeRemainingLabel.textColor = UIColor.gray
        view.addSubview(timeRemainingLabel)
        
        view.addSubview(seekSlider)
        seekSlider.addTarget(self, action: #selector(sliderBeganTracking),
                             for: .touchDown)
        seekSlider.addTarget(self, action: #selector(sliderEndedTracking),
                             for: [.touchUpInside, .touchUpOutside])
    }
    
    deinit {
        avPlayer.removeTimeObserver(timeObserver)
    }
    
    func invisibleButtonTapped(sender: UIButton) {
        let playerIsPlaying = avPlayer.rate > 0
        if playerIsPlaying {
            avPlayer.pause()
        } else {
            avPlayer.play()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        avPlayer.play() // Start the playback
        loadingIndicatorView.startAnimating()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Layout subviews manually
        avPlayerLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 200.0)
        invisibleButton.frame = view.bounds
        let controlsHeight: CGFloat = 30
        let controlsY: CGFloat = view.bounds.size.height - controlsHeight
        timeRemainingLabel.frame = CGRect(x: 30, y: 170, width: 80, height: controlsHeight)
        seekSlider.frame = CGRect(x: timeRemainingLabel.frame.origin.x + timeRemainingLabel.bounds.size.width,
                                  y: 170, width: view.bounds.size.width - timeRemainingLabel.bounds.size.width - 60, height: controlsHeight)
        loadingIndicatorView.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
    }
    
    
    func sliderBeganTracking(slider: UISlider) {
        playerRateBeforeSeek = avPlayer.rate
        avPlayer.pause()
    }
    
    func sliderEndedTracking(slider: UISlider) {
        let videoDuration = CMTimeGetSeconds(avPlayer.currentItem!.duration)
        let elapsedTime: Float64 = videoDuration * Float64(seekSlider.value) / videoDuration
        
        avPlayer.seek(to: CMTimeMakeWithSeconds(elapsedTime, 100)) { (completed: Bool) -> Void in
            if self.playerRateBeforeSeek > 0 {
                self.avPlayer.play()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

