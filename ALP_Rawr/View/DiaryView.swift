//
//  DiaryView.swift
//  ALP_Rawr
//
//  Created by Gerald Gavin Lienardi on 27/05/25.
//

import SwiftUI

struct DiaryView: View {
    var body: some View {
        NavigationStack{
            ScrollView{
                HStack{
                    EntryCard(username: "try", entryText: "trytrytry", likesCount: 10, commentsCount: 10, timeAgo: "10h")
                        .padding(20)
                }
            }
            .navigationTitle(Text("My Diary"))
        }
    }
}

#Preview {
    DiaryView()
}
