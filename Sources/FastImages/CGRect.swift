//
//  File.swift
//  
//
//  Created by Scott Lydon on 7/19/22.
//

import UIKit

extension CGRect {
    var maxDimension: CGFloat {
        [height, width].compactMap {$0 }.max()!
    }
}
