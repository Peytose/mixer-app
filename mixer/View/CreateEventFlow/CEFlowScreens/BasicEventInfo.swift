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
    @Binding var privacy: CreateEventViewModel.PrivacyType
    @Binding var visibility: CreateEventViewModel.VisibilityType
    @State private var selectedPrivacy: Selection<CreateEventViewModel.PrivacyType>?
    @State private var selectedVisibility: Selection<CreateEventViewModel.VisibilityType>?
    let action: () -> Void
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 35) {
                // Flyer
                VStack(alignment: .center) {
                    Button { self.imagePickerPresented.toggle() } label: {
                        if let image = image {
                            image
                                .resizable()
                                .scaledToFill()
                                .cornerRadius(9)
                        } else {
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
                        }
                    }
                    .frame(maxWidth: DeviceTypes.ScreenSize.width,
                           minHeight: DeviceTypes.ScreenSize.height / 5)
                    .background(alignment: .center) {
                        RoundedRectangle(cornerRadius: 9)
                            .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [10]))
                            .foregroundColor(.secondary)
                    }
                    .onChange(of: selectedImage) { _ in loadImage() }
                }
                
                // Name
                CreateEventTextField(input: $title, title: "Title", placeholder: "Choose something catchy!", keyboard: .default)
                
                // Description
                VStack(alignment: .leading, spacing: 10) {
                    Text("Description")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        TextField("Include important details, such attire or theme!",
                                  text: $description,
                                  axis: .vertical)
                            .lineLimit(7, reservesSpace: true)
                            .keyboardType(.twitter)
                            .disableAutocorrection(true)
                            .foregroundColor(Color.mainFont)
                            .font(.body)
                            .fontWeight(.medium)
                            .padding()
                            .background(alignment: .center) {
                                RoundedRectangle(cornerRadius: 9)
                                    .stroke(lineWidth: 3)
                                    .foregroundColor(.mixerIndigo)
                            }
                        
                        CharactersRemainView(valueName: "",
                                             currentCount: description.count,
                                             limit: 250)
                    }
                }
                                
                // Privacy
//                VStack(alignment: .leading, spacing: 10) {
//                    Text("Privacy")
//                        .font(.title)
//                        .fontWeight(.semibold)
//                        .foregroundColor(.white)
//
//                    SelectionPicker(selections: CreateEventViewModel.PrivacyType.allCases.map { Selection($0) }, selectedSelection: $selectedPrivacy)
//                        .onChange(of: selectedPrivacy) { newValue in
//                            if let value = newValue?.value {
//                                self.privacy = value
//                            }
//                        }
//                }
                
                
                // Visibility
                
//                VStack(alignment: .leading, spacing: 10) {
//                    Text("Visibility")
//                        .font(.title)
//                        .fontWeight(.semibold)
//                        .foregroundColor(.white)
//
//                    SelectionPicker(selections: CreateEventViewModel.VisibilityType.allCases.map { Selection($0) }, selectedSelection: $selectedVisibility)
//                        .onChange(of: selectedVisibility) { newValue in
//                            if let value = newValue?.value {
//                                self.visibility = value
//                            }
//                        }
//                }
                
//                VStack(alignment: .leading) {
//                    NextButton(action: action)
//                        .disabled(selectedImage == nil ||
//                                  title.isEmpty ||
//                                  description.isEmpty)
//                        .opacity(selectedImage == nil ||
//                                 title.isEmpty ||
//                                 description.isEmpty ? 0.3 : 1)
//                }
            }
            .padding()
        }
        .background(Color.mixerBackground)
        .overlay(alignment: .bottom) {
            if selectedImage == nil ||
                title.isEmpty ||
                description.isEmpty {
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
    func loadImage() {
        guard let selectedImage = selectedImage else { return }
        image = Image(uiImage: selectedImage)
    }
}

struct BasicEventInfo_Previews: PreviewProvider {
    @State static var privacy: CreateEventViewModel.PrivacyType       = .open
    @State static var visibility: CreateEventViewModel.VisibilityType = ._public
    @State static var selectedImage: UIImage?
    
    static var previews: some View {
        BasicEventInfo(selectedImage: $selectedImage,
                       title: .constant(""),
                       description: .constant(""),
                       privacy: $privacy,
                       visibility: $visibility) {  }
        .preferredColorScheme(.dark)
    }
}
