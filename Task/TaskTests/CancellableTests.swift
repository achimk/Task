//
//  Created by Joachim Kret on 25.07.2018.
//  Copyright © 2018 JK. All rights reserved.
//

import XCTest
@testable import Task

final class CancellableTests: XCTestCase {
    
    func testNoopCancel() {
        
        // Given
        let token = Cancelables.noop()
        XCTAssertFalse(token.isCancelled)
        
        // When
        token.cancel()
        
        // Then
        XCTAssertTrue(token.isCancelled)
    }
    
    func testAnyCancel() {
        
        // Given
        var invoked = false
        let token = Cancelables.any {
            invoked = true
        }
        XCTAssertFalse(invoked)
        XCTAssertFalse(token.isCancelled)
        
        // When
        token.cancel()
        
        // Then
        XCTAssertTrue(token.isCancelled)
        
    }
    
    func testSingleCancel() {
        
        // Given
        var invoked = false
        let other = Cancelables.any {
            invoked = true
        }
        
        let token = Cancelables.single()
        XCTAssertFalse(token.isCancelled)
        XCTAssertFalse(invoked)
        
        // When
        token.set(other)
        token.cancel()
        
        // Then
        XCTAssertTrue(token.isCancelled)
    }
    
    func testSerialCancel() {
        
        // Given
        var invokedFirst = false
        let first = Cancelables.any {
            invokedFirst = true
        }
        
        var invokedSecond = false
        let second = Cancelables.any {
            invokedSecond = true
        }
        
        let token = Cancelables.serial()
        XCTAssertFalse(token.isCancelled)
        XCTAssertFalse(invokedFirst)
        XCTAssertFalse(invokedSecond)
        
        // When
        token.cancelable = first
        XCTAssertFalse(first.isCancelled)
        XCTAssertFalse(second.isCancelled)
        
        token.cancelable = second
        XCTAssertTrue(first.isCancelled)
        XCTAssertFalse(second.isCancelled)
        
        token.cancel()
        
        // Then
        XCTAssertTrue(token.isCancelled)
    }
}
