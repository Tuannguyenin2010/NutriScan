import UIKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var actionButton1: UIButton! // Action button outlet

    var products: [FoodProduct] = []
    let barcodes = ["737628064502", "3017620422003", "8936017366933", "05942305", "6920766211080", "8850987101083", "059284123455", "063209152826"]
    var userProfile: UserProfile!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 130
        
        if let email = UserDefaults.standard.string(forKey: "currentUserEmail") {
            greetingLabel.text = "Hi \(email)"
            
            // Load the user profile and their specific products
            userProfile = UserProfileManager.getUserProfile(byEmail: email)
            loadProducts()
        } else {
            print("No user logged in")
            greetingLabel.text = "Welcome!"
        }
    }
    
    func loadProducts() {
        guard let email = userProfile?.email else {
            print("No user profile found")
            return
        }
        
        let sanitizedEmail = email.replacingOccurrences(of: ".", with: "_").replacingOccurrences(of: "@", with: "_")
        let fileURL = FileManager.documentsDirectory.appendingPathComponent("\(sanitizedEmail)_products.json")
        
        guard let data = try? Data(contentsOf: fileURL) else {
            print("No products data found for \(email)")
            return
        }
        
        let decoder = JSONDecoder()
        if let loadedProducts = try? decoder.decode([FoodProduct].self, from: data) {
            products = loadedProducts
        }
    }
    
    func saveProducts() {
        guard let email = userProfile?.email else {
            print("No user profile found")
            return
        }
        
        let sanitizedEmail = email.replacingOccurrences(of: ".", with: "_").replacingOccurrences(of: "@", with: "_")
        let fileURL = FileManager.documentsDirectory.appendingPathComponent("\(sanitizedEmail)_products.json")
        
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(products) {
            try? data.write(to: fileURL)
        }
    }
    
    // MARK: - Action Button
    @IBAction func actionButton1Tapped(_ sender: UIButton) {
        generateRandomProduct()
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
                    self.saveProducts()
                    self.tableView.reloadData()
                    self.presentProductDetails(for: productResponse.product)
                }
            } catch let decodeError as NSError {
                print("Error decoding product data: \(decodeError.localizedDescription)")
            }
        }
        
        task.resume()
    }
    
    func presentProductDetails(for product: FoodProduct) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let productDetailsVC = storyboard.instantiateViewController(withIdentifier: "ProductDetailsViewController") as? ProductDetailsViewController {
            productDetailsVC.product = product
            productDetailsVC.modalPresentationStyle = .fullScreen // Present full screen
            present(productDetailsVC, animated: true, completion: nil)
        }
    }
    
    // MARK: - UITableViewDataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as! ProductTableViewCell
        let product = products[indexPath.row]
        cell.configure(with: product)
        return cell
    }
    
    // MARK: - UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let product = products[indexPath.row]
        presentProductDetails(for: product)
    }
}
