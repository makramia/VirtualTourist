//
//  Photo+Extensions.swift
//  Virtual Tourist
//
//  Created by makramia on 26/01/2019.
//  Copyright © 2019 makramia. All rights reserved.
//

import Foundation
import CoreData

extension Photo {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
}
