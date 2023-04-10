//
//  TagManager.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 10/4/2023.
//

import Foundation



class TagManager{
    
    static let shared = TagManager()
    
    var TagList:[TagBean] = []
    
    func addTag(name: String) {
        TagList.append(TagBean(name: name))
    }
    
    func addTagInstance(tag: TagBean) {
        TagList.append(tag)
    }
    
    func removeTag(name: String) -> TagBean {
        return TagList.remove(at: TagList.firstIndex(where: {$0.getContent() == (" "+name+" ")})!)
    }
    
    func removeTagInstance(tag: TagBean) -> TagBean {
        return TagList.remove(at: TagList.firstIndex(where: {$0.getContent() == tag.getContent()})!)
    }
    
    func getAllTag() -> [TagBean] {
        return TagList
    }
    
    private init(){
        TEST_DATA_FUNCTION()
    }
    
    
    
    
    // ONLY TEST
    func TEST_DATA_FUNCTION(){
        addTagInstance(tag: TagBean(name: "Title 1"))
        addTagInstance(tag: TagBean(name: "Title 2"))
        addTagInstance(tag: TagBean(name: "Food"))
        addTagInstance(tag: TagBean(name: "Ball"))
        addTagInstance(tag: TagBean(name: "Nature"))
        addTagInstance(tag: TagBean(name: "djaisodjioas"))
        addTagInstance(tag: TagBean(name: "Title"))
        addTagInstance(tag: TagBean(name: "Tit"))
    }
    
    
}

