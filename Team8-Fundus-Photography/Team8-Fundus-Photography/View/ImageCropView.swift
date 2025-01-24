////
////  ImageCropView.swift
////  Team8-Fundus-Photography
////
////  Created by Anjola Adewale on 2025-01-24.
////
//
//import SwiftUI
//import CropViewController
//
////struct ImageCropView: View {
////    let image: UIImage
////    var body: some View {
////        Text("Image Crop View")
////    }
////}
//
//struct ImageCropView: UIViewControllerRepresentable {
//    struct CroppedRect {
//        let rect: CGRect
//        let angle: Int
//    }
//    
//    struct CroppedImage {
//        let image: UIImage
//        let rect: CGRect
//        let angle: Int
//    }
//    
//    private var image: UIImage
//    private var didCropToImage: ((CroppedImage) -> ())?
//    private var didCropToCircularImage: ((CroppedImage) -> ())?
//    private var didCropImageToRect: ((CroppedRect) -> ())?
//    private var didFinishCancelled: (Bool) -> ()
//        
//    private let controller: CropViewController
//    
//    init(image: UIImage,
//         croppingStyle: CroppedPhotosPickerCroppingStyle = .circular,
//         croppingOptions: CroppedPhotosPickerOptions = .init(),
//         didCropToImage: ((CroppedImage) -> Void)? = nil,
//         didCropToCircularImage: ((CroppedImage) -> Void)? = nil,
//         didCropImageToRect: ((CroppedRect) -> Void)? = nil,
//         didFinishCancelled: @escaping (Bool) -> Void) {
//        
//        self.image = image
//        
//        self.didCropToImage = didCropToImage
//        self.didCropToCircularImage = didCropToCircularImage
//        self.didCropImageToRect = didCropImageToRect
//        self.didFinishCancelled = didFinishCancelled
//        
//        self.controller = CropViewController(croppingStyle: croppingStyle, image: image)
//        self.controller.setCroppingOptions(croppingOptions)
//    }
//    
//    class Coordinator: NSObject,  CropViewControllerDelegate {
//        let parent: ImageCropView
//        
//        init(parent: ImageCropView) {
//            self.parent = parent
//        }
//        
//        func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
//                    let croppedImage = CroppedImage(image: image, rect: cropRect, angle: angle)
//                    parent.didCropToImage?(croppedImage)
//                }
//                
//        func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
//            let croppedImage = CroppedImage(image: image, rect: cropRect, angle: angle)
//            parent.didCropToImage?(croppedImage)
//        }
//        
//        func cropViewController(_ cropViewController: CropViewController, didCropImageToRect cropRect: CGRect, angle: Int) {
//            let croppedRect = CroppedRect(rect: cropRect, angle: angle)
//            parent.didCropImageToRect?(croppedRect)
//        }
//        
//        func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
//            parent.didFinishCancelled(cancelled)
//        }
//        
//    }
//    func makeCoordinator() -> Coordinator {
//        return Coordinator(parent: self)
//    }
//    
//    func makeUIViewController(context: Context) -> some UIViewController {
//        controller.delegate = context.coordinator
//        return controller
//    }
//    
//    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
//        
//    }
//}
//
//
////func presentCropViewController() {
////    var image: UIImage? // Load an image
////    let cropViewController = CropViewController(croppingStyle: .circular, image: image)
////    cropViewController.delegate = self
////    self.present(cropViewController, animated: true, completion: nil)
////}
////
////func cropViewController(_ cropViewController: TOCropViewController?, didCropToCircularImage image: UIImage?, with cropRect: CGRect, angle: Int) {
////    // 'image' is the newly cropped, circular version of the original image
////}
import SwiftUI
import CropViewController

struct ImageCropView: UIViewControllerRepresentable {
    @Binding var image: UIImage // Pass the image to be updated after cropping
    var croppingStyle: CropViewCroppingStyle = .default // Circular or default cropping
    var onCancel: (() -> Void)? // Optional cancel callback

    class Coordinator: NSObject, CropViewControllerDelegate {
        var parent: ImageCropView

        init(parent: ImageCropView) {
            self.parent = parent
        }
        // Handle cropped image
        func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
            print("Original Image Size: \(parent.image.size.width)x\(parent.image.size.height)")
            print("Cropped Image Size: \(image.size.width)x\(image.size.height)")
            parent.image = image // Update the image binding
            cropViewController.dismiss(animated: true)
        }

        // Handle circular cropped image
        func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
            print("Original Image Size: \(parent.image.size.width)x\(parent.image.size.height)")
            print("Cropped Image Size: \(image.size.width)x\(image.size.height)")
            parent.image = image // Update the image binding
            cropViewController.dismiss(animated: true)
        }


//        // Handle cropped image
//        func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
//            parent.image = image // Update the image binding
//            cropViewController.dismiss(animated: true)
//        }
//
//        // Handle circular cropped image
//        func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
//            parent.image = image // Update the image binding
//            cropViewController.dismiss(animated: true)
//        }

        // Handle cancel action
        func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
            parent.onCancel?() // Trigger optional cancel callback
            cropViewController.dismiss(animated: true)
        }

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> CropViewController {
        let cropViewController = CropViewController(croppingStyle: croppingStyle, image: image)
        cropViewController.delegate = context.coordinator
        return cropViewController
    }

    func updateUIViewController(_ uiViewController: CropViewController, context: Context) {
        // No updates needed
    }
}
