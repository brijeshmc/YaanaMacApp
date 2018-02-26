
import UIKit

class RegisterOtpController : UIViewController, UITextFieldDelegate {
    
    var displayName : String!
    var email : String!
    var mobileNumber : String!
    var password : String!
    var dob : String!
    
    @IBOutlet weak var otpTextField1: UITextField!
    @IBOutlet weak var otpTextField2: UITextField!
    @IBOutlet weak var otpTextField3: UITextField!
    @IBOutlet weak var otpTextField4: UITextField!
    @IBOutlet weak var otpTextField5: UITextField!
    @IBOutlet weak var otpTextField6: UITextField!
    
    @IBOutlet weak var mobileNumberLabel: UILabel!
    
    @IBAction func otpField1(_ sender: UITextField) {
        let str = sender.text!
        if str.count == 1 {
            otpTextField2.becomeFirstResponder()
        }
    }
    @IBAction func otpField2(_ sender: UITextField) {
        let str = sender.text!
        if str.count == 1 {
            otpTextField3.becomeFirstResponder()
        }
    }
    @IBAction func otpField3(_ sender: UITextField) {
        let str = sender.text!
        if str.count == 1 {
            otpTextField4.becomeFirstResponder()
        }
    }
    @IBAction func otpField4(_ sender: UITextField) {
        let str = sender.text!
        if str.count == 1 {
            otpTextField5.becomeFirstResponder()
        }
    }
    @IBAction func otpField5(_ sender: UITextField) {
        let str = sender.text!
        if str.count == 1 {
            otpTextField6.becomeFirstResponder()
        }
    }
    @IBAction func otpField6(_ sender: UITextField) {
        let str = sender.text!
        if str.count == 1 {
            otpTextField6.resignFirstResponder()
        }
    }
    
    @IBAction func submitButtonClick(_ sender: Any) {
        if(otpTextField1.text?.count == 1 && otpTextField2.text?.count == 1 && otpTextField3.text?.count == 1 && otpTextField4.text?.count == 1 && otpTextField5.text?.count == 1 && otpTextField6.text?.count == 1){
            
            let otp = "\(otpTextField1.text!)\(otpTextField2.text!)\(otpTextField3.text!)\(otpTextField4.text!)\(otpTextField5.text!)\(otpTextField6.text!)"
            
            let userDomain = UserDomain.init(userId: 0, displayName: displayName, email: email, lastName: nil, password: password, userCreatedOn: "", aadhaarNo: nil, mobileNo: mobileNumber, dateOfBirth: dob, locked: false, rideExists: false, balanceAmount: 0, promoBalance: 0, qrCode: nil, profilePicturePath: nil)

            let userDomainData = try? JSONEncoder.init().encode(userDomain)
            let queries : Array<Any> = ["otp", otp, "androidId",  "a454a546aa"]
            let (urlSession, urlRequest) = self.view.makeHttpRequest(path: "/token/yaana/users",queries: queries,method: "POST", body: userDomainData)
            
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
                case 201:
                    
                    DispatchQueue.main.async(execute: {
                        self.view.makeToast(message: "Account has been created successfully", duration: 2.0, position: HRToastPositionDefault as AnyObject)
                        
                            self.performSegue(withIdentifier: "LoginSegue", sender: nil)
                    })
                    
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
    
    @IBAction func resendOtpButton(_ sender: Any) {
        let queries : Array<Any> = ["mobileNumber", mobileNumber]
        let (urlSession, urlRequest) = self.view.makeHttpRequest(path: "/token/yaana/register/otp",queries: queries,method: "PUT", body: nil)
        
        let dataTask = urlSession.dataTask(with: urlRequest)
        {
            ( data: Data?, response: URLResponse?, error: Error?) -> Void in
            guard let httpResponse = response as? HTTPURLResponse, let _ = data
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
                    self.view.makeToast(message: "OTP sent successfully", duration: 2.0, position: HRToastPositionDefault as AnyObject)
                    
                })
            
            default:
                DispatchQueue.main.async(execute: {
                        self.view.makeToast(message: "Internal Server Error", duration: 2.0, position: HRToastPositionDefault as AnyObject)
                        })
            }
        }
        dataTask.resume()
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mobileNumberLabel.text = "sent to \(mobileNumber!)"
        
        otpTextField1.delegate = self
        otpTextField2.delegate = self
        otpTextField3.delegate = self
        otpTextField4.delegate = self
        otpTextField5.delegate = self
        otpTextField6.delegate = self
        
        otpTextField1.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let str = (textField.text! + string)

        if str.count <= 1 {
            return true
        }
        textField.text = String(str.prefix(1))
        return false
    }
    

}
