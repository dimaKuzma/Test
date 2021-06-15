//
//  TableViewCell.swift
//  Test
//
//  Created by Дмитрий on 6/8/21.
//  Copyright © 2021 DK. All rights reserved.
//

import UIKit
import ImagePicker
import Firebase

class TableViewCell: UITableViewCell {
    // - UI
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    //- VC
    weak var vc: ViewController!
    
    // - Data
    var id = ""
    var images = [String]()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
        
    }
    
    
    @IBAction func addButtonAction(_ sender: Any) {
        vc.presentImagePicker()
        vc.selectedCell = id
    }
}

// MARK: -
// MARK: Configure
extension TableViewCell {
    func configure() {
        configureCollectionView()
        configureLongTap()
        configureTextField()
    }
    
    func configureLongTap() {
        let longTap = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        longTap.minimumPressDuration = 1
        collectionView.addGestureRecognizer(longTap)
    }
    
    func configureCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    func configureTextField() {
        nameTextField.delegate = self
        addressTextField.delegate = self
    }
    
    @objc func longPress() {
        vc.checkBox = false
        if let name = self.nameTextField.text {
            vc.selectedCell = id
        }
        vc.configureDeleteButton()
        collectionView.reloadData()
    }
}

// MARK: -
// MARK: CollectionView DataSource
extension TableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        cell.tableCell = self
        cell.index = indexPath.item
        do {
            let imageUrl = URL(string: self.images[indexPath.item] as! String)
            let data = try Data(contentsOf: imageUrl!)
            cell.imageView.image = UIImage(data: data)
        }
        catch {
            print(error)
        }
        if vc.checkBox {
            cell.checkBox.isHidden = true
        } else {
            cell.checkBox.isHidden = false
        }
        return cell
    }
}

// MARK: -
// MARK: CollectionView Delegate
extension TableViewCell: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 40) / 3
        let size = CGSize(width: width, height: width)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if vc.checkBox {
            return
        } else {
            let cell = collectionView.cellForItem(at: indexPath)
            
        }
    }
}

// MARK: -
// MARK: TextField Delegate
extension TableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let ref = Database.database(url: Constants.reference).reference().child(self.id)
        if textField == addressTextField {
            ref.child("place").setValue(textField.text)
            self.endEditing(true)
        } else if textField == nameTextField {
            ref.child("name").setValue(textField.text)
            self.endEditing(true)
        }
        return true
    }
}
