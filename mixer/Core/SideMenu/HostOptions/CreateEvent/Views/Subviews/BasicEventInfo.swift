//
//  BasicEventInfo.swift
//  mixer
//
//  Created by Peyton Lyons on 3/15/23.
//

import SwiftUI

struct BasicEventInfo: View {
    @EnvironmentObject var viewModel: EventCreationViewModel
    
    var body: some View {
        FlowContainerView {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    FlyerSection(viewModel: viewModel)
                    
                    if let _ = viewModel.selectedImage {
                        EventTypeMenu(type: $viewModel.type)
                        
                        TextFieldItem(title: "Title",
                                      placeholder: "Choose something catchy!",
                                      input: $viewModel.title,
                                      limit: 50)
                        
                        TextFieldItem(title: "Description",
                                      placeholder: "Briefly describe your event",
                                      input: $viewModel.eventDescription,
                                      limit: 150)
                        
                        NotesSection(note: $viewModel.note)
                    }
                }
                .padding()
                .padding(.bottom, 80)
            }
        }
    }
}

struct BasicEventInfo_Previews: PreviewProvider {
    static var previews: some View {
        BasicEventInfo()
    }
}

fileprivate struct EventTypeMenu: View {
    @Binding var type: EventType
    
    var body: some View {
        HStack(spacing: 10) {
            Text("Type: \(type.description)")
                .primaryHeading()
            
            Spacer()
            
            Menu("Change") {
                ForEach(EventType.allCases, id: \.self) { type in
                    Button(type.description) { self.type = type }
                }
            }
            .menuTextStyle()
        }
    }
}

fileprivate struct NotesSection: View {
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
                TextFieldItem(title: "Note for guests",
                              placeholder: "Add any additional notes/info",
                              input: $note,
                              limit: 250)
            }
        }
    }
}

fileprivate struct FlyerSection: View {
    @ObservedObject var viewModel: EventCreationViewModel
    @State private var image: Image?
    @State private var imagePickerPresented = false
    
    var body: some View {
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
                    VStack {
                        Text("First, upload a flyer for your event!")
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
        }
        .sheet(isPresented: $imagePickerPresented, onDismiss: loadImage) {
            ImagePicker(image: $viewModel.selectedImage)
        }
    }
}

extension FlyerSection {
    func loadImage() {
        guard let selectedImage = viewModel.selectedImage else { return }
        self.image = Image(uiImage: selectedImage)
    }
}

fileprivate struct TextFieldItem: View {
    let title: String
    let placeholder: String
    @Binding var input: String
    let limit: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            EventFlowTextField(title: title,
                               placeholder: placeholder,
                               input: $input,
                               keyboardType: .default)
            .autocorrectionDisabled()
            
            CharactersRemainView(currentCount: input.count,
                                 limit: limit)
        }
    }
}
