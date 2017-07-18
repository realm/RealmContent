//
//  RealmContentDataSource.swift
//  Created by Marin Todorov
//  Copyright © 2017 - present Realm. All rights reserved.
//

import Foundation

import UIKit
import RealmSwift
import MMMarkdown
import WebKit

public enum MarkdownRenderOption {
    case mainColor(String)
    case linkColor(String)
    case customCss(String)
}

/// a webview sub-class rendering markdown
public class MarkdownView: UIWebView {

    // options
    private var mainColor = "#000000"
    private var linkColor: String? = nil
    private var customCss = ""

    public func render(markdown: String, options: [MarkdownRenderOption] = []) {

        for option in options {
            switch option {
            case .mainColor(let hex): mainColor = hex
            case .linkColor(let hex): linkColor = hex
            case .customCss(let css): customCss = css
            }
        }

        guard let mdHtml = try? MMMarkdown.htmlString(withMarkdown: markdown, extensions: MMMarkdownExtensions.gitHubFlavored) else {
            loadHTMLString("", baseURL: nil)
            return
        }

        var fullPage = MarkdownTemplate.html.replacingOccurrences(of: "%markdown%", with: mdHtml)
        fullPage = fullPage.replacingOccurrences(of: "%headingColor%", with: mainColor)
        fullPage = fullPage.replacingOccurrences(of: "%linkColor%", with: (linkColor ?? mainColor))
        fullPage = fullPage.replacingOccurrences(of: "%customCss%", with: customCss)
        fullPage = fullPage.replacingOccurrences(of: "%fontSize%", with: "\(UIFont.systemFontSize)px")
        fullPage = fullPage.replacingOccurrences(of: "%fontName%", with: UIFont.systemFont(ofSize: UIFont.systemFontSize).fontName)
        loadHTMLString(fullPage, baseURL: nil)
    }
}

private struct MarkdownTemplate {
    static let html = "<html><head>"
        + "<meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0'>"
        + "<style> html { min-height: 100%; }"
        + "body { font-family: '%fontName%'; font-size: %fontSize%; margin: 0px; padding: 16px; padding-bottom:60px; background: white; line-height: 1.2em; }"
        + "h1, h2, h3, h4, h5, h6 { color: %headingColor% }"
        + "a:link {color: %linkColor%} strong {color: %linkColor%} img {border:0px; max-width:90%; margin:auto;}"
        + "%customCss%"
        + "</style></head><body>%markdown%</body></html>"
}
