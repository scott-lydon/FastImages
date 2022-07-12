//
//  UIImageView.swift
//  
//
//  Created by Scott Lydon on 7/12/22.
//


import UIKit
import PersistenceCall

public extension UIImageView {
    
    private static var urlStore: NSCache<NSString, NSString> = .init()
    
    func setImage(
        url: String,
        placeholderImage: UIImage? = nil,
        backgroundColor: UIColor = .gray
    ) {
        let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
        Self.urlStore.setObject(url as NSString, forKey: tmpAddress as NSString)
        if let image = ImageChache.shared.image(forKey: url) {
            self.image = image
            return
        } else if let image = placeholderImage {
            self.image = image
        } else {
            self.backgroundColor = backgroundColor
        }
        url.url?.request?.callPersistData(fetchStrategy: .alwaysUseCacheIfAvailable) {
            [weak self] data in
            guard let image = UIImage(data: data) else { return }
            ImageChache.shared.set(image, forKey: url)
            DispatchQueue.main.async {
                if Self.urlStore.object(forKey: tmpAddress as NSString) == url as NSString {
                    self?.image = image
                    self?.backgroundColor = .clear
                }
            }
        }
    }
}
