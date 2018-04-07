import UIKit

struct UserDiscountDomain : Codable{
    
    var userDiscountId : Int64
    
    var userId : Int64
    
    var discount : DiscountDomain
    
    var remainingUses : Int32
}
