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
        guard let startByNumber = segue.destination as? StartByNumberController else {
            guard let rideDetails = segue.destination as? RideDetailsController else {
                return
            }
            rideDetails.navigationItem.title = "View Controller Pizza"
            navigationItem.title = "Pizza to One"
            
            //rideDetails.navigationController?.view.backgroundColor = UIColor.orange
            //rideDetails.navigationController?.view.tintColor = UIColor.white
            rideDetails.navigationItem.title = "Ride Details"
            navigationItem.title = "Back"
            //For back button in navigation bar
            //let backButton = UIBarButtonItem()
            //backButton.title = "Back"
            //rideDetails.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
            
            rideDetails.ToastMessage = self.ToastMessage
            return
        }
        startByNumber.rideExists = rideExists!
    }
    
    @IBAction func endRideButton(_ sender: Any) {
        let userId = KeychainWrapper.standard.integer(forKey: "yaana_user_id")
        
        let (urlSession, urlRequest) = self.view.makeHttpRequest(path: "/yaana/bicycles/ride/\(userId!)/terminate",queries: nil, method: "PUT", body: nil, accepts: "application/json")
        
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
                
                do {
                    _ = try JSONDecoder().decode(RideDomain.self, from: receivedData)

                    DispatchQueue.main.async(execute: {
                        self.ToastMessage = "Your ride has ended"
                        KeychainWrapper.standard.set(false, forKey:"yaana_ride_exists")
                        
                        self.performSegue(withIdentifier: "RideDetailsSegue", sender: nil)

                    })
                } catch {
                    print("Error info: \(error)")
                    DispatchQueue.main.async(execute: {
                        self.view.makeToast(message: "Internal Server Error", duration: 2.0, position: HRToastPositionDefault as AnyObject)
                        
                    })
                    return
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
}
