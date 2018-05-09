import UIKit
import WebKit

class AboutUsController : UIViewController {
    
    @IBAction func backButton(_ sender: Any) {
        removeController(controller: self)
    }
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
    
    func removeController(controller: AboutUsController) {
        if self.navigationController != nil {
            self.navigationController!.popViewController(animated: true)
        }
        else {
            controller.dismiss(animated: true, completion: {() -> Void in
            })
        }
    }
}
