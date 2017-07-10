//
//  DemosTableViewController.swift
//  RealmContent
//
//  Created by Marin Todorov on 7/10/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import RealmSwift
import RealmContent

let defaultTextColor = TextContentCell.defaultTextColor

class DemosTableViewController: UITableViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier, let vc = segue.destination as? ContentViewController else { return }

        // fetch page
        let realm = try! Realm()
        DemoData.createDemoDataSet1(in: realm)

        let page = realm.objects(ContentPage.self)
            .filter("id = %@", "showcase")
            .first!

        // inject it in view controller
        switch identifier {
        case "DefaultPage":
            // vanilla formatting
            try! realm.write {
                page.mainColor = nil
            }
            TextContentCell.defaultTextColor = defaultTextColor

            vc.page = page

        case "CustomColor":
            // custom color
            try! realm.write {
                page.mainColor = "#cc3355"
            }
            TextContentCell.defaultTextColor = .brown

            vc.page = page

        case "CustomElements":
            // customized elements
            vc.page = page
            vc.customizeCell = customizeElementBlock

        default: break
        }
    }

    func customizeElementBlock(cell: UITableViewCell, indexPath: IndexPath, element: ContentElement) {
        var dashColor: UIColor
        if let _ = cell as? TextContentCell {
            dashColor = .blue
        } else {
            dashColor = .red
        }

        if indexPath.row % 2 == 0 {
            cell.contentView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        }
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
}
