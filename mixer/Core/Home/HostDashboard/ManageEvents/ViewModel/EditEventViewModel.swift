//
//  EditEventViewModel.swift
//  mixer
//
//  Created by Peyton Lyons on 12/8/23.
//

import SwiftUI
import Firebase

class EditEventViewModel: ObservableObject, SettingsConfigurable, AmenityHandling {
    
    private var event: Event
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
        self.event             = event
        self.eventImageUrl     = event.eventImageUrl
        self.title             = event.title
        self.description       = event.description
        self.note              = event.note ?? ""
        self.selectedAmenities = Set(event.amenities ?? [])
        self.bathroomCount     = event.bathroomCount ?? 0
        self.containsAlcohol   = event.containsAlcohol
        self.startDate         = event.startDate
        self.endDate           = event.endDate
        
        print("DEBUG: Initialized edit event vm!")
    }
    
    
    func save(for type: SettingSaveType) {
        self.save(for: type) {
            EventManager.shared.updateEvent(self.event)
            HapticManager.playSuccess()
        }
    }
    
    
    private func save(for type: SettingSaveType, completion: @escaping () -> Void) {
        guard let eventId = event.id else { return }
        
        switch type {
        case .image(let selectedImage):
            ImageUploader.uploadImage(image: selectedImage, type: .event) { imageUrl in
                COLLECTION_EVENTS
                    .document(eventId)
                    .updateData(["hostImageUrl": imageUrl]) { _ in
                        self.eventImageUrl = imageUrl
                        self.event.eventImageUrl = imageUrl
                        completion()
                    }
            }
            
        case .title:
            guard self.title != "" else { return }
            
            COLLECTION_EVENTS
                .document(eventId)
                .updateData(["title": self.title]) { _ in
                    self.event.title = self.title
                    completion()
                }
            
        case .description(let updatedDescription):
            guard updatedDescription != self.description, updatedDescription != "" else { return }
            
            COLLECTION_EVENTS
                .document(eventId)
                .updateData(["description": updatedDescription]) { _ in
                    self.event.description = self.description
                    completion()
                }
        
        case .amenities:
            let amenitiesStrings = selectedAmenities.map { $0.rawValue }
            
            var data: [String: Any] = [:]
            
            if Array(selectedAmenities) != event.amenities {
                data["amenities"] = amenitiesStrings
            }
            
            data["containsAlcohol"] = selectedAmenities.contains(where: { $0 == .alcohol || $0 == .beer })
            
            if bathroomCount != event.bathroomCount {
                data["bathroomCount"] = bathroomCount
            }

            COLLECTION_EVENTS
                .document(eventId)
                .updateData(data) { _ in
                    self.event.amenities = Array(self.selectedAmenities)
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
    
    
    func shouldShowRow(withTitle title: String) -> Bool {
        return true
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
                                        text: note,
                                        limit: 250) { updatedText in
                self.save(for: .note(updatedText))
            }
        case "Amenities":
            EditAmenitiesView(viewModel: self,
                              amenities: event.amenities,
                              bathroomCount: event.bathroomCount)
        case "Address":
            EditAddressView()
        default: ComingSoonView()
        }
    }
    
    
    func isSecondaryButton() -> Bool {
        let isAmenitiesChanged = Set(event.amenities ?? []) != selectedAmenities
        let isBathroomCountChanged = bathroomCount != event.bathroomCount
        return !isAmenitiesChanged && !isBathroomCountChanged
    }
}
