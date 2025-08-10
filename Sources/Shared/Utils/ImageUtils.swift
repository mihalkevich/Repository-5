import UIKit

enum ImageUtils {
    static func jpegData(_ image: UIImage, quality: CGFloat = 0.85) -> Data? {
        image.jpegData(compressionQuality: quality)
    }
}