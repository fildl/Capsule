//
//  ImageProcessing.swift
//  Capsule
//
//  Created by Filippo Di Ludovico on 05/12/25.
//

import SwiftUI
import Vision
import CoreImage.CIFilterBuiltins

struct ImageProcessing {
    
    /// Removes the background from the given image data using Apple's Vision framework (iOS 17+).
    /// Returns the PNG data of the image with a transparent background.
    static func removeBackground(from imageData: Data?) async -> Data? {
        guard let imageData = imageData,
              let sourceImage = UIImage(data: imageData) else {
            return nil
        }
        
        // Fix orientation before processing
        let inputImage = fixOrientation(of: sourceImage)
        
        guard let cgImage = inputImage.cgImage else {
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
            print("Background removal requires iOS 17+")
            return imageData
        }
    }

    /// Normalizes the image orientation to .up
    private static func fixOrientation(of image: UIImage) -> UIImage {
        if image.imageOrientation == .up { return image }
        
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: image.size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return normalizedImage ?? image
    }
}
