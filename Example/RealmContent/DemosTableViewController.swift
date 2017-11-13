//
//  DemosTableViewController.swift
//
//  Created by Marin Todorov
//  Copyright © 2017 - present Realm. All rights reserved.
//

import UIKit
import RealmSwift
import RealmContent

let defaultTextColor = TextContentCell.defaultTextColor

class DemosTableViewController: UITableViewController {

    private func getPage(realm: Realm, prep: (Realm)->Void, id: String) -> ContentPage {
        prep(realm)
        return realm.objects(ContentPage.self)
            .filter("uuid = %@", id)
            .first!
    }

    /// load demo content depending on the row tapped
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier  else { return }

        TextContentCell.defaultTextColor = defaultTextColor
        let realm = try! Realm()

        /// show content via MarkdownViewController
        if let vc = segue.destination as? MarkdownViewController {
            switch identifier {
            case "MarkdownAndHTML":
                // show markdown and html content
                let page = getPage(realm: realm, prep: DemoData.createDemoDataSet4, id: "formatting")
                vc.page = page
                vc.openCustomURL = handleCustomUrl

            default: break
            }
        }

        /// show content via ContentViewController
        if let vc = segue.destination as? ContentViewController {

            // inject it in view controller
            switch identifier {
            case "DefaultPage":
                // vanilla formatting
                let page = getPage(realm: realm, prep: DemoData.createDemoDataSet1, id: "showcase")
                try! realm.write {
                    page.mainColor = nil
                }

                vc.page = page

            case "CustomColor":
                // custom color
                let page = getPage(realm: realm, prep: DemoData.createDemoDataSet1, id: "showcase")
                try! realm.write {
                    page.mainColor = "#cc3355"
                }
                TextContentCell.defaultTextColor = .brown

                vc.page = page

            case "CustomElements":
                // customized elements
                let page = getPage(realm: realm, prep: DemoData.createDemoDataSet1, id: "showcase")
                vc.page = page
                vc.customizeCell = customizeElementBlock

            case "Interactions":
                // shows different interactions
                let page = getPage(realm: realm, prep: DemoData.createDemoDataSet2, id: "interactions")
                vc.page = page
                vc.openCustomURL = handleCustomUrl

            default: break
            }
        }
    }

    /// method which customizes all content blocks in a custom page
    func customizeElementBlock(cell: UITableViewCell, indexPath: IndexPath, element: ContentElement) {
        var dashColor: UIColor
        if let _ = cell as? TextContentCell {
            dashColor = .blue
        } else {
            dashColor = .red
        }

        cell.contentView.backgroundColor = UIColor(white: (indexPath.row % 2 == 0) ? 0.95 : 1.0, alpha: 1.0)

        let separator = cell.viewWithTag(1000) ?? {
            let v = UIView()
            v.tag = 1000
            let dash = CAShapeLayer()
            dash.fillColor = UIColor.clear.cgColor
            dash.lineWidth = 1.0
            dash.lineDashPattern = [2, 2]
            cell.contentView.addSubview(v)
            v.layer.addSublayer(dash)
            return v
            }()
        separator.frame = CGRect(x: 0, y: 0, width: cell.contentView.bounds.size.width, height: 1)
        let dash = separator.layer.sublayers![0] as! CAShapeLayer
        dash.frame = separator.bounds
        dash.path = UIBezierPath(roundedRect: cell.bounds.insetBy(dx: 6, dy: 6), cornerRadius: 10).cgPath
        dash.strokeColor = dashColor.cgColor
    }

    /// handles custom URL schemes in content
    func handleCustomUrl(url: URL) {

        let alert = UIAlertController(title: "Added to cart", message: "The product id \(url.lastPathComponent) has been successfully added to your cart", preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {[weak self] in
            self?.dismiss(animated: true, completion: nil)
        })
    }
}
