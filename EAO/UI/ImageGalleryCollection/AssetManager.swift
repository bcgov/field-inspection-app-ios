//
//  assetManager.swift
//  imageMultiSelect
//
//  Created by Amir Shayegh on 2017-12-13.
//  Copyright © 2017 Amir Shayegh. All rights reserved.
//

import Foundation
import Photos
import UIKit

class AssetManager {

    static let sharedInstance = AssetManager()

    // Video size limit
    let SIZE_LIMIT = 19.0 // mb

    let phManager: PHCachingImageManager?

    private init() {
        phManager = PHCachingImageManager()
    }

    func getThumbnailSize() -> CGSize {
        return CGSize(width: 150, height: 150)
    }

    func getPHImageRequestOptions() -> PHImageRequestOptions {
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .opportunistic
        return options
    }

    func getPHVideoRequestOptions() -> PHVideoRequestOptions {
        let options = PHVideoRequestOptions()
        options.deliveryMode = .automatic
        return options
    }

    func getPHAssetImages() -> [PHAsset] {
        var phCache = [PHAsset]()
        let options = PHFetchOptions()
        options.includeHiddenAssets = false
        let phassets = PHAsset.fetchAssets(with: .image, options: options)
        phassets.enumerateObjects { (asset, count, stop) in
            phCache.append(asset)
            if phCache.count == phassets.count {
                phCache.reverse()
            }
        }
        return phCache
    }

    func getPHAssetVideos() -> [PHAsset] {
        var phCache = [PHAsset]()
        let options = PHFetchOptions()
        options.includeHiddenAssets = false
        let phassets = PHAsset.fetchAssets(with: .video, options: options)
        phassets.enumerateObjects { (asset, count, stop) in
            // LIMIST SIZE

            let resources = PHAssetResource.assetResources(for: asset)

            var sizeOnDisk: Int64? = 0
            if let resource = resources.first {
                let unsignedInt64 = resource.value(forKey: "fileSize") as? CLong
                sizeOnDisk = Int64(bitPattern: UInt64(unsignedInt64!))
                let sizeMB: Double = ((Double(sizeOnDisk!) / 1000.0) / 1000.0);
                if sizeMB < self.SIZE_LIMIT {
                    print("include video with size: \(sizeMB)")
                    phCache.append(asset)
                } else {
                    print("Don't include video with size: \(sizeMB)")
                }
            }
        }
        phCache.reverse()
        return phCache
    }

    // get thumbnail for video
    func getThumbnailForVideo(url: NSURL) -> UIImage? {
        let asset = AVAsset(url: url as URL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true

        var time = asset.duration
        //If possible - take not the first frame (it could be completely black or white on camara's videos)
        time.value = min(time.value, 2)

        do {
            let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imageRef)
        }
        catch let error as NSError {
            print("Image generation failed with error \(error)")
            return nil
        }
    }

    func cacheImages() {
        phManager?.startCachingImages(for: getPHAssetImages(), targetSize: getThumbnailSize(), contentMode: .aspectFit, options: getPHImageRequestOptions())
    }

    func cacheVideos() {
        phManager?.startCachingImages(for: getPHAssetVideos(), targetSize: getThumbnailSize(), contentMode: .aspectFit, options: getPHImageRequestOptions())
    }

    func getImageFromAsset(phAsset: PHAsset, completion: @escaping (_ assetImage: UIImage) -> Void) {
        AssetManager.sharedInstance.phManager?.requestImage(for: phAsset, targetSize: AssetManager.sharedInstance.getThumbnailSize(), contentMode: .aspectFit, options: AssetManager.sharedInstance.getPHImageRequestOptions(), resultHandler: { (image, info) in
                if let image = image {
                    DispatchQueue.main.async {
                        completion(image)
                    }
            }
        })
    }

    func getVideoFromAsset(phAsset: PHAsset, completion: @escaping (_ video: AVAsset) -> Void) {
        AssetManager.sharedInstance.phManager?.requestAVAsset(forVideo: phAsset, options: getPHVideoRequestOptions(), resultHandler: { (avAsset, avAudioMix, other) in
            if let vid = avAsset {
                DispatchQueue.main.async {
                    completion(vid)
                }
            }
        })
    }
    
    func getOriginal(phAsset: PHAsset, completion: @escaping (_ assetImage: UIImage) -> Void) {
        let requestImageOption = PHImageRequestOptions()
        requestImageOption.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat

        AssetManager.sharedInstance.phManager?.requestImage(for: phAsset, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.default, options: requestImageOption) { (image: UIImage?, _) in
                if let image = image {
                    DispatchQueue.main.async {
                        completion(image)
                    }
                }
        }
    }
}
