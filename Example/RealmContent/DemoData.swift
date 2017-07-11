//
//  ViewController+DemoData.swift
//
//  Created by Marin Todorov
//  Copyright © 2017 - present Realm. All rights reserved.
//

import Foundation

import RealmSwift
import RealmContent

struct DemoData {

    static func createDemoDataSet2(in realm: Realm) {
        try! realm.write {
            realm.deleteAll()

            let contact = ContentPage(value: [
                "title": "Interactions Showcase",
                "mainColor": "Blue",
                "id": "interactions"
                ])
            let elements: [ContentElement] = [
                ContentElement(value: ["type": "p", "content": "This is a text"]),
                ContentElement(value: ["type": "p", "content": "This is a text with a URL", "url": "https://www.wikipedia.com"]),
                ContentElement(value: ["type": "p", "content": "Below is a heading with a URL"]),
                ContentElement(value: ["type": "h2", "content": "Tap me!", "url": "https://www.kiva.org"]),
                ContentElement(value: ["type": "p", "content": "Below is an image with url"]),
                ContentElement(value: ["type": "img", "content": "http://realm.io/assets/img/news/2016-05-17-realm-rxswift/rx.png", "url": "https://news.realm.io/news/marin-todorov-realm-rxswift/"]),
                ContentElement(value: ["type": "p", "content": "Below is a custom schema URL of this type: app://product/id/134. This schema allows you to implement custom app logic when the user taps on a link."]),
                ContentElement(value: ["type": "h2", "content": "Add to cart", "url": "app://product/id/134"])
            ]
            contact.elements.append(objectsIn: elements)

            realm.add(contact)
        }
    }

    static func createDemoDataSet1(in realm: Realm) {
        try! realm.write {
            realm.deleteAll()

            let about = ContentPage(value: [
                "title": "About",
                "priority": 10,
                "mainColor": "purple",
                "tag": "Info"
                ])
            about.elements.append(
                ContentElement(value: ["type": "p", "content": "A demo about page"])
            )

            let contact = ContentPage(value: [
                "title": "Formatting Showcase",
                "priority": 8,
                "mainColor": "purple",
                "tag": "Info",
                "id": "showcase"
                ])
            let elements: [ContentElement] = [
                ContentElement(value: ["type": "h1", "content": "Heading with h1"]),
                ContentElement(value: ["type": "h2", "content": "Heading with h2"]),
                ContentElement(value: ["type": "h3", "content": "Heading with h3"]),
                ContentElement(value: ["type": "h4", "content": "Heading with h4"]),
                ContentElement(value: ["type": "p", "content": "In publishing and graphic design, lorem ipsum is a filler text commonly used to demonstrate the graphic elements of a document or visual presentation. Replacing meaningful content with placeholder text allows designers to design the form of the content before the content itself has been produced. (source: Wikipedia)"]),
                ContentElement(value: ["type": "p", "content": "Link to Wikipedia", "url": "https://en.wikipedia.org/wiki/Lorem_ipsum"]),
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
                ContentElement(value: ["type": "p", "content": "A demo store page"])
            )
            
            realm.add([about, contact, store])
        }
    }
}
