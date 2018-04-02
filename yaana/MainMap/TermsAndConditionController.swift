import UIKit
import WebKit

class TermsAndConditionController : UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: "http://www.yaana.net.in/terms-and-conditions.php")
        let request = URLRequest(url: url!)
        webView.load(request)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
