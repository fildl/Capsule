//
//  ImageProcessing.swift
//  Capsule
//
//  Created by Capsule Assistant on 05/12/25.
//

import SwiftUI
import Vision
import CoreImage.CIFilterBuiltins

struct ImageProcessing {
    
    /// Removes the background from the given image data using Apple's Vision framework (iOS 17+).
    /// Returns the PNG data of the image with a transparent background.
    static func removeBackground(from imageData: Data?) async -> Data? {
        guard let imageData = imageData,
              let inputImage = UIImage(data: imageData),
              let cgImage = inputImage.cgImage else {
            return nil
        }
        
        // This request is available from iOS 17.0
        if #available(iOS 17.0, *) {
            let request = VNGenerateForegroundInstanceMaskRequest()
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try handler.perform([request])
                guard let result = request.results?.first else {
                    print("No background removal result")
                    return nil
                }
                
                let maskPixelBuffer = try result.generateMaskedImage(ofInstances: result.allInstances, from: handler, croppedToInstancesExtent: false)
                
                let ciImage = CIImage(cvPixelBuffer: maskPixelBuffer)
                
                // The result from Vision is the masked image directly if using generateMaskedImage,
                // mostly usually it returns the image with alpha channel.
                
                let context = CIContext()
                guard let cgOutput = context.createCGImage(ciImage, from: ciImage.extent) else {
                    return nil
                }
                
                let finalImage = UIImage(cgImage: cgOutput)
                return finalImage.pngData()
                
            } catch {
                print("Vision Background Removal Failed: \(error)")
                return nil
            }
        } else {
            // Fallback for older iOS versions (simple Center or just return original)
            // Ideally we shouldn't be here if we target iOS 17
            print("Background removal requires iOS 17+")
            return imageData
        }
    }
}
