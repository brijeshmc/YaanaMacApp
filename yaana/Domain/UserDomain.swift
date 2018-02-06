
import UIKit

struct UserDomain : Codable {
    
    let userId: Int64
    
    let displayName: String
    
    let email: String
    
    let lastName: String?
    
    let password: String?
    
    let userCreatedOn: String
    
    let aadhaarNo: String?
    
    let mobileNo: String
    
    let dateOfBirth: String
    
    let locked: Bool
    
    let rideExists: Bool
    
    let balanceAmount: Double
    
    let promoBalance: Double
    
    let qrCode: String?
    
    let profilePicturePath: String?
    
}
