//
//  ChooseImageViewController.swift
//  imageMultiSelect
//
//  Created by Amir Shayegh on 2017-12-12.
//  Copyright © 2017 Amir Shayegh. All rights reserved.
//

import UIKit
import Photos

extension Notification.Name {
    static let selectedImages = Notification.Name("selectedImages")
}

class ChooseImageViewController: UIViewController {

    // MARK: IB Outlets
    @IBOutlet weak var navBar: UIView!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var loadingContainer: UIView!

    // MARK: variables
    var images = [PHAsset]()
    var selectedIndexs = [Int]()

    var callBack: ((_ close: Bool) -> Void )?

    let cellReuseIdentifier = "GalleryImageCell"
    let cellXibName = "GalleryImageCollectionViewCell"

    var mode: GalleryMode = GalleryMode.Image

    // colors:
    var backgroundColor: UIColor = UIColor(hex: "1598a7")
    var utilBarBG: UIColor = UIColor(hex: "0a3e44")
    var buttonText: UIColor = UIColor(hex: "d7eef1")
    var loadingBG: UIColor = UIColor(hex: "1598a7")
    var loadingIndicator: UIColor = UIColor(hex: "d7eef1")

    override func viewDidLoad() {
        super.viewDidLoad()
        lockdown()
        
        style()
        loadData()
        setUpCollectionView()
        styleContainer(view: navBar.layer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(sent), name: .selectedImages, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        unlock()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.selectedIndexs.removeAll()
    }

    func sendBackImages(images: [PHAsset]) {
        NotificationCenter.default.post(name: .selectedImages, object: self, userInfo: ["name": images])
        unlock()
        closeVC()
    }

    @objc func sent() {
    }

    @objc func appWillEnterForeground() {
        if self.images.count != AssetManager.sharedInstance.getPHAssetImages().count {
            reloadData()
        }
    }

    @IBAction func addImages(_ sender: Any) {
        if selectedIndexs.count == 0 {
            closeVC()
        }
        lockdown()
        var selectedImages = [PHAsset]()
        for index in selectedIndexs {
            selectedImages.append(images[index])
        }
        sendBackImages(images: selectedImages)
    }

    @IBAction func cancel(_ sender: Any) {
        closeVC()
    }

    func closeVC() {
        self.selectedIndexs.removeAll()
        self.collectionView.reloadData()
        self.dismiss(animated: true, completion: {
            if self.callBack != nil {
                return self.callBack!(true)
            }
        })
    }

    func lockdown() {
        self.loading.startAnimating()
        self.view.isUserInteractionEnabled = false
        self.loading.isHidden = false
        self.loadingContainer.isHidden = false
    }

    func unlock() {
        self.loading.stopAnimating()
        self.loading.isHidden = true
        self.loadingContainer.isHidden = true
        self.view.isUserInteractionEnabled = true
    }

    func reloadCellsOfInterest(indexPath: IndexPath) {
        let indexes = self.selectedIndexs.map { (value) -> IndexPath in
            return IndexPath(row: value, section: 0)
        }
        if indexes.contains(indexPath) {
            self.collectionView.reloadItems(at: indexes)
        } else {
            self.collectionView.reloadItems(at: indexes)
            self.collectionView.reloadItems(at: [indexPath])
        }
    }

    func style() {
        setColors(bg: Colors.White, utilBarBG: Colors.Blue, buttonText: Colors.White, loadingBG: Colors.Blue, loadingIndicator: Colors.White)
        loadingContainer.layer.cornerRadius = loadingContainer.frame.height / 2
        self.container.backgroundColor = backgroundColor
        self.collectionView.backgroundColor = backgroundColor
        self.loadingContainer.backgroundColor = loadingBG
        self.loading.color = loadingIndicator
    }

    func setColors(bg: UIColor, utilBarBG: UIColor, buttonText: UIColor, loadingBG: UIColor, loadingIndicator: UIColor) {
        self.backgroundColor = bg
        self.utilBarBG = utilBarBG
        self.buttonText = buttonText
        self.loadingBG = loadingBG
        self.loadingIndicator = loadingIndicator
    }

    func styleContainer(view: CALayer) {
        view.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        view.shadowOffset = CGSize(width: 0, height: 2)
        view.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        view.shadowOpacity = 1
        view.shadowRadius = 3
    }
}

extension ChooseImageViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func reloadData() {
        self.selectedIndexs.removeAll()
        loadData()
    }

    func loadData() {
        if self.mode == .Image {
            self.images = AssetManager.sharedInstance.getPHAssetImages()
            self.collectionView.reloadData()
        } else {
            self.images = AssetManager.sharedInstance.getPHAssetVideos()
            self.collectionView.reloadData()
        }
    }

    func setUpCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self

        self.collectionView.register(UINib(nibName: cellXibName, bundle: nil), forCellWithReuseIdentifier: cellReuseIdentifier)

        // set size of cells
        guard let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }

        layout.itemSize = getCellSize()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: GalleryImageCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! GalleryImageCollectionViewCell

        cell.setUp(selectedIndexes: selectedIndexs, indexPath: indexPath, phAsset: images[indexPath.row], primaryColor: UIColor(hex: "4667a2"), textColor: UIColor.white)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedIndexs.contains(indexPath.row) {
            selectedIndexs.remove(at: selectedIndexs.index(of: indexPath.row)!)
        } else {
            selectedIndexs.append(indexPath.row)
        }

        reloadCellsOfInterest(indexPath: indexPath)
    }

    func getCellSize() -> CGSize {
        return CGSize(width: self.view.frame.size.width/3 - 10, height: self.view.frame.size.width/3 - 15)
    }
}
