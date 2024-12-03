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
                if viewModel.dDayItems.isEmpty {
                    DDayEmptyView()
                } else {
                    DDayListView()
                    .listStyle(.grouped)
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
            .navigationDestination(isPresented: $navigateToAddDDayView) {
                AddDDayView(type: selectedDDayType)
                    .environmentObject(viewModel)
            }
            .toolbar { 
                ToolbarContent()
            }
            .task {
                viewModel.fetchDDay()
            }
        }
        .tint(.secondary)
    }
}

private extension DDayView {
    @ViewBuilder
    func DDayEmptyView() -> some View {
        VStack(spacing: 10) {
            Text("기억하고 싶은 순간을 기록하세요.")
                .foregroundStyle(.secondary)
                .font(.title3)
            Text("상단의 + 버튼을 눌러 D-DAY를 추가할 수 있습니다.")
                .foregroundColor(.secondary.opacity(0.8))
                .font(.caption)
        }
        .padding()
    }
    
    @ViewBuilder
    func DDayListView() -> some View {
        List {
            if viewModel.isGrouped {
                ForEach(viewModel.sortedAndGroupedDDayItems, id: \.key) { group in
                    Section(header: Text(group.key.rawValue)) {
                        ForEach(group.value, id: \.pk) { dDayItem in
                            NavigationLink(destination: DDayDetailView(dDayItem: dDayItem, viewModel: viewModel)) {
                                DDayCardView(dDayItem: dDayItem, dDayText: viewModel.dDayText[dDayItem.pk] ?? "")
                            }
                        }
                    }
                }
            } else {
                ForEach(viewModel.sortedDDayItems, id: \.pk) { dDayItem in
                    NavigationLink(destination: DDayDetailView(dDayItem: dDayItem, viewModel: viewModel)) {
                        DDayCardView(dDayItem: dDayItem, dDayText: viewModel.dDayText[dDayItem.pk] ?? "")
                    }
                }
            }
        }
    }
    
    @ToolbarContentBuilder
    func ToolbarContent() -> some ToolbarContent {
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
            DDayMenu()
            .onChange(of: viewModel.selectedSortOption) { _ in
                viewModel.updateSortedAndGroupedDDays()
            }
            .onChange(of: viewModel.isGrouped) { _ in
                viewModel.updateSortedAndGroupedDDays()
            }
        }
    }
    
    private func DDayMenu() -> some View {
        Menu {
            Picker("정렬", selection: $viewModel.selectedSortOption) {
                ForEach(SortOption.allCases, id: \.self) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            Toggle(isOn: $viewModel.isGrouped) {
                Label("그룹화", systemImage: "rectangle.grid.1x2")
            }
        } label: {
            Image(systemName: "ellipsis")
                .foregroundColor(.gray)
                .rotationEffect(.degrees(90))
        }
    }
}
