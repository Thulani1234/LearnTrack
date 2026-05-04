import SwiftUI
import Combine

struct CalendarDate: Identifiable {
    let id = UUID()
    let date: Date?
}

class FullCalendarViewModel: ObservableObject {
    @Published var selectedMonth = Date()
    @Published var selectedDate = Date()
    @Published var plannerSessions: [StudySession] = []
    
    private let calendar = Calendar.current
    
    var monthTitle: String {
        selectedMonth.formatted(.dateTime.month(.wide).year())
    }
    
    var currentMonthDays: [CalendarDate] {
        let range = calendar.range(of: .day, in: .month, for: selectedMonth)!
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedMonth))!
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        
        var days: [CalendarDate] = Array(repeating: CalendarDate(date: nil), count: firstWeekday - 1)
        for day in 1...range.count {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(CalendarDate(date: date))
            }
        }
        
        while days.count % 7 != 0 {
            days.append(CalendarDate(date: nil))
        }
        return days
    }
    
    func changeMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: selectedMonth) {
            selectedMonth = newMonth
        }
    }
    
    func selectToday() {
        selectedMonth = Date()
        selectedDate = Date()
    }
    
    func isSelected(_ date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: selectedDate)
    }
    
    func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }
    
    func isSameMonth(_ date: Date) -> Bool {
        calendar.isDate(date, equalTo: selectedMonth, toGranularity: .month)
    }
    
    func hasSessions(for date: Date) -> Bool {
        plannerSessions.contains { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    func dayNumber(for date: Date) -> String {
        "\(calendar.component(.day, from: date))"
    }
}

struct FullCalendarView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var data: MockData
    @StateObject private var viewModel = FullCalendarViewModel()
    
    private let daysOfWeek = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { router.navigateBack() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                        .padding(12)
                        .background(AppColors.cardBackground)
                        .clipShape(Circle())
                }
                
                Button(action: { 
                    withAnimation { viewModel.selectToday() }
                }) {
                    Text("Today")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppColors.primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(AppColors.primary.opacity(0.1))
                        .clipShape(Capsule())
                }
                
                Spacer()
                
                Text(viewModel.monthTitle)
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button(action: { withAnimation { viewModel.changeMonth(by: -1) } }) {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.title3)
                            .foregroundColor(AppColors.primary)
                    }
                    Button(action: { withAnimation { viewModel.changeMonth(by: 1) } }) {
                        Image(systemName: "chevron.right.circle.fill")
                            .font(.title3)
                            .foregroundColor(AppColors.primary)
                    }
                }
            }
            .padding()
            .background(AppColors.background)
            
            // Calendar Grid
            VStack(spacing: 20) {
                // Days of Week
                HStack {
                    ForEach(daysOfWeek, id: \.self) { day in
                        Text(day)
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(AppColors.textSecondary.opacity(0.5))
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal)
                
                // Month Grid (Simplified call)
                CalendarGrid(viewModel: viewModel)
            }
            .padding(.vertical)
            .background(AppColors.cardBackground.cornerRadius(32, corners: [.bottomLeft, .bottomRight]))
            .shadow(color: Color.black.opacity(0.05), radius: 20, x: 0, y: 10)
            
            // Events List for Selected Day
            VStack(alignment: .leading, spacing: 20) {
                SectionHeader(title: "SCHEDULE FOR \(viewModel.selectedDate.formatted(.dateTime.day().month()))")
                
                ScrollView(showsIndicators: false) {
                    ScheduledSessionsView(date: viewModel.selectedDate)
                        .id(viewModel.selectedDate)
                }
            }
            .padding()
            .padding(.top, 10)
            
            Spacer()
        }
        .background(AppColors.background.ignoresSafeArea())
        .onAppear {
            viewModel.plannerSessions = data.scheduledSessions
        }
    }
}

struct CalendarGrid: View {
    @ObservedObject var viewModel: FullCalendarViewModel
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
            let days = viewModel.currentMonthDays
            ForEach(days) { calendarDate in
                if let date = calendarDate.date {
                    DayCell(
                        day: viewModel.dayNumber(for: date),
                        isSelected: viewModel.isSelected(date),
                        isToday: viewModel.isToday(date),
                        isSameMonth: viewModel.isSameMonth(date),
                        hasSessions: viewModel.hasSessions(for: date)
                    )
                    .onTapGesture {
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.selectedDate = date
                        }
                    }
                } else {
                    Color.clear.frame(height: 50)
                }
            }
        }
        .padding(.horizontal)
    }
}

struct DayCell: View {
    let day: String
    let isSelected: Bool
    let isToday: Bool
    let isSameMonth: Bool
    let hasSessions: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Text(day)
                .font(.system(size: 16, weight: isSelected || isToday ? .bold : .medium))
                .foregroundColor(isSelected ? .white : (isToday ? AppColors.primary : (isSameMonth ? AppColors.textPrimary : AppColors.textSecondary.opacity(0.3))))
            
            if isSameMonth && hasSessions {
                Circle()
                    .fill(isSelected ? .white : AppColors.primary)
                    .frame(width: 4, height: 4)
            } else {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 4, height: 4)
            }
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .background(isSelected ? AppColors.primary : Color.clear)
        .cornerRadius(12)
    }
}
