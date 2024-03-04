//
//  NetworkServise.swift
//  IMusic
//
//  Created by user on 09/02/24.
//

import UIKit
import Alamofire

class NetworkServise {
    
    func fetchRequest(searchText: String, completion: @escaping (SearchResponse?) -> Void) {
        let url = "https://itunes.apple.com/search?term="
        let params = ["term":"\(searchText)",
                      "limit":"30",
                      "media":"music"]
        AF.request(url, method: .get, parameters: params, headers: nil).response { dataResponse in
            if let error = dataResponse.error {
                print(error.localizedDescription)
                completion(nil)
            }
            guard let data = dataResponse.data else { return }
            let decoder = JSONDecoder()
            do {
                let results = try decoder.decode(SearchResponse.self, from: data)
                print("results: ", results)
                completion(results)
            } catch let jsonError {
                print("Failed decode Json", jsonError)
                completion(nil)
            }
            
        }
    }
}
