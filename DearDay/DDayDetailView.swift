//
//  DDayDetailView.swift
//  DearDay
//
//  Created by Jaehui Yu on 10/14/24.
//

import SwiftUI

struct DDayDetailView: View {
    var body: some View {
        VStack {
            ZStack(alignment: .leading) {
                Image("yourImageName")
                    .resizable()
                    .background(Color.gray.opacity(0.2))
                
                VStack(alignment: .leading) {
                    Text("혜성")
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                    
                    Text("2024.09.22(일) | 커플")
                        .foregroundColor(.white)
                        .font(.callout)
                    Spacer()
                    HStack {
                        Spacer()
                        Text("23일")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.white)
                    }
                    
                }
                .padding()
            }
            .frame(height: 300)
            
            List {
                DDayRow(dayText: "10일", date: "2024.10.01(화)")
                DDayRow(dayText: "오늘", date: "2024.10.14(월)", isToday: true)
                DDayRow(dayText: "50일", date: "2024.11.10(일)", highlight: true)
                DDayRow(dayText: "100일", date: "2024.12.30(월)")
            }
    
            .listStyle(PlainListStyle())
            
            
        }
    }
}

struct DDayRow: View {
    var dayText: String
    var date: String
    var isToday: Bool = false
    var highlight: Bool = false
    
    var body: some View {
        HStack {
            Text(dayText)
                .font(.title3)
                .fontWeight(highlight ? .bold : .regular)
                .foregroundColor(highlight ? .red : .primary)
            
            Spacer()
            
            if isToday {
                Text("오늘의 스토리는 무엇인가요?")
                    .foregroundColor(.blue)
                    .font(.body)
            } else {
                Text(date)
                    .font(.body)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
    }
}

struct DDayDetailView_Previews: PreviewProvider {
    static var previews: some View {
        DDayDetailView()
    }
}

