import UIKit

class UnlockingController : UIViewController {
    
    @IBOutlet weak var progressView: UIProgressView!
    var progressValue : Float = 0
    var rideExists : Bool!
    var CycleNumber : String!
    var ToastMessage : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //progressView.layer.borderWidth = 100.0;
        //progressView.layer.borderColor = UIColor.black.cgColor
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
        Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(getLockStatus), userInfo: nil, repeats: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func updateProgress(){
            progressValue += 0.1
            progressView.progress = progressValue
    }
    
    @objc func getLockStatus(){
        
        let queries : Array<Any> = ["lockId", CycleNumber]
            
        let (urlSession, urlRequest) = self.view.makeHttpRequest(path: "/yaana/lock/getLockStatus",queries: queries, method: "GET", body: nil, accepts : "text/plain")
            
            let dataTask = urlSession.dataTask(with: urlRequest)
            {
                ( data: Data?, response: URLResponse?, error: Error?) -> Void in
                guard let httpResponse = response as? HTTPURLResponse, let receivedData = data
                    else {
                        DispatchQueue.main.async(execute: {
                            self.ToastMessage = "Unable to connect to server"
                            self.performSegue(withIdentifier: "MainMapSegue", sender: nil)
                        })
                        return
                }
                
                switch (httpResponse.statusCode)
                {
                case 200:
                    
                    let LockStatus = String(data: receivedData, encoding: .utf8)
                    DispatchQueue.main.async(execute: {
                        if(LockStatus == "false"){
                            if(self.self.rideExists == false){
                                KeychainWrapper.standard.set(true, forKey:"yaana_ride_exists")
                                KeychainWrapper.standard.set(self.CycleNumber, forKey:"yaana_cycle_number")
                                self.ToastMessage = "Unlock successful. Your ride has started"
                            }
                            else{
                                self.ToastMessage = "Unlock successful"
                            }
                        }
                        else{
                            self.ToastMessage = "Unlock failed"
                        }
                        self.performSegue(withIdentifier: "MainMapSegue", sender: nil)
                    })
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
                            self.performSegue(withIdentifier: "MainMapSegue", sender: nil)
                        })
                    }
                    catch{
                        DispatchQueue.main.async(execute: {
                            self.ToastMessage = "Internal Server Error"
                            self.performSegue(withIdentifier: "MainMapSegue", sender: nil)
                        })
                    }
                }
            }
            dataTask.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let mainMap = segue.destination as? MainMapController else {return}
        mainMap.ToastMessage = ToastMessage
    }
}

