//
//  CustomError.swift
//  mixer
//
//  Created by Peyton Lyons on 2/25/24.
//

import Foundation

protocol CustomError: Error {
    var alertItem: AlertItem { get }
}
