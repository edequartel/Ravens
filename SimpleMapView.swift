import SwiftUI
import MapKit

struct SimpleMapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 34.011_286, longitude: -116.166_868),
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )
    @State private var tracking: MapUserTrackingMode = .follow

    var body: some View {
        Map(coordinateRegion: $region,
            interactionModes: .all,
            showsUserLocation: true,
            userTrackingMode: $tracking)
    }
}

struct SimpleMapView_Previews: PreviewProvider {
    static var previews: some View {
        SimpleMapView()
    }
}
