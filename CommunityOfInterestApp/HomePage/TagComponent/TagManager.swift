//
//  TagManager.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 10/4/2023.
//

import Foundation


// a static class to manage the global Tag Bean
class TagManager{
    
    // static instance of TagManager
    static let shared = TagManager()
    
    var TagList:[TagBean] = []
    
    // add tag method
    func addTag(name: String) {
        if !TagList.contains(where: {$0.getName() == name}){
            TagList.append(TagBean(name: name))
        }
        
    }
    
    // add tag instance
    func addTagInstance(tag: TagBean) {
        if !TagList.contains(where: {$0.getName() == tag.getName()}){
            TagList.append(tag)
        }
        
    }
    
    // remove tag method
    func removeTag(name: String) -> TagBean {
        return TagList.remove(at: TagList.firstIndex(where: {$0.getContent() == (" "+name+" ")})!)
    }
    
    // remove tag instance method
    func removeTagInstance(tag: TagBean) -> TagBean {
        return TagList.remove(at: TagList.firstIndex(where: {$0.getContent() == tag.getContent()})!)
    }
    
    // remove all tags
    func removeAllTags(){
        TagList.removeAll(where: {$0.getName() != "Explore"})
    }
    
    // get all tags
    func getAllTag() -> [TagBean] {
        return TagList
    }
    
    // get all tags without explore tag
    func getAllTagsWithoutExplore() -> [TagBean]{
        // user can manage all tags without explore
        var tags:[TagBean] = []
        TagList.forEach{ tag in
            if tag.getName() != "Explore"{
                tags.append(tag)
            }
            
        }
        return tags
    }
    
    private init(){
        // add default tag
        TagList.append(TagBean(name: "Explore"))
    }

    
    
}

