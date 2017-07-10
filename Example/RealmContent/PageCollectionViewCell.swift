//
//  ViewController.swift
//  Created by Marin Todorov
//  Copyright © 2017 - present Realm. All rights reserved.
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
