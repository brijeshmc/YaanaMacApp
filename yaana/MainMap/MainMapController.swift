import UIKit
import GoogleMaps

class MainMapController: UIViewController,CLLocationManagerDelegate  {
    
    @IBOutlet var googleMapsContainerView: UIView!
    @IBOutlet var startRideContainerView: UIView!
    @IBOutlet var endRideContainerView: UIView!
    
    var resultsArray = [String]()
    var googleMapsView:GMSMapView!
    var locationManager = CLLocationManager()
    var rideExists : Bool? = false
    var ToastMessage : String! = ""
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rideExists = KeychainWrapper.standard.bool(forKey: "yaana_ride_exists")
        if(rideExists == nil){
            rideExists = false;
        }
        startRideContainerView.isHidden = rideExists!;
        endRideContainerView.isHidden = !rideExists!;
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        self.googleMapsView = GMSMapView (frame: self.googleMapsContainerView.frame)
        self.googleMapsView.settings.compassButton = true
        self.googleMapsView.isMyLocationEnabled = true
        self.googleMapsView.settings.myLocationButton = true
        self.view.addSubview(self.googleMapsView)
        
        if(ToastMessage.count > 0){
            self.view.makeToast(message: ToastMessage, duration: 2.0, position: HRToastPositionDefault as AnyObject)
        }

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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let startByNumber = segue.destination as? StartByNumberController else {return}
        startByNumber.rideExists = rideExists!
    }
}
