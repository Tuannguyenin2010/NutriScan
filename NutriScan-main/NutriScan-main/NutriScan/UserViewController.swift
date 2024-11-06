import UIKit

class UserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var dietaryPreferenceButton: UIButton!
    @IBOutlet weak var dietaryRestrictionButton: UIButton!
    @IBOutlet weak var allergensButton: UIButton!
    @IBOutlet weak var selectionTableView: UITableView!
    @IBOutlet weak var signOutButton: UIButton! // Sign-Out button added in the storyboard
    
    let dietaryPreferences = [
        ("Calories", ["Low", "Medium", "High"]),
        ("Protein", ["Low", "Medium", "High"]),
        ("Saturated Fat", ["Low", "Medium", "High"]),
        ("Sugar", ["Low", "Medium", "High"]),
        ("Fibre", ["Low", "Medium", "High"]),
        ("Sodium", ["Low", "Medium", "High"]),
        ("Fruits, Veggies, Nuts", ["Low", "Medium", "High"])
    ]
    
    let dietaryRestrictions = ["Vegan", "Vegetarian", "Palm Oil Free"]
    let allergens = [
        "Gluten", "Crustaceans", "Egg", "Fish", "Red caviar", "Orange", "Kiwi",
        "Banana", "Peach", "Apple", "Beef", "Pork", "Chicken", "Yamaimo", "Gelatin",
        "Matsutake", "Peanuts", "Soybeans", "Milk", "Nuts", "Celery", "Mustard",
        "Sesame", "Sulphur dioxide and sulphites", "Lupin", "Molluscs"
    ]
    
    var selectedDietaryPreferences = [String: String]()
    var selectedDietaryRestrictions = Set<String>()
    var selectedAllergens = Set<String>()
    
    var currentSelectionType: SelectionType?
    var userProfile: UserProfile!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectionTableView.delegate = self
        selectionTableView.dataSource = self
        selectionTableView.isHidden = true

        if let email = UserDefaults.standard.string(forKey: "currentUserEmail") {
            greetingLabel.text = "Hello \(email), here are your dietary settings:"
            
            // Load user profile based on the current email
            userProfile = UserProfileManager.getUserProfile(byEmail: email)
            
            if userProfile == nil {
                print("No profile found for user \(email)")
                userProfile = UserProfile(email: email, password: "", dietaryPreference: [:], dietaryRestriction: [], allergens: [])
                UserProfileManager.saveUserProfile(userProfile)
            }
            
            loadProfileData()
        } else {
            print("No user logged in")
            greetingLabel.text = "No user logged in"
        }
    }
    
    func loadProfileData() {
        // Load the existing user profile data and set selections accordingly
        guard let profile = UserProfileManager.getUserProfile(byEmail: userProfile.email) else {
            print("No profile data found for \(userProfile.email)")
            return
        }
        
        selectedDietaryPreferences = profile.dietaryPreference ?? [:]
        selectedDietaryRestrictions = Set(profile.dietaryRestriction ?? [])
        selectedAllergens = Set(profile.allergens ?? [])
    }

    @IBAction func dietaryPreferenceButtonTapped(_ sender: UIButton) {
        currentSelectionType = .dietaryPreference
        selectionTableView.reloadData()
        selectionTableView.isHidden = false
    }
    
    @IBAction func dietaryRestrictionButtonTapped(_ sender: UIButton) {
        currentSelectionType = .dietaryRestriction
        selectionTableView.reloadData()
        selectionTableView.isHidden = false
    }
    
    @IBAction func allergensButtonTapped(_ sender: UIButton) {
        currentSelectionType = .allergens
        selectionTableView.reloadData()
        selectionTableView.isHidden = false
    }
    
    @IBAction func saveProfileButtonTapped(_ sender: UIButton) {
        saveProfile()
    }

    func saveProfile() {
        userProfile.dietaryPreference = selectedDietaryPreferences
        userProfile.dietaryRestriction = Array(selectedDietaryRestrictions)
        userProfile.allergens = Array(selectedAllergens)
        
        UserProfileManager.saveUserProfile(userProfile)
        print("Profile saved successfully")
        
        let alert = UIAlertController(title: "Success", message: "Your profile has been saved.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Sign-Out Action
    @IBAction func signOutTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Sign Out", message: "Are you sure you want to sign out?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive) { _ in
            self.performSignOut()
        })
        
        present(alert, animated: true, completion: nil)
    }
    
    private func performSignOut() {
        // Remove the current user's email from UserDefaults
        UserDefaults.standard.removeObject(forKey: "currentUserEmail")
        
        // Transition back to the LoginViewController
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            let navigationController = UINavigationController(rootViewController: loginVC)
            
            sceneDelegate.window?.rootViewController = navigationController
            sceneDelegate.window?.makeKeyAndVisible()
            
            // Optional transition animation
            UIView.transition(with: sceneDelegate.window!, duration: 0.5, options: .transitionFlipFromLeft, animations: nil, completion: nil)
        }
    }

    // MARK: - UITableViewDataSource Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        if currentSelectionType == .dietaryPreference {
            return dietaryPreferences.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentSelectionType {
        case .dietaryPreference:
            return dietaryPreferences[section].1.count
        case .dietaryRestriction:
            return dietaryRestrictions.count
        case .allergens:
            return allergens.count
        case .none:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if currentSelectionType == .dietaryPreference {
            return dietaryPreferences[section].0
        }
        return nil
    }
    
    // MARK: - UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        switch currentSelectionType {
        case .dietaryPreference:
            let category = dietaryPreferences[indexPath.section].0
            let option = dietaryPreferences[indexPath.section].1[indexPath.row]
            cell.textLabel?.text = option
            
            if selectedDietaryPreferences[category] == option {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            
        case .dietaryRestriction:
            let restriction = dietaryRestrictions[indexPath.row]
            cell.textLabel?.text = restriction
            cell.accessoryType = selectedDietaryRestrictions.contains(restriction) ? .checkmark : .none
            
        case .allergens:
            let allergen = allergens[indexPath.row]
            cell.textLabel?.text = allergen
            cell.accessoryType = selectedAllergens.contains(allergen) ? .checkmark : .none
            
        case .none:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch currentSelectionType {
        case .dietaryPreference:
            let category = dietaryPreferences[indexPath.section].0
            let preference = dietaryPreferences[indexPath.section].1[indexPath.row]
            selectedDietaryPreferences[category] = preference
            tableView.reloadData()
            
        case .dietaryRestriction:
            let restriction = dietaryRestrictions[indexPath.row]
            if selectedDietaryRestrictions.contains(restriction) {
                selectedDietaryRestrictions.remove(restriction)
            } else {
                selectedDietaryRestrictions.insert(restriction)
            }
            tableView.reloadRows(at: [indexPath], with: .automatic)
            
        case .allergens:
            let allergen = allergens[indexPath.row]
            if selectedAllergens.contains(allergen) {
                selectedAllergens.remove(allergen)
            } else {
                selectedAllergens.insert(allergen)
            }
            tableView.reloadRows(at: [indexPath], with: .automatic)
            
        case .none:
            break
        }
    }
}
