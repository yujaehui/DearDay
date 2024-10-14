//
//  DDayCardView.swift
//  DearDay
//
//  Created by Jaehui Yu on 10/14/24.
//

import SwiftUI

struct DDayCardView: View {
    var imageName: String
    var title: String
    var date: String
    var dday: String
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 150)
                .cornerRadius(15)
                .overlay(
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.pink)
                            Text(title)
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        Text(date)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                        .padding(),
                    alignment: .topLeading
                )
            Text(dday)
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
                .padding()
        }
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

#Preview {
    ContentView()
}
