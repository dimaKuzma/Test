//
//  CollectionViewCell.swift
//  Test
//
//  Created by Дмитрий on 6/8/21.
//  Copyright © 2021 DK. All rights reserved.
//

import UIKit
import BEMCheckBox

class CollectionViewCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    // - UI
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    let checkBox: BEMCheckBox = {
        let checkBox = BEMCheckBox()
        checkBox.boxType = .circle
        checkBox.onTintColor = .white
        checkBox.onCheckColor = .white
        checkBox.translatesAutoresizingMaskIntoConstraints = false
        return checkBox
    }()
    
    // - delegate
    weak var tableCell: TableViewCell!
    
    // - Data
    var index = Int()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func layoutSubviews() {
        checkBox.delegate = self
        setupImage()
        setupCheckBox()
    }
}

// MARK: -
// MARK: BEMCheckBoxDelegate
extension CollectionViewCell: BEMCheckBoxDelegate {
    func didTap(_ checkBox: BEMCheckBox) {
        tableCell.vc.cellsToDelete.append(index)
    }
}

// MARK: -
// MARK: ConfigureUI
extension CollectionViewCell {
    func setupImage() {
        self.addSubview(imageView)
        imageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive
         = true
        imageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
    }
    
    func setupCheckBox() {
        self.addSubview(checkBox)
        checkBox.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 5).isActive = true
        checkBox.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        checkBox.widthAnchor.constraint(equalToConstant: 25).isActive = true
        checkBox.heightAnchor.constraint(equalToConstant: 25).isActive = true
    }
}

