//
//  NotesSection.swift
//  mixer
//
//  Created by Peyton Lyons on 10/28/23.
//

import SwiftUI

struct NotesSection: View {
    var title: String?
    @State private var showNoteToggle = false
    @Binding var note: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Toggle("Add Notes", isOn: $showNoteToggle)
                    .toggleStyle(iOSCheckboxToggleStyle())
                    .buttonStyle(.plain)
                Spacer()
            }
            
            if showNoteToggle {
                TextFieldItem(title: title,
                              placeholder: "Add any additional notes/info",
                              input: $note,
                              limit: 250)
            }
        }
    }
}

#Preview {
    NotesSection(note: .constant(""))
}
