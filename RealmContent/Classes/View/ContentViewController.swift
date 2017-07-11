//
//  RealmContentDataSource.swift
//  Created by Marin Todorov
//  Copyright © 2017 - present Realm. All rights reserved.
//

import Foundation
import UIKit
import SafariServices
import RealmSwift
import Kingfisher

/**
 `ContentViewController` is a view controller, which displays a given `ContentPage`'s content
 */
public class ContentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // MARK: - public properties

    /// whether to use Safari controller to open URLs
    public var usesSafariController = true
    public var openCustomURL: ((URL)->Void)?
    public var customizeCell: ((UITableViewCell, IndexPath, ContentElement)->Void)?

    // MARK: - private properties
    private let tableView = UITableView()
    public var page: ContentPage!
    private var lastHashes = [Int]()

    /// realm notifications
    private var pageUpdatesToken: NotificationToken?
    private var pageElementsUpdatesToken: NotificationToken?

    // MARK: - initialization

    /// initialize with a given content page
    public init(page: ContentPage) {
        self.page = page
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - view controller life-cycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = page.title
        observe(page: page)

        NotificationCenter.default.addObserver(forName: .UIContentSizeCategoryDidChange, object: .none, queue: OperationQueue.main) { [weak self] _ in
            self?.tableView.reloadData()
        }
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pageUpdatesToken = nil
        pageElementsUpdatesToken = nil

        NotificationCenter.default.removeObserver(self, name: .UIContentSizeCategoryDidChange, object: .none)
    }

    // MARK: - private methods

    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 40
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.register(TextContentCell.self, forCellReuseIdentifier: String(describing: TextContentCell.self))
        tableView.register(ImageContentCell.self, forCellReuseIdentifier: String(describing: ImageContentCell.self))

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }

    private func observe(page: ContentPage) {
        pageUpdatesToken?.stop()
        pageElementsUpdatesToken?.stop()

        // load the page content
        populateFrom(page: page)

        // enable updates
        pageUpdatesToken = page.addNotificationBlock() { [weak self] change in
            switch change {
            case .change(let properties):
                for p in properties {
                    switch p.name {
                    case "title": self?.title = p.newValue as? String
                    case "mainColor": self?.tableView.reloadData()
                    default: break
                    }
                }
            case .deleted: self?.pageUpdatesToken = nil
            default: break
            }
        }

        pageElementsUpdatesToken = page.elements.addNotificationBlock(applyChanges)
    }

    private func populateFrom(page: ContentPage) {
        title = page.title
    }

    // MARK: - table methods
    private func fromRow(_ section: Int) -> (_ row: Int) -> IndexPath {
        return { row in
            return IndexPath(row: row, section: section)
        }
    }

    private func applyChanges(_ changes: RealmCollectionChange<List<ContentElement>>) {
        let section = 0

        switch changes {
        case .initial(let elements):
            lastHashes = elements.map { $0.hashValue }
            tableView.reloadData()

        case .update(let elements, var deletions, var insertions, let modifications):

            let deletedHashes = deletions.map { lastHashes[$0].hashValue }
            let insertedHashes = insertions.map { elements[$0].hashValue }

            typealias IndexedValue = (index: Int, value: Int)
            typealias Move = (from: Int, to: Int)

            let moves = insertedHashes.enumerated()
                .flatMap({ (newIndex, hash) -> (from: IndexedValue, to: IndexedValue)? in
                    if let oldIndex = deletedHashes.index(of: hash) {
                        return (
                            from: (index: oldIndex, value: deletions[oldIndex]),
                            to: (index: newIndex, value: insertions[newIndex])
                        )
                    } else {
                        return nil
                    }
                })

            moves.map({ $0.from.index }).forEach { deletions.remove(at: $0) }
            moves.map({ $0.to.index }).forEach { insertions.remove(at: $0) }

            tableView.beginUpdates()
            tableView.deleteRows(at: deletions.map(fromRow(section)), with: .automatic)
            tableView.insertRows(at: insertions.map(fromRow(section)), with: .automatic)
            tableView.reloadRows(at: modifications.map(fromRow(section)), with: .none)

            moves.forEach { print("move from \($0.from.value) to \($0.to.value)") }

            moves.forEach {
                tableView.moveRow(
                    at: fromRow(section)($0.from.value),
                    to: fromRow(section)($0.to.value)
                )
            }

            tableView.endUpdates()

            lastHashes = elements.map { $0.hashValue }
        default: break
        }
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return page.elements.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let element = page.elements[indexPath.row]

        guard let kind = ContentElement.Kind(rawValue: element.type) else {
            return UITableViewCell()
        }

        switch kind {
        case .h1, .h2, .h3, .h4, .p:
            let cellId = String(describing: TextContentCell.self)
            let cell: TextContentCell = tableView.dequeueReusableCell(withIdentifier: cellId) as! TextContentCell
            cell.populate(with: element, config: TextContentCell.TextConfig(mainColor: page.mainColor))
            cell.delegate = self
            return cell

        case .img:
            let cellId = String(describing: ImageContentCell.self)
            let cell: ImageContentCell = tableView.dequeueReusableCell(withIdentifier: cellId) as! ImageContentCell
            cell.populate(with: element) { [weak self] in
                self?.tableView.beginUpdates()
                self?.tableView.endUpdates()
            }
            cell.delegate = self
            return cell
        }
    }

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        customizeCell?(cell, indexPath, page.elements[indexPath.row])
    }
}

/// content cell delegate methods
extension ContentViewController: ContentCellDelegate {
    public func openUrl(url: URL) {
        if let scheme = url.scheme, scheme == "app" {
            openCustomURL?(url)
            return
        }

        guard usesSafariController, let scheme = url.scheme, scheme.hasPrefix("http") else {
            UIApplication.shared.openURL(url)
            return
        }

        let safari = SFSafariViewController(url: url)
        present(safari, animated: true, completion: nil)
    }
}
