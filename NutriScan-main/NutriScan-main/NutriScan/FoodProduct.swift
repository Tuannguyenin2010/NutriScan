struct ProductResponse: Codable {
    let product: FoodProduct
}

struct FoodProduct: Codable {
    let name: String?
    let brands: String?
    let imageUrl: String?
    let nutriments: Nutriments
    let allergens: [String]?
    let additives: [String]?
    let recommendedProducts: [String]?

    enum CodingKeys: String, CodingKey {
        case name = "product_name"
        case brands
        case imageUrl = "image_url"
        case nutriments
        case allergens = "allergens_tags"
        case additives = "additives_tags"
        case recommendedProducts = "recommended_products"
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
        case sugars = "sugars_100g"
        case energyKcal = "energy-kcal_100g"
        case fat = "fat_100g"
        case saturatedFat = "saturated-fat_100g"
        case fiber = "fiber_100g"
        case proteins = "proteins_100g"
        case salt = "salt_100g"
    }
}
