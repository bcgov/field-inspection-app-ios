//
//  ProjectListController.swift
//  EAO
//
//  Created by Micha Volin on 2017-03-30.
//  Copyright © 2017 FreshWorks. All rights reserved.
//
import Alamofire
import RealmSwift

final class ProjectListController: UIViewController {
	@objc var result : ((_: String?)->Void)?

    var eao_projects: Results<EAOProject>?
    
	fileprivate var projects : [String]?
	fileprivate var filtered : [NSMutableAttributedString]?
	
	//MARK: IB Outlets
	@IBOutlet fileprivate var indicator: UIActivityIndicatorView!
	@IBOutlet fileprivate var tableView: UITableView!
	@IBOutlet fileprivate var searchBar: UISearchBar!

	//MARK: IB Actions
	@IBAction func customTapped(_ sender: UIBarButtonItem) {
		let alert = UIAlertController(title: "Project name", message: nil, preferredStyle: .alert)
		alert.addTextField { (textField) in
			textField.placeholder = "Start Typing..."
		}
		let select = UIAlertAction(title: "Select", style: .default) { (_) in
			if let text = alert.textFields?.first?.text, !text.isEmpty(){
				self.result?(text)
				self.pop()
			}
		}
		let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		alert.addActions([select,cancel])
		present(controller: alert)
	}
	
	//MARK:-
	override func viewDidLoad() {
		searchBar.returnKeyType = .default
		load()
	}

	//MARK:-
	fileprivate func filter(by search: String?) -> [NSMutableAttributedString]?{
		guard let text = search?.lowercased() else { return nil }
		let filtered = projects?.filter({ (name) -> Bool in
			name.lowercased().contains(text)
		})
		let sorted = filtered?.sorted(by: { (left, right) -> Bool in
			left.map(to: text) > right.map(to: text)
		})
		var array = [NSMutableAttributedString]()
		sorted?.forEach({ (string) in
			let attributed = NSMutableAttributedString(string: string)
			if let range = attributed.string.range(of: text, options: String.CompareOptions.caseInsensitive, range: nil, locale: nil){
				let location = string.distance(from: string.startIndex, to: range.lowerBound)
				let lenght = string.distance(from: range.lowerBound, to: range.upperBound)
				let ns_range = NSRange.init(location: location, length: lenght)
				attributed.addAttribute(NSAttributedStringKey.backgroundColor, value: UIColor.yellow, range: ns_range)
			}
			array.append(attributed)
		})
		return array
	}
	
	fileprivate func load(){
		indicator.startAnimating()
        
        DataServices.fetchProjectList() { (error: Error?) in
            
            DispatchQueue.main.async {
                self.eao_projects = DataServices.shared.getProjects()
                print(self.eao_projects?.count)
            }
            
            if let error = error {
                print(error)
            }
        }
        /** TODO: #11
         
         reload and save all project to Realm
         load all project from Realm
         show projects in the table
         */
        
		Alamofire.request(String.projects_API).responseJSON { response in
			guard let objects = response.result.value as? [Any] else{
				if let array = NSArray(contentsOf: FileManager.directory.appendingPathComponent(.projects)) as? [String]{
					self.projects = array
					self.tableView.reloadData()
				}
				self.indicator.stopAnimating()
				
                let title = "Network Error"
                let message = "Project list was not refreshed due to an error. Cached projects are displayed"
                self.showAlert(withTitle: title, message: message)
                
				return
			}
			var projects = [String?]()
			for case let object as [String: Any] in objects  {
				guard let title = object[.name] as? String else { continue }
				projects.append(title)
			}
            self.projects = projects.compactMap({$0})
			self.tableView.reloadData()
			self.indicator.stopAnimating()
            let array = NSArray(array: projects.compactMap({$0}))
			array.write(to: FileManager.directory.appendingPathComponent(.projects), atomically: true)
		}
	}
}

//MARK: -
extension ProjectListController: UISearchBarDelegate{
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		searchBar.resignFirstResponder()
	}
	
	func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
		if projects == nil{
			return false
		}
		return true
	}
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		filtered = nil
		tableView.reloadData()
		searchBar.text = ""
		searchBar.resignFirstResponder()
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		if searchText.isEmpty() == true{
			self.filtered?.removeAll()
			self.filtered = nil
		} else{
			self.filtered = self.filter(by: searchBar.text)
		}
		self.indicator.stopAnimating()
		self.tableView.reloadData()
	}
}

//MARK: -
extension ProjectListController: UITableViewDelegate, UITableViewDataSource{
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return filtered?.count ?? projects?.count ?? 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeue(identifier: "ProjectListCell") as! ProjectListCell
		if filtered == nil{
			cell.titleLabel.text = projects?[indexPath.row]
		} else{
			cell.titleLabel.attributedText = filtered?[indexPath.row]
		}
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		result?(filtered?[indexPath.row].string ?? projects?[indexPath.row])
		pop()
	}
}
