import UIKit

class PromotionsController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var promotions : [UserDiscountDomain] = []
    var RedeemableBalance : Double!
    var PromotionalBalance : Double!
    var UserDiscounts : [UserDiscountDomain]! = []
    var amount : Double! = 0
    var promoCode : String! = ""

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return promotions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let promotionViewCell : PromotionsViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PromotionsViewIdentifier", for: indexPath) as! PromotionsViewCell
        
        let promotion = promotions[indexPath.row]
        let imageUrl = URL(string : promotion.discount.discountUrl)
        do{
            let image = try Data(contentsOf : imageUrl!)
            promotionViewCell.promotionsImage.image = UIImage(data : image)
        }
        catch{
            return promotionViewCell
        }
        return promotionViewCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let promotion = promotions[indexPath.row]
        if(promotion.discount.discountType == "3"){
            amount = promotion.discount.minAmount
            promoCode = promotion.discount.discountCode
            self.performSegue(withIdentifier: "AddMoneySegue", sender: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        for discount in promotions {
            if(discount.discount.discountType == "3"){
                UserDiscounts.append(discount)
            }
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let addMoney = segue.destination as? AddMoneyController else {
            return
        }
        addMoney.UserDiscounts = UserDiscounts
        addMoney.amount = amount
        addMoney.promoCode = promoCode
    }
    
    @IBAction func backButton(_ sender: Any) {
        removeController(controller: self)
    }
    
    func removeController(controller: PromotionsController) {
        controller.dismiss(animated: true, completion: {() -> Void in
        })
    }
}
