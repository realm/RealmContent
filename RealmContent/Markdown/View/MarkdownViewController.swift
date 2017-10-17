//
//  RealmContentDataSource.swift
//  Created by Marin Todorov
//  Copyright © 2017 - present Realm. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import SafariServices
import MMMarkdown
import RealmSwift
import NSString_Color

/// a view controller, which owns a `MarkdownView`
public class MarkdownViewController: UIViewController {

    // types of content input
    public enum Content {
        case page(ContentPage)
        case markdown(String)
    }

    private var content: Content!
    public var page: ContentPage! {
        didSet {
            content = .page(self.page)
        }
    }

    public var openCustomURL: ((URL)->Void)?

    // the controller's view
    private let webView = MarkdownView()

    // realm notifications
    private var pageUpdatesToken: NotificationToken?
    private var pageElementsUpdatesToken: NotificationToken?

    // dynamically update the content
    private func observe(page: ContentPage) {
        pageUpdatesToken?.invalidate()
        pageElementsUpdatesToken?.invalidate()

        // load the page content
        populateFrom(page: page)

        // enable updates
        pageUpdatesToken = page.observe { [weak self] change in
            switch change {
            case .change: self?.populateFrom(page: page)
            case .deleted: self?.pageUpdatesToken = nil
            default: break
            }
        }

        pageElementsUpdatesToken = page.elements.observe { [weak self] change in
            switch change {
            case .update: self?.populateFrom(page: page)
            default: break
            }
        }
    }

    public var usesSafariController = true
    public var customCssStyle: String? = nil

    public init(page: ContentPage) {
        self.content = .page(page)
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func populateFrom(markdown md: String) {
        var renderOptions = [MarkdownRenderOption]()
        if let css = customCssStyle {
            renderOptions.append(.customCss(css))
        }
        webView.render(markdown: md, options: renderOptions)
    }

    private func populateFrom(page: ContentPage) {
        title = page.title

        let pageRef = ThreadSafeReference(to: page)
        let configuration = page.realm!.configuration

        DispatchQueue.global(qos: .background).async { [weak self] in
            let realm = try! Realm(configuration: configuration)
            guard let page = realm.resolve(pageRef) else { return }

            let markdown = MarkdownContentConverter.markdownFrom(
                page: page, options: [.addNewlines])

            var renderOptions = [MarkdownRenderOption]()
            if let color = page.mainColor {
                renderOptions.append(.mainColor(color))
            }
            if let css = self?.customCssStyle {
                renderOptions.append(.customCss(css))
            }
            DispatchQueue.main.async { [weak self] in
                self?.webView.render(markdown: markdown, options: renderOptions)
            }
        }
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        view = webView
        webView.delegate = self

        switch content! {
        case .page(let page):
            observe(page: page)
            populateFrom(page: page)
        case .markdown(let md):
            populateFrom(markdown: md)
        }
    }
}

extension MarkdownViewController: UIWebViewDelegate {
    public func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == .linkClicked, let url = request.url {
            // website
            if let scheme = url.scheme, scheme == "app" {
                openCustomURL?(url)
            } else if usesSafariController, let scheme = url.scheme, scheme.hasPrefix("http") {
                let safari = SFSafariViewController(url: url)
                present(safari, animated: true, completion: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
            return false
        }
        return true
    }
}
