
import UIKit

struct UserDomain : Codable {
    
    let userId: Int64
    
    var displayName: String
    
    var email: String
    
    let lastName: String?
    
    var password: String?
    
    let userCreatedOn: String
    
    let aadhaarNo: String?
    
    var mobileNo: String
    
    var dateOfBirth: String
    
    let locked: Bool
    
    let rideExists: Bool
    
    let balanceAmount: Double
    
    let promoBalance: Double
    
    let qrCode: String?
    
    let profilePicturePath: String?
    
}
