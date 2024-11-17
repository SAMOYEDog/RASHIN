//
//  Share_page.swift
//  Rashin_β
//
//  Created by 松浦充希 on 2024/10/06.
//
/*
import SwiftUI
import MapKit


struct IdentifiablePointAnnotation: Identifiable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
    var title: String?
}


// MKPointAnnotationをIdentifiablePointAnnotationに変換する関数
func convertToIdentifiable(_ mkAnnotations: [MKPointAnnotation]) -> [IdentifiablePointAnnotation] {
    return mkAnnotations.map { mkAnnotation in
        IdentifiablePointAnnotation(
            coordinate: mkAnnotation.coordinate,
            title: mkAnnotation.title ?? ""
        )
    }
}

// ピンを管理するMapView
struct PinMapView: UIViewRepresentable {
    @Binding var annotations: [IdentifiablePointAnnotation]
    @Binding var mkAnnotations: [MKPointAnnotation]
    var allowTap: Bool // タップを有効にするフラグ
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: PinMapView
        
        init(_ parent: PinMapView) {
            self.parent = parent
        }
        
        @objc func handleMapTap(_ gestureRecognizer: UITapGestureRecognizer) {
            print("Tap detected, allowTap: \(parent.allowTap)")
            guard parent.allowTap else {
                print("Tap disabled") // ここでallowTapがfalseで処理が中断されている
                return
            }
            let mapView = gestureRecognizer.view as! MKMapView
            let tapPoint = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(tapPoint, toCoordinateFrom: mapView)
            
            // タップした場所にピンを立てる
            let newAnnotation = MKPointAnnotation()
            newAnnotation.coordinate = coordinate
            newAnnotation.title = "New Pin"
            parent.mkAnnotations.append(newAnnotation)
            print("Pin added at: \(coordinate)")
        }
    }

    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        // タップジェスチャーを追加
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleMapTap(_:)))
        mapView.addGestureRecognizer(tapGesture)
        
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)
        
        for annotation in annotations {
            let mkAnnotation = MKPointAnnotation()
            mkAnnotation.coordinate = annotation.coordinate
            mkAnnotation.title = annotation.title
            uiView.addAnnotation(mkAnnotation)
        }
    }
}
*/

import SwiftUI
import MapKit

struct PinMapView: UIViewRepresentable {
    @Binding var coordinateRegion: MKCoordinateRegion
    @Binding var pins: [MKPointAnnotation]  // ピンを管理する配列
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "Pin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true  // タップ時にコールアウトを表示
            annotationView?.pinTintColor = .red    // ピンの色を変更
            
            // 詳細ボタンを追加
            let detailButton = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = detailButton
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }

    
    // MapViewを作成
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator  // デリゲート設定
        mapView.addGestureRecognizer(UILongPressGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.addPin(_:))))  // 長押しジェスチャーでピンを追加
        mapView.setRegion(coordinateRegion, animated: true)
        return mapView
    }
    
    // MapViewの更新
    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.addAnnotations(pins)  // 新しいピンを追加
        mapView.setRegion(coordinateRegion, animated: true)  // 現在地に基づいて更新

    }
    
    // コーディネータを使用して、MapViewの操作を管理
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // コーディネータクラス
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: PinMapView
        var annotations: [CustomAnnotation] = []  // CustomAnnotation型の配列を用意
        
        init(_ parent: PinMapView) {
            self.parent = parent
        }
        
        @objc func addPin(_ gestureRecognizer: UILongPressGestureRecognizer) {
            guard gestureRecognizer.state == .began else { return }
            
            let location = gestureRecognizer.location(in: gestureRecognizer.view)
            if let mapView = gestureRecognizer.view as? MKMapView {
                let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
                
                // 確認のアラートを表示
                showPinConfirmation(at: coordinate, on: mapView)
            }
        }
        
        // ピンを追加するかどうかの確認アラートを表示
        private func showPinConfirmation(at coordinate: CLLocationCoordinate2D, on mapView: MKMapView) {
            let alert = UIAlertController(title: "確認", message: "ここにピンを立てますか？", preferredStyle: .alert)
            
            // "はい" を選択した場合、情報を入力するアラートを表示
            alert.addAction(UIAlertAction(title: "はい", style: .default) { _ in
                self.showInformationInput(at: coordinate, on: mapView)
            })
            
            // "いいえ" を選択した場合はキャンセル
            alert.addAction(UIAlertAction(title: "いいえ", style: .cancel, handler: nil))
            
            // アラートを表示
            if let viewController = UIApplication.shared.windows.first?.rootViewController {
                viewController.present(alert, animated: true, completion: nil)
            }
        }
        
        // 情報入力フォームを表示するメソッド
        private func showInformationInput(at coordinate: CLLocationCoordinate2D, on mapView: MKMapView) {
            let inputAlert = UIAlertController(title: "情報入力", message: "事件名と発生日時を入力してください", preferredStyle: .alert)
            
            // 事件名のテキストフィールド
            inputAlert.addTextField { textField in
                textField.placeholder = "事件名"
            }
            
            // 発生日時のテキストフィールド
            inputAlert.addTextField { textField in
                textField.placeholder = "発生日時 (例: YYYY-MM-DD)"
            }
            
            // "OK"ボタンが押された場合
            inputAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                let eventName = inputAlert.textFields?[0].text ?? "No Title"
                let eventDate = inputAlert.textFields?[1].text ?? "No Date"
                
                // ピンを作成し、情報を追加
                let annotation = CustomAnnotation()
                annotation.coordinate = coordinate
                annotation.title = eventName
                annotation.subtitle = eventDate
                
                // ピンを配列に追加
                self.annotations.append(annotation)
                mapView.addAnnotation(annotation)  // 地図にピンを追加
            })
            
            // "キャンセル"ボタンが押された場合
            inputAlert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
            
            // アラートを表示
            if let viewController = UIApplication.shared.windows.first?.rootViewController {
                viewController.present(inputAlert, animated: true, completion: nil)
            }
        }
    }
    
    // CustomAnnotationクラス (MKPointAnnotationを拡張して事件名と発生日時を持たせる)
    class CustomAnnotation: MKPointAnnotation {
        var eventName: String?
        var eventDate: String?
    }



}


