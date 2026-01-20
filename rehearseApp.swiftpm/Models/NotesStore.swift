//
//  NotesStore.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 1/17/26.
//

import Foundation

@MainActor
final class NotesStore {
    static let shared = NotesStore()
    private init() {}

    var currentNotes: String?
}
