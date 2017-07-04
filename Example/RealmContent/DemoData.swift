//
//  ViewController+DemoData.swift
//  RealmContent
//
//  Created by Marin Todorov on 7/4/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation

import RealmSwift
import RealmContent

func createDemoData() {
    let realm = try! Realm()

    try! realm.write {
        let pages = realm.objects(ContentPage.self)
            .filter("title IN %@", ["About", "Formatting Showcase", "Store"])
        pages.map { $0.elements } .forEach(realm.delete)
        realm.delete(pages)

        let about = ContentPage(value: [
            "title": "About",
            "priority": 10,
            "mainColor": "purple",
            "tag": "Info"
            ])
        about.elements.append(
            ContentElement(value: ["type": "p", "content": "Just a placeholder text about Realm Content"])
        )

        let contact = ContentPage(value: [
            "title": "Formatting Showcase",
            "priority": 8,
            "mainColor": "purple",
            "tag": "Info"
            ])
        let elements: [ContentElement] = [
            ContentElement(value: ["type": "h1", "content": "Heading with h1"]),
            ContentElement(value: ["type": "h2", "content": "Heading with h2"]),
            ContentElement(value: ["type": "h3", "content": "Heading with h3"]),
            ContentElement(value: ["type": "h4", "content": "Heading with h4"]),
            ContentElement(value: ["type": "p", "content": "In publishing and graphic design, lorem ipsum is a filler text commonly used to demonstrate the graphic elements of a document or visual presentation. Replacing meaningful content with placeholder text allows designers to design the form of the content before the content itself has been produced. (source: Wikipedia)"]),
            ContentElement(value: ["type": "link", "content": "Link to Wikipedia", "url": "https://en.wikipedia.org/wiki/Lorem_ipsum"]),
            ContentElement(value: ["type": "img", "content": "http://realm.io/assets/img/news/2016-05-17-realm-rxswift/rx.png", "url": "https://news.realm.io/news/marin-todorov-realm-rxswift/"]),
            ContentElement(value: ["type": "p", "content": "Tap on the image above to open Realm's blog 🦄 ..."])
            ]
        contact.elements.append(objectsIn: elements)

        let store = ContentPage(value: [
            "title": "Store",
            "priority": 0,
            "mainColor": "purple",
            "tag": "Shopping"
            ])
        store.elements.append(
            ContentElement(value: ["type": "p", "content": "just a placeholder text"])
        )

        realm.add([about, contact, store])
    }
}
