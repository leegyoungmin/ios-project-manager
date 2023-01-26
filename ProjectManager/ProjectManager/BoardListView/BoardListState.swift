//
//  BoardListState.swift
//  ProjectManager
//
//  Copyright (c) 2023 Minii All rights reserved.

import Foundation
import ComposableArchitecture

struct BoardListState: Equatable {
  var projects: [Project] = []
  var status: ProjectState
  
  var selectedProject: DetailState?
  
  var targetItem: Project?
  
}

enum BoardListAction {
  // User Action
  case didDelete(IndexSet)
  case tapDetailShow(Project)
  case movingToTodo(Project)
  case movingToDoing(Project)
  case movingToDone(Project)
  
  // Inner Action
  case _createDetailState(Project)
  case _dismissItem
  
  // Child Action
  case detailAction(DetailAction)
}

struct BoardListEnvironment {
  init() { }
}

let boardListReducer = Reducer<BoardListState, BoardListAction, BoardListEnvironment>.combine([
  detailReducer
    .optional()
    .pullback(
      state: \.selectedProject,
      action: /BoardListAction.detailAction,
      environment: { _ in DetailEnvironment()}
    ),
  Reducer<BoardListState, BoardListAction, BoardListEnvironment> { state, action, environment in
    switch action {
    case let .didDelete(indexSet):
      indexSet.forEach { state.projects.remove(at: $0) }
      return .none
      
    case let .tapDetailShow(project):
      return Effect(value: ._createDetailState(project))
      
    case let ._createDetailState(project):
      let existingState = DetailState(id: project.id, title: project.title, description: project.description, deadLineDate: project.date, editMode: true)
      state.selectedProject = existingState
      return .none
      
    case ._dismissItem:
      state.selectedProject = nil
      return .none
      
    case .detailAction(.didDoneTap):
      guard let selectedState = state.selectedProject else {
        return .none
      }
      
      let newItem = Project(
        id: selectedState.id,
        title: selectedState.title,
        date: selectedState.deadLineDate,
        description: selectedState.description,
        state: state.status
      )
      
      guard let index = state.projects.firstIndex(where: { $0.id == newItem.id }) else {
        return .none
      }
      
      state.projects[index] = newItem
      
      return Effect(value: ._dismissItem)
    default:
      return .none
    }
  }
])