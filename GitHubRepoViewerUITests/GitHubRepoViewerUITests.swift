//
//  GitHubRepoViewerUITests.swift
//  GitHubRepoViewerUITests
//
//  Created by Amir Daliri on 19.02.2024.
//

import XCTest

final class GitHubRepoViewerUITests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        
        let app = XCUIApplication()
        app.launchArguments = ["-UITesting"]
        app.launch()
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
    
    func testFirstRepositoryCellAppears() throws {
        let app = XCUIApplication()
        
        // Adjust this identifier based on the actual identifier used in your app
        let firstRepositoryCell = app.tables.cells.element(boundBy: 0)
        
        // Increase the timeout if necessary to account for app launch time, data fetching, etc.
        let exists = NSPredicate(format: "exists == true")
        
        expectation(for: exists, evaluatedWith: firstRepositoryCell, handler: nil)
        waitForExpectations(timeout: 20, handler: nil) // Adjust the timeout based on your app's performance
        
        XCTAssert(firstRepositoryCell.exists, "The first repository cell should be visible on the screen.")
    }
    
    // Need to Improvements
    /*
    func testRepositorySearchBarEnable() throws {
        let app = XCUIApplication()
        
        let searchBar = app.otherElements["MainSearchBarIdentifier"]

        XCTAssertTrue(searchBar.waitForExistence(timeout: 5), "The search bar should exist.")

        searchBar.tap()
        
        XCTAssertTrue(searchBar.isEnabled, "The search bar Is enable.")
    }

    func testRepositorySearchFunctionality() throws {
        
        let app = XCUIApplication()
        app.navigationBars["Repositories"].tap()
        app.otherElements.containing(.activityIndicator, identifier:"In progress").children(matching: .other).element.swipeUp()

        
        app.tables/*@START_MENU_TOKEN@*/.staticTexts["Some tools for debugging/testing the VRF"]/*[[".cells.staticTexts[\"Some tools for debugging\/testing the VRF\"]",".staticTexts[\"Some tools for debugging\/testing the VRF\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.navigationBars["vrf"].buttons["Repositories"].tap()
                                        
    }
    
    func testRepositorySearchFunctionality2() throws {
        let app = XCUIApplication()
        
        // Replace "SearchBarIdentifier" with the actual accessibility identifier of your search bar
        let searchBar = app.searchFields["SearchBarIdentifier"]
        XCTAssertTrue(searchBar.waitForExistence(timeout: 10), "The search bar should exist.")

        searchBar.tap()
        searchBar.typeText("teal") // Replace "YourSearchTerm" with a term expected to return results
        
        // Verify that at least one cell appears after searching, adjust the identifier as needed
        let firstResultCell = app.tables.cells.element(boundBy: 0)
        let exists = NSPredicate(format: "exists == true")
        
        expectation(for: exists, evaluatedWith: firstResultCell, handler: nil)
        waitForExpectations(timeout: 10, handler: nil) // Adjust the timeout based on your app's performance
        
        XCTAssert(firstResultCell.exists, "The search should return at least one repository.")
    }

    func testNavigationToRepositoryDetails() throws {
        let app = XCUIApplication()
        
        // Assuming the first cell is always there for the purpose of this test, adjust if necessary
        let firstRepositoryCell = app.tables.cells.element(boundBy: 0)
        
        let exists = NSPredicate(format: "exists == true")
        expectation(for: exists, evaluatedWith: firstRepositoryCell, handler: nil)
        waitForExpectations(timeout: 10, handler: nil) // Adjust the timeout based on your app's performance
        
        XCTAssert(firstRepositoryCell.exists, "The first repository cell should exist.")
        firstRepositoryCell.tap()
        
        // Replace "DetailViewIdentifier" with the actual accessibility identifier for elements in the detail view
        let detailViewElement = app.otherElements["DetailViewIdentifier"]
        expectation(for: exists, evaluatedWith: detailViewElement, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssert(detailViewElement.exists, "The detail view should be displayed after tapping a repository cell.")
    }

    func testErrorMessageDisplayOnNetworkError() throws {
        let app = XCUIApplication()
        // This requires the app to be configured to simulate a network error condition
        app.launchArguments += ["-simulateNetworkError"]
        app.launch()
        
        // Replace "ErrorViewIdentifier" with the actual accessibility identifier of your error message UI element
        let errorMessage = app.staticTexts["ErrorViewIdentifier"]
        
        let exists = NSPredicate(format: "exists == true")
        expectation(for: exists, evaluatedWith: errorMessage, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssert(errorMessage.exists, "An error message should be displayed in case of a network error.")
    }
    */
}
