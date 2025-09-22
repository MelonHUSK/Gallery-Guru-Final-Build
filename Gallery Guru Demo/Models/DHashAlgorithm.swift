import UIKit

// Helper function to convert UIImage to grayscale
func resizeImage(image: UIImage, size: CGSize) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
    image.draw(in: CGRect(origin: .zero, size: size))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage
}

// Helper function to compare adjacent pixels and create a hash
func differenceHash(for image: UIImage) -> UInt64? {
    let size = CGSize(width: 9, height: 8) // 9x8 to compare adjacent pixels horizontally
    guard let grayscaleImage = resizeImage(image: image, size: size),
          let cgImage = grayscaleImage.cgImage,
          let data = cgImage.dataProvider?.data,
          let ptr = CFDataGetBytePtr(data) else { return nil }

    var hash: UInt64 = 0

    for y in 0..<8 {
        for x in 0..<8 {
            let pixel1 = ptr[y * cgImage.bytesPerRow + x]
            let pixel2 = ptr[y * cgImage.bytesPerRow + (x + 1)]
            hash <<= 1
            if pixel1 > pixel2 {
                hash |= 1
            }
        }
    }
    return hash
}

// Function to calculate the Hamming distance between two hashes
func hammingDistance(_ hash1: UInt64, _ hash2: UInt64) -> Int {
    return (hash1 ^ hash2).nonzeroBitCount
}
