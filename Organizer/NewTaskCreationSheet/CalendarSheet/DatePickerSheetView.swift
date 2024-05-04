//
//  DatePickerSheetView.swift
//  Organizer
//
//  Created by Parthiv Naresh on 4/28/24.
//

import SwiftUI
import MijickCalendarView


struct DatePickerSheetView: View {
    @Binding var dateDue: Date?
    @Binding var showingDatePicker: Bool
    @Binding var selectedRange: MDateRange?

    @State private var tempDate: Date? = Date()
    @State private var tempTime: Date = Date()
    
    init(dateDue: Binding<Date?>, showingDatePicker: Binding<Bool>, selectedRange: Binding<MDateRange?>) {
        self._dateDue = dateDue
        self._showingDatePicker = showingDatePicker
        self._selectedRange = selectedRange
        _tempDate = State(initialValue: dateDue.wrappedValue ?? Date())
        _tempTime = State(initialValue: dateDue.wrappedValue ?? Date())
    }

    var body: some View {
        NavigationView {
            VStack {
                Button(action: {
                    dateDue = Date()
                    showingDatePicker = false
                }) {
                    datePickerButtonView(title: "Today", date: Date())
                }
                .padding(.horizontal)
                
                Button(action: {
                    let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
                    dateDue = tomorrow
                    showingDatePicker = false
                }) {
                    datePickerButtonView(title: "Tomorrow", date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)
                }
                .padding(.horizontal)

                MCalendarView(selectedDate: $tempDate, selectedRange: $selectedRange) {
                    $0
                        .dayView { date, isCurrentMonth, selectedDate, selectedRange in
                            CustomDayView(date: date, isCurrentMonth: isCurrentMonth, selectedDate: selectedDate, selectedRange: selectedRange)
                        }
                        .monthLabelToDaysDistance(12)
                        .daysVerticalSpacing(-14)
                }

                DatePicker("Select Time", selection: $tempTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(CompactDatePickerStyle())
                    .padding()
            }
            .navigationTitle("Due Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingDatePicker = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        combineDateAndTime()
                        showingDatePicker = false
                    }
                }
            }
        }
    }
    
    private func combineDateAndTime() {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: tempDate ?? Date())
        let timeComponents = calendar.dateComponents([.hour, .minute], from: tempTime)
        dateDue = calendar.date(from: DateComponents(year: dateComponents.year,
                                                     month: dateComponents.month,
                                                     day: dateComponents.day,
                                                     hour: timeComponents.hour,
                                                     minute: timeComponents.minute))
    }
    
    private func datePickerButtonView(title: String, date: Date) -> some View {
        HStack {
            CalendarIconView(active: true, date: date)
            Text(title)
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .font(.system(size: 16))
            Spacer()
            Text(date, formatter: dayOfWeekFormatter)
                .foregroundColor(.gray)
                .font(.system(size: 16))
        }
        .background(Color.white)
        .padding(.leading, -10)
        .padding(.top, -10)
    }
    
    private let dayOfWeekFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }()
}
