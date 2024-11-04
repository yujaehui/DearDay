//
//  DDayView.swift
//  DearDay
//
//  Created by Jaehui Yu on 10/14/24.
//

import SwiftUI
import RealmSwift

struct DDayView: View {
    @ObservedResults(DDay.self) var dDays
    
    @State private var isPresentedSelectDDayTypeAlertView = false
    @State private var navigateToAddDDayView = false
    @State private var selectedDDayType: DDayType = .dDay
    
    var body: some View {
        NavigationStack {
            ZStack {
                List(dDays) { dDay in
                    NavigationLink(destination: DDayDetailView(dDay: dDay)) {
                        DDayCardView(dDay: dDay)
                    }
                }
                .listStyle(.grouped)
                .navigationDestination(isPresented: $navigateToAddDDayView) {
                    AddDDayView(type: selectedDDayType)
                }
                
                
                if isPresentedSelectDDayTypeAlertView {
                    SelectDDayTypeAlertView(
                        isPresentedSelectDDayTypeAlertView: $isPresentedSelectDDayTypeAlertView,
                        selectedDDayType: $selectedDDayType,
                        navigateToAddDDayView: $navigateToAddDDayView
                    )
                }
            }
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
                        isPresentedSelectDDayTypeAlertView.toggle()
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
