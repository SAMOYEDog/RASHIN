import SwiftUI
import MapKit
import CoreLocation
import UserNotifications
import SlideOverCard

/*注意点
 
 構造体がかなり複雑になってきてるから注意
 
 今contentviewで
 Mapview
 StatusBar
 裏にある設定画面
 の三つを用意してるけど，Mapview中にNavigationBarがあるので，NavigationBarの変数を変えて，状態を変異させたいときは，Mapviewに渡す変数も用意しないといけない．例えば，NavigationのisScreenBVisibleは，Navigationの中で変えた場合は，MapViewの定義で    @Binding var isScreenBVisible: Bool // Bindingを受け取る
のようにし，値をBindingで受け取る必要がある．そうすれば，@stateで常にその変数を監視することができる．

*/

struct ContentView: View {
    @ObservedObject var networkManager = NetworkManager()
    @ObservedObject var locationManager = LocationManager(minLat: 35.0, maxLat: 36.0, minLong: 139.0, maxLong: 140.0)
    @State private var selectedPlace: Place? = nil
    //@State private var coordinateRegion = MKCoordinateRegion()
    @State private var coordinateRegion: MKCoordinateRegion
    @State private var position: CardPosition = .bottom
    @State private var isScreenBVisible = false
    @State private var mkAnnotations: [MKPointAnnotation] = [] // MKPointAnnotationの配列
    @State private var isShareActive = false // Shareボタンが押されたかを管理
    @State private var pins: [MKPointAnnotation] = []  // ピンの配列
    @State private var currentScreen = 1  // 現在表示している画面を表す状態変数
    @State private var scale: CGFloat = 1.0 // 拡大縮小のスケール
    init() {
        // ここで初期位置を設定
        let initialLocation = CLLocationCoordinate2D(latitude: 35.0, longitude: 139.0) // 例えば東京の位置
        _coordinateRegion = State(initialValue: MKCoordinateRegion(center: initialLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))
    }



    

    
    var body: some View {
        ZStack {
            
            // Map View with annotations and overlays
            ZStack {
                
                if currentScreen == 1 {
                    MapViewWrapper(
                        networkManager: networkManager,
                        locationManager: locationManager,
                        selectedPlace: $selectedPlace,
                        coordinateRegion: $coordinateRegion,
                        isScreenBVisible: $isScreenBVisible
                    )
                    .edgesIgnoringSafeArea(.top)
                    .scaleEffect(scale)
                }
                
            
                StatusBar(pinCount: $locationManager.pinCount)
                    .padding(.bottom, 630)
                    //.zIndex(1)
                // VerticalButtonStackを右下に配置
                VerticalButtonStack(region: $coordinateRegion)
                    .padding(.bottom,330) // 右下の余白

                if currentScreen == 2 {
                    
                    ScreenB(isScreenBVisible: $isScreenBVisible)
                    //.zIndex(2)
                        .transition(.move(edge: .bottom))  // 下から表示されるアニメーション
                        .animation(.easeInOut, value: isScreenBVisible)  // アニメーションを追加
                }
                if currentScreen == 3 {
                    PinMapView(coordinateRegion: $coordinateRegion, pins: $pins)
                        .edgesIgnoringSafeArea(.all)  // 全画面表示
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    //.zIndex(2)
                }


                
                // Slide Over Card to show place details
                SlideOverCardView(position: $position, selectedPlace: $selectedPlace)
                
                
                

                if isShareActive {
                    PinMapView(coordinateRegion: $coordinateRegion, pins: $pins)
                        .edgesIgnoringSafeArea(.all)  // 全画面表示
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        //.zIndex(2)
                }
                NavigationBar( currentScreen: $currentScreen)
                    .padding(.top, 710)
                    .zIndex(3)
            }
            .onChange(of: selectedPlace) { newValue in
                if newValue != nil {
                    position = .top
                } else {
                    position = .bottom
                }
            }

        }
    }
}
// nil を置き換えるための Binding 拡張
extension Binding {
    init(_ source: Binding<Value?>, replacingNilWith defaultValue: Value) {
        self.init(get: { source.wrappedValue ?? defaultValue }, set: { source.wrappedValue = $0 })
    }
}

// プレビュー用
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView() // locationManagerの引数を渡す必要なし
    }
}

