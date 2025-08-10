import UIKit
import CoreImage

enum ImageUtils {
    static func jpegData(_ image: UIImage, quality: CGFloat = 0.85) -> Data? {
        image.jpegData(compressionQuality: quality)
    }

    static func downscaleForPreview(_ image: UIImage, targetLongSide: CGFloat = 640) -> UIImage {
        guard let cg = image.cgImage else { return image }
        let width = CGFloat(cg.width)
        let height = CGFloat(cg.height)
        let longSide = max(width, height)
        guard longSide > targetLongSide else { return image }
        let scale = targetLongSide / longSide
        let newSize = CGSize(width: width * scale, height: height * scale)
        UIGraphicsBeginImageContextWithOptions(newSize, true, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let scaled = UIGraphicsGetImageFromCurrentImageContext() ?? image
        UIGraphicsEndImageContext()
        return scaled
    }
}