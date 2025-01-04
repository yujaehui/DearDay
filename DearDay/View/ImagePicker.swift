//
//  ImagePicker.swift
//  DearDay
//
//  Created by Jaehui Yu on 12/9/24.
//

import SwiftUI
import PhotosUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Binding var isImageSelected: Bool
    var targetSize: CGSize = UIScreen.main.bounds.size
    var scale: CGFloat = UIScreen.main.scale
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, targetSize: targetSize, scale: scale)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        let targetSize: CGSize
        let scale: CGFloat
        
        init(_ parent: ImagePicker, targetSize: CGSize, scale: CGFloat) {
            self.parent = parent
            self.targetSize = targetSize
            self.scale = scale
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let provider = results.first?.itemProvider, provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) else {
                parent.isImageSelected = false // 이미지가 선택되지 않은 경우
                return
            }
            
            parent.isImageSelected = true // 이미지가 선택된 경우
            provider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { [weak self] url, error in
                guard let self = self, let url = url else { return }
                
                let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(url.lastPathComponent)
                do {
                    try FileManager.default.copyItem(at: url, to: tempURL)
                    
                    let downsampledImage = self.downsampleImage(at: tempURL, to: self.targetSize, scale: self.scale)
                    
                    DispatchQueue.main.async {
                        self.parent.selectedImage = downsampledImage
                    }
                    
                    try FileManager.default.removeItem(at: tempURL)
                } catch {
                    print("Error handling image file: \(error)")
                }
            }
        }
        
        private func downsampleImage(at imageURL: URL, to pointSize: CGSize, scale: CGFloat) -> UIImage {
            let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
            guard let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, imageSourceOptions) else {
                return UIImage()
            }
            
            let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
            let downsampleOptions = [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceShouldCacheImmediately: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
            ] as CFDictionary
            
            guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
                return UIImage()
            }
            
            return UIImage(cgImage: downsampledImage)
        }
    }
}
