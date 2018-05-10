import UIKit
import WebKit

class AboutUsController : UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: "http://www.yaana.net.in/about.php")
        let request = URLRequest(url: url!)
        webView.load(request)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButton(_ sender: Any) {
        removeController(controller: self)
    }
    func removeController(controller: AboutUsController) {
        controller.dismiss(animated: true, completion: {() -> Void in
        })
    }
}
