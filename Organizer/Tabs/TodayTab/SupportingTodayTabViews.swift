//
//  SupportingTodayTabViews.swift
//  Organizer
//
//  Created by Parthiv Naresh on 5/4/24.
//

import SwiftUI


extension Date {
    var midnight: Date {
        Calendar.current.startOfDay(for: self)
    }

    var tomorrow: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: self.midnight)!
    }
}
