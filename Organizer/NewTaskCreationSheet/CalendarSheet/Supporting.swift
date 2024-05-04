//
//  SupportingViews.swift
//  Organizer
//
//  Created by Parthiv Naresh on 4/28/24.
//

import SwiftUI
import MijickCalendarView
import UserNotifications
import CoreLocation


struct CustomDayView: DayView {
    var date: Date
    var isCurrentMonth: Bool
    var selectedDate: Binding<Date?>?
    var selectedRange: Binding<MDateRange?>?

    private var dayText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"  // Day of the month
        return formatter.string(from: date)
    }
    
    func createContent() -> AnyView {
        AnyView(
            Text(dayText)
                .padding(8)
                .background(isSelected ? Color.blue : Color.clear)
                .clipShape(Circle())
                .onTapGesture {
                    self.selectedDate?.wrappedValue = self.date
                }
        )
    }

    func createDayLabel() -> AnyView {
        AnyView(
            Text(dayText)
                .foregroundColor(isCurrentMonth ? .black : .gray)
        )
    }

    func createSelectionView() -> AnyView {
        AnyView(
            Circle()
                .fill(isSelected ? Color.blue : Color.clear)
                .frame(width: 30, height: 30)
        )
    }

    func createRangeSelectionView() -> AnyView {
        AnyView(Rectangle().fill(Color.blue.opacity(0.3)))
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }

    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }

    private var isSelected: Bool {
        guard let selected = selectedDate?.wrappedValue else { return false }
        return Calendar.current.isDate(selected, inSameDayAs: date)
    }
}
