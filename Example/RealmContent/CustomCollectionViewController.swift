//
//  ViewController.swift
//  Created by Marin Todorov
//  Copyright © 2017 - present Realm. All rights reserved.
//

import UIKit
import RealmSwift
import RealmContent

private let reuseIdentifier = "PageCell"
private let headerIdentifier = "Header"

class CustomCollectionViewController: UICollectionViewController {

    var items: Results<ContentPage>!

    override func viewDidLoad() {
        super.viewDidLoad()

        clearsSelectionOnViewWillAppear = false

        let realm = try! Realm()
        DemoData.createDemoDataSet1(in: realm)

        items = realm.objects(ContentPage.self)
            .filter("priority > 0")
            .sorted(byKeyPath: "priority")
    }

    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PageCollectionViewCell
        cell.populateFromPage(page: items[indexPath.row] )
        cell.contentView.backgroundColor = (items[indexPath.row].priority >= 10) ? UIColor.orange : UIColor.yellow
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let page = items[indexPath.row]
        navigationController!.pushViewController(ContentViewController(page: page) , animated: true)
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath)
        header.subviews.filter { $0.isKind(of: UILabel.self) }.map {$0 as! UILabel}.first!.text = "Content Pages"
        return header
    }
}
