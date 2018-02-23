	
import UIKit

class LoginController : UIViewController {
    
    @IBOutlet weak var userNameErrorLabel: UILabel!
    
    @IBOutlet weak var passwordErrorLabel: UILabel!
    
    @IBOutlet weak var mobileNumberField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    var mobileNumber : String = ""
    var password : String = ""
    		
    //@IBOutlet weak var loginButtonText: UIButton!
    
    @IBAction func buttonClick(_ sender: Any) {
        mobileNumber = mobileNumberField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        password = passwordField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        let isPasswordValid : Bool = validatePassword(password: password)
        let isUserNameValid : Bool = validateUserName(userName: mobileNumber)
        
        if (isUserNameValid && isPasswordValid) {
            let configuration = URLSessionConfiguration .default
            let session = URLSession(configuration: configuration)
            
            var urlComponents = URLComponents()
            urlComponents.scheme = AppUrl.scheme
            urlComponents.host = AppUrl.host
            urlComponents.port = AppUrl.port
            urlComponents.path = "/token/yaana/login"
            let userNameItem = URLQueryItem(name: "userName", value: mobileNumber)
            let passwordItem = URLQueryItem(name: "password", value: password)
            urlComponents.queryItems = [userNameItem,passwordItem]
            guard let url = urlComponents.url else {
                DispatchQueue.main.async(execute: {
                    self.view.makeToast(message: "Internal Server Error", duration: 2.0, position: HRToastPositionDefault as AnyObject)
                    
                })
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.timeoutInterval = 30
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let dataTask = session.dataTask(with: request)
            {
                ( data: Data?, response: URLResponse?, error: Error?) -> Void in
                guard let httpResponse = response as? HTTPURLResponse, let receivedData = data
                    else {
                        DispatchQueue.main.async(execute: {
                            self.view.makeToast(message: "Internal Server Error", duration: 2.0, position: HRToastPositionDefault as AnyObject)
                            
                        })
                        return
                }
                
                switch (httpResponse.statusCode)
                {
                case 200:
                    
                    do {
                        let userLoginDomain = try JSONDecoder().decode(UserLoginDomain.self, from: receivedData)
                        
                        KeychainWrapper.standard.set(userLoginDomain.token, forKey:"yaana_token")
                        KeychainWrapper.standard.set(userLoginDomain.userDomain.userId, forKey:"yaana_user_id")
                        KeychainWrapper.standard.set(userLoginDomain.userDomain.displayName, forKey:"yaana_name")
                        KeychainWrapper.standard.set(userLoginDomain.userDomain.email, forKey:"yaana_email")
                        KeychainWrapper.standard.set(userLoginDomain.userDomain.mobileNo, forKey:"yaana_mobile_no")

                        DispatchQueue.main.async(execute: {
                            self.view.makeToast(message: "Login Successful", duration: 2.0, position: HRToastPositionDefault as AnyObject)
                            
                            }
                        )

                    } catch {
                        DispatchQueue.main.async(execute: {
                            self.view.makeToast(message: "Internal Server Error", duration: 2.0, position: HRToastPositionDefault as AnyObject)
                            
                        })
                        return
                    }
                    
                default:
                    DispatchQueue.main.async(execute: {
                        self.view.makeToast(message: "Internal Server Error", duration: 2.0, position: HRToastPositionDefault as AnyObject)
                        
                    })
                    return
                }
            }
            dataTask.resume()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mobileNumberField.becomeFirstResponder()
        
    }
    	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func validateUserName(userName : String) -> Bool{
        
        if(userName.count == 0){
            userNameErrorLabel.text = "Mobile number is required"
            userNameErrorLabel.isHidden = false
            mobileNumberField.becomeFirstResponder()
            return false
        }
        else{
            let mobilePattern : String = "[0-9]{10}";
            let mobilePredicate = NSPredicate(format:"SELF MATCHES %@", mobilePattern)
            if(!mobilePredicate.evaluate(with: userName)){
                userNameErrorLabel.text = "Invalid mobile number"
                userNameErrorLabel.isHidden = false
                mobileNumberField.becomeFirstResponder()
                return false
            }
        }
        userNameErrorLabel.isHidden = true
        return true
    }
    
    func validatePassword(password : String) -> Bool{
        
        if(password.count == 0){
            passwordErrorLabel.text = "Password is required"
            passwordErrorLabel.isHidden = false
            passwordField.becomeFirstResponder()
            return false
        }
        passwordErrorLabel.isHidden = true
        return true
    }

}
