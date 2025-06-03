//
//  AddFriendWatchView.swift
//  ALP_RawrWatchApp Watch App
//
//  Created by Gerald Gavin Lienardi on 01/06/25.
//

import SwiftUI

struct AddFriendWatchView: View {
    @State var friendUID: String = ""
    @State var isSearching = true
    @State var searchButtonIsDisabled = true
    @State var friend : [String : Any] = [:]
    
    @StateObject var diaryWatchViewModel: iOSConnectivity
    
    var body: some View {
        NavigationStack{
            VStack{
                TextField("Search Friend's UID", text: $friendUID)
                    .textFieldStyle(.automatic)
                    .onChange(of: friendUID) {
                        searchButtonIsDisabled = friendUID.isEmpty
                    }
                if isSearching{
                    Button("Search"){
                        diaryWatchViewModel.searchFriendFrom(uid: friendUID)
                        isSearching = false
                    }
                    .disabled(searchButtonIsDisabled)
                } else {
                    Text("found:")
                    if let friend = diaryWatchViewModel.searchedFriend,
                       let username = friend["username"] as? String {
                        Text(username)
                        Button("Add"){
                            diaryWatchViewModel.addFriendFromWatch(friendId: friendUID)
                            friendUID = ""
                        }
                    } else {
                        Text("None")
                            .foregroundColor(.gray)
                    }
                    Button("Cancel"){
                        isSearching = true
                    }
                }
                
            }
            .navigationTitle("Search Friend")

        }
    }
}

#Preview {
    AddFriendWatchView(diaryWatchViewModel: iOSConnectivity())
}
