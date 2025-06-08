import Foundation
import Supabase
import CoreLocation
import SwiftUI
import MapKit



struct Place: Identifiable,Equatable {
    let coordinate: CLLocationCoordinate2D
    let name: String
    let incident: String
    let id = UUID() // ランダムなidを付ける
    let url: String
    let timestamptz: String
    static func == (lhs: Place, rhs: Place) -> Bool {
        return lhs.id == rhs.id
    }
}

// Response structure for the fetched data
struct Response: Codable {
    let id: String
    let description: String
    let lat: Double
    let long: Double
    let url: String
    let timestamptz: String // Timestamp with time zone
    
}

class NetworkManager: ObservableObject {
    @Published var placesAfterDate: [Place] = []
    @Published var placesBeforeDate: [Place] = []
    @Published var places_X_BeforeDate: [Place] = []
    @Published var places_X_AfterDate: [Place] = []
    @Published var userLocation: CLLocation?

    
    private var client: SupabaseClient
    
    init() {
        client = SupabaseClient(
            supabaseURL: URL(string: "")!,
            supabaseKey: ""
        )
    }
    
    func fetchLocationsAfterDate(minLat: Double, minLong: Double, maxLat: Double, maxLong: Double, dateString: String) async {
        
        do {
            let responses: [Response] = try await client.rpc(
                "locations_in_view_news_after_date",
                params: [
                    "min_lat": minLat,
                    "min_long": minLong,
                    "max_lat": maxLat,
                    "max_long": maxLong,
                ]
            ).execute().value
            
            DispatchQueue.main.async {
                self.placesAfterDate = responses.map { response in
                    Place(
                        coordinate: CLLocationCoordinate2D(latitude: response.lat, longitude: response.long),
                        name: response.description,
                        incident: "News Incident after \(dateString)", // Modify as needed
                        url: response.url,
                        timestamptz: response.timestamptz
                    )
                }
                
                // Debug: Print the fetched places
                for place in self.placesAfterDate {
                    print("ID: \(place.id)")
                    print("Latitude: \(place.coordinate.latitude)")
                    print("Longitude: \(place.coordinate.longitude)")
                    print("Name: \(place.name)")
                    print("Incident: \(place.incident)")
                    print("URL: \(place.url)")
                    print("Timestamp: \(place.timestamptz)")
                    print("-----------")
                }
            }
        } catch {
            print("Error fetching locations after date: \(error.localizedDescription)")
        }
    }

    
    func fetchLocationsBeforeDate(minLat: Double, minLong: Double, maxLat: Double, maxLong: Double, dateString: String) async {
        do {
            let responses: [Response] = try await client.rpc(
                "locations_in_view_news_before_date",
                params: [
                    "min_lat": minLat,
                    "min_long": minLong,
                    "max_lat": maxLat,
                    "max_long": maxLong,
                ]
            ).execute().value
            
            DispatchQueue.main.async {
                self.placesBeforeDate = responses.map { response in
                    Place(
                        coordinate: CLLocationCoordinate2D(latitude: response.lat, longitude: response.long),
                        name: response.description,
                        incident: "News Incident before \(dateString)", // Modify as needed
                        url: response.url,
                        timestamptz: response.timestamptz
                    )
                }
                
                // Debug: Print the fetched places
                for place in self.placesBeforeDate {
                    print("ID: \(place.id)")
                    print("Latitude: \(place.coordinate.latitude)")
                    print("Longitude: \(place.coordinate.longitude)")
                    print("Name: \(place.name)")
                    print("Incident: \(place.incident)")
                    print("URL: \(place.url)")
                    print("Timestamp: \(place.timestamptz)")
                    print("-----------")
                }
            }
        } catch {
            print("Error fetching locations before date: \(error.localizedDescription)")
        }
    }
    func fetchLocationsBeforefromX(minLat: Double, minLong: Double, maxLat: Double, maxLong: Double, dateString: String) async {
        do {
            let sourceValue: Double = 3
            let responses: [Response] = try await client.rpc(
                "locations_in_view_before_date_1",
                params: [
                    "min_lat": minLat,
                    "min_long": minLong,
                    "max_lat": maxLat,
                    "max_long": maxLong,
                    "source_num" : sourceValue
                ]
            ).execute().value
            
            DispatchQueue.main.async {
                self.places_X_BeforeDate = responses.map { response in
                    Place(
                        coordinate: CLLocationCoordinate2D(latitude: response.lat, longitude: response.long),
                        name: response.description,
                        incident: "X Incident before \(dateString)", // Modify as needed
                        url: response.url,
                        timestamptz: response.timestamptz
                    )
                }
                
                // Debug: Print the fetched places
                for place in self.places_X_BeforeDate {
                    print("ID: \(place.id)")
                    print("Latitude: \(place.coordinate.latitude)")
                    print("Longitude: \(place.coordinate.longitude)")
                    print("Name: \(place.name)")
                    print("Incident: \(place.incident)")
                    print("URL: \(place.url)")
                    print("Timestamp: \(place.timestamptz)")
                    print("-----------")
                }
            }
        } catch {
            print("Error fetching locations before date from X: \(error.localizedDescription)")
        }
    }
    func fetchLocationsAfterfromX(minLat: Double, minLong: Double, maxLat: Double, maxLong: Double, dateString: String) async {
        do {
            let sourceValue: Double = 3
            let responses: [Response] = try await client.rpc(
                "locations_in_view_after_date_1",
                params: [
                    "min_lat": minLat,
                    "min_long": minLong,
                    "max_lat": maxLat,
                    "max_long": maxLong,
                    "source_num" : sourceValue
                ]
            ).execute().value
            
            DispatchQueue.main.async {
                self.places_X_AfterDate = responses.map { response in
                    Place(
                        coordinate: CLLocationCoordinate2D(latitude: response.lat, longitude: response.long),
                        name: response.description,
                        incident: "X Incident after  \(dateString)", // Modify as needed
                        url: response.url,
                        timestamptz: response.timestamptz
                    )
                }
                
                // Debug: Print the fetched places
                for place in self.places_X_AfterDate {
                    print("ID: \(place.id)")
                    print("Latitude: \(place.coordinate.latitude)")
                    print("Longitude: \(place.coordinate.longitude)")
                    print("Name: \(place.name)")
                    print("Incident: \(place.incident)")
                    print("URL: \(place.url)")
                    print("Timestamp: \(place.timestamptz)")
                    print("-----------")
                }
            }
        } catch {
            print("Error fetching locations After date from X: \(error.localizedDescription)")
        }
    }


}

