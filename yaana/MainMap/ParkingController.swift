import UIKit
import GoogleMaps

class ParkingController : UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate  {
    
    @IBOutlet var parkingMapContainerView: UIView!
    var googleMapsView:GMSMapView!
    var locationManager = CLLocationManager()

    @IBOutlet weak var AddressField: UITextView!
    @IBOutlet weak var PinIcon: UIImageView!
    @IBAction func SearchParkingClicked(_ sender: Any) {
        let latitude = self.googleMapsView.camera.target.latitude
        let longitude = self.googleMapsView.camera.target.longitude
        updateParkingLocation(latitude: latitude, longitude: longitude)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        self.googleMapsView = GMSMapView (frame: self.parkingMapContainerView.frame)
        self.googleMapsView.delegate = self
        self.googleMapsView.settings.compassButton = true
        self.googleMapsView.isMyLocationEnabled = true
        self.googleMapsView.settings.myLocationButton = true
        self.view.addSubview(self.googleMapsView)
        self.view.bringSubview(toFront: PinIcon)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        getAddress(latitude: position.target.latitude, longitude: position.target.longitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error" + error.localizedDescription)
    }
    
    func updateParkingLocation(latitude : Double, longitude : Double){
        let queries : Array<Any> = ["latitude", "\(latitude)", "longitude", "\(longitude)"]
        
        let (urlSession, urlRequest) = self.view.makeHttpRequest(path: "/yaana/parking",queries: queries, method: "GET", body: nil, accepts : "application/json")
        
        let dataTask = urlSession.dataTask(with: urlRequest)
        {
            ( data: Data?, response: URLResponse?, error: Error?) -> Void in
            guard let httpResponse = response as? HTTPURLResponse, let receivedData = data
                else {
                    DispatchQueue.main.async(execute: {
                        self.view.makeToast(message: "Unable to connect to server", duration: 2.0, position: HRToastPositionDefault as AnyObject)
                    })
                    return
            }
            
            switch (httpResponse.statusCode)
            {
            case 200:
                
                do{
                    let parkingsDomain = try JSONDecoder().decode([ParkingDomain].self, from: receivedData)
                    DispatchQueue.main.async(execute: {
                        if(parkingsDomain.count > 0){
                            var center : CLLocationCoordinate2D
                            for parkingDomain in parkingsDomain{
                                center = CLLocationCoordinate2D(latitude: parkingDomain.latitude, longitude: parkingDomain.longitude)
                                
                                let marker = GMSMarker(position: center)
                                marker.title = parkingDomain.address
                                if(parkingDomain.avilableParkingSpace == 0){
                                    marker.icon = UIImage(named:"cycle_parking_icon_1.png")
                                    marker.snippet = "No parking space available"
                                }
                                else{
                                    marker.icon = UIImage(named:"cycle_parking_icon_2.png")
                                    marker.snippet = "Parking space available - \(parkingDomain.avilableParkingSpace)"
                                }
                                marker.map = self.googleMapsView
                                
                            }
                        }
                        else{
                            self.showAlert(message: "Parking not available at the selected location")
                        }
                    })
                }
                catch{
                    DispatchQueue.main.async(execute: {
                        self.showAlert(message: "Parking not available at the selected location")
                    })
                }
            default:
                do{
                    let errorDomain = try JSONDecoder().decode(ErrorDomain.self, from: receivedData)
                    DispatchQueue.main.async(execute: {
                        if(errorDomain.errorCode != 0){
                            self.view.makeToast(message: errorDomain.errorMessage, duration: 2.0, position: HRToastPositionDefault as AnyObject)
                        }
                        else{
                            self.view.makeToast(message: "Internal Server Error", duration: 2.0, position: HRToastPositionDefault as AnyObject)
                        }
                    })
                }
                catch{
                    DispatchQueue.main.async(execute: {
                        self.view.makeToast(message: "Internal Server Error", duration: 2.0, position: HRToastPositionDefault as AnyObject)
                    })
                }
            }
        }
        dataTask.resume()
    }
    
    func showAlert(message : String){
        let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        //let userLocation = locations.last
        //userLocation!.coordinate.latitude
        //userLocation!.coordinate.longitude
        
        let camera = GMSCameraPosition.camera(withLatitude: 13.076558, longitude: 77.577284, zoom: 14);
        self.googleMapsView.camera = camera
        self.googleMapsView.isMyLocationEnabled = true
        locationManager.stopUpdatingLocation()
    }
    
    func getAddress(latitude : Double, longitude : Double) {
        var addressString: String = ""
        
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        //selectedLat and selectedLon are double values set by the app in a previous process
        
        geoCoder.reverseGeocodeLocation(location, completionHandler:
            {(placemarks, error) in
                if (error != nil)
                {
                    self.AddressField.text = addressString
                }
                let pm = placemarks! as [CLPlacemark]
                
                if pm.count > 0 {
                    let pm = placemarks![0]
                
                    if pm.name != nil {
                        addressString = addressString + pm.name!
                    }
                    if pm.subLocality != nil {
                        addressString = addressString + ", " + pm.subLocality!
                    }
                    if pm.thoroughfare != nil {
                        addressString = addressString + ", " + pm.thoroughfare!
                    }
                    if pm.locality != nil {
                        addressString = addressString + ", " +  pm.locality!
                    }
                    if pm.administrativeArea != nil {
                        addressString = addressString + ", " + pm.administrativeArea!
                    }
                    self.AddressField.text = addressString
                }
        })
    }
}
