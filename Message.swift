//
//  Message.swift
//  Seecret
//
//  Created by Matthew D'Arcy on 10/9/15.
//  Copyright (c) 2015 Matt D'Arcy. All rights reserved.
//

import Foundation
import CoreData
@objc(Message)
class Message: NSManagedObject {

    @NSManaged var chatObjectId: String
    @NSManaged var createdAt: String
    @NSManaged var messageText: String
    @NSManaged var senderObjectId: String
    @NSManaged var chatMessage: Chat

}
