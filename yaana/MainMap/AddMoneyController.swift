import UIKit
import DropDown

class AddMoneyController : UIViewController{
    
    let promoCodeDropDown = DropDown()
    var promocodesList : [String] = []
    var UserDiscounts : [UserDiscountDomain]! = []

    @IBOutlet weak var PromoCodeButton: UIView!

    @IBOutlet weak var PromoCodeTextField: UITextField!
    @IBAction func PromoCode(_ sender: Any) {
        PromoCodeTextField.resignFirstResponder()
        promoCodeDropDown.show()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        promoCodeDropDown.anchorView = PromoCodeButton // UIView or UIBarButtonItem
        
        promoCodeDropDown.dismissMode = .onTap
        promoCodeDropDown.direction = .any
        promoCodeDropDown.backgroundColor = UIColor(white: 1, alpha: 1)
        promoCodeDropDown.bottomOffset = CGPoint(x: 0, y: PromoCodeButton.bounds.height)
        for userDiscount in UserDiscounts {
            promocodesList.append(userDiscount.discount.discountCode)
        }
        promoCodeDropDown.dataSource = promocodesList
        promoCodeDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.PromoCodeTextField.text = item
        }
    }
}
