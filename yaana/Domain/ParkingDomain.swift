import UIKit

struct ParkingDomain : Codable {
    let parkingId : Int64
    let latitude : Double
    let longitude : Double
    let parkingRadius : Float
    let maxCycleLimit : Int32
    let cycles : [LockStatusDomain]?
    let avilableParkingSpace : Int32
    let availableCycles : Int32
    let address : String
}
