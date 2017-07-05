//
//  RealmContentDataSource.swift
//  Created by Marin Todorov
//  Copyright © 2017 - present Realm. All rights reserved.
//

import Foundation
import RealmSwift

/// represents a single element in a content page
public class ContentElement: Object {

    /// the supported element types
    public enum Kind: String {
        case p, img, h1, h2, h3, h4
    }

    public dynamic var type = "p"
    public dynamic var content = ""
    public dynamic var url: String?
    
}

extension ContentElement {
    override public var hashValue: Int {
        return (31 &* content.hashValue) &+ type.hashValue
    }
}
