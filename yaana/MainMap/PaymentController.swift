import UIKit

class PaymentController : UIViewController {
    
    var RedeemableBalance : Double!
    var PromotionalBalance : Double!
    var UserDiscounts : [UserDiscountDomain]! = []
    
    @IBOutlet weak var TotalBalance: UILabel!
    @IBOutlet weak var RedeemableBalanceLabel: UILabel!
    @IBOutlet weak var PromotionalBalanceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TotalBalance.text = "\u{20B9}\(RedeemableBalance + PromotionalBalance)"
        RedeemableBalanceLabel.text = "\u{20B9}\(RedeemableBalance!)"
        PromotionalBalanceLabel.text = "\u{20B9}\(PromotionalBalance!)"
    }
    
    @IBAction func AddMoneyButton(_ sender: Any) {
        let userId = KeychainWrapper.standard.integer(forKey: "yaana_user_id")

        let (urlSession, urlRequest) = self.view.makeHttpRequest(path: "/yaana/user-discounts/payment/\(userId!)",queries: nil, method: "GET", body: nil, accepts: "application/json")
        
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
                    let userDiscounts = try JSONDecoder().decode([UserDiscountDomain].self, from: receivedData)
                    
                    DispatchQueue.main.async(execute: {
                        self.UserDiscounts = userDiscounts
                        self.performSegue(withIdentifier: "AddMoneySegue", sender: nil)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /*guard let destinationNavigationController = segue.destination as? UINavigationController else {
            return
        }*/
        guard let addMoney = segue.destination as? AddMoneyController else {
            return
        }
        addMoney.UserDiscounts = UserDiscounts
    }
}
