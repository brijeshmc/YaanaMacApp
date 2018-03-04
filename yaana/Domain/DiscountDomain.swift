import UIKit

struct DiscountDomain : Codable {
    let discountId : Int64
    
    let discountCode : String
    
    let  discountType : String
    
    let maxDiscount : Double
    
    let discountPercentage : Int32
    
    let createdOn : String
    
    let expiryDate : String
    
    let discountDescription : String
    
    let discountValidTill : String
    
    let discountHours : Int32
    
    let discountUrl : String
    
    let minAmount : Double

}
