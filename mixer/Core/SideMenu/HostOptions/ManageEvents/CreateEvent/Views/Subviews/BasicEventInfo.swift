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
                        
                        NotesSection(title: "Note for guests",
                                     note: $viewModel.note)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            // Co-planners shown here
                            ForEach(Array(viewModel.plannerNameMap.keys), id: \.self) { plannerId in
                                let name = viewModel.plannerNameMap[plannerId] ?? ""
                                ZStack(alignment: .topTrailing) {
                                    Text(name)
                                        .font(.body)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color.theme.backgroundColor)
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(8)
                                    
                                    Button {
                                        viewModel.removePlanner(withId: plannerId)
                                    } label: {
                                        Image(systemName: "xmark")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color.theme.backgroundColor)
                                            .padding([.top, .trailing], 5)
                                            .contentShape(Rectangle())
                                    }
                                }
                            }
                            
                            Button {
                                // Trigger the alert to add a user
                                viewModel.isShowingAddPlannerAlert.toggle()
                            } label: {
                                Image(systemName: "plus")
                                    .foregroundStyle(.white)
                                    .padding()
                                    .background {
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.white, lineWidth: 2)
                                    }
                            }
                        }
                        .padding()
                    }
                }
                .padding()
                .padding(.bottom, 80)
            }
        }
        .actionSheet(isPresented: $viewModel.isShowingHostSelectionAlert) {
            ActionSheet(title: Text("Select a Host"),
                        message: Text("Please select one of your associated hosts."),
                        buttons: viewModel.hostSelectionButtons())
        }
        .alert("Add Co-Planner(s)", isPresented: $viewModel.isShowingAddPlannerAlert) {
            VStack {
                TextField("Type a username here...", text: $viewModel.plannerUsername)
                    .foregroundColor(.primary)
                
                if #available(iOS 16.0, *) {
                    Button("Add") { viewModel.addPlanner() }
                        .tint(.secondary)
                    Button("Cancel", role: .cancel) {
                        viewModel.isShowingAddPlannerAlert = false
                    }
                    .tint(.white)
                }
            }
        } message: {
            Text("")
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
