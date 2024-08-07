import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let currentUserEmail = getCurrentUserEmail() {
            // User is signed in
            let mainViewController = storyboard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
            mainViewController.userProfile = UserProfileManager.getUserProfile(byEmail: currentUserEmail)
            let navigationController = UINavigationController(rootViewController: mainViewController)
            window?.rootViewController = navigationController
        } else {
            // No user is signed in
            let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            window?.rootViewController = loginViewController
        }
        
        window?.makeKeyAndVisible()
        return true
    }

    // Function to get the current user's email
    func getCurrentUserEmail() -> String? {
        // Retrieve the current user's email from UserDefaults or another local storage solution
        return UserDefaults.standard.string(forKey: "currentUserEmail")
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
