import UIKit

class ProductTableViewCell: UITableViewCell {
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productBrandLabel: UILabel!
    @IBOutlet weak var statusIndicatorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Set status indicator to be a circle
        statusIndicatorView.layer.cornerRadius = statusIndicatorView.frame.size.width / 2
        statusIndicatorView.clipsToBounds = true
    }
    
    func configure(with product: FoodProduct) {
        productNameLabel.text = product.name ?? "N/A"
        productBrandLabel.text = product.brands ?? "N/A"
        
        // Load image from product.imageUrl
        if let urlString = product.imageUrl, let url = URL(string: urlString) {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async {
                    self.productImageView.image = UIImage(data: data)
                }
            }
            task.resume()
        }
        
        // Example logic for setting the status indicator
        if let energyKcal = product.nutriments.energyKcal, energyKcal > 300 {
            statusIndicatorView.backgroundColor = .red
        } else {
            statusIndicatorView.backgroundColor = .green
        }
    }
}
