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
                MultilineTextField(text: $note,
                                   title: title,
                                   placeholder: "Add any additional notes/info",
                                   limit: 250,
                                   lineLimit: 4)
            }
        }
    }
}

#Preview {
    NotesSection(note: .constant(""))
}
