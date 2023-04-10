//
//  TagBean.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 10/4/2023.
//

import Foundation





struct TagBean {
    private var name: String
    var content: String
    
    init(name: String) {
        self.name = name
        self.content = " " + self.name + " "
    }
    
    public func getContent() -> String{
        return self.content
    }
    
    
    
}



