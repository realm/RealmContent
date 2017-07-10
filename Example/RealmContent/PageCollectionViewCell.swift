//
//  PageCollectionViewCell.swift
//  RealmContent
//
//  Created by Marin Todorov on 7/10/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import RealmContent

class PageCollectionViewCell: UICollectionViewCell {
    @IBOutlet var title: UILabel!
    @IBOutlet var prio: UILabel!
    @IBOutlet var elements: UILabel!

    func populateFromPage(page: ContentPage) {
        title.text = page.title
        prio.text = "Priority \(page.priority)"
        elements.text = "\(page.elements.count) elements"
    }
}
