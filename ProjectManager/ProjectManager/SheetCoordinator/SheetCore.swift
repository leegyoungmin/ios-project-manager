//
//  NavigationStore.swift
//  ProjectManager
//
//  Copyright (c) 2023 Minii All rights reserved.

import ComposableArchitecture

struct SheetState: Equatable {
  var isPresent: Bool = false
  var title: String = "Project Manager"
  var detailState: DetailState?
  
  var createdProject: Project?
}

enum SheetAction {
  // User Action
  case didTapPresent(Bool)
  case detailAction(DetailAction)
  
  // Inner Action
}

struct SheetEnvironment {
  init() { }
}

let sheetReducer = Reducer<SheetState, SheetAction, SheetEnvironment>.combine([
  detailReducer
    .optional()
    .pullback(
      state: \.detailState,
      action: /SheetAction.detailAction,
      environment: { _ in DetailEnvironment() }
    ),
  
  Reducer<SheetState, SheetAction, SheetEnvironment> { state, action, environment in
    switch action {
    case let .didTapPresent(isPresent):
      if isPresent {
        state.isPresent = true
        state.detailState = DetailState()
        return .none
      } else {
        state.isPresent = false
        state.detailState = nil
        return .none
      }
      
    case .detailAction(.didDoneTap):
      guard let detail = state.detailState else { return .none }
      state.createdProject = Project(
        title: detail.title,
        date: Int(detail.deadLineDate.timeIntervalSince1970),
        description: detail.description
      )
      return Effect(value: .didTapPresent(false))
      
    case .detailAction(.didCancelTap):
      return Effect(value: .didTapPresent(false))
      
    case .detailAction:
      return .none
    }
  }
])