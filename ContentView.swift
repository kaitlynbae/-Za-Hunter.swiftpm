import SwiftUI
import MapKit

struct ContentView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 42.088, longitude: -87.9806),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var locationManager = CLLocationManager()
    @State private var pizzaShops: [IdentifiableAnnotation] = []
    @State private var searching = false
    
    var body: some View {
        VStack {
            Button(action: {
                searching = true
                searchPizzaShops()
            }) {
                Text("Hungry for Pizza? ")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
            Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: pizzaShops) { pizzaShop in
                MapPin(coordinate: pizzaShop.coordinate, tint: .red)
            }
        }
        .onAppear {
            locationManager.requestWhenInUseAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    private func searchPizzaShops() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "pizza"
        request.region = MKCoordinateRegion(center: region.center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
           
            self.pizzaShops.removeAll()
            
           
            for item in response.mapItems {
                let annotation = IdentifiableAnnotation()
                annotation.title = item.name
                annotation.coordinate = item.placemark.coordinate
                self.pizzaShops.append(annotation)
            }
            searching = false
        }
    }
}

class IdentifiableAnnotation: MKPointAnnotation, Identifiable {}

