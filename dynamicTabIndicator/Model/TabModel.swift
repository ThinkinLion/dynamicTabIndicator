//
//  TabModel.swift
//  dynamicTabIndicator
//
//  Created by 1100690 on 2022/11/24.
//

import SwiftUI

struct TabModel: Identifiable, Hashable {
    let id: String = UUID().uuidString
    let name: String
    let image: String
}

var tabs: [TabModel] = [
    TabModel(name: "Iceland", image: "image1"),
    TabModel(name: "France", image: "image2"),
    TabModel(name: "Italy", image: "image3"),
]
