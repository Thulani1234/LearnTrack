//
//  AppRouter.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//
import SwiftUI
import Combine

enum Route: Hashable {
    case dashboard
    case planner
    case planSession
    case subjects
    case addSubject
    case addResult
    case timer(MockData.SubjectMock)
    case quizList
    case quiz(MockData.QuizMock)
    case results
    case targetActual
    case voiceNotes
    case notes
    case addNote
    case report
    case profile
    case editProfile
    case settings
    case notifications
    case planSetup
    case planGenerated
    case privacy
    case help
    case contact
    case resultDetail(Result)
}

class AppRouter: ObservableObject {
    @Published var path = NavigationPath()
    
    func navigate(to route: Route) {
        path.append(route)
    }
    
    func navigateBack() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func navigateToRoot() {
        path.removeLast(path.count)
    }
}
