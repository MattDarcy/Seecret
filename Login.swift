//
//  Login.swift
//  
//
//  Created by 매튜달시 on 10/21/15.
//
//

import Foundation
import CoreData
@objc(Login)
class Login: NSManagedObject {
    @NSManaged var username: String
    @NSManaged var password: String
}
