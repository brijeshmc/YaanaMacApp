//
//  HelpCentreController.swift
//  yaana
//
//  Created by Brijesh on 16/04/18.
//  Copyright © 2018 Yaana. All rights reserved.
//

import UIKit
import DropDown
import GoogleMaps

class HelpCentreController: UIViewController, CLLocationManagerDelegate {
    var defaultIssues : [IssueDomain]! = []
    var issues : [String]! = []
    let issuesDropDown = DropDown()
    var selectedIssueId = 0
    var latitude : Double! = 0
    var longitude : Double! = 0
    var locationManager = CLLocationManager()

    @IBAction func backButton(_ sender: Any) {
        removeController(controller: self)
    }
    @IBOutlet weak var IssueField: UITextField!
    @IBAction func IssueButtonClicked(_ sender: Any) {
        issuesDropDown.show()
    }
    @IBOutlet weak var IssueButton: UIButton!
    @IBOutlet weak var messageField: UITextView!
    @IBOutlet weak var CycleNumberField: UITextField!
    @IBOutlet weak var CycleNumberErrorLabel: UILabel!
    @IBAction func SubmitButton(_ sender: Any) {
        let qrCodeValid = validateQRCode()
        if(qrCodeValid){
            let userId = KeychainWrapper.standard.integer(forKey: "yaana_user_id")
            let feedbackDomain = FeedbackDomain.init(id: 0, code: "", userId: userId!, rating: 0, qrCode: CycleNumberField.text!, issueId: Int32(selectedIssueId) + 1, location: "\(latitude!),\(longitude!)", message: messageField.text!, resolved: false)
            let feedBackDomainData = try? JSONEncoder.init().encode(feedbackDomain)
            let (urlSession, urlRequest) = self.view.makeHttpRequest(path: "/yaana/feedback",queries: nil, method: "POST", body: feedBackDomainData, accepts: "application/json")
            
            let dataTask = urlSession.dataTask(with: urlRequest)
            {
                ( data: Data?, response: URLResponse?, error: Error?) -> Void in
                guard let httpResponse = response as? HTTPURLResponse, let receivedData = data
                    else {
                        DispatchQueue.main.async(execute: {
                            self.view.makeToast(message: "Unable to connect to server", duration: 2.0, position: HRToastPositionDefault as AnyObject)
                            
                        })
                        return
                }
                
                switch (httpResponse.statusCode)
                {
                case 201:
                    
                    do {
                        let feedBack = try JSONDecoder().decode(FeedbackDomain.self, from: receivedData)
                        let issueCode = feedBack.code
                        DispatchQueue.main.async(execute: {
                            self.showAlert(message: "Issue has been recorded with incident [\(issueCode!)]. Our customer support team will reach out to you shortly.")
                        })
                        
                    } catch {
                        print(error)
                        DispatchQueue.main.async(execute: {
                            self.view.makeToast(message: "Internal Server Error", duration: 2.0, position: HRToastPositionDefault as AnyObject)
                            
                        })
                        return
                    }
                default:
                    do{
                        let errorDomain = try JSONDecoder().decode(ErrorDomain.self, from: receivedData)
                        DispatchQueue.main.async(execute: {
                            if(errorDomain.errorCode != 0){
                                self.view.makeToast(message: errorDomain.errorMessage, duration: 2.0, position: HRToastPositionDefault as AnyObject)
                            }
                            else{
                                self.view.makeToast(message: "Internal Server Error", duration: 2.0, position: HRToastPositionDefault as AnyObject)
                            }
                        })
                    }
                    catch{
                        DispatchQueue.main.async(execute: {
                            self.view.makeToast(message: "Internal Server Error", duration: 2.0, position: HRToastPositionDefault as AnyObject)
                        })
                    }
                }
            }
            dataTask.resume()
        }
    }
    
    func showAlert(message : String){
        let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            switch action.style{
            case .default:
                self.removeController(controller: self)
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
            }}))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageField.layer.borderWidth = 1
        messageField.layer.borderColor = UIColor.black.cgColor
        issuesDropDown.anchorView = IssueButton
        issuesDropDown.dismissMode = .onTap
        issuesDropDown.direction = .any
        issuesDropDown.backgroundColor = UIColor(white: 1, alpha: 1)
        issuesDropDown.bottomOffset = CGPoint(x: 0, y: IssueButton.bounds.height)
        
        for issue in defaultIssues {
            issues.append(issue.description)
        }
        issuesDropDown.dataSource = issues
        issuesDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.IssueField.text = item
            self.selectedIssueId = index
        }
        issuesDropDown.selectRow(at: 0)
        IssueField.text = defaultIssues[0].description
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error" + error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let userLocation = locations.last
        latitude = userLocation!.coordinate.latitude
        longitude = userLocation!.coordinate.longitude
        
        locationManager.stopUpdatingLocation()
    }
    
    func validateQRCode() -> Bool {
        if((selectedIssueId == 0 || selectedIssueId == 1 || selectedIssueId == 2) && CycleNumberField.text?.count == 0){
            CycleNumberField.becomeFirstResponder()
            CycleNumberErrorLabel.isHidden = false
            return false
        }
        CycleNumberErrorLabel.isHidden = true
        return true
    }
    
    func removeController(controller: HelpCentreController) {
        if self.navigationController != nil {
            self.navigationController!.popViewController(animated: true)
        }
        else {
            controller.dismiss(animated: true, completion: {() -> Void in
            })
        }
    }
}

