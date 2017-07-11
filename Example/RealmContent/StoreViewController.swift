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

    let offers = ContentListDataSource(style: .plain)
    let products = ContentListDataSource(style: .plain)

    override func viewDidLoad() {
        super.viewDidLoad()

        let realm = try! Realm()
        DemoData.createDemoDataSet3(in: realm)

        offers.loadContent(from: realm, filter: NSPredicate(format: "tag = %@", "offer"))
        products.loadContent(from: realm, filter: NSPredicate(format: "tag = %@", "product"))


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

    }

}
