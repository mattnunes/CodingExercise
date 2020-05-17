//
// User+PhoneNumbers.swift
// Copyright © 2020 Matt Nunes-Spraggs
//


import Foundation

extension User {

    struct PhoneNumbers: Codable, Equatable {
        let home: String
        let cell: String
    }

}
