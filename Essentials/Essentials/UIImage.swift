//
//  UIImage.swift
//  Vmee
//
//  Created by Micha Volin on 2016-12-28.
//  Copyright © 2016 Vmee. All rights reserved.
//

extension UIImage {
    public enum Quality: CGFloat{
        case low    = 0.25
        case medium = 0.5
        case high   = 0.75
        case uncompressed = 1
    }
   
   public func toData(quality: Quality) -> Data{
      return UIImageJPEGRepresentation(self, quality.rawValue)!
   }
   
   
   
   public func compress(quality: Quality) -> UIImage{
      let data = self.toData(quality: quality)
      let image = UIImage(data: data)
      return image!
   }
	
   public func scale(width: CGFloat) -> UIImage?{
      let scale = width / self.size.width
      let newHeight = self.size.height * scale
      UIGraphicsBeginImageContext(CGSize(width: width, height: newHeight))
      self.draw(in: CGRect(x: 0, y: 0, width: width, height: newHeight))
      let newImage = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      
      return newImage
   }

   public func prepareImageForCell(completion: @escaping (_ image: UIImage?) -> Void){
      DispatchQueue.global().async {
         let image = self.compress(quality: .medium)
         DispatchQueue.main.async {
            completion(image)
         }
      }
   }
   
}


