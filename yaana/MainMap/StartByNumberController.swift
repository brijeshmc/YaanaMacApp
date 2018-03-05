
import UIKit

class StartByNumberController : UIViewController {
    
    
    @IBOutlet weak var CycleNumberField: UITextField!
    @IBOutlet weak var ConfirmCycleNumberField: UITextField!
    
    @IBOutlet weak var CycleNumberErrorLabel: UILabel!
    @IBOutlet weak var ConfirmCycleNumberErrorLabel: UILabel!
    var CycleNumber = ""
    var ConfirmCycleNumber = ""
    var ToastMessage : String! = ""
    var rideExists : Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CycleNumberField.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func UnlockClicked(_ sender: Any) {
        CycleNumber = CycleNumberField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        ConfirmCycleNumber = ConfirmCycleNumberField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        let isConfirmCycleNumberValid = ValidateConfirmCycleNumber(confirmCycleNumber : ConfirmCycleNumber, cycleNumber : CycleNumber)
        let isCycleNumberValid = ValidateCycleNumber(cycleNumber : CycleNumber)
        
        if(isConfirmCycleNumberValid && isCycleNumberValid){
            KeychainWrapper.standard.set(CycleNumber, forKey:"yaana_cycle_number")

            let userId = KeychainWrapper.standard.integer(forKey: "yaana_user_id")
            
            let queries : Array<Any> = ["lockId", CycleNumber, "userId",  String(describing: userId!), "promoCode",  ""]
            
            var urlSession : URLSession
            var urlRequest : URLRequest
            if(rideExists){
                (urlSession, urlRequest) = self.view.makeHttpRequest(path: "/yaana/bicycles/unlock",queries: queries,method: "PUT", body: nil, accepts: "application/json")
            }
            else{
                (urlSession, urlRequest) = self.view.makeHttpRequest(path: "/yaana/bicycles/ride",queries: queries,method: "POST", body: nil, accepts: "application/json")
            }
            
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
                    
                    DispatchQueue.main.async(execute: {
                        self.performSegue(withIdentifier: "UnlockingSegue", sender: nil)
                    })
                    
                default:
                    do{
                        let errorDomain = try JSONDecoder().decode(ErrorDomain.self, from: receivedData)
                        DispatchQueue.main.async(execute: {
                            if(errorDomain.errorCode != 0){
                                if(errorDomain.errorCode == 1015){
                                    KeychainWrapper.standard.set(true, forKey:"yaana_ride_exists")
                                    self.performSegue(withIdentifier: "MainMapSegue", sender: nil)
                                    self.ToastMessage = errorDomain.errorMessage
                                }
                                else{
                                    self.view.makeToast(message: errorDomain.errorMessage, duration: 2.0, position: HRToastPositionDefault as AnyObject)
                                }
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
    
    func ValidateCycleNumber(cycleNumber : String) -> Bool{
        if(cycleNumber.count == 0){
            CycleNumberErrorLabel.isHidden = false
            CycleNumberField.becomeFirstResponder()
            return false
        }
        CycleNumberErrorLabel.isHidden = true
        return true
    }
    
    func ValidateConfirmCycleNumber(confirmCycleNumber : String, cycleNumber : String) -> Bool{
        if(confirmCycleNumber.count == 0){
            ConfirmCycleNumberErrorLabel.text = "Confirm cycle number is required"
            ConfirmCycleNumberErrorLabel.isHidden = false
            ConfirmCycleNumberField.becomeFirstResponder()
            return false
        }
        else{
            if(cycleNumber != confirmCycleNumber){
                ConfirmCycleNumberErrorLabel.text = "Cycle Number and Confirm Cycle Number do not match"
                ConfirmCycleNumberErrorLabel.isHidden = false
                ConfirmCycleNumberField.becomeFirstResponder()
                return false
            }
        }
        ConfirmCycleNumberErrorLabel.isHidden = true
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let unlocking = segue.destination as? UnlockingController else {
            guard let mainMap = segue.destination as? MainMapController else {return}
            mainMap.ToastMessage = ToastMessage
            return
        }
        unlocking.rideExists = rideExists
        unlocking.CycleNumber = CycleNumber
    }
}
