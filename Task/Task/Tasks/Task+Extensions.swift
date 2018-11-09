//
//  Created by Joachim Kret on 17.07.2018.
//  Copyright © 2018 JK. All rights reserved.
//

import Foundation

extension Task {
    
    public static func create(_ transform: @escaping (Input, @escaping (Output) -> ()) -> Cancelable) -> Task<Input, Output> {
        
        return AnyTask<Input, Output>(transform)
    }
    
    public static func never() -> Task<Input, Output> {
        
        return AnyTask<Input, Output> { (_, _) in Cancelables.noop() }
    }
    
    public func then<T>(_ other: Task<Output, T>) -> Task<Input, T> {
        
        return AnyTask { (input, completion) in

            let dispose = Cancelables.serial()
            
            dispose.cancelable = self.run(input, { (output) in
                
                if dispose.isCancelled { return }

                dispose.cancelable = other.run(output, completion)
            })
            
            return dispose
        }
    }
    
    public func async(_ queue: DispatchQueue) -> Task<Input, Output> {
        
        return AnyTask { (input, completion) in
            
            let dispose = Cancelables.single()
            
            let cancelable = self.run(input, { (output) in
                
                if dispose.isCancelled { return }
                
                queue.async {
                    
                    completion(output)
                }
            })
            
            dispose.set(cancelable)
            
            return dispose
        }
    }
}
