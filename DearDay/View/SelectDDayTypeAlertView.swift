//
//  SelectDDayTypeAlertView.swift
//  DearDay
//
//  Created by Jaehui Yu on 10/30/24.
//

import SwiftUI

struct SelectDDayTypeAlertView: View {
    @Binding var isPresentedSelectDDayTypeAlertView: Bool
    @Binding var selectedDDayType: DDayType
    @Binding var navigateToAddDDayView: Bool
    
    var body: some View {
        ZStack {
            Color.secondary.opacity(0.8)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Text("계산 방법을 선택하세요")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button {
                            isPresentedSelectDDayTypeAlertView.toggle()
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundStyle(.secondary)
                                .font(.title3)
                        }
                    }
                    .padding(.bottom)
                    
                    Button {
                        selectedDDayType = .dDay
                        isPresentedSelectDDayTypeAlertView.toggle()
                        navigateToAddDDayView = true
                    } label: {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("D-Day")
                                .foregroundStyle(.primary)
                                .font(.title3)
                                .fontWeight(.bold)
                            Text("시험, 생일 등 (D+는 0부터 시작)")
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Divider()
                    
                    Button {
                        selectedDDayType = .numberOfDays
                        isPresentedSelectDDayTypeAlertView.toggle()
                        navigateToAddDDayView = true
                    } label: {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("날짜 수")
                                .foregroundStyle(.primary)
                                .font(.title3)
                                .fontWeight(.bold)
                            Text("연인 기념일 등 (D+는 1부터 시작)")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.vertical)
                .padding(.horizontal)
                .background(.background)
                .cornerRadius(8)
                .padding()
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.clear)
        }
    }
}
