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

    @IBAction func loginButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            print("Invalid input")
            return
        }
        if let userProfile = UserProfileManager.getUserProfile(byEmail: email), userProfile.password == password {
            print("User signed in successfully")
            UserDefaults.standard.set(email, forKey: "currentUserEmail")
            checkUserProfile(email: email)
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

    func checkUserProfile(email: String) {
        if let userProfile = UserProfileManager.getUserProfile(byEmail: email) {
            if userProfile.dietaryPreference != nil || userProfile.dietaryRestriction != nil || userProfile.allergens != nil {
                // Profile exists, navigate to the main screen
                navigateToMainScreen(with: userProfile)
            } else {
                // Profile does not exist, navigate to profile creation screen
                navigateToProfileScreen(with: userProfile)
            }
        }
    }

    func navigateToProfileScreen(with userProfile: UserProfile) {
        // Perform segue to ProfileViewController
        performSegue(withIdentifier: "showProfile", sender: userProfile)
    }

    func navigateToMainScreen(with userProfile: UserProfile) {
        // Perform segue to MainViewController
        performSegue(withIdentifier: "showMain", sender: userProfile)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? ProfileViewController,
           let userProfile = sender as? UserProfile {
            destinationVC.userProfile = userProfile
        } else if let destinationVC = segue.destination as? MainViewController,
                  let userProfile = sender as? UserProfile {
            destinationVC.userProfile = userProfile
        }
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
