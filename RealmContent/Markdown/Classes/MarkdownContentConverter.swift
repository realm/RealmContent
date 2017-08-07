//
//  RealmContentDataSource.swift
//  Created by Marin Todorov
//  Copyright © 2017 - present Realm. All rights reserved.
//

import Foundation
import RealmSwift

/**
 `MarkdownConvertorOptions` is a set of options enabling conversion features as follows:
 
 - `includeTitle` starts the output with the `ContentPage` title as a h1 heading
 - `addNewlines` adds extra newline after each element

 */
struct MarkdownConvertorOptions : OptionSet {
    let rawValue: Int

    static let includeTitle  = MarkdownConvertorOptions(rawValue: 1 << 0)
    static let addNewlines = MarkdownConvertorOptions(rawValue: 1 << 1)
}

private let newLine = "\n"

/**
 `MarkdownContentConverter` is a struct with static content-conversion functions
 */
struct MarkdownContentConverter {

    /**
     Returns the markdown representation of the provided `ContentPage` object

     - parameter page: a content page with elements to convert to markdown
     - parameter options: a `MarkdownConvertorOptions` set of options to enable
     
     - returns: a markdown `String`
     */
    static func markdownFrom(page: ContentPage, options: MarkdownConvertorOptions = []) -> String {
        var result = ""

        if options.contains(.includeTitle), let title = page.title {
            result += "# \(title) \(newLine)"
        }

        for element in page.elements {
            if let kind = ContentElement.Kind(rawValue: element.type) {
                switch kind {
                case .p :
                    if let url = element.url {
                        result += "\(newLine) [\(element.content)](\(url))"
                    } else {
                        result += "\(newLine) \(element.content)"
                    }
                case .h1: result += "\(newLine) # \(element.content)"
                case .h2: result += "\(newLine) ## \(element.content)"
                case .h3: result += "\(newLine) ### \(element.content)"
                case .h4: result += "\(newLine) #### \(element.content)"
                case .img:
                    guard let url = element.url else { break }
                    if element.content.hasPrefix("http") {
                        result += "\(newLine) [![\(element.content)](\(url))](\(element.content))"
                    } else {
                        result += "\(newLine) ![\(element.content)](\(url))"
                    }
                }
                if options.contains(.addNewlines) {
                    result += newLine
                }
            }
        }

        return result
    }

}
