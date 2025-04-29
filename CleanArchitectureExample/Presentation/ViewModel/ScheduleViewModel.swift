//
//  Created by Edison on 2025/4/25.
//

import Foundation
import Combine

@MainActor
protocol ScheduleViewModelProtocol: AnyObject {
    var daySchedules: [DaySchedule] { get }
    var currentWeek: Date { get }
    var timezone: TimeZone { get }
    var isLoading: Bool { get }
    var error: Error? { get }
    var errorPublisher: Published<Error?>.Publisher { get }
    var objectWillChange: ObservableObjectPublisher { get }
    
    func fetchSchedules() async
    func canMoveToPreviousWeek() -> Bool
    func moveToNextWeek()
    func moveToPreviousWeek()
    func getWeekDates() -> [Date]
}

@MainActor
final class ScheduleViewModel: ObservableObject, ScheduleViewModelProtocol {
    
    @Published private(set) var daySchedules: [DaySchedule] = []
    @Published private(set) var currentWeek: Date
    @Published private(set) var timezone: TimeZone = TimeZone.current
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    var errorPublisher: Published<(any Error)?>.Publisher { $error }
    
    private let fetchUseCase: FetchScheduleUseCaseProtocol
    private let calendar: Calendar
    
    init(fetchUseCase: FetchScheduleUseCaseProtocol,
         calendar: Calendar = .current,
         currentWeek: Date = Date().startOfDayInLocalTime()) {
        self.fetchUseCase = fetchUseCase
        self.calendar = calendar
        self.currentWeek = currentWeek
        self.timezone = fetchUseCase.timezone
    }

    deinit { print("ScheduleViewModel deinit") }
    
    func fetchSchedules() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await fetchUseCase.execute()
            timezone = fetchUseCase.timezone
            updateDaySchedules(with: response)
        } catch {
            self.error = error
        }
    }
    
    func canMoveToPreviousWeek() -> Bool {
        return !currentWeek.isBeforeToday()
    }
    
    func moveToNextWeek() {
        currentWeek = currentWeek.movedBy(days: 7).startOfDayInLocalTime()
        Task {
            await fetchSchedules()
        }
    }
    
    func moveToPreviousWeek() {
        let previousStart = currentWeek.movedBy(days: -7).startOfDayInLocalTime()
        
        if !currentWeek.isBeforeToday() {
            currentWeek = previousStart
            Task {
                await fetchSchedules()
            }
        }
    }
    
    func getWeekDates() -> [Date] {
        return currentWeek.startOfDayInLocalTime().next7Days()
    }
    
    private func updateDaySchedules(with response: ScheduleResponse) {
        let weekDates = getWeekDates()
        
        daySchedules = weekDates.map { date in
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay   = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            
            // 只挑出屬於這天範圍內的 raw slot
            let rawAvail = response.available.filter { slot in
                (slot.start < endOfDay) && (slot.end > startOfDay)
            }
            let rawBooked = response.booked.filter { slot in
                (slot.start < endOfDay) && (slot.end > startOfDay)
            }
            
            // 將它們拆成每半小時一格，並且只保留真正落在當天的那一部分
            let availableSlots = rawAvail
                .flatMap { $0.splitByHalfHour() }
                .filter { calendar.isDate($0.start, inSameDayAs: date) }
            
            let bookedSlots = rawBooked
                .flatMap { $0.splitByHalfHour() }
                .filter { calendar.isDate($0.start, inSameDayAs: date) }
            
            return DaySchedule(
                date: date,
                availableSlots: availableSlots,
                bookedSlots: bookedSlots
            )
        }
    }
}
