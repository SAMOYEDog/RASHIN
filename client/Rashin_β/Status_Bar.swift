//
//  Status_Bar.swift
//  Rashin_β
//
//  Created by 松浦充希 on 2024/10/07.
//

import SwiftUI
import MapKit


/*
struct StatusBar: View {
    @Binding var pinCount: Int  // LocationManagerから受け取る
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                ZStack {
                    // グラデーション付きのバー
                    HStack{
                        Rectangle()
                            .fill(gradient_1(for: pinCount)) // pinCountに応じたグラデーション
                            .frame(width: 140, height: 30) // 長い棒のバー
                            .cornerRadius(16)
                        
                        Rectangle()
                            .fill(gradient_2(for: pinCount)) // pinCountに応じたグラデーション
                            .frame(width: 140, height: 30) // 長い棒のバー
                            .cornerRadius(16)

                        
                    }
                    
                    // 丸いオブジェクトの配置
                    HStack(spacing: 105) {
                        Circle()
                            .fill(pinCount >= 1 ? Color.green : Color.gray)
                            .frame(width: 30, height: 30)
                        
                        Circle()
                            .fill(pinCount >= 3 ? Color.yellow : Color.gray)
                            .frame(width: 30, height: 30)
                        
                        Circle()
                            .fill(pinCount >= 5 ? Color.red : Color.gray)
                            .frame(width: 30, height: 30)
                    }
                }
                .padding()

                    
                    // ピン数に基づくテキスト
                    Text(getText(for: pinCount))
                        .font(Font.custom("Noto Sans", size: 17).weight(.semibold))
                        .lineSpacing(22)
                        .foregroundColor(Color(red: 0.39, green: 0.39, blue: 0.39))
                        .offset(x: 0.50, y: 32.50)
                }
                .frame(width: 339, height: 34)
            }
            .padding(EdgeInsets(top: 13, leading: 12, bottom: 13, trailing: 12))
            .frame(width: 364, height: 98)
            .background(Color.white.opacity(0.9))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.14), lineWidth: 0.50)
            )
            .onAppear {
                print("Current pinCount: \(pinCount)")  // pinCountを表示
            }
        }
    }
    
    // pinCountに基づいて位置を計算する関数
    private func calculatePosition(pinCount: Int) -> CGFloat {
        let barWidth: CGFloat = 339  // バーの幅
        let leftEdge: CGFloat = -barWidth / 2  // 左端の位置
        let rightEdge: CGFloat = barWidth / 2  // 右端の位置
        
        let clampedPinCount = min(max(pinCount, 0), 5)  // 0から5に制限
        let position = CGFloat(clampedPinCount) / 5 * (rightEdge - leftEdge) + leftEdge
        
        return position
    }
    
    // pinCountに基づいてテキストを取得する関数
    private func getText(for pinCount: Int) -> String {
        switch pinCount {
        case 0:
            return "周辺は安全地域です"
        case 1, 2:
            return "過去に事件が発生した地域です．注意してください"
        case 3, 4, 5:
            return "過去に多くの事件が発生した地域です．"
        default:
            return "過去に多くの事件が発生した地域です．"
        }
    }
private func gradient_1(for pinCount: Int) -> LinearGradient {
    switch pinCount {
    case 0:
        return LinearGradient(
            gradient: Gradient(colors: [Color.green, Color.gray]),
            startPoint: .leading,
            endPoint: .trailing
        )
    case 1...5:
        return LinearGradient(
            gradient: Gradient(colors: [Color.green, Color.yellow]),
            startPoint: .leading,
            endPoint: .trailing
        )
    default:
        return LinearGradient(
            gradient: Gradient(colors: [Color.green, Color.yellow]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}
private func gradient_2(for pinCount: Int) -> LinearGradient {
    switch pinCount {
    case 0...2:
        return LinearGradient(
            gradient: Gradient(colors: [Color.gray, Color.gray]),
            startPoint: .leading,
            endPoint: .trailing
        )
    case 3...5:
        return LinearGradient(
            gradient: Gradient(colors: [Color.yellow, Color.red]),
            startPoint: .leading,
            endPoint: .trailing
        )
    default:
        return LinearGradient(
            gradient: Gradient(colors: [Color.yellow, Color.red]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}



*/


struct StatusBar: View {
    @Binding var pinCount: Int  // LocationManagerから受け取る
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                // グラデーション付きのバー
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 339, height: 8)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0, green: 0.6, blue: 0),
                                Color(red: 0.9, green: 0.9, blue: 0.2),
                                Color(red: 0.8, green: 0.2, blue: 0.2)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                
                HStack(spacing: 70) { // 丸の間隔を調整
                    ForEach(0..<5) { index in
                        ZStack {
                            // ベースの小さい丸
                            Circle()
                                .fill(Color.black)
                                .frame(width: 5, height: 5)
                            
                            // 大きくなる丸（必要な場合にのみ表示）
                            if index == clampedPinCount {
                                Circle()
                                    .fill(Color.black)
                                    .frame(width: 15, height: 15)
                                Circle()
                                    .fill(Color.gray.opacity(0.5))
                                    .frame(width: 40, height: 40)
                            }
                        }
                        .frame(width: 13, height: 13) // 固定サイズを設定
                    }
                }
                
                // ピン数に基づくテキスト
                /*
                Text(getText(for: pinCount))
                    .font(Font.custom("Noto Sans", size: 17).weight(.semibold))
                    .lineSpacing(22)
                    .foregroundColor(Color(red: 0.39, green: 0.39, blue: 0.39))
                    .offset(x: 0.50, y: 32.50)
                 */
            }
            .frame(width: 339, height: 34)
        }
        .padding(EdgeInsets(top: 13, leading: 12, bottom: 13, trailing: 12))
        .frame(width: 370, height: 60)
        .background(Color.white.opacity(0.9))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.14), lineWidth: 0.50)
        )
        .onAppear {
            print("Current pinCount: \(pinCount)")  // pinCountを表示
        }
    }
    
    // pinCountに基づいてテキストを取得する関数
    private func getText(for pinCount: Int) -> String {
        switch pinCount {
        case 0:
            return "周辺は安全地域です"
        case 1, 2:
            return "過去に事件が発生した地域です．注意してください"
        case 3, 4, 5:
            return "過去に多くの事件が発生した地域です．"
        default:
            return "過去に多くの事件が発生した地域です．"
        }
    }
    
    private var clampedPinCount: Int {
        min(max(pinCount, 0), 4)
    }

}
