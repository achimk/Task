//
//  Created by Joachim Kret on 17.07.2018.
//  Copyright © 2018 JK. All rights reserved.
//

import XCTest
@testable import Task

final class TaskTests: XCTestCase {
    
    func testAnyTaskExecution() {
        
        // Given
        var output: String? = nil
        
        let task = AnyTask<Int, String> { (input, completion) in completion(String(input)); return Cancelables.noop() }
        
        // When
        task.run(1) { output = $0 }
        
        // Then
        XCTAssertEqual(output, "1")
        
    }
    
    func testTaskChaining() {
        
        // Given
        var output: String? = nil
        
        let increment: Task<Int, Int> = AnyTask { (input, completion) in
            completion(input.advanced(by: 1))
            return Cancelables.noop()
        }
        
        let multiply: Task<Int, Int> = AnyTask { (input, completion) in
            completion(input * 2)
            return Cancelables.noop()
        }
        
        let convert: Task<Int, String> = AnyTask { (input, completion) in
            completion(String(input))
            return Cancelables.noop()
        }
        
        
        // When
        increment.then(multiply).then(convert).run(1) { output = $0 }
        
        // Then
        XCTAssertEqual(output, "4")
        
    }
    
    func testAsyncTaskChaining() {
        
        // Given
        var output: String? = nil
        
        let increment: Task<Int, Int> = AnyTask { (input, completion) in
            completion(input.advanced(by: 1))
            return Cancelables.noop()
        }
        
        let multiply: Task<Int, Int> = AnyTask { (input, completion) in
            completion(input * 2)
            return Cancelables.noop()
        }
        
        let convert: Task<Int, String> = AnyTask { (input, completion) in
            completion(String(input))
            return Cancelables.noop()
        }
        
        let exp = expectation(description: "")
        
        // When
        increment
            .async(.global(qos: .background))
            .then(multiply)
            .then(convert)
            .async(.main)
            .run(1) { result in
                output = result
                exp.fulfill()
            }
        
        // Then
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssertEqual(output, "4")
    }
    
    func testCancelChainedTasks() {
        
        var runTask1 = false
        var runTask2 = false
        var completed = false
        
        let task1 = Task<Int, Int>.create { (input, completion) -> Cancelable in
        
            runTask1 = true

            completion(input)
            
            return Cancelables.noop()
        }
        
        let taskCancel = Task<Int, Int>.create { (input, completion) -> Cancelable in
            
            let dispose = Cancelables.noop()
            
            dispose.cancel()
            
            return dispose
        }
        
        let task2 = Task<Int, Int>.create { (input, completion) -> Cancelable in
            
            runTask2 = true
            
            completion(input)
            
            return Cancelables.noop()
        }
        
        _ = task1
            .then(taskCancel)
            .then(task2)
            .run(1) { _ in
                completed = true
            }

        XCTAssertTrue(runTask1)
        XCTAssertFalse(runTask2)
        XCTAssertFalse(completed)
    }
}
