//
//  Extension.swift
//  E-Movie
//
//  Created by Sourav Basu Roy on 09/09/22.
//

import Foundation

// Fail gracefully if index is out of bound
extension Collection where Indices.Iterator.Element == Index {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
