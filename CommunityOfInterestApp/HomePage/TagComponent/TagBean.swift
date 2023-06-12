//
//  TagBean.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 10/4/2023.
//

import Foundation




// a struct for tag
struct TagBean {
    private var name: String
    var content: String
    
    // content has two space to split another tag bean
    init(name: String) {
        self.name = name
        self.content = " " + self.name + " "
    }
    
    public func getContent() -> String{
        return self.content
    }
    
    public func getName() -> String{
        return self.name
    }
    
    
}



