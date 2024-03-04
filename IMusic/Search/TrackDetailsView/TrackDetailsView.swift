//
//  RrackDetailsView.swift
//  IMusic
//
//  Created by user on 11/02/24.
//

import UIKit
import SDWebImage
import AVKit

protocol TrackMovingDelegate {
    func moveBackForPreviousTrack() -> SearchViewModel.Cell?
    func moveForwardForPreviousTrack() -> SearchViewModel.Cell?
}

class TrackDetailsView: UIView {
    
    @IBOutlet weak var miniTrackView: UIView!
    @IBOutlet weak var miniImageView: UIImageView!
    @IBOutlet weak var miniTrackNameLabel: UILabel!
    @IBOutlet weak var miniPlayPauseButton: UIButton!
    @IBOutlet weak var miniNextButton: UIButton!
    @IBOutlet weak var maxStackView: UIStackView!
    
    
    @IBOutlet weak var currentTimeSlider: UISlider!
    @IBOutlet weak var trackImage: UIImageView!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationTimeLabel: UILabel!
    @IBOutlet weak var trackTitleLabel: UILabel!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var volumeSlider: UISlider!
    
    let player: AVPlayer = {
        let player = AVPlayer()
        player.automaticallyWaitsToMinimizeStalling = false
        return player
    }()
    
    var delegate: TrackMovingDelegate?
    weak var tabBardelegate: MainTabBarControllerDelegate?
    //MARK: - awakeFromNib
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        let scale: CGFloat = 0.8
        trackImage.transform = CGAffineTransform(scaleX: scale, y: scale)
        trackImage.layer.cornerRadius = 8
        setupGesture()
    }
    
    //MARK: - setup
    
    func set(viewModel: SearchViewModel.Cell) {
        miniTrackNameLabel.text = viewModel.trackName
        trackTitleLabel.text = viewModel.trackName
        authorNameLabel.text = viewModel.artistName
        playTrack(previewUrl: viewModel.previewUrl)
        monitorStartTime()
        observeOlayerCurrentTime()
        let image600 = viewModel.iconUrlString?.replacingOccurrences(of: "100x100", with: "600x600")
        guard let url = URL(string: image600 ?? "") else { return }
        trackImage.sd_setImage(with: url)
        miniImageView.sd_setImage(with: url)
    }
    
    private func setupGesture() {
        miniTrackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapMax)))
        miniTrackView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan)))
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismissedPan)))
    }
    
    private func playTrack(previewUrl: String?) {
        guard let url = URL(string: previewUrl ?? "") else { return }
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
    
    //MARK: - Max and min gesture
    
    @objc private func handleTapMax() {
        print("maxGesture tapped")
        self.tabBardelegate?.maximizeTrackDetailcontroller(viewModel: nil)
    }
    
    @objc private func handlePan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            print("began")
        case .changed:
            handleChanged(gesture: gesture)
        case .ended:
            handleEnded(gesture: gesture)
        @unknown default:
            print("@unknown default")
        }
    }
    
    private func handleChanged(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        self.transform = CGAffineTransform(translationX: 0, y: translation.y)
        let newAlfa = 1 + translation.y / 200
        self.miniTrackView.alpha = newAlfa < 0 ? 0 : newAlfa
        self.maxStackView.alpha = -translation.y / 200
    }
    
    private func handleEnded(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        let velocity = gesture.velocity(in: self.superview)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseInOut) {
            self.transform = .identity
            if translation.y < -200 || velocity.y < -500 {
                self.tabBardelegate?.maximizeTrackDetailcontroller(viewModel: nil)
            } else {
                self.miniTrackView.alpha = 1
                self.maxStackView.alpha = 0
            }
        }
    }
    
    @objc func handleDismissedPan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .changed:
            handleDismissChanged(gesture: gesture)
        case .ended:
            handleDismissEnded(gesture: gesture)
        @unknown default:
            print("unknown default")
        }
    }
    
    private func handleDismissChanged(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        maxStackView.transform = CGAffineTransform(translationX: 0, y: translation.y)
    }
    
    private func handleDismissEnded(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseInOut) {
            self.maxStackView.transform = .identity
            if translation.y > 50 {
                self.tabBardelegate?.minimizeTrackDetailController()
            }
        }
    }
    
    //MARK: - Time setup
    
    private func monitorStartTime() {
        let time = CMTimeMake(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            self?.enLargeTrackImage()
        }
    }
    
    func observeOlayerCurrentTime() {
        let interval = CMTimeMake(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.currentTimeLabel.text = time.toDisplayString()
            
            let durationTime = self?.player.currentItem?.duration
            let currentDurationText = ((durationTime ?? CMTimeMake(value: 1, timescale: 1)) - time).toDisplayString()
            self?.durationTimeLabel.text = "-\(currentDurationText)"
            self?.updateCurrentSlider()
        }
    }
    
    private func updateCurrentSlider() {
        let currenttimeSeconds = CMTimeGetSeconds(player.currentTime())
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
        let persentage = currenttimeSeconds / durationSeconds
        self.currentTimeSlider.value = Float(persentage)
    }
    
    //MARK: - Animation
    
    func enLargeTrackImage() {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.trackImage.transform = .identity
        }
    }
    
    func reduceTrackImage() {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut) {
            let scale: CGFloat = 0.8
            self.trackImage.transform = CGAffineTransform(scaleX: scale, y: scale)
            
        }
    }
    
    //MARK: - @IBAction
    
    @IBAction func handleVolumeSlider(_ sender: Any) {
        player.volume = volumeSlider.value
    }
    @IBAction func dragDownButton(_ sender: Any) {
        self.tabBardelegate?.minimizeTrackDetailController()
        //self.removeFromSuperview()
    }

    @IBAction func pauseButton(_ sender: Any) {
        if player.timeControlStatus == .paused {
            player.play()
            playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
            miniPlayPauseButton.setImage(UIImage(named: "pause"), for: .normal)
            enLargeTrackImage()
        } else {
            player.pause()
            playPauseButton.setImage(UIImage(named: "play"), for: .normal)
            miniPlayPauseButton.setImage(UIImage(named: "play"), for: .normal)
            reduceTrackImage()
        }
    }
    
    
    @IBAction func nextMusicButton(_ sender: Any) {
        guard let viewModel = delegate?.moveForwardForPreviousTrack() else { return }
        self.set(viewModel: viewModel)
    }
    
    @IBAction func musicbackButton(_ sender: Any) {
        guard let viewModel = delegate?.moveBackForPreviousTrack() else { return }
        self.set(viewModel: viewModel)
    }
 
    @IBAction func handleCurrentTimeSlider(_ sender: Any) {
        let persentage = currentTimeSlider.value
        guard let duration = player.currentItem?.duration else { return }
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeUnSeconds = Float64(persentage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeUnSeconds, preferredTimescale: 1)
        player.seek(to: seekTime)
    }
    
    
}
