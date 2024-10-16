//
//  DDayView.swift
//  DearDay
//
//  Created by Jaehui Yu on 10/14/24.
//

import SwiftUI

struct DDayView: View {
    var body: some View {
        NavigationStack {
            List(sampleDDays) { dday in
                NavigationLink(destination: DDayDetailView(dday: dday)) {
                    DDayCardView(dday: dday)
                }
            }
            .listStyle(.grouped)
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Dear Day")
                        .foregroundStyle(.gray)
                        .font(.headline)
                        .fontWeight(.bold)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        print("D-Day Add Button Tap")
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(.gray)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        print("Setting Button Tap")
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.gray)
                            .rotationEffect(.degrees(90))
                    }
                }
            }
        }
        .tint(.gray)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        DDayView()
    }
}
