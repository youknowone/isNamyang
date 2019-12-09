//
//  isNamyangTests.swift
//  isNamyangTests
//
//  Created by Jeong YunWon on 2019/12/09.
//  Copyright © 2019 NullFull. All rights reserved.
//

@testable import isNamyang
import XCTest

class isNamyangTests: XCTestCase {
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        service = Service()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBarcode() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        let item = service.database.search(barcode: "8801069403427")!
        XCTAssertEqual(item.name, "루카스나인 리저브 드립 인 스틱 과테말라 안티구아 블렌드")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
}
