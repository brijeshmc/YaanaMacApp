
import UIKit

struct RideDomain : Codable {
    
    let rideId : Int64;
    let rideCode : String?
    let lockStatus : LockStatusDomain?
    let userId : Int64
    let startTime : String
    let endTime : String
    let source : String
    let destination : String
    let rideAmount : Double
    let travelDistance : Float
    let discount : DiscountDomain?
    let ended : Bool
    let amountPayable : Double
    let amountPaid : Double
    let sourceParking : String?
    let destinationParking : String?
    let totalRideTime : Int64
    let tax : Double

}
