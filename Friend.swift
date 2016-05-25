//
//  Friend.swift
//  Seecret
//
//  Created by Matthew D'Arcy on 10/9/15.
//  Copyright (c) 2015 Matt D'Arcy. All rights reserved.
//

import Foundation
import CoreData
@objc(Friend)
class Friend: NSManagedObject {

    @NSManaged var friendDisplayName: String
    @NSManaged var friendObjectId: String
    @NSManaged var friendPhoto: NSData
    @NSManaged var friendUsername: String

}
