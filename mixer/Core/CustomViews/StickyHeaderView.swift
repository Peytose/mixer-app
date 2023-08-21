//
//  StickyHeaderView.swift
//  mixer
//
//  Created by Peyton Lyons on 8/21/23.
//

import SwiftUI

struct StickyHeaderView<Item: CustomStringConvertible>: View {
    let items: [Item]
    @Binding var selectedItem: Item

    var body: some View {
        let width = UIScreen.main.bounds.width
        let totalTabs = CGFloat(items.count)
        let tabWidth = width / totalTabs
        let selectedIndex = items.firstIndex { $0.description == selectedItem.description } ?? 0
        let selectedIdx = CGFloat(selectedIndex)

        var offset: CGFloat {
            return (tabWidth * selectedIdx) - (width / 2) + (tabWidth / 2)
        }

        return ZStack(alignment: .center) {
            HStack(alignment: .center) {
                Spacer()

                ForEach(0..<items.count, id: \.self) { index in
                    Text(items[index].description.capitalized)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(selectedIdx == CGFloat(index) ? .white : .gray)
                        .contentShape(Rectangle())
                        .frame(width: tabWidth)
                        .padding(.bottom, 10)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0)) {
                                selectedItem = items[index]
                            }
                        }

                    Spacer()
                }
            }

            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(Color.theme.mixerIndigo)
                .frame(width: tabWidth * 0.8, height: 4)
                .offset(x: offset, y: 20)
        }
        .background(Color.theme.backgroundColor)
    }
}
