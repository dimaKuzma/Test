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
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var checkBox: BEMCheckBox!
    
    // - delegate
    weak var tableCell: TableViewCell!
    
    // - Data
    var index = Int()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        checkBox.boxType = .circle
        checkBox.onTintColor = .white
        checkBox.onCheckColor = .white
        checkBox.delegate = self
    }
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
    }
}

extension CollectionViewCell: BEMCheckBoxDelegate {
    func didTap(_ checkBox: BEMCheckBox) {
        tableCell.vc.cellsToDelete.append(index)
    }
}
