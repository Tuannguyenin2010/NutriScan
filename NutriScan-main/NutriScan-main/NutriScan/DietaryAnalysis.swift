import Foundation

struct DietaryAnalysis {
    
    enum NutrientLevel: String {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
    }
    
    // Updated thresholds for nutrient levels (per 100g/100ml where applicable)
    private static let sugarThresholds = (low: 5.0, high: 22.5)        // in grams per 100g
    private static let fiberThresholds = (low: 3.0, high: 6.0)         // in grams per 100g
    private static let calorieThresholds = (low: 100.0, high: 300.0)   // in kcal per 100g
    private static let fatThresholds = (low: 3.0, high: 17.5)          // in grams per 100g
    private static let proteinThresholds = (low: 5.0, high: 15.0)      // in grams per 100g
    private static let sodiumThresholds = (low: 140.0, high: 600.0)    // in mg per 100g
    
    // MARK: - Public Functions
    
    static func categorizeSugar(_ value: Double) -> NutrientLevel {
        return categorize(value, thresholds: sugarThresholds)
    }
    
    static func categorizeFiber(_ value: Double) -> NutrientLevel {
        return categorize(value, thresholds: fiberThresholds)
    }
    
    static func categorizeCalories(_ value: Double) -> NutrientLevel {
        return categorize(value, thresholds: calorieThresholds)
    }
    
    static func categorizeFat(_ value: Double) -> NutrientLevel {
        return categorize(value, thresholds: fatThresholds)
    }
    
    static func categorizeProtein(_ value: Double) -> NutrientLevel {
        return categorize(value, thresholds: proteinThresholds)
    }
    
    static func categorizeSodium(_ value: Double) -> NutrientLevel {
        return categorize(value, thresholds: sodiumThresholds)
    }
    
    // MARK: - Helper Function
    
    private static func categorize(_ value: Double, thresholds: (low: Double, high: Double)) -> NutrientLevel {
        if value < thresholds.low {
            return .low
        } else if value < thresholds.high {
            return .medium
        } else {
            return .high
        }
    }
}
