//
//  CreateEventView.swift
//  mixer
//
//  Created by Jose Martinez on 12/18/22.
//

import SwiftUI
import MapItemPicker

struct CreateEventView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = CreateEventViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.mixerBackground
                    .ignoresSafeArea()
                
                List {
                    flyerSection
                    
                    mainDetailsSection
                    
                    dateSection
                    
                    attireDescriptionSection
                    
                    noteSection
                    
                    eventAttendanceSection
                    
                    Rectangle()
                        .fill(Color.clear)
                        .listRowBackground(Color.clear)
                }
                .tint(.mixerIndigo)
                .preferredColorScheme(.dark)
                .scrollContentBackground(.hidden)
                .scrollIndicators(.hidden)
            }
            .overlay(alignment: .bottom, content: {
                NavigationLink(destination: EventLocationView()) {
                    NextButton()
                }
            })
            .navigationBarTitle(Text("Create an Event"), displayMode: .large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading, content: {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                })
            }
            .sheet(isPresented: $viewModel.isShowingPhotoPicker) { PhotoPicker(image: $viewModel.flyer) }
        }
    }
    
    var flyerSection: some View {
        VStack {
            Image(uiImage: viewModel.flyer)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .cornerRadius(12)
                .frame(width: 140, height: 140)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding()
        .onTapGesture {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            
            viewModel.isShowingPhotoPicker = true
        }
        .listRowBackground(Color.clear)
    }
    
    var mainDetailsSection: some View {
        Section(header: Text("Main Details")) {
            TextField("Event Title*", text: $viewModel.title)
                .foregroundColor(Color.mainFont)
                .font(.body.weight(.semibold))
            
            TextField("Event Theme*", text: $viewModel.theme, axis: .vertical)
                .foregroundColor(Color.mainFont)
                .font(.body.weight(.semibold))
                .lineLimit(4)
            
            TextField("Event/Theme Description*", text: $viewModel.description, axis: .vertical)
                .foregroundColor(Color.mainFont)
                .font(.body.weight(.semibold))
                .lineLimit(4)
        }
        .listRowBackground(Color.mixerSecondaryBackground)
    }
    
    var dateSection: some View {
        Section(header: Text("Date Details")) {
            EventDatePicker(text: "Start date*", selection: $viewModel.startDate)
                .padding(.vertical, -4)

            EventDatePicker(text: "End date*", selection: $viewModel.endDate)
                .padding(.vertical, -4)

            Picker("Wet or Dry", selection: $viewModel.selectedWetDry) {
                Text("Dry").tag(WetOrDry.dry)
                Text("Wet").tag(WetOrDry.wet)
            }
            .pickerStyle(.segmented)
            .padding(.vertical, 4)
        }
        .listRowBackground(Color.mixerSecondaryBackground)
    }
    
    var attireDescriptionSection: some View {
        Section {
            TextField("e.g. Halloween costume required", text: $viewModel.attireDescription)
                .foregroundColor(Color.mainFont)
        } header: {
            Text("Attire Description")
        }
        .listRowBackground(Color.mixerSecondaryBackground)
    }
    
    var noteSection: some View {
        Section {
            TextField("Bring your own beer 🍺 or no entry", text: $viewModel.note)
                .foregroundColor(Color.mainFont)
        } header: {
            Text("Note for guest")
        }
        .listRowBackground(Color.mixerSecondaryBackground)
    }
    
    var eventAttendanceSection: some View {
        Section {
            Toggle("Event Attendance Public?", isOn: $viewModel.showAttendanceCount.animation())
                .font(.body)
                .listRowBackground(Color.mixerSecondaryBackground)

        } header: {
            Text("Event Attendance")
        } footer: {
            Text("This allows mixer to make your event's attendance count public information")

        }
    }
}


struct AddEventView_Previews: PreviewProvider {
    static var previews: some View {
        CreateEventView()
    }
}


fileprivate struct EventDatePicker: View {
    var text: String
    var selection: Binding<Date>
    
    var body: some View {
        DatePicker(text,
                   selection: selection,
                   displayedComponents: [.date, .hourAndMinute])
        .datePickerStyle(.automatic)
        .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: -5))
    }
}
