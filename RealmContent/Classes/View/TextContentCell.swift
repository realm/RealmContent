//
//  RealmContentDataSource.swift
//  Created by Marin Todorov
//  Copyright © 2017 - present Realm. All rights reserved.
//

import Foundation
import UIKit
import NSString_Color

/// delegate protocol for handling URL taps
public protocol ContentCellDelegate {
    func openUrl(url: URL)
}

/// content cell that represents a text element in a content page
public class TextContentCell: UITableViewCell {

    /// read-write property with the default cell text color
    public static var defaultTextColor = UIColor.black

    /// the cell delegate, required
    public var delegate: ContentCellDelegate!

    // MARK: - private properties
    private let label = UILabel()
    private let verticalPadding: CGFloat = 0.0
    private let horizontalPadding: CGFloat = 0.0

    private var topConstraint: NSLayoutConstraint!
    private var bottomConstraint: NSLayoutConstraint!

    private var url: URL?

    private lazy var installTap: Void = {
        self.contentView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTap))
        )
    }()

    // MARK: - cell life-cycle

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let marginGuide = contentView.layoutMarginsGuide

        label.isUserInteractionEnabled = false
        label.textAlignment = .left
        label.textColor = TextContentCell.defaultTextColor
        label.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0

        // configure titleLabel
        contentView.addSubview(label)

        label.translatesAutoresizingMaskIntoConstraints = false
        let leading = label.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor, constant: horizontalPadding)
        topConstraint = label.topAnchor.constraint(equalTo: marginGuide.topAnchor, constant: verticalPadding)
        let trailing = label.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor, constant: horizontalPadding)
        bottomConstraint = label.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor, constant: verticalPadding)

        NSLayoutConstraint.activate([topConstraint, bottomConstraint, leading, trailing])
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func prepareForReuse() {
        label.text = nil
    }

    /// text cell rendering configuration struct
    public struct TextConfig {
        var mainColor: String?
        func color() -> UIColor {
            if let mainColor = mainColor, !mainColor.isEmpty {
                return NSString(string: mainColor).representedColor()
            } else {
                return TextContentCell.defaultTextColor
            }
        }
    }

    // MARK: - public methods

    /**
     Populates the cell content from a `ContentElement`
      - parameter element: the element object containing the cell text
      - parameter config: the rendering configuration for the given cell
     */
    public func populate(with element: ContentElement, config: TextConfig) {
        _ = installTap

        // text
        label.text = element.content

        // url
        if let urlString = element.url, let url = URL(string: urlString) {
            self.url = url
        } else {
            self.url = nil
        }

        guard let kind = ContentElement.Kind(rawValue: element.type) else { return }

        label.textColor = TextContentCell.defaultTextColor

        // formatting
        switch kind {
        case .p:
            label.font = UIFont.preferredFont(forTextStyle: .body)
        case .h1:
            label.font = UIFont.preferredFont(forTextStyle: .title1)
            label.textColor = config.color()
        case .h2:
            label.font = UIFont.preferredFont(forTextStyle: .title2)
            label.textColor = config.color()
        case .h3:
            label.font = UIFont.preferredFont(forTextStyle: .headline)
        case .h4:
            label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        case .link:
            label.font = UIFont.preferredFont(forTextStyle: .callout)
            label.textColor = config.color()
        default: break
        }

    }

    // MARK: - private methods
    
    internal func didTap() {
        guard let url = url else { return }
        label.alpha = 0.5
        UIView.animate(withDuration: 0.33, animations: {
            self.label.alpha = 1.0
        }, completion: {_ in
            self.delegate.openUrl(url: url)
        })
    }
}
