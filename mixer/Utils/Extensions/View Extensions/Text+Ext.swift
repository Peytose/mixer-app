//
//  Text+Ext.swift
//  mixer
//
//  Created by Jose Martinez on 5/15/23.
//

import SwiftUI

extension Text {
    //MARK: General Text
    
    //Headings
    func heading() -> some View {
        self
            .font(.title.weight(.bold))
    }
    
    //Subheadings
    func subheading() -> some View {
        self
            .font(.title2)
            .fontWeight(.semibold)
    }
    
    func subheading2() -> some View {
        self
            .font(.title3)
            .fontWeight(.semibold)
    }
    
    func subheading3(foregroundColor: Color = .white) -> some View {
        self
            .font(.body)
    }
    
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
    
    // Notes
    func textFieldNote() -> some View {
        self
            .font(.body)
            .foregroundColor(.secondary)
    }
    
    //Headers
    func textFieldHeader() -> some View {
        self
            .font(.subheadline)
            .foregroundColor(.secondary)
    }
    
    
    //Footnotes
    func textFieldFootnote() -> some View {
        self
            .font(.footnote)
            .foregroundColor(.secondary)
    }
}
