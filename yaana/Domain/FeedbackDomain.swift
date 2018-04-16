import UIKit

struct FeedbackDomain : Codable {
    let id : Int64
    let code : String?
    let userId : Int64
    let rating : Int16
    let qrCode : String?
    let issueId : Int32
    let location : String?
    let message : String?
    let resolved : Bool
}
