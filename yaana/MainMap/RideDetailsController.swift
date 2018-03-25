

import UIKit

class RideDetailsController : UIViewController {
    
    var ToastMessage : String! = ""
    /*var RideId : Double! = 0
    var StartDate: String = ""
    var StartTime: String = ""
    var EndTime: String = ""*/
    var RideDetails: RideDomain! 
    
    @IBOutlet weak var RideIdLabel: UILabel!
    @IBOutlet weak var StartDateLabel: UILabel!
    @IBOutlet weak var StartTimeLabel: UILabel!
    @IBOutlet weak var EndDateLabel: UILabel!
    @IBOutlet weak var EndTimeLabel: UILabel!
    @IBOutlet weak var RideSourceLabel: UILabel!
    @IBOutlet weak var RideDestinationLabel: UILabel!
    @IBOutlet weak var RideAmountLabel: UILabel!
    @IBOutlet weak var DiscountAmountLabel: UILabel!
    @IBOutlet weak var TaxAmountLabel: UILabel!
    @IBOutlet weak var TotalAmountLabel: UILabel!
    @IBOutlet weak var AmountPaidLabel: UILabel!
    @IBOutlet weak var AmountPayableLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(ToastMessage.count > 0){
            self.view.makeToast(message: ToastMessage, duration: 2.0, position: HRToastPositionDefault as AnyObject)
        }
        RideIdLabel.text = "Ride ID: RID\(RideDetails.rideId)"
        let lowerBound = RideDetails.startTime.index(RideDetails.startTime.startIndex, offsetBy: 0)
        let upperBound = RideDetails.startTime.index(RideDetails.startTime.startIndex, offsetBy: 16)
        var StartDateTime = String(RideDetails.startTime[lowerBound..<upperBound]).split(separator: " ")
        var EndDateTme = String(RideDetails.endTime[lowerBound..<upperBound]).split(separator: " ")
        StartDateLabel.text = String(StartDateTime[0])
        StartTimeLabel.text = String(StartDateTime[1])
        EndDateLabel.text = String(EndDateTme[0])
        EndTimeLabel.text = String(EndDateTme[1])
        RideSourceLabel.text = RideDetails.sourceParking
        RideDestinationLabel.text = RideDetails.destinationParking
        let rideAmount = RideDetails.rideAmount + RideDetails.tax
        RideAmountLabel.text = "\u{20B9}\(RideDetails.rideAmount)"
        DiscountAmountLabel.text = "-\u{20B9}\(rideAmount - RideDetails.amountPayable)"
        TaxAmountLabel.text = "\u{20B9}\(RideDetails.tax)"
        TotalAmountLabel.text = "\u{20B9}\(RideDetails.amountPayable)"
        AmountPaidLabel.text = "\u{20B9}\(RideDetails.amountPaid)"
        AmountPayableLabel.text = "\u{20B9}\(RideDetails.amountPayable - RideDetails.amountPaid)"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
