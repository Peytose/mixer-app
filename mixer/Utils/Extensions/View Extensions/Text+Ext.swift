//
//  Text+Ext.swift
//  mixer
//
//  Created by Jose Martinez on 5/15/23.
//

import SwiftUI

extension Text {
    // MARK: General Text
    //Titles
    func title() -> some View {
        self
            .font(.largeTitle)
            .bold()
    }
    
    // Headings
    func heading() -> some View {
        self
            .font(.title.weight(.bold))
            .foregroundColor(.white)

    }
    
    func heading2() -> some View  {
        self
            .font(.title2.weight(.bold))
            .foregroundColor(.white)
    }
    
    // Subheadings
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
    
    //Body
    func tagline() -> some View {
        self
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.white.opacity(0.8))
    }
    
    
    //MARK: Textfield Font Modifiers
    // Titles
    func textFieldTitle() -> some View {
        self
            .font(.largeTitle.weight(.semibold))
            .foregroundColor(.white)
    }
    
    func textFieldSmallTitle() -> some View {
        self
            .font(.title.weight(.bold))
            .foregroundColor(.white)
    }
    
    // Notes
    func textFieldNote() -> some View {
        self
            .font(.body)
            .foregroundColor(.secondary)
    }
    
    // Headers
    func textFieldHeader() -> some View {
        self
            .font(.subheadline)
            .foregroundColor(.secondary)
    }
    
    // Footnotes
    func textFieldFootnote() -> some View {
        self
            .font(.footnote)
            .foregroundColor(.secondary)
    }
}

extension Menu {
    func menuTextStyle() -> some View  {
        self
            .accentColor(.mixerIndigo)
            .fontWeight(.medium)
    }
}
