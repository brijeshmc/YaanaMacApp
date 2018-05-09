
import UIKit

class SliderViewController : UIViewController {
    
    var RedeemableBalance : Double! = 0
    var PromotionalBalance : Double! = 0
    var UserRides : [RideDomain] = []
    var promotions : [UserDiscountDomain]! = []
    var defaultIssues : [IssueDomain]! = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func HelpCentreButton(_ sender: Any) {
        
        let (urlSession, urlRequest) = self.view.makeHttpRequest(path: "/yaana/issues",queries: nil, method: "GET", body: nil, accepts: "application/json")
        
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
                    self.defaultIssues = try JSONDecoder().decode([IssueDomain].self, from: receivedData)
                    
                    DispatchQueue.main.async(execute: {
                        self.performSegue(withIdentifier: "HelpCentreSegue", sender: nil)
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
    @IBAction func PromotionsButton(_ sender: Any) {
        let userId = KeychainWrapper.standard.integer(forKey: "yaana_user_id")
        
        let (urlSession, urlRequest) = self.view.makeHttpRequest(path: "/yaana/user-discounts/\(userId!)",queries: nil, method: "GET", body: nil, accepts: "application/json")
        
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
                    self.promotions = try JSONDecoder().decode([UserDiscountDomain].self, from: receivedData)
                    
                    DispatchQueue.main.async(execute: {
                        self.performSegue(withIdentifier: "PromotionsSegue", sender: nil)
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
        let userId = KeychainWrapper.standard.integer(forKey: "yaana_user_id")
        let (urlSession, urlRequest) = self.view.makeHttpRequest(path: "/yaana/users/rides/\(userId!)",queries: nil, method: "GET", body: nil, accepts: "application/json")
        
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
                    self.UserRides = try JSONDecoder().decode([RideDomain].self, from: receivedData)
                    
                    DispatchQueue.main.async(execute: {
                        self.performSegue(withIdentifier: "MyRidesSegue", sender: nil)
                    })
                    
                } catch {
                    print(error)
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
    
    @IBAction func SignOutButton(_ sender: Any) {
        self.showAlert(message: "Are you sure you want to sign out?")
    }
    
    func showAlert(message : String){
        let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            switch action.style{
            case .default:
                _ = KeychainWrapper.standard.removeAllKeys()
                
                let storyboard = UIStoryboard(name: "LoginRegister", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "LoginRegisterController") as UIViewController
                let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
                appDelegate.window?.rootViewController = controller
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
            }}))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { action in
            switch action.style{
            case .default:
                print("default")
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
            }}))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationNavigationController = segue.destination as? UINavigationController else {
            guard let helpCentre = segue.destination as? HelpCentreController else {
                return
            }
            helpCentre.defaultIssues = self.defaultIssues
            return
        }
        guard let myWallet = destinationNavigationController.topViewController as? PaymentController else {
            guard let myRides = destinationNavigationController.topViewController as? MyRidesController else {
                guard let promotions = destinationNavigationController.topViewController as? PromotionsController else {
                    return
                }
                promotions.promotions = self.promotions
                return
            }
            myRides.myRides = self.UserRides
            return
        }
        myWallet.RedeemableBalance = RedeemableBalance!
        myWallet.PromotionalBalance = PromotionalBalance!
    }
}
