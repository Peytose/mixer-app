//
//  EditEventViewModel.swift
//  mixer
//
//  Created by Peyton Lyons on 12/8/23.
//

import SwiftUI
import Firebase

class EditEventViewModel: ObservableObject, SettingsConfigurable, AmenityHandling {
    
    private var eventId: String?
    @Published var eventImageUrl: String
    @Published var title: String
    @Published var description: String
    @Published var note: String
    @Published var selectedAmenities: Set<EventAmenity>
    @Published var bathroomCount: Int
    @Published var containsAlcohol: Bool
    @Published var startDate: Timestamp
    @Published var endDate: Timestamp
    
    init(event: Event) {
        eventId           = event.id
        eventImageUrl     = event.eventImageUrl
        title             = event.title
        description       = event.description
        note              = event.note ?? ""
        selectedAmenities = Set(event.amenities ?? [])
        bathroomCount     = event.bathroomCount ?? 0
        containsAlcohol   = event.containsAlcohol
        startDate         = event.startDate
        endDate           = event.endDate
        
        print("DEBUG: Initialized edit event vm!")
    }
    
    
    func save(for type: SettingSaveType) {
        self.save(for: type) {
            print("DEBUG: \(type.self) saved!")
            HapticManager.playSuccess()
        }
    }
    
    
    private func save(for type: SettingSaveType, completion: @escaping () -> Void) {
        guard let eventId = eventId else { return }
        
        switch type {
        case .image(let selectedImage):
            ImageUploader.uploadImage(image: selectedImage, type: .event) { imageUrl in
                COLLECTION_EVENTS
                    .document(eventId)
                    .updateData(["hostImageUrl": imageUrl]) { _ in
                        self.eventImageUrl = imageUrl
                        completion()
                    }
            }
            
        case .title:
            guard self.title != "" else { return }
            
            COLLECTION_EVENTS
                .document(eventId)
                .updateData(["title": self.title]) { _ in
                    completion()
                }
            
        case .description(let updatedDescription):
            guard updatedDescription != self.description, updatedDescription != "" else { return }
            
            COLLECTION_EVENTS
                .document(eventId)
                .updateData(["description": updatedDescription]) { _ in
                    completion()
                }
            
//        case .address:
//            guard self.address != "" else { return }
//            
//            print("DEBUG: Not implemented yet.")
//            break
            
        default:
            break
        }
    }
    
    
    func content(for title: String) -> Binding<String> {
        switch title {
        case "Title":
            return Binding<String>(get: { self.title }, set: { self.title = $0 })
        default:
            return .constant("")
        }
    }
    
    
    func saveType(for title: String) -> SettingSaveType {
        switch title {
            case "Title":
                return .title
            default:
                return .unknown
        }
    }
    
    
    func toggle(for title: String) -> Binding<Bool> {
        switch title {
            default:
                return .constant(false)
        }
    }
    
    
    func url(for title: String) -> String {
        switch title {
            default:
                return ""
        }
    }
    
    @ViewBuilder
    func destination(for title: String) -> some View {
        switch title {
        case "Description":
            EditTextView(navigationTitle: "Edit Description",
                                        title: "Description",
                                        text: description,
                                        limit: 150) { updatedText in
                self.save(for: .description(updatedText))
            }
        case "Note":
            EditTextView(navigationTitle: "Edit Note",
                                        title: "Note",
                                        text: description,
                                        limit: 250) { updatedText in
                self.save(for: .note(updatedText))
            }
        case "Amenities":
            List{ ToggleAmenityView(viewModel: self) }
        case "Address":
            EditAddressView()
        default: EmptyView()
        }
    }
}
