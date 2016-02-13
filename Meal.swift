//
//  Meal.swift
//  RateThisMeal
//
//  Created by Trevor Griffin on 2/10/16.
//  Copyright © 2016 TREVOR E GRIFFIN. All rights reserved.
//

import UIKit

class Meal: NSObject, NSCoding {

    // MARK: Properties
    var name: String
    var photo: UIImage?
    var rating: Int
    var comment: String?
    
    // MARK: Archiving Paths
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("meals")
    
    // MARK: Types
    struct PropertyKey {
        static let nameKey = "name"
        static let photoKey = "photo"
        static let ratingKey = "rating"
        static let comment = "comment"
    }

    // MARK: Initialization
    init?(name: String, photo: UIImage?, rating: Int, comment: String?) {
        // Initialize stored properties.
        self.name = name
        self.photo = photo
        self.rating = rating
        self.comment = comment
        
        // Initialize NS(Coding? Object?) superclass
        super.init()
        
        // Initialization should fail if there is no name or if the rating is negative.
        if name.isEmpty || rating < 0 {
            return nil
        }
    }
    
    // MARK: NSCoding
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: PropertyKey.nameKey)
        aCoder.encodeObject(photo, forKey: PropertyKey.photoKey)
        aCoder.encodeInteger(rating, forKey: PropertyKey.ratingKey)
        aCoder.encodeObject(comment, forKey: PropertyKey.comment)
    }

    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObjectForKey(PropertyKey.nameKey) as! String
        
        // Because photo is an optional property of Meal, use conditional cast (ie. "as?")
        let photo = aDecoder.decodeObjectForKey(PropertyKey.photoKey) as? UIImage
        
        let rating = aDecoder.decodeIntegerForKey(PropertyKey.ratingKey)
        
        // Because comment is an optional property of Meal, use conditional cast
        let comment = aDecoder.decodeObjectForKey(PropertyKey.comment) as? String
        
        // Must call designated initializer.
        self.init(name: name, photo: photo, rating: rating, comment: comment)
    }
}

