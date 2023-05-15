//
//  Text+Ext.swift
//  mixer
//
//  Created by Jose Martinez on 5/15/23.
//

import SwiftUI

extension Text {
    //MARK: Textfield Font Modifiers
    // Titles
    func textFieldTitle() -> some View {
        self
            .font(.largeTitle.weight(.semibold))
            .foregroundColor(.mainFont)
    }
    
    func textFieldSmallTitle() -> some View {
        self
            .font(.title.weight(.semibold))
            .foregroundColor(.mainFont)
    }
    
    func textFieldNote() -> some View {
        self
            .font(.body)
            .foregroundColor(.secondary)
    }
    
    func textFieldHeader() -> some View {
        self
            .font(.subheadline)
            .foregroundColor(.secondary)
    }
    
    func textFieldFootnote() -> some View {
        self
            .font(.footnote)
            .foregroundColor(.secondary)
    }
}
