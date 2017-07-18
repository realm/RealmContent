//
//  RealmContentDataSource.swift
//  Created by Marin Todorov
//  Copyright © 2017 - present Realm. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

/// content cell that represents an image element in a content page
public class ImageContentCell: UITableViewCell {

    /// read-write property with the default image corner radius
    public static var defaultCornerRadius: CGFloat = 6.0

    /// the cell delegate, required
    public var delegate: ContentCellDelegate!

    // MARK: - private properties
    private let img = UIImageView()
    private let padding: CGFloat = 2.0

    private var heightConstraint: NSLayoutConstraint!

    private var url: URL?

    private lazy var installTap: Void = {
        self.img.isUserInteractionEnabled = true
        self.img.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTap))
        )
    }()

    lazy private var placeholder: UIImage = {
        return self.placeholderImage(
            size: CGSize(width: self.contentView.bounds.size.width, height: 40.0)
        )
    }()

    // MARK: - cell life-cycle
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let marginGuide = contentView.layoutMarginsGuide

        img.contentMode = .scaleAspectFit

        // configure titleLabel
        contentView.addSubview(img)
        img.translatesAutoresizingMaskIntoConstraints = false
        img.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor).isActive = true
        img.topAnchor.constraint(equalTo: marginGuide.topAnchor).isActive = true
        img.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
        img.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true
        heightConstraint = img.heightAnchor.constraint(equalToConstant: 20)
        heightConstraint.isActive = true
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func prepareForReuse() {
        img.image = nil
    }

    // MARK: - public methods

    /**
     Populates the cell content from a `ContentElement`
     - parameter element: the element object containing the cell text
     - parameter relayout: a closure to call when cell height changes and table view needs a re-layout
     */
    public func populate(with element: ContentElement, relayout: @escaping (()->Void)) {
        _ = installTap

        if let url = URL(string: element.content) {
            img.kf.setImage(
                with: url, placeholder: placeholder,
                options: [.backgroundDecode, .processor(RoundCornerImageProcessor(cornerRadius: ImageContentCell.defaultCornerRadius))],
                completionHandler: { [weak self] (image, error, cache, url) in
                    guard let this = self, let image = image else { return }
                    if image.size.width > this.contentView.frame.width {
                        let newHeight = (this.contentView.frame.width * image.size.height) / image.size.width
                        this.heightConstraint.constant = newHeight
                    } else {
                        this.heightConstraint.constant = image.size.height
                    }
                    DispatchQueue.main.async(execute: relayout)
            })
        }

        if let urlString = element.url, let url = URL(string: urlString) {
            self.url = url
        } else {
            self.url = nil
        }
    }

    // MARK: - private methods

    private func placeholderImage(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, true, 0)

        let ctx = UIGraphicsGetCurrentContext()!
        ctx.saveGState()

        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)

        let path = UIBezierPath(rect: rect)
        UIColor.white.setFill()
        path.fill()

        let clipPath = UIBezierPath(roundedRect: rect, cornerRadius: 6.0).cgPath

        ctx.addPath(clipPath)
        ctx.setFillColor(UIColor(white: 0.95, alpha: 1.0).cgColor)

        ctx.closePath()
        ctx.fillPath()
        ctx.restoreGState()

        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }

    internal func didTap() {
        guard let url = url else { return }
        img.alpha = 0.67
        UIView.animate(withDuration: 0.33, animations: {
            self.img.alpha = 1.0
        }, completion: {_ in
            self.delegate.openUrl(url: url)
        })
    }
}
