////
////  ImagePicker.swift
////  DearDay
////
////  Created by Jaehui Yu on 12/9/24.
////
//
//import SwiftUI
//import PhotosUI
//
//struct ImagePicker: UIViewControllerRepresentable {
//    @Binding var selectedImage: UIImage?
//    @Binding var isImageSelected: Bool
//    
//    func makeUIViewController(context: Context) -> PHPickerViewController {
//        var configuration = PHPickerConfiguration()
//        configuration.filter = .images
//        configuration.selectionLimit = 1
//        
//        let picker = PHPickerViewController(configuration: configuration)
//        picker.delegate = context.coordinator
//        return picker
//    }
//    
//    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//    
//    class Coordinator: NSObject, PHPickerViewControllerDelegate {
//        let parent: ImagePicker
//        
//        init(_ parent: ImagePicker) {
//            self.parent = parent
//        }
//        
//        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
//            picker.dismiss(animated: true)
//            
//            guard let provider = results.first?.itemProvider, provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) else {
//                parent.isImageSelected = false
//                return
//            }
//            
//            provider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { [weak self] data, error in
//                guard let self = self, let data = data else {
//                    self?.parent.isImageSelected = false
//                    return
//                }
//                
//                /* 다운샘플링 이미지 사용 */
//                self.parent.selectedImage = self.downsampleImage(data: data)
//                self.parent.isImageSelected = true
//            }
//        }
//        
//        private func downsampleImage(data: Data, 
//                                     to size: CGSize = UIScreen.main.bounds.size,
//                                     scale: CGFloat = UIScreen.main.scale) -> UIImage? {
//            let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
//            guard let imageSource = CGImageSourceCreateWithData(data as CFData, imageSourceOptions) else { return nil }
//            
//            let maxDimensionInPixels = max(size.width, size.height) * scale
//            let downsampleOptions = [
//                kCGImageSourceCreateThumbnailFromImageAlways: true,
//                kCGImageSourceShouldCacheImmediately: true,
//                kCGImageSourceCreateThumbnailWithTransform: true,
//                kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
//            ] as CFDictionary
//            
//            guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else { return nil }
//            
//            return UIImage(cgImage: downsampledImage)
//        }
//    }
//}
