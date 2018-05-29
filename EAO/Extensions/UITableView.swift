//
//  UITableView.swift
//  VIATEC
//
//  Created by Work on 2017-02-05.
//  Copyright © 2017 FreshWorks Studio. All rights reserved.
//

import UIKit

extension UITableView {
    @objc func registerNib(withIdentifier identifer: String) {
        self.register(UINib(nibName: identifer, bundle: nil), forCellReuseIdentifier: identifer)
    }
    @objc func cell(withIdentifier identifier: String, for indexPath: IndexPath) -> UITableViewCell {
        return self.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
    }
}
