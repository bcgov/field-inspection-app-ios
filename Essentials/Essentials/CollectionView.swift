//
//  CollectionView.swift
//  Vmee
//
//  Created by Micha Volin on 2017-02-04.
//  Copyright © 2017 Vmee. All rights reserved.
//

extension UICollectionView {
   
   public func dequeue(identifier: String, indexPath: IndexPath) -> UICollectionViewCell? {
      return dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
   }
}
