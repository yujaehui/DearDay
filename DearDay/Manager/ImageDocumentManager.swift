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
        guard let data = image.jpegData(compressionQuality: 1) else { return }
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
    
    func loadImageFromDocument(fileName: String) async -> UIImage? {
        guard let documentDirectory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppGroupID.id) else { return nil }
        
        //try? await Task.sleep(nanoseconds: 1_000_000_000)
        let fileURL = documentDirectory.appendingPathComponent("\(fileName).jpg")

        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {  // 백그라운드에서 실행
                if FileManager.default.fileExists(atPath: fileURL.path()) {
                    let image = UIImage(contentsOfFile: fileURL.path()) // 파일 IO
                    continuation.resume(returning: image)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
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
