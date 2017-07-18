//
//  StoreViewController.swift
//  Created by Marin Todorov
//  Copyright © 2017 - present Realm. All rights reserved.
//

import UIKit
import NSString_Color

import RealmSwift
import RealmContent

class StoreViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var cartItem: UIBarButtonItem!
    
    var cart = [String: Int]()

    let offers = ContentListDataSource(style: .plain)
    let products = ContentListDataSource(style: .plain)

    override func viewDidLoad() {
        super.viewDidLoad()

        let realm = try! Realm()
        DemoData.createDemoDataSet3(in: realm)

        offers.loadContent(from: realm, filter: NSPredicate(format: "tag = %@", "offer"))
        offers.updating(view: tableView)

        products.loadContent(from: realm, filter: NSPredicate(format: "tag = %@", "product"))
        products.updating(view: collectionView)
    }
}

extension StoreViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Current Offers"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return offers.numberOfItemsIn(section: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PageCell") as! PageCellView
        cell.populate(with: offers.itemAt(indexPath: indexPath), atRow: indexPath.row)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let offer = offers.itemAt(indexPath: indexPath)
        navigationController!.pushViewController(
            ContentViewController(page: offer), animated: true)
    }
}

extension StoreViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.numberOfItemsIn(section: section)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCellView
        cell.populate(with: products.itemAt(indexPath: indexPath))
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        let product = products.itemAt(indexPath: indexPath)
        let productDetailsVC = ContentViewController(page: product)
        productDetailsVC.openCustomURL = addToCart
        productDetailsVC.customizeCell = styleElement

        navigationController!.pushViewController(productDetailsVC, animated: true)
    }

    func styleElement(cell: UITableViewCell, indexPath: IndexPath, element: ContentElement) {
        if element.content == "Add to Cart" {
            cell.contentView.backgroundColor = NSString(string: "#FCC397").representedColor()
        } else {
            cell.contentView.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        }
    }

    func addToCart(url: URL) {
        let product = url.lastPathComponent
        cart[product] = (cart[product] ?? 0) + 1
        cartItem.title = "Cart (\(cart.values.reduce(0, +)))"

        let alert = UIAlertController(title: "Added to cart", message: "\(product) added to your cart", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
            self?.navigationController!.popViewController(animated: true)
        }))
        present(alert, animated: true, completion: nil)
    }
}

extension StoreViewController /* Cart */ {
    @IBAction func showCart(_ sender: Any) {
        let contents = cart.map { key, value in "\(value) x \(key)" }.joined(separator: "\n")
        let alert = UIAlertController(title: "Your Cart", message: contents, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .default, handler: { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
}
