////
////  BasicEventInfo.swift
////  mixer
////
////  Created by Peyton Lyons on 3/15/23.
////
//
//import SwiftUI
//
//struct BasicEventInfo: View {
//    @EnvironmentObject var viewModel: EventFlowViewModel
//    @State private var isNoteAdded          = false
//    @State private var imagePickerPresented = false
//    @State private var image: Image?
//    
//    enum FocusedField {
//        case title
//        case description
//        case notes
//    }
//    
//    @FocusState private var focusedField: FocusedField?
//    
//    var body: some View {
//        ScrollView(showsIndicators: false) {
//            VStack(alignment: .leading, spacing: 16) {
//                // MARK: - Event type menu
//                HStack(spacing: 10) {
//                    Text(viewModel.type.rawValue)
//                        .primaryHeading()
//                    
//                    Spacer()
//                    
//                    Menu("Change") {
//                        ForEach(EventType.allCases, id: \.self) { type in
//                            Button(type.rawValue) {
//                                self.type = type
//                            }
//                        }
//                    }
//                    .menuTextStyle()
//                }
//                
//                // MARK: - Textfields section
//                VStack(spacing: 16) {
//                    VStack(alignment: .leading, spacing: 4) {
//                        EventFlowTextField(title: "Title",
//                                           placeholder: "Choose something catchy!",
//                                           input: $viewModel.title,
//                                           isNoteAdded: .constant(false),
//                                           keyboardType: .default)
//                        .focused($focusedField, equals: .title)
//                        .autocorrectionDisabled()
//                        
//                        CharactersRemainView(currentCount: viewModel.title.count,
//                                             limit: 50)
//                    }
//                    
//                    VStack(alignment: .leading, spacing: 4) {
//                        EventFlowTextField(title: "Description",
//                                           placeholder: "Briefly describe your event",
//                                           input: $viewModel.description,
//                                           isNoteAdded: .constant(false),
//                                           keyboardType: .default)
//                        .focused($focusedField, equals: .description)
//                        
//                        CharactersRemainView(currentCount: viewModel.description.count,
//                                             limit: 150)
//                    }
//                    
//                    if isNoteAdded {
//                        VStack(alignment: .leading, spacing: 4) {
//                            EventFlowTextField(title: "Note for guests",
//                                               placeholder: "Add any additional notes/info",
//                                               input: $viewModel.note,
//                                               isNoteAdded: $isNoteAdded,
//                                               keyboardType: .default,
//                                               showNoteToggle: true)
//                            .focused($focusedField, equals: .notes)
//                            
//                            CharactersRemainView(currentCount: viewModel.note.count,
//                                                 limit: 250)
//                        }
//                    }
//                }
//                
//                // MARK: Flyer
//                VStack(alignment: .center) {
//                    Button { self.imagePickerPresented.toggle() } label: {
//                        if let image = image {
//                            // Selected image
//                            image
//                                .resizable()
//                                .scaledToFit()
//                                .cornerRadius(12)
//                                .frame(width: 250, height: 250)
//                                .frame(maxWidth: .infinity, alignment: .center)
//                        } else {
//                            // Placeholder view
//                            VStack {
//                                Text("Event Flyer")
//                                    .font(.title2)
//                                    .fontWeight(.semibold)
//                                    .foregroundColor(.white)
//                                
//                                HStack {
//                                    Text("Select image")
//                                        .font(.body)
//                                        .foregroundColor(.secondary)
//                                    
//                                    Image(systemName: "hand.point.up")
//                                        .resizable()
//                                        .scaledToFit()
//                                        .foregroundColor(.secondary)
//                                        .frame(width: 22, height: 22, alignment: .center)
//                                }
//                            }
//                            .frame(maxWidth: DeviceTypes.ScreenSize.width,
//                                   minHeight: DeviceTypes.ScreenSize.height / 5)
//                            .background(alignment: .center) {
//                                RoundedRectangle(cornerRadius: 8)
//                                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [10]))
//                                    .foregroundColor(.secondary)
//                            }
//                        }
//                    }
//                }
//                .padding(.top, 16)
//            }
//            .padding()
//            .padding(.bottom, 80)
//            .onSubmit {
//                if focusedField == .title {
//                    focusedField = .description
//                } else if focusedField == .description {
//                    focusedField = .notes
//                } else {
//                    focusedField = nil
//                }
//            }
//        }
//        .background(Color.theme.backgroundColor)
//        .sheet(isPresented: $imagePickerPresented, onDismiss: loadImage, content: {
//            ImagePicker(image: $viewModel.selectedImage)
//        })
//    }
//}
//
//extension BasicEventInfo {
//    func loadImage() {
//        guard let selectedImage = viewModel.selectedImage else { return }
//        self.image = Image(uiImage: selectedImage)
//    }
//}
//
//struct BasicEventInfo_Previews: PreviewProvider {
//    static var previews: some View {
//        BasicEventInfo()
//    }
//}
