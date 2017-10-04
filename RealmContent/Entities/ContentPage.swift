//
//  RealmContentDataSource.swift
//  Created by Marin Todorov
//  Copyright © 2017 - present Realm. All rights reserved.
//

import Foundation
import RealmSwift

/// represents a single content page - news article, blog post, announcement, etc.
public class ContentPage: Object {

    public dynamic var title: String?
    public let elements = List<ContentElement>()
    public dynamic var priority = 0
    public dynamic var mainColor: String?
    public dynamic var lang: String?
    public dynamic var tag = ""
    public dynamic var uuid = UUID().uuidString

    override public static func indexedProperties() -> [String] {
        return ["priority", "tag"]
    }

    override public class func primaryKey() -> String {
        return "uuid"
    }
}
