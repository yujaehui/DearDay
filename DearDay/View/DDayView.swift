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
    @AppStorage("isGrouped") private var isGrouped: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    if isGrouped {
                        GroupedDDayListView(dDays: dDays)
                    } else {
                        DDayListView(dDays: dDays)
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
                    Menu {
                        Menu {
                            Button {
                                // 제목순으로 정렬 기능 추가
                            } label: {
                                Label("제목순", systemImage: "textformat")
                            }
                            Button {
                                // 디데이순으로 정렬 기능 추가
                            } label: {
                                Label("디데이순", systemImage: "calendar")
                            }
                        } label: {
                            Label("정렬", systemImage: "arrow.up.arrow.down")
                        }
                        Toggle(isOn: $isGrouped) {
                            Label("그룹화", systemImage: "rectangle.grid.1x2")
                        }
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

struct DDayListView: View {
    let dDays: Results<DDay>
    
    var body: some View {
        ForEach(dDays) { dDay in
            NavigationLink(destination: DDayDetailView(dDay: dDay)) {
                DDayCardView(dDay: dDay)
            }
        }
    }
}

struct GroupedDDayListView: View {
    let dDays: Results<DDay>
    
    private var sortedGroupedDDays: [(key: DDayType, value: [DDay])] {
        let grouped = Dictionary(grouping: dDays, by: { $0.type })
        return grouped.sorted { $0.key.rawValue < $1.key.rawValue }
    }
    
    var body: some View {
        ForEach(sortedGroupedDDays, id: \.key) { group in
            Section(header: Text(group.key.rawValue)) {
                ForEach(group.value) { dDay in
                    NavigationLink(destination: DDayDetailView(dDay: dDay)) {
                        DDayCardView(dDay: dDay)
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        DDayView()
    }
}
