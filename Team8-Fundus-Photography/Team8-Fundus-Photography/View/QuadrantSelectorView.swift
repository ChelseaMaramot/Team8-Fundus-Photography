import SwiftUI

struct CircleButton: View {
    let quadrant: String
    let isSelected: Bool
    let size: CGFloat
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(isSelected ? Color.blue : Color.gray.opacity(1))
                .frame(width: size, height: size)
                .overlay(
                    
                    Group{
                        if size > 50 {
                            Text(quadrant)
                                .foregroundColor(isSelected ? Color.white : Color.black)
                                .font(.caption)
                            
                        }
                    }
                )
        }
    }
}

struct QuadrantSelectorView: View {
    @Binding var selectedQuadrant: String
    let isInteractive: Bool
    let size: CGFloat
    let quadrants = ["Superior", "Inferior", "Nasal", "Temporal", "Central"]
    
    
    private var offset: CGFloat {
           (size) + 10
       }
    private func offsetForQuadrant(_ quadrant: String) -> CGSize {
        switch quadrant {
        case "Superior":
            return CGSize(width: 0, height: -offset)
        case "Inferior":
            return CGSize(width: 0, height: offset)
        case "Nasal":
            return CGSize(width: -offset, height: 0)
        case "Temporal":
            return CGSize(width: offset, height: 0)
        default:
            return CGSize.zero
        }
    }
    
    var body: some View {
        ZStack {
            ForEach(quadrants, id: \.self) { quadrant in
                CircleButton(quadrant: quadrant, isSelected: selectedQuadrant == quadrant, size: size) {
                    if isInteractive {
                        selectedQuadrant = quadrant
                    }
                }
                .offset(offsetForQuadrant(quadrant))
            }
        }
    }
}

#Preview {
    QuadrantSelectorView(selectedQuadrant: .constant("Central"), isInteractive: false, size: 90)
}
