	
import UIKit

class LoginController : UIViewController {

    @IBOutlet weak var mobileNumber: UITextField!
    
    @IBOutlet weak var password: UITextField!
    		
    //@IBOutlet weak var loginButtonText: UIButton!
    
    @IBAction func buttonClick(_ sender: Any) {
        if (mobileNumber.text != "" && password.text != "") {
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
            guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
            
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
                        print("error: not a valid http response")
                        return
                }
                
                switch (httpResponse.statusCode)
                {
                case 200:
                    
                    do {
                        //Decode retrived data with JSONDecoder and assing type of Article object
                        
                        let userLoginDomain = try JSONDecoder().decode(UserLoginDomain.self, from: receivedData)
                        
                        KeychainWrapper.standard.set(userLoginDomain.token, forKey:"yaana_token")
                        KeychainWrapper.standard.set(userLoginDomain.userDomain.userId, forKey:"yaana_user_id")
                        
                        print(KeychainWrapper.standard.string(forKey: "yaana_token") ?? "")
                        print(KeychainWrapper.standard.long(forKey: "yaana_user_id") ?? 0)
                    } catch {
                        self.view.showToast(toastMessage: "Internal Server Error", duration: 3.0)
                        return
                    }
                    
                default:
                    print("save profile POST request got response \(httpResponse.statusCode)")
                }
            }
            dataTask.resume()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //loginButtonText.layer.cornerRadius = 15;
        //mobileNumber.becomeFirstResponder();
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
