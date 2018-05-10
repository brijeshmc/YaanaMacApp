import UIKit

class MyRidesController : UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    var RideDetails : RideDomain!
    @IBOutlet weak var noRidesLabel: UILabel!
    
    var myRides : [RideDomain]! = []
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myRides.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let rideViewCell : MyRidesViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "RideInfoIdentifier", for: indexPath) as! MyRidesViewCell
        let rideDomain = myRides[indexPath.row]
        rideViewCell.rideIdLabel.text = "Ride ID: RID\(rideDomain.rideId)"
        let lowerBound = rideDomain.startTime.index(rideDomain.startTime.startIndex, offsetBy: 0)
        let upperBound = rideDomain.startTime.index(rideDomain.startTime.startIndex, offsetBy: 16)
        var StartDateTime = String(rideDomain.startTime[lowerBound..<upperBound]).split(separator: " ")
        var EndDateTme = String(rideDomain.endTime[lowerBound..<upperBound]).split(separator: " ")
        rideViewCell.startDateLabel.text = String(StartDateTime[0])
        rideViewCell.startTimeLabel.text = String(StartDateTime[1])
        rideViewCell.endDateLabel.text = String(EndDateTme[0])
        rideViewCell.endTimeLabel.text = String(EndDateTme[1])
        rideViewCell.sourceLabel.text = rideDomain.sourceParking
        rideViewCell.destinationLabel.text = rideDomain.destinationParking
        return rideViewCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        RideDetails = myRides[indexPath.row]
        self.performSegue(withIdentifier: "RideDetailsSegue", sender: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(myRides.count == 0){
            noRidesLabel.isHidden = false
            self.view.bringSubview(toFront: noRidesLabel)
        }
        else{
            noRidesLabel.isHidden = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let rideDetails = segue.destination as? RideDetailsController else {
            return
        }
        rideDetails.RideDetails = self.RideDetails
        return
    }
    
    @IBAction func backButton(_ sender: Any) {
        removeController(controller: self)
    }
    
    func removeController(controller: MyRidesController) {
        controller.dismiss(animated: true, completion: {() -> Void in
        })
    }
}
