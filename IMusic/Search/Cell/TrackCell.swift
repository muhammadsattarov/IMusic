//
//  TrackCell.swift
//  IMusic
//
//  Created by user on 10/02/24.
//

import UIKit
import SDWebImage

protocol TrackCellViewModel {
    var iconUrlString: String? { get }
    var trackName: String { get }
    var artistName: String { get }
    var collectionName: String { get }

}

class TrackCell: UITableViewCell {

    @IBOutlet weak var trackImageView: UIImageView!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var collectionNameLabel: UILabel!
    
    @IBOutlet weak var addTrackButton: UIButton!
    
    
    static let reuseId = "TrackCell"
    
    override func prepareForReuse() {
        super.prepareForReuse()
        trackImageView.image = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print("awake")
    }
    
    var cell: SearchViewModel.Cell?
    
    func set(viewModel: SearchViewModel.Cell) {
        self.cell = viewModel
        
        let savedTracks = UserDefaults.standard.savedTracks()
        let hasFavorite = savedTracks.firstIndex(where: {
            $0.trackName == self.cell?.trackName && $0.artistName == self.cell?.artistName }) != nil
        if hasFavorite {
            addTrackButton.isHidden = true
        } else {
            addTrackButton.isHidden = false
        }
        
        trackNameLabel.text = viewModel.trackName
        artistNameLabel.text = viewModel.artistName
        collectionNameLabel.text = viewModel.collectionName
        
        guard let url = URL(string: viewModel.iconUrlString ?? "") else { return }
        trackImageView.sd_setImage(with: url, completed: nil)
    }
    
    @IBAction func addTrackAction(_ sender: Any) {
        let defaults = UserDefaults.standard
        guard let cell = cell else { return }
        addTrackButton.isHidden = true
        var listOfTracks = defaults.savedTracks()
        listOfTracks.append(cell)
        
        if let saveData = try? NSKeyedArchiver.archivedData(withRootObject: listOfTracks, requiringSecureCoding: false) {
            print("success")
            defaults.set(saveData, forKey: UserDefaults.favoriteTrackkey)
        }
    }
}
