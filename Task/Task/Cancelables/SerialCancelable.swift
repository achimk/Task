//
//  Created by Joachim Kret on 22.07.2018.
//  Copyright © 2018 JK. All rights reserved.
//

import Foundation

public final class SerialCancelable: Cancelable {
    
    private let lock = NSLock()
    private var cancelled = false
    private var current: Cancelable?
    
    public var isCancelled: Bool {
        return cancelled
    }
    
    public var cancelable: Cancelable {
        
        get {
            return current ?? AnyCancelable { }
        }
        
        set (newCancelable) {
            
            lock.lock(); defer { lock.unlock() }
            
            let cancelable: Cancelable? = {
                
                if cancelled {
                    
                    return newCancelable
                    
                } else {
                    
                    let toCancel = current
                    current = newCancelable
                    return toCancel
                    
                }
                
            }()
            
            cancelable?.cancel()
        }
    }
    
    public init() { }
    
    public func cancel() {
        
        lock.lock(); defer { lock.unlock() }
        
        if !cancelled {
            cancelled = true
            current?.cancel()
            current = nil
        }
    }
}
