//
//  DDayView.swift
//  DearDay
//
//  Created by Jaehui Yu on 10/14/24.
//

import SwiftUI
import RealmSwift

enum SortOption: String, CaseIterable, Identifiable {
    case creationDate = "생성일"
    case title = "제목"
    case dDay = "디데이"
    
    var id: String { self.rawValue }
}

struct DDayView: View {
    @ObservedResults(DDay.self) var dDays
    
    @State private var dDayTexts: [String : String] = [:]
    @State private var isPresentedSelectDDayTypeAlertView: Bool = false
    @State private var navigateToAddDDayView: Bool = false
    @State private var selectedDDayType: DDayType = .dDay
    
    @AppStorage("isGrouped") private var isGrouped: Bool = false
    @AppStorage("selectedSortOption") private var selectedSortOption: SortOption = .creationDate
    
    private var sortedDDays: [DDay] {
        switch selectedSortOption {
        case .creationDate:
            return dDays.toArray()
        case .title:
            return dDays.sorted(byKeyPath: "title", ascending: true).toArray()
        case .dDay:
            return dDays.sorted { (dDay1, dDay2) -> Bool in
                let dDayText1 = dDayTexts[dDay1.pk.stringValue] ?? ""
                let dDayText2 = dDayTexts[dDay2.pk.stringValue] ?? ""
                return compareDDayTexts(dDayText1, dDayText2)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    if isGrouped {
                        GroupedDDayListView(dDays: sortedDDays, dDayTexts: $dDayTexts)
                    } else {
                        DDayListView(dDays: sortedDDays, dDayTexts: $dDayTexts)
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
                    DDayMenu(selectedSortOption: $selectedSortOption, isGrouped: $isGrouped)
                }
            }
        }
        .tint(.gray)
    }
    
    private func compareDDayTexts(_ text1: String, _ text2: String) -> Bool {
        if text1.sortPriority != text2.sortPriority {
            return text1.sortPriority < text2.sortPriority
        } else {
            return text1 < text2
        }
    }
}

struct DDayListView: View {
    let dDays: [DDay]
    @Binding var dDayTexts: [String: String]
    
    var body: some View {
        ForEach(dDays, id: \.pk) { dDay in
            NavigationLink(destination: DDayDetailView(dDay: dDay)) {
                DDayCardView(
                    dDay: dDay,
                    dDayText: Binding(
                        get: { dDayTexts[dDay.pk.stringValue] ?? "" },
                        set: { dDayTexts[dDay.pk.stringValue] = $0 }
                    )
                )
            }
        }
    }
}

struct GroupedDDayListView: View {
    let dDays: [DDay]
    @Binding var dDayTexts: [String: String]
    
    private var sortedGroupedDDays: [(key: DDayType, value: [DDay])] {
        Dictionary(grouping: dDays, by: { $0.type })
            .sorted { $0.key.rawValue < $1.key.rawValue }
    }
    
    
    var body: some View {
        ForEach(sortedGroupedDDays, id: \.key) { group in
            Section(header: Text(group.key.rawValue)) {
                ForEach(group.value, id: \.pk) { dDay in
                    NavigationLink(destination: DDayDetailView(dDay: dDay)) {
                        DDayCardView(
                            dDay: dDay,
                            dDayText: Binding(
                                get: { dDayTexts[dDay.pk.stringValue] ?? "" },
                                set: { dDayTexts[dDay.pk.stringValue] = $0 }
                            )
                        )
                    }
                }
            }
        }
    }
}

struct DDayMenu: View {
    @Binding var selectedSortOption: SortOption
    @Binding var isGrouped: Bool
    
    var body: some View {
        Menu {
            Menu {
                Picker("", selection: $selectedSortOption) {
                    ForEach(SortOption.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
            } label: {
                Label("다음으로 정렬", systemImage: "arrow.up.arrow.down")
                Text(selectedSortOption.rawValue)
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

#Preview {
    DDayView()
}
