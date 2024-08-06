import UIKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var actionButton1: UIButton!
    @IBOutlet weak var actionButton2: UIButton!
    
    var products: [FoodProduct] = []
    let barcodes = ["737628064502", "3017620422003", "8936017366933", "05942305", "6920766211080", "8850987101083", "059284123455", "063209152826"]
    var userProfile: UserProfile!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 130
        
        guard let email = userProfile?.email else {
            fatalError("UserProfile email is nil")
        }
        
        greetingLabel.text = "Hi \(email)"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), style: .plain, target: self, action: #selector(showMenu))
        
        navigationItem.hidesBackButton = true
        
        loadProducts(for: email)
    }
    
    @objc func showMenu() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let profileAction = UIAlertAction(title: "Profile", style: .default) { _ in
            self.performSegue(withIdentifier: "showProfile", sender: self.userProfile)
        }
        
        let signOutAction = UIAlertAction(title: "Sign Out", style: .destructive) { _ in
            self.signOut()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(profileAction)
        alert.addAction(signOutAction)
        alert.addAction(cancelAction)
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    func signOut() {
        UserDefaults.standard.removeObject(forKey: "currentUserEmail")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        let navigationController = UINavigationController(rootViewController: loginViewController)
        navigationController.modalPresentationStyle = .fullScreen
        self.view.window?.rootViewController = navigationController
        self.view.window?.makeKeyAndVisible()
    }
    
    @IBAction func actionButton1Tapped(_ sender: UIButton) {
        generateRandomProduct()
    }
    
    @IBAction func actionButton2Tapped(_ sender: UIButton) {
        let scanVC = ScanViewController()
        navigationController?.pushViewController(scanVC, animated: true)
    }
    
    // MARK: - UITableViewDataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Number of products: \(products.count)")
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Dequeuing cell for row \(indexPath.row)")
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as! ProductTableViewCell
        let product = products[indexPath.row]
        print("Configuring cell with product: \(product)")
        cell.configure(with: product)
        return cell
    }
    
    // MARK: - UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let product = products[indexPath.row]
        performSegue(withIdentifier: "showProductDetails", sender: product)
    }
    
    func generateRandomProduct() {
        let randomBarcode = barcodes.randomElement()!
        let urlString = "https://world.openfoodfacts.net/api/v2/product/\(randomBarcode)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error fetching product: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data returned")
                return
            }
            
            do {
                let productResponse = try JSONDecoder().decode(ProductResponse.self, from: data)
                DispatchQueue.main.async {
                    self.products.append(productResponse.product)
                    self.saveProducts(for: self.userProfile.email)
                    self.tableView.reloadData()
                    self.performSegue(withIdentifier: "showProductDetails", sender: productResponse.product)
                }
            } catch let decodeError as NSError {
                print("Error decoding product data: \(decodeError.localizedDescription)")
            }
        }
        
        task.resume()
    }
    
    func loadProducts(for email: String) {
        let sanitizedEmail = email.replacingOccurrences(of: ".", with: "_").replacingOccurrences(of: "@", with: "_")
        let fileURL = FileManager.documentsDirectory.appendingPathComponent("\(sanitizedEmail)_products.json")
        guard let data = try? Data(contentsOf: fileURL) else { return }
        let decoder = JSONDecoder()
        if let loadedProducts = try? decoder.decode([FoodProduct].self, from: data) {
            products = loadedProducts
        }
    }
    
    func saveProducts(for email: String) {
        let sanitizedEmail = email.replacingOccurrences(of: ".", with: "_").replacingOccurrences(of: "@", with: "_")
        let fileURL = FileManager.documentsDirectory.appendingPathComponent("\(sanitizedEmail)_products.json")
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(products) {
            try? data.write(to: fileURL)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProductDetails",
           let productDetailsVC = segue.destination as? ProductDetailsViewController,
           let product = sender as? FoodProduct {
            productDetailsVC.product = product
        } else if segue.identifier == "showProfile",
                  let profileVC = segue.destination as? ProfileViewController {
            profileVC.userProfile = userProfile
        }
    }
}
