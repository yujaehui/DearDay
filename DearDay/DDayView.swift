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
            VStack {
                ZStack {
                    ScrollView {
                        VStack(spacing: 20) {
                            NavigationLink(destination: DDayDetailView()) {
                                DDayCardView(imageName: "firstImage", title: "혜성", date: "2024.09.22(일)", dday: "23일")
                            }
                        }
                        .padding()
                    }
                    
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button {
                                print("D-Day Add Button Tap")
                            } label: {
                                Image(systemName: "plus")
                                    .foregroundColor(.white)
                                    .font(.system(size: 24))
                                    .padding()
                                    .background(Color.red)
                                    .clipShape(Circle())
                                    .shadow(radius: 10)
                            }
                            .padding(.trailing, 16)
                            .padding(.bottom, 16)
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Dear Day")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        print("Setting Button Tap")
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.gray)
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
