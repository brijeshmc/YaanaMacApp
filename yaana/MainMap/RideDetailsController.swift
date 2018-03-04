

import UIKit

class RideDetailsController : UIViewController {
    
    var ToastMessage : String! = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        //edgesForExtendedLayout = []
        //setUpNavBar()
        if(ToastMessage.count > 0){
            self.view.makeToast(message: ToastMessage, duration: 2.0, position: HRToastPositionDefault as AnyObject)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setUpNavBar(){
        //For title in navigation bar
        self.navigationController?.view.backgroundColor = UIColor.orange
        self.navigationController?.view.tintColor = UIColor.white
        self.navigationItem.title = "Ride Details"
        
        //For back button in navigation bar
        let backButton = UIBarButtonItem()
        backButton.title = "Back"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
}
