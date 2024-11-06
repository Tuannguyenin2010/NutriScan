import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

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

    @IBAction func loginButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            print("Invalid input")
            return
        }
        
        if let userProfile = UserProfileManager.getUserProfile(byEmail: email), userProfile.password == password {
            UserDefaults.standard.set(email, forKey: "currentUserEmail")
            
            if userProfile.dietaryPreference == nil || userProfile.dietaryPreference!.isEmpty,
               userProfile.dietaryRestriction == nil || userProfile.dietaryRestriction!.isEmpty,
               userProfile.allergens == nil || userProfile.allergens!.isEmpty {
                // New user with no profile setup, navigate to ProfileViewController
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
                profileVC.userProfile = userProfile
                navigationController?.pushViewController(profileVC, animated: true)
            } else {
                // Existing user, navigate to main interface
                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                    sceneDelegate.switchToMainInterface()
                }
            }
        } else {
            handleLoginError()
        }
    }


    func handleLoginError() {
        emailTextField.layer.borderWidth = 1.0
        emailTextField.layer.borderColor = UIColor.red.cgColor
        emailErrorLabel.text = "Invalid email or password!"
        emailErrorLabel.isHidden = false
    }

    // Ensure to reset text fields and hide error labels when editing begins
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
