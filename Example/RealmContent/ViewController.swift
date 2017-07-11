//
//  ViewController.swift
//  Created by Marin Todorov
//  Copyright © 2017 - present Realm. All rights reserved.
//

import UIKit

// 1) Import RealmSwift + RealmContent

import RealmSwift
import RealmContent

class ViewController: UIViewController {

    @IBOutlet var tableView: UITableView!

    var items: ContentListDataSource!

    override func viewDidLoad() {
        super.viewDidLoad()

        // load the data into realm to display this demo
        let realm = try! Realm()
        DemoData.createDemoDataSet1(in: realm)

        // 2) create a content data source
        switch navigationItem.title! {
        case "Plain List":
            // one section, lists all pages by priority
            items = ContentListDataSource(style: .plain)
            items.loadContent(from: realm)
        case "List with Sections":
            // mulitple section, lists pages by priority within section
            items = ContentListDataSource(style: .sectionsByTag)
            items.loadContent(from: realm)
        case "Custom List Subset":
            // filter the content with a custom predicate
            items = ContentListDataSource(style: .plain)
            items.loadContent(from: realm, filter: NSPredicate(format: "priority > %d", 5))
        default: break
        }

        // 3) initialize the data source and set view to update
        items.updating(view: tableView)
    }
}

// 4) implement table/collection data source methods as you wish...

extension ViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return items.numberOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.numberOfItemsIn(section: section)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return items.titleForSection(section: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items.itemAt(indexPath: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!

        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = "»  \(item.title ?? "...")"

        return cell
    }
}

// 5) Push or present a ContentViewController to display content

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let item = items.itemAt(indexPath: indexPath)
        let vc = ContentViewController(page: item)

        navigationController!.pushViewController(vc, animated: true)
    }
}
