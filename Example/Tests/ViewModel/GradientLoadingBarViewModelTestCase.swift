//
//  GradientLoadingBarViewModelTestCase.swift
//  GradientLoadingBar_Tests
//
//  Created by Felix Mau on 26.12.17.
//  Copyright © 2017 Felix Mau. All rights reserved.
//

import XCTest
import LightweightObservable

@testable import GradientLoadingBar

class GradientLoadingBarViewModelTestCase: XCTestCase {
    // MARK: - Private properties

    private var sharedApplicationMock: SharedApplicationMock!
    private var notificationCenter: NotificationCenter!

    // MARK: - Public methods

    override func setUp() {
        super.setUp()

        sharedApplicationMock = SharedApplicationMock()
        notificationCenter = NotificationCenter()
    }

    override func tearDown() {
        notificationCenter = nil
        sharedApplicationMock = nil

        super.tearDown()
    }

    // MARK: - Test observable `superview`

    func testInitializerShouldSetupSuperviewObservableNil() throws {
        // When
        let viewModel = GradientLoadingBarViewModel(sharedApplication: sharedApplicationMock,
                                                    notificationCenter: notificationCenter)

        // Then
        let variable = try XCTUnwrap(viewModel.superview as? Variable, "Cast `Observable` instance to `Variable` in order to validate the initial value.")
        XCTAssertNil(variable.value)
    }

    func testInitializerShouldSetupSuperviewObservableWithKeyWindow() {
        // Given
        let keyWindow = UIWindow()
        keyWindow.makeKey()

        let otherWindow = UIWindow()
        sharedApplicationMock.windows = [keyWindow, otherWindow]

        // When
        let viewModel = GradientLoadingBarViewModel(sharedApplication: sharedApplicationMock,
                                                    notificationCenter: notificationCenter)

        // Then
        XCTAssertEqual(viewModel.superview.value, keyWindow)
    }

    func testInitializerShouldSetupSuperviewObservableAfterUIWindowDidBecomeKeyNotification() {
        // Given
        let keyWindow = UIWindow()
        keyWindow.makeKey()

        let otherWindow = UIWindow()
        sharedApplicationMock.windows = [otherWindow]

        let viewModel = GradientLoadingBarViewModel(sharedApplication: sharedApplicationMock,
                                                    notificationCenter: notificationCenter)

        // When
        sharedApplicationMock.windows.append(keyWindow)
        notificationCenter.post(name: UIWindow.didBecomeKeyNotification,
                                object: nil)

        // Then
        XCTAssertEqual(viewModel.superview.value, keyWindow)
    }

    func testDeinitShouldResetSuperviewObservableToNil() {
        // Given
        let keyWindow = UIWindow()
        keyWindow.makeKey()

        let otherWindow = UIWindow()
        sharedApplicationMock.windows = [keyWindow, otherWindow]

        var viewModel: GradientLoadingBarViewModel? = GradientLoadingBarViewModel(sharedApplication: sharedApplicationMock,
                                                                                  notificationCenter: notificationCenter)

        let expectation = self.expectation(description: "Expected observer to be informed to reset superview to nil.")
        var disposeBag = DisposeBag()

        // As we've just initialized the view model it has to exist at this point, and therefore we can "safely" use force-unwrapping here.
        // swiftlint:disable:next force_unwrapping
        viewModel!.superview.subscribe { newSuperview, _ in
            guard newSuperview == nil else {
                // Skip initial call to observer.
                return
            }

            expectation.fulfill()
        }.disposed(by: &disposeBag)

        // When
        viewModel = nil

        // Then
        wait(for: [expectation], timeout: 0.1)
    }
}

// MARK: - Mocks

class SharedApplicationMock: UIApplicationProtocol {
    var windows = [UIWindow]()
}
