//
//  PreferenceKey.swift
//  mixer
//
//  Created by Jose Martinez on 12/18/22.
//

import SwiftUI

struct ScrollPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
    
}

struct CirclePreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
    
}

struct TabPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct CellYPreferenceKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue: Value = 0
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }
}

struct HeaderYPreferenceKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue: Value = 0
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }
}
