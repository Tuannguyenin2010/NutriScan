import Foundation

extension FileManager {
    static var documentsDirectory: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

struct UserProfile: Codable {
    var email: String
    var password: String
    var dietaryPreference: [String: String]?
    var dietaryRestriction: [String]?
    var allergens: [String]?
}

class UserProfileManager {
    private static let fileName = "userProfiles.json"
    
    static func saveUserProfile(_ profile: UserProfile) {
        var profiles = loadUserProfiles()
        if let index = profiles.firstIndex(where: { $0.email == profile.email }) {
            profiles[index] = profile
        } else {
            profiles.append(profile)
        }
        saveUserProfiles(profiles)
    }
    
    static func loadUserProfiles() -> [UserProfile] {
        let fileURL = FileManager.documentsDirectory.appendingPathComponent(fileName)
        guard let data = try? Data(contentsOf: fileURL) else { return [] }
        let decoder = JSONDecoder()
        return (try? decoder.decode([UserProfile].self, from: data)) ?? []
    }
    
    static func getUserProfile(byEmail email: String) -> UserProfile? {
        return loadUserProfiles().first { $0.email == email }
    }
    
    private static func saveUserProfiles(_ profiles: [UserProfile]) {
        let fileURL = FileManager.documentsDirectory.appendingPathComponent(fileName)
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(profiles) {
            try? data.write(to: fileURL)
        }
    }
}
