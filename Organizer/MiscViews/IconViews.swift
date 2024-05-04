//
//  IconViews.swift
//  Organizer
//
//  Created by Parthiv Naresh on 5/3/24.
//

import SwiftUI

struct CalendarIconView: View {
    var active: Bool
    var date: Date?
    
    init(active: Bool, date: Date? = Date()) {
        self.active = active
        self.date = date
    }
    
    var body: some View {
        Image(iconName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 30, height: 30)
            .padding()
            .background(Color.white)
    }

    private var iconName: String {
        let dayOfMonth = Calendar.current.component(.day, from: date ?? Date())
        let isActive = active ? "Active" : ""
        return "Calendar\(dayOfMonth)\(isActive)"
    }
}
