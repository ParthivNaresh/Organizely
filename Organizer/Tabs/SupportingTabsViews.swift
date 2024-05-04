//
//  SupportingTabsViews.swift
//  Organizer
//
//  Created by Parthiv Naresh on 5/4/24.
//

import SwiftUI


struct SortButton: View {
    var title: String
    @Binding var isAscending: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: isAscending ? "arrow.down.circle" : "arrow.up.circle")
                    .imageScale(.medium)
                    .foregroundColor(.blue)
                Text(title)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .padding(.top, 3)
                    .padding(.bottom, 5)
            }
            .padding(.horizontal, 15)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(8)
        }
    }
}

