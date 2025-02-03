//
//  Card.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2025-01-09.
//

import SwiftUI

struct Card: View {
    
    var name: String
    var isStitched: Bool?
    var scanNumber: Int?
    
    var colors = cardColors()
    var spacing = cardSpacing()
    
//    private var formattedDate: String {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .medium
//        return formatter.string(from: date)
//    }
    
    var body: some View {
            VStack(alignment: .leading, spacing: 8){
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
                    if let scanNumber = scanNumber {
                        Text("\(scanNumber) scans")
                            .padding(.vertical, 4)
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .background(colors.white)
                            .cornerRadius(spacing.cardInnerCornerRadius)
                            .font(.system(size:14))
                    }
                    
                    if isStitched == true {
                        Text("Image Stitched")
                            .padding(.vertical, 4)
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .background(colors.white)
                            .cornerRadius(spacing.cardInnerCornerRadius)
                            .font(.system(size: 14))
                    }
                    
//                 
//                    Text(formattedDate)
//                        .padding(.vertical, 4)
//                        .padding(.horizontal)
//                        .frame(maxWidth: .infinity, alignment: .center)
//                        .background(colors.white)
//                        .cornerRadius(spacing.cardInnerCornerRadius)
//                        .font(.system(size:14))
//                    
                   
                }
            }
            .padding()
            .background(colors.cardBackground)
            .cornerRadius(spacing.cardOuterCornerRadius)
            .frame(maxWidth: .infinity, minHeight: 120) 
        }
}

#Preview {
    Card(name: "Chelsea Grace", scanNumber: 1)
}
