//
//  UIImageView.swift
//  
//
//  Created by Scott Lydon on 7/12/22.
//

import UIKit
import PersistenceCall

public extension UIImageView {
    
    /// We get URL created by the system in call
    /// KEY: is the UIImageView address
    /// Value: is the url which has the corresponding data.
    private static var imageURLMatchCache: NSCache<NSString, NSString> = .init()
    
    
    /// <#Description#>
    /// - Parameters:
    ///   - url: <#url description#>
    ///   - placeholderImage: <#placeholderImage description#>
    ///   - backgroundColor: <#backgroundColor description#>
    ///   - dataImageScale: <#dataImageScale description#>
    @discardableResult
    func setImage(
        url: String,
        indexPath: IndexPath,
        placeholderImage: UIImage? = nil,
        backgroundColor: UIColor = .gray,
        dataImageScale: CGFloat = 1,
        dimensionMultiplier: CGFloat = 2,
        // for some reason the the dimensions for thumbnails seems to be a bit too small
        autoResume: Bool = true
    ) -> DownloadTaskInterceptor? {
        URLRequest.downloadHashImgDataCache.countLimit = 100
        let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
        let maxDimension = frame.maxDimension * dimensionMultiplier
        Self.imageURLMatchCache.setObject(url as NSString, forKey: tmpAddress as NSString)
        if let image = ImageChache.shared.image(for: url, maxDimension: maxDimension) ?? placeholderImage {
            self.backgroundColor = nil
            self.image = image
            return nil
        } else {
            self.backgroundColor = backgroundColor
        }
        
        let dataAction: DataAction = { [weak self] data in
            // Minor optimization but has a strong effect.
            guard Self.imageURLMatchCache.object(forKey: tmpAddress as NSString) == url as NSString else { return }
            // Resizing the image makes a substantial improvement
            // against choppiness, leads to smoother scrolling.
            guard let image: UIImage = UIImage(data: data)?.resize(maxDimension: maxDimension) else {
                return
            }
            
            // Double check in case it changed while converting the data to an image.
            if Self.imageURLMatchCache.object(forKey: tmpAddress as NSString) == url as NSString {
                DispatchQueue.main.async { [weak self] in
                    self?.image = image
                    self?.backgroundColor = .clear
                    self?.setNeedsDisplay()
                    self?.setNeedsLayout()
                }
            } else {
                // This imageView was most likely recycled and already used...
                // We need to put the current url to another place...
                // We need to access UIImageView by url [url: UIImageView] here
                // There should be another dataTask being created to pass the correct data.
            }
            ImageChache.shared.set(image, forKey: url + String(maxDimension))
            // Clear data cache in PersistenceCall
            URLRequest.downloadHashImgDataCache.removeObject(forKey: url as NSString)
        }
        
        // url Download cache is provided to expose tasks so that they can be cancelled or resumed.
        if let interceptor = urlDownloadTaskCache.object(forKey: url as NSString) {
            interceptor.dataAction = dataAction
            if !(interceptor.addressCalled == nil || interceptor.addressCalled == tmpAddress) {
                interceptor.downloadTask?.cancel()
                interceptor.downloadTask = nil
                interceptor.downloadTask = url.url?.request?.callPersistDownloadData(fetchStrategy: .alwaysUseCacheIfAvailable) { [weak interceptor] data in
                    interceptor?.addressCalled = tmpAddress
                    interceptor?.dataAction!(data)
                }
            }
            if autoResume {
                interceptor.downloadTask?.resume()
            }
            return interceptor
        } else {
            let interceptor = DownloadTaskInterceptor()
            urlDownloadTaskCache.setObject(interceptor, forKey: url as NSString)
            interceptor.dataAction = dataAction
            interceptor.downloadTask = url.url?.request?.callPersistDownloadData(fetchStrategy: .alwaysUseCacheIfAvailable) { [weak interceptor] data in
                interceptor?.addressCalled = tmpAddress
                interceptor?.dataAction!(data)
            }
            if autoResume {
                interceptor.downloadTask?.resume()
            }
            return interceptor
        }
    }
}


typealias DataAction = (Data) -> Void

public class DownloadTaskInterceptor {
    var dataAction: DataAction?
    var downloadTask: URLSessionDownloadTask?
    var addressCalled: String?
}

var urlDownloadTaskCache: NSCache<NSString, DownloadTaskInterceptor> = .init()
