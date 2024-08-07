import UIKit

class CreateAccountViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var togglePasswordVisibilityButton: UIButton!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!

    private var isPasswordVisible = false

    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        emailErrorLabel.isHidden = true
        passwordErrorLabel.isHidden = true

        setupPasswordVisibilityToggle()
        setupTapGesture()
    }

    private func setupPasswordVisibilityToggle() {
        togglePasswordVisibilityButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        togglePasswordVisibilityButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        passwordTextField.isSecureTextEntry = true
    }

    @objc private func togglePasswordVisibility() {
        isPasswordVisible.toggle()
        passwordTextField.isSecureTextEntry = !isPasswordVisible
        let imageName = isPasswordVisible ? "eye" : "eye.slash"
        togglePasswordVisibilityButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func createAccountButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            print("Invalid input")
            return
        }
        if password.count < 6 {
            passwordTextField.layer.borderWidth = 1.0
            passwordTextField.layer.borderColor = UIColor.red.cgColor
            passwordErrorLabel.text = "Password must have 6 or more characters"
            passwordErrorLabel.isHidden = false
            return
        }
        
        if UserProfileManager.getUserProfile(byEmail: email) != nil {
            emailTextField.layer.borderWidth = 1.0
            emailTextField.layer.borderColor = UIColor.red.cgColor
            emailErrorLabel.text = "This email address is already used!"
            emailErrorLabel.isHidden = false
        } else {
            let userProfile = UserProfile(email: email, password: password)
            UserProfileManager.saveUserProfile(userProfile)
            print("User created successfully")
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 0
        textField.layer.borderColor = UIColor.clear.cgColor
        if textField == emailTextField {
            emailErrorLabel.isHidden = true
        } else if textField == passwordTextField {
            passwordErrorLabel.isHidden = true
        }
    }
}
