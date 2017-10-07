//
//  ErrorHandling.swift
//  EuroFlipBook
//
//  Created by Stephen Martinez on 10/7/17.
//  Copyright © 2017 Stephen Martinez. All rights reserved.
//

import Foundation

enum NetworkError: LocalizedError{
    case general
    case invalidLogIn
    case JSONToData
    case DataToJSON
    case differentObject(description: String)
    case emptyObject(domain: String)
    case nonOKHTTP(status: Int)
    case noDataReturned(domain: String)
    case invalidAPIPath(domain: String)
    case invalidPostingData(domain: String, data: String)
    case invalidPutData(domain: String, data: String)
    case invalidDeleteData(domain: String, data: String)
    
    var localizedDescription: String{
        switch self{
        case .general:
            return "The task could not be completed due to a Network Request Error"
        case .invalidLogIn:
            return "Invalid Password/Username Combination"
        case .JSONToData:
            return "Error with converting Swift Object to JSON Object (DATA), check values!"
        case .DataToJSON:
            return "Error with converting JSON Object (DATA) to Swift Object, check values!"
        case .differentObject(description: let explain):
            return "Network returned with unexpected object: \(explain)"
        case .emptyObject(domain: let method):
            return "An empty object/No content was returned by \(method)"
        case .nonOKHTTP(status: let statusNumber):
            return "A Non 2XX (OK) HTTP Status code of \(statusNumber) was given"
        case .noDataReturned(domain: let method):
            return "No data was returned from \(method)"
        case .invalidAPIPath(domain: let method):
            return "The API Structure Does not match the expected path traversed in \(method)"
        case .invalidPostingData(domain: let method, data: let description):
            return "The invalid data: \(description) was rejected from \(method)"
        case .invalidPutData(domain: let method, data: let description):
            return "The invalid data: \(description) was rejected from \(method)"
        case .invalidDeleteData(domain: let method, data: let description):
            return "The invalid data: \(description) was rejected from \(method)"
        }
    }
}
