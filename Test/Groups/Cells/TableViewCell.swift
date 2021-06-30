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
    let addressTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .backgroundColor
        textField.layer.cornerRadius = 10
        textField.textColor = .black
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    let aimImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "aim")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    let nameTextFieldView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10.0
        view.backgroundColor = .backgroundColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let nameTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .backgroundColor
        textField.layer.cornerRadius = 10
        textField.textColor = .textColor
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let addButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.layer.cornerRadius = 12
        button.setImage(UIImage(named: "plusMini"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let collectionView: UICollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout.init())
    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout.init()
    
    //- VC
    weak var vc: ViewController!
    
    // - Data
    var id = ""
    var images = [String]()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
        setupAnchors()
    }
    
    override func layoutSubviews() {
        configure()
        setupAnchors()
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
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "CollectionViewCell")
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        collectionView.backgroundColor = .backgroundColor
        collectionView.setCollectionViewLayout(layout, animated: true)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    func configureTextField() {
        nameTextField.delegate = self
        addressTextField.delegate = self
    }
    
    @objc func longPress() {
        vc.checkBox = false
        vc.selectedCell = id
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

// MARK: -
// MARK: Configure Anchors
extension TableViewCell {
    func setupAnchors() {
        setupAddressTextField()
        setupAimImageView()
        setupNameTextFieldView()
        setupNameTextField()
        setupCollectionView()
        setupAddButton()
    }
    
    func setupAddressTextField() {
        self.addSubview(addressTextField)
        addressTextField.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        addressTextField.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20).isActive = true
        addressTextField.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        addressTextField.heightAnchor.constraint(equalToConstant: 34).isActive = true
    }
    
    func setupAimImageView() {
        self.addSubview(aimImageView)
        aimImageView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20).isActive = true
        aimImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 15).isActive = true
        aimImageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        aimImageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
    }
    
    func setupNameTextFieldView() {
        self.addSubview(nameTextFieldView)
        nameTextFieldView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16).isActive = true
        nameTextFieldView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16).isActive = true
        nameTextFieldView.topAnchor.constraint(equalTo: addressTextField.bottomAnchor, constant: 10).isActive = true
        nameTextFieldView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
        nameTextFieldView.makeInShadow(to:[.top], radius: 3.0)
    }
    
    func setupNameTextField() {
        nameTextFieldView.addSubview(nameTextField)
        nameTextField.leftAnchor.constraint(equalTo: nameTextFieldView.leftAnchor, constant: 3).isActive = true
        nameTextField.rightAnchor.constraint(equalTo: nameTextFieldView.rightAnchor, constant: -3).isActive = true
        nameTextField.topAnchor.constraint(equalTo: nameTextFieldView.topAnchor, constant: 5).isActive = true
        nameTextField.heightAnchor.constraint(equalToConstant: 34).isActive = true
    }
    
    func setupAddButton() {
        addButton.addTarget(self, action: #selector(addImageButtonAction), for: .touchUpInside)
        nameTextFieldView.addSubview(addButton)
        addButton.rightAnchor.constraint(equalTo: nameTextFieldView.rightAnchor, constant: -10).isActive = true
        addButton.topAnchor.constraint(equalTo: nameTextFieldView.topAnchor, constant: 10).isActive = true
        addButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
    }
    
    @objc func addImageButtonAction(){
        vc.presentImagePicker()
        vc.selectedCell = id
    }
    
    func setupCollectionView() {
        nameTextFieldView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leftAnchor.constraint(equalTo: nameTextFieldView.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: nameTextFieldView.rightAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 0).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: nameTextFieldView.bottomAnchor, constant: -10).isActive = true
    }
}
