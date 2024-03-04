//
//  Library.swift
//  IMusic
//
//  Created by user on 12/02/24.
//


import SwiftUI
import URLImage


struct Library: View {
    
    @State var tracks = UserDefaults.standard.savedTracks()
    @State private var showAlert = false
    @State private var track: SearchViewModel.Cell!
    var tabBarDelegate: MainTabBarControllerDelegate?
    var body: some View {
        NavigationView {
            VStack(spacing: 5) {
                    HStack(spacing: 15) {
                        Button(action: {
                            self.track = self.tracks[0]
                            self.tabBarDelegate?.maximizeTrackDetailcontroller(viewModel: self.track)
                        }, label: {
                            Image(systemName: "play.fill")
                                .imageScale(.large)
                                .frame(width: UIScreen.main.bounds.size.width / 2 - 20,
                                       height: 50)
                                .foregroundStyle(.pink)
                                .background(.gray.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        })
                        
                        Button(action: {
                            self.tracks = UserDefaults.standard.savedTracks()
                        }, label: {
                            Image(systemName: "arrow.2.circlepath")
                                .imageScale(.large)
                                .frame(width: UIScreen.main.bounds.size.width / 2 - 20,
                                       height: 50)
                                .foregroundStyle(.pink)
                                .background(.gray.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        })
                        
                    }
                    .frame(height: 50)
                
                Divider()
                    .padding(.top, 5)
                List{
                    ForEach(tracks) { track in
                        LibraryCell(cell: track)
                            .gesture(LongPressGesture()
                            .onEnded{ _ in
                            print("pressed!")
                            self.track = track
                            self.showAlert = true
                        }.simultaneously(with: TapGesture().onEnded{ _ in
                            let keyWindow = UIApplication.shared.connectedScenes.filter({$0.activationState == .foregroundActive}).map({$0 as? UIWindowScene}).compactMap({$0}).first?.windows.filter({$0.isKeyWindow}).first
                            let tabbarVC = keyWindow?.rootViewController as? MainTabBarController
                            tabbarVC?.trackDetailView.delegate = self
                            
                            self.track = track
                            self.tabBarDelegate?.maximizeTrackDetailcontroller(viewModel: self.track)
                        }))
                    }
                    .onDelete(perform: delete)
                }
                .listStyle(.plain)
            }
            .actionSheet(isPresented: $showAlert, content: {
                ActionSheet(title: Text("Are you sure you want to delete this track?"), buttons: [
                    .destructive(Text("Delete"), action: {
                        delete(track: self.track)
                    }),
                    .cancel()
                ])
            })
            .navigationTitle("Library")
        }
    }
    func delete(at offsets: IndexSet) {
        tracks.remove(atOffsets: offsets)
        if let saveData = try? NSKeyedArchiver.archivedData(withRootObject: tracks, requiringSecureCoding: false) {
            let defaults = UserDefaults.standard
            defaults.set(saveData, forKey: UserDefaults.favoriteTrackkey)
        }
    }
    
    func delete(track: SearchViewModel.Cell) {
        let index = tracks.firstIndex(of: track)
        guard let myindex = index else { return }
        tracks.remove(at: myindex)
        if let saveData = try? NSKeyedArchiver.archivedData(withRootObject: tracks, requiringSecureCoding: false) {
            let defaults = UserDefaults.standard
            defaults.set(saveData, forKey: UserDefaults.favoriteTrackkey)
        }
    }
}

struct LibraryCell: View {
    let cell: SearchViewModel.Cell
    var body: some View {
        HStack{
            if let url = URL(string: cell.iconUrlString ?? "") {
                URLImage(url) { image in
                    image
                        .resizable()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                }
            }
            VStack(alignment: .leading) {
                Text("\(cell.trackName)")
                    .font(.system(size: 17, weight: .medium))
                Text("\(cell.artistName)")
                    .font(.system(size: 13))
                    .foregroundStyle(.gray)
            }
        }
    }
}

#Preview {
    Library()
}

extension Library: TrackMovingDelegate {
    func moveBackForPreviousTrack() -> SearchViewModel.Cell? {
        let index = tracks.firstIndex(of: track)
        guard let myTrack = index else { return nil }
        var nextIndex: SearchViewModel.Cell
        if myTrack - 1 == -1 {
            nextIndex = tracks[tracks.count - 1]
        } else {
            nextIndex = tracks[myTrack - 1]
        }
        self.track = nextIndex
        return nextIndex
    }
    
    func moveForwardForPreviousTrack() -> SearchViewModel.Cell? {
        let index = tracks.firstIndex(of: track)
        guard let myIndex = index else { return nil }
        var nextTrack: SearchViewModel.Cell
        if myIndex + 1 == tracks.count {
            nextTrack = tracks[0]
        } else {
            nextTrack = tracks[myIndex + 1]
        }
        self.track = nextTrack
        return nextTrack
    }
    
    
}
