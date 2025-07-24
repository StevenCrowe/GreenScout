//
//  ImageMetadata.swift
//  GreenScout
//
//  Stores metadata from images including location, date, and camera information
//

import Foundation
import CoreLocation

struct ImageMetadata: Codable {
    // Location data
    let latitude: Double?
    let longitude: Double?
    let altitude: Double?
    let locationAccuracy: Double?
    
    // Time data
    let captureDate: Date?
    let timezone: TimeZone?
    
    // Camera/Device data
    let deviceMake: String?
    let deviceModel: String?
    let lensModel: String?
    
    // Image properties
    let imageWidth: Int?
    let imageHeight: Int?
    let orientation: Int?
    
    // Agricultural context (can be expanded in future)
    let season: String?
    let fieldName: String?  // User can add this later
    let cropType: String?   // User can add this later
    
    // Analysis results reference
    let analysisDate: Date
    let greenCoveragePercentage: Double?
    
    // Computed properties
    var coordinates: CLLocationCoordinate2D? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    var hasLocation: Bool {
        return latitude != nil && longitude != nil
    }
    
    var formattedLocation: String? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return String(format: "%.6f, %.6f", lat, lon)
    }
    
    var formattedCaptureDate: String? {
        guard let date = captureDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var year: Int? {
        guard let date = captureDate else { return nil }
        return Calendar.current.component(.year, from: date)
    }
    
    var month: Int? {
        guard let date = captureDate else { return nil }
        return Calendar.current.component(.month, from: date)
    }
    
    var monthName: String? {
        guard let date = captureDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: date)
    }
    
    var seasonName: String? {
        guard let date = captureDate else { return season }
        let month = Calendar.current.component(.month, from: date)
        
        // Adjust for Southern Hemisphere (Australia)
        switch month {
        case 12, 1, 2:
            return "Summer"
        case 3, 4, 5:
            return "Autumn"
        case 6, 7, 8:
            return "Winter"
        case 9, 10, 11:
            return "Spring"
        default:
            return nil
        }
    }
}

// Extension to create metadata from dictionary
extension ImageMetadata {
    init(from exifData: [String: Any], analysisDate: Date = Date(), greenCoveragePercentage: Double? = nil) {
        // Extract GPS data
        var lat: Double? = nil
        var lon: Double? = nil
        var alt: Double? = nil
        var accuracy: Double? = nil
        
        if let gpsData = exifData["{GPS}"] as? [String: Any] {
            // Latitude
            if let latitudeRef = gpsData["LatitudeRef"] as? String,
               let latitude = gpsData["Latitude"] as? Double {
                lat = latitudeRef == "S" ? -latitude : latitude
            }
            
            // Longitude
            if let longitudeRef = gpsData["LongitudeRef"] as? String,
               let longitude = gpsData["Longitude"] as? Double {
                lon = longitudeRef == "W" ? -longitude : longitude
            }
            
            // Altitude
            if let altitude = gpsData["Altitude"] as? Double {
                alt = altitude
            } else if let altitudeRef = gpsData["AltitudeRef"] as? Int,
                      let altitude = gpsData["Altitude"] as? Double {
                alt = altitudeRef == 1 ? -altitude : altitude  // 1 means below sea level
            }
            
            // Accuracy
            if let hdop = gpsData["HDOP"] as? Double {
                accuracy = hdop
            } else if let dop = gpsData["DOP"] as? Double {
                accuracy = dop
            }
        }
        
        // Extract EXIF data
        var captureDate: Date? = nil
        var deviceMake: String? = nil
        var deviceModel: String? = nil
        var lensModel: String? = nil
        
        if let exifDict = exifData["{Exif}"] as? [String: Any] {
            // Date - try multiple date fields
            if let dateString = exifDict["DateTimeOriginal"] as? String {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
                captureDate = formatter.date(from: dateString)
            } else if let dateString = exifDict["DateTimeDigitized"] as? String {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
                captureDate = formatter.date(from: dateString)
            }
            
            // Lens model
            lensModel = exifDict["LensModel"] as? String ?? exifDict["LensMake"] as? String
        }
        
        // Also check for date in TIFF data
        if captureDate == nil, let tiffData = exifData["{TIFF}"] as? [String: Any] {
            if let dateString = tiffData["DateTime"] as? String {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
                captureDate = formatter.date(from: dateString)
            }
        }
        
        // Extract TIFF data
        var imageWidth: Int? = nil
        var imageHeight: Int? = nil
        var orientation: Int? = nil
        
        if let tiffData = exifData["{TIFF}"] as? [String: Any] {
            deviceMake = tiffData["Make"] as? String
            deviceModel = tiffData["Model"] as? String
            orientation = tiffData["Orientation"] as? Int
            
            // Try to get dimensions from TIFF data
            imageWidth = tiffData["ImageWidth"] as? Int
            imageHeight = tiffData["ImageLength"] as? Int
        }
        
        // If dimensions not found in TIFF, check main dictionary
        if imageWidth == nil || imageHeight == nil {
            imageWidth = imageWidth ?? exifData["PixelWidth"] as? Int
            imageHeight = imageHeight ?? exifData["PixelHeight"] as? Int
            
            // Also check for ExifImageWidth/Height
            if let exifDict = exifData["{Exif}"] as? [String: Any] {
                imageWidth = imageWidth ?? exifDict["PixelXDimension"] as? Int
                imageHeight = imageHeight ?? exifDict["PixelYDimension"] as? Int
            }
        }
        
        // Initialize
        self.latitude = lat
        self.longitude = lon
        self.altitude = alt
        self.locationAccuracy = accuracy
        self.captureDate = captureDate
        self.timezone = TimeZone.current
        self.deviceMake = deviceMake
        self.deviceModel = deviceModel
        self.lensModel = lensModel
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
        self.orientation = orientation
        self.season = nil  // Will be computed
        self.fieldName = nil
        self.cropType = nil
        self.analysisDate = analysisDate
        self.greenCoveragePercentage = greenCoveragePercentage
    }
}

// Storage manager for metadata
class MetadataStorage {
    static let shared = MetadataStorage()
    private let userDefaults = UserDefaults.standard
    private let storageKey = "GreenScoutMetadataHistory"
    
    private init() {}
    
    func save(_ metadata: ImageMetadata) {
        var history = loadAll()
        history.append(metadata)
        
        // Keep only last 1000 entries to avoid excessive storage
        if history.count > 1000 {
            history = Array(history.suffix(1000))
        }
        
        if let encoded = try? JSONEncoder().encode(history) {
            userDefaults.set(encoded, forKey: storageKey)
        }
    }
    
    func loadAll() -> [ImageMetadata] {
        guard let data = userDefaults.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([ImageMetadata].self, from: data) else {
            return []
        }
        return decoded
    }
    
    func loadByLocation(latitude: Double, longitude: Double, radiusMeters: Double = 100) -> [ImageMetadata] {
        let all = loadAll()
        return all.filter { metadata in
            guard let metaLat = metadata.latitude,
                  let metaLon = metadata.longitude else { return false }
            
            let location1 = CLLocation(latitude: latitude, longitude: longitude)
            let location2 = CLLocation(latitude: metaLat, longitude: metaLon)
            
            return location1.distance(from: location2) <= radiusMeters
        }
    }
    
    func loadByDateRange(from startDate: Date, to endDate: Date) -> [ImageMetadata] {
        let all = loadAll()
        return all.filter { metadata in
            guard let captureDate = metadata.captureDate else { return false }
            return captureDate >= startDate && captureDate <= endDate
        }
    }
    
    func loadByYear(_ year: Int) -> [ImageMetadata] {
        let all = loadAll()
        return all.filter { $0.year == year }
    }
    
    func clear() {
        userDefaults.removeObject(forKey: storageKey)
    }
}
