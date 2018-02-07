	
import UIKit

class LoginController : UIViewController {

    let MOBILE_PATTERN : String = "[0-9]{10}";
    
    @IBOutlet weak var userNameErrorLabel: UILabel!
    
    @IBOutlet weak var passwordErrorLabel: UILabel!
    
    @IBOutlet weak var mobileNumber: UITextField!
    
    @IBOutlet weak var password: UITextField!
    		
    //@IBOutlet weak var loginButtonText: UIButton!
    
    @IBAction func buttonClick(_ sender: Any) {
        
        let isUserNameValid : Bool = validateUserName(userName: mobileNumber.text!, invalidUserNameLabel: userNameErrorLabel)
        let isPasswordValid : Bool = validatePassword(password: password.text!, invalidPasswordLabel: passwordErrorLabel)
        if (isUserNameValid && isPasswordValid) {
            let configuration = URLSessionConfiguration .default
            let session = URLSession(configuration: configuration)
            
            var urlComponents = URLComponents()
            urlComponents.scheme = AppUrl.scheme
            urlComponents.host = AppUrl.host
            urlComponents.port = AppUrl.port
            urlComponents.path = "/token/yaana/login"
            let userNameItem = URLQueryItem(name: "userName", value: mobileNumber.text)
            let passwordItem = URLQueryItem(name: "password", value: password.text)
            urlComponents.queryItems = [userNameItem,passwordItem]
            guard let url = urlComponents.url else {
                self.view.showToast(toastMessage: "Internal Server Error", duration: 3.0)
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
                // 1: Check HTTP Response for successful GET request
                guard let httpResponse = response as? HTTPURLResponse, let receivedData = data
                    else {
                        self.view.showToast(toastMessage: "Internal Server Error", duration: 3.0)
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

                    } catch {
                        self.view.showToast(toastMessage: "Internal Server Error", duration: 3.0)
                        return
                    }
                    
                default:
                    self.view.showToast(toastMessage: "Internal Server Error", duration: 3.0)
                }
            }
            dataTask.resume()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mobileNumber.becomeFirstResponder()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func validateUserName(userName : String, invalidUserNameLabel : UILabel) -> Bool{
        
        if(userName.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count == 0){
            invalidUserNameLabel.text = "Mobile number is required"
            invalidUserNameLabel.isHidden = false
            return false
        }
        else{
            
        }
        invalidUserNameLabel.isHidden = true
        return true
    }
    
    func validatePassword(password : String, invalidPasswordLabel : UILabel) -> Bool{
        
        if(password.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count == 0){
            invalidPasswordLabel.text = "Password is required"
            invalidPasswordLabel.isHidden = false
            return false
        }
        invalidPasswordLabel.isHidden = true
        return true
    }
}
