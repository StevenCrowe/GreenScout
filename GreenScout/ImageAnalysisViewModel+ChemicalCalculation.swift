//
//  ImageAnalysisViewModel+ChemicalCalculation.swift
//  GreenScout
//
//  Extension to add chemical calculation support to ImageAnalysisViewModel
//

import Foundation

extension ImageAnalysisViewModel {
    func prepareForChemicalCalculation() -> (greenCoveragePercent: Double, analysisDate: Date, imageQuality: (score: Double, isAcceptable: Bool))? {
        guard let results = analysisResults else { return nil }
        
        // Calculate image quality score based on resolution
        let score: Double
        let isAcceptable: Bool
        
        // Use the same thresholds as defined in ImageAnalysisViewModel
        let minimumPixels = 1024 * 1024      // 1 megapixel minimum
        let warningPixels = 2048 * 2048      // 4 megapixels warning threshold
        let recommendedPixels = 4096 * 4096  // 16 megapixels recommended
        
        if let image = selectedImage {
            let pixelCount = Int(image.size.width * image.scale) * Int(image.size.height * image.scale)
            
            if pixelCount >= recommendedPixels {
                score = 1.0
                isAcceptable = true
            } else if pixelCount >= warningPixels {
                score = 0.8
                isAcceptable = true
            } else if pixelCount >= minimumPixels {
                score = 0.6
                isAcceptable = true
            } else {
                score = 0.4
                isAcceptable = false
            }
        } else {
            score = 0.5
            isAcceptable = true
        }
        
        return (
            greenCoveragePercent: results.greenPercentage,
            analysisDate: Date(),
            imageQuality: (score: score, isAcceptable: isAcceptable)
        )
    }
}
