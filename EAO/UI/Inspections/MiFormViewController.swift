//
//  MiFormViewController.swift
//  time-me
//
//  Created by Amir Shayegh on 2018-01-08.
//  Copyright © 2018 Amir Shayegh. All rights reserved.
//
 
import UIKit

class MiFormViewController: UIViewController {
    
    @IBOutlet var viewView: UIView!
    @IBOutlet weak var tableView: UITableView!

    var fields: [SimpleCell] = [SimpleCell]()

    var bg: UIColor = UIColor.white
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.layer.cornerRadius = 8
        setUpTable()
        viewView.backgroundColor = bg
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func close(completion: @escaping () -> Void) {
        self.dismiss(animated: true, completion: completion)
    }
}

extension MiFormViewController: UITableViewDelegate, UITableViewDataSource {

    func getButtonCell(indexPath: IndexPath) -> MiFormButtonTableViewCell {
        return tableView.dequeueReusableCell(forIndexPath: indexPath)
    }

    func getTextFieldCell(indexPath: IndexPath) -> SimpleFormTableViewCell {
        return tableView.dequeueReusableCell(forIndexPath: indexPath)
    }

    func getImageCell(indexPath: IndexPath) -> miFormImageTableViewCell {
        return tableView.dequeueReusableCell(forIndexPath: indexPath)
    }

    func getTextViewCell(indexPath: IndexPath) -> MiFormTextViewTableViewCell {
        return tableView.dequeueReusableCell(forIndexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fields.count
    }

    func getLabelCell(indexPath: IndexPath) -> MiFormTableViewCell {
        return tableView.dequeueReusableCell(forIndexPath: indexPath)
    }

    // Csn be cleaned with use of generics
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentObj = fields[indexPath.row]
        switch currentObj.type {
        case .Button?:
            let cell = getButtonCell(indexPath: indexPath)
            if currentObj.buttonStyle != nil {
                cell.style = currentObj.buttonStyle
            }
            cell.setup(simpleCell: currentObj)
            return cell
        case .TextInput?:
            let cell = getTextFieldCell(indexPath: indexPath)
            // fix should reset
            cell.setup(obj: currentObj)
            if currentObj.textfieldStyle != nil {
                cell.style = currentObj.textfieldStyle
            }
            return cell
        case .Image?:
            let cell = getImageCell(indexPath: indexPath)
            cell.setup(obj: currentObj)
            return cell
        case .TextViewInput?:
            let cell = getTextViewCell(indexPath: indexPath)
            cell.setup(obj: currentObj)
            if currentObj.textfieldStyle != nil {
                cell.style = currentObj.textfieldStyle
            }
            return cell
        case .Label?:
            let cell = getLabelCell(indexPath: indexPath)
            cell.setup(obj: currentObj)
            if currentObj.labelStyle != nil {
                cell.style = currentObj.labelStyle
            }
            return cell
        default:
            return getTextFieldCell(indexPath: indexPath)
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func setUpTable() {
        tableView.delegate = self
        tableView.dataSource = self
        let nib1 = UINib(nibName: SimpleFormTableViewCell.nibName, bundle: nil)
        tableView.register(nib1, forCellReuseIdentifier: SimpleFormTableViewCell.reuseIdentifier)
        let nib2 = UINib(nibName: MiFormButtonTableViewCell.nibName, bundle: nil)
        tableView.register(nib2, forCellReuseIdentifier: MiFormButtonTableViewCell.reuseIdentifier)
        let nib3 = UINib(nibName: miFormImageTableViewCell.nibName, bundle: nil)
        tableView.register(nib3, forCellReuseIdentifier: miFormImageTableViewCell.reuseIdentifier)
        let nib4 = UINib(nibName: MiFormTextViewTableViewCell.nibName, bundle: nil)
        tableView.register(nib4, forCellReuseIdentifier: MiFormTextViewTableViewCell.reuseIdentifier)
        let nib5 = UINib(nibName: MiFormTableViewCell.nibName, bundle: nil)
        tableView.register(nib5, forCellReuseIdentifier: MiFormTableViewCell.reuseIdentifier)
    }
}
