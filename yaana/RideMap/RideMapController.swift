
import UIKit
import GoogleMaps

class RideMapController : UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet var googleMapsContainerView: UIView!
    var resultsArray = [String]()
    var googleMapsView:GMSMapView!
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        self.googleMapsView = GMSMapView (frame: self.googleMapsContainerView.frame)
        self.googleMapsView.settings.compassButton = true
        self.googleMapsView.isMyLocationEnabled = true
        self.googleMapsView.settings.myLocationButton = true
        self.view.addSubview(self.googleMapsView)
        
    }
    
    @IBAction func startButtonClicked(_ sender: Any) {
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error" + error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let userLocation = locations.last
        let center = CLLocationCoordinate2D(latitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude)
        
        let camera = GMSCameraPosition.camera(withLatitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude, zoom: 15);
        self.googleMapsView.camera = camera
        self.googleMapsView.isMyLocationEnabled = true
        
        let marker = GMSMarker(position: center)
        
        marker.map = self.googleMapsView
        
        marker.title = "Current Location"
        locationManager.stopUpdatingLocation()
    }
}
