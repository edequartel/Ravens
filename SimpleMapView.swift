import SwiftUI
import MapKit

struct SimpleMapView: View {
    
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    
    var body: some View {
        Map(position: $position) {
        }
        .mapControls() {
            MapUserLocationButton()
                .frame(width: 44, height: 44)
        }
    }
}

struct SimpleMapView_Previews: PreviewProvider {
    static var previews: some View {
        SimpleMapView()
    }
}
