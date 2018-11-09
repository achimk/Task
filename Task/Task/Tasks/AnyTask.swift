//
//  Created by Joachim Kret on 17.07.2018.
//  Copyright © 2018 JK. All rights reserved.
//

import Foundation

public final class AnyTask<Input, Output>: Task<Input, Output> {
    
    let transform: (Input, @escaping (Output) -> ()) -> Cancelable
    let dispose: () -> ()
    
    public static func onDispose<T>(_ dispose: @escaping () -> ()) -> Task<T, T> {

        return AnyTask<T, T>(transform: { (input, completion) in
            completion(input)
            return Cancelables.noop()
        }, dispose: dispose)
    }
    
    public convenience init(_ transform: @escaping (Input, @escaping (Output) -> ()) -> Cancelable) {
        self.init(transform: transform, dispose: { })
    }
    
    public init(transform: @escaping (Input, @escaping (Output) -> ()) -> Cancelable, dispose: @escaping () -> ()) {
        self.transform = transform
        self.dispose = dispose
    }

    deinit {
        dispose()
    }
    
    @discardableResult
    public override func run(_ input: Input, _ completion: @escaping (Output) -> ()) -> Cancelable {
        return transform(input, completion)
    }
    
}
