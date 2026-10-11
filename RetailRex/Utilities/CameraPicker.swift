import SwiftUI
import UIKit

public struct CameraPickerView: UIViewControllerRepresentable {
    public var sourceType: UIImagePickerController.SourceType = .camera
    public var onImageCaptured: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss
    
    public init(
        sourceType: UIImagePickerController.SourceType = .camera,
        onImageCaptured: @escaping (UIImage) -> Void
    ) {
        self.sourceType = sourceType
        self.onImageCaptured = onImageCaptured
    }

    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            picker.sourceType = sourceType
        } else {
            picker.sourceType = .photoLibrary
        }
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }

    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraPickerView

        init(_ parent: CameraPickerView) {
            self.parent = parent
        }

        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.onImageCaptured(uiImage)
            }
            parent.dismiss()
        }

        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
