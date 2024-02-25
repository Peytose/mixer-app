import SwiftUI

extension Text {
    // Base styling functions
    private func customFont(_ font: Font, weight: Font.Weight = .medium, color: Color = .white) -> some View {
        self
            .font(font)
            .fontWeight(weight)
            .foregroundColor(color)
    }

    //Titles
    func largeTitle(weight: Font.Weight = .bold) -> some View {
        customFont(.largeTitle, weight: weight)
    }
    
    // Headings
    func primaryHeading(weight: Font.Weight = .bold, color: Color = .white) -> some View {
        customFont(.title, weight: weight, color: color)
    }
    
    func secondaryHeading(color: Color = .white) -> some View {
        customFont(.title2, weight: .bold, color: color)
    }
    
    // Subheadings
    func primarySubheading() -> some View {
        customFont(.title2, weight: .semibold)
    }
    
    func secondarySubheading() -> some View {
        customFont(.title3, weight: .semibold)
    }
    
    //Body
    func subheadline(color: Color = .secondary) -> some View {
        customFont(.subheadline, color: color)
    }
    
    //Small Text
    func footnote(color: Color = .secondary) -> some View {
        customFont(.footnote, color: color)
    }
    
    func caption(color: Color = .secondary) -> some View {
        customFont(.caption, color: color)
    }
    
    func body(weight: Font.Weight = .medium, color: Color = .secondary) -> some View {
        customFont(.body, weight: weight, color: color)
    }
    
    // Button Fonts
    func primaryActionButtonFont(color: Color = .white) -> some View {
        customFont(.body, color: color)
    }
}

extension Menu {
    func menuTextStyle() -> some View {
        self
            .accentColor(Color.theme.mixerIndigo)
            .fontWeight(.medium)
    }
}
