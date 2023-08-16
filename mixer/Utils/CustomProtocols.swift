//
//  CustomProtocols.swift
//  mixer
//
//  Created by Peyton Lyons on 8/7/23.
//

import Foundation

protocol CustomStringConvertible {
    var stringVal: String { get }
}

protocol MenuOption {
    var title: String { get }
    var imageName: String { get }
}
