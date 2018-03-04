import UIKit

struct LockStatusDomain : Codable {
    let lockId : String
    let bicycleId : Int64
    let latitude : Double
    let longitude : Double
    let status : Int16
    let batteryLevel : Double
    let locked : Bool
    let active : Bool
}
