//
//  PageCellView.swift
//  RealmContent
//
//  Created by Marin Todorov on 7/11/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import RealmContent

struct OrbColor {
    static func at(index: Int) -> UIColor {
        switch index {
        case 0: return NSString(string: "#D34CA3").representedColor()
        case 1: return NSString(string: "#9A50A5").representedColor()
        case 2: return NSString(string: "#59569E").representedColor()
        default: return NSString(string: "#39477F").representedColor()
        }
    }
}

class PageCellView: UITableViewCell {

    @IBOutlet var label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }

    func populate(with page: ContentPage, atRow row: Int) {
        label.text = page.title
        label.textColor = OrbColor.at(index: row)
    }
}
