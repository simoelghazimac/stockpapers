//
//  StockpapersUITests.swift
//  StockpapersUITests
//
//  Created by Federico Vitale on 11/11/2018.
//  Copyright © 2018 Federico Vitale. All rights reserved.
//

import XCTest

class StockpapersUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app = XCUIApplication()
        
        app.launchArguments.append("--uitesting")
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    func testFullScreenMode() {
        app.launch()
        
        let homeCell = app.cells["firstHomeCell"]
        let firstPhotoCell = app.cells["firstCollectionCell"]
        
        XCTAssertTrue(app.isLoading)
        
        waitForElementToAppear(homeCell, waitFor: 60)
        XCTAssertTrue(app.isDisplayingHome)
        homeCell.tap()
        
        waitForElementToAppear(firstPhotoCell, waitFor: 15)
        XCTAssertTrue(app.isDisplayingCollection)
        firstPhotoCell.tap()
        
        waitForElementToAppear(app.buttons["closeButton"], waitFor: 60)
        XCTAssertTrue(app.isDisplayingFullScreen)

        app.buttons["rotateButton"].tap() // 45°
        app.buttons["rotateButton"].tap() // 90°
        app.buttons["rotateButton"].tap() // 180°
        app.buttons["rotateButton"].tap() // 360°
        sleep(1)
        
        app.buttons["favoritesButton"].tap()
        sleep(1)
        app.buttons["favoritesButton"].tap()
        sleep(2)
        
        app.buttons["downloadButton"].tap()
        sleep(3)
        
        app.buttons["closeButton"].tap()
    }
    
    
    func testSettingsVC() {
        app.launch()
        let pref = app.buttons["PreferencesButton"];
        let toggleDarkTheme = app.switches["toggleDarkTheme"]
        let toggleHQ = app.switches["toggleHQPreview"]
        let toggleStatusBar = app.switches["toggleStatusBarOnPreview"]
//
//        let accentColorCell = app.cells["accentColor"]
//        let restorePurchases = app.cells["restorePurchases"]
//        let removeWatermarks = app.cells["removeWatermarks"]
//        let unsplashLogin = app.cells["unsplashLogin"]
//        let about = app.cells["aboutCell"]
        
        waitForElementToAppear(pref)
        pref.tap()
        sleep(2)
        
        
        toggleDarkTheme.tap()
        toggleDarkTheme.tap()
        toggleDarkTheme.tap()
        toggleDarkTheme.tap()
        toggleDarkTheme.tap()
        sleep(2)
        
        toggleHQ.tap()
        sleep(2)
        
        toggleStatusBar.tap()
        sleep(2)
    }
    
    func waitForElementToAppear(_ element: XCUIElement, waitFor: TimeInterval = 5) {
        let existsPredicate = NSPredicate(format: "exists == true")
        expectation(for: existsPredicate, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: waitFor, handler: nil)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        app.screenshot()
    }
}


extension XCUIApplication {
    var isDisplayingFullScreen: Bool {
        return otherElements["FullScreenPictureVC"].exists
    }
    
    var isDisplayingHome: Bool {
        return otherElements["HomeVC"].exists
    }
    
    var isDisplayingCollection: Bool {
        return otherElements["CollectionVC"].exists
    }
    
    var isLoading: Bool {
        return otherElements["LoadingVC"].exists
    }
}
