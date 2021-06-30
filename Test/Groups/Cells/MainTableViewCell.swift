//
//  MainTableViewCell.swift
//  Test
//
//  Created by Дмитрий on 6/30/21.
//  Copyright © 2021 DK. All rights reserved.
//

import UIKit

class MainTableViewCell: UITableViewCell {
    // - UI
    let vectorImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Vector")
        imageView.contentMode = .scaleToFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    let unionImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Union")
        imageView.contentMode = .scaleToFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    let locationsLabel: UILabel = {
        let label = UILabel()
        label.text = "ЛОКАЦИИ"
        label.textAlignment = .center
        label.font = UIFont(descriptor: UIFontDescriptor(name: "Thin", size: 33.0), size: 33.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let nameTextFieldView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let nameTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = UIColor.backgroundColor
        textField.layer.cornerRadius = 10
        textField.textAlignment = .center
        textField.textColor = .textColor
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupAnchors()
    }
    
    override func layoutSubviews() {
        setupAnchors()
    }
}

// MARK: -
// MARK: Setup Anchors
extension MainTableViewCell {
    func setupAnchors() {
        setupVectorImageView()
        setupUnionImageView()
        setupLocationLabel()
        setupNameTextFieldView()
        setupNameTextField()
    }
    func setupVectorImageView() {
        self.addSubview(vectorImage)
        vectorImage.topAnchor.constraint(equalTo: self.topAnchor, constant: 25).isActive = true
        vectorImage.leftAnchor.constraint(equalTo: self
            .leftAnchor, constant: 50).isActive = true
        vectorImage.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -50).isActive = true
        vectorImage.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setupUnionImageView() {
        self.addSubview(unionImage)
        unionImage.topAnchor.constraint(equalTo: vectorImage.bottomAnchor, constant: -25).isActive = true
        unionImage.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 70).isActive = true
        unionImage.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -70).isActive = true
        unionImage.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setupLocationLabel() {
        self.addSubview(locationsLabel)
        locationsLabel.topAnchor.constraint(equalTo: vectorImage.topAnchor).isActive = true
        locationsLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 50).isActive = true
        locationsLabel.widthAnchor.constraint(equalToConstant: self.frame.width - 100).isActive = true
        locationsLabel.bottomAnchor.constraint(equalTo: unionImage.bottomAnchor).isActive = true
    }
    
    func setupNameTextFieldView() {
        self.addSubview(nameTextFieldView)
        nameTextFieldView.topAnchor.constraint(equalTo: unionImage.bottomAnchor, constant: 10).isActive = true
        nameTextFieldView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 2).isActive = true
        nameTextFieldView.widthAnchor.constraint(equalToConstant: self.frame.width - 4).isActive = true
        nameTextFieldView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        nameTextFieldView.makeShadow()
    }
    
    func setupNameTextField() {
        nameTextFieldView.addSubview(nameTextField)
        nameTextField.topAnchor.constraint(equalTo: nameTextFieldView.topAnchor, constant: 5).isActive = true
        nameTextField.leftAnchor.constraint(equalTo: nameTextFieldView.leftAnchor, constant: 10).isActive = true
        nameTextField.rightAnchor.constraint(equalTo: nameTextFieldView.rightAnchor, constant: -10).isActive = true
        nameTextField.heightAnchor.constraint(equalToConstant: 34).isActive = true
    }
}
