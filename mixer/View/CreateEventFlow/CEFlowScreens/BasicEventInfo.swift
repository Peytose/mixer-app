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
                VStack(alignment: .leading, spacing: 10) {
                    Text("Title")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    TextField("Choose something catchy!", text: $title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding()
                        .background(alignment: .center) {
                            RoundedRectangle(cornerRadius: 9)
                                .stroke(lineWidth: 2)
                                .foregroundColor(.mixerPurple)
                        }
                }
                
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
                                    .stroke(lineWidth: 2)
                                    .foregroundColor(.mixerPurple)
                            }
                        
                        CharactersRemainView(valueName: "",
                                             currentCount: description.count,
                                             limit: 250)
                    }
                }
                
                // Visibility
                VStack(alignment: .leading, spacing: 10) {
                    Text("Privacy")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    PrivacyPicker()
                }
                
                VStack(alignment: .leading) {
                    NextButton(action: action)
                        .disabled(selectedImage == nil ||
                                  title.isEmpty ||
                                  description.isEmpty)
                        .opacity(selectedImage == nil ||
                                 title.isEmpty ||
                                 description.isEmpty ? 0.3 : 1)
                }
            }
            .padding()
        }
        .background(Color.mixerBackground)
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
    @State static var privacy: CreateEventViewModel.PrivacyType = .open
    @State static var selectedImage: UIImage?
    
    static var previews: some View {
        BasicEventInfo(selectedImage: $selectedImage,
                       title: .constant(""),
                       description: .constant(""),
                       privacy: $privacy) {  }
        .preferredColorScheme(.dark)
    }
}

extension BasicEventInfo {
    @ViewBuilder func PrivacyPicker() -> some View {
        HStack(alignment: .center) {
            ForEach(CreateEventViewModel.PrivacyType.allCases, id: \.self) { selection in
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: selection.privacyIcon)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(privacy == selection ? .white : .gray)
                            .frame(width: 22, height: 22, alignment: .center)
                        
                        Text(selection.rawValue)
                            .font(.title3)
                            .fontWeight(privacy == selection ? .semibold : .medium)
                            .foregroundColor(privacy == selection ? .white : .secondary)
                        
                    }
                    
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(privacy == selection ? Color.mixerPurple : Color.clear)
                        .padding(.horizontal, 8)
                        .frame(height: 2)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        self.privacy = selection
                    }
                }
            }
        }
    }
}
