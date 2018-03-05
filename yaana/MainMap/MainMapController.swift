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
    
    @IBAction func refreshButtonClicked(_ sender: Any) {
        locationManager.startUpdatingLocation()
    }
    @IBAction func RideInfoClicked(_ sender: Any) {
        let CycleNumber = KeychainWrapper.standard.string(forKey: "yaana_cycle_number")

        let alert = UIAlertController(title: "Ride Info", message: "Cycle Number : \(CycleNumber!)", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error" + error.localizedDescription)
    }
    
    func updateCycleLocation(latitude : Double, longitude : Double){
        let queries : Array<Any> = ["latitude", "\(latitude)", "longitude", "\(longitude)"]
        
        let (urlSession, urlRequest) = self.view.makeHttpRequest(path: "/yaana/bicycles",queries: queries, method: "GET", body: nil, accepts : "application/json")
        
        let dataTask = urlSession.dataTask(with: urlRequest)
        {
            ( data: Data?, response: URLResponse?, error: Error?) -> Void in
            guard let httpResponse = response as? HTTPURLResponse, let receivedData = data
                else {
                    DispatchQueue.main.async(execute: {
                        self.ToastMessage = "Unable to connect to server"
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
                                if(parkingDomain.availableCycles == 0){
                                    marker.icon = UIImage(named:"cycle_parking_icon_1.png")
                                    marker.snippet = "No cycles available"
                                }
                                else{
                                    marker.icon = UIImage(named:"cycle_parking_icon_2.png")
                                    marker.snippet = "Cycles available - \(parkingDomain.availableCycles)"
                                }
                                marker.map = self.googleMapsView
                                
                            }
                        }
                        else{
                            self.showAlert(message: "No cycles available in your location")
                        }
                    })
                }
                catch{
                    DispatchQueue.main.async(execute: {
                        self.showAlert(message: "No cycles available in your location")
                    })
                }
            default:
                do{
                    let errorDomain = try JSONDecoder().decode(ErrorDomain.self, from: receivedData)
                    DispatchQueue.main.async(execute: {
                        if(errorDomain.errorCode != 0){
                            if(errorDomain.errorCode == 1015){
                                KeychainWrapper.standard.set(true, forKey:"yaana_ride_exists")
                            }
                            self.ToastMessage = errorDomain.errorMessage
                        }
                        else{
                            self.ToastMessage = "Internal Server Error"
                        }
                    })
                }
                catch{
                    DispatchQueue.main.async(execute: {
                        self.ToastMessage = "Internal Server Error"
                        
                    })
                }
            }
        }
        dataTask.resume()
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
                        self.ToastMessage = "Unable to connect to server"
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
                            if(errorDomain.errorCode == 1015){
                                KeychainWrapper.standard.set(true, forKey:"yaana_ride_exists")
                            }
                            self.ToastMessage = errorDomain.errorMessage
                        }
                        else{
                            self.ToastMessage = "Internal Server Error"
                        }
                    })
                }
                catch{
                    DispatchQueue.main.async(execute: {
                        self.ToastMessage = "Internal Server Error"
                        
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
    
    /*{ action in
     switch action.style{
     case .default:
     print("default")
     
     case .cancel:
     print("cancel")
     
     case .destructive:
     print("destructive")
     }}*/
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        //let userLocation = locations.last
        //userLocation!.coordinate.latitude
        //userLocation!.coordinate.longitude
        
        let camera = GMSCameraPosition.camera(withLatitude: 13.076558, longitude: 77.577284, zoom: 14);
        self.googleMapsView.camera = camera
        self.googleMapsView.isMyLocationEnabled = true
        
        rideExists = KeychainWrapper.standard.bool(forKey: "yaana_ride_exists")
        if(rideExists!){
            updateParkingLocation(latitude: 13.076558, longitude: 77.577284)
        }
        else{
            updateCycleLocation(latitude: 13.076558, longitude: 77.577284)
        }
        locationManager.stopUpdatingLocation()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let startByNumber = segue.destination as? StartByNumberController else {
            guard let rideDetails = segue.destination as? RideDetailsController else {
                return
            }
            
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
                        self.startRideContainerView.isHidden = false
                        self.endRideContainerView.isHidden = true
                        self.locationManager.startUpdatingLocation()
                        self.performSegue(withIdentifier: "RideDetailsSegue", sender: nil)

                    })
                } catch {
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
