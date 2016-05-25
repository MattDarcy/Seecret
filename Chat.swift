//
//  Chat.swift
//  Seecret
//
//  Created by Matthew D'Arcy on 10/9/15.
//  Copyright (c) 2015 Matt D'Arcy. All rights reserved.
//

import Foundation
import CoreData
@objc(Chat)
class Chat: NSManagedObject {

    @NSManaged var chatObjectId: String
    @NSManaged var chatTitle: String
    @NSManaged var chatMessage: NSSet
    @NSManaged var chatAcquaintance: NSSet

}
