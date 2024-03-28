//
//  MixerTabView.swift
//  mixer
//
//  Created by Jose Martinez on 3/21/24.
//

import SwiftUI

struct MixerTabView<Item: CustomStringConvertible>: View {
    let items: [Item]
    @Binding var selectedItem: Item

    var uniqueItems: [Item] {
        var seenDescriptions: Set<String> = []
        return items.filter { seenDescriptions.insert($0.description).inserted }
    }

    var body: some View {
        let width = UIScreen.main.bounds.width
        let totalTabs = CGFloat(uniqueItems.count)
        let tabWidth = width / totalTabs
        let selectedIndex = uniqueItems.firstIndex { $0.description == selectedItem.description } ?? 0
        let selectedIdx = CGFloat(selectedIndex)

        var offset: CGFloat {
            return (tabWidth * (selectedIdx + 0.5)) - (width / 2)
        }

        return VStack {
            ZStack(alignment: .center) {
                HStack(alignment: .center, spacing: 0) { // set spacing to 0
                    ForEach(0..<uniqueItems.count, id: \.self) { index in
                        Text(uniqueItems[index].description.capitalized)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(selectedIdx == CGFloat(index) ? .white : .gray)
                            .contentShape(Rectangle())
                            .frame(width: tabWidth, height: 70)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0)) {
                                    selectedItem = uniqueItems[index]
                                }
                            }
                        
                    }
                }

                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(Color.theme.mixerIndigo) // Adjust the color as needed
                    .frame(width: tabWidth * 0.8, height: 4)
                    .offset(x: offset, y: 20)
            }
            .padding(.top, 30)
            .background(Color.theme.backgroundColor)
            .frame(width: DeviceTypes.ScreenSize.width)
        }
    }
}
