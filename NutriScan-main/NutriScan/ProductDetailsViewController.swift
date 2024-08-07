import UIKit

class ProductDetailsViewController: UIViewController {
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productBrandLabel: UILabel!
    @IBOutlet weak var negativesStackView: UIStackView!
    @IBOutlet weak var positivesStackView: UIStackView!
    @IBOutlet weak var statusIndicatorView: UIView!
    
    var product: FoodProduct!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Set status indicator to be a circle
        statusIndicatorView.layer.cornerRadius = statusIndicatorView.frame.size.width / 2
        statusIndicatorView.clipsToBounds = true
    }
    
    func configureView() {
        productNameLabel.text = product.name ?? "N/A"
        productBrandLabel.text = product.brands ?? "N/A"
        
        if let urlString = product.imageUrl, let url = URL(string: urlString) {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async {
                    self.productImageView.image = UIImage(data: data)
                }
            }
            task.resume()
        }
        
        // Set status indicator based on energyKcal
        if let energyKcal = product.nutriments.energyKcal, energyKcal > 300 {
            statusIndicatorView.backgroundColor = .red
        } else {
            statusIndicatorView.backgroundColor = .green
        }
        
        // Clear previous views
        negativesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        positivesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add headers
        addSectionHeader(to: positivesStackView, withText: "Positives")
        addSectionHeader(to: negativesStackView, withText: "Negatives")
        
        // Populate positives
        if let fiber = product.nutriments.fiber {
            addNutrientLabel(to: positivesStackView, withText: "Fiber: \(fiber) g")
        }
        
        if let proteins = product.nutriments.proteins {
            addNutrientLabel(to: positivesStackView, withText: "Proteins: \(proteins) g")
        }
        
        // Populate negatives
        if let sugars = product.nutriments.sugars {
            addNutrientLabel(to: negativesStackView, withText: "Sugar: \(sugars) g")
        }
        
        if let energy = product.nutriments.energyKcal {
            addNutrientLabel(to: negativesStackView, withText: "Calories: \(energy) kcal")
        }
        
        if let saturatedFat = product.nutriments.saturatedFat {
            addNutrientLabel(to: negativesStackView, withText: "Saturated Fat: \(saturatedFat) g")
        }
        
        if let salt = product.nutriments.salt {
            addNutrientLabel(to: negativesStackView, withText: "Sodium: \(salt) g")
        }
    }
    
    func addSectionHeader(to stackView: UIStackView, withText text: String) {
        let headerLabel = UILabel()
        headerLabel.text = text
        headerLabel.font = UIFont.boldSystemFont(ofSize: 24)
        stackView.addArrangedSubview(headerLabel)
        // Add a smaller invisible view for spacing between header and first item
        let smallSpacingView = UIView()
        smallSpacingView.heightAnchor.constraint(equalToConstant: 2).isActive = true
        stackView.addArrangedSubview(smallSpacingView)
    }
    
    func addNutrientLabel(to stackView: UIStackView, withText text: String) {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 20)
        label.numberOfLines = 0
        stackView.addArrangedSubview(label)
        // Add a larger invisible view for spacing between items
        let largeSpacingView = UIView()
        largeSpacingView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        stackView.addArrangedSubview(largeSpacingView)
    }
}
