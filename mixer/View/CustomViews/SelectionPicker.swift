//
//  SelectionPicker.swift
//  mixer
//
//  Created by Peyton Lyons on 4/5/23.
//

import SwiftUI

protocol IconRepresentable {
    var icon: String { get }
}

struct Selection<Type: RawRepresentable & IconRepresentable>: Identifiable, Equatable where Type.RawValue == String {
    static func == (lhs: Selection<Type>, rhs: Selection<Type>) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    
    let id = UUID()
    let rawValue: String
    let icon: String
    let value: Type
    
    init(_ value: Type) {
        self.rawValue = value.rawValue
        self.icon = value.icon
        self.value = value
    }
}


@ViewBuilder func SelectionPicker<Type: Equatable>(selections: [Selection<Type>], selectedSelection: Binding<Selection<Type>?>) -> some View {
    HStack(alignment: .center) {
        ForEach(selections) { selection in
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: selection.icon)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(selectedSelection.wrappedValue?.value == selection.value ? .white : .gray)
                        .frame(width: 22, height: 22, alignment: .center)
                    
                    Text(selection.rawValue)
                        .font(.title3)
                        .fontWeight(selectedSelection.wrappedValue?.value == selection.value ? .semibold : .medium)
                        .foregroundColor(selectedSelection.wrappedValue?.value == selection.value ? .white : .secondary)
                }
                
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(selectedSelection.wrappedValue?.value == selection.value ? Color.mixerPurple : Color.clear)
                    .padding(.horizontal, 8)
                    .frame(height: 2)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.easeInOut) {
                    if selectedSelection.wrappedValue?.value != selection.value {
                        selectedSelection.wrappedValue = selection
                    } else {
                        selectedSelection.wrappedValue = nil
                    }
                }
            }
        }
    }
}
