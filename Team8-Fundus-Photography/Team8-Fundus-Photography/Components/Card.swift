//
//  Card.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2025-01-09.
//

import SwiftUI

struct Card: View {
    
    var name: String
    var date: Date
    var isStitched: Bool
    var scanNumber: Int
    
    var colors = cardColors()
    var spacing = cardSpacing()
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    var body: some View {
        GeometryReader {geometry in
            VStack(alignment: .leading, spacing: 10){
                Text(name)
                    .padding(.vertical, 8)
                    .padding(.horizontal)
                    .foregroundColor(colors.cardMainText)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(colors.white)
                    .cornerRadius(spacing.cardInnerCornerRadius)
                    .font(.system(size:24))
                
                   
                HStack{
                    Text("\(scanNumber) scans")
                        .padding(.vertical, 4)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(colors.white)
                        .cornerRadius(spacing.cardInnerCornerRadius)
                        .font(.system(size:14))
                    
                    
                    Text(formattedDate)
                        .padding(.vertical, 4)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(colors.white)
                        .cornerRadius(spacing.cardInnerCornerRadius)
                        .font(.system(size:14))
                    
                   
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .background(colors.cardBackground)
            .frame(width: geometry.size.width * 0.88)
            .frame(height: geometry.size.height * 0.15)
            .cornerRadius(spacing.cardOuterCornerRadius)
        }
     
    }
}

#Preview {
    Card(name: "Chelsea Grace", date: Date(), isStitched: false, scanNumber: 1)
}
