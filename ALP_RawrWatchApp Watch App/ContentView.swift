//
//  ContentView.swift
//  ALP_RawrWatchApp Watch App
//
//  Created by student on 30/05/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var diaryWatchViewModel: DiaryWatchViewModel = DiaryWatchViewModel()
    var body: some View {
        DiaryWatchView(diaryWatchViewModel: diaryWatchViewModel)
    }
}

#Preview {
    ContentView()
}
