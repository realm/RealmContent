//
//  User.swift
//  Created by Marin Todorov
//  Copyright © 2017 - present Realm. All rights reserved.
//

import Foundation
import RealmSwift

class Dog: Object {
    @objc dynamic var name = ""
    @objc dynamic var age = 0
}

class Person: Object {
    @objc dynamic var name = ""
    @objc dynamic var picture: NSData? = nil
    let dogs = List<Dog>()
}
