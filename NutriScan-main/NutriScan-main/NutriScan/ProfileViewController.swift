import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var dietaryPreferenceButton: UIButton!
    @IBOutlet weak var dietaryRestrictionButton: UIButton!
    @IBOutlet weak var allergensButton: UIButton!
    @IBOutlet weak var selectionTableView: UITableView!
    @IBOutlet weak var skipButton: UIButton!
    
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
    var userProfile: UserProfile! // Make sure this is set before using it
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectionTableView.delegate = self
        selectionTableView.dataSource = self
        selectionTableView.isHidden = true
        
        if let email = userProfile?.email {
            greetingLabel.text = "Hello \(email), for us to assist you with your diet, please choose your:"
        }
        
        loadProfileData()
    }
    
    func loadProfileData() {
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
    
    @IBAction func skipButtonTapped(_ sender: UIButton) {
        navigateToMainScreen()
    }
    
    func saveProfile() {
        userProfile.dietaryPreference = selectedDietaryPreferences
        userProfile.dietaryRestriction = Array(selectedDietaryRestrictions)
        userProfile.allergens = Array(selectedAllergens)
        
        UserProfileManager.saveUserProfile(userProfile)
        print("Profile saved successfully")
        navigateToMainScreen()
    }
    
    func navigateToMainScreen() {
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.switchToMainInterface()
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
            cell.textLabel?.text = dietaryPreferences[indexPath.section].1[indexPath.row]
            if let category = dietaryPreferences[indexPath.section].0 as String?,
               let selectedValue = selectedDietaryPreferences[category],
               selectedValue == dietaryPreferences[indexPath.section].1[indexPath.row] {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        case .dietaryRestriction:
            cell.textLabel?.text = dietaryRestrictions[indexPath.row]
            cell.accessoryType = selectedDietaryRestrictions.contains(dietaryRestrictions[indexPath.row]) ? .checkmark : .none
        case .allergens:
            cell.textLabel?.text = allergens[indexPath.row]
            cell.accessoryType = selectedAllergens.contains(allergens[indexPath.row]) ? .checkmark : .none
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
