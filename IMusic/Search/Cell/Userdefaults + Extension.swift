//
//  Userdefaults + Extension.swift
//  IMusic
//
//  Created by user on 12/02/24.
//

import Foundation


extension UserDefaults {
    static let favoriteTrackkey = "favoriteTrackkey"
    
    func savedTracks() -> [SearchViewModel.Cell] {
        let defaults = UserDefaults.standard
        
        guard let savedTracks = defaults.object(forKey: UserDefaults.favoriteTrackkey) as? Data else { return [] }
        guard let decodedTracks = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedTracks) as? [SearchViewModel.Cell] else { return [] }
        return decodedTracks
    }
}
