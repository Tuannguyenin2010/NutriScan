struct ProductResponse: Codable {
    let product: FoodProduct
}

struct FoodProduct: Codable {
    let name: String?
    let brands: String?
    let ingredients: String?
    let nutriments: Nutriments
    let imageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case name = "product_name"
        case brands
        case ingredients = "ingredients_text"
        case nutriments
        case imageUrl = "image_url"
    }
}

struct Nutriments: Codable {
    let sugars: Double?
    let energyKcal: Double?
    let fat: Double?
    let saturatedFat: Double?
    let fiber: Double?
    let proteins: Double?
    let salt: Double?
    
    enum CodingKeys: String, CodingKey {
        case sugars
        case energyKcal = "energy-kcal"
        case fat
        case saturatedFat = "saturated-fat"
        case fiber
        case proteins
        case salt
    }
}
