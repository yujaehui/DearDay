//
//  DDayView.swift
//  DearDay
//
//  Created by Jaehui Yu on 10/14/24.
//

import SwiftUI

struct DDayView: View {
    @StateObject private var viewModel = DDayViewModel(repository: DDayRepository(), apiService: APIService())
    
    @State private var isPresentedSelectDDayTypeAlertView: Bool = false
    @State private var navigateToAddDDayView: Bool = false
    @State private var selectedDDayType: DDayType = .dDay
    
    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    if viewModel.isGrouped {
                        ForEach(viewModel.sortedAndGroupedDDays, id: \.key) { group in
                            Section(header: Text(group.key.rawValue)) {
                                ForEach(group.value, id: \.pk) { dDayItem in
                                    NavigationLink(destination: DDayDetailView(dDayItem: dDayItem, viewModel: viewModel)) {
                                        DDayCardView(dDayItem: dDayItem, dDayText: viewModel.dDayText[dDayItem.pk] ?? "")
                                    }
                                }
                            }
                        }
                    } else {
                        ForEach(viewModel.sortedDDays, id: \.pk) { dDayItem in
                            NavigationLink(destination: DDayDetailView(dDayItem: dDayItem, viewModel: viewModel)) {
                                DDayCardView(dDayItem: dDayItem, dDayText: viewModel.dDayText[dDayItem.pk] ?? "")
                            }
                        }
                    }
                    
                }
                .listStyle(.grouped)
                .navigationDestination(isPresented: $navigateToAddDDayView) {
                    AddDDayView(type: selectedDDayType)
                        .environmentObject(viewModel)
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
                    DDayMenu(selectedSortOption: $viewModel.selectedSortOption, isGrouped: $viewModel.isGrouped)
                        .onChange(of: viewModel.selectedSortOption) { _ in
                            viewModel.updateSortedAndGroupedDDays()
                        }
                        .onChange(of: viewModel.isGrouped) { _ in
                            viewModel.updateSortedAndGroupedDDays()
                        }
                }
            }
        }
        .task {
            viewModel.fetchDDay()
        }
        .tint(.gray)
    }
}

fileprivate struct DDayMenu: View {
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
