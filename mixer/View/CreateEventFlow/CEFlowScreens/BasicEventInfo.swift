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
    let action: () -> Void
    
    enum FocusedField {
        case title, description
    }
    @FocusState private var focusedField: FocusedField?
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 35) {
                // Title
                CreateEventTextField(input: $title, title: "Title", placeholder: "Choose something catchy!", keyboard: .default)
                    .focused($focusedField, equals: .title)
                
                // Description
                VStack(alignment: .leading, spacing: 10) {
                    Text("Description")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        TextField("Include important details, such as attire or theme!",
                                  text: $description,
                                  axis: .vertical)
                        .lineLimit(7, reservesSpace: true)
                        .keyboardType(.default)
                        .foregroundColor(Color.mainFont)
                        .font(.body)
                        .fontWeight(.medium)
                        .focused($focusedField, equals: .description)
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
                
                // Flyer
                VStack(alignment: .center) {
                    Button { self.imagePickerPresented.toggle() } label: {
                        if let image = image {
                            image
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(12)
                                .frame(width: 200, height: 200)
                                .frame(maxWidth: .infinity, alignment: .center)
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
                            .frame(maxWidth: DeviceTypes.ScreenSize.width,
                                   minHeight: DeviceTypes.ScreenSize.height / 5)
                            .background(alignment: .center) {
                                RoundedRectangle(cornerRadius: 9)
                                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [10]))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .onChange(of: selectedImage) { _ in loadImage() }
                }
            }
            .padding()
            .padding(.bottom, 80)
            .onSubmit {
                if focusedField == .title {
                    focusedField = .description
                } else {
                    focusedField = nil
                }
            }
        }
        .background(Color.mixerBackground)
        .onTapGesture {
            self.hideKeyboard()
        }
        .overlay(alignment: .bottom) {
            if selectedImage == nil ||
                title.isEmpty ||
                description.isEmpty {
                CreateEventNextButton(text: "Continue", action: action, isActive: false)
                    .disabled(true)
            } else {
                CreateEventNextButton(text: "Continue", action: action, isActive: true)
                    .onTapGesture {
                        self.hideKeyboard()
                    }
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
                       description: .constant("")) {  }
        .preferredColorScheme(.dark)
    }
}
