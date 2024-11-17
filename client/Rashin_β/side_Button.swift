//
//  side_Button.swift
//  Rashin_β
//
//  Created by 松浦充希 on 2024/11/02.
//

import SwiftUI
import MapKit
import CoreLocation



struct IdentifiablePointAnnotation: Identifiable {
    let id = UUID()
    let annotation: MKPointAnnotation
}
struct VerticalButtonStack: View {
    @StateObject var networkManager = NetworkManager()
    @StateObject private var locationManager = LocationManager(
        minLat: 35.0,   // 適切な最小緯度を指定
        maxLat: 36.0,   // 適切な最大緯度を指定
        minLong: 139.0, // 適切な最小経度を指定
        maxLong: 140.0  // 適切な最大経度を指定
    )
    @State private var coordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 36.111152, longitude: 140.094558), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))

    @Binding var region: MKCoordinateRegion  // Bindingとして受け取る
    @State private var locations = [IdentifiablePointAnnotation]()
    @State private var hasInitializedRegion = false // 初期化フラグ

    
    var body: some View {
        VStack {
            Spacer()  // 画面下部までスペースを広げる
            
            HStack {
                Spacer()  // 画面右端までスペースを広げる
                
                VStack {
                    Button(action: {
                        let span = MKCoordinateSpan(latitudeDelta: region.span.latitudeDelta / 2.0, longitudeDelta: region.span.longitudeDelta / 2.0)
                        region = MKCoordinateRegion(center: region.center, span: span)
                    }) {
                        Text("+")
                    }
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44) // 同じフレームサイズ

                    .font(.title)
                    .clipShape(Circle())
                    .padding(.bottom, 10)  // 上下ボタンの間隔を空ける
                    
                    Button(action: {
                        let span = MKCoordinateSpan(latitudeDelta: region.span.latitudeDelta * 2.0, longitudeDelta: region.span.longitudeDelta * 2.0)
                        region = MKCoordinateRegion(center: region.center, span: span)
                    }) {
                        Text("-")
                    }
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44) // 同じフレームサイズ

                    .font(.title)
                    .clipShape(Circle())
                    .padding(.bottom, 30)  // 上下ボタンの間隔を空ける
                    
                    Button(action: {
                        let span = MKCoordinateSpan(latitudeDelta: region.span.latitudeDelta * 1.01, longitudeDelta: region.span.longitudeDelta * 1.01)
                        region = MKCoordinateRegion(center: region.center, span: span)
                    }) {
                        Image(systemName: "location.fill") // 現在地シンボル
                            .resizable()
                            .frame(width: 24, height: 24) // アイコンサイズ
                            .foregroundColor(.blue) // アイコンカラー
                            .padding(20) // アイコン周りのスペース
                            .background(Color.white) // 白い背景
                            .clipShape(Circle()) // 背景を円形にクリップ
                    }
                }
                .padding()  // ボタン全体の余白
            }
            .padding(.bottom,-300)  // ボタンを下端に寄せるためのスペーシング


        }

        .onAppear {
            if !hasInitializedRegion, let userLocation = locationManager.currentLocation {
                // ユーザーの現在地に基づいて地域を更新
                region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                hasInitializedRegion = true // 初期化済みとしてマーク
            }
        }

    }
}
