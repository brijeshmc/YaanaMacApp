

import UIKit

class RideDetailsController : UIViewController {
    
    var ToastMessage : String! = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        if(ToastMessage.count > 0){
            self.view.makeToast(message: ToastMessage, duration: 2.0, position: HRToastPositionDefault as AnyObject)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
