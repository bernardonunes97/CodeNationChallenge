//
//  Message.swift
//  CodeNationChallenge
//
//  Created by Bernardo Nunes on 04/05/20.
//  Copyright © 2020 Bernardo Nunes. All rights reserved.
//

import Foundation

struct Message: Codable {
    var numero_casas: Int 
    var token: String
    var cifrado: String
    var decifrado: String
    var resumo_criptografico: String
}
