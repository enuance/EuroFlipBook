//
//  StackType.swift
//  EuroFlipBook
//
//  Created by Stephen Martinez on 10/6/17.
//  Copyright © 2017 Stephen Martinez. All rights reserved.
//

import Foundation

fileprivate class StackElement<Node>{
    var value: Node
    var nextStackElement: StackElement?
    init(value: Node){self.value = value}
}

class Stack<Element>{
    //The stack entry point
    private var top: StackElement<Element>?
    //The very bottom Entity
    var root: Element?{return findRootValue()}
    //The topmost entity
    var showing: Element?{return top?.value}
    //The entity just underneath the topmost
    var underneath: Element?{return top?.nextStackElement?.value}
    //The count of the elements inside the stack
    var count: Int{return findCount()}
    
    func push(_ value: Element){
        let newStackTop = StackElement(value: value)
        newStackTop.nextStackElement = top
        top = newStackTop
    }
    
    func pop() -> Element?{
        guard let currentTop = top else{return nil}
        let oldTop = currentTop
        top = oldTop.nextStackElement
        return oldTop.value
    }
    
    //Recursively Finds how many Elements have been pushed
    private func findCount(stackElement: StackElement<Element>? = nil, isStarting: Bool = true, _ currentCount: Int = 0) -> Int{
        if isStarting{return findCount(stackElement: top, isStarting: false)}
        if let stackElement = stackElement{
            let newCount = currentCount + 1
            return findCount(stackElement: stackElement.nextStackElement, isStarting: false, newCount)
        }
        return currentCount
    }
    
    //Recursively Finds the root value
    private func findRootValue(stackElement: StackElement<Element>? = nil, isStarting: Bool = true) -> Element?{
        if isStarting{return findRootValue(stackElement: top, isStarting: false)}
        if let nextStackElement = stackElement?.nextStackElement{
            return findRootValue(stackElement: nextStackElement, isStarting: false)}
        return stackElement?.value
    }
    
}
