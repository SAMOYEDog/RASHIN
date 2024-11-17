//
//  Map_page.swift
//  Rashin_β
//
//  Created by 松浦充希 on 2024/10/06.
//

import SwiftUI
import MapKit
import CoreLocation
import UserNotifications
import SlideOverCard


class CustomPointAnnotation: MKPointAnnotation {
    var url: String
    var timestamptz: String
    var color: UIColor
    
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?, url: String, timestamptz: String, color: UIColor) {
        self.url = url
        self.timestamptz = timestamptz
        self.color = color
        super.init()
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}



struct NavigationBar: View {
    @State private var annotations: [MKPointAnnotation] = [] // ピンの配列
    @State private var showGuide: Bool = false // ガイド表示の状態を管理
    @State private var didTapMap: Bool = false // マップがタップされたかどうか
    @State private var tappedCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude:0, longitude: 0) // タップした位置
    @State private var isPromptVisible = false // ガイドの表示状態
    @State private var mkAnnotations: [MKPointAnnotation] = [] // MKPointAnnotationの配列
    @State private var isPinMapViewActive = false // PinMapViewを表示するためのフラグ
    @State private var isButtonPressed = false  // ボタンの状態を管理するための変数
    @Binding var currentScreen: Int  // 親から受け取った状態をバインディング
    @State private var scale: CGFloat = 1.0 // 拡大縮小のスケール
    @State private var maxScale: CGFloat = 2.0 // 最大拡大率
    @State private var minScale: CGFloat = 0.5 // 最小縮小率


    
    var body: some View {
        VStack {
            
            Spacer() // 上部にスペースを追加
            
            // 既存のボタンエリアを下部に配置
            HStack(alignment: .top, spacing: 8) {
                VStack(spacing: 4) {
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            Button(action: {
                                currentScreen = 1 // isScreenBVisibleをfalseに設定
                            }) {
                                Image(systemName: "house")
                                    .frame(width: 24, height: 24)
                                    .padding()
                                    .foregroundColor(.black)
                                    .clipShape(Circle())
                            }
                        }
                        .padding(EdgeInsets(top: 4, leading: 20, bottom: 0, trailing: 20))
                        .frame(width: 64, height: 32)
                    }
                    Text("Home")
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20))
                        .font(Font.custom("Roboto", size: 12).weight(.semibold))
                        .tracking(0.50)
                        .lineSpacing(16)
                        .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.13))
                }
                .padding(EdgeInsets(top: 12, leading: 0, bottom: 16, trailing: 0))
                .frame(maxWidth: .infinity)
                
                VStack {
                    // Shareボタン
                    Button(action: {
                        // ボタンを押した際の処理
                        currentScreen = 3
                        print("Share button tapped, tap on map to add a pin.")
                    }) {
                        VStack(spacing: 4) {
                            HStack(spacing: 0) {
                                HStack(spacing: 10) {
                                    ZStack {
                                        Image(systemName: "mappin.and.ellipse")
                                    }
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.black)
                                }
                                .padding(EdgeInsets(top: 4, leading: 20, bottom: 0, trailing: 20))
                                .frame(width: 64, height: 32)
                            }
                            .frame(width: 32)
                            .cornerRadius(16)
                            Text("Share")
                                .font(Font.custom("Roboto", size: 12).weight(.medium))
                                .tracking(0.50)
                                .lineSpacing(16)
                                .foregroundColor(Color(red: 0.29, green: 0.27, blue: 0.31))
                        }
                        .padding(EdgeInsets(top: 12, leading: 0, bottom: 16, trailing: 0))
                        .frame(maxWidth: .infinity)
                    }
                }
                
                VStack(spacing: 4) {
                    HStack(spacing: 0) {
                        HStack(spacing: 10) {
                            ZStack {
                                Button(action: {
                                    currentScreen = 2
                                }) {
                                    Image(systemName: "gear")
                                        .frame(width: 24, height: 24)
                                        .padding()
                                        .foregroundColor(.black)
                                        .clipShape(Circle())
                                }
                            }
                            .frame(width: 24, height: 24)
                        }
                        .padding(EdgeInsets(top: 4, leading: 20, bottom: 0, trailing: 20))
                        .frame(width: 64, height: 32)
                    }
                    
                    Text("Setting")
                        .font(Font.custom("Roboto", size: 12).weight(.medium))
                        .tracking(0.50)
                        .lineSpacing(16)
                        .foregroundColor(Color(red: 0.29, green: 0.27, blue: 0.31))
                }
                .padding(EdgeInsets(top: 12, leading: 0, bottom: 16, trailing: 0))
                .frame(maxWidth: .infinity)
            }
            .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
            .frame(width: 412, height: 80)
            .background(Color(red: 0.95, green: 0.93, blue: 0.97))
            

        }
        .frame(maxHeight: .infinity) // 高さをフルに使用
    }
        
    private func showPinConfirmation() {
        let alert = UIAlertController(title: "確認", message: "ここにピンを立てますか？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "はい", style: .default) { _ in
            let newAnnotation = MKPointAnnotation()
            newAnnotation.coordinate = tappedCoordinate // タップした位置に新しいピンを立てる
            newAnnotation.title = "New Pin" // ピンのタイトル
            annotations.append(newAnnotation) // 配列にピンを追加
        })
        alert.addAction(UIAlertAction(title: "いいえ", style: .cancel, handler: nil))
        // アラートを表示する
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
}

struct MapView: UIViewRepresentable {
    @ObservedObject var networkManager: NetworkManager
    @Binding var selectedPlace: Place?
    @Binding var coordinateRegion: MKCoordinateRegion // Bindingを追加
    @Binding var zoomLevel: Double
    // パブリック初期化子を追加
    init(networkManager: NetworkManager, selectedPlace: Binding<Place?>, coordinateRegion: Binding<MKCoordinateRegion>, zoomLevel: Binding<Double>) {
        self.networkManager = networkManager
        self._selectedPlace = selectedPlace
        self._coordinateRegion = coordinateRegion
        self._zoomLevel = zoomLevel
    }


    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.delegate = context.coordinator
        context.coordinator.mapView = mapView
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.mapType = .mutedStandard

        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        if let selectedPlace = selectedPlace {
            let region = MKCoordinateRegion(
                center: selectedPlace.coordinate,
                span: mapView.region.span // 現在のズームレベルを保持するため
            )
            
            // selectedPlace の変更時のみ地図を移動
            if mapView.region.center.latitude != region.center.latitude ||
                mapView.region.center.longitude != region.center.longitude ||
                mapView.region.span.latitudeDelta != region.span.latitudeDelta ||
                mapView.region.span.longitudeDelta != region.span.longitudeDelta {
                mapView.setRegion(region, animated: true)
            }
        } else {
            // selectedPlace が nil の場合は現在地を表示
            if mapView.userLocation.location != nil {
                let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: mapView.region.span)
                mapView.setRegion(region, animated: true)
            }
        }
        // 既存の注釈やオーバーレイを保持して、変わった場合のみ更新
        if !mapView.annotations.isEmpty {
            mapView.removeAnnotations(mapView.annotations)
        }
        if !mapView.overlays.isEmpty {
            mapView.removeOverlays(mapView.overlays)
        }
        // ズームレベルだけを調整
        if context.coordinator.lastZoomLevel != zoomLevel {
            mapView.camera.altitude = 10000 / zoomLevel
            context.coordinator.lastZoomLevel = zoomLevel
        }
        
        for place in networkManager.placesAfterDate {
            let annotation = CustomPointAnnotation(
                coordinate: place.coordinate,
                title: place.name,
                subtitle: place.incident,
                url: place.url,
                timestamptz: place.timestamptz,
                color: .purple
            )
            mapView.addAnnotation(annotation)
            
            let circle = MKCircle(center: place.coordinate, radius: 2000)
            mapView.addOverlay(circle)
        }
        
        for place in networkManager.placesBeforeDate {
            let annotation = CustomPointAnnotation(
                coordinate: place.coordinate,
                title: place.name,
                subtitle: place.incident,
                url: place.url,
                timestamptz: place.timestamptz,
                color: .blue
            )
            mapView.addAnnotation(annotation)
            
            let circle = MKCircle(center: place.coordinate, radius: 2000)
            mapView.addOverlay(circle)
        }
        
        for place in networkManager.places_X_BeforeDate {
            let annotation = CustomPointAnnotation(
                coordinate: place.coordinate,
                title: place.name,
                subtitle: place.incident,
                url: place.url,
                timestamptz: place.timestamptz,
                color: .black
            )
            mapView.addAnnotation(annotation)
            
            let circle = MKCircle(center: place.coordinate, radius: 1600)
            mapView.addOverlay(circle)
        }
        
        for place in networkManager.places_X_AfterDate {
            let annotation = CustomPointAnnotation(
                coordinate: place.coordinate,
                title: place.name,
                subtitle: place.incident,
                url: place.url,
                timestamptz: place.timestamptz,
                color: .red
            )
            mapView.addAnnotation(annotation)
            
            let circle = MKCircle(center: place.coordinate, radius: 800)
            mapView.addOverlay(circle)
        }
         

    }
    private func addAnnotationAndOverlay(for place: Place, on mapView: MKMapView, color: UIColor) {
        let annotation = CustomPointAnnotation(
            coordinate: place.coordinate,
            title: place.name,
            subtitle: place.incident,
            url: place.url,
            timestamptz: place.timestamptz,
            color: color
        )
        mapView.addAnnotation(annotation)
        
        let circle = MKCircle(center: place.coordinate, radius: 2000)
        mapView.addOverlay(circle)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        var mapView: MKMapView?
        var lastZoomLevel: Double = 1.0  // 初期ズームレベル

        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let customAnnotation = annotation as? CustomPointAnnotation else {
                return nil
            }
            
            
            let annotationView = MKMarkerAnnotationView(annotation: customAnnotation, reuseIdentifier: "place")
            annotationView.canShowCallout = true
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationView.markerTintColor = customAnnotation.color
            annotationView.clusteringIdentifier = nil
            //annotationView.displayPriority = .required

            
            return annotationView
        }
         
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            guard let customAnnotation = view.annotation as? CustomPointAnnotation else {
                return
            }
            
            parent.selectedPlace = Place(
                coordinate: customAnnotation.coordinate,
                name: customAnnotation.title ?? "",
                incident: customAnnotation.subtitle ?? "",
                url: customAnnotation.url,
                timestamptz: customAnnotation.timestamptz
            )
            
            print("Selected Place: \(String(describing: parent.selectedPlace))")
        }
         
        
        //ここで円のプロパティを変更する
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let circleOverlay = overlay as? MKCircle {
                let renderer = MKCircleRenderer(circle: circleOverlay)
                renderer.fillColor = circleOverlay.title == "afterDate" ? UIColor.red.withAlphaComponent(0.1) : UIColor.red.withAlphaComponent(0.15)
                renderer.strokeColor = nil
                renderer.lineWidth = 0
                return renderer
            }
            return MKOverlayRenderer()
        }
    }
}

// 1. MapViewWrapper: マップ表示を担当する構造体
struct MapViewWrapper: View {
    @ObservedObject var networkManager: NetworkManager
    @ObservedObject var locationManager: LocationManager
    @Binding var selectedPlace: Place?
    @Binding var coordinateRegion: MKCoordinateRegion
    @State private var isShareActive = false  // Shareボタンが押されたかの状態を管理
    @Binding var isScreenBVisible: Bool // Bindingを受け取る
    @State private var mkAnnotations: [MKPointAnnotation] = []
    @State private var zoomLevel: Double = 1.0
    @State private var hasCenteredMapOnUser = false  // 初期設定かどうかのフラグ


    
    var body: some View {
        ZStack {
            MapView(networkManager: networkManager, selectedPlace: $selectedPlace, coordinateRegion: $coordinateRegion, zoomLevel: $zoomLevel)


            
        }
        .onAppear {
            if !hasCenteredMapOnUser, let userLocation = locationManager.currentLocation {
                coordinateRegion = MKCoordinateRegion(
                    center: userLocation,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
                hasCenteredMapOnUser = true  // フラグを立てて再設定を防ぐ
            }
            Task {
                if let userLocation = locationManager.currentLocation {
                    let radius: CLLocationDistance = 100000000000  // 自分の位置からどこまで表示するか
                    let radius_pin: CLLocationDistance = 2000  // 自分の位置からどこまで表示するか

                    let minLat = userLocation.latitude - (radius / 111320)
                    let maxLat = userLocation.latitude + (radius / 111320)
                    let minLong = userLocation.longitude - (radius / (111320 * cos(userLocation.latitude * .pi / 180)))
                    let maxLong = userLocation.longitude + (radius / (111320 * cos(userLocation.latitude * .pi / 180)))
                    
                    coordinateRegion = MKCoordinateRegion(
                        center: userLocation,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                    
                    await networkManager.fetchLocationsBeforefromX(minLat: minLat, minLong: minLong, maxLat: maxLat, maxLong: maxLong, dateString: "24m")
                    await networkManager.fetchLocationsAfterfromX(minLat: minLat, minLong: minLong, maxLat: maxLat, maxLong: maxLong, dateString: "24m")
                    
                    locationManager.placesAfterDate = networkManager.places_X_AfterDate
                    locationManager.placesBeforeDate = networkManager.places_X_BeforeDate
                    locationManager.updateCombinedPinCount()
                }
            }
        }
    }
}
struct SlideOverCardView: View {
    @Binding var position: CardPosition
    @Binding var selectedPlace: Place?
    
    var body: some View {
        SlideOverCard($position) {
            VStack(alignment: .leading) { // VStack に alignment: .leading を指定
                if let selectedPlace = selectedPlace {
                    Text("\(selectedPlace.name)")
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 10)  // 上部の余白を調整
                    
                    if let formattedDate = formatDate(selectedPlace.timestamptz) {
                        Text("事件発生日時：\(formattedDate)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 10)  // 上部の余白を調整

                            .padding(.leading, 25) // 左の余白
                        
                    }
                    Text("情報元：")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 25) // 左の余白
                    
                    if let url = URL(string: selectedPlace.url) {
                        Text(selectedPlace.url)
                            .foregroundColor(.blue)
                            .underline()
                            .onTapGesture {
                                UIApplication.shared.open(url)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 25) // 左の余白
                    }
                } else {
                    Text("No Place Selected")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 10)  // 上部の余白を調整
                }
            }
            .padding(.horizontal, 25) // 左右の余白を調整
            .padding(.top, 0) // 上部の余白を調整
        }
        .frame(height: 300)
        .animation(.default, value: position)
        .offset(y: 175)  // 位置の調整
    }
    
    func formatDate(_ timestamp: String) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let date = formatter.date(from: timestamp) {
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.string(from: date)
        }
        return nil
    }
}

