//
//  WaveBoxTests.swift
//  WaveBoxTests
//
//  Created by Harri on 28/11/18.
//  Copyright © 2018 Harri. All rights reserved.
//

import XCTest
@testable import WaveBox

class WaveBoxTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testIndexFunctions() {
        let simulator = ExplicitSimulator(Nx: 200, Ny: 300, Lx: 10.0, Ly: 10.0, C: 1.0, dt: 0.005)
        let ii = 40
        let jj = 50
        let II = simulator.I(i: ii, j: jj)
        XCTAssertEqual(ii, simulator.i(I: II))
        XCTAssertEqual(jj, simulator.j(I: II))
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
