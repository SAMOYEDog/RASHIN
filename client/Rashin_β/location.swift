import Foundation
import CoreLocation
import SwiftUI
import MapKit
import UserNotifications


class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager?
    private var networkManager = NetworkManager()
    
    @Published var latitude: Double?
    @Published var longitude: Double?
    @Published var message: String?
    @Published var selectedPlace: Place?
    @Published var inside: Bool = false
    @Published var pinCount: Int = 0
    @Published var combinedPinCount: Int = 0
    
    var minLat: Double
    var maxLat: Double
    var minLong: Double
    var maxLong: Double
    
    // Add properties for placesAfterDate and placesBeforeDate
    var placesAfterDate: [Place] = []
    var placesBeforeDate: [Place] = []
    var places_X_AfterDate: [Place] = []
    var places_X_BeforeDate: [Place] = []
    
    init(minLat: Double, maxLat: Double, minLong: Double, maxLong: Double) {
        self.minLat = minLat
        self.maxLat = maxLat
        self.minLong = minLong
        self.maxLong = maxLong
        super.init()
        setupLocationManager()
    }
    
    // Change the access level to internal
    func updateCombinedPinCount() {
        self.combinedPinCount = placesAfterDate.count + placesBeforeDate.count
    }
    
    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager!.delegate = self
        locationManager!.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager!.startUpdatingLocation()
            locationManager!.startMonitoringSignificantLocationChanges()
        } else {
            print("Location services are not enabled.")
        }
        
        Task {
            // Fetch locations after and before a specific date
            /*
            await networkManager.fetchLocationsAfterDate(minLat: minLat, minLong: minLong, maxLat: maxLat, maxLong: maxLong, dateString: "2024-08-11")
            self.placesAfterDate = networkManager.placesAfterDate
            
            await networkManager.fetchLocationsBeforeDate(minLat: minLat, minLong: minLong, maxLat: maxLat, maxLong: maxLong, dateString: "2024-08-11")
            self.placesBeforeDate = networkManager.placesBeforeDate
            */
            
            await networkManager.fetchLocationsBeforefromX(minLat: minLat, minLong: minLong, maxLat: maxLat, maxLong: maxLong, dateString: "24m")
            self.places_X_AfterDate
            await networkManager.fetchLocationsAfterfromX(minLat: minLat, minLong: minLong, maxLat: maxLat, maxLong: maxLong, dateString: "24m")
            updateCombinedPinCount()
            
            // Recalculate pin count based on current location
            guard let currentLocation = locationManager!.location?.coordinate else {
                print("Failed to get the current location.")
                return
            }
            updatePinCount(from: currentLocation)
            
            // Monitor regions for placesAfterDate
            for (index, place) in placesAfterDate.enumerated() {
                let circularRegion = CLCircularRegion(
                    center: place.coordinate,
                    radius: 2000,
                    identifier: "最近発生した事件です\(index + 1)"
                )
                
                if circularRegion.contains(currentLocation) {
                    scheduleNotification(title: "You're in the area!", body: "You've entered After Date Area \(index + 1).")
                    self.selectedPlace = place
                    self.inside = true
                    self.message = "You have entered the region: \(place.coordinate.latitude), \(place.coordinate.longitude)"
                }
                
                locationManager!.startMonitoring(for: circularRegion)
            }
            
            // Monitor regions for placesBeforeDate
            for (index, place) in placesBeforeDate.enumerated() {
                let circularRegion = CLCircularRegion(
                    center: place.coordinate,
                    radius: 2000,
                    identifier: "過去に発生した事件です\(index + 1)"
                )
                
                if circularRegion.contains(currentLocation) {
                    scheduleNotification(title: "You're in the area!", body: "You've entered Before Date Area \(index + 1).")
                    self.selectedPlace = place
                    self.inside = true
                    self.message = "You have entered the region: \(place.coordinate.latitude), \(place.coordinate.longitude)"
                }
                
                locationManager!.startMonitoring(for: circularRegion)
            }
            for (index, place) in places_X_AfterDate.enumerated() {
                let circularRegion = CLCircularRegion(
                    center: place.coordinate,
                    radius: 2000,
                    identifier: "最近発生した事件です\(index + 1)"
                )
                
                if circularRegion.contains(currentLocation) {
                    scheduleNotification(title: "You're in the area!", body: "You've entered Before Date Area \(index + 1).")
                    self.selectedPlace = place
                    self.inside = true
                    self.message = "You have entered the region: \(place.coordinate.latitude), \(place.coordinate.longitude)"
                }
                
                locationManager!.startMonitoring(for: circularRegion)
            }
            for (index, place) in places_X_BeforeDate.enumerated() {
                let circularRegion = CLCircularRegion(
                    center: place.coordinate,
                    radius: 2000,
                    identifier: "過去に発生した事件です\(index + 1)"
                )
                
                if circularRegion.contains(currentLocation) {
                    scheduleNotification(title: "You're in the area!", body: "You've entered Before Date Area \(index + 1).")
                    self.selectedPlace = place
                    self.inside = true
                    self.message = "You have entered the region: \(place.coordinate.latitude), \(place.coordinate.longitude)"
                }
                
                locationManager!.startMonitoring(for: circularRegion)
            }
        }
    }
    
    var currentLocation: CLLocationCoordinate2D? {
        return locationManager?.location?.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
        }
        
        // Recheck if the updated location is inside any region
        checkIfInsideRegion(location.coordinate)
        updatePinCount(from: location.coordinate)  // Update pin count when location updates
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let circularRegion = region as? CLCircularRegion else { return }
        
        let place: Place
        if circularRegion.identifier.starts(with: "AfterDateArea") {
            let placeIndex = Int(circularRegion.identifier.replacingOccurrences(of: "AfterDateArea", with: ""))! - 1
            place = placesAfterDate[placeIndex]
        } else {
            let placeIndex = Int(circularRegion.identifier.replacingOccurrences(of: "BeforeDateArea", with: ""))! - 1
            place = placesBeforeDate[placeIndex]
        }
        
        DispatchQueue.main.async {
            self.selectedPlace = place
            self.inside = true
            self.message = "You have entered the region: \(place.coordinate.latitude), \(place.coordinate.longitude)"
        }
        
        scheduleNotification(title: "You're in the area!", body: "You've entered \(region.identifier).")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        DispatchQueue.main.async {
            self.selectedPlace = nil
            self.inside = false
            self.message = "You have exited the region."
        }
    }
    
    private func checkIfInsideRegion(_ coordinate: CLLocationCoordinate2D) {
        for (index, place) in placesAfterDate.enumerated() {
            let circularRegion = CLCircularRegion(
                center: place.coordinate,
                radius: 2000,
                identifier: "AfterDateArea\(index + 1)"
            )
            
            if circularRegion.contains(coordinate) {
                self.selectedPlace = place
                self.inside = true
                self.message = "You have entered the region: \(place.coordinate.latitude), \(place.coordinate.longitude)"
                return
            }
        }
        
        for (index, place) in placesBeforeDate.enumerated() {
            let circularRegion = CLCircularRegion(
                center: place.coordinate,
                radius: 2000,
                identifier: "BeforeDateArea\(index + 1)"
            )
            
            if circularRegion.contains(coordinate) {
                self.selectedPlace = place
                self.inside = true
                self.message = "You have entered the region: \(place.coordinate.latitude), \(place.coordinate.longitude)"
                return
            }
        }
        
        for (index, place) in places_X_BeforeDate.enumerated() {
            let circularRegion = CLCircularRegion(
                center: place.coordinate,
                radius: 2000,
                identifier: "過去に事件が発生した場所です\(index + 1)"
            )
            
            if circularRegion.contains(coordinate) {
                self.selectedPlace = place
                self.inside = true
                self.message = "You have entered the region: \(place.coordinate.latitude), \(place.coordinate.longitude)"
                return
            }
        }
        
        for (index, place) in places_X_AfterDate.enumerated() {
            let circularRegion = CLCircularRegion(
                center: place.coordinate,
                radius: 2000,
                identifier: "24時間以内に事件が発生した場所です．注意してください．\(index + 1)"
            )
            
            if circularRegion.contains(coordinate) {
                self.selectedPlace = place
                self.inside = true
                self.message = "You have entered the region: \(place.coordinate.latitude), \(place.coordinate.longitude)"
                return
            }
        }
        
        // If not inside any region
        self.selectedPlace = nil
        self.inside = false
        self.message = nil
    }
    
    private func updatePinCount(from coordinate: CLLocationCoordinate2D) {
        let currentLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        // Count pins within 10km radius
        let allPins = placesAfterDate + placesBeforeDate
        let filteredPins = allPins.filter { place in
            let pinLocation = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            return currentLocation.distance(from: pinLocation) <= 2000// 半径10km以内
        }
        
        // Update the pin count
        pinCount = filteredPins.count
    }
    
    func scheduleNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
}
