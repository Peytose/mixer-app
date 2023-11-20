//
//  EditTextView.swift
//  mixer
//
//  Created by Jose Martinez on 11/16/23.
//

import SwiftUI

struct EditTextView: View {
    @Environment (\.dismiss) private var dismiss
    @State var text: String
    
    let navigationTitle: String
    let title: String
    let initialText: String
    let saveFunc: (String) -> Void
    var limit: Int = 200

    init(navigationTitle: String,
         title: String,
         text: String,
         limit: Int = 200,
         saveFunc: @escaping (String) -> Void) {
        self.navigationTitle = navigationTitle
        self.title           = title
        self._text           = State(initialValue: text)
        self.initialText     = text
        self.limit           = limit
        self.saveFunc        = saveFunc
    }
    
    var body: some View {
        ZStack {
            Color.theme.backgroundColor
                .ignoresSafeArea()
            
            List {
                SettingsSectionContainer(header: title) {
                    TextField("Start typing here...", text: $text, axis: .vertical)
                        .lineLimit(8, reservesSpace: true)
                    
                    HStack {
                        CharactersRemainView(currentCount: text.count,
                                             limit: limit)
                        
                        Spacer()
                        
                        ListCellActionButton(text: "Save",
                                             isSecondaryLabel: text.count > limit || text == initialText) {
                            if text.count <= limit || text != initialText {
                                saveFunc(text)
                                dismiss()
                            }
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
            .scrollContentBackground(.hidden)
            .navigationBar(title: navigationTitle, displayMode: .inline)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                PresentationBackArrowButton()
            }
        }
    }
}
