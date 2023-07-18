//
//  BasicEventInfo.swift
//  mixer
//
//  Created by Peyton Lyons on 3/15/23.
//

import SwiftUI

struct BasicEventInfo: View {
    @Binding var selectedImage: UIImage?
    @State private var image: Image?
    @State var imagePickerPresented = false
    @Binding var title: String
    @Binding var description: String
    @Binding var notes: String
    @Binding var hasNote: Bool
    @Binding var selectedType: EventType
    
    let action: () -> Void
    
    enum FocusedField {
        case title, description, notes
    }
    
    @FocusState private var focusedField: FocusedField?
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                //Event type menu
                eventTypeRow
                
                //Textfields section
                textFields
                
                //Flyer section
                flyerSection
                    .padding(.top, 16)
            }
            .padding()
            .padding(.bottom, 80)
            .onSubmit {
                if focusedField == .title {
                    focusedField = .description
                } else if focusedField == .description {
                    focusedField = .notes
                } else {
                    focusedField = nil
                }
            }
        }
        .background(Color.mixerBackground)
        .overlay(alignment: .bottom) {
            if selectedImage == nil ||
                title.isEmpty ||
                description.isEmpty ||
                title.count > 50 ||
                description.count > 150 ||
                notes.count > 250 {
                CreateEventNextButton(text: "Continue", action: action, isActive: false)
                    .disabled(true)
            } else {
                CreateEventNextButton(text: "Continue", action: action, isActive: true)
            }
        }
        .sheet(isPresented: $imagePickerPresented) {
            ImagePicker(image: $selectedImage)
        }
    }
}

extension BasicEventInfo {
    var eventTypeRow: some View {
        HStack(spacing: 10) {
            Text(selectedType.rawValue)
                .primaryHeading()
            
            Spacer()
            
            Menu("Change") {
                Button("Party") { setType(type: .party) }
                
                Button("Kickback") { setType(type: .kickback) }
                
                Button("Club Event") { setType(type: .club) }
                
                Button("School Event") { setType(type: .school) }
                
                Button("Mixer") { setType(type: .mixer) }
                
                Button("Rager") { setType(type: .rager) }
                
                Button("Darty") { setType(type: .darty) }
            }
            .menuTextStyle()
        }
    }
    
    @ViewBuilder
    var textFields: some View {
        // MARK: Title
        VStack(alignment: .leading, spacing: 4) {
            CreateEventTextField(input: $title,
                                 title: "Title",
                                 placeholder: "Choose something catchy!",
                                 keyboard: .default,
                                 toggleBool: .constant(false))
            .disableAutocorrection(true)
            .focused($focusedField, equals: .title)
            .autocorrectionDisabled()
            
            CharactersRemainView(currentCount: title.count,
                                 limit: 50)
        }
        
        // MARK: Description
        VStack(alignment: .leading, spacing: 4) {
            CreateEventTextField(input: $description,
                                 title: "Description",
                                 placeholder: "Briefly describe your event",
                                 keyboard: .default,
                                 hasToggle: true,
                                 toggleBool: $hasNote)
            .focused($focusedField, equals: .description)
            
            CharactersRemainView(currentCount: description.count,
                                 limit: 150)
        }
        
        // MARK: Notes
        if hasNote {
            VStack(alignment: .leading, spacing: 4) {
                CreateEventTextField(input: $notes,
                                     title: "Note for guests",
                                     placeholder: "Add any additional notes/info",
                                     keyboard: .default,
                                     toggleBool: .constant(false))
                .focused($focusedField, equals: .notes)
                
                CharactersRemainView(currentCount: notes.count,
                                     limit: 250)
            }
        }
    }
    
    var flyerSection: some View {
        // MARK: Flyer
        VStack(alignment: .center) {
            Button { self.imagePickerPresented.toggle() } label: {
                if let image = image {
                    // Selected image
                    image
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                        .frame(width: 250, height: 250)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    // Placeholder view
                    VStack {
                        Text("Event Flyer")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        HStack {
                            Text("Select image")
                                .font(.body)
                                .foregroundColor(.secondary)
                            
                            Image(systemName: "hand.point.up")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.secondary)
                                .frame(width: 22, height: 22, alignment: .center)
                        }
                    }
                    .frame(maxWidth: DeviceTypes.ScreenSize.width,
                           minHeight: DeviceTypes.ScreenSize.height / 5)
                    .background(alignment: .center) {
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [10]))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .onChange(of: selectedImage) { _ in loadImage() }
        }
    }
    
    func loadImage() {
        guard let selectedImage = selectedImage else { return }
        image = Image(uiImage: selectedImage)
    }
    
    func setType(type: EventType) {
        selectedType = type
    }
}

struct BasicEventInfo_Previews: PreviewProvider {
    @State static var selectedImage: UIImage?
    
    static var previews: some View {
        BasicEventInfo(selectedImage: $selectedImage,
                       title: .constant(""),
                       description: .constant(""),
                       notes: .constant(""),
                       hasNote: .constant(false),
                       selectedType: .constant(.party)) {  }
        .preferredColorScheme(.dark)
    }
}
