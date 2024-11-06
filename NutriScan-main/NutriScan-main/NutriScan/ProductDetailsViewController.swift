import UIKit

class ProductDetailsViewController: UIViewController {
    @IBOutlet weak var mainStackView: UIStackView!

    var product: FoodProduct!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let scrollView = mainStackView.superview as? UIScrollView {
            scrollView.contentSize = CGSize(width: scrollView.frame.width, height: mainStackView.frame.height)
        }
    }

    // Dismiss the view controller when the back button is tapped
    @IBAction func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    
    func configureView() {
        mainStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        addProductInfoSection()
        addAllergensSection()
        addNutritionSection()
        addAdditivesSection()
        addRecommendedProductsSection()
    }
    
    private func addProductInfoSection() {
        let productInfoStack = UIStackView()
        productInfoStack.axis = .vertical
        productInfoStack.alignment = .center
        productInfoStack.spacing = 8
        
        let productNameLabel = UILabel()
        productNameLabel.text = product.name ?? "N/A"
        productNameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        productNameLabel.numberOfLines = 0 // Allow wrapping
        productInfoStack.addArrangedSubview(productNameLabel)
        
        let productBrandLabel = UILabel()
        productBrandLabel.text = product.brands ?? "N/A"
        productBrandLabel.font = UIFont.systemFont(ofSize: 16)
        productBrandLabel.textColor = .gray
        productBrandLabel.numberOfLines = 0 // Allow wrapping
        productInfoStack.addArrangedSubview(productBrandLabel)
        
        let productImageView = UIImageView()
        productImageView.contentMode = .scaleAspectFit
        productImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true // Smaller image
        if let urlString = product.imageUrl, let url = URL(string: urlString) {
            let task = URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data {
                    DispatchQueue.main.async {
                        productImageView.image = UIImage(data: data)
                    }
                }
            }
            task.resume()
        }
        productInfoStack.addArrangedSubview(productImageView)
        
        mainStackView.addArrangedSubview(productInfoStack)
    }
    
    private func addAllergensSection() {
        guard let allergens = product.allergens else { return }
        
        let allergensStack = UIStackView()
        allergensStack.axis = .vertical
        allergensStack.spacing = 8
        
        let allergensLabel = UILabel()
        allergensLabel.text = "Allergens"
        allergensLabel.font = UIFont.boldSystemFont(ofSize: 16)
        allergensStack.addArrangedSubview(allergensLabel)
        
        let allergenTagsStack = UIStackView()
        allergenTagsStack.axis = .horizontal
        allergenTagsStack.spacing = 8
        
        for allergen in allergens {
            let allergenLabel = createTagLabel(withText: allergen.capitalized)
            allergenTagsStack.addArrangedSubview(allergenLabel)
        }
        
        allergensStack.addArrangedSubview(allergenTagsStack)
        mainStackView.addArrangedSubview(allergensStack)
    }
    
    private func addNutritionSection() {
        let nutritionStack = UIStackView()
        nutritionStack.axis = .vertical
        nutritionStack.spacing = 8
        
        // Negatives Section
        let negativesLabel = UILabel()
        negativesLabel.text = "Negatives (per 100g)"
        negativesLabel.font = UIFont.boldSystemFont(ofSize: 16)
        nutritionStack.addArrangedSubview(negativesLabel)
        
        if let sugar = product.nutriments.sugars {
            let sugarLabel = createNutrientLabel(withText: "Sugar: \(sugar) g")
            nutritionStack.addArrangedSubview(sugarLabel)
        }
        
        if let calories = product.nutriments.energyKcal {
            let calorieLabel = createNutrientLabel(withText: "Calories: \(calories) kcal")
            nutritionStack.addArrangedSubview(calorieLabel)
        }
        
        if let saturatedFat = product.nutriments.saturatedFat {
            let fatLabel = createNutrientLabel(withText: "Saturated Fat: \(saturatedFat) g")
            nutritionStack.addArrangedSubview(fatLabel)
        }
        
        // Positives Section
        let positivesLabel = UILabel()
        positivesLabel.text = "Positives (per 100g)"
        positivesLabel.font = UIFont.boldSystemFont(ofSize: 16)
        nutritionStack.addArrangedSubview(positivesLabel)
        
        if let fiber = product.nutriments.fiber {
            let fiberLabel = createNutrientLabel(withText: "Fiber: \(fiber) g")
            nutritionStack.addArrangedSubview(fiberLabel)
        }
        
        if let protein = product.nutriments.proteins {
            let proteinLabel = createNutrientLabel(withText: "Protein: \(protein) g")
            nutritionStack.addArrangedSubview(proteinLabel)
        }
        
        mainStackView.addArrangedSubview(nutritionStack)
    }
    
    private func addAdditivesSection() {
        guard let additives = product.additives else { return }
        
        let additivesStack = UIStackView()
        additivesStack.axis = .vertical
        additivesStack.spacing = 8
        
        let additivesLabel = UILabel()
        additivesLabel.text = "Additives"
        additivesLabel.font = UIFont.boldSystemFont(ofSize: 16)
        additivesStack.addArrangedSubview(additivesLabel)
        
        let additivesContentLabel = UILabel()
        additivesContentLabel.text = additives.joined(separator: ", ").capitalized
        additivesContentLabel.font = UIFont.systemFont(ofSize: 14)
        additivesContentLabel.numberOfLines = 0 // Allow wrapping
        additivesStack.addArrangedSubview(additivesContentLabel)
        
        mainStackView.addArrangedSubview(additivesStack)
    }
    
    private func addRecommendedProductsSection() {
        guard let recommendedProducts = product.recommendedProducts else { return }
        
        let recommendedStack = UIStackView()
        recommendedStack.axis = .vertical
        recommendedStack.spacing = 8
        
        let recommendedLabel = UILabel()
        recommendedLabel.text = "Recommended Products"
        recommendedLabel.font = UIFont.boldSystemFont(ofSize: 16)
        recommendedStack.addArrangedSubview(recommendedLabel)
        
        for product in recommendedProducts {
            let productLabel = createTagLabel(withText: product)
            recommendedStack.addArrangedSubview(productLabel)
        }
        
        mainStackView.addArrangedSubview(recommendedStack)
    }
    
    private func createTagLabel(withText text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.backgroundColor = UIColor.systemGray5
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.heightAnchor.constraint(equalToConstant: 30).isActive = true
        label.widthAnchor.constraint(greaterThanOrEqualToConstant: 60).isActive = true
        return label
    }
    
    private func createNutrientLabel(withText text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.numberOfLines = 0 // Allow wrapping
        return label
    }
}
