import UIKit

class RegisterController : UIViewController {
    
    @IBOutlet weak var displayName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var mobileNumber: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var dateOfBirth: UITextField!
    
    @IBOutlet weak var displayNameErrorLabel: UILabel!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var mobileNumberErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var confirmPasswordErrorLabel: UILabel!
    @IBOutlet weak var dobErrorLabel: UILabel!
    
    var displayNameValue : String = ""
    var emailValue : String = ""
    var mobileNumberValue : String = ""
    var passwordValue : String = ""
    var confirmPasswordValue : String = ""
    var dateOfBirthValue : String = ""
    
    @IBAction func dateOfBirthTapped(_ sender: UITextField) {
        let datePickerView  : UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(self.handleDatePicker(sender:)), for: UIControlEvents.valueChanged)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateOfBirth.text = dateFormatter.string(from: datePickerView.date)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayName.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func registerButtonClick(_ sender: Any) {
        displayNameValue = displayName.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        emailValue = email.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        mobileNumberValue = mobileNumber.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        passwordValue = password.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        confirmPasswordValue = confirmPassword.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        dateOfBirthValue = dateOfBirth.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        let isDobValid = validateDateOfBirth(dateOfBirthValue : dateOfBirthValue)
        let isConfirmPasswordValid = validateConfirmPassword(confirmPasswordValue: confirmPasswordValue, password: passwordValue)
        let isPasswordValid = validatePassword(passwordValue: passwordValue)
        let isMobileNumberValid = validateMobileNumber(mobileNumberValue: mobileNumberValue)
        let isEmailValid = validateEmail(emailValue: emailValue)
        let isDisplayNameValid = validateDisplayName(displayNameValue : displayNameValue)

        if(isDobValid && isConfirmPasswordValid && isPasswordValid && isMobileNumberValid && isEmailValid && isDisplayNameValid){
            
        }
    }
    
    func validateDisplayName(displayNameValue : String) -> Bool{
        
        if(displayNameValue.count == 0){
            displayNameErrorLabel.text = "Display name is required"
            displayNameErrorLabel.isHidden = false
            displayName.becomeFirstResponder()
            return false
        }
        else{
            let namePattern = "^[a-zA-Z]+[ a-zA-Z]*$";
            let namePredicate = NSPredicate(format:"SELF MATCHES %@", namePattern)
            if(!namePredicate.evaluate(with: displayNameValue)){
                displayNameErrorLabel.text = "Numeric and special charecters not allowed"
                displayNameErrorLabel.isHidden = false
                displayName.becomeFirstResponder()
                return false
            }
            else{
                if(displayNameValue.count > 20){
                    displayNameErrorLabel.text = "Maximum 20 charecters allowed"
                    displayNameErrorLabel.isHidden = false
                    displayName.becomeFirstResponder()
                    return false
                }
            }
        }
        displayNameErrorLabel.isHidden = true
        return true
    }
    
    func validateEmail(emailValue : String) -> Bool{
        
        if(emailValue.count == 0){
            emailErrorLabel.text = "Email is required"
            emailErrorLabel.isHidden = false
            email.becomeFirstResponder()
            return false
        }
        else{
            let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailPattern)
            if(!emailPredicate.evaluate(with: emailValue)){
                emailErrorLabel.text = "Invalid email"
                emailErrorLabel.isHidden = false
                email.becomeFirstResponder()
                return false
            }
            else{
                if(emailValue.count > 256){
                    emailErrorLabel.text = "Maximum 256 charecters allowed"
                    emailErrorLabel.isHidden = false
                    email.becomeFirstResponder()
                    return false
                }
            }
        }
        emailErrorLabel.isHidden = true
        return true
    }
    
    func validateMobileNumber(mobileNumberValue : String) -> Bool{
        
        if(mobileNumberValue.count == 0){
            mobileNumberErrorLabel.text = "Mobile number is required"
            mobileNumberErrorLabel.isHidden = false
            mobileNumber.becomeFirstResponder()
            return false
        }
        else{
            let mobilePattern : String = "[0-9]{10}";
            let mobilePredicate = NSPredicate(format:"SELF MATCHES %@", mobilePattern)
            if(!mobilePredicate.evaluate(with: mobileNumberValue)){
                mobileNumberErrorLabel.text = "Invalid mobile number"
                mobileNumberErrorLabel.isHidden = false
                mobileNumber.becomeFirstResponder()
                return false
            }
        }
        mobileNumberErrorLabel.isHidden = true
        return true
    }
    
    func validatePassword(passwordValue : String) -> Bool{
        
        if(passwordValue.count == 0){
            passwordErrorLabel.text = "Password is required"
            passwordErrorLabel.isHidden = false
            password.becomeFirstResponder()
            return false
        }
        else{
            if(passwordValue.count > 50){
                passwordErrorLabel.text = "Maximum 50 charecters allowed"
                passwordErrorLabel.isHidden = false
                password.becomeFirstResponder()
                return false
            }
        }
        passwordErrorLabel.isHidden = true
        return true
    }
    
    func validateConfirmPassword(confirmPasswordValue : String, password : String) -> Bool{
        
        if(confirmPasswordValue.count == 0){
            confirmPasswordErrorLabel.text = "Confirm password is required"
            confirmPasswordErrorLabel.isHidden = false
            confirmPassword.becomeFirstResponder()
            return false
        }
        else{
            if(confirmPasswordValue != password){
                confirmPasswordErrorLabel.text = "Password and Confirm password do not match"
                confirmPasswordErrorLabel.isHidden = false
                confirmPassword.becomeFirstResponder()
                return false
            }
        }
        confirmPasswordErrorLabel.isHidden = true
        return true
    }
    
    func validateDateOfBirth(dateOfBirthValue : String) -> Bool {
        
        dobErrorLabel.isHidden = true
        return true
    }
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateOfBirth.text = dateFormatter.string(from: sender.date)
    }
}