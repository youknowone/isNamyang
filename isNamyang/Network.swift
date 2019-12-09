//
//  Network.swift
//  isNamyang
//
//  Created by Jeong YunWon on 2019/12/09.
//  Copyright © 2019 NullFull. All rights reserved.
//

import Foundation
import SVGKit
import SwiftCSV

class Service {
    static let HOST = "https://isnamyang.nullfull.kr"

    static var logoImage: UIImage? = loadLogo()
    let database: Database

    static func loadLogo() -> UIImage? {
        SVGKImage(contentsOf: URL(string: Service.HOST + "/isnamyang-logo.svg")!)?.uiImage
    }

    init?() {
        if Service.logoImage == nil {
            Service.logoImage = Service.loadLogo()
        }

        do {
            database = try Database()
        } catch {
            return nil
        }
    }
}

struct Item {
    let data: [String: String]

    var barcode: String {
        data["바코드"] ?? ""
    }

    var name: String {
        data["제품명"] ?? ""
    }
}

class Database {
    let items: [Item]

    init(items: [Item]) throws {
        self.items = items
    }

    convenience init() throws {
        let url = URL(string: "https://raw.githubusercontent.com/NullFull/isnamyang/master/backend/data/products.csv")!
        let csv = try CSV(url: url)
        var items: [Item] = []
        try csv.enumerateAsDict {
            items.append(Item(data: $0))
            print($0)
        }
        try self.init(items: items)
    }

    func search(barcode: String) -> Item? {
        items.first(where: { $0.barcode == barcode })
    }

    func search(keyword _: String) -> [Item] {
        []
    }
}

var service: Service! = Service()
