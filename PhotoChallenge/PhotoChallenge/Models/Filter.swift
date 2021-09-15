//
//  Filter.swift
//  PhotoChallenge
//
//  Created by Andres Liu on 9/14/21.
//

import UIKit

struct Filter {
    let filterName: String
    var filterEffectValue: Any?
    var filterEffectValueName: String?
    
    init(filterName: String, filterEffectValue: Any?, filterEffectValueName: String?) {
        self.filterName = filterName
        self.filterEffectValue = filterEffectValue
        self.filterEffectValueName = filterEffectValueName
    }
}

