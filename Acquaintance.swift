//
//  Acquaintance.swift
//  Seecret
//
//  Created by Matthew D'Arcy on 10/9/15.
//  Copyright (c) 2015 Matt D'Arcy. All rights reserved.
//

import Foundation
import CoreData
@objc(Acquaintance)
class Acquaintance: NSManagedObject {

    @NSManaged var acqDisplayName: String
    @NSManaged var acqUsername: String
    @NSManaged var acqObjectId: String
    @NSManaged var acqImage: NSData
    @NSManaged var acqAdminBool: NSNumber
    @NSManaged var chatAcquaintance: Chat

}
