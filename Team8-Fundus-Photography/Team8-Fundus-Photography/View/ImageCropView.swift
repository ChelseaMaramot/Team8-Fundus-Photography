import SwiftUI
import CropViewController

struct ImageCropView: UIViewControllerRepresentable {
    @Binding var image: UIImage? // Bind the image to allow updates after cropping
    var croppingStyle: CropViewCroppingStyle = .default // Set default cropping style (can be circular, rectangular, etc.)
    var onCancel: (() -> Void)? // Optional cancel callback

    class Coordinator: NSObject, CropViewControllerDelegate {
        var parent: ImageCropView

        init(parent: ImageCropView) {
            self.parent = parent
        }

        // Handle cropped image
        func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
            // Safely unwrap image and assign the cropped result
            if let _ = parent.image {
                print("Original Image Size: \(parent.image?.size.width ?? 0)x\(parent.image?.size.height ?? 0)")
                print("Cropped Image Size: \(image.size.width)x\(image.size.height)")
                parent.image = image // Update the binding with the cropped image
            }
            cropViewController.dismiss(animated: true)
        }

        // Handle circular cropped image
        func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
            // Safely unwrap image and assign the circular cropped result
            if let _ = parent.image {
                print("Original Image Size: \(parent.image?.size.width ?? 0)x\(parent.image?.size.height ?? 0)")
                print("Cropped Image Size: \(image.size.width)x\(image.size.height)")
                parent.image = image // Update the binding with the cropped image
            }
            cropViewController.dismiss(animated: true)
        }

        // Handle cancel action
        func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
            // Trigger optional cancel callback
            parent.onCancel?()
            cropViewController.dismiss(animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> CropViewController {
        guard let unwrappedImage = image else {
            fatalError("Image is nil, unable to proceed with cropping.") // Handle the error if the image is nil
        }

        let cropViewController = CropViewController(croppingStyle: croppingStyle, image: unwrappedImage)
        cropViewController.delegate = context.coordinator
        return cropViewController
    }

    func updateUIViewController(_ uiViewController: CropViewController, context: Context) {
        // No updates needed as we are not updating the controller directly
    }
}

