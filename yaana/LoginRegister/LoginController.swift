	
import UIKit

class LoginController : UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var userNameErrorLabel: UILabel!
    
    @IBOutlet weak var passwordErrorLabel: UILabel!
    
    @IBOutlet weak var mobileNumberField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    var mobileNumber : String = ""
    var password : String = ""
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    @IBAction func buttonClick(_ sender: Any) {
        
        if(mobileNumberField.isFirstResponder){
            mobileNumberField.resignFirstResponder()
        }else{
            passwordField.resignFirstResponder()
        }
        
        mobileNumber = mobileNumberField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        password = passwordField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        let isPasswordValid : Bool = validatePassword(password: password)
        let isUserNameValid : Bool = validateUserName(userName: mobileNumber)
        
        if (isUserNameValid && isPasswordValid) {
            
            let queries : Array<Any> = ["userName", mobileNumber, "password", password]
            let (urlSession, urlRequest) = self.view.makeHttpRequest(path: "/token/yaana/login",queries: queries,method: "POST", body: nil)
            
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
                        let userLoginDomain = try JSONDecoder().decode(UserLoginDomain.self, from: receivedData)
                        
                        KeychainWrapper.standard.set(userLoginDomain.token, forKey:"yaana_token")
                        KeychainWrapper.standard.set(userLoginDomain.userDomain.userId, forKey:"yaana_user_id")
                        KeychainWrapper.standard.set(userLoginDomain.userDomain.displayName, forKey:"yaana_name")
                        KeychainWrapper.standard.set(userLoginDomain.userDomain.email, forKey:"yaana_email")
                        KeychainWrapper.standard.set(userLoginDomain.userDomain.mobileNo, forKey:"yaana_mobile_no")

                        DispatchQueue.main.async(execute: {
                            
                                let storyboard = UIStoryboard(name: "MainMap", bundle: nil)
                                let controller = storyboard.instantiateViewController(withIdentifier: "MainMapController") as UIViewController
                                let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
                                appDelegate.window?.rootViewController = controller
                            
                            }
                        )

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
                            switch errorDomain.errorCode{
                            case 1001 :
                                self.view.makeToast(message: errorDomain.errorMessage, duration: 3.0, position: HRToastPositionDefault as AnyObject)
                            case 1002:
                                self.passwordErrorLabel.text = errorDomain.errorMessage
                                self.passwordErrorLabel.isHidden = false
                                self.passwordField.becomeFirstResponder()
                            default :
                                self.view.makeToast(message: "Internal Server Error", duration: 2.0, position: HRToastPositionDefault as AnyObject)
                            }
                        })
                    }
                    catch{
                        DispatchQueue.main.async(execute: {
                            self.view.makeToast(message: "Internal Server Error", duration: 2.0, position: HRToastPositionDefault as AnyObject)
                        })
                    }
                    return
                }
            }
            dataTask.resume()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mobileNumberField.delegate = self
        passwordField.delegate = self
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
