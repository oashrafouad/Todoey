//
//  Category.swift
//  Todoey
//
//  Created by Omar Ashraf on 07/11/2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name = ""
    @objc dynamic var color = ""
    var items = List<Item>()
}
