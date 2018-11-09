//
//  Created by Joachim Kret on 25.07.2018.
//  Copyright © 2018 JK. All rights reserved.
//

import Foundation

public struct Cancelables {
    
    // No Operation
    public static func noop() -> Cancelable {
        
        return AnyCancelable { }
    }
    
    public static func any(_ onCancel: @escaping () -> ()) -> Cancelable {
        
        return AnyCancelable(onCancel)
    }
    
    public static func single() -> SingleCancelable {
        
        return SingleCancelable()
    }
    
    public static func serial() -> SerialCancelable {
        
        return SerialCancelable()
    }
}
