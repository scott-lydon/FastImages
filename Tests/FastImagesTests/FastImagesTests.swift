import XCTest
@testable import FastImages

final class FastImagesTests: XCTestCase {
    func testImageCache() {
        let screenShot = "screenShot"
        let image = UIImage()
        ImageChache.shared.set(image, forKey: screenShot)
        let checkedImage = ImageChache.shared.image(forKey: screenShot)
        XCTAssertEqual(image, checkedImage)
    }

    func testClearImageCache() {
        let screenShot = "screenShot"
        let image = UIImage()
        ImageChache.shared.set(image, forKey: screenShot)
        ImageChache.shared.clearCache()
        XCTAssertNil(ImageChache.shared.image(forKey: screenShot))
    }

    func testCacheLimit() {
        let screenShot = "screenShot"
        let second = "secondScreen"
        let image = UIImage()
        let secondImage = UIImage()
        ImageChache.shared.cacheSize = 1
        ImageChache.shared.set(image, forKey: screenShot)
        ImageChache.shared.set(secondImage, forKey: second)
        XCTAssertNil(ImageChache.shared.image(forKey: screenShot))
        XCTAssertEqual(ImageChache.shared.image(forKey: second), secondImage)
    }
}
