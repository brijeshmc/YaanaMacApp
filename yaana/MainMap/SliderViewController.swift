
import UIKit

class SliderViewController : UIViewController {
    
    var RedeemableBalance : Double! = 0
    var PromotionalBalance : Double! = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func PromotionsButton(_ sender: Any) {
    }
    
    @IBAction func MyWalletButton(_ sender: Any) {
        let userId = KeychainWrapper.standard.integer(forKey: "yaana_user_id")
        if(userId != nil && userId != 0){
            
            let (urlSession, urlRequest) = self.view.makeHttpRequest(path: "/yaana/users/\(userId!)",queries: nil, method: "GET", body: nil, accepts: "application/json")
            
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
                        let userDomain = try JSONDecoder().decode(UserDomain.self, from: receivedData)
                        
                        DispatchQueue.main.async(execute: {
                            self.RedeemableBalance = userDomain.balanceAmount
                            self.PromotionalBalance = userDomain.promoBalance
                            self.performSegue(withIdentifier: "MyWalletSegue", sender: nil)
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
        else{
            let storyboard = UIStoryboard(name: "LoginRegister", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "LoginRegisterController") as UIViewController
            let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
            appDelegate.window?.rootViewController = controller
        }
    }
    
    @IBAction func MyRidesButton(_ sender: Any) {
    }
    
    @IBAction func AboutUsButton(_ sender: Any) {
        
    }
    
    @IBAction func SignOutButton(_ sender: Any) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let myWallet = segue.destination as? PaymentController else {
            return
        }
        myWallet.RedeemableBalance = RedeemableBalance!
        myWallet.PromotionalBalance = PromotionalBalance!
    }
}
