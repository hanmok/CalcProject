//
//  HelperTest.swift
//  CalieTests
//
//  Created by 핏투비 on 2022/09/05.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import XCTest

class HelperTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    
    func test_josaTest() {
//        func splitText(text: String) -> Bool {
        print("josa Testing started ")
        let text = "안씨"
            guard let text = text.last else {  fatalError() }
            let val = UnicodeScalar(String(text))?.value
            guard let value = val else {  fatalError() }
            
            let x = (value - 0xac00) / 28 / 21
            let y = ((value - 0xac00) / 28) % 21
            let z = (value - 0xac00) % 28
            
            print(x,y,z)//“안” -> 11 0 4
            
            let i = UnicodeScalar(0x1100 + x) //초성
            let j = UnicodeScalar(0x1161 + y) //중성
            let k = UnicodeScalar(0x11a6 + 1 + z) //종성
            
            guard let end = k else {  fatalError()}
//            if end.value == 4519 {
//                return false
//                }
//            return true
        print(i, j, k)
        
//            XCTAssertNotEqual(text, "")
        XCTAssertNotEqual(1, 0)
        }
    
}
