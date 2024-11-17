//
//  Untitled.swift
//  Rashin_β
//
//  Created by 松浦充希 on 2024/10/06.
//


import SwiftUI
import MapKit



struct ScreenB: View {
    @Binding var isScreenBVisible: Bool
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("This is Screen B")
                    .font(.largeTitle)
                    .padding()
                
                Button(action: {
                    isScreenBVisible = false  // ボタンを押すとデフォルト画面に戻る
                }) {
                    Text("Back to Map View")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)  // 画面いっぱいの大きさに設定
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 10)
        }
        .edgesIgnoringSafeArea(.all)  // ステータスバーなども無視して全画面表示
    }
}

