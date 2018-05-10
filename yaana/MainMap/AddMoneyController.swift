import UIKit
import DropDown

class AddMoneyController : UIViewController, PGTransactionDelegate{
    
    var RedeemableBalance : Double! = 0
    var PromotionalBalance : Double! = 0
    
    func updateTransactionResponse(transactionResponse : Data){
        let userId = KeychainWrapper.standard.integer(forKey: "yaana_user_id")
        let queries : Array<Any> = ["userId", "\(userId!)", "promoCode", PromoCodeTextField.text!]
        
        let (urlSession, urlRequest) = self.view.makeHttpRequest(path: "/yaana/payment",queries: queries, method: "POST", body: transactionResponse, accepts: "application/json")
        
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
                    let paymentResponse = try JSONDecoder().decode(PaymentStatusUpdateResponse.self, from: receivedData)
                    
                    DispatchQueue.main.async(execute: {
                        if paymentResponse.status == "TXN_SUCCESS" {
                            self.view.makeToast(message: "Payment successful", duration: 2.0, position: HRToastPositionDefault as AnyObject)
                        }
                        else{
                            self.view.makeToast(message: "Payment failed", duration: 2.0, position: HRToastPositionDefault as AnyObject)

                        }
                        self.showMyWalletScreen()
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
    
    func didFinishedResponse(_ controller: PGTransactionViewController!, response responseString: String!) {
        if let data = responseString.data(using: .utf8) {
            updateTransactionResponse(transactionResponse: data)
        }
        else{
            self.view.makeToast(message: "Internal Server Error", duration: 2.0, position: HRToastPositionDefault as AnyObject)
        }
        self.removeController(controller: controller)
    }
    
    func didCancelTrasaction(_ controller: PGTransactionViewController!) {
        self.view.makeToast(message: "Payment Cancelled", duration: 2.0, position: HRToastPositionDefault as AnyObject)
        self.removeController(controller: controller)
    }
    
    func errorMisssingParameter(_ controller: PGTransactionViewController!, error: Error!) {

        self.view.makeToast(message: "Internal Server Error", duration: 2.0, position: HRToastPositionDefault as AnyObject)
        
        self.removeController(controller: controller)
    }
    
    
    let promoCodeDropDown = DropDown()
    var promocodesList : [String] = []
    var UserDiscounts : [UserDiscountDomain]! = []
    var amount : Double! = 0
    var promoCode : String! = ""
    
    @IBOutlet weak var AmountErrorLabel: UILabel!
    @IBOutlet weak var PromoCodeButton: UIView!
    @IBOutlet weak var AmountTextField: UITextField!
    @IBOutlet weak var PromoCodeTextField: UITextField!
    @IBAction func PromoCode(_ sender: Any) {
        AmountTextField.resignFirstResponder()
        if promocodesList.count == 0 {
            self.showAlert(message: "No promo codes available")
        }
        else {
            promoCodeDropDown.show()
        }
    }
    
    @IBAction func NextButton(_ sender: Any) {
        let amountValid = validateAmount(amount : AmountTextField.text!, promoCode: PromoCodeTextField.text!)
        if amountValid {
            let userId = KeychainWrapper.standard.integer(forKey: "yaana_user_id")
            amount = Double(AmountTextField.text!)
            let queries : Array<Any> = ["userId", "\(userId!)", "amount", "\(Int(amount))"]

            let (urlSession, urlRequest) = self.view.makeHttpRequest(path: "/yaana/getPaytmPayload",queries: queries, method: "GET", body: nil, accepts: "application/json")
            
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
                        let orderDict = try JSONDecoder().decode(Dictionary<String, String>.self, from: receivedData)
                        
                        DispatchQueue.main.async(execute: {
                            let merchantConfiguration : PGMerchantConfiguration = PGMerchantConfiguration.default()
                            let order = PGOrder(params :orderDict)
                            let txnController = PGTransactionViewController.init(transactionFor: order)
                            txnController?.serverType = eServerTypeProduction
                            txnController?.merchant = merchantConfiguration
                            txnController?.delegate = self
                            self.showController(controller: txnController!)
                        })
                        
                    } catch {
                        
                        DispatchQueue.main.async(execute: {
                            self.view.makeToast(message: "Internal Server Error", duration: 2.0, position: HRToastPositionDefault as AnyObject)
                            
                        })
                        return
                    }
                    
                default:
                    do{
                        print(receivedData)
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
    
    func showController(controller: PGTransactionViewController) {
        
        if self.navigationController != nil {
            self.navigationController!.pushViewController(controller, animated: true)
        }
        else {
            self.present(controller, animated: true, completion: {() -> Void in
            })
        }
    }
    
    func removeController(controller: PGTransactionViewController) {
        if self.navigationController != nil {
            self.navigationController!.popViewController(animated: true)
        }
        else {
            controller.dismiss(animated: true, completion: {() -> Void in
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AmountTextField.text = "\(Int(amount!))"
        PromoCodeTextField.text = promoCode
        AmountErrorLabel.isHidden = true
        AmountTextField.becomeFirstResponder()
        promoCodeDropDown.anchorView = PromoCodeButton // UIView or UIBarButtonItem
        
        promoCodeDropDown.dismissMode = .onTap
        promoCodeDropDown.direction = .any
        promoCodeDropDown.backgroundColor = UIColor(white: 1, alpha: 1)
        promoCodeDropDown.bottomOffset = CGPoint(x: 0, y: PromoCodeButton.bounds.height)
        if(UserDiscounts.count > 0){
            promocodesList.append("")
        }
        for userDiscount in UserDiscounts {
            promocodesList.append(userDiscount.discount.discountCode)
        }
        promoCodeDropDown.dataSource = promocodesList
        promoCodeDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.PromoCodeTextField.text = item
        }
    }
    
    func validateAmount(amount : String, promoCode : String) -> Bool {
        let enteredAmount = Double(amount)
        if(enteredAmount == nil || enteredAmount! <= 0){
            AmountTextField.becomeFirstResponder()
            AmountErrorLabel.text = "Amount is required"
            AmountErrorLabel.isHidden = false
            return false
        }
        if(promoCode != ""){
            let userDiscount = getUserDiscountDomain(promoCode: promoCode)
            if(userDiscount != nil){
                let minAmount : Double! = userDiscount?.discount.minAmount
                if(Double(amount)! < minAmount!){
                    AmountTextField.becomeFirstResponder()
                    AmountErrorLabel.text = "Minimum amount of \u{20B9}\(minAmount!) required"
                    AmountErrorLabel.isHidden = false
                    return false
                }
            }
        }
        AmountErrorLabel.isHidden = true
        return true
    }
    func showAlert(message : String){
        let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showMyWalletScreen(){
        let userId = KeychainWrapper.standard.integer(forKey: "yaana_user_id")
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let myWallet = segue.destination as? PaymentController else {
            return
        }
        myWallet.RedeemableBalance = RedeemableBalance!
        myWallet.PromotionalBalance = PromotionalBalance!
    }
    
    func  getUserDiscountDomain(promoCode : String) -> UserDiscountDomain?{
        for userDiscount in UserDiscounts {
            if(userDiscount.discount.discountCode == promoCode){
                return userDiscount
            }
        }
        return nil
    }
}

