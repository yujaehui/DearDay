//
//  ImageDocumentManager.swift
//  DearDay
//
//  Created by Jaehui Yu on 10/31/24.
//

import Foundation
import SwiftUI

final class ImageDocumentManager {
    static let shared = ImageDocumentManager()
    private init() {}
    
    func saveImageToDocument(image: UIImage, fileName: String) {
        guard let documentDirectory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppGroupID.id) else { return }
        let fileURL = documentDirectory.appendingPathComponent("\(fileName).jpg")
        guard let data = image.pngData() else { return }
        do {
            try data.write(to: fileURL)
        } catch {
            print(error)
        }
    }
    
    func loadImageFromDocument(fileName: String) -> UIImage? {
        guard let documentDirectory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppGroupID.id) else { return nil }
        let fileURL = documentDirectory.appendingPathComponent("\(fileName).jpg")
        if FileManager.default.fileExists(atPath: fileURL.path()) {
            return UIImage(contentsOfFile: fileURL.path())
        } else {
            return nil
        }
    }
    
    func loadImageFromDocument(fileName: String, maxPixelSize: CGFloat) -> UIImage? {
        guard let documentDirectory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppGroupID.id) else { return nil }
        let fileURL = documentDirectory.appendingPathComponent("\(fileName).jpg")
        
        guard FileManager.default.fileExists(atPath: fileURL.path),
              let imageSource = CGImageSourceCreateWithURL(fileURL as CFURL, nil) else { return nil }

        let options: [CFString: Any] = [
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize,
            kCGImageSourceCreateThumbnailFromImageAlways: true
        ]

        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary) else { return nil }

        return UIImage(cgImage: cgImage)
    }
    
    func loadImageFromDocument(fileName: String) async -> UIImage? {
        guard let documentDirectory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppGroupID.id) else { return nil }
        let fileURL = documentDirectory.appendingPathComponent("\(fileName).jpg")
        
        return await Task.detached {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                return UIImage(contentsOfFile: fileURL.path)
            } else {
                return nil
            }
        }.value
    }
    
    func removeImageFromDocument(fileName: String) {
        guard let documentDirectory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppGroupID.id) else { return }
        let fileURL = documentDirectory.appendingPathComponent("\(fileName).jpg")
        if FileManager.default.fileExists(atPath: fileURL.path()) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path())
            } catch {
                print(error)
            }
        } else {
            print("file not exist, remove error")
        }
    }
}
