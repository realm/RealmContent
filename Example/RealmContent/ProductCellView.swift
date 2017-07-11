//
//  ProductCellView.swift
//  RealmContent
//
//  Created by Marin Todorov on 7/11/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import RealmContent
import Kingfisher

class ProductCellView: UICollectionViewCell {

    @IBOutlet var image: UIImageView!
    @IBOutlet var label: UILabel!

    func populate(with page: ContentPage) {
        label.text = page.title

        // expects the top element in the page to be an image,
        // grabs it, and shows it in the cell
        
        if let imageElement = page.elements.first,
            imageElement.type == ContentElement.Kind.img.rawValue,
            let urlString = imageElement.url,
            let url = URL(string: urlString) {

            image.kf.setImage(with: url)
        }
    }
}
