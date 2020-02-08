//
//  TableViewCell.swift
//  TO DO List
//
//  Created by Мария Матичина on 9/13/19.
//  Copyright © 2019 Мария Матичина. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkEmpty: UIImageView!
    
    override func awakeFromNib() {
        // Срабатывает до начала загрузки вью, как только поступает команда для открытия экрана
        // override - переопределение
        super.awakeFromNib()
        
    }
}



