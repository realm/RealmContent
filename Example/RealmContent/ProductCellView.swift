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
    @IBOutlet var price: UILabel!

    func populate(with page: ContentPage) {
        label.text = page.title

        // expects the top element in the page to be an image,
        // grabs it, and shows it in the cell

        if let imageElement = page.elements.first,
            imageElement.type == ContentElement.Kind.img.rawValue {

            image.kf.setImage(with: URL(string: imageElement.content))
        }

        // checks if second element is a price (custom type)
        if page.elements.count > 1,
            page.elements[1].type == "price" {
            price.text = page.elements[1].content
        } else {
            price.text = nil
        }
    }
}
